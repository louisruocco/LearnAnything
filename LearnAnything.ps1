function Find {
    param (
        [Parameter(Mandatory)]
        [string]$topic
    )

    # encrypt credentials on first run
    $username = ".\utils\username.xml"
    $emailaddress = ".\utils\emailaddress.xml"
    $password = ".\utils\password.xml"
    $apikey = ".\utils\apikey.xml"

    try {
        if(!(Test-Path $username) -and !(Test-Path $password) -and !(Test-Path $emailaddress) -and !(Test-Path $apikey)){
            Get-Content "$PSScriptRoot\utils\username.txt" | ConvertTo-SecureString -AsPlainText -Force  | Export-Clixml -Path "$PSScriptRoot\utils\username.xml"
            Get-Content "$PSScriptRoot\utils\password.txt" | ConvertTo-SecureString -AsPlainText -Force | Export-Clixml -Path "$PSScriptRoot\utils\password.xml"
            Get-Content "$PSScriptRoot\utils\emailaddress.txt" | ConvertTo-SecureString -AsPlainText -Force  | Export-Clixml -Path "$PSScriptRoot\utils\emailaddress.xml"
            Get-Content "$PSScriptRoot\utils\apikey.txt" | ConvertTo-SecureString -AsPlainText -Force  | Export-Clixml -Path "$PSScriptRoot\utils\apikey.xml"
            Remove-Item -Path  "$PSScriptRoot\utils\username.txt"  
            Remove-Item -Path  "$PSScriptRoot\utils\password.txt"  
            Remove-Item -Path  "$PSScriptRoot\utils\emailaddress.txt"  
            Remove-Item -Path  "$PSScriptRoot\utils\apikey.txt"  
        }
    } Catch {
        Write-output "No credentials found. Please try again"
    }

    # find results and send email
    Write-Output "Finding results based on $topic..."
    $path = resolve-path $PSScriptRoot\utils
    Set-location $path
    $apiKey = Import-Clixml -Path $PSScriptRoot\utils\apikey.xml | ConvertFrom-SecureString -AsPlainText
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

    Write-Host "Sending results now!"
    $username = Import-Clixml -Path "$PSScriptRoot\utils\username.xml" | ConvertFrom-SecureString -AsPlainText
    $emailAddress = Import-Clixml -Path "$PSScriptRoot\utils\emailAddress.xml" | ConvertFrom-SecureString -AsPlainText
    $password =  Import-Clixml -Path "$PSScriptRoot\utils\password.xml"
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
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

    Send-MailMessage @email -BodyAsHtml -WarningAction 0

    set-location $HOME
}

Find
