import os
import sys
import re
from dotenv import load_dotenv
from pinecone import Pinecone
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from tqdm import tqdm

# --------------------------------
# LOAD ENV
# --------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
PINECONE_ENVIRONMENT = os.getenv("PINECONE_ENVIRONMENT")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME")
PDF_PATH = os.getenv("PDF_PATH") or os.path.join(BASE_DIR, "final_resume.pdf")

EMBEDDING_DIM = 384   # all-MiniLM-L6-v2 output dim

if not PINECONE_API_KEY or not PINECONE_INDEX_NAME:
    raise ValueError("❌ Missing PINECONE_API_KEY or PINECONE_INDEX_NAME in .env")

if not os.path.exists(PDF_PATH):
    raise FileNotFoundError(f"❌ PDF not found: {PDF_PATH}")

# Optional CLI override: python ingest.py <pdf_path>
if len(sys.argv) > 1:
    PDF_PATH = sys.argv[1]


# --------------------------------
# INIT PINECONE CLIENT
# --------------------------------
pc = Pinecone(api_key=PINECONE_API_KEY)
index = pc.Index(PINECONE_INDEX_NAME)


# --------------------------------
# ENSURE INDEX EXISTS
# --------------------------------
def ensure_index():
    print(f"✅ Using Pinecone index: {PINECONE_INDEX_NAME}")


# --------------------------------
# LOAD PDF
# --------------------------------
print(f"📄 Loading PDF: {PDF_PATH}")
loader = PyPDFLoader(PDF_PATH)
docs = loader.load()
print(f"✅ Loaded {len(docs)} pages")


# --------------------------------
# HELPER: SANITIZE TEXT
# --------------------------------
def sanitize_text(text: str) -> str:
    """Remove problematic characters for Pinecone storage"""
    if not text:
        return ""
    text = text.encode('ascii', 'ignore').decode('ascii')
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]', '', text)
    text = re.sub(r'\n{3,}', '\n\n', text)  # Remove excessive newlines
    return text.strip()


# --------------------------------
# SPLIT INTO CHUNKS
# --------------------------------
print("✂️ Splitting text into chunks...")
splitter = RecursiveCharacterTextSplitter(
    chunk_size=400,
    chunk_overlap=80,
    separators=["\n\n", "\n", ".", " "],
    length_function=len
)
chunks = splitter.split_documents(docs)
print(f"✅ Created {len(chunks)} chunks")


# --------------------------------
# LOAD EMBEDDING MODEL
# --------------------------------
print("🧠 Loading embedding model (MiniLM)...")

embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2",
    model_kwargs={'device': 'cpu'},
    encode_kwargs={'normalize_embeddings': True}
)


# --------------------------------
# EMBED + UPLOAD TO PINECONE
# --------------------------------
ensure_index()

print(f"🚀 Uploading {len(chunks)} chunks to Pinecone...\n")

# Get source filename
pdf_filename = os.path.basename(PDF_PATH)

# Prepare texts for batch embedding (use embed_documents for efficiency)
texts_to_embed = []
valid_chunks = []

for idx, doc in enumerate(chunks):
    text = sanitize_text(doc.page_content)
    if text:  # Skip empty chunks
        texts_to_embed.append(text)
        valid_chunks.append((idx, doc, text))

print(f"📊 Processing {len(valid_chunks)} valid chunks (skipped {len(chunks) - len(valid_chunks)} empty)")

# Batch embed all documents at once (more efficient than embed_query one by one)
print("🧠 Generating embeddings...")
all_embeddings = embeddings.embed_documents(texts_to_embed)
print(f"✅ Generated {len(all_embeddings)} embeddings (dim={len(all_embeddings[0])})")

# Prepare vectors - only store text in metadata (simplified)
vectors_to_upsert = []
for i, (chunk_idx, doc, text) in enumerate(tqdm(valid_chunks, desc="Preparing vectors")):
    vector_id = f"{pdf_filename}-chunk-{chunk_idx}"
    
    vectors_to_upsert.append({
        "id": vector_id,
        "values": all_embeddings[i],
        "metadata": {"text": text}
    })

# Upsert in batches
batch_size = 100
print(f"\n💾 Uploading to Pinecone...")
for i in tqdm(range(0, len(vectors_to_upsert), batch_size), desc="Uploading"):
    batch = vectors_to_upsert[i:i + batch_size]
    try:
        index.upsert(vectors=batch)
    except Exception as e:
        print(f"⚠️ Error: {e}")

print(f"\n✅ Done! Ingested {len(vectors_to_upsert)} chunks from '{pdf_filename}'")
