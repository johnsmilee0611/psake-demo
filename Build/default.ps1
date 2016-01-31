﻿properties {

FormatTaskName "`r`n`r`n------------ Executing {0} Task ------------"

task default -depends Test

task Init -description "Initialises the build by removing previous artifacts and creating output directories" `
		  -requiredVariables outputDirectory, temporaryOutputDirectory, buildConfiguration, buildPlatform {
	# check build configurations
    Assert -conditionToCheck("Debug", "Release" -contains $buildConfiguration) `
			  -failureMessage "Invalid build configuration '$buildConfiguration'. Valid values are 'Debug' or 'Release'"
	Assert -conditionToCheck("x86", "x64", "Any CPU" -contains $buildPlatform) `
			  -failureMessage "Invalid build platform '$buildPlatform'. Valid values are 'x86' or 'x64' or 'Any CPU'"

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

task Test -depends Compile, Clean -description "Run unit tests" {
	Write-Host $testMessage
}
