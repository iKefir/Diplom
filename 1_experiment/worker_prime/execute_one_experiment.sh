# /usr/bin/bash

DIR=$(dirname $0)
profilerpath=${DIR}/IOHProfiler
resultpath=${profilerpath}/Experimentation/build/Cpp
newpath_subfolder=fit_${1}_${2}_${3}_${4}
dimensions=${5}
restarts=${6}
newpath=${7}
f_id=${8}
bud_multiplier=${9}
user_algorithm_param_1=${10}
user_algorithm_param_2=${11}

if ! [ -z "$user_algorithm_param_1" ] && [ "$user_algorithm_param_1" -ne 0 ]; then
    newpath_subfolder+="_$user_algorithm_param_1"
fi

if ! [ -z "$user_algorithm_param_2" ] && [ "$user_algorithm_param_2" -ne 0 ]; then
    newpath_subfolder+="_$user_algorithm_param_2"
fi

filename=${newpath_subfolder}

printf "FUNC_ID\t${f_id}\tEXPERIMENT ${newpath_subfolder}\tASSEMBLING\n"
# create config.ini
${DIR}/assemble_config.sh ${filename} ${dimensions} ${f_id} &&
cp ${DIR}/config/assembled.cpp ${resultpath}/configuration.ini &&
# create user algorithm file
${DIR}/assemble_ua.sh ${restarts} ${bud_multiplier} ${1} ${2} ${3} ${4} ${user_algorithm_param_1} ${user_algorithm_param_2} &&
cp ${DIR}/user_algorithm/cpp/assembled/assembled.cpp ${resultpath}/IOHprofiler_run_experiment.cpp &&
# delete any unfinished experiments folders
rm -rf ${resultpath}/${filename}* &&
# build experiment
printf "FUNC_ID\t${f_id}\tEXPERIMENT ${newpath_subfolder}\tCOMPILING\n"
make -C ${profilerpath}/Experimentation > /dev/null &&
# run experiment
printf "FUNC_ID\t${f_id}\tEXPERIMENT ${newpath_subfolder}\tRUNNING\n"
pushd ${resultpath} > /dev/null &&
./bin/IOHprofiler_run_experiment > /dev/null &&
popd > /dev/null &&
# create new folder for results
mkdir -p ${newpath}/${newpath_subfolder} &&
# choose name for result to not intersect with results of same experiment from the past
suffix="" &&
if [ -e ${newpath}/${newpath_subfolder}/${filename} ]; then
    for i in $(seq -f "%03g" 1 999)
    do
        if ! [ -e ${newpath}/${newpath_subfolder}/${filename}-${i} ]; then
            suffix=-${i}
            break
        fi
    done
    mv ${resultpath}/${filename} ${resultpath}/${filename}${suffix}
fi &&
cp -r ${resultpath}/${filename}${suffix} ${newpath}/${newpath_subfolder}/ &&
rm -rf ${resultpath}/${filename}${suffix} &&

# check for phase transition
# ${DIR}/phase_transition_check.py ${newpath} ${newpath_subfolder}/${filename}${suffix} ${dimensions} &&

# zip result
printf "FUNC_ID\t${f_id}\tEXPERIMENT ${newpath_subfolder}\tCOMPRESSING\n"
pushd ${newpath}/${newpath_subfolder} > /dev/null  &&
zip -r -qq ${filename}${suffix} ${filename}${suffix} > /dev/null &&
popd > /dev/null &&

# move zipped result to destination
zipped_path=${newpath}/${newpath_subfolder}/${filename}${suffix}.zip &&
mkdir -p ${newpath}/all_zips &&
new_prefix="" &&
for i in $(seq -f "%03g" 1 999); do
    if ! [ -e ${newpath}/all_zips/${i}-${filename}.zip ]; then
        new_prefix=${i}-
        break
    fi
done &&
cp ${zipped_path} ${newpath}/all_zips/${new_prefix}${filename}.zip &&

# keep your folders clean
rm -rf ${newpath}/${newpath_subfolder}

printf "FUNC_ID\t${f_id}\tEXPERIMENT ${newpath_subfolder}\tFINISHED\n"