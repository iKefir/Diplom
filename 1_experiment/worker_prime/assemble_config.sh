# /usr/bin/bash

DIR=$(dirname $0)
partspath=${DIR}/config
resultname=assembled.cpp
experiment_name=${1}

> ${partspath}/${resultname}
echo "[suite]" >> ${partspath}/${resultname} &&
echo "suite_name = PBO" >> ${partspath}/${resultname} &&
echo "problem_id = "${3} >> ${partspath}/${resultname} &&
echo "instance_id = 1" >> ${partspath}/${resultname} &&
echo "dimension = "${2} >> ${partspath}/${resultname} &&

echo "[logger]" >> ${partspath}/${resultname} &&
echo "output_directory = ./" >> ${partspath}/${resultname} &&
echo "result_folder = "${experiment_name} >> ${partspath}/${resultname} &&
echo "algorithm_name = "${experiment_name} >> ${partspath}/${resultname} &&
echo "algorithm_info = "${experiment_name} >> ${partspath}/${resultname} &&

echo "[observer]" >> ${partspath}/${resultname} &&
echo "complete_triggers = true" >> ${partspath}/${resultname} &&
echo "update_triggers = false" >> ${partspath}/${resultname} &&
echo "number_interval_triggers = 0" >> ${partspath}/${resultname}
echo "number_target_triggers = 0" >> ${partspath}/${resultname} &&
echo "base_evaluation_triggers = 1,2,5" >> ${partspath}/${resultname}
