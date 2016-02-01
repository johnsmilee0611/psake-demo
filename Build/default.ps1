Include ".\helpers.ps1"properties {  $testMessage = 'Executed Test!'  $compileMessage = 'Executed Compile!'  $cleanMessage = 'Executed Clean!'	$packagesPath = "$solutionDirectory\packages"	$solutionDirectory = (Get-Item $solutionFile).DirectoryName	$outputDirectory = "$solutionDirectory\.build"	$temporaryOutputDirectory = "$outputDirectory\temp"	#$publishedMSTestDiretory = "$temporaryOutputDirectory\_PublishedMSTestTests"	#$testResultsDirectory = "$outputDirectory\TestResults"	#$MSTestResultDirectory = "$testResultsDirectory\MSTest"	#$vsTestExe = (Get-ChildItem ("C:\Program Files (x86)\Microsoft Visual Studio*\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe")).FullName | Sort-Object $_ | select -last 1	$buildConfiguration = "Release"	$buildPlatform = "Any CPU"}

FormatTaskName "`r`n`r`n------------ Executing {0} Task ------------"

task default -depends Test

task Init -description "Initialises the build by removing previous artifacts and creating output directories" `
		  -requiredVariables outputDirectory, temporaryOutputDirectory, buildConfiguration, buildPlatform {
	# check build configurations
    Assert -conditionToCheck("Debug", "Release" -contains $buildConfiguration) `
			  -failureMessage "Invalid build configuration '$buildConfiguration'. Valid values are 'Debug' or 'Release'"
	Assert -conditionToCheck("x86", "x64", "Any CPU" -contains $buildPlatform) `
			  -failureMessage "Invalid build platform '$buildPlatform'. Valid values are 'x86' or 'x64' or 'Any CPU'"
	
    # Check that all tools are available
	Write-Host "Checking that all required tools are available"

	#Assert (Test-Path $vsTestExe) "VSTest Console could not be found"

	# Remove previous build results
	if (Test-Path $outputDirectory) {
		Write-Host "Removing output directory located at $outputDirectory"
		Remove-Item $outputDirectory -Force -Recurse
	}
	
	Write-Host "Creating output directory located at $outputDirectory"
	New-Item $outputDirectory -ItemType Directory | Out-Null

	Write-Host "Creating temporary directory located at $temporaryOutputDirectory"
	New-Item $temporaryOutputDirectory -ItemType Directory | Out-Null
}

task Clean -description "Remove temporary files" {
	Write-Host $cleanMessage
}

task Compile  -depends Init  -description "Compile the code" {
	Write-Host "Building solution $solutionFile"
	Exec {
		msbuild $SolutionFile "/p:Configuration=$buildConfiguration;Platform=$buildPlatform;OutDir=$temporaryOutputDirectory"
	}
}

#task TestMSTest -depends Compile -description "Run MSTest tests" -precondition { return Test-Path $publishedMSTestDiretory } -requiredVariable publishedMSTestDiretory, MSTestResultDirectory {
#	$testAssemblies = Prepare-Tests -testRunnerName "MSTest" -publishedTestsDirectory $publishedMSTestDiretory -testResultsDirectory $MSTestResultDirectory
	
#	# vstest console doesn't have any option to change the output directory
#	# so we need to change the working directory
#	Push-Location  $MSTestResultDirectory
#	Exec { &$vsTestExe $testAssemblies /Logger:trx }
#	Pop-Location

#	# move the .trx file back to $MSTestResultDirectory
#	Move-Item -Path $MSTestResultDirectory\TestResults\*.trx -Destination $MSTestResultDirectory\MSTest.trx

#	Remove-Item $MSTestResultDirectory\TestResults
#}

task Test -depends Compile -description "Run unit tests" {
	Write-Host $testMessage
}

