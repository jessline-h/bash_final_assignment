#!/bin/bash
PATH=~:$PATH

# This script take BAM file and converts it to BED file
# input: BAM file
# output: output directory

source $(dirname $(dirname $(which mamba)))/etc/profile.d/conda.sh


#error handling: if only 1 file provided
if [[ "$#" -lt 2 ]]; then
	echo "Error: please provide minimum 2 arguments."
	exit 1
fi


#define input files
input_bam=$1
outputdir=$2


#error handling: if no bam file is provided
if [[ ! "$input_bam" =~ \.bam$ ]]; then
	echo "Error: input file must be .bam file."
	exit 1
fi


#extract file name
filename_bam="${input_bam##*/}"
filename="${filename_bam%.*}"

#error handling if the output_dir provided name already exist
#make new directory

if [[ -d "$outputdir" ]]; then
	timestamp=$(date +"%Y%m%d_%H%M%S")
	output_dir="${outputdir}_${timestamp}"
	mkdir -p "$output_dir"

else 
	output_dir="$outputdir"
	mkdir -p "$output_dir"

fi


#define output bed file path
output_bed="$output_dir/$filename"

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
grep -Ei '^chr1\s' "$output_bed.bed" > "$output_bed.filtered_chr1.bed"


#error handling: if no chr 1
if [[ $? -eq 0 ]]; then
	echo "Success! BED file filtered for chr 1."
else
	echo "Failed filtering"
	exit 1
fi


#count the number of lines
wc -l "$output_bed.bed" > "$output_dir/bam2bed_number_of_rows.txt"

num_rows=$(< "$output_bed.bed" wc -l)

echo "Number of rows for $filename.bed: $num_rows"


#print name
echo "Jessline Haruman"
