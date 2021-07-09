# The FizzBuzz Test Collection

The "Fizz-Buzz test" is an interview question designed to help filter out the 99.5% of programming job candidates who can't seem to program their way out of a wet paper bag. The text of the programming assignment is as follows: 

> "Write a program that prints the numbers from 1 to 100. But for multiples of three print "Fizz" instead of the number and for the multiples of five print "Buzz". For numbers which are multiples of both three and five print "FizzBuzz"." - [FizzBuzz Test](http://wiki.c2.com/?FizzBuzzTest)

## Solutions

* [ARMHF ASM](src/ASM/armhf)
* [x64 ASM](src/ASM/x64)
* [x86 ASM](src/ASM/x86)
* [C](src/C)
* [C++](src/C++)
* [C#](src/CSharp)
* [C# w/Compiled Expression Trees](src/CSharpExpressions)
* [C# w/IL](src/CSharpIL)
* [F#](src/FSharp)
* [Homespring](src/Homespring)
* [Java](src/Java)
* [JavaScript](src/JavaScript)
* [Pattern-Lang](src/Pattern-Lang) <sup>1</sup>
* [PowerShell](src/PowerShell)
* [PowerShell-Ninja](src/PS-Ninja)
* [Python 3](src/Python)
* [Ruby](src/Ruby)
* [Visual Basic](src/VisualBasic)

## Submit Your Solution!

Create a Pull Request with your solution.  Be sure to specify the following in your PR:

* Language
* Compiler/SDK Required to Build    
  * Include the _specific OS and repository_ to obtain the Compiler/SDK from.  **Linux** or **Windows** accepted.
* Script to Perform the Build

Be practical or creative, but limit your solution to a **single source file**, please.

## NEW

There are now manifest files you can include in your submission so that your FizzBuzz solution will be run from the main script.

### test.json For Compiled Solutions

```json
{
    "$schema": "../test_schema.json",
    "location": "/src/C",
    "nameShort": "C",
    "nameLong": "C",
    "buildCommand": "wsl",
    "buildCommandParameters": "./linux_build.sh",
    "buildCommandParametersArray": [ ],
    "executeCommand": "wsl",
    "executeCommandParameters": "",
    "executeCommandParameters": [ "./bin/linux/fizzbuzz" ],
    "preBuild": ""
}
```

###### Parameters can be passed as a single string, an array of strings, or both simultaneously.

#### test.json Fields

* __location__ - Relative path from the root of the project to the working directory of your solution.
* __nameShort__ - A (very) short name for your solution with no spaces.
* __nameLong__ - A descriptive name for your solution, which may have spaces.
* __buildCommand__ - The command to execute in the shell to build your solution.
* __buildCommandParameters__ - The parameters to pass to your __buildCommand__.
* __executeCommand__ - The command to execute in the shell to run your solution.
* __executeCommandParameters__ - The parameters to pass to your __executeCommand__.
* __preBuild__ - A command to execute before building your solution.

Place this file in the _first_ child directory of `/src` in your solution.

### test_nobuild.json For Scripted Solutions

```json
{
    "$schema": "../test_schema.json",
    "location": "/src/Ruby",
    "nameShort": "Ruby",
    "nameLong": "Ruby",
    "command": "wsl",
    "commandParmaters": "",
    "commandParametersArray": ["ruby", "./fizz_buzz.rb"],
    "preExecute": ""
}
```

###### Parameters can be passed as a single string, an array of strings, or both simultaneously.

#### test_nobuild.json Fields

* __location__ - Relative path from the root of the project to the working directory of your solution.
* __nameShort__ - A (very) short name for your solution with no spaces.
* __nameLong__ - A descriptive name for your solution, which may have spaces.
* __command__ - The command to execute in the shell to run your solution.
* __commandParameters__ - The parameters to pass to your __executeCommand__.
* __preExecute__ - A command to execute before running your solution.

Place this file in the _first_ child directory of `/src` in your solution.

---

<sup>1</sup> - Pattern-Lang is still concept only/
