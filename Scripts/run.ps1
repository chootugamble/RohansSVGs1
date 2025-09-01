# PowerShell script to generate unique identifiers
# Step 1: Create a unique ID and store it in a variable

# Global array to store all generated GUIDs
$global:usedGuids = @()

# Generate a unique ID using GUID + timestamp, ensuring it's not already used
function New-UniqueID {
    do {
        # Generate a random GUID
        $guid = [System.Guid]::NewGuid().ToString()
        
        # Get current timestamp in numbers (format: yyyyMMddHHmmss)
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        
        # Combine GUID and timestamp, then remove all hyphens and underscores
        $result = "$guid`_$timestamp" -replace '[-_]', ''
    } while ($global:usedGuids -contains $result)
    
    # Add the new unique ID to the used list
    $global:usedGuids += $result
    return $result
}

# Step 1: Generate unique ID and store in variable
$uniqueId = New-UniqueID

# Display the generated unique ID
Write-Host "Generated unique ID: $uniqueId"
Write-Host "Unique ID stored in variable: `$uniqueId = '$uniqueId'"

# Verify the variable contains the unique ID
Write-Host "Variable verification: `$uniqueId contains: $uniqueId"

# Step 2: Get list of all SVG files from the Icons folder
Write-Host "`nStep 2: Getting list of all SVG files from Icons folder..."

# Get the current script directory and navigate to the Icons folder
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconsPath = Join-Path $scriptPath "..\Icons"

# Check if Icons folder exists
if (Test-Path $iconsPath) {
    # Get all SVG files recursively from the Icons folder
    $svgFiles = Get-ChildItem -Path $iconsPath -Filter "*.svg" -Recurse
    
    # Store the list in a variable
    $svgFileList = $svgFiles | ForEach-Object { $_.FullName }
    
    # Display the results
    Write-Host "Found $($svgFiles.Count) SVG files:"
    $svgFiles | ForEach-Object { 
        Write-Host "  - $($_.FullName)"
    }
    
    Write-Host "`nSVG file list stored in variable: `$svgFileList"
    Write-Host "Total SVG files found: $($svgFiles.Count)"
} else {
    Write-Host "Error: Icons folder not found at: $iconsPath"
    $svgFileList = @()
}

# Step 3: Find all ID declarations and concatenate different unique IDs to each ID
Write-Host "`nStep 3: Finding all ID declarations and concatenating unique IDs..."

# Function to generate a new unique ID for each ID
function New-IDUniqueID {
    $uniqueId = New-UniqueID
    return "I$uniqueId"
}

# Function to generate a new unique class name
function New-ClassUniqueID {
    $uniqueId = New-UniqueID
    return "C$uniqueId"
}

# Function to process SVG files and replace IDs and classes
function Process-SVGIdsAndClasses {
    param(
        [string[]]$SvgFilePaths
    )
    
    $idReplacements = @{}
    $classReplacements = @{}
    $totalIdsFound = 0
    $totalClassesFound = 0
    
    foreach ($svgFile in $SvgFilePaths) {
        try {
            # Read SVG file content
            $svgContent = Get-Content -Path $svgFile -Raw -Encoding UTF8
            
            # Find all ID declarations using regex
            $idPattern = 'id="([^"]*)"'
            $idMatches = [regex]::Matches($svgContent, $idPattern)
            
            # Find all class declarations using regex
            $classPattern = 'class="([^"]*)"'
            $classMatches = [regex]::Matches($svgContent, $classPattern)
            
            if ($idMatches.Count -gt 0 -or $classMatches.Count -gt 0) {
                Write-Host "Processing: $svgFile"
                
                # Process IDs
                if ($idMatches.Count -gt 0) {
                    Write-Host "  Found $($idMatches.Count) ID declarations:"
                    
                    # Process each ID found
                    foreach ($match in $idMatches) {
                        $originalId = $match.Groups[1].Value
                        $totalIdsFound++
                        
                        # Generate new unique ID for this ID
                        $newUniqueId = New-IDUniqueID
                        $newId = $newUniqueId
                        
                        # Store the replacement mapping
                        $idReplacements[$originalId] = $newId
                        
                        Write-Host "    - ID '$originalId' -> '$newId'"
                    }
                }
                
                # Process Classes
                if ($classMatches.Count -gt 0) {
                    Write-Host "  Found $($classMatches.Count) class declarations:"
                    
                    # Process each class found
                    foreach ($match in $classMatches) {
                        $originalClass = $match.Groups[1].Value
                        $totalClassesFound++
                        
                        # Generate new unique class name
                        $newUniqueClass = New-ClassUniqueID
                        $newClass = $newUniqueClass
                        
                        # Store the replacement mapping
                        $classReplacements[$originalClass] = $newClass
                        
                        Write-Host "    - Class '$originalClass' -> '$newClass'"
                    }
                }
                
                # Replace all IDs and classes in the SVG content
                $newSvgContent = $svgContent
                
                # Replace IDs
                foreach ($originalId in $idReplacements.Keys) {
                    $newId = $idReplacements[$originalId]
                    # Replace the ID declaration
                    $newSvgContent = $newSvgContent -replace "id=`"$originalId`"", "id=`"$newId`""
                    # Replace all references to the old ID (with # prefix)
                    $newSvgContent = $newSvgContent -replace "#$originalId", "#$newId"
                }
                
                # Replace Classes
                foreach ($originalClass in $classReplacements.Keys) {
                    $newClass = $classReplacements[$originalClass]
                    # Replace the class declaration
                    $newSvgContent = $newSvgContent -replace "class=`"$originalClass`"", "class=`"$newClass`""
                    # Replace all CSS references to the old class (with . prefix)
                    $newSvgContent = $newSvgContent -replace "\.$originalClass", ".$newClass"
                }
                
                # Write the updated content back to the file
                Set-Content -Path $svgFile -Value $newSvgContent -Encoding UTF8
                Write-Host "  Updated file with new IDs and classes"
            } else {
                Write-Host "No ID or class declarations found in: $svgFile"
            }
        }
        catch {
            Write-Host "Error processing file $svgFile : $($_.Exception.Message)"
        }
    }
    
    return @{
        TotalIds = $totalIdsFound
        TotalClasses = $totalClassesFound
    }
}

# Process all SVG files
if ($svgFileList.Count -gt 0) {
    $results = Process-SVGIdsAndClasses -SvgFilePaths $svgFileList
    Write-Host "`nStep 3 Summary:"
    Write-Host "Total IDs processed across all SVG files: $($results.TotalIds)"
    Write-Host "Total classes processed across all SVG files: $($results.TotalClasses)"
    Write-Host "Total unique GUIDs generated: $($global:usedGuids.Count)"
    Write-Host "All SVG files have been updated with new unique IDs, classes, and all references updated"
} else {
    Write-Host "No SVG files to process for ID and class replacement"
}
