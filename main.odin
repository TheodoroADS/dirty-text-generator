package main 

import "core:fmt"
import "core:os"

DEBUG :: false

main :: proc(){

    data, ok := read_dataset("processed.txt")

    if !ok {
        fmt.println("Could not open file!")
        return
    }

    markov := make(Markov)


    markov_train(&markov, data)

    out , _ := os.open("jooj.txt", os.O_CREATE) 
    defer os.close(out)

    when DEBUG {

        fmt.println("jooj" , len(markov))
    
        for key , value in markov{
    
            // fmt.println("cock")
    
            fmt.fprintf(out, "(")
            
            for word in key {
                
                fmt.fprintf(out, " %s,", word)
            } 
            
            fmt.fprintf(out, ") %v \n", value)
    
        }
    }

    hohoho , yay := markov_generate_text(&markov, State{"my", "mouth"}, 20 , sample_most_likely)
    
    if !yay{
        fmt.println("Oh no")
        os.exit(1)
    }

    fmt.println(hohoho)

}   
