# /usr/bin/bash

for graph_type in best_fitness mutation_rate; do

DIR=$(dirname $0)

p=${DIR}/../../RunResults/$1

# merged stat and ab
s_p='all_zips/comb_graphs/'${graph_type}

bi_arr=('fit_stat_0' 'fit_bi_5000' 'fit_bi_500' 'fit_bi_50' 'fit_bi_5')
pm_arr=('fit_stat_0' 'fit_pm_5000' 'fit_pm_500' 'fit_pm_50' 'fit_pm_5')
fun_ids=(1 4 7 9)

n_bi_arr=()
n_pm_arr=()

for fun_id in ${fun_ids[@]}; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in ${fun_ids[@]}; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}
mkdir ${p}/${graph_type}/OM
mkdir ${p}/${graph_type}/OM/merged
montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_bi_arr[@]} ${p}/${graph_type}/OM/merged/OM_bi_${graph_type}.png
montage -geometry 1280x960 -tile ${#pm_arr[@]}x${#fun_ids[@]} ${n_pm_arr[@]} ${p}/${graph_type}/OM/merged/OM_pm_${graph_type}.png

fun_ids=(2 11 14 16)
n_bi_arr=()
n_pm_arr=()

for fun_id in ${fun_ids[@]}; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in ${fun_ids[@]}; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}/LO
mkdir ${p}/${graph_type}/LO/merged
montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_bi_arr[@]} ${p}/${graph_type}/LO/merged/LO_bi_${graph_type}.png
montage -geometry 1280x960 -tile ${#pm_arr[@]}x${#fun_ids[@]} ${n_pm_arr[@]} ${p}/${graph_type}/LO/merged/LO_pm_${graph_type}.png

done
