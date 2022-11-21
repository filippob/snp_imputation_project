#!/bin/sh

## script that converts alleles simulated by QMsim
## from 1/2 coding to arbitrary nucleotides (e.g. A/C)
## would this work? (operationally yes, but what about possible biases?)

prefix="line"
targetpath="simulation/r_sim1"

if [ ! -d $targetpath ]; then
	mkdir -p $targetpath
fi

for i in {1..3}
do
	echo "processing file line$i.ped"
	inpf=${prefix}$i.ped
	cut -f7- -d' ' ${targetpath}/$inpf > ${targetpath}/temp
	cut -f1-6 -d' ' ${targetpath}/$inpf > ${targetpath}/metadata

	sed -i 's/1/A/g' ${targetpath}/temp
	sed -i 's/2/C/g' ${targetpath}/temp
	
	outf=${prefix}${i}_recoded.ped
	paste -d' ' ${targetpath}/metadata ${targetpath}/temp > ${targetpath}/${outf}
done

rm ${targetpath}/temp ${targetpath}/metadata

echo "DONE!"
