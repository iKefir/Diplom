# /usr/bin/bash

DIR=$(dirname $0)
partspath=${DIR}/user_algorithm/cpp
resultname=assembled/assembled.cpp
configname=config.txt
ua_file=${1}
fitness_change_type=${2}
fitness_change_frequency=${3}
user_algorithm_name=${4}
restarts=${5}
bud_multiplier=${6}

> ${partspath}/${resultname} &&
echo '#include "../../src/Template/Experiments/IOHprofiler_experimenter.hpp"' >> ${partspath}/${resultname};
if [ ${user_algorithm_name} == ab ]; then echo "#define AB\n" >> ${partspath}/${resultname}; fi &&
if [ ${user_algorithm_name} == abopt ]; then echo "#define ABOPT\n" >> ${partspath}/${resultname}; fi &&
if [ ${user_algorithm_name} == aboptopt ]; then echo "#define ABOPTOPT\n" >> ${partspath}/${resultname}; fi &&
if [ ${user_algorithm_name} == abstrictinequality ]; then echo "#define ABSTRICTINEQUALITY\n" >> ${partspath}/${resultname}; fi &&
if [ ${user_algorithm_name} == statmin ]; then echo "#define STATMIN\n" >> ${partspath}/${resultname}; fi &&
echo "static const size_t INDEPENDENT_RESTARTS = " ${restarts} ";\n" >> ${partspath}/${resultname} &&
echo "static const size_t BUDGET_MULTIPLIER = " ${bud_multiplier} ";\n" >> ${partspath}/${resultname} &&
cat ${partspath}/params.cpp >> ${partspath}/${resultname} &&
cat ${partspath}/fitness_change_type/${fitness_change_type}.cpp >> ${partspath}/${resultname} &&
echo "static const int FITNESS_CHANGE_FREQUENCY = "${fitness_change_frequency}";\n" >> ${partspath}/${resultname} &&
cat ${partspath}/dynamic_fitness_common.cpp >> ${partspath}/${resultname} &&
cat ${partspath}/mutation.cpp >> ${partspath}/${resultname} &&
cat ${partspath}/user_algorithm/${ua_file} >> ${partspath}/${resultname}
