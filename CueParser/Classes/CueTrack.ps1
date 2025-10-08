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

class CueTrack {
    [int]$Number = $null
    [string]$Type = $null

    [string]$Isrc = $null
    [string]$Performer = $null
    [string]$Pregap = $null
    [string]$Postgap = $null
    [string]$Songwriter = $null
    [string]$Title = $null
    [string]$Flags = $null

    [string]$Composer = $null

    [CueIndex[]]$Indices = $null

    [void]ParseTrackProp($line) {
        [string[]]$SplitLine = Split-Quoted $line;
        if ($SplitLine.Length -lt 2) {
            throw [FormatException] "Failed to parse line '$line'";
        }

        [string]$FormattedPropName = (Get-Culture).TextInfo.ToTitleCase(
            $SplitLine[0].ToLower());
        if ($SplitLine.Length -eq 2) {
            $PropValue = $SplitLine[1];
        }
        else {
            $PropValue = $SplitLine[1..$SplitLine.Length - 1];
        }

        switch ($FormattedPropName) {
            "Type" {
                [string[]]$ValidFileTypes = @(
                    "WAVE", "MP3", "AIFF", "BINARY", "MOTOROLA");
                
                if ($PropValue.ToUpper() -notin $ValidFileTypes) {
                    throw [System.ArgumentException] `
                        "Invalid file type found in cue sheet: $PropValue";
                }
            }
        }

        $this.$FormattedPropName = $PropValue;
    }

    [void]ParseIndex($line) {
        [string[]]$SplitLine = Split-Quoted $line;

        [int]$IndexNum = [int]$SplitLine[1].Trim("`"");
        [string]$IndexTime = $SplitLine[2];

        if ($null -eq $this.Indices) {
            $this.Indices = [CueIndex[]]@();
        }

        [CueIndex]$NewIndex = New-Object CueIndex;
        $NewIndex.IndexNum = $IndexNum;
        $NewIndex.IndexTime = $IndexTime;

        $this.Indices += $NewIndex;
    }
}
