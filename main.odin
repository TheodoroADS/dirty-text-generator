package main 

import "core:fmt"
import "core:os"

DEBUG :: false

N_SAYINGS :: 4


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

    markov_he := make(Markov)
    defer delete(markov_he)

    markov_she := make(Markov)
    defer delete(markov_she)

    markov_train(&markov_he, data)
    markov_train(&markov_she, data)

    
    when DEBUG {
        out , _ := os.open("jooj.txt", os.O_CREATE) 
        defer os.close(out)
        
        fmt.println("jooj" , len(markov_he))
    
        for key , value in markov_he{
    
    
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

        if !(initial_state in markov_he){
            fmt.eprintln("Sorry, I've never seen those words used together :( Please try with others")
            return
        }
    }else{
        initial_state = markov_sample_initial_state(&markov_he)
    }

    fmt.println("He : ")
    
    he_text , he_yay := markov_generate_text(&markov_he, initial_state , 40 , jooj_sample)


    if !he_yay{
        fmt.println("He died")
        return
    }

    fmt.println(he_text)

    fmt.println()

    fmt.println("She : ")

    she_text , she_yay := markov_generate_text(&markov_she, initial_state , 40 , jooj_sample)
    
        if !she_yay{
            fmt.println("She died")
            return
        }
        
    fmt.println(she_text)


}   
