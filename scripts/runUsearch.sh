for eachS in `cat ./sample.list`
do
    echo $eachS
    mv ./rawdata/$eachS\_*R1_001.fastq.gz ./rawdata/$eachS\_R1.fastq.gz
    mv ./rawdata/$eachS\_*R2_001.fastq.gz ./rawdata/$eachS\_R2.fastq.gz
    gunzip ./rawdata/$eachS\_R1.fastq.gz ./rawdata/$eachS\_R2.fastq.gz
#    gzip ./rawdata/$eachS\_R1.fastq &
 #   gzip ./rawdata/$eachS\_R2.fastq &
done
wait

#rename reads
for READ1 in *_R1_001.fastq; do mv "$READ1" "${READ1/%_R1_001.fastq/_R1.fastq}"; done

for READ2 in *_R2_001.fastq; do mv "$READ2" "${READ2/%_R2_001.fastq/_R2.fastq}"; done

#####Need to do usearch on ec2 Diego_master

#####Remove all _ character from file names
for file in *; do mv "${file}" "${file/_/}"; done

#mkdir -p output
./bin/usearch11.0.667_i86linux32 -fastq_mergepairs rawdata/*_R1.fastq -relabel @ -fastqout ../output/merged.fq

./bin/usearch11.0.667_i86linux32 -fastq_filter ../output/merged.fq -fastq_maxee 1.0 -fastq_minlen 240 -relabel Filt -fastaout ../output/filtered.fa

./bin/usearch11.0.667_i86linux32 -fastx_uniques ../output/filtered.fa -sizeout -relabel Uniq -fastaout ../output/uniques.fa

./bin/usearch11.0.667_i86linux32 -unoise3 ./output/uniques.fa -zotus ../output/zotus.fa

sed -i 's/Zotu/Otu/g' ../output/zotus.fa > ../output/clean_zotus.fa

./bin/usearch11.0.667_i86linux32 -otutab ../output/merged.fq -zotus ../output/zotus.fa -otutabout ../output/otu_table_zotu.txt -threads 8

#This is just for .biom format
#./bin/usearch11.0.667_i86linux32 -otutab Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/merged.fq -zotus Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/zotus.fa -otutabout Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/otu_table_zotu.txt -biomout Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/otu_table_zotu.biom -threads 16
#rm -f ./output/merged.fq ./output/uniques.fa ./output/filtered.fa

./usearch11.0.667_i86linux32 -sintax ../output/clean_zotus.fq -db ../ref/rdp_16s_v18.fa -strand both -tabbedout ../output/otus_tax.txt -sintax_cutoff 0.8

bash ./convert_usearch_tax.sh ../output/otus_tax.txt ../output/otus_tax_modified.txt

#./Desktop/Wang_lab/data/amerindian_data/bin/usearch11.0.667_i86osx32 -sintax_summary /Users/DRG/Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/otus_tax.txt -otutabin /Users/DRG/Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/otu_table_zotu.txt -rank g -output Desktop/Wang_lab/data/amerindian_data/usearch_analysis/merged_reads/genus_summary.txt