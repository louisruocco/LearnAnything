function Find {
    param (
        [Parameter(Mandatory)]
        [string]$topic
    )
    $apiKey = Get-Content 'E:\Code\Learn Anything\utils\secrets.txt'
    $endpoint = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=$topic&type=video&key=$apiKey"
    $res = Invoke-RestMethod $endpoint
    $items = $res.items
    foreach($item in $items){
        $titles = $item.snippet.title
        $ids = $item.id.videoId
        $table = @{ $titles = $ids }
        foreach($video in $table){
            $keys = $video.Keys
            $values = $video.Values
            write-host "$keys | https://www.youtube.com/watch?v=$values"
        }
    }
}

Find 