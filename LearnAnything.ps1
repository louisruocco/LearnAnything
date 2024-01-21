function Find {
    param (
        [Parameter(Mandatory)]
        [string]$topic
    )
    $apiKey = Import-Clixml -Path .\utils\apikey.xml | ConvertFrom-SecureString -AsPlainText
    $endpoint = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=$topic&type=video&key=$apiKey"
    $res = Invoke-RestMethod $endpoint
    $items = $res.items
    $results = foreach($item in $items){
        $titles = $item.snippet.title
        $ids = $item.id.videoId
        $table = @{ $titles = $ids }
        foreach($video in $table){
            $keys = $video.Keys
            $values = $video.Values
            "$keys | <a href = 'https://www.youtube.com/watch?v=$values'>https://www.youtube.com/watch?v=$values</a>"
        }
    }

    Send-Email
}

function Send-Email {
    $username = Import-Clixml -Path ".\utils\username.xml" | ConvertFrom-SecureString -AsPlainText
    $emailAddress = Import-Clixml -Path ".\utils\emailAddress.xml" | ConvertFrom-SecureString -AsPlainText
    $password =  Import-Clixml -Path ".\utils\password.xml"
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
    $cred.UserName
    $videos = foreach($video in $results){
        "<li>$video</li>"
    }

    $body = @"
    <h1>Learning Resources for $topic</h1>
    <p>Please find some learning resources that could be useful on $topic</p>
    <h2>Videos</h2>
    <ul>
        $videos
    </ul>


"@
    $email = @{
        from = $cred.UserName
        to = $emailAddress
        subject = "Search Results for $topic"
        smtpserver = "smtp.gmail.com"
        body = $body
        port = 587
        credential = $cred
        usessl = $true
        verbose = $true
    }

    Send-MailMessage @email -BodyAsHtml

}

Find