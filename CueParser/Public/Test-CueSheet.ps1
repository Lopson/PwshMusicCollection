function Test-CueSheet {
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNull()]
        [CueSheet]$CueSheet
    )

    # Cue sheet genres, expected to be comma-separated.
    [string[]]$CueGenres = $CueSheet.Genre -split ",";
    if (-not (Test-StringArray -StringArray $CueGenres)) {
        throw [System.ArgumentException] "Genre not found in Cue sheet"; }
    
    # Cue sheet date; year is expected.
    [string]$CueDate = $CueSheet.Date;
    [datetime]$CueDateTime = New-Object datetime;
    if (-not $CueDate) {
        throw [System.ArgumentNullException] "Date not found in Cue sheet"; }
    if (-not ([datetime]::TryParseExact(
                $CueDate,
                "yyyy",
                [CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None,
                [ref]$CueDateTime))) {
        throw [System.ArgumentException] "Date field isn't a valid year";
    }
    
    # Cue sheet country; custom value that we're using in our music collection.
    # Expected value is either "Country, Continent" (old) or 3-letter country
    # code (current).
    [string]$CueCountry = $CueSheet.Country;
    if (-not $CueCountry) {
        throw [System.ArgumentNullException] "Country not found in Cue sheet"; }
    if ($CueCountry -notin [Valid3LetterCountryCodes]::new().GetValidValues()) {
        if (($CueCountry -split ",").Length -eq 2) {
            Write-Warning ("Possible old-format country value found, " + 
                "consider replacing it with a 3-letter country code");
        }
        else {
            throw [System.ArgumentException] (
                "Country value is not a valid 3-letter code");
        }
    }

    # Cue sheet performers, expected to be comma-separated.
    [string[]]$CuePerformer = $CueSheet.Performer -split ",";
    if (-not (Test-StringArray -StringArray $CuePerformer)) {
        throw [System.ArgumentException] (
            "Album performer not found in Cue sheet"); }
    
    # Cue sheet album title.
    [string]$CueTitle = $CueSheet.Title;
    if (-not $CueTitle) {
        throw [System.ArgumentException] "Album title not found in Cue sheet"; }

    # Make sure the tracks' files exist and are in the same folder as the Cue sheet.
    [string[]]$CueFileExtensions = @();
    foreach ($CueFile in $CueSheet.Files) {
        $CueFilePath = Join-Path (Get-Item -LiteralPath $CueSheet.Path).DirectoryName $CueFile.Name;
        
        if (-not (Test-Path -LiteralPath $CueFilePath -PathType "Leaf")) {
            throw [System.IO.FileNotFoundException] (
                "File $($CueFile.Name) not found"); }
        
        $CueFileExtensions += (Get-Item -LiteralPath $CueFilePath).Extension;
    }
    
    # Make sure all files have the same file extension.
    if (@(($CueFileExtensions | Select-Object -Unique)).Length -ne 1) {
        throw [System.ArgumentException] (
            "Not all audio files have the same extension"); }
}
