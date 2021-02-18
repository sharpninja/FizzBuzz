/*
* FizzBuzz Implementation in C# with dynamic IL
* Sergio0694 - October 20, 2019
*
* "Write a program that prints the numbers from 1 to 100. But for multiples of three print
* “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which
* are multiples of both three and five print “FizzBuzz”."
*/

#nullable enable

using System.Linq;
using System;
using System.Reflection;
using System.Reflection.Emit;

namespace CSharpExpressions
{
    class Program
    {
        static void Main()
        {
            // Console.WriteLine method info
            MethodInfo writeLine = (
                from methodInfo in typeof(Console).GetMethods(BindingFlags.Public | BindingFlags.Static)
                where methodInfo.Name == nameof(Console.WriteLine)
                let args = methodInfo.GetParameters()
                where args.Length == 1 &&
                      args[0].ParameterType == typeof(object)
                select methodInfo).First();

            // Build the dynamic method
            DynamicMethod method = new DynamicMethod("FizzBuzz", typeof(void), Type.EmptyTypes, typeof(Program));
            ILGenerator il = method.GetILGenerator();
            Label
                loop = il.DefineLabel(),
                plusplus = il.DefineLabel(),
                check = il.DefineLabel(),
                notFizz = il.DefineLabel(),
                notFizzBuzz = il.DefineLabel(),
                notBuzz = il.DefineLabel();
            il.DeclareLocal(typeof(int));
            il.Emit(OpCodes.Ldc_I4_1);
            il.Emit(OpCodes.Stloc_0);
            il.Emit(OpCodes.Br_S, check);
            il.MarkLabel(loop);
            il.Emit(OpCodes.Ldloc_0);
            il.Emit(OpCodes.Ldc_I4_3);
            il.Emit(OpCodes.Rem);
            il.Emit(OpCodes.Brtrue, notFizz);
            il.Emit(OpCodes.Ldloc_0);
            il.Emit(OpCodes.Ldc_I4_5);
            il.Emit(OpCodes.Rem);
            il.Emit(OpCodes.Brtrue_S, notFizzBuzz);
            il.Emit(OpCodes.Ldstr, "FizzBuzz");
            il.EmitCall(OpCodes.Call, writeLine, null);
            il.Emit(OpCodes.Br_S, plusplus);
            il.MarkLabel(notFizzBuzz);
            il.Emit(OpCodes.Ldstr, "Fizz");
            il.EmitCall(OpCodes.Call, writeLine, null);
            il.Emit(OpCodes.Br_S, plusplus);
            il.MarkLabel(notFizz);
            il.Emit(OpCodes.Ldloc_0);
            il.Emit(OpCodes.Ldc_I4_5);
            il.Emit(OpCodes.Rem);
            il.Emit(OpCodes.Brtrue_S, notBuzz);
            il.Emit(OpCodes.Ldstr, "Buzz");
            il.EmitCall(OpCodes.Call, writeLine, null);
            il.Emit(OpCodes.Br_S, plusplus);
            il.MarkLabel(notBuzz);
            il.Emit(OpCodes.Ldloc_0);
            il.Emit(OpCodes.Box, typeof(int));
            il.EmitCall(OpCodes.Call, writeLine, null);
            il.MarkLabel(plusplus);
            il.Emit(OpCodes.Ldloc_0);
            il.Emit(OpCodes.Ldc_I4_1);
            il.Emit(OpCodes.Add);
            il.Emit(OpCodes.Stloc_0);
            il.MarkLabel(check);
            il.Emit(OpCodes.Ldloc_0);
            il.Emit(OpCodes.Ldc_I4_S, (byte)100);
            il.Emit(OpCodes.Ble_S, loop);
            il.Emit(OpCodes.Ret);

            // Invoke the delegate
            ((Action)method.CreateDelegate(typeof(Action)))();
        }
    }
}
