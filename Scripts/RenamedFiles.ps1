param (
    [string]$RootPath = "."
)

$folders = Get-ChildItem -Path $RootPath -Directory -Recurse

foreach ($folder in $folders) {
    $folderName = $folder.Name
    $files = Get-ChildItem -Path $folder.FullName -File

    foreach ($file in $files) {
        $extension = $file.Extension
        $newName = "$folderName$extension"
        try {
            Rename-Item -Path $file.FullName -NewName $newName -Force -ErrorAction Stop
        }
        catch {
            Write-Host "⚠️ Error renaming file in folder '$folderName': $($file.Name)" -ForegroundColor Yellow
            Write-Host "   $_" -ForegroundColor DarkGray
        }
    }
}
