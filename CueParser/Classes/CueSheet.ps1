# MIT License
# 
# Copyright (c) 2020 Gregory Khvatsky
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
# Source: https://github.com/x0wllaar/cuetag.ps1

class CueSheet {
    # Standard fields.
    [string]$Catalog = $null
    [string]$CdTextFile = $null
    [string]$Performer = $null
    [string]$Songwriter = $null
    [string]$Title = $null

    # REMs fields.
    [string]$Date = $null
    [string]$Genre = $null
    [string]$Discid = $null
    [string]$Comment = $null
    [string]$Composer = $null
    [string]$Country = $null

    [string]$Path = $null
    [CueFile[]]$Files = $null
    $Tracks = @();

    CueSheet([string]$Path, [string]$Encoding) {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            throw [System.IO.FileNotFoundException] "Invalid cue sheet path";
        }
        
        $File = $null;
        if (Test-Path -Path "$([WildcardPattern]::Escape($Path))" -PathType "Leaf") {
            $File = Get-Item -Path "$([WildcardPattern]::Escape($Path))";
        }
        elseif (Test-Path -LiteralPath $Path -PathType "Leaf") {
            $File = Get-Item -LiteralPath $Path;
        }
        else {
            throw [System.IO.FileNotFoundException] "Cue sheet file `"$Path`" not found.";
        }

        $this.Path = $File;
        $this.Init($File, $Encoding);
    }

    hidden Init([string]$File, [string]$Encoding) {
        Get-Content "$([WildcardPattern]::Escape($File))" -Encoding $Encoding | ForEach-Object {
            $_.Trim()
        } | ForEach-Object {
            $this.ParseLine($_)
        };

        $this.GetTracks();
    }

    hidden GetTracks() {
        #https://wiki.hydrogenaud.io/index.php?title=Tag_Mapping

        foreach ($CurFile in $this.Files) {
            [int]$TrackCount = $CurFile.Tracks.Length;
            
            foreach ($CurTrack in $CurFile.Tracks) {
                [CueTrack]$CurTrack = $CurTrack;
                $CurTrackInfo = [ordered]@{};
                
                if ($null -ne $this.Title) {
                    $CurTrackInfo["ALBUM"] = $this.Title;
                }
                if ($null -ne $CurTrack.Title) {
                    $CurTrackInfo["TITLE"] = $CurTrack.Title;
                }
                
                if ($null -ne $this.Performer) {
                    $CurTrackInfo["ALBUMARTIST"] = $this.Performer;
                }

                if ($null -ne $this.Date) {
                    $CurTrackInfo["DATE"] = $this.Date;
                }

                if ($null -ne $this.Comment) {
                    $CurTrackInfo["COMMENT"] = $this.Comment;
                }

                if ($null -ne $CurTrack.Number) {
                    $CurTrackInfo["TRACKNUMBER"] = $CurTrack.Number;
                }

                if ($null -ne $CurTrack.Performer) {
                    $CurTrackInfo["ARTIST"] = $CurTrack.Performer;
                }
                elseif ($null -ne $this.Performer) {
                    $CurTrackInfo["ARTIST"] = $this.Performer;
                }

                if ($null -ne $CurTrack.Songwriter) {
                    $CurTrackInfo["WRITER"] = $CurTrack.Songwriter;
                }
                elseif ($null -ne $this.Songwriter) {
                    $CurTrackInfo["WRITER"] = $this.Songwriter;
                }

                if ($null -ne $CurTrack.Composer) {
                    $CurTrackInfo["COMPOSER"] = $CurTrack.Composer;
                }
                elseif ($null -ne $this.Composer) {
                    $CurTrackInfo["COMPOSER"] = $this.Composer;
                }

                $CurTrackInfo["TRACKTOTAL"] = $TrackCount;
                $CurTrackInfo["TOTALTRACKS"] = $TrackCount;

                $this.Tracks += $CurTrackInfo;
            }
        }

        # if ($TotalAcrossFiles) {
        #    (0..$CueTracks.Length - 1) | ForEach-Object {
        #     $CueTracks[$_]["TOTALTRACKS"] = $CueTracks.Length
        #     }
        # }
    }

    [CueFile]GetCurrentFile() {
        if ($null -eq $this.Files) {
            throw [InvalidOperationException] "Cannot get current file (not initialized)";
        }

        $alen = $this.Files.Length
        if ($alen -eq 0) {
            throw [InvalidOperationException] "Cannot get current file (array length 0)";
        }

        return $this.Files[$alen - 1];
    }

    [void]ParseREM($line) {
        [string]$line = $line.Replace("REM ", "");
        $this.ParseLine($line);
    } 
    
    [void]ParseFile($line) {
        $SplitLine = Split-Quoted $line;

        $FileName = $SplitLine[1].Trim("`"");
        $FileType = $SplitLine[2];

        [CueFile]$NewFile = New-Object CueFile;
        $NewFile.Name = $FileName;
        $NewFile.Type = $FileType;

        if ($null -eq $this.Files) {
            $this.Files = [CueFile[]]@();
        }
        $this.Files += $NewFile;
    } 
    
    [void]ParseTrack($line) {
        [CueFile]$CurFile = $this.GetCurrentFile();
        $CurFile.ParseTrack($line);
    }

    [void]ParseGlobalProp($line) {
        [string[]]$SplitLine = Split-Quoted $line;
        if ($SplitLine.Length -lt 2) {
            throw [FormatException] "Failed to parse line $line";
        }

        [string]$FomattedPropName = (Get-Culture).TextInfo.ToTitleCase(
            $SplitLine[0].ToLower());
        if ($SplitLine.Length -eq 2) {
            [string]$PropValue = $SplitLine[1];
        }
        else {
            [string]$PropValue = $SplitLine[1..($SplitLine.Length - 1)];
        }

        $this.$FomattedPropName = $PropValue;
    }

    [void]ParseTrackProp($line) {
        $CurFile = $this.GetCurrentFile();
        $CurTrack = $CurFile.GetCurrentTrack();
        $CurTrack.ParseTrackProp($line);
    }

    [void]ParseIndex($line) {
        $CurFile = $this.GetCurrentFile();
        $CurTrack = $CurFile.GetCurrentTrack();
        $CurTrack.ParseIndex($line);
    }
    
    [void]ParseGlobalOrTrackProp($line) {
        if ($null -eq $this.Files) {
            $this.ParseGlobalProp($line);
        }
        else {
            $this.ParseTrackProp($line);
        }
    }
    
    [void]ParseLine($line) {
        [string[]]$SplitLine = $line -split " ", 2;
        [string]$FieldName = $SplitLine[0];

        switch ($FieldName) {
            "REM" { $this.ParseREM($line) }

            "FILE" { $this.ParseFile($line) }
            "TRACK" { $this.ParseTrack($line) }
            "INDEX" { $this.ParseIndex($line) }

            "CATALOG" { $this.ParseGlobalProp($line) }
            "CDTEXTFILE" { $this.ParseGlobalProp($line) }

            "DATE" { $this.ParseGlobalProp($line) }
            "GENRE" { $this.ParseGlobalProp($line) }
            "DISCID" { $this.ParseGlobalProp($line) }
            "COMMENT" { $this.ParseGlobalProp($line) }
            "COUNTRY" { $this.ParseGlobalProp($line) }

            "FLAGS" { $this.ParseTrackProp($line) }
            "ISRC" { $this.ParseTrackProp($line) }
            "POSTGAP" { $this.ParseTrackProp($line) }
            "PREGAP" { $this.ParseTrackProp($line) }

            "SONGWRITER" { $this.ParseGlobalOrTrackProp($line) }
            "PERFORMER" { $this.ParseGlobalOrTrackProp($line) }
            "TITLE" { $this.ParseGlobalOrTrackProp($line) }
            "COMPOSER" { $this.ParseGlobaOrTracklProp($line) }


            Default { throw [ArgumentException] "Unknown field name $FieldName" }
        }
    }
}
