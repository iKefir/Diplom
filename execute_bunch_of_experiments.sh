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

# for ua in stat ab; do
#   for fitness in stat; do
#     for frequency in 0; do
#       if ! ./execute_one_experiment.sh ${fitness} ${frequency} ${ua}; then
#         exit 1
#       fi
#     done
#   done
# done

newpath="../IOHProfiler/Results/IOHExperimenter"

for ua in stat ab; do # stat ab
  for fitness in bi; do # bi pm
    for frequency in 100; do # 1 5 10 50 100 500 1000 5000 10000 20000 100000
      if ! ./execute_one_experiment.sh ${fitness} ${frequency} ${ua} 100 100 ${newpath} 2 1000; then
        exit 1
      fi
    done
  done
done

say DONE &&
echo DONE
