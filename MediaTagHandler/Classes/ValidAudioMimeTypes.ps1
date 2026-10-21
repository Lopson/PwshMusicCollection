class ValidAudioMimeTypes : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        'audio/aac', 'audio/x-aiff', 'audio/aiff', 'sound/aiff',
        'application/x-aiff', 'audio/x-ape', 'audio/ape', 'application/x-ape',
        'audio/x-ms-wma', 'audio/x-ms-asf', 'video/x-ms-asf',
        'audio/x-audible', 'audio/x-dsf', 'audio/dsf', 'sound/dsf',
        'application/x-dsf', 'audio/x-flac', 'application/x-flac',
        'audio/flac', 'audio/mp4', 'audio/x-m4a', 'audio/x-mp3',
        'application/x-id3', 'audio/mpeg', 'audio/x-mpeg', 'audio/x-mpeg-3',
        'audio/mpeg3', 'audio/mp3', 'audio/x-mp2', 'audio/x-mp1',
        'audio/x-musepack', 'application/ogg', 'application/x-ogg',
        'audio/vorbis', 'audio/x-vorbis', 'audio/x-vorbis+ogg', 'audio/ogg',
        'audio/x-ogg', 'video/ogg', 'video/x-ogm+ogg', 'video/x-theora+ogg',
        'video/x-theora', 'audio/opus', 'audio/x-opus', 'audio/x-opus+ogg',
        'audio/wav', 'audio/wave', 'audio/x-wav', 'audio/x-wavpack',
        'video/x-matroska', 'application/octet-stream',
        'audio/x-wavpack-correction', 'audio/x-dff', 'audio/dff', 'sound/dff',
        'application/x-dff'
    )

    static [string[]]$DsdValues = @(
        'audio/x-wavpack-correction', 'audio/x-dff', 'audio/dff', 'sound/dff',
        'application/x-dff', 'audio/x-dsf', 'audio/dsf', 'sound/dsf',
        'application/x-dsf'
    )

    [string[]] GetValidValues() {
        return [ValidAudioMimeTypes]::ValidValues;
    }

    [string[]] GetDsdValues() {
        return [ValidAudioMimeTypes]::DsdValues;
    }
}
