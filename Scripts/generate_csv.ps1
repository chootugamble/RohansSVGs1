# PowerShell script to generate CSV file for Icons folders
# This script creates a CSV with folders as rows and files as columns

# Get the current script directory and navigate to the Icons folder
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconsPath = Join-Path $scriptPath "..\Icons"

# Check if Icons folder exists
if (-not (Test-Path $iconsPath)) {
    Write-Host "Error: Icons folder not found at: $iconsPath"
    exit 1
}

# Define the target subdirectories
$targetDirs = @("Monocolor", "Multicolor")
$csvData = @()

Write-Host "Scanning Icons folder for Monocolor and Multicolor subdirectories..."

# Process each target directory
foreach ($targetDir in $targetDirs) {
    $fullPath = Join-Path $iconsPath $targetDir
    
    if (Test-Path $fullPath) {
        Write-Host "Processing: $targetDir"
        
        # Get all subdirectories in the target directory
        $subdirs = Get-ChildItem -Path $fullPath -Directory
        
        foreach ($subdir in $subdirs) {
            Write-Host "  - $($subdir.Name)"
            
            # Get all files in this subdirectory
            $files = Get-ChildItem -Path $subdir.FullName -File
            
            # Create a row for this folder with the specified column order
            $row = [PSCustomObject]@{
                "Name" = $subdir.Name
                "ColorType" = $targetDir
                "SVGLink" = ""
                "PNGLink" = ""
                "AILink" = ""
                "PSDLink" = ""
            }
            
            # Add file columns organized by extension with relative paths from Icons folder and GitHub raw URL prefix
            $svgFiles = $files | Where-Object { $_.Extension -eq ".svg" } | ForEach-Object { "https://raw.githubusercontent.com/chootugamble/RohansSVGs1/refs/heads/main/" + ("Icons" + $_.FullName.Substring($iconsPath.Length)) }
            $pngFiles = $files | Where-Object { $_.Extension -eq ".png" } | ForEach-Object { "https://raw.githubusercontent.com/chootugamble/RohansSVGs1/refs/heads/main/" + ("Icons" + $_.FullName.Substring($iconsPath.Length)) }
            $aiFiles = $files | Where-Object { $_.Extension -eq ".ai" } | ForEach-Object { "https://raw.githubusercontent.com/chootugamble/RohansSVGs1/refs/heads/main/" + ("Icons" + $_.FullName.Substring($iconsPath.Length)) }
            $psdFiles = $files | Where-Object { $_.Extension -eq ".psd" } | ForEach-Object { "https://raw.githubusercontent.com/chootugamble/RohansSVGs1/refs/heads/main/" + ("Icons" + $_.FullName.Substring($iconsPath.Length)) }
            
            # Update the row with file links
            $row.SVGLink = ($svgFiles -join "; ")
            $row.PNGLink = ($pngFiles -join "; ")
            $row.AILink = ($aiFiles -join "; ")
            $row.PSDLink = ($psdFiles -join "; ")
            
            $csvData += $row
        }
    } else {
        Write-Host "Warning: $targetDir not found at: $fullPath"
    }
}

# Generate CSV filename with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvFilename = "Icons_Folders_$timestamp.csv"
$csvPath = Join-Path $scriptPath $csvFilename

# Export to CSV
if ($csvData.Count -gt 0) {
    $csvData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    
    Write-Host "`nCSV file generated successfully!"
    Write-Host "File: $csvFilename"
    Write-Host "Location: $csvPath"
    Write-Host "Total folders processed: $($csvData.Count)"
    
    # Display preview of the CSV data
    Write-Host "`nPreview of CSV data:"
    $csvData | Format-Table -AutoSize
    
} else {
    Write-Host "No data found to export to CSV"
}

Write-Host "`nScript completed!"
