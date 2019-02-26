Function PSGamGroupUpdate {

Param(
[Parameter(Mandatory=$true, Position=0)]
$adgroup,
[Parameter(Mandatory=$true, Position=1)]
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


$ADUser = New-Object System.Collections.Generic.List[System.Object]
$users = Get-ADGroup $adgroup -Properties Member | Select-Object -Expand Member | Get-ADUser -Property mail | select -ExpandProperty mail
foreach ($user in $users) {

$ADUsers.add($user)

}

#$compare = Compare-Object -referenceobject ($Users) -differenceobject ($GoogleArray) #| Where-Object {$_.SideIndicator -eq '<=' or } | Select-Object -ExpandProperty inputobject

$compare = $ADUsers | Where{$GoogleArray -notcontains $_}

$compare = $compare | Sort-Object -Property @{Expression={$_.Trim()}} -Unique

foreach ($object in $compare){

Add-Content $env:APPDATA\PSGAM\temp\gamfile.txt "gam update group $googlegroup add member user $object"

}
$ErrorActionPreference = 'SilentlyContinue'

try{
& gam.exe batch $env:APPDATA\PSGAM\temp\gamfile.txt
}
catch{
}
$ErrorActionPreference = 'Continue'

Remove-Item -Recurse -Force $env:APPDATA\PSGAM\temp
}
Export-ModuleMember -Function PSGamGroupUpdate