function Get-TridFileInfo {
    [CmdletBinding(DefaultParameterSetName = "Path")]
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
    begin {
        $result = [System.Collections.ArrayList]@();
    }
    process {
        [string]$filePath = $null;
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $filePath = Get-Item -Path $Path;
            }
            "LiteralPath" {
                $filePath = Get-Item -LiteralPath $LiteralPath;
            }
        }

        # Check if TrID exists on local system.
        if ($null -eq (Get-Command "trid" -ErrorAction SilentlyContinue)) {
            throw [System.Management.Automation.CommandNotFoundException] (
                "Unable to find `"trid`" in user's Path");
        }
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
                [System.Runtime.InteropServices.OSPlatform]::Windows) -and `
                (Get-ItemProperty `
                    "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage"
                ).ACP -ne "65001") {
            throw [System.NotSupportedException] (
                "In order for TrID to work properly, you must set " +
                "`"Use Unicode UTF-8 for worldwide language support`" to " +
                "On in Language & Region settings."
            );
        }

        # Run TrID and capture all of its output to a variable and a CSV file.
        [string]$tridCsvPath = Join-Path $env:TEMP "trid_$(
            Get-Date -Format "FileDateTime").csv";
        [string[]]$tridOutput = (
            (trid --out $tridCsvPath $filePath *>&1) | Out-String).TrimEnd().Split(
                [System.Environment]::NewLine);

        # Python runtime error (TrID relies on Python).
        if ($tridOutput -match `
                ".*Failed to execute script 'trid' due to unhandled exception!") {
            throw [System.Management.Automation.RuntimeException] (
                "TrID's Python backend failed to execute properly"
            );
        }

        # Import TrID's CSV output.
        $tridCsv = Import-Csv -Encoding "utf8" -LiteralPath $tridCsvPath;
        Remove-Item -LiteralPath $tridCsvPath -Force;

        # Process TrID's CSV output.
        foreach ($csvEntry in $tridCsv) {
            $csvEntry.File = $filePath;
            
            $csvEntry."%" = $csvEntry."%" -replace "%", "";
            if ($csvEntry."%" -and `
                    -not [double]::TryParse(
                        $csvEntry."%",
                        [System.Globalization.NumberStyles]::Any,
                        [System.Globalization.CultureInfo]::InvariantCulture,
                        [ref]($csvEntry."%"))) {
                throw [System.FormatException] (
                    "Tried to parse percentage value in TrID CSV output but failed"
                );
            }

            [string[]]$csvEntry."Extension(s)" = $csvEntry."Extension(s)" -split "/" | `
                ForEach-Object {$_.ToLower()};
        }
        
        [Void]$result.Add($tridCsv);
    }
    end {
        return $result;
    }
}