class ValidAudioMimeTypes : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        'taglib/aac', 'audio/aac', 'taglib/aif', 'taglib/aiff', 'audio/x-aiff',
        'audio/aiff', 'sound/aiff', 'application/x-aiff', 'taglib/ape',
        'audio/x-ape', 'audio/ape', 'application/x-ape', 'taglib/wma',
        'taglib/asf', 'audio/x-ms-wma', 'audio/x-ms-asf', 'video/x-ms-asf',
        'audio/x-audible', 'taglib/aa', 'taglib/aax', 'taglib/dsf',
        'audio/x-dsf', 'audio/dsf', 'sound/dsf', 'application/x-dsf',
        'taglib/flac', 'audio/x-flac', 'application/x-flac', 'audio/flac',
        'taglib/mka', 'taglib/m4a', 'audio/mp4', 'audio/x-m4a', 'taglib/mp3',
        'audio/x-mp3', 'application/x-id3', 'audio/mpeg', 'audio/x-mpeg',
        'audio/x-mpeg-3', 'audio/mpeg3', 'audio/mp3', 'taglib/m2a',
        'taglib/mp2', 'taglib/mp1', 'audio/x-mp2', 'audio/x-mp1', 'taglib/mpc',
        'taglib/mp+', 'taglib/mpp', 'audio/x-musepack', 'taglib/ogg',
        'taglib/oga', 'taglib/opus', 'application/ogg', 'application/x-ogg',
        'audio/vorbis', 'audio/x-vorbis', 'audio/x-vorbis+ogg', 'audio/ogg',
        'audio/x-ogg', 'video/ogg', 'video/x-ogm+ogg', 'video/x-theora+ogg',
        'video/x-theora', 'audio/opus', 'audio/x-opus', 'audio/x-opus+ogg',
        'taglib/wav', 'audio/wav', 'audio/wave', 'audio/x-wav', 'taglib/wv',
        'audio/x-wavpack', 'video/x-matroska', 'application/octet-stream',
        'audio/x-wavpack-correction'
    )

    [string[]] GetValidValues() {
        return [ValidAudioMimeTypes]::ValidValues;
    }
}
