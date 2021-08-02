import json
import os
import re
import pandas as pd

import nltk
#nltk.download('punkt')

import string
from nltk.tokenize import TweetTokenizer
from nltk.stem import WordNetLemmatizer

filewords = ['size','study','analysis','sample','ref','fig','table','also','may','multimediatype','result','figure','pattern','difference']

def clean_text(tt):
    # remove numbers
    text_nonum = re.sub(r'\d+', '', tt)
    # remove punctuations and convert characters to lower case
    text_nopunct = "".join([char.lower() for char in text_nonum if char not in string.punctuation])
    # substitute multiple whitespace with single whitespace
    # Also, removes leading and trailing whitespaces
    text_no_doublespace = re.sub('\s+', ' ', text_nopunct).strip()
    return text_no_doublespace
    

meta_data = pd.read_csv("articles_JHE_added_pages.csv")
#print(type(meta_data))
meta_data = meta_data[['eid','prism:doi', 'pii', 'dc:title',
    'prism:coverDate','prism:volume', 'prism:pageRange',
    'dc:creator', 'citedby-count',
    'article-number', 'source-id','pubmed-id','dc:identifier']]


dr_now = os.getcwd()
dr_all = os.path.join(dr_now,'data')

arr = os.listdir(dr_all)
#print(arr)
#print(len(arr))

i = 0

#print(meta_data.columns)

for name_now in arr:
    if  name_now.endswith('.json'):
        name_now_now = os.path.join(dr_all,name_now)
        f = open(name_now_now)
        data = json.load(f)
        f.close()

        one_text = json.dumps(data)
        print(type(one_text))
        #print(one_text)
        
        id = re.split('\s+', one_text)[1]
        id = id.replace('"', "")
        id = id.replace(',', "")
        #print(id)
        #print(type(id))
        
        row_now = meta_data.loc[meta_data['eid'] == id]
        #print(row_now.size)
        #print(meta_data['eid'][3897])
        #print(meta_data['eid'][3897] == id)
        #print(type(row_now))
        pp = str(row_now['prism:pageRange'])
        
        cleaned_text = clean_text(one_text)
        #print(cleaned_text)
        tt = TweetTokenizer()
        tok_text = tt.tokenize(cleaned_text)
        print(type(tok_text))
        stopwords = nltk.corpus.stopwords.words('english')
        med_word_text = [word for word in tok_text if word.lower() not in stopwords and not in filewords and len(word)>2 and len(word)<20]
        lemmatizer = WordNetLemmatizer()
        lem_word_text = [lemmatizer.lemmatize(word) for word in med_word_text]
        
        final_text = ' '.join(map(str, lem_word_text))
        #final_text = tok_text
        print(type(final_text))
        
        if "-" in pp:
            row_now['text'] = final_text
            if i==0:
                print('i =', i)
                new_data = row_now
                print(type(new_data))
                i = i + 1
            else:
                print('i =', i)
                #print(row_now.columns)
                #print(new_data.columns)
                #new_data.loc[len(new_data)] = row_now
                frames = [new_data, row_now]
                new_data = pd.concat(frames)
                i = i + 1
        else:
            print(pp)
            

#print(new_data)
            
new_data.to_csv (r'corpus_JHE.csv', index = False, header=True)
print(i)

