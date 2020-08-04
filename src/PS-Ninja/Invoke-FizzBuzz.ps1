#  FizzBuzz Implementation in PowerShell
#  The Sharp Ninja - August 3, 2020
#
#  "Write a program that prints the numbers from 1 to 100. But for multiples of three print 
#  “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which 
#  are multiples of both three and five print “FizzBuzz”."

1..100 | ForEach-Object -Process {
    [string]$result = $null;

    if ($_ % 3 -eq 0) { $result += "Fizz"; }
    if ($_ % 5 -eq 0) { $result += "Buzz"; }
    if (!$result) { $result = $_; }
    
    $result;
}
