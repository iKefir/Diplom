DIR=$(dirname $0)
partspath=${DIR}/user_algorithm/c/create_your_ua
resultname=assembled.c
configname=config.txt
fitness_change_type=${1}
fitness_change_frequency=${2}
user_algorithm_name=${3}
restarts=${4}
bud_multiplier=${5}

> ${partspath}/${resultname} &&
if [ ${user_algorithm_name} == ab ]; then echo "#define AB\n" >> ${partspath}/${resultname}; fi &&
echo "static const size_t INDEPENDENT_RESTARTS = " ${restarts} ";\n" >> ${partspath}/${resultname} &&
echo "static const size_t BUDGET_MULTIPLIER = " ${bud_multiplier} ";\n" >> ${partspath}/${resultname} &&
cat ${partspath}/params.c >> ${partspath}/${resultname} &&
cat ${partspath}/fitness_change_type/${fitness_change_type}.c >> ${partspath}/${resultname} &&
echo "static const int FITNESS_CHANGE_FREQUENCY = "${fitness_change_frequency}";\n" >> ${partspath}/${resultname} &&
cat ${partspath}/dynamic_fitness_common.c >> ${partspath}/${resultname} &&
cat ${partspath}/mutation.c >> ${partspath}/${resultname} &&
cat ${partspath}/user_algorithm/algo.c >> ${partspath}/${resultname}
