import os
from dotenv import load_dotenv
from pinecone import Pinecone
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.document_loaders import PyPDFLoader, Docx2txtLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
import google.generativeai as genai
import streamlit as st
import tempfile
import re
from typing import List, Dict, Tuple

# -----------------------------
# ENV
# -----------------------------
load_dotenv(override=True)  # Force reload env variables

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# RAG Configuration
TOP_K = 15  # Retrieve more chunks for wider context
MIN_SIMILARITY = 0.30  # Lower threshold for more results
EMBEDDING_DIM = 384  # all-MiniLM-L6-v2 dimension
DEFAULT_CHUNK_SIZE = 400  # Default chunk size for ingestion

# -----------------------------
# HELPER FUNCTIONS
# -----------------------------
def sanitize_text(text: str) -> str:
    """Sanitize text to remove problematic characters for Pinecone"""
    if not text:
        return ""
    # Remove non-ASCII characters that cause encoding issues
    text = text.encode('ascii', 'ignore').decode('ascii')
    # Remove control characters except newlines
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]', '', text)
    # Remove excessive whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r' {2,}', ' ', text)
    return text.strip()


def compute_text_similarity(text1: str, text2: str) -> float:
    """Simple Jaccard similarity for deduplication"""
    words1 = set(text1.lower().split())
    words2 = set(text2.lower().split())
    if not words1 or not words2:
        return 0.0
    intersection = words1 & words2
    union = words1 | words2
    return len(intersection) / len(union)


def deduplicate_chunks(chunks: List[Dict], similarity_threshold: float = 0.85) -> List[Dict]:
    """Remove near-duplicate chunks using simple text similarity"""
    if not chunks:
        return []
    
    unique_chunks = [chunks[0]]
    for chunk in chunks[1:]:
        is_duplicate = False
        for existing in unique_chunks:
            sim = compute_text_similarity(chunk['text'], existing['text'])
            if sim > similarity_threshold:
                is_duplicate = True
                break
        if not is_duplicate:
            unique_chunks.append(chunk)
    return unique_chunks


def clean_context(chunks: List[Dict]) -> str:
    """Clean and format context for the prompt - only text, no metadata"""
    if not chunks:
        return ""
    
    # Deduplicate
    unique_chunks = deduplicate_chunks(chunks)
    
    # Return only the text content
    formatted_parts = []
    for chunk in unique_chunks:
        text = chunk['text'].strip()
        text = re.sub(r'\n\s*\n', '\n', text)
        if text:
            formatted_parts.append(text)
    
    return "\n\n".join(formatted_parts)

# -----------------------------
# INIT CLIENTS
# -----------------------------
@st.cache_resource
def init_clients():
    pc = Pinecone(api_key=PINECONE_API_KEY)
    
    # Check if index exists, if not create it
    try:
        index = pc.Index(PINECONE_INDEX_NAME)
    except Exception as e:
        st.error(f"❌ Index '{PINECONE_INDEX_NAME}' not found. Creating it now...")
        pc.create_index(
            name=PINECONE_INDEX_NAME,
            dimension=384,
            metric="cosine"
        )
        import time
        time.sleep(2)
        index = pc.Index(PINECONE_INDEX_NAME)
        st.success(f"✅ Index '{PINECONE_INDEX_NAME}' created successfully!")
    
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2",
        model_kwargs={"device": "cpu"},
        encode_kwargs={"normalize_embeddings": True}
    )
    
    # Gemini init
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel("gemini-2.5-flash-lite")
    
    return index, embeddings, model

try:
    index, embeddings, model = init_clients()
except Exception as e:
    st.error(f"Failed to initialize clients: {str(e)}")
    st.stop()


# -----------------------------
# RAG RETRIEVAL FUNCTION
# -----------------------------
def is_summary_query(query: str) -> bool:
    """Check if query is asking for summary/overview"""
    summary_keywords = ['summary', 'summarize', 'summarise', 'overview', 'brief', 'main points', 'key points']
    query_lower = query.lower()
    return any(keyword in query_lower for keyword in summary_keywords)


def is_vague_query(query: str) -> bool:
    """Check if query is vague and needs context from conversation"""
    vague_patterns = [
        'more', 'explain', 'elaborate', 'detail', 'tell me more',
        'what about', 'how about', 'and', 'also', 'continue',
        'go on', 'keep going', 'yes', 'okay', 'sure'
    ]
    # Check for pronouns that reference earlier context
    pronouns = ['it', 'this', 'that', 'these', 'those', 'them', 'they', 'its']
    
    query_lower = query.lower().strip()
    words = query_lower.split()
    
    # Very short query (less than 5 words) with pronouns
    if len(words) < 6 and any(p in words for p in pronouns):
        return True
    
    # Contains vague patterns
    if any(pattern in query_lower for pattern in vague_patterns):
        return True
    
    return False


def expand_query_with_context(query: str, conversation_history: List[Dict]) -> str:
    """
    Expand a vague query using conversation history.
    Combines current query with the last user question for better retrieval.
    """
    if not conversation_history or not is_vague_query(query):
        return query
    
    # Find the last user message (not including current)
    last_user_query = None
    last_assistant_response = None
    
    for msg in reversed(conversation_history):
        if msg['role'] == 'user' and last_user_query is None:
            last_user_query = msg['content']
        elif msg['role'] == 'assistant' and last_assistant_response is None:
            last_assistant_response = msg['content']
        if last_user_query and last_assistant_response:
            break
    
    # Combine last question with current query for better retrieval
    if last_user_query:
        # Extract key terms from last exchange
        expanded = f"{last_user_query} {query}"
        return expanded
    
    return query


def retrieve_chunks(query: str, top_k: int = None) -> List[Dict]:
    """
    Retrieve relevant chunks from Pinecone.
    For summary queries, retrieves ALL chunks.
    """
    try:
        query_vec = embeddings.embed_query(query)
        
        # For summary queries, fetch more chunks
        if is_summary_query(query):
            fetch_count = 100
        else:
            fetch_count = top_k if top_k else TOP_K
        
        results = index.query(
            vector=query_vec,
            top_k=fetch_count,
            include_metadata=True
        )
        
        if not results.get('matches'):
            return []
        
        # Extract chunks
        filtered_chunks = []
        for match in results['matches']:
            score = match.get('score', 0)
            metadata = match.get('metadata', {})
            text = metadata.get('text', '')
            
            # For summary, include all; otherwise filter by score
            if is_summary_query(query) or (score >= MIN_SIMILARITY and text):
                filtered_chunks.append({'text': text, 'score': score})
        
        # Sort by score descending
        filtered_chunks.sort(key=lambda x: x['score'], reverse=True)
        
        return filtered_chunks
        
    except Exception as e:
        return []


# -----------------------------
# BUILD FINAL ANSWER (Gemini)
# -----------------------------
def generate_answer(query: str, chunks: List[Dict], conversation_history: List[Dict] = None) -> str:
    """Generate answer using Gemini with strict RAG prompt and conversation history"""
    
    if not chunks:
        return "The provided document does not contain this information. Please upload a relevant document first."
    
    # Clean and format context - only text
    context = clean_context(chunks)
    
    if not context.strip():
        return "The provided document does not contain this information."
    
    # Build conversation history string
    history_str = ""
    if conversation_history and len(conversation_history) > 0:
        # Include last 6 messages (3 exchanges) for context
        recent_history = conversation_history[-6:]
        history_parts = []
        for msg in recent_history:
            role = "User" if msg["role"] == "user" else "Assistant"
            history_parts.append(f"{role}: {msg['content']}")
        history_str = "\n".join(history_parts)
    
    # Strict RAG prompt with conversation history
    prompt = f"""You are a helpful assistant that answers questions ONLY from the provided context.

RULES:
- Answer ONLY using the DOCUMENT CONTEXT below. Do NOT use external knowledge.
- If the answer is not in the context, say exactly: "The provided document does not contain this information."
- Do NOT guess or hallucinate.
- Give clear, detailed answers (3-6 sentences) when possible.
- Use bullet points for lists if appropriate.
- Consider the conversation history for follow-up questions.

DOCUMENT CONTEXT:
{context}
"""
    
    if history_str:
        prompt += f"""\nCONVERSATION HISTORY:
{history_str}
"""
    
    prompt += f"""\nCURRENT QUESTION: {query}

ANSWER:"""

    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        return f"Error generating response: {str(e)}"


# -----------------------------
# DOCUMENT INGESTION FUNCTION
# -----------------------------
def ingest_document(uploaded_file, chunk_size: int = DEFAULT_CHUNK_SIZE) -> Tuple[bool, int]:
    """Ingest PDF or DOCX file into Pinecone"""
    try:
        filename = uploaded_file.name
        file_ext = filename.lower().split('.')[-1]
        
        # Save uploaded file to temp location
        with tempfile.NamedTemporaryFile(delete=False, suffix=f".{file_ext}") as tmp_file:
            tmp_file.write(uploaded_file.read())
            tmp_path = tmp_file.name
        
        # Load document based on type
        with st.spinner("Loading document..."):
            if file_ext == 'pdf':
                loader = PyPDFLoader(tmp_path)
            elif file_ext in ['docx', 'doc']:
                loader = Docx2txtLoader(tmp_path)
            else:
                st.error("Unsupported file type")
                return False, 0
            
            docs = loader.load()
        
        # Split into chunks with configurable size
        chunk_overlap = int(chunk_size * 0.2)  # 20% overlap
        with st.spinner(f"Splitting into chunks (size: {chunk_size})..."):
            splitter = RecursiveCharacterTextSplitter(
                chunk_size=chunk_size,
                chunk_overlap=chunk_overlap,
                separators=["\n\n", "\n", ". ", " "],
                length_function=len
            )
            chunks = splitter.split_documents(docs)
        
        # Prepare texts for batch embedding
        texts_to_embed = []
        valid_chunks_data = []
        
        for idx, doc in enumerate(chunks):
            text = sanitize_text(doc.page_content)
            if text:
                texts_to_embed.append(text)
                valid_chunks_data.append({'idx': idx, 'text': text})
        
        if not valid_chunks_data:
            st.warning("No valid text found in document")
            os.unlink(tmp_path)
            return False, 0
        
        # Batch embed using embed_documents
        with st.spinner("Generating embeddings..."):
            all_embeddings = embeddings.embed_documents(texts_to_embed)
        
        # Prepare vectors (only store text in metadata)
        vectors_to_upsert = []
        for i, chunk_data in enumerate(valid_chunks_data):
            vector_id = f"{filename}-chunk-{chunk_data['idx']}"
            vectors_to_upsert.append({
                "id": vector_id,
                "values": all_embeddings[i],
                "metadata": {"text": chunk_data['text']}
            })
        
        # Upsert in batches
        with st.spinner("Uploading to database..."):
            batch_size = 100
            for i in range(0, len(vectors_to_upsert), batch_size):
                batch = vectors_to_upsert[i:i + batch_size]
                index.upsert(vectors=batch)
        
        # Cleanup
        os.unlink(tmp_path)
        
        st.success(f"✅ Ingested {len(vectors_to_upsert)} chunks from '{filename}'")
        return True, len(vectors_to_upsert)
        
    except Exception as e:
        st.error(f"Error: {str(e)}")
        return False, 0


def wipe_index():
    """Delete all vectors from the Pinecone index"""
    try:
        index.delete(delete_all=True)
        return True
    except Exception as e:
        st.error(f"❌ Error wiping index: {str(e)}")
        return False


# -----------------------------
# STREAMLIT UI
# -----------------------------
st.set_page_config(
    page_title="🚀 Gemini RAG Chatbot",
    page_icon="🤖",
    layout="wide"
)

st.title("🚀 Gemini RAG Chatbot")
st.caption("Ask questions and get answers based on your uploaded documents")

# Sidebar
with st.sidebar:
    st.header("📚 Documents")
    
    # File Upload (PDF or DOCX)
    uploaded_file = st.file_uploader(
        "Upload PDF or DOCX",
        type=["pdf", "docx"],
        help="Add a document to your knowledge base"
    )
    
    # Chunk size slider
    chunk_size = st.slider(
        "Chunk Size",
        min_value=200,
        max_value=800,
        value=DEFAULT_CHUNK_SIZE,
        step=50,
        help="Smaller chunks = more precise retrieval. Larger chunks = more context per chunk."
    )
    
    if uploaded_file is not None:
        if st.button("📤 Upload Document", use_container_width=True, type="primary"):
            success, chunk_count = ingest_document(uploaded_file, chunk_size=chunk_size)
            if success:
                if "ingested_docs" not in st.session_state:
                    st.session_state.ingested_docs = []
                st.session_state.ingested_docs.append({
                    "name": uploaded_file.name,
                    "chunks": chunk_count
                })
    
    st.divider()
    
    # Show ingested documents
    if st.session_state.get("ingested_docs"):
        st.caption("**Uploaded:**")
        for doc in st.session_state.ingested_docs:
            st.caption(f"• {doc['name']}")
    
    st.divider()
    
    # Clear buttons
    col1, col2 = st.columns(2)
    with col1:
        if st.button("🧹 Clear Chat", use_container_width=True):
            st.session_state.messages = []
            st.rerun()
    with col2:
        if st.button("🗑️ Wipe Data", use_container_width=True):
            if wipe_index():
                st.session_state.ingested_docs = []
                st.success("Cleared!")

# Initialize chat history with context storage
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat history
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Chat input
if query := st.chat_input("Ask a question about your documents..."):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": query})
    
    # Display user message
    with st.chat_message("user"):
        st.markdown(query)
    
    # Get AI response
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            # Get conversation history (excluding current message)
            history = st.session_state.messages[:-1]
            
            # Expand vague queries like "explain more on it" using conversation context
            expanded_query = expand_query_with_context(query, history)
            
            # Retrieve chunks using the expanded query
            chunks = retrieve_chunks(expanded_query)
            
            # Pass conversation history for context awareness in generation
            answer = generate_answer(query, chunks, conversation_history=history)
            st.markdown(answer)
    
    # Add assistant response to chat history
    st.session_state.messages.append({"role": "assistant", "content": answer})

# Welcome message
if not st.session_state.messages:
    st.info("👋 Upload a PDF or DOCX in the sidebar, then ask questions about it.")
