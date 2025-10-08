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

class CueFile {
    [string]$Name = $null
    [string]$Type = $null

    [CueTrack[]]$Tracks = $null

    [CueTrack]GetCurrentTrack() {
        if ($null -eq $this.Tracks) {
            throw [InvalidOperationException] "Cannot get current track `(not initialized`)"
        }

        [int]$alen = $this.Tracks.Length;
        if ($alen -eq 0) {
            throw [InvalidOperationException] "Cannot get current track `(array length 0`)"
        }

        return $this.Tracks[$alen - 1];
    }

    [void]ParseTrack($line) {
        [string[]]$SplitLine = Split-Quoted $line;

        [int]$TrackNum = [int]$SplitLine[1].Trim("`"");
        [string]$TrackType = $SplitLine[2];

        [CueTrack]$NewTrack = New-Object CueTrack;
        $NewTrack.Number = $TrackNum;
        $NewTrack.Type = $TrackType;

        if ($null -eq $this.Tracks) {
            $this.Tracks = [CueTrack[]]@();
        }
        $this.Tracks += $NewTrack;
    }
}
