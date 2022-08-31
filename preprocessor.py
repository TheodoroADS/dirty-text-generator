import spacy 
import sys


if len(sys.argv) != 2 :
    print(f'Usage : {sys.argv[0]} [input file]')
    exit(1)


with open(sys.argv[1], 'r' , encoding= "utf8") as input_file :

    nlp = spacy.load("en_core_web_sm")

    temp = ""

    data = input_file.readlines()

    for line in data:
        temp += line.lstrip("He:").lstrip("She:").lower() + " "

    data = temp 
    
    text = nlp(data)

    result = ""

    for token in text:
        if token.is_alpha: #or (token.is_punct and not token.text in ["(", ")" , ";", "”"]):
            result += " " + token.text


    with open("processed.txt", "w", encoding='utf8') as output_file:
        output_file.write(result)
        output_file.close()

    input_file.close()





