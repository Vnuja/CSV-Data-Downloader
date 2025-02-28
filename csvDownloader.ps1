# © [Vinuja Ransith] | All Rights Reserved  
# Created on: [2/28/25]  
# Project: [CSV Image Downloader]  
# Description: [change the csv path and download path to download images from csv file]  

$csvPath = "Sample.csv"  # Update with the full path if needed
$downloadRoot = "C:\Downloads\FolderName"  # Root folder for downloads

# Create root directory if not exists
if (!(Test-Path -Path $downloadRoot)) {
    New-Item -ItemType Directory -Path $downloadRoot | Out-Null
}

# Import CSV file
$data = Import-Csv -Path $csvPath

foreach ($row in $data) {
    $folderName = $row."Folder Name"
    $folderPath = "$downloadRoot/$folderName"
    
    # Create a directory for each folder name
    if (!(Test-Path -Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath | Out-Null
    }
    
    # Loop through image columns
    for ($i = 1; $i -le 8; $i++) {
        $imageUrl = $row.("Images$i")
        if ($imageUrl -and $imageUrl -ne "") {
            $fileName = "$folderPath/Image$i.jpg"  # Naming convention for downloaded images
            Invoke-WebRequest -Uri $imageUrl -OutFile $fileName
        }
    }
}
