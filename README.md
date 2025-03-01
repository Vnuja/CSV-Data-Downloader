# © [Vinuja Ransith] | All Rights Reserved  
# Created on: [2/28/25]  
# Project: [CSV Image Downloader]  
# Description: [change the csv path and download path to download images from csv file]  

## How to Use This Script

# Save the script as Download-Images.ps1 on your computer
# Open PowerShell and navigate to the directory where you saved the script
# Run the script by typing .\Download-Images.ps1

## Follow the prompts:

# First, you'll be asked to select the CSV file containing the image URLs
# Then, you'll select the destination folder where you want to save the images

## The script will:

# Create folders named according to the "Folder Name" column in the CSV
# Download all images from the URLs in each row to their respective folders
# Skip downloading if an image already exists (to avoid duplicates)
# Show progress as it works through the folders and images

## Provide a summary when finished

## Features

# User-friendly file and folder selection dialogs
# Progress tracking with percentages
# Error handling for failed downloads
# Skips existing files to prevent duplicate downloads
# Creates folders automatically if they don't exist
# Detailed summary at the end