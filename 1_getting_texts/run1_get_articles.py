from elsapy.elsclient import ElsClient
from elsapy.elsprofile import ElsAuthor, ElsAffil
from elsapy.elsdoc import FullDoc, AbsDoc
from elsapy.elssearch import ElsSearch
import json

## Load configuration
con_file = open("config.json")
config = json.load(con_file)
con_file.close()

## Initialize client
client = ElsClient(config['apikey'])
client.inst_token = config['insttoken']


## Initialize doc search object using Scopus and execute search, retrieving 
#   all results
doc_srch = ElsSearch("ISSN(0047-2484)",'scopus')
doc_srch.execute(client, get_all = True)
print ("doc_srch has", len(doc_srch.results), "results.")
#print(doc_srch.results)
doc_srch.results_df.to_csv(r'articles_JHE.csv', index = False)
