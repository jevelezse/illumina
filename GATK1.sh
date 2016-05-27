#!/bin/sh
 
#bwa index -a bwtsw reference.fa
#samtools faidx reference.fa 

java -jar /home/jennifer/Desktop/filtro/picard-tools-1.119/CreateSequenceDictionary.jar  REFERENCE=reference.fa  OUTPUT=reference.dict 

