param([Parameter(Mandatory=$true)] $JSONFile)

function CreateADGroup()
{
    param([Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    New-ADGroup -Name $name -GroupScope Global
}

function RemoveADGroup()
{
    param([Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$false
}

function CreateADUser()
{
    param([Parameter(Mandatory=$true)] $userObject)

    # Pull out the name from the JSON object

    $name = $userObject.name
    $password = $userObject.password

    # Generate a "first initial, last name" structure for username

    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $SamAccountName = $username
    $principalname = $username

    # Actually create the AD user object
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # Add the user its appropriate group
    foreach($group_name in $userObject.groups) {
        try 
        {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "User $name NOT added to group $group_name because it does not exist"
        }
    }
}

function WeakenPasswordPolicy()
{
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db C:\Windows\Security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITY
    Remove-Item -Force C:\Windows\Tasks\secpol.cfg -Confirm:$false
}

WeakenPasswordPolicy

$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach($group in $json.groups)
{
    CreateADGroup $group
}

foreach($user in $json.users)
{
    CreateADUser $user
}