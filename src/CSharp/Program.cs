/*
* FizzBuzz Implementation in C#
* The Sharp Ninja - October 20, 2019
*
* "Write a program that prints the numbers from 1 to 100. But for multiples of three print
* “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which
* are multiples of both three and five print “FizzBuzz”."
*/
using System;

namespace FizzBuzz
{
    class Program
    {
        static void Main(string[] _)
        {
            for (int i = 1; i <= 100; ++i)
            {
                Console.WriteLine($@"{(
                    i % 3 == 0
                        ? i % 5 == 0
                            ? "FizzBuzz"
                            : "Fizz"
                        : i % 5 == 0
                            ? "Buzz"
                            : $"{i}"
                )}");
            }
        }
    }
}
