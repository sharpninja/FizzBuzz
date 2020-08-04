param (
    [string[]] $Targets = @()
)

Clear-Host
[string[]]$tgts = @()

if ($Targets.Length -gt 0) { 
    Write-Debug "Targets is not null."
    $tgts = $Targets 
}

if ($tgts.Length -eq 0) {
    Write-Debug "Populating tgts"
    $tgts += "x64";
    $tgts += "x86";
    $tgts += "armhf";
    $tgts += "C";
    $tgts += "C++";
    $tgts += "CSharp";
    $tgts += "CSharpExpressions";
    $tgts += "CSharpIL";
    $tgts += "VisualBasic";
    $tgts += "FSharp";
    $tgts += "Java";
    $tgts += "JavaScript";
    $tgts += "PowerShell";
    $tgts += "PS-Ninja";
    $tgts += "Python3";
    $tgts += "Ruby";
}

$pattern = [string]::Join("|", $tgts).Replace("+", "\+")

$directory = Get-Location
$root = $directory.Path

. $directory\Write-OutputFile.ps1

$referenceHash = (Get-FileHash $directory\FizzBuzz.txt).Hash;
$failed = New-Object "System.Collections.Generic.List[String]"
$passed = New-Object "System.Collections.Generic.List[String]"

function Invoke-FizzBuzz {
    param (
        $location = "\src"
        , $buildCommand = ""
        , $buildCommandParameters = ""
        , $buildCommandParametersArray = @()
        , $executeCommand = ""
        , $executeCommandParameters = ""
        , $executeCommandParametersArray = @()
        , $nameShort = ""
        , $nameLong = ""
        , $preBuild = ""
        , [System.Collections.Generic.List[String]] $fail
        , [System.Collections.Generic.List[String]] $pass
        , [System.Collections.Generic.List[String]] $targets
    )

    process {
        if ($null -eq $root) { $root = "" }
        if ($null -eq $location) { $location = "" }
        if ($null -eq $buildCommand) { $buildCommand = "" }
        if ($null -eq $buildCommandParameters) { $buildCommandParameters = "" }
        if ($null -eq $buildCommandParametersArray) { $buildCommandParametersArray = @( "" ) }
        if ($null -eq $executeCommand) { $executeCommand = "" }
        if ($null -eq $executeCommandParameters) { $executeCommandParameters = "" }
        if ($null -eq $executeCommandParametersArray) { $executeCommandParametersArray = @( "" ) }
        if ($null -eq $nameShort) { $nameShort = "" }
        if ($null -eq $nameLong) { $nameLong = "" }
        if ($null -eq $preBuild) { $preBuild = "" }

        Write-Host "Looking for [$nameShort]"
        Write-Debug $root
        Write-Debug $location
        Write-Debug $buildCommand
        Write-Debug $buildCommandParameters
        Write-Debug $executeCommand
        Write-Debug $executeCommandParameters
        Write-Debug $nameShort
        Write-Debug $nameLong
        Write-Debug $preBuild

        $isTarget = $targets | Where-Object { $nameShort -ilike $_ }
        $found = Get-Command $buildCommand -errorAction SilentlyContinue

        Write-Debug "[$isTarget]"
        if ($isTarget -and $found) {        
            Write-Debug "$buildCommand exists"

            Write-Debug "Building $nameLong in $location"

            Join-Path $root -ChildPath $location | Set-Location
            $wd = Get-Location

            if ($preBuild) {
                & $preBuild
            }

            Write-Host "$buildCommand $buildCommandParameters $buildCommandParametersArray"
            & $buildCommand $buildCommandParameters $buildCommandParametersArray

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Executing $executeCommand $executeCommandParameters $executeCommandParametersArray in $location"

                $outputFilename = Join-Path $root -ChildPath "FizzBuzz.$nameShort.txt"

                & $executeCommand $executeCommandParameters $executeCommandParametersArray > $outputFilename

                if (-not($referenceHash -eq ((Get-FileHash $outputFilename).Hash))) {
                    Write-Host "Incorrect hash on output for $nameLong implementation. :("
                    $fail.Add($wd)
                }
                else {
                    Write-Debug "$nameLong passed!"
                    $pass.Add($wd)
                }
            }
            else {
                Write-Host "Error compiling $nameLong program."        
            }        
        }
    }
}

function Invoke-FizzBuzzNoBuild {
    param (
        $location = "\src"
        , $command = ""
        , $commandParameters = ""
        , $commandParametersArray = @()
        , $nameShort = ""
        , $nameLong = ""
        , $preExecute = ""
        , [System.Collections.Generic.List[String]] $fail
        , [System.Collections.Generic.List[String]] $pass
        , [System.Collections.Generic.List[String]] $targets
    )

    process {
        if ($null -eq $root) { $root = "" }
        if ($null -eq $location) { $location = "" }
        if ($null -eq $command) { $command = "" }
        if ($null -eq $commandParameters) { $commandParameters = "" }
        if ($null -eq $nameShort) { $nameShort = "" }
        if ($null -eq $nameLong) { $nameLong = "" }
        if ($null -eq $preExecute) { $preExecute = "" }

        Write-Host "Looking for [$nameShort]"
        Write-Debug $root
        Write-Debug $location
        Write-Debug $command
        Write-Debug $commandParameters
        Write-Debug $nameShort
        Write-Debug $nameLong
        Write-Debug $preExecute

        $isTarget = $targets | Where-Object { $nameShort -ilike $_ }
        Write-Debug "[$isTarget]"
        $found = Get-Command $command -errorAction SilentlyContinue

        if ($isTarget -and $found) {        
            Write-Debug "$command exists"

            Join-Path $root -ChildPath $location | Set-Location
            $wd = Get-Location

            if ($preExecute -ne "") {
                & $preExecute
            }

            Write-Host "Executing $command $commandParameters $commandParametersArray in $location"

            $outputFilename = Join-Path $root -ChildPath "FizzBuzz.$nameShort.txt"
            
            & $command $commandParameters $commandParametersArray > $outputFilename

            if (-not($referenceHash -eq ((Get-FileHash $outputFilename).Hash))) {
                Write-Host "Incorrect hash on output for $nameLong implementation. :("
                $fail.Add($wd)
            }
            else {
                Write-Debug "$nameLong passed!"
                $pass.Add($wd)
            }
        }
    }
}

$tests = Get-ChildItem test.json -Recurse

$tests | ForEach-Object -Process {
    if ($_ -match $pattern) {
        Write-Host "Testing $_"
        $test = (Get-Content $_ | Out-String | ConvertFrom-Json)

        Invoke-FizzBuzz -location $test.location `
            -buildCommand $test.buildCommand `
            -buildCommandParameters $test.buildCommandParameters `
            -buildCommandParametersArray $test.buildCommandParametersArray `
            -executeCommand $test.executeCommand `
            -executeCommandParameters $test.executeCommandParameters `
            -executeCommandParametersArray $test.executeCommandParametersArray `
            -nameShort $test.nameShort `
            -nameLong $test.nameLong `
            -preBuild $test.preBuild `
            -fail $failed `
            -pass $passed `
            -targets $tgts
    }
}

Set-Location $directory

$tests = Get-ChildItem test_nobuild.json -Recurse

$tests | ForEach-Object -Process {
    if ($_ -match $pattern) {
        Write-Host "Testing $_"
        $test = (Get-Content $_ | Out-String | ConvertFrom-Json)

        Invoke-FizzBuzzNoBuild -location $test.location `
            -command $test.command `
            -commandParameters $test.commandParameters `
            -commandParametersArray $test.commandParametersArray `
            -nameShort $test.nameShort `
            -nameLong $test.nameLong `
            -preExecute $test.preExecute `
            -fail $failed `
            -pass $passed `
            -targets $tgts
    }
}

Set-Location $directory

Write-Host ""
Write-Host "Results"

if ($failed.Count -gt 0) {
    Write-Host "Failed:"
    $failed | Sort-Object | ForEach-Object -Process {
        Write-Host $_
    }
}

if ($passed.Count -gt 0) {
    Write-Host "Passed:"
    $passed | Sort-Object | ForEach-Object -Process {
        Write-Host $_
    }
}
