package main

import "core:fmt"
import "core:os"
import "core:math/rand"

Dataset :: [dynamic]string

NGRAM_SIZE :: 2

State :: [NGRAM_SIZE]string 

Frequencies :: map[State]f64

Markov :: map[State]Frequencies

BUFF_SIZE :: 200

is_white :: proc(r : rune) -> bool {

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
            
            if !is_white(c) {

                state = .reading_word
                begin = rune_num
           //     fmt.printf("white -> word |%c| \n", c)
            }
            
        case .reading_word:
            
            if is_white(c) {

                append(&dataset, string(text[begin:rune_num]))
                state = .reading_white
              //  fmt.printf("word -> white |%c| \n", c)
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

    current_words , next_words :State

    // defer delete(&current_words)

    fmt.println("begin training")

    for i:= 0; i < len(dataset) - NGRAM_SIZE - 1 ; i += 1 {

        // fmt.println("Iteration :", i )

        for j in 0..<NGRAM_SIZE {
            current_words[j] = dataset[i + j]
            next_words[j] = dataset[NGRAM_SIZE + i + j]
        }

        // fmt.println(current_words)

        if current_words in markov {


            // fmt.println(dataset[i + NGRAM_SIZE])

            // fmt.println(markov[current_words])


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


markov_generate_text :: proc(markov : ^Markov ,
    initial_state : State,
    nb_ngrams : int,
    sampling_method : proc(freqs : Frequencies) -> State) -> (text : string, ok:  bool)
    {

    text = "cock"

    current_state := initial_state

    for word in initial_state{
        // text += word + " "
        fmt.print(word, " ")
    }

    for _ in 0..<nb_ngrams {

        current_state = sampling_method(markov[current_state])

        for word in current_state{
            // text += word + " "
            fmt.print(word, " ")
        }

    }

    ok = true

    return
}


