#!/bin/bash

# Params
in_file=$1
out_dir=$2
user=$3
password=$4

# Download files.
url=https://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11
mkdir -p $out_dir
sed 1d $in_file | while read line
do
	file=$(echo $line | sed 's/\r//g')
	out_file=$file
	if [ ! -f "$out_file" ]; then
        wget --auth-no-challenge -O $out_file --user=$user --password=$password $url/$file || rm -f $url/$file
    fi
    if [ ! $out_dir == "" ]; then
        unzipped1=$out_dir/"${file%%.*}".hgt
        unzipped2=$out_dir/"${file%%.*}".SRTMGL1.hgt
        if [[ ! -f "$unzipped1" && ! -f "$unzipped2" ]]; then
            unzip $out_file -d $out_dir
        fi
    fi
done
