# /usr/bin/bash

DIR=$(dirname $0)
partspath=${DIR}/user_algorithm/cpp
resultname=assembled/assembled.cpp
configname=config.txt
restarts=${1}
bud_multiplier=${2}
fitness_change_type=${3}
fitness_change_frequency=${4}
user_algorithm_name=${5}
user_algorithm_param_1=${6}
user_algorithm_param_2=${7}

> ${partspath}/${resultname}
echo '#include "../../src/Template/Experiments/IOHprofiler_experimenter.hpp"' >> ${partspath}/${resultname}
echo "static const size_t INDEPENDENT_RESTARTS = " ${restarts} ";\n" >> ${partspath}/${resultname}
echo "static const size_t BUDGET_MULTIPLIER = " ${bud_multiplier} ";\n" >> ${partspath}/${resultname}
if ! [ -z "$user_algorithm_param_1" ]; then
    echo "static const size_t USER_ALGORITHM_PARAM_1 = " ${user_algorithm_param_1} ";\n" >> ${partspath}/${resultname}
fi
if ! [ -z "$user_algorithm_param_2" ]; then
    echo "static const size_t USER_ALGORITHM_PARAM_2 = " ${user_algorithm_param_2} ";\n" >> ${partspath}/${resultname}
fi
cat ${partspath}/params.cpp >> ${partspath}/${resultname}
cat ${partspath}/fitness_change_type/${fitness_change_type}.cpp >> ${partspath}/${resultname}
echo "static const int FITNESS_CHANGE_FREQUENCY = "${fitness_change_frequency}";\n" >> ${partspath}/${resultname}
cat ${partspath}/dynamic_fitness_common.cpp >> ${partspath}/${resultname}
cat ${partspath}/mutation.cpp >> ${partspath}/${resultname}
cat ${partspath}/user_algorithm/${user_algorithm_name}/algo.cpp >> ${partspath}/${resultname}
