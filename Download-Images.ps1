# © [Vinuja Ransith] | All Rights Reserved  
# Created on: [2/28/25]  
# Description: [change the csv path and download path to download images from csv file]  
# PowerShell Image Downloader Script
# This script downloads images from URLs in a CSV file to their respective folders

function Select-FileDialog {
    param([string]$Title, [string]$Filter = "CSV Files (*.csv)|*.csv")
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = $Title
    $openFileDialog.Filter = $Filter
    $openFileDialog.ShowDialog() | Out-Null
    return $openFileDialog.FileName
}

function Select-FolderDialog {
    param([string]$Description = "Select folder to save images")
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = $Description
    $folderBrowser.ShowDialog() | Out-Null
    return $folderBrowser.SelectedPath
}

# Get the CSV file path
Write-Host "Please select the CSV file containing image URLs" -ForegroundColor Cyan
$csvPath = Select-FileDialog -Title "Select CSV file with image URLs"

if (-not $csvPath -or -not (Test-Path $csvPath)) {
    Write-Host "No file selected or file does not exist. Exiting script." -ForegroundColor Red
    exit
}

# Get the destination folder path
Write-Host "Please select the destination folder where images will be downloaded" -ForegroundColor Cyan
$destinationRoot = Select-FolderDialog -Description "Select destination folder for images"

if (-not $destinationRoot) {
    Write-Host "No destination folder selected. Exiting script." -ForegroundColor Red
    exit
}

# Import CSV file
$csvData = Import-Csv $csvPath

# Create a progress counter
$totalFolders = $csvData.Count
$currentFolder = 0
$totalImages = 0
$downloadedImages = 0
$skippedImages = 0

# Count total images to download
foreach ($row in $csvData) {
    for ($i = 1; $i -le 8; $i++) {
        $imageUrl = $row."Image $i"
        if ($imageUrl -and $imageUrl -ne "") {
            $totalImages++
        }
    }
}

Write-Host "Found $totalFolders folders and $totalImages images to download" -ForegroundColor Green

# Create WebClient for downloading
$webClient = New-Object System.Net.WebClient

# Process each row in the CSV
foreach ($row in $csvData) {
    $currentFolder++
    $folderName = $row."Folder Name"
    
    # Skip if folder name is empty
    if (-not $folderName -or $folderName -eq "") {
        continue
    }
    
    # Create folder if it doesn't exist
    $folderPath = Join-Path -Path $destinationRoot -ChildPath $folderName
    if (-not (Test-Path $folderPath)) {
        New-Item -Path $folderPath -ItemType Directory | Out-Null
        Write-Host "Created folder: $folderName" -ForegroundColor Yellow
    }
    
    # Process each image in the row
    for ($i = 1; $i -le 8; $i++) {
        $imageUrl = $row."Image $i"
        
        # Skip empty URLs
        if (-not $imageUrl -or $imageUrl -eq "") {
            continue
        }
        
        try {
            # Extract filename from URL
            $fileName = [System.IO.Path]::GetFileName($imageUrl)
            $destinationPath = Join-Path -Path $folderPath -ChildPath $fileName
            
            # Skip if file already exists
            if (Test-Path $destinationPath) {
                Write-Host "Skipping, already exists: $fileName" -ForegroundColor Yellow
                $skippedImages++
                continue
            }
            
            # Download the image
            $webClient.DownloadFile($imageUrl, $destinationPath)
            $downloadedImages++
            
            # Display progress
            $progressPercent = [math]::Round(($downloadedImages + $skippedImages) / $totalImages * 100, 2)
            Write-Host "Downloaded ($progressPercent%): $fileName to $folderName" -ForegroundColor Green
            
        } catch {
            Write-Host "Error downloading: $imageUrl - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Show folder progress
    $folderProgress = [math]::Round($currentFolder / $totalFolders * 100, 2)
    Write-Host "Processed folder $currentFolder of $totalFolders ($folderProgress%): $folderName" -ForegroundColor Cyan
}

# Display summary
Write-Host "`nDownload Summary:" -ForegroundColor Cyan
Write-Host "Total folders processed: $totalFolders" -ForegroundColor White
Write-Host "Total images found: $totalImages" -ForegroundColor White
Write-Host "Images downloaded: $downloadedImages" -ForegroundColor Green
Write-Host "Images skipped (already existed): $skippedImages" -ForegroundColor Yellow
Write-Host "Images failed: $($totalImages - $downloadedImages - $skippedImages)" -ForegroundColor Red
Write-Host "`nDownload completed. Images saved to: $destinationRoot" -ForegroundColor Green

$webClient.Dispose()