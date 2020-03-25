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

DIR=$(dirname $0)

newpath=${DIR}/../../1Diplom/1_experiment/RunResults/$1

worker_amount=${2:-1}

dimension=100
restarts=100
budget_multiplier=6

func_id_arr=(1 4 7 9 2 11 14 16) # 1 4 7 9 2 11 14 16
ua_arr=(stat ab)
fitness_arr=(bi pm)
frequency_arr=(5000 500 50 5)

full_counter=$((${#func_id_arr[@]}*${#ua_arr[@]}*${#fitness_arr[@]}*${#frequency_arr[@]}+${#func_id_arr[@]}*${#ua_arr[@]}))

counter=0

workers=()
for (( worker_i=0; worker_i<$worker_amount; worker_i++ )); do
  workers+=( "${DIR}/../../$((worker_i+1))Diplom/1_experiment/execute_one_experiment.sh" )
done
jobs=()
for func_id in ${func_id_arr[@]}; do
for ua in ${ua_arr[@]}; do
  for fitness in stat; do
    for frequency in 0; do
      jobs+=( "${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}" )
    done
  done

  for fitness in ${fitness_arr[@]}; do # bi pm
    for frequency in ${frequency_arr[@]}; do # 1 5 10 50 100 500 1000 5000 10000 20000 100000
      jobs+=( "${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}" )
    done
  done
done
done

printf "\n"
for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
  printf "\n"
done

for (( job_i=0; job_i<${#jobs[@]}; job_i+=${#workers[@]} )); do
  printf "\r\033[K\033[1F\033[K"
  for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
    printf "\033[1F\033[K"
  done
  printf "$((counter*100/full_counter))%%\t$counter / $full_counter\tExperimenting\n"
  for (( worker_i=0; worker_i<${#workers[@]}; worker_i++ )); do
    job=${jobs[$(( $job_i + $worker_i ))]}
    worker=${workers[$worker_i]}
    if [ -n "$job" ]; then
      ((counter++))
      $worker $job &
    fi
  done
  wait
done