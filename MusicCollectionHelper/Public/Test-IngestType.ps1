function Test-IngestType {
    # TODO consider making this pipeline-capable
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
    [string]$isoPath = Get-ChildItem -LiteralPath $ingestFolder -Filter "*.iso";
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
    [string]$cuePath = Get-ChildItem -LiteralPath $ingestFolder -Filter "*.cue";

    # Check if all music files have the same extension.
    $musicExtensionsFound = [System.Collections.Generic.HashSet[string]]::new();
    foreach ($audioType in [ValidAudioExtensions]::new().GetValidValues()) {
        if (".$audioType" -in `
                [string[]](
                    Get-ChildItem -LiteralPath $ingestFolder `
                    -Filter ("*.$audioType")).Extension.ToLower()) {
            $musicExtensionsFound.Add($audioType);
        }
    }
    if ($musicExtensionsFound.Count -gt 1) {
        Write-Warning (
            "More than one music extension detected in folder, which makes it " +
            "impossible to determine the ingest type"
        );
        return [IngestType]::Unknown;
    }
    elseif ($musicExtensionsFound.Count -eq 0) {
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
    foreach ($musicFileInfo in $musicFilesInfo) {
        [Void]$musicMimesFound.Add($musicFileInfo."MIME type");
    }
    if ($musicMimesFound.Count -gt 1) {
        Write-Warning (
            "Music files have more than one MIME type, which makes it " +
            "impossible to determine the ingest type"
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
    elseif ($musicMimesFound[0] -notin `
            [ValidAudioMimeTypes]::new().GetValidValues()) {
        Write-Warning (
            "File(s) in folder with music file extensions don't have audio " +
            "MIME types"
        );
        return [IngestType]::Invalid;
    }

    # Check if files are PCM or DSD.
    # TODO get the MIME type of uncompressed dsf files please.
}
