"""
RAG (Retrieval Augmented Generation) Service for F-Buddy
Uses Pinecone for vector storage and Gemini for answer generation
Processes DOCX files uploaded by admin for financial advisory
"""

import os
import uuid
import re
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
from pinecone import Pinecone, ServerlessSpec
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.document_loaders import Docx2txtLoader, PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
import google.generativeai as genai
from werkzeug.utils import secure_filename

# Load environment variables
load_dotenv()

# Configuration
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME", "fbuddy-rag")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
ALLOWED_EXTENSIONS = {'docx', 'doc', 'pdf'}
TOP_K = 7

# Create upload folder if not exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Initialize Flask app
app = Flask(__name__)
CORS(app, origins='*')
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max file size

# Global clients (initialized on first request)
pc_client = None
index = None
embeddings = None
gemini_model = None

def sanitize_text(text: str) -> str:
    """Sanitize text to remove problematic characters"""
    if not text:
        return ""
    # Remove non-ASCII characters
    text = text.encode('ascii', 'ignore').decode('ascii')
    # Remove control characters except newlines
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]', '', text)
    return text.strip()

def init_clients():
    """Initialize Pinecone, Embeddings, and Gemini clients"""
    global pc_client, index, embeddings, gemini_model
    
    if pc_client is not None:
        return  # Already initialized
    
    try:
        print("🔧 Initializing RAG clients...")
        
        # Initialize Pinecone
        pc_client = Pinecone(api_key=PINECONE_API_KEY)
        
        # Check/Create index
        try:
            index = pc_client.Index(PINECONE_INDEX_NAME)
            print(f"✅ Connected to Pinecone index: {PINECONE_INDEX_NAME}")
        except Exception as e:
            print(f"⚠️ Index not found, creating: {PINECONE_INDEX_NAME}")
            pc_client.create_index(
                name=PINECONE_INDEX_NAME,
                dimension=384,
                metric="cosine",
                spec=ServerlessSpec(
                    cloud='aws',
                    region='us-east-1'
                )
            )
            import time
            time.sleep(3)
            index = pc_client.Index(PINECONE_INDEX_NAME)
            print(f"✅ Created Pinecone index: {PINECONE_INDEX_NAME}")
        
        # Initialize embeddings model
        embeddings = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2",
            model_kwargs={"device": "cpu"},
            encode_kwargs={"normalize_embeddings": True}
        )
        print("✅ Loaded embedding model")
        
        # Initialize Gemini
        genai.configure(api_key=GEMINI_API_KEY)
        gemini_model = genai.GenerativeModel("gemini-2.5-flash-lite")
        print("✅ Initialized Gemini model")
        
    except Exception as e:
        print(f"❌ Error initializing clients: {str(e)}")
        raise

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'OK',
        'message': 'RAG Service is running',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/upload-documents', methods=['POST'])
def upload_documents():
    """Upload and ingest DOCX documents into Pinecone"""
    try:
        # Initialize clients if not already done
        if pc_client is None:
            init_clients()
        
        # Check if files are present
        if 'files' not in request.files:
            return jsonify({'success': False, 'message': 'No files provided'}), 400
        
        files = request.files.getlist('files')
        if not files or files[0].filename == '':
            return jsonify({'success': False, 'message': 'No files selected'}), 400
        
        results = []
        total_chunks = 0
        
        for file in files:
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                filepath = os.path.join(UPLOAD_FOLDER, f"{uuid.uuid4()}_{filename}")
                file.save(filepath)
                
                try:
                    # Load document based on file type
                    print(f"📄 Loading document: {filename}")
                    if filename.lower().endswith('.pdf'):
                        loader = PyPDFLoader(filepath)
                    else:
                        loader = Docx2txtLoader(filepath)
                    docs = loader.load()
                    
                    # Split into chunks
                    print("✂️ Splitting into chunks...")
                    splitter = RecursiveCharacterTextSplitter(
                        chunk_size=500,
                        chunk_overlap=100
                    )
                    chunks = splitter.split_documents(docs)
                    
                    # Embed and upload to Pinecone
                    print(f"🚀 Uploading {len(chunks)} chunks to Pinecone...")
                    vectors_to_upsert = []
                    
                    for doc in chunks:
                        text = sanitize_text(doc.page_content)
                        if not text:
                            continue
                        
                        embedding = embeddings.embed_query(text)
                        point_id = str(uuid.uuid4())
                        
                        vectors_to_upsert.append({
                            "id": point_id,
                            "values": embedding,
                            "metadata": {
                                "text": text,
                                "source": filename,
                                "uploaded_at": datetime.now().isoformat()
                            }
                        })
                    
                    # Upsert in batches
                    batch_size = 100
                    for i in range(0, len(vectors_to_upsert), batch_size):
                        batch = vectors_to_upsert[i:i + batch_size]
                        index.upsert(vectors=batch)
                    
                    total_chunks += len(vectors_to_upsert)
                    results.append({
                        'filename': filename,
                        'chunks': len(vectors_to_upsert),
                        'success': True
                    })
                    
                    print(f"✅ Successfully ingested {filename}")
                    
                except Exception as e:
                    results.append({
                        'filename': filename,
                        'error': str(e),
                        'success': False
                    })
                    print(f"❌ Error processing {filename}: {str(e)}")
                
                finally:
                    # Cleanup file
                    if os.path.exists(filepath):
                        os.unlink(filepath)
            else:
                results.append({
                    'filename': file.filename,
                    'error': 'Invalid file type',
                    'success': False
                })
        
        return jsonify({
            'success': True,
            'message': f'Processed {len(files)} files, ingested {total_chunks} chunks',
            'results': results,
            'total_chunks': total_chunks
        })
        
    except Exception as e:
        print(f"❌ Upload error: {str(e)}")
        return jsonify({
            'success': False,
            'message': str(e)
        }), 500

@app.route('/chat', methods=['POST'])
def chat():
    """Handle chat queries using RAG pipeline"""
    try:
        # Initialize clients if not already done
        if pc_client is None:
            init_clients()
        
        data = request.get_json()
        if not data or 'query' not in data:
            return jsonify({'success': False, 'message': 'Query is required'}), 400
        
        query = data['query']
        
        # Retrieve relevant chunks from Pinecone
        print(f"🔍 Searching for: {query}")
        query_vec = embeddings.embed_query(query)
        
        results = index.query(
            vector=query_vec,
            top_k=TOP_K,
            include_metadata=True
        )
        
        # Extract context
        context_chunks = []
        sources = []
        for match in results.get("matches", []):
            if match.get("metadata"):
                context_chunks.append(match["metadata"]["text"])
                source = match["metadata"].get("source", "Unknown")
                if source not in sources:
                    sources.append(source)
        
        if not context_chunks:
            return jsonify({
                'success': True,
                'answer': "I don't have any relevant information to answer your question. Please ensure financial advisory documents are uploaded.",
                'sources': []
            })
        
        # Generate answer using Gemini
        context = "\n\n".join(context_chunks)
        
        prompt = f"""You are a helpful financial advisor AI assistant for F-Buddy, a student finance management app.

CONTEXT (from financial advisory documents):
{context}

USER QUESTION:
{query}

Instructions:
- Provide a clear, concise, and helpful answer based ONLY on the context above
- If the context doesn't contain relevant information, politely say so
- For financial advice, always remind users to consult with professionals for major decisions
- Be friendly and encouraging, especially to students
- Keep your response under 200 words

Answer:"""

        print("🤖 Generating answer with Gemini...")
        # Re-configure API key before each request (ensures it's set)
        genai.configure(api_key=GEMINI_API_KEY)
        response = gemini_model.generate_content(prompt)
        answer = response.text
        
        print(f"✅ Generated answer ({len(answer)} chars)")
        
        return jsonify({
            'success': True,
            'answer': answer,
            'sources': sources,
            'context_used': len(context_chunks)
        })
        
    except Exception as e:
        print(f"❌ Chat error: {str(e)}")
        return jsonify({
            'success': False,
            'message': str(e)
        }), 500

@app.route('/stats', methods=['GET'])
def get_stats():
    """Get statistics about indexed documents"""
    try:
        if pc_client is None:
            init_clients()
        
        stats = index.describe_index_stats()
        
        return jsonify({
            'success': True,
            'total_vectors': stats.get('total_vector_count', 0),
            'dimension': stats.get('dimension', 384),
            'index_name': PINECONE_INDEX_NAME
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': str(e)
        }), 500

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Starting F-Buddy RAG Service")
    print("=" * 60)
    
    # Initialize clients on startup
    try:
        init_clients()
        print("\n✅ RAG Service ready!")
    except Exception as e:
        print(f"\n❌ Failed to initialize: {e}")
        print("Service will attempt to initialize on first request")
    
    print("\n📡 Starting Flask server on port 5002...")
    print("=" * 60)
    
    app.run(host='0.0.0.0', port=5002, debug=True)
