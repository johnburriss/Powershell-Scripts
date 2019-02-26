Function PS-GamGroupUpdate {

Param(
[Parameter(Mandatory=$true, Position=0)]
[ValidateSet("add", "remove")]
$action,
[Parameter(Mandatory=$false, Position=1)]
[ValidateSet("member", "manager", "owner")]
$title,
[Parameter(Mandatory=$true, Position=2)]
$adgroup,
[Parameter(Mandatory=$true, Position=3)]
$googlegroup
)


$env:GAM_THREADS=20

$path = "$env:APPDATA\PSGAM"
$testpath = "$env:APPDATA\PSGAM\temp"



if(!(Test-Path $Path)) { 
    New-Item -ItemType directory -Path "$env:APPDATA\PSGAM"
}

if(!(Test-Path $testpath)) {
New-Item -ItemType directory -Path  "$env:APPDATA\PSGAM\temp"
}


New-Item -ItemType "file" -Path "$env:APPDATA\PSGAM\temp\gamfile.txt"


$GoogleArray = New-Object System.Collections.Generic.List[System.Object]

$ErrorActionPreference = 'SilentlyContinue'

try{
$GoogleUsers = gam.exe print group-members group $googlegroup
}
catch{
}

$ErrorActionPreference = 'Continue'
 
foreach ($GoogleUser in ($GoogleUsers| select -skip 1)){

$temp = $GoogleUser | ConvertFrom-String -Delimiter "," -PropertyNames group, status, type, role, id, email | select -ExpandProperty email 

$GoogleArray.add($Temp)
}

$users = Get-ADGroup $adgroup -Properties Member | Select-Object -Expand Member | Get-ADUser -Property mail | select -ExpandProperty mail

$compare = $users | Where{$GoogleArray -notcontains $_}

$compare = $compare | Sort-Object -Property @{Expression={$_.Trim()}} -Unique

if($title -ne $null){

foreach ($object in $compare){

Add-Content $env:APPDATA\PSGAM\temp\gamfile.txt "gam update group $googlegroup $action $title user $object"

}
else{

Add-Content $env:APPDATA\PSGAM\temp\gamfile.txt "gam update group $googlegroup $action member user $object"

}
}

$ErrorActionPreference = 'SilentlyContinue'

try{
& gam.exe batch $env:APPDATA\PSGAM\temp\gamfile.txt
}
catch{
}
$ErrorActionPreference = 'Continue'

Remove-Item -Recurse -Force $env:APPDATA\PSGAM\
}
Export-ModuleMember -Function PS-GamGroupUpdate
Function PS-GamUsertoGroup {

Param(
[Parameter(Mandatory=$true, Position=0)]
[ValidateSet("add", "remove")]
$action,
[Parameter(Mandatory=$false, Position=1)]
[ValidateSet("member", "manager", "owner")]
$title,
[Parameter(Mandatory=$true, Position=2)]
$AdUser,
[Parameter(Mandatory=$true, Position=3)]
$googlegroup
)
$path = "$env:APPDATA\PSGAM"
$testpath = "$env:APPDATA\PSGAM\temp"



if(!(Test-Path $Path)) { 
    New-Item -ItemType directory -Path "$env:APPDATA\PSGAM"
}

if(!(Test-Path $testpath)) {
New-Item -ItemType directory -Path  "$env:APPDATA\PSGAM\temp"
}


New-Item -ItemType "file" -Path "$env:APPDATA\PSGAM\temp\gamfile.txt"


$GoogleArray = New-Object System.Collections.Generic.List[System.Object]

$ErrorActionPreference = 'SilentlyContinue'

try{
$GoogleUsers = gam.exe print group-members group $googlegroup
}
catch{
}

$ErrorActionPreference = 'Continue'
 
foreach ($GoogleUser in ($GoogleUsers| select -skip 1)){

$temp = $GoogleUser | ConvertFrom-String -Delimiter "," -PropertyNames group, status, type, role, id, email | select -ExpandProperty email 

$GoogleArray.add($Temp)
}

$user = Get-ADuser $aduser -Properties Member | Select-Object -Expand Member | Get-ADUser -Property mail | select -ExpandProperty mail

$compare = $user | Where{$GoogleArray -notcontains $_}

$compare = $compare | Sort-Object -Property @{Expression={$_.Trim()}} -Unique

if($title -ne $null){

foreach ($object in $compare){

Add-Content $env:APPDATA\PSGAM\temp\gamfile.txt "gam update group $googlegroup $action $title user $object"

}
else{

Add-Content $env:APPDATA\PSGAM\temp\gamfile.txt "gam update group $googlegroup $action member user $object"

}
}

$ErrorActionPreference = 'SilentlyContinue'

try{
& gam.exe batch $env:APPDATA\PSGAM\temp\gamfile.txt
}
catch{
}
$ErrorActionPreference = 'Continue'

Remove-Item -Recurse -Force $env:APPDATA\PSGAM\
}
Export-ModuleMember -Function PS-GamUsertoGroup