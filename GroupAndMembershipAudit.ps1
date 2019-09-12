#Import activedirectory module
import-module activedirectory

#Set Execution Policy so that you can run the script
Set-ExecutionPolicy -scope CurrentUser -ExecutionPolicy RemoteSigned

write-host "Enter partial name of group(s) to list membership" -foregroundcolor yellow

$groupname = read-host "Group Name"

#Add wildcard after group
$groupname = $groupname + '*'

$Groups = (Get-AdGroup -filter * | Where-Object { $_.name -like $groupname } | Select-Object name -expandproperty name)

#Create blank array to hold group membership data
$Table = @()

#Setup splat
$Record = [ordered]@{
    "Group"          = ""
    "SamAccountName" = ""
    "Name"           = ""
}

Foreach ($Group in $Groups) {

    $Arrayofmembers = Get-ADGroupMember -identity $Group | Select-Object name, samaccountname

    foreach ($Member in $Arrayofmembers) {
        $Record."Group" = $Group
        $Record."SamAccountName" = $Member.SamAccountName
        $Record."Name" = $Member.Name
        $objRecord = New-Object PSObject -property $Record
        $Table += $objrecord
    }

}
write-host "Enter CSV name for output" -foregroundcolor cyan

$Outfile = read-host "CSV Name"

$Table | export-csv "$outfile.csv" -NoTypeInformation