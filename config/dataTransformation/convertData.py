import csv
from rdflib import Graph, URIRef, Literal, Namespace
from rdflib.namespace import SDO, RDF
import pandas as pd
import requests
import json


df = pd.read_csv("doc/aanduidingsobjecten.csv")


# Define the namespaces
generiek = Namespace("https://data.vlaanderen.be/ns/generiek#")
objecten = Namespace("https://inventaris.onroerenderfgoed.be/aanduidingsobjecten/")
locn = Namespace("http://www.w3.org/ns/locn#")
adres = Namespace("https://data.vlaanderen.be/ns/adres#")
oe = Namespace("https://id.erfgoed.net/vocab/ontology#")


# Initialize the graph
g = Graph()

g.bind("generiek", generiek)
g.bind("objecten", objecten)
g.bind("locn", locn)
g.bind("adres", adres)
g.bind("oe", oe)
g.bind("SDO", SDO)

for index, row in df.iterrows():
    # Create a unique IRI for each row based on the 'id' column
    subject = URIRef(objecten + str(row['id']))
    # Add the triples
    predicate = generiek.lokaleIdentificator
    g.add((subject, RDF.type, oe.Aanduidingsobject))
    g.add((subject, predicate, Literal(row['id'])))    
    g.add((subject, SDO.name, Literal(row['naam'])))
    g.add((subject, locn.fullAddress, Literal(row['locatie'])))
    g.add((subject, adres.Gemeentenaam, Literal(row['gemeente'])))
    g.add((subject, locn.adminUnitL2, Literal(row['provincie'])))
    g.add((subject, SDO.keywords, Literal(row['typologie'])))
        
# Serialize the graph to Turtle format and save it
output_file = 'output.ttl'
g.serialize(destination=output_file, format="turtle")

print(f"RDF data has been written to {output_file}")







# def fetch_straatnaam(aanduidingsobject_id):
    
#     base_url = "https://inventaris.onroerenderfgoed.be/aanduidingsobjecten/"
#     url = f"{base_url}{aanduidingsobject_id}"
#     # print(url)
#     # # Make the GET request to the API
#     # response = requests.get(url)
#     # print(response)
#     # # Check if the request was successful
#     # if response.status_code == 200:
#     #     # data = response.json()  # Parse JSON response
        
#     #     json_response = json.loads(response.text)
#     #     # Assuming 'straat_naam' is part of the response
#     #     if 'straat_naam' in data:
#     #         return data['straat_naam']
#     #     else:
#     #         return "straat_naam not found in the response"
#     # else:
#     #     return f"Error: Received status code {response.status_code}"
    
#     # Define the JSON payload
#     json_payload = {
#         "prettyPrint": True,
#     }

#     # Perform the API request using the requests library
#     headers = {"Content-Type": "application/json"}
#     response = requests.get(url, headers=headers)
#     print(response)

