# /usr/bin/bash

DIR=$(dirname $0)
partspath=${DIR}/config
resultname=assembled.c
experiment_name=${1}

> ${partspath}/${resultname}
echo "[suite]" >> ${partspath}/${resultname} &&
echo "suite_name = PBO" >> ${partspath}/${resultname} &&
echo "functions_id = "${3} >> ${partspath}/${resultname} &&
echo "instances_id = 1" >> ${partspath}/${resultname} &&
echo "dimensions = "${2} >> ${partspath}/${resultname} &&

echo "[observer]" >> ${partspath}/${resultname} &&
echo "observer_name = PBO" >> ${partspath}/${resultname} &&
echo "result_folder = "${experiment_name} >> ${partspath}/${resultname} &&
echo "algorithm_name = "${experiment_name} >> ${partspath}/${resultname} &&
echo "algorithm_info = "${experiment_name} >> ${partspath}/${resultname} &&
echo "parameters_name = best_value,mutation_rate,next_budget_to_change_fitness" >> ${partspath}/${resultname} &&

# mutation_rate,FITNESS_CHANGE_FREQUENCY,lambda

echo "[triggers]" >> ${partspath}/${resultname} &&
echo "number_target_triggers = 0" >> ${partspath}/${resultname} &&
echo "base_evaluation_triggers = 1,2,5" >> ${partspath}/${resultname} &&
echo "complete_triggers = true" >> ${partspath}/${resultname} &&
echo "number_interval_triggers = 0" >> ${partspath}/${resultname}
