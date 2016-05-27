#!/bin/bash

#A =(<)
#31050_S1_L001.vcf

sed  '/chr7_/d' $1  > filtro.vcf
wc -l filtro.vcf  
sed -i '/chr1_g/d' filtro.vcf  |  wc -l filtro.vcf	
sed -i '/chrUn_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr4_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr6_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr8_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr9_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr11_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr17_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr18_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr19_/d' filtro.vcf |  wc -l filtro.vcf
sed -i '/chr21_/d' filtro.vcf  | wc -l filtro.vcf 
sed -i '/^chrM/d' filtro.vcf  
wc -l filtro.vcf  

java -jar GenomeAnalysisTK.jar  -T SelectVariants -R reference.fa -V filtro.vcf -select "QUAL > 1000.0" -o HC.qual500.filtered.vcf 

java -jar GenomeAnalysisTK.jar \ -T SelectVariants \ -R reference.fa \ -V HC.qual500.filtered.vcf \-selectType SNP \ -o raw_snp.vcf 

java -jar GenomeAnalysisTK.jar \ -T SelectVariants \ -R reference.fa \ -V HC.qual500.filtered.vcf \-selectType INDEL \ -o raw_indels.vcf
 
java -jar GenomeAnalysisTK.jar -T VariantFiltration -R reference.fa -V raw_snp.vcf --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filterName "my_snp_filter" -o filtered_snps.vcf 

java -jar GenomeAnalysisTK.jar -T VariantFiltration -R reference.fa -V raw_indels.vcf  --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filterName "my_indel_filter" -o filtered_indels.vcf 

# --excludeNonVariants \ --excludeFiltered 
# Concatenar

java -jar GenomeAnalysisTK.jar \
    -T CombineVariants \
    -R reference.fa \
    --variant filtered_snps.vcf \
    --variant filtered_indels.vcf \
    -o output.vcf \
    -genotypeMergeOptions UNIQUIFY

#Metricas de comparación de vcf
#java -jar GenomeAnalysisTK.jar \
#    -R referencia.fa \
#    -T CombineVariants \
#    -V:FOO 31050_S1.vcf \
#    -V:BAR output.vcf \
#    -priority FOO,BAR \
#    -o merged.vcf
#ftp://ftp.broadinstitute.org/bundle/2.8/hg19/

#java -jar GenomeAnalysisTK.jar \
#     -T VariantEval \
#     -R referencia.fa \
#    -D dbsnp.vcf \
#     -select 'set=="Intersection"' -selectName Intersection \
#     -select 'set=="FOO"' -selectName FOO \
#     -select 'set=="FOO-filterInBAR"' -selectName InFOO-FilteredInBAR \
#     -select 'set=="BAR"' -selectName BAR \
#     -select 'set=="filterInFOO-BAR"' -selectName InBAR-FilteredInFOO \
#     -select 'set=="FilteredInAll"' -selectName FilteredInAll \
#     -o merged.eval.gatkreport \
#     -eval merged.vcf \
#    -l INFO

bgzip output.vcf

tabix -f output.vcf.gz
tabix -f 31050_S1.vcf.gz 

vcf-compare  output.vcf.gz 31050_S1.vcf.gz  > comparacion2.txt

vcftools --vcf NA12878_2.vcf --bed ConfidentRegions.bed --out salida --recode --keep-INFO-all

