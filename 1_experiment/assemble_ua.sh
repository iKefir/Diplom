# /usr/bin/bash

DIR=$(dirname $0)
partspath=${DIR}/user_algorithm/cpp
resultname=assembled/assembled.cpp
configname=config.txt
fitness_change_type=${1}
fitness_change_frequency=${2}
user_algorithm_name=${3}
restarts=${4}
bud_multiplier=${5}

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
cat ${partspath}/user_algorithm/algo.cpp >> ${partspath}/${resultname}
