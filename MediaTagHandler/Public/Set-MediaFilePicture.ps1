function Set-MediaFilePicture {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [TagLib.Picture]$Picture = $null,

        [TagLib.PictureType]$PictureType = [TagLib.PictureType]::NotAPicture,

        [bool]$Save = $true
    )
    
    process {
        Test-MediaFile -MediaFile $MediaFile;

        # Input validation and initialization.
        switch ($Picture) {
            $null {
                if ([TagLib.PictureType]::NotAPicture -eq $PictureType) {
                    throw [System.ArgumentNullException] (
                        "You have to specify a picture type when attempting " +
                        "to delete a picture");
                }
            }
            default {
                if ([TagLib.PictureType]::NotAPicture -eq $PictureType) {
                    $PictureType = $Picture.Type;
                }
            }
        }

        # Data manipulation.
        switch ($Picture) {
            # Picture deletion.
            $null {
                if (-not $MediaFile.Tag.Pictures -or `
                    ($MediaFile.Tag.Pictures.Length -le 0)) {
                    return;
                }
                else {
                    $MediaFile.Tag.Pictures = $MediaFile.Tag.Pictures | Where-Object {
                        $_.Type -ne $PictureType
                    };
                }
            }
            # Picture adding/replacing.
            default {
                if (-not $MediaFile.Tag.Pictures -or `
                    ($MediaFile.Tag.Pictures.Length -le 0)) {
                    $MediaFile.Tag.Pictures += $Picture;
                }
                else {
                    $MediaFile.Tag.Pictures = $MediaFile.Tag.Pictures | `
                        Where-Object { $_.Type -ne $PictureType };
                    $MediaFile.Tag.Pictures += $Picture;
                }
            }
        }

        if ($Save) {
            $MediaFile.Save();
        }
    }
}
