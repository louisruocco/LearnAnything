function Find {
    param (
        [Parameter(Mandatory)]
        [string]$topic
    )
    $apiKey = Get-Content 'E:\Code\Learn Anything\utils\secrets.txt'
    $endpoint = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&&q=$topic&key=$apiKey"
    $res = Invoke-RestMethod $endpoint
    $items = $res.items
    $names = $items.snippet.title
    $names
}

Find