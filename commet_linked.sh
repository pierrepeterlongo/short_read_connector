#!/bin/bash

version="1.0.0"

function help {
echo "commet_linked.sh. Compare reads from two read sets (distinct or not)"
echo "Version "$version
echo "Usage: sh commet_linked.sh -b read_file_of_files -q read_file_of_files [OPTIONS]"
echo -e "\tMANDATORY:"
echo -e "\t\t -b read_file_of_files for bank"
echo -e "\t\t    Example: -ref data/c1.fasta.gz"
echo -e "\t\t -r read_file_of_files for query"
echo -e "\t\t    Example: -ref data/c2.fasta.gz"

echo -e "\tOPTIONS:"
echo -e "\t\t -p prefix. All out files will start with this prefix. Default=\"commet_linked_res\""
echo -e "\t\t -k value. Set the length of used kmers. Must fit the compiled value. Default=25"
echo -e "\t\t -a: kmer abundance min (kmer from bank seen less than this value are not indexed). Default=2"
echo -e "\t\t -t: minimal number of kmer shared by two reads to be considered as similar. Default=20"
#echo "Any further question: read the readme file or contact us via the Biostar forum: https://www.biostars.org/t/discosnp/"
}



bank_set=""
query_set=""
kmer_size=25
abundance_min=2
fingerprint_size=8
kmer_threshold=20
prefix="commet_linked_res"

#######################################################################
#################### GET OPTIONS                #######################
#######################################################################
while getopts ":hb:q:p:k:a:t:" opt; do
case $opt in

h)
help
exit 
;;

b)
echo "use bank read set: $OPTARG" >&2
bank_set=$OPTARG
;;


q)
echo "use query read set: $OPTARG" >&2
query_set=$OPTARG
;;



p)
echo "use prefix=$OPTARG" >&2
prefix=$OPTARG
;;


k)
echo "use k=$OPTARG" >&2
k=$OPTARG
;;


a)
echo "use abundance_min=$OPTARG" >&2
abundance_min=$OPTARG
;;

t)
echo "use kmer_threshold=$OPTARG" >&2
kmer_threshold=$OPTARG
;;

       #
       # u)
       # echo "use at most $OPTARG cores" >&2
       # option_cores_gatb="-nb-cores $OPTARG"
       # option_cores_post_analysis="-t $OPTARG"
       # ;;

\?)
echo "Invalid option: -$OPTARG" >&2
exit 1
;;

:)
echo "Option -$OPTARG requires an argument." >&2
exit 1
;;
esac
done
#######################################################################
#################### END GET OPTIONS            #######################
#######################################################################

if [ -z "${bank_set}" ]; then
	echo "You must provide a bank read set (-b)"
help
exit 1
fi

if [ -z "${query_set}" ]; then
	echo "You must provide a query read set (-q)"
help
exit 1
fi

out_dsk=${prefix}"_solid_kmers.h5"
result_file=${prefix}".txt"


EDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Count kmers using dsk
#
$EDIR/thirdparty/dsk/bin/macosx/dsk -file ${bank_set} -kmer-size ${kmer_size} -abundance-min ${abundance_min} -out ${out_dsk}

unsorted_result_file=${result_file}"_unsorted"
# Compare read sets
$EDIR/build/tools/kmer_quasi_indexer/kmer_quasi_indexer -graph ${out_dsk}  -bank ${bank_set} -query ${query_set} -out ${unsorted_result_file} -kmer_threshold ${kmer_threshold} -fingerprint_size ${fingerprint_size}

sort -n ${unsorted_result_file} > ${result_file}
rm -f ${unsorted_result_file}
