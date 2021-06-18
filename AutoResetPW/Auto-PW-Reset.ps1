# this is a legacy production example of a password generator/reset tool written in PowerShell. The only way to re-produce this in your environment is
# to replace the identifying AD attributes. :-)

Set-ExecutionPolicy unrestricted

#Initialize PowerShell GUI
Add-Type -AssemblyName System.Windows.Forms

Import-Module ActiveDirectory

#important prereqs and functions


function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

function KeyPhrase
    {
    $keyword = @('Ocean','Boardwalk','Casino','Atlantic','Blackjack','Poker','Tower','Hotel','Floor','Dealer','Patron','Beach','Lobby','Slots', 'Shore', 'Office', 'Keyword', 'Oc3an','D3aler','B3ach','Hot3l','Offic3','K3yword','HotelAC','CasinoAC','DealerAC','@tlantic')
    $keyword | Get-Random
    }

$password = KeyPhrase
$password += Get-RandomCharacters -length 4 -characters '1234567890'
$password += Get-RandomCharacters -length 3 -characters '!@#$%*'

#Creates the window form
$AutoPWForm                    = New-Object system.Windows.Forms.Form
$AutoPWForm.ClientSize         = '550,350'
$AutoPWForm.text               = "Corp AD Auto Password Reset"
$AutoPWForm.BackColor          = "#ffffff"

#title label
$PWTitle = New-Object System.Windows.Forms.label
$PWTitle.AutoSize = $true
$PWTitle.Location = '10,25'
$PWTitle.Font = 'Microsoft Sans Serif,14'
$PWTitle.Text = "For CORP Users Only"
$AutoPWForm.Controls.Add($PWTitle)

#admin check label
$PWAdminCheck = New-Object System.Windows.Forms.Label
$PWAdminCheck.Autosize = $true
$PWAdminCheck.Font = 'Microsoft Sans Serif,13'
$PWAdminCheck.Location = '10,310'
$PWAdminCheck.Text = ""

$Currentuser = "$env:UserName"

if(
(Get-ADUser $Currentuser -Properties memberof).memberof -like "CN=ADRIGHTS-IT-Technicians*" -or "CN=Domain Admins*" -or "CN=Enterprise Admins*")
{
$PWAdminCheck.Font = 'Microsoft Sans Serif,10'
$PWAdminCheck.ForeColor = "green"
$PWADminCheck.text = "You are currently logged in with AD privileges"}
Else
{


$PWAdminCheck.Font = 'Microsoft Sans Serif,10'
$PWAdminCheck.ForeColor= "Red"
$PWAdminCheck.Text = "You are NOT currently logged in with AD privileges"}
$AutoPWForm.Controls.Add($PWAdminCheck) 

#body label
$PWLabel = New-Object System.Windows.Forms.label
$PWLabel.AutoSize = $true
$PWLabel.Location = '10,50'
$PWLabel.Font = 'Microsoft Sans Serif,13'
$PWLabel.Text = "Enter 6-digit employee ID"
$AutoPWForm.Controls.Add($PWLabel)

#input box
$objTextbox = New-Object System.Windows.Forms.TextBox
$objTextbox.Location = New-Object System.Drawing.Size(10,80)
$objTextbox.Size = New-Object System.Drawing.Size(120,10)
$AutoPWForm.Controls.Add($objTextbox)

#cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(135,105)
$cancelButton.AutoSize = $true
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$AutoPWForm.Controls.Add($cancelButton)

#canonical name label
$cnlabel = New-Object System.Windows.Forms.Label
$cnlabel.AutoSize = $true
$cnlabel.Font = 'Microsoft Sans Serif,13'
$cnlabel.Location = '10,140'
$AutoPWForm.Controls.Add($cnlabel)

#description label
$desclabel = New-Object System.Windows.Forms.Label
$desclabel.AutoSize = $true
$desclabel.Font = 'Microsoft Sans Serif,13'
$desclabel.Location = '10,164'
$AutoPWForm.Controls.Add($desclabel)

#action label
$actionlabel = New-Object System.Windows.Forms.Label
$actionlabel.AutoSize = $true
$actionlabel.Font = 'Microsoft Sans Serif,13'
$actionlabel.Location = '40,161'
$AutoPWForm.Controls.Add($actionlabel)

#confirm label
$confirmlabel = New-Object System.Windows.Forms.Label
$confirmlabel.AutoSize = $true
$confirmlabel.Font = 'Microsoft Sans Serif,13'
$confirmlabel.Location = '10,200'
$confirmlabel.Text = "Reset user's password?"

#not-found label
$notfoundlabel = New-Object System.Windows.Forms.Label
$notfoundlabel.AutoSize = $true
$notfoundlabel.Font = 'Microsoft Sans Serif,13'
$notfoundlabel.Location = '10,200'
$notfoundlabel.Text = "User not found"

#"OK" button
$objButton = New-Object System.Windows.Forms.Button
$objButton.Location = New-Object System.Drawing.Size(135,78)
$objButton.AutoSize = $true
$objButton.Text = "OK"
$ObjButton.Add_Click({
$AutoPWForm.Controls.Remove($ok2Button)
$AutoPWForm.Controls.Remove($pwislabel)
$AutoPWForm.Controls.Remove($confirmlabel)
$AutoPWForm.Controls.Remove($notfoundlabel)
$AutoPWForm.Controls.Remove($pwlabel)
})
$ObjButton.Add_Click({$global:IDNumber = $objTextbox.Text})
$ObjButton.Add_Click({$cnlabel.Text = Get-ADUser -Filter "employeeID -eq '$IDNumber'" -Properties cn | select -expandProperty cn})
$ObjButton.Add_Click({$desclabel.Text = Get-ADUser -Filter "employeeID -eq '$IDNumber'" -Properties description | select -expandProperty description})
$ObjButton.Add_Click({$global:user = Get-ADUser -Filter "employeeID -eq '$IDNumber'"})
$ObjButton.Add_Click({
if ($cnlabel.Text =  Get-ADUser -Filter "employeeID -eq '$IDNumber'" -Properties cn | select -expandProperty cn)
{$AutoPWForm.Controls.Add($confirmlabel)
$AutoPWForm.Controls.Add($ok2Button)} 

else {$AutoPWForm.Controls.Add($notfoundlabel)}
}
)
$AutoPWForm.Controls.Add($objButton)

#"OK2" button
$ok2Button = New-Object System.Windows.Forms.Button
$ok2Button.Location = New-Object System.Drawing.Size(205,199)
$ok2Button.AutoSize = $true
$ok2Button.Text = "OK"
$Ok2Button.Add_Click({$AutoPWForm.Controls.Add($pwislabel)})
$Ok2Button.Add_Click({$AutoPWForm.Controls.Add($pwlabel)})
$Ok2button.Add_Click({
Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)})
$Ok2button.Add_Click({
Set-ADUser -Identity $user -ChangePasswordAtLogon $true})

#password-is label
$pwislabel = New-Object System.Windows.Forms.Label
$pwislabel.AutoSize = $true
$pwislabel.Font = 'Microsoft Sans Serif,13'
$pwislabel.Location = '10,224'
$pwislabel.Text = "Temporary password is:"

#password label
$pwlabel = New-Object System.Windows.Forms.Label
$pwlabel.AutoSize = $true
$pwlabel.Font = 'Microsoft Sans Serif,13'
$pwlabel.Location = '10,252'
$pwlabel.Text = "$password"

$AutoPWForm.ShowDialog()
