#!/bin/sh


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

genoma_ref=/hpcfs/home/ciencias/biologia/cursos/bcom4103/j.velez248/omics/WholeGenomeFasta/genome.fa
nueva_carpeta=/hpcfs/home/ciencias/biologia/cursos/bcom4103/j.velez248/

module load gatk/3.5

java -jar `which GenomeAnalysisTK.jar` \ -T SelectVariants -R $genoma_ref -V filtro.vcf -select "QUAL > 1000.0" -o HC.qual500.filtered.vcf 

java -jar `which GenomeAnalysisTK.jar` \ -T SelectVariants \ -R $genoma_ref \ -V HC.qual500.filtered.vcf \-selectType SNP \ -o raw_snp.vcf 

java -jar `which GenomeAnalysisTK.jar` \ -T SelectVariants \ -R $genoma_ref \ -V HC.qual500.filtered.vcf \-selectType INDEL \ -o raw_indels.vcf
 
java -jar `which GenomeAnalysisTK.jar` -T VariantFiltration -R $genoma_ref -V raw_snp.vcf --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filterName "my_snp_filter" -o filtered_snps.vcf 

java -jar `which GenomeAnalysisTK.jar` -T VariantFiltration -R $genoma_ref -V raw_indels.vcf  --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filterName "my_indel_filter" -o filtered_indels.vcf 

# --excludeNonVariants \ --excludeFiltered 
# Concatenar

java -jar `which GenomeAnalysisTK.jar` \
    -T CombineVariants \
    -R $genoma_ref \
    --variant filtered_snps.vcf \
    --variant filtered_indels.vcf \
    -o $1_filtrado.vcf \
    -genotypeMergeOptions UNIQUIFY

