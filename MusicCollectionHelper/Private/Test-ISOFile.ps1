function Test-ISOFile {
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
        [string]$Path,

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
        [string]$LiteralPath
    )
    [bool]$result = $false;

    [string]$isoPath = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            $isoPath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            $isoPath = Get-Item -LiteralPath $LiteralPath;
        }
    }

    # Make sure we have sacd_extract to test the ISO.
    if ($null -eq (Get-Command "sacd_extract" -ErrorAction SilentlyContinue)) {
        throw [System.Management.Automation.CommandNotFoundException] (
            "Unable to find `"sacd_extract`" in user's Path");
    }

    # Run sacd_extract and capture its output.
    [string[]]$cmdOutput = (
        (sacd_extract -i $isoPath --print *>&1 | Out-String).TrimEnd().Split(
            [System.Environment]::NewLine));
    
    # Check the output of sacd_extract for successful parsing.
    # 
    # Error messages:
    #   - "scarletbook_open: Can't read Master TOC !!"
    #   - "Errors reading sacd data!!"
    # Success messages:
    #   - "The size of sacd is ok"
    foreach ($line in $cmdOutput) {
        if ($line -match "The size of sacd is ok") {
            $result = $true;
        }
    }

    return $result;
}