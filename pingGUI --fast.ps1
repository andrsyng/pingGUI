#Region Function Hide-PowerShellWindow
Function Hide-PowerShellWindow()
{
<#
.SYNOPSIS
Hides the PowerShell Console Window
.DESCRIPTION
Hides the PowerShell Console Window
.PARAMETER Handle
The Handle of the Window to Hide
.EXAMPLE
[Void]$(Hide-PowerShellWindow)
.INPUTS
.OUTPUTS
.NOTES
Copyright (c) 2013 by Me
.LINK
#>
[CmdletBinding()]
param (
[IntPtr]$Handle=$(Get-Process -id $PID).MainWindowHandle
)
$WindowDisplay = @"
using System;
using System.Runtime.InteropServices;

namespace Window
{
public class Display
{
[DllImport("user32.dll")]
private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

public static bool Hide(IntPtr hWnd)
{
return ShowWindowAsync(hWnd, 0);
}
}
}
"@
Try
{
Add-Type -TypeDefinition $WindowDisplay
[Window.Display]::Hide($Handle)
}
Catch
{
}
}
#EndRegion
[Void]$(Hide-PowerShellWindow)


function Test-Port($hostname, $port)
{
    # This works no matter in which form we get $host - hostname or ip address
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($hostname) | 
            select-object IPAddressToString -expandproperty  IPAddressToString
        if($ip.GetType().Name -eq "Object[]")
        {
            #If we have several ip's for that address, let's take first one
            $ip = $ip[0]
        }
    } catch {
       return $false
    }
    $t = New-Object Net.Sockets.TcpClient
    # We use Try\Catch to remove exception info from console if we can't connect
    try
    {
        $t.Connect($ip,$port)
    } catch {}

    if($t.Connected)
    {
        $t.Close()
        $msg = $true
    }
    else
    {
        $msg = $false                               
    }
    return $msg
}



cls

Add-Type -AssemblyName System.Windows.Forms
$mywindow = New-Object System.Windows.Forms.Form
$mywindow.Text ="Ping List"

$mywindow.Width = 600
$mywindow.Height = 600
$mywindow.MaximumSize = "600,600"
$mywindow.MinimumSize ="600,200"
$mywindow.MaximizeBox = $false

$buttonRun = New-Object System.Windows.Forms.Button
$buttonRun.Text = 'Ping'
$buttonRun.Location = New-Object System.Drawing.Point(110,10)
$buttonRun.Scale(2)
$buttonRun.BackColor = "lightgreen"
$mywindow.Controls.Add($buttonRun)

$buttonPort = New-Object System.Windows.Forms.Button
$buttonPort.Text = 'Port'
$buttonPort.Location = New-Object System.Drawing.Point(30,10)
$buttonPort.Scale(2)
$buttonPort.BackColor = "lightblue"
$mywindow.Controls.Add($buttonPort)

$buttonPlus = New-Object System.Windows.Forms.Button
$buttonPlus.Text = '+'
$buttonPlus.Location = New-Object System.Drawing.Point(508,26)
$buttonPlus.Width = 26
$buttonPlus.Height = 26
$buttonPlus.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$buttonPlus.BackColor = "lightblue"
$mywindow.Controls.Add($buttonPlus)

$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "IP"
$infoLabel.Location = New-Object System.Drawing.Point(130,80)
$infoLabel2 = New-Object System.Windows.Forms.Label
$infoLabel2.Text = "Result"
$infoLabel2.Location = New-Object System.Drawing.Point(400,80)
$infoLabelPort = New-Object System.Windows.Forms.Label
$infoLabelPort.Text = "Port:"
$infoLabelPort.ForeColor = "blue"
$infoLabelPort.Location = New-Object System.Drawing.Point(420,30)


$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Size = New-Object System.Drawing.Size(250,400) 
$TextBox.Location  = New-Object System.Drawing.Point(30,100)
$TextBox.Multiline =  $true

$mywindow.Controls.Add($TextBox)

$TextBoxPort = New-Object System.Windows.Forms.TextBox
$TextBoxPort.Size = New-Object System.Drawing.Size(50,24) 
$TextBoxPort.Location  = New-Object System.Drawing.Point(460,27)
$TextBoxPort.Multiline =  $true
$mywindow.Controls.Add($TextBoxPort)

$TextBox2 = New-Object System.Windows.Forms.TextBox
$TextBox2.Size = New-Object System.Drawing.Size(250,400) 
$TextBox2.Location  = New-Object System.Drawing.Point(300,100)
$TextBox2.Multiline =  $true
$mywindow.Controls.Add($TextBox2)
$mywindow.Controls.Add($infoLabel)
$mywindow.Controls.Add($infoLabel2)
$mywindow.Controls.Add($infoLabelPort)


# Init ProgressBar
$progress = New-Object System.Windows.Forms.ProgressBar
#$progress.Maximum = 100
$progress.Minimum = 0
$progress.Location = new-object System.Drawing.Size(30,514)
$progress.size = new-object System.Drawing.Size(520,25)
$progress.Value = 0
$progress.Style = "Continuous"
$mywindow.Controls.Add($progress)


$objTypeCheckbox = New-Object System.Windows.Forms.Checkbox 
$objTypeCheckbox.Location = New-Object System.Drawing.Size(605,515) 
$objTypeCheckbox.Size = New-Object System.Drawing.Size(500,20)
$objTypeCheckbox.Text = "Log"
$objTypeCheckbox.TabIndex = 4
$objTypeCheckbox.Checked = $false
$objTypeCheckbox.Hide()
$mywindow.Controls.Add($objTypeCheckbox)






Function ButtonRun_Click()
{
   for ($i=0; $i -lt $TextBox.Lines.Count; $i++){
   $progress.Maximum = $($TextBox.Lines.Count)
   $progress.Value = $i + 1
if ($TextBox.Lines[$i] -eq ''){$TextBox2.lines += ""; Continue } 
$tc = Test-Connection $TextBox.Lines[$i] -Quiet
if ($tc) { 
$ip = $TextBox.Lines[$i]
$TextBox2.lines += "$ip OK"
}Else{
$ip = $TextBox.Lines[$i]
$TextBox2.lines += "$ip NOT OK"
}
}

}


Function ButtonPort_Click()
{
$progress.Value = 0
$lines= $TextBoxPort.Lines
$progress.Maximum =$lines.Count * $($TextBox.Lines.Count)
foreach($line in $lines){
if ($($TextBoxPort.Text)  -eq ''){$TextBoxPort.Text = '22'}
   for ($i=0; $i -lt $TextBox.Lines.Count; $i++){
      
#   if($TextBox.Lines.Count
  $pv++
   $progress.Value = $pv
   if ($TextBox.Lines[$i] -eq ''){$TextBox2.lines += ""; Continue } 
#$tcp =  Test-NetConnection -ComputerName $TextBox.Lines[$i] -Port $line   
$tcp= Test-Port $TextBox.Lines[$i] $line
if ($tcp) { 
$ip = $TextBox.Lines[$i]
$TextBox2.lines += "$ip [$line] OK"
}Else{
$ip = $TextBox.Lines[$i]
$TextBox2.lines += "$ip [$line] NOT OK"
}
}
}

}







$buttonRun.Add_Click(
        {    
        $buttonRun.BackColor = "yellow"
If ($objTypeCheckbox.Checked -eq $false)
  {
 $TextBox2.Text = $null
  } Else{$TextBox2.ScrollBars =  "Vertical"; $TextBox.ScrollBars =  "Vertical"}
 
	
ButtonRun_Click
$buttonRun.BackColor = "lightgreen"
        }
    )





$buttonPort.Add_Click(
        {    
        $buttonPort.BackColor = "yellow"

        If ($objTypeCheckbox.Checked -eq $false)
  {
 $TextBox2.Text = $null
  }Else{$TextBox2.ScrollBars =  "Vertical"; $TextBox.ScrollBars =  "Vertical"}
  
	ButtonPort_Click
$buttonPort.BackColor = "lightblue"
        }
    )






Function ButtonPlus_Click()
{
if($($TextBoxPort.Height) -eq 24){
$mywindow.MaximumSize = "720,600"

#for ($i=0; $i -lt 120; $i++){
while ($mywindow.Width -lt 720){
$mywindow.Width = $mywindow.Width + 1
}



$buttonPlus.Text = "-"
$buttonPlus.Location = New-Object System.Drawing.Point(651,26)
$TextBoxPort.Location  = New-Object System.Drawing.Point(601,27)
$infoLabelPort.Location = New-Object System.Drawing.Point(562,30)
$TextBoxPort.Height = 473
$objTypeCheckbox.Show()
}Else{

for ($i=0; $i -lt 120; $i++){
$mywindow.Width = $($mywindow.Width) - 1
}
$mywindow.MaximumSize = "600,600"
$buttonPlus.Text = "+"
$TextBoxPort.Height = 24
$buttonPlus.Location = New-Object System.Drawing.Point(508,26)
$TextBoxPort.Location  = New-Object System.Drawing.Point(460,27)
$infoLabelPort.Location = New-Object System.Drawing.Point(400,30)
$objTypeCheckbox.Hide()

}



}

$buttonPlus.Add_Click(
        {    
         
	ButtonPlus_Click

        }
    )





$mywindow.ShowDialog();


