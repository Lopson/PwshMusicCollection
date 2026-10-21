function Test-IngestType {
    # NOTE Consider making this pipeline-capable.
    [OutputType([IngestType])]
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
    [string]$ingestFolder = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path"        { $ingestFolder = Get-Item -Path $Path; }
        "LiteralPath" { $ingestFolder = Get-Item -LiteralPath $LiteralPath; }
        "NoPath"      { $ingestFolder = (Get-Location).Path; }
    }

    # Check if an ISO file is present.
    # 
    # ISO files should be for DSD rips. I guess they can also be standard ISOs
    # but I don't think we've ever downloaded such an ISO, so it should be safe
    # to ignore those. And BTW, WavPack ISOs are ".iso.wv", so no need to check
    # for those here.
    # 
    # We can immediately bail out here because there's nothing else to check
    # and also because it makes the coding easier to manage.
    [string[]]$isoFiles = Get-ChildItem -LiteralPath $ingestFolder -Filter "*.iso";
    [string]$isoPath = $null;
    if ($isoFiles.Count -gt 1) {
        Write-Warning (
            "More than one ISO file was found, which is not an approved " +
            "album structure"
        );
        return [IngestType]::Invalid;
    }
    elseif ($isoFiles.Count -eq 1) {
        $isoPath = $isoFiles[0];
    }

    if ($isoPath) {
        # Test if the ISO is an actual DSD ISO.
        if (Test-ISOFile -LiteralPath $isoPath) {
            return [IngestType]::IsoDsd;
        }
        else{
            return [IngestType]::Iso;
        }
    }

    # Now we know that there's no ISO, so that means there must be music files,
    # either one or many. As such, we need to validate that that's the case.

    # Check if a Cue sheet is present.
    # 
    # The presence of a Cue doesn't automatically mean that it's a PCM folder
    # as DSD folders can also have one. No conclusions can be made just yet.
    # Do NOT validate the cue sheet here please, leave that to the caller.
    [string[]]$cueFiles = Get-ChildItem -LiteralPath $ingestFolder -Filter "*.cue";
    [string]$cuePath = $null;
    if ($cueFiles.Count -gt 1) {
        Write-Warning (
            "More than one cue sheet was found, which is not an approved " +
            "album structure"
        );
        return [IngestType]::Invalid;
    }
    elseif ($cueFiles.Count -eq 1) {
        $cuePath = $cueFiles[0];
    }

    # Check if all music files have the same extension.
    $musicExtensionsFound = [System.Collections.Generic.HashSet[string]]::new();
    foreach ($audioType in [ValidAudioExtensions]::new().GetValidValues()) {
        $audioTypeFiles = [string[]](
            Get-ChildItem -LiteralPath $ingestFolder `
            -Filter ("*.$audioType")).Extension;
        if ($audioTypeFiles -and ".$audioType" -in $audioTypeFiles.ToLower()) {
            [void]$musicExtensionsFound.Add($audioType);
        }
        else {
            continue;
        }
    }
    if ($musicExtensionsFound.Count -gt 1) {
        # If more than one music extension was detected.
        Write-Warning (
            "More than one music extension detected in folder, which makes it " +
            "impossible to determine the ingest type"
        );
        return [IngestType]::Unknown;
    }
    elseif ($musicExtensionsFound.Count -eq 0) {
        # If no music file extensions were detected.
        Write-Warning (
            "No files with music extensions were found in folder"
        );
        return [IngestType]::Invalid;
    }

    [string]$musicExtension = $musicExtensionsFound[0]; # Has no dot.
    [string[]]$musicFiles = (
        Get-ChildItem -LiteralPath $ingestFolder -Filter "*.$musicExtension" | `
        Sort-Object).FullName;

    # Double-check that all audio files are of the same format by looking at
    # their internal metadata.
    $musicFilesInfo = $musicFiles | Get-TridFileInfo;
    $musicMimesFound = [System.Collections.Generic.HashSet[string]]::new();
    foreach ($musicFile in $musicFiles) {
        $musicFileInfo = $musicFilesInfo | `
            Where-Object {$_.File -eq $musicFile} | `
            Sort-Object -Descending -Property "%";
        
        if ($musicFileInfo.Count -eq 0) {
            # If a music file isn't in the list of TrID results.
            Write-Warning (
                "Music file $musicFile either wasn't processed by TrID or " +
                "something went wrong with TrID"
            );
            return [IngestType]::Invalid;
        }
        
        if (($musicFileInfo | Where-Object {$_."TrID-Score" -eq 0}).Count -gt 0) {
            # If TrID was incapable of detecting a file's type.
            Write-Warning (
                "Type of file $musicFile was impossible to determine by TrID"
            );
            return [IngestType]::Unknown;
        }
    
        $musicFileInfoTopResults = $musicFileInfo | `
            Where-Object {$_."%" -eq $musicFileInfo[0]."%"}

        if ($musicExtension -notin $musicFileInfoTopResults."Extension(s)") {
            # If the folder's music file extension isn't in a file's
            # list of TrID entries.
            Write-Warning (
                "Expected file extension $musicExtension was not determined " +
                "as valid for the file $musicFile based on TrID's top " +
                "results, which means the file likely has the wrong " +
                "extension. TrID thinks the right extension would be one of " +
                "the following: " +
                $musicFileInfo."Extension(s)"
            );
            return [IngestType]::Invalid;
        }

        if ($musicExtension -notin $musicFileInfoTopResults."Extension(s)") {
            # If the folder's music file extension isn't matched by
            # the top result(s) in the list of TrID entries. Note that there
            # may be more than one result with the same % value, hence the
            # filtering taking place in the if condition.
            Write-Warning (
                "Expected file extension $musicExtension doesn't match " +
                "any of TrID's top results' extensions for file $musicFile`: " +
                $musicFileInfoTopResults."Extension(s)"
            );
            return [IngestType]::Unknown;
        }

        foreach ($musicFileInfoEntry in $musicFileInfoTopResults) {
            # If any of the top TrID results for the current music file don't
            # have an audio MIME type.
            if ($musicFileInfoEntry."MIME type" -notin 
                    [ValidAudioMimeTypes]::new().GetValidValues()) {
                Write-Warning (
                    "TrID's top results' for file $musicFile don't have an " +
                    "audio MIME types; types detected were " +
                    $musicFileInfoTopResults."MIME type"
                );
                return [IngestType]::Invalid;
            }
        }

        [void]$musicMimesFound.UnionWith(
            [string[]]$musicFileInfoTopResults."MIME type");
    }
    if ($musicMimesFound.Count -gt 1) {
        Write-Warning (
            "Music files have more than one MIME type, which makes it " +
            "impossible to determine the ingest type: " +
            $musicMimesFound
        );
        return [IngestType]::Unknown;
    }
    elseif ($musicMimesFound.Count -lt 0) {
        Write-Warning (
            "File(s) in folder with music file extensions don't have a " +
            "MIME type, making it impossible to determine the ingest type"
        );
        return [IngestType]::Unknown;
    }

    [string]$musicMimeType = $musicMimesFound[0];
    [string]$isMusicPCM = $true;
    
    # Check if files are PCM or DSD.
    if ($musicMimeType -in [ValidAudioMimeTypes]::new().GetDsdValues()) {
        $isMusicPCM = $false;
    }

    # If it's a single audio file with cue sheet, return an ingest type.
    if ($musicFiles.Count -eq 1 -and $cuePath) {
        switch ($isMusicPCM) {
            $true  { return [IngestType]::CueAlbumPCM; }
            $false { return [IngestType]::CueAlbumDSD; }
        }
    }
    # If it's multiple audio files with cue sheet, return an ingest type.
    elseif ($musicFiles.Count -gt 1 -and $cuePath) {
        switch ($isMusicPCM) {
            $true  { return [IngestType]::CueMultiPCM; }
            $false { return [IngestType]::CueMultiDSD; }
        }
    }
    elseif ($musicFiles.Count -ge 1) {
        switch ($isMusicPCM) {
            $true  { return [IngestType]::FilePCM; }
            $false { return [IngestType]::FileDSD; }
        }
    }
    else {
        Write-Warning (
            "All detection methods have been attempted, yet it was " +
            "impossible to determine the ingest type"
        );
        return [IngestType]::Unknown;
    }
}
