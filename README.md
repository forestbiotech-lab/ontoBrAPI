# Welcome to OntoBrAPI
![OntoBrAPI logo](https://github.com/forestbiotech-lab/ontoBrAPI-node-docker/blob/master/public/images/logo.png)

OntoBrAPI runs a web server, which provides a Graphical User Interface (GUI) that allows the conversion of the MIAPPE spreadsheet into n-triples format. The GUI allows the user to dynamically map the MIAPPE spreadsheet to the appropriate PPEO ontological properties using a JavaScript Object Notation (JSON). The user can also start from an initial mapping in JSON and adjust any fields deemed necessary. The GUI uses the constraints coded in the ontology to validate the mapping. As an example, the data types allowed for each of the data properties is enforced by the GUI, which are inherited from the rules in the ontology; the same goes for the object properties that can link classes and the data properties that can annotate classes.

# Setup

## NGINX
add the following line to location section of your server in nginx config file. To allow body size to be larger. This is for the ajax request to send mapping and jsheet

```bash
client_max_body_size 2M;
````
# ontoBrAPI-node-docker
Docker file for the webserver running on Node JS

## Build image
``` bash
	docker build -t brunocosta/ontobrapi-node .
	#docker build -t <your username>/ontobrapi-node .
```

## Run image

``` bash
	# See images
	docker images
	
	# Get container ID
	docker ps

	# Print app output
	 docker logs <container id>
	
	# Enter the container
	docker exec -it <container id> /bin/bash

	docker run -p 49160:3000 -d brunocosta/ontobrapi-node
	docker run -p 49160:3000 -d <your username>/ontobrapi-node
``` 

## Connecting to the SPARQL endpoint mas be done through the service name

In this case db should be used instead of localhost to refer to network on another container




**Notes**

``` sql

PREFIX miappe: <http://purl.org/ppeo/PPEO.owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdf: <http://www.w3.org/2000/01/rdf-schema#> 

INSERT INTO GRAPH miappe:{
   miappe:N353 a miappe:study . 
   miappe:hasIdentifier rdf:subClassOf miappe:N353 .
   miappe:hasIdentifier xsd:string  "353" .
   miappe:obs_unit_1 a miappe:observation_unit .   
   miappe:obs_unit_1 miappe:partOf miappe:N353 .
   miappe:hasIdentifier rdf:subClassOf miappe:obs_unit_1 .
   miappe:hasInternalIdentifier rdf:subClassOf miappe:hasIdentifier .
   miappe:hasInternalIdentifier xsd:string "1" .
}


miappe:hasIdentifier rdf:subClassOf miappe:N353 
Isto já definido implicitamente? Preciso de definir esta relação?

miappe:N353 a miappe:study . 
Estou a instanciar uma classe study? Que nomenclatura devo usar para definir este elemento.

Estou a ver estes triplos como graphs. 
?c   ?r ?i
?s (Um elemento (vertice)) ?p (que estabelece uma relação (edge)) ?o (com outro elemento (vertice))

```

## debug NT generation
```bash
DEBUG=l1 npm start
```

## Instancing the PPEO ontology
Each spreadsheet must have a class to add the data properties
Generally the columns are considered to have data properties for a Class. The class should appear in other spreadsheets in order to connect. I.E In the investigation spreadsheet there is a general description of the investigation, while in the study spreadsheet that isn't a fine detail of the investigtion, rather it is only a support to connect the study to the investigation.  

To change the URI of the instanced classes generated got to `componentes/generators/nt.js` and modify the prefix that match the name given to the initiation of the Triples class.

#### Use case

 * Upload file
 * Define order of processing

 * Define prefixes, and the name of the ontology being generated, and the base ontology to be imported.
 * Define the observation Levels, and other dependent individuals that are not implicitly in the spreadsheet
 * Define the observation Variables

 * Set the mappings
 * Define the object properties 
 * Create necessary class to link to each object property 
 * Link data proerties to appropriate class
 * Define the data properties

 * Use #{} to refer to another node use @{} to get the inline value of the particular column.
 * "observation", "environment_parameter", and "observation_unit" types are processed as dependents and an can user @{auto_increment} as the subject name. These triples are only created when going through the sheet lines. 

### Algorithm overview

  1- Identify each column 
  2- Parse all lines into memory with headers for mapping
  3- Create individuals for all distinct elements in columns that are classes, if class references another column a new class will be created for each row.
  4- [Deprecated] Create Dependent individuals and/or dataProperties and objectProperties for each line if the column has associated properties. 
  5- Adds Object Properties for each class
  6- Add data properties for each clas
  6- Generate file/JSON with triples

### Mapping

JSON object with keys for each sheet, (corresponding names), each sheet has a JSON object with a key for each column (corresponding names), each column has a JSON object with a set of the following keys, _name_  _type_ _name_scheme_ and properties

``` JSON
let mapping={
  "Sheet1":{
    "Column1":{
      "type":"class",
      "name":"study",
      "naming_scheme":"xxxx_@{value}",
      "properties":{
        "ObjectProperties":[
          {"hasProperty1":"#{column1}"},
          {"hasLocation":{"value":""}},
        ],
        "DataProperties":[
          {"hasObservationUnitDescription":{"value":"Some literal description in english for example","type":"@en"}},    
          {"hasStartDateTime":{"value":"@{date}","type":"xsd:dateTime"}},   //Minimum of the dates? || Manually entry
        ]    
      }
    },
    "Column2":{
      "type":"dataProperty",
      "name":"hasDateTime",
      "naming_scheme":"@{value}"
    },(...)
  },
  "Sheet2":{(...)}

```

The mapping should be generated by the GUI in the browser.

* type:["class",".*"] //The only imporatant type for now is class any other is disconsidered
* name: The observation of the type of the named nome Ex: <thing:[name_scheme]> <thing:type> <thing:name>
* nameing_scheme: The name of the triple subject of the individual. Accepts, @{value} or other values if the individual is set as a dependent, because the firt generated individual don't have the context other then their value.  

### Global graph
The global graph maps all classes created and associated data properties connecting them.

### Parsing files
localhost:3001 from docker-compose 

Upload file, *.tsv* for now.  

https://github.com/mgcrea/node-xlsx#readme

or

https://github.com/SheetJS/sheetjs  (See what the above adds)

###### Development

- /forms/parse/file downlaods a file. The file will not have the appropriate namespace of the destination. 
- /forms/parse/file/json  This is the json version. 
The JSON comes with the observation of data properties already transformed, with datatype validation for Boolean, integer and float.  


### Information tooltips
Adding tooltips requires a simple html element:
```jade
 information-tooltip(:info="info" label="nomeoftextmessage")
```
The label identifies the key in: components/datastructures/info.js



## Triple Store

Open virtuoso: Normally running on localhost:8890. Open the Linked Data tab. There you can list active graphs, manage them and upload new ones

#### Adding a new graph (.nt)
From the Linked Data tab go to Quad Store Upload. Select the file to upload, tick create graph explicitly and select the name used to store the new graph

#### Listing Graphs
In the Linked Data tab got to Graphs > Graphs. From here you can delete or rename any of the stored graphs

#### MongoDB
Run on docker
Todo integrate into docker-compose
https://hub.docker.com/_/mongo
```bash
	docker pull mongo:latest
	docker run -name mongo-ontobrapi -p 27010:27010 -d mongo:latest
	mongosh ## Access database
```


#### Adding Calls

Add the json file of the normal call.
Modify the call structure add the anchor. The anchor defines the starting class from which all calls are directed.
"_anchor": {
"class": "study",
"s": "?study",
"p": "rdf:type",
"o": "ppeo:study"
},



## TODO

Updating a dataproperty might not propagate in Class data properties


# Changing the base ontology
This action was not considered when the project was designed, however since 90% of the actions are implemented based on ontology properties and the options are derived from the base ontology changing the base ontology will only take a couple of actions  
 1) Change the base ontology in the Triples constructor `componentes/helpers/triples.js` 
 2) Provide the prefix to the base ontology in `componentes/generators/nt.js` *makeTriples* function 
 3) Change the "from" URI in the used `componentes/sparql/*.js` files that are used. Most are now set to require explictly the base ontolgy for queries 
