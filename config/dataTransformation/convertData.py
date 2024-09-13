import csv
from rdflib import Graph, URIRef, Literal, Namespace
from rdflib.namespace import SDO, RDF
import pandas as pd
import requests
import json
from datetime import datetime

df = pd.read_csv("doc/aanduidingsobjecten.csv")


# Define the namespaces
generiek = Namespace("https://data.vlaanderen.be/ns/generiek#")
objecten = Namespace("https://inventaris.onroerenderfgoed.be/aanduidingsobjecten/")
locn = Namespace("http://www.w3.org/ns/locn#")
adres = Namespace("https://data.vlaanderen.be/ns/adres#")
oe = Namespace("https://id.erfgoed.net/vocab/ontology#")
crm = Namespace("http://www.cidoc-crm.org/cidoc-crm/")


# Initialize the graph
g = Graph()

g.bind("generiek", generiek)
g.bind("objecten", objecten)
g.bind("locn", locn)
g.bind("adres", adres)
g.bind("oe", oe)
g.bind("sdo", SDO)
g.bind("crm", crm)

for index, row in df.iterrows():
    # Create a unique IRI for each row based on the 'id' column
    subject = URIRef(objecten + str(row['id']))
    # Add the triples
    predicate = generiek.lokaleIdentificator
    g.add((subject, RDF.type, oe.Aanduidingsobject))
    
    if pd.notna(row.get('id')) and str(row['id']).strip():
        g.add((subject, predicate, Literal(row['id'])))    
        
    if pd.notna(row.get('naam')) and str(row['naam']).strip():
        g.add((subject, SDO.name, Literal(row['naam'])))
        
    if pd.notna(row.get('locatie')) and str(row['locatie']).strip():
        g.add((subject, locn.fullAddress, Literal(row['locatie'])))
        
    if pd.notna(row.get('gemeente')) and str(row['gemeente']).strip():
        g.add((subject, adres.Gemeentenaam, Literal(row['gemeente'])))
        
    if pd.notna(row.get('provincie')) and str(row['provincie']).strip():
        g.add((subject, locn.adminUnitL2, Literal(row['provincie'])))
    
    if pd.notna(row.get('typologie')) and str(row['typologie']).strip():
        g.add((subject, SDO.keywords, Literal(row['typologie'])))
        
        
    if pd.notna(row.get('materiaal')) and str(row['materiaal']).strip():
        g.add((subject, crm.P45_consists_of, Literal(row['materiaal'])))
    
        
# # Serialize the graph to Turtle format and save it
# output_file = 'output.ttl'

# Get the current timestamp and format it
timestamp = datetime.now().strftime("%Y%m%d%H%M%S")

# Use the timestamp in the output file name
output_file = f'{timestamp}_data.ttl'


g.serialize(destination=output_file, format="turtle")

print(f"RDF data has been written to {output_file}")
