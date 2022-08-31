package main 

import "core:fmt"
import "core:os"

DEBUG :: false

main :: proc(){

    if len(os.args) != 1  && len(os.args) != NGRAM_SIZE + 1{

        fmt.eprintln("This program takes", NGRAM_SIZE, "words as input. Please input that amount of arguments or none")
        return
    }

    data, ok := read_dataset("processed.txt")
    defer delete(data)

    if !ok {
        fmt.eprintln("Could not open file!")
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

    initial_state : State

    if len(os.args) == NGRAM_SIZE + 1 {


        for i in 0..<NGRAM_SIZE{
            initial_state[i] = os.args[i + 1] 
        }

        if !(initial_state in markov){
            fmt.eprintln("Sorry, I've never seen those words used together :( Please try with others")
            return
        }
    }else{
        initial_state = markov_sample_initial_state(&markov)
    }

    hohoho , yay := markov_generate_text(&markov, initial_state , 40 , python_sample)
    
    if !yay{
        fmt.println("Oh no")
        return
    }

    fmt.println(hohoho)

}   
