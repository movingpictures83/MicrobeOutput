library(optparse)
library(tidyverse)
library(dplyr)
library(stringr)

dyn.load(paste("RPluMA", .Platform$dynlib.ext, sep=""))
source("RPluMA.R")


source("RIO.R")

input <- function(infile) {
         pfix = prefix()
   parameters <<- readParameters(infile)
   sample_name <<- parameters['sample_name', 2]
   output_file <<- paste(pfix, parameters['output_file', 2], sep="/")
   kraken_report <<- paste(pfix, parameters['kraken_report', 2], sep="/")
   mpa_report <<- paste(pfix, parameters['mpa_report', 2], sep="/")
   keep_original <<- parameters['keep_original', 2]
   ntaxid <<- as.numeric(parameters['ntaxid', 2])
}

run <- function() {}

output <- function(out_path) {

kr = read.delim(kraken_report, header = F)
kr = kr[-c(1:2), ]
mpa = read.delim(mpa_report, header = F)
n = str_which(mpa$V1, 'k__Bacteria|k__Fungi|k__Viruses')
taxid = kr$V7[n]
taxid.list = split(taxid, ceiling(seq_along(taxid)/ntaxid))
print(taxid.list)

if(file.exists(paste0(out_path, sample_name, '.microbiome.output.txt'))){
  system(paste0('rm ', out_path, sample_name, '.microbiome.output.txt'))
}

for(i in 1:length(taxid.list)){
  print(paste('Extracting output data', i, '/', length(taxid.list)))
  
  taxid = paste0("(taxid ", taxid.list[[i]], ")", collapse = "\\|")
  taxid = paste0("'", taxid, "'")
  str = paste0("grep -w ", taxid, " ", output_file, " >> ", out_path, sample_name, ".microbiome.output.txt")
  system(str)
}

if(keep_original == F){
  system(paste('rm', output_file))
}

print('Done')
}
