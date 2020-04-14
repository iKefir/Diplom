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

newpath=${DIR}/../../RunResults/$1

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
jobs=()

setup_workers(){
    for (( worker_i=0; worker_i<$worker_amount; worker_i++ )); do
        workers+=( "${DIR}/$((worker_i+1))worker/execute_one_experiment.sh" )
    done
}

generate_jobs(){
    dimension=100
    restarts=100
    budget_multiplier=6

    func_id_arr=(2) # 1 4 7 9 2 11 14 16
    ua_arr=(stat) # stat ab stat_rea ab_rea
    fitness_arr=(bi_1 bi_2 bi_3 bi_4 bi_5 pm) # stat bi pm
    frequency_arr=(5000 500 50 5)
    gamma_arr=(10 25 50 75) # 1 5 100

    for func_id in ${func_id_arr[@]}; do
        for ua in ${ua_arr[@]}; do
            for fitness in stat; do
                for frequency in 0; do
                    # jobs+=( "${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier} 0" )
                    for gamma in ${gamma_arr[@]}; do
                        jobs+=( "${fitness} ${frequency} ${ua}_rea ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier} ${gamma}" )
                    done
                done
            done

            for fitness in ${fitness_arr[@]}; do
                for frequency in ${frequency_arr[@]}; do
                    # jobs+=( "${fitness} ${frequency} ${ua} ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier} 0" )
                    for gamma in ${gamma_arr[@]}; do
                        jobs+=( "${fitness} ${frequency} ${ua}_rea ${dimension} ${restarts} ${newpath}/${func_id} ${func_id} ${budget_multiplier} ${gamma}" )
                    done
                done
            done
        done
    done
}

print_processing_info(){
    job_i=0
    worker_last_info=()
    for (( worker_i=0; worker_i<$worker_amount; worker_i++ )); do
        worker_last_info+=( "WAITING" )
        printf "\n"
    done
    printf "\n"
    while true; do
        if read line <$processing_info_pipe; then
            # printf "READ: $line\n"
            if [[ "$line" == 'tinc' ]]; then
                ((job_i++))
            else
                if IFS=',' read -r -a args <<< "$line"; then
                    worker_last_info[${args[0]}]="${args[1]}"
                fi
            fi
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

start_worker(){
    job=${jobs[$2]}
    worker=${workers[$1]}
    # printf "Worker: $worker\tJob: $job\n"
    if [ -n "$job" ]; then
        $worker $job | while read line; do echo "$1,$line" >$processing_info_pipe; done
        sleep 1
        echo "tinc" >$processing_info_pipe
        sleep 1
        echo "$1" >$pipe
    else
        echo "quit" >$pipe
    fi
}

setup_workers
generate_jobs

job_i=0
finished_workers=0

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