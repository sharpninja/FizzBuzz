Clear-Host

$referenceHash = (Get-FileHash .\FizzBuzz.txt).Hash;
$failed = @()
$directory = Get-Location

Write-Host "Building C"
Set-Location $directory\src\C
& .\win_x64_build.cmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "Executing C"
    & bin\windows_x64\fizzbuzz.exe > $directory\FizzBuzz.C.txt

    if (-not($referenceHash -eq ((Get-FileHash $directory\FizzBuzz.C.txt).Hash))) {
        Write-Host "Incorrect hash on output for C implementation. :("
        $failed += "$directory\FizzBuzz.C.txt"
    }
}
else {
    Write-Host "Error compiling C program."
}

Write-Host ""
Write-Host "---------------------------------"
Write-Host "Building C#"

Set-Location $directory\src\CSharp
& dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Executing C#"
    & dotnet run --no-build > $directory\FizzBuzz.CSharp.txt

    if (-not($referenceHash -eq ((Get-FileHash $directory\FizzBuzz.CSharp.txt).Hash))) {
        Write-Host "Incorrect hash on output for C# implementation. :("
        $failed += "$directory\FizzBuzz.CSharp.txt"
    }
}
else {
    Write-Host "Error compiling C# program."
}

Write-Host ""
Write-Host "---------------------------------"
Write-Host "Building Java"

Set-Location $directory\src\Java
& javac -cp $env:JAVA_HOME -d bin FizzBuzz.java

if ($LASTEXITCODE -eq 0) {
    Write-Host "Executing Java"
    Set-Location bin
    & java ninja.thesharp.FizzBuzz > $directory\FizzBuzz.Java.txt

    if (-not($referenceHash -eq ((Get-FileHash $directory\FizzBuzz.Java.txt).Hash))) {
        Write-Host "Incorrect hash on output for Java implementation. :("
        $failed += "$directory\FizzBuzz.Java.txt"
    }
    Set-Location ..
}
else {
    Write-Host "Error compiling Java program."
}


Write-Host ""
Write-Host "---------------------------------"
Write-Host "Executing JavaScript"

Set-Location $directory\src\JavaScript
& node index.js > $directory\FizzBuzz.JavaScript.txt

if (-not($referenceHash -eq ((Get-FileHash $directory\FizzBuzz.JavaScript.txt).Hash))) {
    Write-Host "Incorrect hash on output for JavaScript implementation. :("
    $failed += "$directory\FizzBuzz.JavaScript.txt"
}

Write-Host ""
Write-Host "---------------------------------"
Write-Host "Building Python"

Set-Location $directory\src\Python
& python fizzbuzz.py > $directory\FizzBuzz.Python.txt

if (-not($referenceHash -eq ((Get-FileHash $directory\FizzBuzz.Python.txt).Hash))) {
    Write-Host "Incorrect hash on output for Python implementation. :("
    $failed += "$directory\FizzBuzz.Python.txt"
}


Set-Location $directory

Write-Host ""
Write-Host "Results"

if ($failed.Length -gt 0) {
    Write-Host $failed.Length "Failed:"
    $failed | ForEach-Object -Process {
        Write-Host $_.ToString()
    }
} else {
    Write-Host "All Passed."
}
