#in python

import os
import re

## define path to input map file ##
prjfolder = '/home/biscarinif/imputation'
fname = '/home/freeclimb/data/maize/maize.map'
outdir = os.path.join(prjfolder, 'Analysis/maize/filtered_data')
nreplicates = 10 ## n. of bootstrapping replicates of the data
nld = 8144 ## for maize nld = 8144, as in peach (althoug HD is 47k in maize and 18k in peach)

print('input file is', os.path.join(prjfolder, fname))
print('outdir is', outdir)

mapin = open(os.path.join(prjfolder, fname))

snps=[]
for line in mapin:
	line=line.split()
	if line[1] not in snps:
		snps.append(line[1])

nsnps = len(snps)

import numpy as np

counter=0
for i in range(3):
    counter+=1
    print('iteration n. {}'.format(counter))
    randNumbers=np.random.randint(1, nsnps, nld)
    sortedrandNumbers=sorted(randNumbers)
    randsnps=[]
    for i in sortedrandNumbers:
        randsnps.append(snps[i])
    mapin.seek(0)
    bsnm = os.path.basename(mapin.name)
    temp = re.sub('\.map$', '', bsnm) + "_bootstrap_" + str(counter) + ".txt"
    filename = os.path.join(outdir, temp)
    print('currently creating file: ', filename)
    mapOut = open(filename, 'w')
    for line in mapin:
        line=line.split()
        for locus in randsnps:
            if line[1]==locus:
                mapOut.write(str(line[1]).replace("['","").replace("', '","\t").replace("']","")+'\n')
    mapOut.close()



