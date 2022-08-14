package main

import "core:fmt"
import "core:os"
import "core:math/rand"
import "core:strings"
import "core:runtime"

Dataset :: [dynamic]string

NGRAM_SIZE :: 2

State :: [NGRAM_SIZE]string 

Frequencies :: map[State]f64

Markov :: map[State]Frequencies

BUFF_SIZE :: 200

is_blank :: proc(r : rune) -> bool {

    return r == ' ' || r == '\n' || r == '\t' || r == '\r' || r == '\f'

}

read_dataset :: proc(filename : string) -> (Dataset , bool) {

    bytes, ok := os.read_entire_file(filename)

    if !ok {
        return nil, false
    }

    text := string(bytes)

    dataset : Dataset

    state : enum u8 {reading_white, reading_word} = .reading_white

    begin := 0

    for c , rune_num in text{

        switch state {

        case .reading_white:
            
            if !is_blank(c) {

                state = .reading_word
                begin = rune_num
            }
            
        case .reading_word:
            
            if is_blank(c) {

                append(&dataset, string(text[begin:rune_num]))
                state = .reading_white
            }
        
        }

    }

    if state == .reading_word {

        append(&dataset, string(text[begin:len(text)]))

    }

    return dataset, true
}


frequency_len :: proc(freqs : ^Frequencies) -> int{

    result := 0

    for _ , val in freqs^ {
        result += int(val)
    }

    return result
}


markov_train :: proc(markov : ^Markov, dataset : Dataset){

    current_words , next_words : State

    for i:= 0; i < len(dataset) - NGRAM_SIZE - 3; i += 1 {


        for j in 0..<NGRAM_SIZE {
            current_words[j] = dataset[i + j]
            next_words[j] = dataset[NGRAM_SIZE + i + j]
        }

        if current_words in markov {

            if next_words in markov[current_words]{

                // fmt.println("hehehe")
                
                freq := markov[current_words]
                freq[next_words] += 1
                markov[current_words] = freq
                
            }else{
                
                // fmt.println("hahaha")
                freq := markov[current_words]
                freq[next_words] = 1
                markov[current_words] = freq
                // fmt.println("eita porra ", markov[current_words])
                
            }
            
        }else{
            
            freq := make(Frequencies)
            freq[next_words] = 1
            markov[current_words] = freq
            
        }
        

    }


    for _ , node in markov{

        total_size := frequency_len(&node)

        for state , _ in node{

            node[state] =  node[state] / f64(total_size)

        }

    }


}



sample_most_likely :: proc(freqs : Frequencies) -> State{
    
    most_likely : State
    biggest_prob: f64 = 0.0

    for state , next in freqs{

        if next > biggest_prob {
            biggest_prob = next 
            most_likely = state
        } 

    }

    return most_likely
} 

theodoro_sample :: proc(freqs : Frequencies) -> State {

    for {

        dice := rand.float64_range(0 , 1)

        for state , prob in freqs {

            if dice < prob {
                return state
            }

        }

    }

}

markov_generate_text :: proc(markov : ^Markov ,
    initial_state : State,
    nb_ngrams : int,
    sampling_method : proc(freqs : Frequencies) -> State) -> (text : string, ok:  bool)
    {

    words := make([]string, nb_ngrams * NGRAM_SIZE)
    defer delete(words)

    current_state := initial_state

    concatenator : [2]string

    for word , idx in initial_state{
        concatenator[0] = word
        concatenator[1] = " "
        res , err := strings.concatenate_safe(concatenator[:])

        if err != nil {
            fmt.eprintln(err)
            ok = false
            return 
        }

        words[idx] = res
    }


    idx := NGRAM_SIZE

    for idx < nb_ngrams {

        current_state = sampling_method(markov[current_state])

        for word in current_state{  
            concatenator[0] = word
            concatenator[1] = " "
            res , err := strings.concatenate_safe(concatenator[:])
            
            if err != nil {
                fmt.eprintln(err)    
                ok = false
                return 
            }
       
            words[idx] = res
            idx += 1
        }

    }

    err : runtime.Allocator_Error

    text, err  = strings.concatenate_safe(words)

    if err != nil {
        fmt.println(err)

        return "", false

    }

    ok = true

    return
}


