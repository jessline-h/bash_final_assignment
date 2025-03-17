#!/bin/bash
PATH=~:$PATH

# This script take BAM file and converts it to BED file
# input: .bam file and output directory where you want to save your file to
# output: .bed file, .bed file filtered for chromosome 1, and a .txt file containing number of rows of filtered .bed file

source $(dirname $(dirname $(which mamba)))/etc/profile.d/conda.sh

conda create -n bam2bed -y

conda activate bam2bed

#error handling: if only 1 file provided
if [[ "$#" -lt 2 ]]; then
	echo "Error: please provide minimum 2 arguments."
	exit 1
fi


#define input files
input_bam=$1
output_dir=$2


#error handling: if no bam file is provided
if [[ ! "$input_bam" =~ \.bam$ ]]; then
	echo "Error: input file must be .bam file."
	exit 1
fi


#extract file name
filename_bam="${input_bam##*/}"
filename="${filename_bam%.*}"

#if clean flag is used, remove the output directory before recreating it
#make new directory

if [[ "$clean_flag" == "--clean" ]]; then
	rm -rf "$output_dir"
fi

mkdir -p "$output_dir"


#define output bed file path
output_bed="$output_dir/${filename}"


#convert bam to bed files and save in the define directory
bedtools bamtobed -i "$input_bam" > "$output_bed.bed"

#check if conversion was susscessful
if [[ $? -eq 0 ]]; then
	echo "Success! BED file saved to: $output_bed.bed"
else
	echo "Failed conversion"
	exit 1
fi


#filtered bed for chr1
grep -E -i '^chr1\s' "$output_bed.bed" > "${output_bed}_chr1.bed"


#error handling: if no chr 1
if [[ $? -eq 0 ]]; then
	echo "Success! BED file filtered for chr 1."
else
	echo "Failed filtering"
	exit 1
fi

#count the number of lines

wc -l "${output_bed}_chr1.bed" > "$output_dir/bam2bed_number_of_rows.txt"

num_rows=$(< "${output_bed}_chr1.bed" wc -l)

echo "Number of rows for ${filename}_chr1.bed: $num_rows"


#print name
echo "Jessline Haruman"
