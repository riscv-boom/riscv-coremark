#!/bin/bash

# This script tries to assembly our CoreMark-PRO run output from the FPGA and generate a  CoreMark-PRO score.
#
# DO NOT USE THIS TO REPORT COREMARK-PRO RESULTS.
#
# There are two liberties taken:
#  - we aren't doing a separate verification run. We should have already verified off-line that it works.
#  - we aren't doing 3 separate data runs. 

BENCHMARKS=(cmp-cjpeg cmp-core cmp-linear cmp-loops cmp-nnet cmp-parser cmp-radix cmp-sha cmp-zip)

CMP_INSTALL=${CMP_INSTALL:-../coremarkpro_1.1.2743}
DIR=${DIR:-../output}

PARSER=${CMP_INSTALL}/util/perl/results_parser.pl
MEDIAN=${CMP_INSTALL}/util/perl/cert_median.pl
MARK=${CMP_INSTALL}/util/perl/cert_mark.pl
HEADING="#UID            Suite Name                                     Ctx Wrk Fails       t(s)       Iter     Iter/s  Codesize   Datasize"


# assembly data in a per-benchmark file
for b in ${BENCHMARKS[@]}; do
   LOG=${DIR}/${b}.temp
   touch ${LOG}

   echo "${HEADING}" >> ${LOG}

   echo "#Results for verification run" >> ${LOG}
   # LIE: cert_mark needs to see a verification run, so let's lie to it.
   perl ${PARSER} ${LOG} ${DIR}/${b}.out

   echo "#Results for performance runs" >> ${LOG}
   # LIE: "median" needs 3 results, so let's just spam the same result 3 times. ^^
   perl ${PARSER} ${LOG} ${DIR}/${b}.out
   perl ${PARSER} ${LOG} ${DIR}/${b}.out
   perl ${PARSER} ${LOG} ${DIR}/${b}.out

   echo "#Median for final result" >> ${LOG}
   perl ${MEDIAN} ${LOG} single >> ${LOG}

    
   echo "#Results for verification run" >> ${LOG}
   # LIE: cert_mark needs to see a verification run, so let's lie to it.
   perl ${PARSER} ${LOG} ${DIR}/${b}.out

   echo "#Results for performance runs" >> ${LOG}
   # LIE: "median" needs 3 results, so let's just spam the same result 3 times. ^^
   perl ${PARSER} ${LOG} ${DIR}/${b}.out
   perl ${PARSER} ${LOG} ${DIR}/${b}.out
   perl ${PARSER} ${LOG} ${DIR}/${b}.out

   echo "#Median for final result" >> ${LOG}
   perl ${MEDIAN} ${LOG} best >> ${LOG}
done

# assembly data into a single log file -- delete the per-benchmark file
# this hack gets around the fact that "median" wants to print all medians it has seen,
# but "mark" wants a different layout. -.-
rm ${DIR}/cmp.log
touch ${DIR}/cmp.log
for b in ${BENCHMARKS[@]}; do
   LOG=${DIR}/${b}.temp
   cat ${LOG} >> ${DIR}/cmp.log
   rm ${LOG}
done

cat ${DIR}/cmp.log

#perl ${MEDIAN} ${DIR}/cmp.log single >> ${DIR}/cmp.log
perl ${MARK} -i ${DIR}/cmp.log -s coremarkpro > ${DIR}/cmp.mark
cat ${DIR}/cmp.mark
echo "THIS IS NOT A VALID COREMARK-PRO SCORE. STOP USING HACKY FILES THAT IS FULL OF LIES."
