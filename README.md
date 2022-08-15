# Markov Chain for generating dirty text implemented in Odin

## Quick Start 

Inside the project diretory, run:

``` bash
odin run .
```

To specify the initial ngrams of the program, build the project and run it with the words as arguments

``` bash 
odin build .
markov.exe [word1] [word2] ...
```
Change the size of the NGRAM by modifying the NGRAM_SIZE constant in markov.odin

Make sure you have [Odin](https://odin-lang.org/) installed!

*OBS* : if you want to reuse the Python script for processing the text, make sure you have Spacy installed and run it as 

``` bash 
python3 preprocessor.py [input file]
```

## About 

This is a simplified implementation of a Markov Chain text generator implemented in Odin. I have done the text preprocessing with Python + Spacy. This project is made possible by the dataset provided by [mathigatti](https://github.com/mathigatti) [here](https://github.com/mathigatti/sexting-dataset/blob/master/sexting_dataset.txt)! Special thanks to him! 

If you're asking yourself the reason for this project existing, it's just that I have a very childish mind and I find that very funny hihihi
