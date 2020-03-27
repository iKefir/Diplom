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
echo "static const size_t INDEPENDENT_RESTARTS = " ${restarts} ";\n" >> ${partspath}/${resultname} &&
echo "static const size_t BUDGET_MULTIPLIER = " ${bud_multiplier} ";\n" >> ${partspath}/${resultname} &&
cat ${partspath}/params.cpp >> ${partspath}/${resultname} &&
cat ${partspath}/fitness_change_type/${fitness_change_type}.cpp >> ${partspath}/${resultname} &&
echo "static const int FITNESS_CHANGE_FREQUENCY = "${fitness_change_frequency}";\n" >> ${partspath}/${resultname} &&
cat ${partspath}/dynamic_fitness_common.cpp >> ${partspath}/${resultname} &&
cat ${partspath}/mutation.cpp >> ${partspath}/${resultname} &&
cat ${partspath}/user_algorithm/${user_algorithm_name}/algo.cpp >> ${partspath}/${resultname}
