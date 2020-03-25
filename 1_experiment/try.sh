# /usr/bin/bash

keks=()
for let in a b c d e; do
    keks+=( "$let kek" )
done 
for (( worker_i=0; worker_i<${#keks[@]}; worker_i++ )); do
    kek=${keks[$worker_i]}
    printf $kek
    printf "\n"
done
echo ${keks[@]}
# for first second third in ${keks[@]}; do
#     print $first
#     print $second
#     print $third
# done