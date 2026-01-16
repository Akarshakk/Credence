# 🚀 Quick Setup Guide - RAG Feature

## 1. Install Python Dependencies (5 minutes)

```bash
cd backend\rag_service
pip install -r requirements.txt
```

## 2. Get API Keys (10 minutes)

### Pinecone API Key:
1. Visit: https://www.pinecone.io/
2. Sign up (free tier available)
3. Create a project
4. Copy API key from dashboard

### Gemini API Key:
1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with Google
3. Click "Create API Key"
4. Copy the key

## 3. Configure Environment (2 minutes)

Create `.env` file in `backend\rag_service\`:

```env
PINECONE_API_KEY=pc-xxxxxxxxxxxxxxxxxxxxx
PINECONE_INDEX_NAME=fbuddy-rag
GEMINI_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 4. Start RAG Service (1 minute)

Double-click: **`start-rag-service.bat`**

Wait for:
```
✅ Connected to Pinecone index: fbuddy-rag
✅ Loaded embedding model
✅ Initialized Gemini model
📡 Starting Flask server on port 5002...
```

## 5. Upload Documents (5 minutes)

1. Prepare DOCX files with financial content
2. Double-click: **`upload-rag-documents.bat`**
3. Enter file paths or drag & drop
4. Wait for upload confirmation

## 6. Test in App (1 minute)

1. Start main backend: `start-backend.bat`
2. Open Flutter app
3. Go to **Personal Finance Manager**
4. Click **chat button** (bottom-right)
5. Ask: "How should I budget my money?"

---

## ✅ Success Indicators

- RAG service shows: `🚀 Starting F-Buddy RAG Service`
- Upload shows: `✅ Upload successful! Total chunks: X`
- Chat responds with relevant financial advice

---

## 🆘 Troubleshooting

### "Module not found" error:
```bash
pip install -r requirements.txt --upgrade
```

### "Port 5002 in use":
```bash
netstat -ano | findstr :5002
taskkill /PID <PID> /F
```

### Chat not responding:
- Check RAG service is running
- Verify documents are uploaded: `curl http://localhost:5002/stats`

---

**Total Setup Time**: ~25 minutes
**Ready to use!** 🎉
