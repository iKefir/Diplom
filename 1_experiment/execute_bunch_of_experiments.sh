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

# ./execute_one_experiment.sh bi 1000 stat &&
# ./execute_one_experiment.sh bi 1000 ab &&

DIR=$(dirname $0)

newpath=${DIR}/../../1Diplom/1_experiment/RunResults/experiment_4.5

dimension=100
restarts=100
budget_multiplier=6

func_id_arr=(1 4 7 9 2 11 14 16) # 1 4 7 9 2 11 14 16
ua_arr=(ab abopt aboptopt)
fitness_arr=(bi pm)
frequency_arr=(5000 500 50 5)

full_counter=$((${#func_id_arr[@]}*${#ua_arr[@]}*${#fitness_arr[@]}*${#frequency_arr[@]}+${#func_id_arr[@]}*${#ua_arr[@]}))

counter=0

printf "\n"

for func_id in ${func_id_arr[@]}; do
for ua in ${ua_arr[@]}; do
  for fitness in stat; do
    for frequency in 0; do
      printf "\r\033[K\033[1F\033[K$((counter*100/full_counter))%%\t$counter / $full_counter\tExperimenting\n"
      ((counter++))
      if ! ${DIR}/execute_one_experiment.sh ${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}; then
        exit 1
      fi
    done
  done

  for fitness in ${fitness_arr[@]}; do # bi pm
    for frequency in ${frequency_arr[@]}; do # 1 5 10 50 100 500 1000 5000 10000 20000 100000
      printf "\r\033[K\033[1F\033[K$((counter*100/full_counter))%%\t$counter / $full_counter\tExperimenting\n"
      ((counter++))
      if ! ${DIR}/execute_one_experiment.sh ${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}; then
        exit 1
      fi
    done
  done
done
done

printf "\r\033[K\033[1F\033[K$((counter*100/full_counter))%%\t$counter / $full_counter\tExperimenting\n"
printf "DONE\n"
