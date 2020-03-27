# /usr/bin/bash

# Нужно уметь выбрать
#   Изменения фитнесса - параметр fitness = static | bitinvert | permutation
#                        параметр fitness_freq = int - имеет смысл писать, если не static
#   Изменения мутации - параметр mutation_rate = static | dynamic (характер изменений зависит от алгоритма)
#   Изменения параметров для остановки - параметр
#
# execute_one_experiment fitness frequency algorithm_defines
# fitness
#   stat - fitness function don't change
#   bi   - fitness function inverts one bit every frequency evaluations
#   pm   - fitness function changes its permutation every frequency evaluations
# frequency
#   0    - for static fitness function (can work with others with unnecassary calls)
#   any positive integer pls
# algorithm_defines = ab | resend
#   ab     - uses ab mutation rate change

if [ "$#" -eq 0 ]; then
  echo >&2 "Missing experiment name argument"
  exit 1
fi

DIR=$(dirname $0)

newpath=${DIR}/../../1Diplom/1_experiment/RunResults/$1

worker_amount=${2:-1}

pipe=/tmp/experimentPipe
processing_info_pipe=/tmp/processingInfoPipe

cleanup(){
  rm -f $pipe
  rm -f $processing_info_pipe
}

trap "cleanup; exit" INT TERM
trap "cleanup; kill 0" EXIT

if [[ ! -p $pipe ]]; then
  mkfifo $pipe
fi

if [[ ! -p $processing_info_pipe ]]; then
  mkfifo $processing_info_pipe
fi

workers=()
worker_last_info=()
finished_workers=0
jobs=()
job_i=0

setup_workers(){
  for (( worker_i=0; worker_i<$worker_amount; worker_i++ )); do
  workers+=( "${DIR}/../../$((worker_i+1))Diplom/1_experiment/execute_one_experiment.sh" )
  worker_last_info+=( "WAITING" )
  done
}

generate_jobs(){
  dimension=100
  restarts=100
  budget_multiplier=6

  func_id_arr=(1 4 7 9 2 11 14 16) # 1 4 7 9 2 11 14 16
  ua_arr=(stat)
  fitness_arr=(bi)
  frequency_arr=(5000 500)

  for func_id in ${func_id_arr[@]}; do
    for ua in ${ua_arr[@]}; do
      for fitness in stat; do
        for frequency in 0; do
          jobs+=( "${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}" )
        done
      done

      for fitness in ${fitness_arr[@]}; do
        for frequency in ${frequency_arr[@]}; do
          jobs+=( "${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}" )
        done
      done
    done
  done
}

print_processing_info(){
  job_i=0
  while true; do
    if read line <$processing_info_pipe; then
      # printf "READ: $line\n"
      if [[ "$line" == 'tinc' ]]; then
        ((job_i++))
        continue
      fi
      if [[ "$line" == 'quit' ]]; then
        break
      fi
      IFS=',' read -r -a args <<< "$line"
      worker_last_info[${args[0]}]="${args[1]}"
      to_print="\r\033[K\033[1F\033[K"
      for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
        to_print+="\033[1F\033[K"
      done
      to_print+="$((job_i*100/ $1))%%\t${job_i} / $1\tExperimenting\n"
      for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
        to_print+="WORKER\t$((worker_i+1))\t${worker_last_info[$worker_i]}\n"
      done
      printf "$to_print"
    fi
  done
}

update_processing_info(){
  # printf "WRITE: $1,$2\n"
  echo "$1,$2" >$processing_info_pipe
}

start_worker(){
  job=${jobs[$2]}
  worker=${workers[$1]}
  # printf "Worker: $worker\tJob: $job\n"
  if [ -n "$job" ]; then
    $worker $job | while read line; do update_processing_info $1 "$line"; done
    echo "tinc" >$processing_info_pipe
    sleep 1
    echo "$1" >$pipe
  else
    echo "quit" >$pipe
  fi
}

setup_workers
generate_jobs

printf "\n"
for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
  printf "\n"
done

print_processing_info ${#jobs[@]} &
for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
  start_worker $worker_i $job_i &
  ((job_i++))
  sleep 1
done
while true; do
  if [[ ! -p $pipe ]]; then
    break
  fi
  if read line <$pipe; then
    if [[ "$line" == 'quit' ]]; then
      ((finished_workers++))
      if [ $finished_workers -eq ${#workers[@]} ]; then
        exit
      fi
      continue
    fi
    start_worker $line $job_i &
    ((job_i++))
  fi
done