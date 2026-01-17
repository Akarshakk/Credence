#!/usr/bin/env python3
"""
CRUDENCE UI Enhancement Script
Automatically updates all Dart UI files with Crudence design system
"""

import os
import re
from pathlib import Path

# Base directory
BASE_DIR = Path("mobile/lib")

# Files to process
TARGET_PATTERNS = [
    "**/*_screen.dart",
    "**/*_page.dart",
    "**/*_calculator.dart",
    "**/feature_selection_screen.dart",
    "**/splash_screen.dart",
]

# Brand replacements (UI text only)
BRAND_REPLACEMENTS = {
    r'\bF-Buddy\b': 'Crudence',
    r'\bf-buddy\b': 'Crudence',
    r'\bF Buddy\b': 'Crudence',
    r"'Welcome to F-Buddy'": "'Welcome to Crudence'",
    r'"Welcome to F-Buddy"': '"Welcome to Crudence"',
    r"'F Buddy'": "'Crudence'",
    r'"F Buddy"': '"Crudence"',
}

# Color replacements (hardcoded to theme)
COLOR_REPLACEMENTS = {
    # Teal/Orange to Purple
    r'Color\(0xFF0F766E\)': 'AppColors.primary',
    r'Color\(0xFF14B8A6\)': 'AppColors.primary',
    r'Color\(0xFFF97316\)': 'AppColors.secondary',
    r'Color\(0xFFFB923C\)': 'AppColors.secondary',
    
    # Status colors
    r'Colors\.green(?!\.shade)': 'AppColors.success',
    r'Colors\.red(?!\.shade)': 'AppColors.error',
    r'Colors\.orange(?!\.shade)': 'AppColors.warning',
    r'Colors\.blue(?!\.shade)': 'AppColors.info',
    
    # Text colors
    r'Colors\.black87': 'AppColors.textPrimary',
    r'Colors\.grey\[600\]': 'AppColors.textSecondary',
    r'Colors\.grey\[700\]': 'AppColors.textPrimary',
}

# Border radius replacements
BORDER_RADIUS_REPLACEMENTS = {
    # Cards should be 20px
    r'borderRadius:\s*BorderRadius\.circular\(12\)(?=.*Card)': 'borderRadius: BorderRadius.circular(20)',
    r'BorderRadius\.circular\(12\)(?=.*shape:.*Card)': 'BorderRadius.circular(20)',
    
    # Buttons should be 12px (already correct, but ensure)
    r'borderRadius:\s*BorderRadius\.circular\(10\)(?=.*Button)': 'borderRadius: BorderRadius.circular(12)',
    r'borderRadius:\s*BorderRadius\.circular\(8\)(?=.*Button)': 'borderRadius: BorderRadius.circular(12)',
}

# Typography replacements
TYPOGRAPHY_REPLACEMENTS = {
    r'fontSize:\s*32.*fontWeight:\s*FontWeight\.bold': 'style: AppTextStyles.heading1',
    r'fontSize:\s*24.*fontWeight:\s*FontWeight\.bold': 'style: AppTextStyles.heading2',
    r'fontSize:\s*18.*fontWeight:\s*FontWeight\.w600': 'style: AppTextStyles.heading3',
}

def should_process_file(filepath):
    """Check if file should be processed"""
    # Skip test files, generated files, etc.
    skip_patterns = [
        'test',
        '.g.dart',
        '.freezed.dart',
        'generated',
    ]
    
    filepath_str = str(filepath)
    for pattern in skip_patterns:
        if pattern in filepath_str:
            return False
    
    return True

def add_imports_if_missing(content):
    """Add necessary imports if not present"""
    imports_to_add = []
    
    # Check for google_fonts import
    if 'AppTextStyles' in content and 'google_fonts' not in content.lower():
        imports_to_add.append("import 'package:google_fonts/google_fonts.dart';")
    
    # Check for theme import
    if ('AppColors' in content or 'AppTextStyles' in content) and "import '../../config/theme.dart'" not in content:
        # Try to determine correct path
        if '/features/' in str(content):
            imports_to_add.append("import '../../config/theme.dart';")
        elif '/screens/' in str(content):
            imports_to_add.append("import '../config/theme.dart';")
    
    if imports_to_add:
        # Find the last import statement
        import_pattern = r"(import\s+['\"].*['\"];)"
        matches = list(re.finditer(import_pattern, content))
        if matches:
            last_import = matches[-1]
            insert_pos = last_import.end()
            imports_str = '\n' + '\n'.join(imports_to_add)
            content = content[:insert_pos] + imports_str + content[insert_pos:]
    
    return content

def process_file(filepath):
    """Process a single Dart file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Apply brand replacements
        for pattern, replacement in BRAND_REPLACEMENTS.items():
            content = re.sub(pattern, replacement, content)
        
        # Apply color replacements
        for pattern, replacement in COLOR_REPLACEMENTS.items():
            content = re.sub(pattern, replacement, content)
        
        # Apply border radius replacements
        for pattern, replacement in BORDER_RADIUS_REPLACEMENTS.items():
            content = re.sub(pattern, replacement, content)
        
        # Add imports if needed
        content = add_imports_if_missing(content)
        
        # Only write if content changed
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
    
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Main execution"""
    print("🎨 CRUDENCE UI Enhancement Script")
    print("=" * 50)
    
    processed_count = 0
    modified_count = 0
    
    # Find all Dart files
    dart_files = []
    for pattern in TARGET_PATTERNS:
        dart_files.extend(BASE_DIR.glob(pattern))
    
    # Remove duplicates
    dart_files = list(set(dart_files))
    
    print(f"Found {len(dart_files)} Dart files to process\n")
    
    for filepath in dart_files:
        if should_process_file(filepath):
            print(f"Processing: {filepath.relative_to(BASE_DIR)}")
            if process_file(filepath):
                modified_count += 1
                print(f"  ✅ Modified")
            else:
                print(f"  ⏭️  No changes needed")
            processed_count += 1
    
    print("\n" + "=" * 50)
    print(f"✅ Complete!")
    print(f"📊 Processed: {processed_count} files")
    print(f"✏️  Modified: {modified_count} files")
    print(f"⏭️  Skipped: {processed_count - modified_count} files")
    print("\n🎉 All files enhanced with Crudence UI!")

if __name__ == "__main__":
    main()
