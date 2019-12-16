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

newpath=${DIR}/RunResults/experiment_3.1

dimension=100
restarts=100
# func_id=4
budget_multiplier=500

full_counter=0
for func_id in 4; do
for ua in stat ab; do
  for fitness in stat; do
    for frequency in 0; do
      ((full_counter++))
    done
  done
done
for ua in stat ab; do # stat ab
  for fitness in bi pm; do # bi pm
    for frequency in 1 5 10 50 100 500 1000 5000; do # 1 5 10 50 100 500 1000 5000 10000 20000 100000
      ((full_counter++))
    done
  done
done
done

counter=0

printf "\n"

for func_id in 4; do
for ua in stat ab; do
  for fitness in stat; do
    for frequency in 0; do
      printf "\r\033[K\033[1F\033[K$((counter*100/full_counter))%%\t$counter / $full_counter\tExperimenting\n"
      ((counter++))
      if ! ${DIR}/execute_one_experiment.sh ${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier}; then
        exit 1
      fi
    done
  done
done

for ua in stat ab; do # stat ab
  for fitness in bi pm; do # bi pm
    for frequency in 1 5 10 50 100 500 1000 5000; do # 1 5 10 50 100 500 1000 5000 10000 20000 100000
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
