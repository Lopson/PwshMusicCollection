function Test-StringArray {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [string[]]$StringArray
    )

    if (-not $StringArray -or
        $StringArray.Length -lt 1 -or
        ($StringArray | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) })) {
        return $false;
    }
    return $true;
}
