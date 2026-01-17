# 🤖 F-Buddy RAG (Retrieval Augmented Generation) Feature

## Overview

The RAG feature adds an **AI-powered Financial Advisor chatbot** to the Personal Finance Manager section. Users can ask questions about personal finance, investments, budgeting, and money management, and get answers based on curated financial advisory documents uploaded by admins.

---

## 🏗️ Architecture

### Technology Stack:
- **Vector Database**: Pinecone (stores document embeddings)
- **Embeddings**: HuggingFace sentence-transformers/all-MiniLM-L6-v2
- **LLM**: Google Gemini 2.0 Flash (generates answers)
- **Document Processing**: LangChain + docx2txt
- **Backend**: Flask (Python) on port 5002
- **Frontend**: Flutter (Dart) with custom chat widget

### How It Works:
```
1. Admin uploads DOCX files → Split into chunks → Generate embeddings → Store in Pinecone
2. User asks question → Generate query embedding → Search Pinecone for relevant chunks
3. Retrieved chunks + Query → Gemini AI → Generate contextual answer
4. Display answer to user with sources
```

---

## 📁 Project Structure

```
F-Buddy/
├── backend/
│   └── rag_service/
│       ├── rag_server.py          # Flask server for RAG
│       ├── upload_documents.py    # Admin upload script
│       ├── requirements.txt       # Python dependencies
│       ├── .env.example           # Environment template
│       └── uploads/               # Temporary file storage
│
├── mobile/
│   └── lib/
│       ├── widgets/
│       │   └── rag_chat_widget.dart    # Chat UI widget
│       └── services/
│           └── rag_service.dart        # RAG API client
│
├── start-rag-service.bat          # Start RAG server
└── upload-rag-documents.bat       # Upload documents
```

---

## 🚀 Setup Instructions

### 1. Install Python Dependencies

```bash
cd backend\rag_service
pip install -r requirements.txt
```

**Required packages:**
- flask, flask-cors
- pinecone-client
- langchain, langchain-community
- sentence-transformers, torch
- google-generativeai
- docx2txt

### 2. Configure Environment Variables

Create `.env` file in `backend/rag_service/`:

```env
# Pinecone Configuration
PINECONE_API_KEY=your_pinecone_api_key_here
PINECONE_INDEX_NAME=fbuddy-rag

# Google Gemini Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Server Configuration
RAG_SERVICE_PORT=5002
```

#### Get API Keys:

**Pinecone:**
1. Sign up at https://www.pinecone.io/
2. Create a new project
3. Copy API key from dashboard
4. Index will be auto-created on first run

**Google Gemini:**
1. Go to https://makersuite.google.com/app/apikey
2. Create new API key
3. Copy the key

### 3. Start the RAG Service

**Option A: Using Batch File (Recommended)**
```bash
start-rag-service.bat
```

**Option B: Manual Start**
```bash
cd backend\rag_service
python rag_server.py
```

Service will start on: `http://localhost:5002`

### 4. Upload Financial Advisory Documents

**Using Batch File:**
```bash
upload-rag-documents.bat
```

**Using Python Script:**
```bash
cd backend\rag_service
python upload_documents.py path/to/your/documents.docx
```

**Supported Formats:**
- `.docx` (Microsoft Word)
- `.doc` (older Word format)

**What to Upload:**
- Financial planning guides
- Investment advice documents
- Budgeting tips and strategies
- Student finance guides
- Money management tutorials
- Tax planning documents

### 5. Flutter Configuration

The Flutter app automatically connects to the RAG service using the same IP as the main backend but on port 5002.

**No additional configuration needed!** The service will work if:
- RAG service is running on port 5002
- Main backend is configured (already done)

---

## 🎯 Usage

### For Admins (Document Upload):

1. Start RAG service: `start-rag-service.bat`
2. Prepare DOCX files with financial content
3. Run upload script: `upload-rag-documents.bat`
4. Enter file paths when prompted
5. Documents will be processed and indexed

### For Users (Chat):

1. Open F-Buddy app
2. Navigate to **Feature Selection** → **Personal Finance Manager**
3. Look for **chat button** in bottom-right corner
4. Click to open chat interface
5. Ask questions about finance:
   - "How should I budget my monthly income?"
   - "What is an emergency fund?"
   - "How to start investing as a student?"
   - "Tips for saving money in college?"
6. Get AI-powered answers based on uploaded documents

---

## 📡 API Endpoints

### Health Check
```
GET /health
Response: {status: "OK", message: "RAG Service is running"}
```

### Upload Documents
```
POST /upload-documents
Content-Type: multipart/form-data
Body: files[] = [file1.docx, file2.docx, ...]

Response: {
  success: true,
  total_chunks: 250,
  results: [{filename, chunks, success}, ...]
}
```

### Chat Query
```
POST /chat
Content-Type: application/json
Body: {query: "How to save money?"}

Response: {
  success: true,
  answer: "Here are some tips...",
  sources: ["document1.docx", "document2.docx"],
  context_used: 5
}
```

### Get Statistics
```
GET /stats
Response: {
  success: true,
  total_vectors: 500,
  dimension: 384,
  index_name: "fbuddy-rag"
}
```

---

## 🎨 Chat Widget Features

- **Floating Action Button**: Opens/closes chat
- **Animated Interface**: Smooth expand/collapse animation
- **Message History**: Keeps conversation context
- **Typing Indicator**: Shows when AI is thinking
- **Source Attribution**: Displays which documents were used
- **Error Handling**: Graceful fallback on connection issues
- **Responsive Design**: Works on all screen sizes
- **Dark Mode Support**: Follows app theme

---

## 🔍 Technical Details

### Document Processing:
1. Load DOCX with `Docx2txtLoader`
2. Split into 500-char chunks (100-char overlap)
3. Sanitize text (remove non-ASCII)
4. Generate embeddings (384-dimensional)
5. Store in Pinecone with metadata

### Query Processing:
1. Embed user query
2. Search Pinecone (top 5 similar chunks)
3. Extract text + sources from matches
4. Build prompt with context
5. Send to Gemini for answer generation
6. Return formatted response

### Gemini Prompt Template:
```
You are a helpful financial advisor AI assistant for F-Buddy.

CONTEXT:
{retrieved_chunks}

USER QUESTION:
{user_query}

Instructions:
- Provide clear, concise answer based ONLY on context
- Be friendly and encouraging to students
- Keep response under 200 words
```

---

## 🐛 Troubleshooting

### RAG Service Won't Start

**Issue**: Import errors
```bash
pip install -r requirements.txt --upgrade
```

**Issue**: Port 5002 already in use
```bash
# Windows: Find and kill process
netstat -ano | findstr :5002
taskkill /PID <process_id> /F
```

### Document Upload Fails

**Issue**: File too large
- Max file size: 50MB
- Split large documents into smaller files

**Issue**: Invalid format
- Only `.docx` and `.doc` supported
- Convert PDFs to DOCX first

### Chat Not Working

**Issue**: Service not running
```bash
curl http://localhost:5002/health
```

**Issue**: Wrong IP configuration
- Check `mobile/lib/services/rag_service.dart`
- Should use same IP as main API

**Issue**: No documents uploaded
```bash
# Check stats
curl http://localhost:5002/stats
```

### Pinecone Errors

**Issue**: Index not found
- Service auto-creates index on first run
- Check API key in `.env`

**Issue**: Quota exceeded
- Free tier: 1 index, 100K vectors
- Upgrade plan or delete old data

---

## 📊 Performance Considerations

- **First Query**: ~2-3 seconds (model loading)
- **Subsequent Queries**: ~1-2 seconds
- **Document Upload**: ~1-2 sec per page
- **Memory Usage**: ~500MB (embedding model)
- **Storage**: Pinecone cloud (no local storage)

---

## 🔐 Security Notes

- RAG service runs on separate port (5002)
- No authentication on RAG endpoints (admin-only backend)
- Documents stored only in Pinecone (encrypted)
- Temporary files deleted after upload
- API keys in `.env` (gitignored)

---

## 🚧 Future Enhancements

- [ ] Support PDF document upload
- [ ] Multi-document chat sessions
- [ ] Document management UI
- [ ] Chat history persistence
- [ ] Voice input/output
- [ ] Multi-language support
- [ ] Real-time collaboration
- [ ] Admin analytics dashboard

---

## 📝 Example Use Cases

1. **Budget Planning**
   - "How should I allocate my monthly allowance?"
   - Get personalized budgeting advice

2. **Investment Guidance**
   - "What are the best investment options for students?"
   - Learn about SIPs, mutual funds, FDs

3. **Saving Tips**
   - "How can I save money while in college?"
   - Discover practical saving strategies

4. **Financial Literacy**
   - "What is compound interest?"
   - Understand financial concepts easily

5. **Tax Planning**
   - "How to save tax as a student?"
   - Get tax optimization tips

---

## 📞 Support

For issues or questions:
1. Check logs in RAG service terminal
2. Verify API keys are correct
3. Ensure documents are uploaded
4. Check Flutter console for errors
5. Review this documentation

---

## ✅ Quick Start Checklist

- [ ] Python installed (3.8+)
- [ ] Pinecone account created
- [ ] Gemini API key obtained
- [ ] `.env` file configured
- [ ] Dependencies installed
- [ ] RAG service started
- [ ] Documents uploaded
- [ ] Flutter app tested
- [ ] Chat widget working

---

**Last Updated**: January 17, 2026
**Version**: 1.0.0
**Powered by**: Pinecone + Google Gemini + LangChain
