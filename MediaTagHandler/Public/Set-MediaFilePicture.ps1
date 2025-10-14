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
                    if ($MediaFile -is [TagLib.Flac.File]) {
                        $MediaFile.Tag.Pictures += [TagLib.Flac.Picture]$Picture;
                    }
                    else {
                        $MediaFile.Tag.Pictures += $Picture;
                    }
                }
                else {
                    $MediaFile.Tag.Pictures = $MediaFile.Tag.Pictures | `
                        Where-Object { $_.Type -ne $PictureType };
                    if ($MediaFile -is [TagLib.Flac.File]) {
                        $MediaFile.Tag.Pictures += [TagLib.Flac.Picture]$Picture;
                    }
                    else {
                        $MediaFile.Tag.Pictures += $Picture;
                    }
                }

                # If we're dealing with FLAC files, we need to manually
                # set the file's width, height, and color depth.
                # See: https://github.com/gchudov/cuetools.net/commit/cccbcd39b0d02613348b22e1c7259cb867e1e34e
                if ($MediaFile -is [TagLib.Flac.File]) {
                    for ($i = 0; $i -lt $MediaFile.Tag.Pictures.Length; $i++) {
                        if ($MediaFile.Tag.Pictures[$i].Type -eq $PictureType) {
                            [System.Drawing.Bitmap]$pictureData = `
                                [System.Drawing.ImageConverter]::new().ConvertFrom(
                                $Picture.Data.Data);
                            $MediaFile.Tag.Pictures[$i].Width = $pictureData.Width;
                            $MediaFile.Tag.Pictures[$i].Height = $pictureData.Height;
                            $MediaFile.Tag.Pictures[$i].ColorDepth = `
                                [System.Drawing.Image]::GetPixelFormatSize(
                                $pictureData.PixelFormat);
                        }
                    }
                }
            }
        }

        if ($Save) {
            $MediaFile.Save();
        }
    }
}
