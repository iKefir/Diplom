# /usr/bin/bash

DIR=$(dirname $0)
profilerpath=${DIR}/IOHProfiler
resultpath=${profilerpath}/Experimentation/code-experiments/build/c
newpath_subfolder=fit_${1}_${2}_${3}
dimensions=${4}
restarts=${5}
newpath=${6}
f_id=${7}
bud_multiplier=${8}
filename=${newpath_subfolder}

echo ""
echo START ${newpath_subfolder}

# create config.ini
${DIR}/assemble_config.sh ${filename} ${dimensions} ${f_id} &&
cp ${DIR}/config/assembled.c ${resultpath}/configuration.ini &&
# create user algorithm file
${DIR}/assemble_ua.sh ${1} ${2} ${3} ${restarts} ${bud_multiplier} &&
cp ${DIR}/user_algorithm/c/create_your_ua/assembled.c ${resultpath}/user_algorithm.c &&
# delete any unfinished experiments folders
rm -rf ${resultpath}/${filename}* &&
# run experiment
python ${profilerpath}/Experimentation/do.py run-c > /dev/null &&
# create new folder for results
mkdir -p ${newpath}/${newpath_subfolder} &&
# choose name for result to not intersect with results of same experiment from the past
suffix="" &&
if [ -e ${newpath}/${newpath_subfolder}/${filename} ]
then
  for i in $(seq -f "%03g" 1 999)
  do
    if ! [ -e ${newpath}/${newpath_subfolder}/${filename}-${i} ]
    then
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
pushd ${newpath}/${newpath_subfolder} &&
zip -r -qq ${filename}${suffix} ${filename}${suffix} &&
popd &&

# move zipped result to destination
zipped_path=${newpath}/${newpath_subfolder}/${filename}${suffix}.zip &&
mkdir -p ${newpath}/all_zips &&
new_prefix="" &&
for i in $(seq -f "%03g" 1 999)
do
  if ! [ -e ${newpath}/all_zips/${i}-${filename}.zip ]
  then
    new_prefix=${i}-
    break
  fi
done &&
cp ${zipped_path} ${newpath}/all_zips/${new_prefix}${filename}.zip &&

# keep your folders clean
rm -rf ${newpath}/${newpath_subfolder} &&

echo DONE ${newpath_subfolder}
