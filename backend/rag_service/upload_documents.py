"""
Admin Document Upload Script for F-Buddy RAG Service
Use this script to upload DOCX files to the RAG knowledge base
"""

import os
import requests
import sys
from pathlib import Path

RAG_SERVICE_URL = "http://localhost:5002"

def upload_documents(file_paths):
    """Upload documents to RAG service"""
    
    print("=" * 60)
    print("📚 F-Buddy RAG - Document Upload")
    print("=" * 60)
    
    # Prepare files
    files = []
    for file_path in file_paths:
        if not os.path.exists(file_path):
            print(f"❌ File not found: {file_path}")
            continue
        
        if not file_path.lower().endswith(('.docx', '.doc', '.pdf')):
            print(f"⚠️ Skipping unsupported file: {file_path}")
            continue
        
        filename = os.path.basename(file_path)
        # Determine MIME type based on extension
        if file_path.lower().endswith('.pdf'):
            mime_type = 'application/pdf'
        else:
            mime_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        
        files.append(('files', (filename, open(file_path, 'rb'), mime_type)))
        print(f"✅ Added: {filename}")
    
    if not files:
        print("❌ No valid files to upload")
        return False
    
    print(f"\n🚀 Uploading {len(files)} file(s) to {RAG_SERVICE_URL}...")
    
    try:
        response = requests.post(
            f"{RAG_SERVICE_URL}/upload-documents",
            files=files,
            timeout=300  # 5 minutes timeout for large files
        )
        
        # Close file handles
        for _, file_tuple in files:
            file_tuple[1].close()
        
        if response.status_code == 200:
            data = response.json()
            print("\n✅ Upload successful!")
            print(f"📊 Total chunks ingested: {data.get('total_chunks', 0)}")
            
            if 'results' in data:
                print("\n📄 Results:")
                for result in data['results']:
                    if result.get('success'):
                        print(f"  ✅ {result['filename']}: {result['chunks']} chunks")
                    else:
                        print(f"  ❌ {result['filename']}: {result.get('error', 'Unknown error')}")
            
            return True
        else:
            print(f"\n❌ Upload failed: {response.status_code}")
            print(response.text)
            return False
            
    except requests.exceptions.ConnectionError:
        print("\n❌ Could not connect to RAG service!")
        print("Make sure the service is running: python rag_server.py")
        return False
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        return False

def check_service():
    """Check if RAG service is running"""
    try:
        response = requests.get(f"{RAG_SERVICE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ RAG service is running")
            return True
    except:
        pass
    print("⚠️ RAG service is not responding")
    print("Start it with: python rag_server.py")
    return False

def get_stats():
    """Get RAG database statistics"""
    try:
        response = requests.get(f"{RAG_SERVICE_URL}/stats", timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"\n📊 RAG Database Statistics:")
                print(f"  Total vectors: {data.get('total_vectors', 0)}")
                print(f"  Index name: {data.get('index_name', 'N/A')}")
                return True
    except:
        pass
    return False

def main():
    """Main function"""
    print("\n")
    
    # Check if service is running
    if not check_service():
        return
    
    # Get current stats
    get_stats()
    
    # Get files from command line or prompt
    if len(sys.argv) > 1:
        file_paths = sys.argv[1:]
    else:
        print("\n" + "=" * 60)
        print("📁 Enter DOCX file paths to upload (comma-separated):")
        print("   Or drag and drop files here")
        print("=" * 60)
        input_str = input("> ").strip()
        
        if not input_str:
            print("❌ No files specified")
            return
        
        # Split by comma or space
        file_paths = [p.strip().strip('"').strip("'") for p in input_str.replace(',', ' ').split()]
    
    # Upload documents
    success = upload_documents(file_paths)
    
    if success:
        print("\n🎉 Documents successfully uploaded to knowledge base!")
        get_stats()
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
