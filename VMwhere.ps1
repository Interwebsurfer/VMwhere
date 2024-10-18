# stops then removes a service using Remove-Service
function newShell{
    param($service, $serviceObject)
    Write-Output "Stopping $service"
    $serviceObject | Stop-Service -Force -ErrorAction SilentlyContinue
    Write-Output "Removing $service as a service"
    $serviceObject | Remove-Service
}
# stops then removes a service using sc.exe
function oldShell{
    param($service, $serviceObject)
    Write-Output "Stopping $service"
    $serviceObject | Stop-Service -Force -ErrorAction SilentlyContinue
    Write-Output "Removing $service as a service"
    sc.exe delete $serviceObject.Name
}
# takes a service, gets it as an  object, checks to see if it exists, checks the powershell version then runs one of the two above functions
function serviceKiller{
    param($service)
    # this gets the object and saves it to a variable
    $serviceObject = Get-Service -DisplayName $service -ErrorAction SilentlyContinue
    # this makes sure that the service exists
    if($null -eq $serviceObject){
        Write-Output "$service not found, skipping"
        return
    }
    # checks to see the powershell version, runs oldShell if less than 6 otherwise runs newShell
    if($PSVersionTable.PSVersion.Major -lt 6){
        oldShell $service $serviceObject
    }else{
        newShell $service $serviceObject
    }
}

# This function takes no parameters and is hard coded, deal with it. Finds the unique ID and removes it for VMware tools
# Also deletes all of SOFTWARE\VMware, Inc.
function regNuke {
    $regpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $regkey = $regpath | Get-ChildItem | Get-ItemProperty | Where-Object { 'VMware Tools' -contains $_.DisplayName }
    $fullpath = $regkey.PSPath

    Write-Output "Found registry folder for VMware tools at $fullpath"

    # this then recursively deletes it 
    Write-Output "Deleting $fullpath"
    Remove-Item -Path $fullpath -Recurse


    # Computer\HKLM\SOFTWARE\VMware, Inc.
    $path = 'HKLM:\SOFTWARE\VMware, Inc.'
    Write-Output "Checking to see if the path: $path exists..."
    $pathExists = Test-Path -path $path
    if($pathExists){
        Write-Output "Path exists, deleting it and it's subfolders"
        Remove-Item -Path $path -Recurse
        # this will then verify to see if the path was actually removed
        $pathExists = Test-Path -path $path
        if($pathExists){ 
            Write-Output "Something went wrong...path was not removed"
        }else{
            Write-Output "$path was successfully removed!"
        }
    }else{
        Write-Output "Path does not exist, skipping"
    }
}

# start of main
serviceKiller "VMware Alias Manager and Ticket Service"
serviceKiller "VMware Snapshot Provider"
serviceKiller "VMware Tools"
serviceKiller "VMware SVGA Helper Service"

#this removes the program data 
Write-Output "Removing VMware's program data"
Remove-Item -LiteralPath "C:\ProgramData\VMware" -Force -Recurse
# this removes the program files folder
Write-Output "Removing VMware's program Files"
Remove-Item -LiteralPath "C:\Program Files\VMware" -Force -Recurse
regNuke