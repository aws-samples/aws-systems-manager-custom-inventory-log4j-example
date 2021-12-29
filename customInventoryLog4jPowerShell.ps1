$drives = Get-PSDrive -PSProvider 'FileSystem'
$items = @()
Foreach ($drive in $drives)
{
    $items = Get-ChildItem -Path $drive.Root -Recurse -File -Force -Include *.jar -ErrorAction 0 | Select-String "JndiLookup.class" -List
}

if ($items) {
    $data = $items | Select-Object Filename, Path
    $data = $data | ConvertTo-Json
    $content = "{`"SchemaVersion`" : `"1.0`", `"TypeName`": `"Custom:Log4J`", `"Content`": $data}"
    
    $instanceId = Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/instance-id
    if ($instanceId -ne $null)
    {
        $filepath = "C:\ProgramData\Amazon\SSM\InstanceData\" + $instanceId + "\inventory\custom\CustomLog4J.json"
    }
    else 
    {
        $hybridInstanceId = (Get-Content -Path "C:\ProgramData\Amazon\SSM\InstanceData\registration" | ConvertFrom-Json).ManagedInstanceId
        $filepath = "C:\ProgramData\Amazon\SSM\InstanceData\" + $hybridInstanceId + "\inventory\custom\CustomLog4J.json"
    }
    
    if (-NOT (Test-Path $filepath)) {
        New-Item $filepath -ItemType file
    }
    Set-Content -Path $filepath -Value $content
}
