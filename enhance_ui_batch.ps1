# CRUDENCE UI Enhancement - PowerShell Batch Script
# Enhances all Dart UI files with Crudence design system

Write-Host "CRUDENCE UI Enhancement Script" -ForegroundColor Cyan
Write-Host "=" * 50

$basePath = "mobile\lib"
$filesProcessed = 0
$filesModified = 0

# Find all Dart screen/page/calculator files
$dartFiles = Get-ChildItem -Path $basePath -Recurse -Include "*_screen.dart", "*_page.dart", "*_calculator.dart", "feature_selection_screen.dart", "splash_screen.dart"

Write-Host "Found $($dartFiles.Count) Dart files to process`n" -ForegroundColor Yellow

foreach ($file in $dartFiles) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor White
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Brand replacements (UI text only)
    $content = $content -replace '\bF-Buddy\b', 'Crudence'
    $content = $content -replace '\bf-buddy\b', 'Crudence'
    $content = $content -replace '\bF Buddy\b', 'Crudence'
    $content = $content -replace "'Welcome to F-Buddy'", "'Welcome to Crudence'"
    $content = $content -replace '"Welcome to F-Buddy"', '"Welcome to Crudence"'
    
    # Color replacements
    $content = $content -replace 'Color\(0xFF0F766E\)', 'AppColors.primary'
    $content = $content -replace 'Color\(0xFF14B8A6\)', 'AppColors.primary'
    $content = $content -replace 'Color\(0xFFF97316\)', 'AppColors.secondary'
    $content = $content -replace 'Color\(0xFFFB923C\)', 'AppColors.secondary'
    $content = $content -replace 'Color\(0xFFFFC107\)', 'AppColors.primary'
    
    # Border radius for cards (simple approach)
    $content = $content -replace 'borderRadius: BorderRadius\.circular\(12\)', 'borderRadius: BorderRadius.circular(20)'
    $content = $content -replace 'BorderRadius\.circular\(10\)', 'BorderRadius.circular(12)'
    $content = $content -replace 'BorderRadius\.circular\(8\)', 'BorderRadius.circular(12)'
    
    # Check if content changed
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✅ Modified" -ForegroundColor Green
        $filesModified++
    } else {
        Write-Host "  ⏭️  No changes needed" -ForegroundColor Gray
    }
    
    $filesProcessed++
}

Write-Host "`n" + ("=" * 50)
Write-Host "Complete!" -ForegroundColor Green
Write-Host "Processed: $filesProcessed files" -ForegroundColor Cyan
Write-Host "Modified: $filesModified files" -ForegroundColor Yellow
Write-Host "Skipped: $($filesProcessed - $filesModified) files" -ForegroundColor Gray
Write-Host "`nAll files enhanced with Crudence UI!" -ForegroundColor Magenta
