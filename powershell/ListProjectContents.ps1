# change version if running a different version of EG
$eguideApp = New-Object -comObject SASEGObjectModel.Application.7.1

# use the special $input variable to pipe file objects into the script
# for processing
if ( @($input).Count -eq 0) 
{
  Write-Host "EXAMPLE Usage: ls <directoryOfProjects>\*.egp | ListProjectContents.ps1"
  Exit -1
}
else
{
  #reset the $input enumerator
  $input.Reset()
 }
 
foreach ($projName in $input)
{
	# Open the project file
	Write-Host " --------------------------------------------- "
	Write-Host "Examining project:" $projName
	$project = $eguideApp.Open("$projName", "")

	# Show all of the process flows in the project
	$pfCollection = $project.ContainerCollection
	Write-Host "Process flows within project:"
	foreach ($pf in $pfCollection)
	{
	  if ($pf.ContainerType -eq 0)
	  {
		Write-Host "  " $pf.Name
		foreach ($item in $pf.Items)
		{
		  # report on each item within the process flow
		  Write-Host "    " $item.Name " (" $item.GetType() ")"
		  if ($item.GetType().ToString() -eq "SAS.EG.Scripting.Data")
		  {
		    # report on each task attached to this DATA item
		    foreach ($task in $item.Tasks)
			{
			  Write-Host "      " $task.Name  " (" $task.GetType() ")"
			}
		  }
		}
	  }
	}

	Write-Host " ------------------------------------------------------ "
	# Show all of the data references within the project 
	$dataCollection = $project.DataCollection
	Write-Host "ALL Data used within project:"
	foreach ($dataItem in $dataCollection)
	{
	  Write-Host "  " $dataItem.FileName " on server " $dataItem.Server
	}

	# Show all of the code items embedded within the project
	$codeCollection = $project.CodeCollection
	Write-Host "ALL SAS programs embedded within project:"
	foreach ($codeItem in $codeCollection)
	{
	  Write-Host "  """ $codeItem.Name """ runs on server " $codeItem.Server 
	}

	# Close the project file
	$project.Close()
}
# Quit (end) the application object
$eguideApp.Quit()