@echo off
echo ========================================
echo Upload Documents to RAG Knowledge Base
echo ========================================
echo.

cd backend\rag_service

echo Checking if RAG service is running...
curl -s http://localhost:5002/health > nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: RAG service is not running!
    echo Please start it first with: start-rag-service.bat
    echo.
    pause
    exit /b 1
)

echo RAG service is running!
echo.

python upload_documents.py %*

pause
