function ConvertTo-Flac {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "LiteralPath")]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Path",
            Position = 0)]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath",
            Position = 0)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$LiteralPath,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(0, 8)]
        [int]$CompressionLevel = 8,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [switch]$SkipFileCheck
    )
    process {
        [string]$musicFilePath = $null;
        switch ($PSCmdlet.ParameterSetName) {
            "Path"        { $musicFilePath = Get-Item -Path $Path; }
            "LiteralPath" { $musicFilePath = Get-Item -LiteralPath $LiteralPath; }
        }

        # We don't want to compress non-audio files.
        if (-not $SkipFileCheck) {
            $fileInfo = Get-TridFileInfo -LiteralPath $musicFilePath;
            if (-not ($fileInfo.MimeType -in [ValidAudioMimeTypes]::GetValidValues())) {
                throw [System.IO.FileFormatException] (
                    "File passed on to be converted to FLAC is not an audio " +
                    "file, making automated conversion impossible.");
            }
        }

        # Make sure we have FFMPEG installed.
        if ($null -eq (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
            throw [System.Management.Automation.CommandNotFoundException] (
                "Unable to find `"ffmpeg`" in user's Path");
        }

        # If the output file already exists, it'll be overwritten.
        ffmpeg -y -i "$musicFilePath" -c:a flac -compression_level $CompressionLevel `
            "$(Join-Path (Split-Path $musicFilePath) "$(Split-Path $musicFilePath -LeafBase).flac")";
    }
}