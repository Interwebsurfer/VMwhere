# VMwhere
VMwhere is Powershell script to automate the removal of VMware Tools on machines that have been transferred from VM to physical.

## Why not just use the built in uninstaller?
Good question, the built in uninstaller does not work when machines that were a VM have there image transferred to a physical machine. This is becuase VMware tools is not supposed to be able to run or install on physical machines.

## Your script bricked my machine!
Sorry to hear that, sounds like a skill issue though. In all seriousness do be careful with the script, it deletes registry keys to stop the machine from thinking VMware tools is still installed. It targets two **very** specific registry folders, but when altering the registry at all it is best to be on the safe side.

# Please test before using this script in a live environment, for your own sake
