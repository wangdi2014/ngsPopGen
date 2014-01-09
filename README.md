# ngsPopGen

Several tools to perform population genetic analyses from NGS data:
 * ` ngsFst`  - Quantificate population genetic differentiation
 * ` ngsCovar`  - Population structure via PCA (principal components analysis)
 * ` ngs2dSFS`  - Estimate 2D-SFS from posterior probabilities of sample allele frequencies
 * ` ngsStat`  - Estimates number of segregating sites, expected average heterozygosity, and number of fixed differences (if 2 populations provided).

NOTE: In all analisis involving 2 populations, input data must refer to the exact same sites. If they differ (e.g. because of different filtering), use `GetSubSfs` ([ngsUtils](https://github.com/mfumagalli/ngsUtils)) to get an overlapping subset of sites for both populations (you can use .mafs file from ANGSD to get the corresponding coordinates).


### Installation

    % git clone https://github.com/mfumagalli/ngsPopGen.git

To install these tools just run:

    % cd ngsPopGen
    % make
    % make test

Executables are built into the main directory. If you wish to clean all binaries and intermediate files:

    % make clean

---

## ngsFST

Program to estimate FST from NGS data. It computes expected genetic variance components and estimate per-site FST from those using methods-of-moments estimator. See Fumagalli et al. Genetics 2013 for more details.
In input it receives posterior probabilities of sample allele frequencies for each population. It may receive also a 2D-SFS as a prior and in this case it receives as input posterior probabilities with uniform prior (ANGSD with -realSFS 1 only, and then set -islog 1). You can give also 2 marginal spectra as priors.

The output is a tab-separated text file. Each row represents a site. Columns are labelled: EA, EAB, FACT, (EA/EAB)+FACT, pvar; where EA is the expectation of genetic variance between populations, EAB is the expectation of the total genetic variance, FACT is the correcting factor for the ratio of expectations, (EA/EAB)+FACT is the per-site FST value, pvar is the probability for the site of being variable.


### Usage
#### Examples:

 * using a 2D-SFS as a prior, estimated using ngs2dSFS (recommended if data is unfolded):

#

    % ./ngsFST -postfiles pop1.sfs pop2.sfs -priorfile spectrum2D.txt -nind 20 20 -nsites 100000 -block_size 20000 -outfile pops.fst -islog 1

 * using marginal spectra as priors, estimated using optimSFS (ANGSD):

#

    % ./ngsFST -postfiles pop1.sfs pop2.sfs -priorfiles spectrum1.txt spectrum2.txt -nind 20 20 -nsites 100000 -block_size 20000 -outfile pops.fst -islog 1

 * instead of prior files, we can also directly provide the posterior probabilities:

#

    % ./ngsFST -postfiles pop1.sfs.ml.norm pop2.sfs.ml.norm -nind 20 20 -nsites 100000 -block_size 20000 -outfile pops.fst -islog 0

* use posterior probabilities of allele frequencies from a uniform prior without initially folding your data:

#

    % ./ngsFST -postfiles pop1.sfs pop2.sfs -nind 20 20 -nsites 100000 -block_size 20000 -outfile pops.fst -islog 1

#### Parameters:

    -postfiles: files with posterior probabilities of sample allele frequencies (.sfs or .saf) for each population
    -priorfile: 2D-SFS to be used as a prior; you can use ngs2dSfs with parameter -relative set to 1
    -priorfiles: 2 marginal spectra to be used as priors
    -nind: number of individuals for each population
    -nsites: total number of sites; in case of a site subset this is the upper limit
    -firstbase: in case of a site subset, this is the lower limit
    -isfold: boolean, is your data folded?
    -islog: boolean, are postfiles in -log?
    -outfile: name of the output file
    -block_size: number of sites in each chunk (for memory reasons)
    -verbose: level of verbosity

NOTE: Currently, it is not possible to estimate a joint-SFS from folded data. Also, one should check whether each site has the same minor allele for both populations (hardly met for many cases). Therefore, for _Fst_ estimation, a solution would be to use posterior probabilities of allele frequencies from a uniform prior (see examples).

---

## ngsCovar

Program to compute the expected correlation matrix between individuals from genotype posterior probabilities. It receives as input genotype posterior probabilities. It can receive in input also posterior probabilities of sample allele frequencies for computing the probability of each site to be variant.

### Usage

#### Examples:

* not calling genotypes and weighting by each site's probability of being variable (recommended if no SNP calling is performed and coverage is low):

#

    % ./ngsCovar -probfile pop.geno -outfile pop.covar -nind 40 -nsites 100000 -block_size 20000 -call 0 -norm 0 -sfsfile pop.sfs.ml.norm
    
    * not calling genotypes:

#

    % ./ngsCovar -probfile pop.geno -outfile pop.covar -nind 40 -nsites 100000 -block_size 20000 -call 1
    
    * calling genotypes and filtering out rare variants:

#

    % ./ngsCovar -probfile pop.geno -outfile pop.covar -nind 40 -nsites 100000 -block_size 20000 -call 1 -minmaf 0.05


#### Parameters:

    -probfile: file with genotype posterior probabilities
    -sfsfile: file with sample allele frequency posterior probabilities
    -nind: number of individuals
    -nsites: total number of sites; in case of a site subset this is the upper limit
    -offset: in case of a site subset, this is the lower limit
    -genoquality: text file with 'nsites' lines stating whether to use (1) or ignore (0) the site
    -norm: 0 [no normalization, recommended if no SNP calling is performed]
           1 [matrix is normalized by p(1-p) as in Patterson et al (2006)]
           2 [normalized by 2p(1-p)]
    -minmaf: ignore sites below this threshold of minor allele frequency
    -call: call genotypes based on the maximum posterior probability
    -isfold: boolean, is your data folded?
    -islog: boolean, are postfiles in -log?
    -outfile: name of output file
    -block_size: number of sites in each chunk (for memory reasons)
    -verbose: level of verbosity

---

## ngs2dSFS

Program to estimate 2D-SFS from posterior probabilities of sample allele frequencies.

#### Example:

    % ./ngs2dSFS -postfiles pop.sfs.ml.norm pop.sfs.ml.norm -outfile spectrum.txt -relative 1 -nind 20 20 -nsites 100000 -block_size 20000

#### Parameters:

    -postfiles: file with sample allele frequency posterior probabilities for each population
    -nind: number of individuals
    -nsites: total number of sites; in case of a site subset this is the upper limit
    -offset: in case of a site subset, this is the lower limit
    -outfile: name of output file
    -maxlike: compute the MLE as the sum across sites' joint allele frequency (1) or as the sum of the products of likelihoods (0)
    -relative: boolean, whether input are absolute counts of sites with a specific joint allele frequency (0) or relative frequencies (1)
    -block_size: memory efficiency, number of sites for each chunk

---

## ngsStat

Program to compute estimates of the number of segregating sites, the expected average heterozygosity, and the number of fixed differences (if 2 populations data is provided). It receives as input sample allele frequency posterior probabilities (from ANGSD) from 1 or 2 populations. Output is a text file with columns: start, end, segregating sites (pop 1), heterozygosity (pop 1), segregating sites (pop 2), heterozygosity (pop 2), fixed differences.

#### Example:

* 2 populations, sliding windows of 100 sites (latter recommended only if no missing data is present):

#

    ./ngsStat -npop 2 -postfiles pop1.sfs.norm pop2.sfs.norm -nsites 1000 -iswin 1 -nind 10 50 -islog 0 -outfile pops.stat -isfold 0 -verbose 0 -block_size 100
    
* 1 populations, sliding windows of 100 sites (latter recommended only if no missing data is present):

# 

    ./ngsStat -npop 1 -postfiles pop1.sfs.norm -nsites 1000 -iswin 1 -nind 10 -islog 0 -outfile pops.stat -isfold 0 -verbose 0 -block_size 100
    
* 1 population, values estimated at each site (recommended in case of missing data):

#

    ./ngsStat -npop 1 -postfiles pop1.sfs.norm -nsites 1000 -iswin 0 -nind 10 -islog 0 -outfile pops.stat -isfold 0 -verbose 0

#### Parameters:

    -npop: number of populations (should be the first one to be specified)
    -postfiles: file with sample allele frequency posterior probabilities for each population
    -nind: number of individuals
    -nsites: total number of sites; in case of a site subset this is the upper limit
    -firstbase: in case of a site subset, this is the lower limit
    -isfold: boolean, is your data folded?
    -islog: boolean, are postfiles in -log?
    -iswin: if set to 1, chuncks are considered non-overlapping sliding-windows
    -outfile: name of output file
    -block_size: number of sites in each chunk (for memory reasons)
    -verbose: level of verbosity
