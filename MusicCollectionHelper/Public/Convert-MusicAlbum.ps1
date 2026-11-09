function Convert-MusicAlbum {
    [CmdletBinding(DefaultParameterSetName = "NoPath")]
    param (
        [Parameter(ParameterSetName = "Path")]
        [ValidateScript({
                Test-Path -Path -Path $_ -PathType "Container"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,
        
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Container"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath
    )
    
    # Get the folder we want to analyze.
    [string]$albumFolder = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path"        { $albumFolder = Get-Item -Path $Path; }
        "LiteralPath" { $albumFolder = Get-Item -LiteralPath $LiteralPath; }
        "NoPath"      { $albumFolder = (Get-Location).Path; }
    }

    Write-Information -InformationAction "Continue" -MessageData (
            "Processing album in folder $albumFolder");

    [IngestInformation]$albumInfo = Test-IngestType -LiteralPath $albumFolder;
    
    # If it's an invalid or unknown album type, bail out.
    if ($albumInfo.IngestType -eq [IngestType]::Invalid) {
        throw [System.NotSupportedException] (
            "The album found in `"$albumFolder`" has some kind of issue, " +
            "please read the warning messages shown in this terminal.");
    }
    elseif ($albumInfo.IngestType -eq [IngestType]::Unknown) {
        throw [System.ArgumentException] (
            "Automated album type detection for album `"$albumFolder`" " +
            "was unable to determine what type of album it is. Please " +
            "check the contents of its folder and try again.");
    }
    Write-Information -InformationAction "Continue" -MessageData (
            "Album is likely to be of type $($albumInfo.IngestType)");

    # Attempt to process the album's cover image. If that fails, then bail out.
    [string]$albumCoverPath = $null;
    foreach ($imageExtension in [ValidImageExtensions]::new().GetValidValues()) {
        $folderFiles = (Get-ChildItem -LiteralPath $albumFolder).Name.ToLower();
        if ("folder.$($imageExtension.ToLower())" -in $folderFiles) {
            $albumCoverPath = Get-Item -LiteralPath `
                (Join-Path $albumFolder "folder.$imageExtension");
            break;
        }
    }
    if (-not $albumCoverPath) {
        throw [System.IO.FileNotFoundException] (
            "Unable to locate an album cover image with the name `"folder`"," +
            " which all albums are required to have.");
    }
    
    Write-Information -InformationAction "Continue" -MessageData (
        "Processing album cover art `"$(Split-Path $albumCoverPath -Leaf)`".");

    Resize-AlbumImage -LiteralPath $albumCoverPath -Extension "jpg" `
        -TargetSize 1000 -TargetKiB 1024 -Tolerance 0.25 -Overwrite;

    Write-Information -InformationAction "Continue" -MessageData (
        "Album cover art `"$(Split-Path $albumCoverPath -Leaf)`" processed.");
    
    $albumCoverPath = (Join-Path $albumFolder "folder.jpg");
    if (-not (Test-Path -LiteralPath $albumCoverPath -PathType "Leaf")) {
        throw [System.IO.FileNotFoundException] (
            "An album cover image was found and fed to the image processing " +
            "function, but the desired end result, an image named " +
            "`"folder.jpg`", cannot be found.");
    }

    # Process FilePCM album.
    if ($albumInfo.IngestType -eq [IngestType]::FilePCM) {
        Write-Information -InformationAction "Continue" -MessageData (
            "Processing album as being of type `"File PCM`".");

        # We don't want to compress non-PCM audio files.
        if (-not ($albumInfo.MusicMimeType -in `
                [ValidAudioMimeTypes]::GetPcmLosslessValues())) {
            throw [System.IO.FileFormatException] (
                "MIME type of album `"$($albumInfo.MusicMimeType)`" represents " +
                "a lossy audio format, making it unsuitable for FLAC " +
                "conversion. As this album was detected as a PCM one, " +
                "we're canceling its processing as lossy formats are not " +
                "acceptable for our music collection.");
        }

        # Convert non-FLAC files to FLAC.
        if (-not ($albumInfo.MusicMimeType -in `
                [ValidAudioMimeTypes]::GetFlacValues())) {
            Write-Information -InformationAction "Continue" -MessageData (
                "MIME type of album `"$($albumInfo.MusicMimeType)`" is not " +
                "FLAC, converting music files to that format.");

            $newMusicFiles = [System.Collections.ArrayList]@();
            foreach ($musicFile in $albumInfo.MusicFiles) {
                ConvertTo-Flac -LiteralPath $musicFile -SkipFileCheck;
                
                [void]$newMusicFiles.Add(
                    [string](Join-Path (Split-Path $musicFile) `
                        ((Split-Path $musicFile -LeafBase) + ".flac"))
                );

                Write-Information -InformationAction "Continue" -MessageData (
                    "Converted file to FLAC: `"$musicFile`"");
            }

            $albumInfo.MusicFiles = $newMusicFiles.ToArray();
            $albumInfo.MusicExtension = "flac";
            $albumInfo.MusicMimeType = "audio/flac";
        }

        # Apply the cover image to all music files and test its application.
        Write-Information -InformationAction "Continue" -MessageData (
            "Applying album cover art to all music files.");
        
        foreach ($musicFile in $albumInfo.MusicFiles) {
            Set-MediaFileCover -LiteralPath $musicFile;
            Write-Information -InformationAction "Continue" -MessageData (
                "Applied album cover art to `"$musicFile`", testing.");

            Test-MediaFileCover -LiteralPath $musicFile;
            Write-Information -InformationAction "Continue" -MessageData (
                "Album cover art correctly applied to `"$musicFile`".");
        }

        # Ask user to update tags of music files.
        Write-Information -InformationAction "Inquire" -MessageData (
            "Press any key to continue once you've updated the audio files'" + 
            "metadata");
        explorer "$albumFolder";

        [bool]$metadataOkay = $true;
        Write-Information -InformationAction "Continue" -MessageData (
                "Testing metadata of audio files.");
        foreach ($musicFile in $albumInfo.MusicFiles) {
            if (-not (Test-MusicFileTags -LiteralPath $musicFile)) {
                Write-Warning (
                    "Metadata of file `"$musicFile`" has problems! Please " +
                    "fix the issues shown in the terminal.");
                $metadataOkay = $false;
            }
        }

        # Create m3u8 file if no metadata issues were detected.
        if ($metadataOkay) {
            New-M3U8File -LiteralPath albumFolder;
            Write-Information -InformationAction "Continue" -MessageData (
                "Created M3U8 playlist file for album.");
        }
        else {
            Write-Information -InformationAction "Continue" -MessageData (
                "Unable to create M3U8 playlist file for album due to " +
                "audio file metadata issues.");
        }
        
        Write-Information -InformationAction "Continue" -MessageData (
            "Done processing album $albumFolder");
    }
}