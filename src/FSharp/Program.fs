(*
* FizzBuzz Implementation in F#
* Sergio0694 - October 20, 2019
*
* "Write a program that prints the numbers from 1 to 100. But for multiples of three print
* “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which
* are multiples of both three and five print “FizzBuzz”."
*)


let fizbuzz =
    let rec f (i:int) : unit =
        match i with
        | 101 -> ()
        | _ ->
            match i with
            | _ when i % 3 = 0 && i % 5 = 0 -> printfn "FizzBuzz"
            | _ when i % 3 = 0 -> printfn "Fizz"
            | _ when i % 5 = 0 -> printfn "Buzz"
            | _ -> printfn "%i" i
            f (i + 1)
    f 1

[<EntryPoint>]
let main argv =
    fizbuzz |> ignore
    0
