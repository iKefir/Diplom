# /usr/bin/bash

if [ "$#" -eq 0 ]; then
  echo >&2 "Missing experiment name argument"
  exit 1
fi

DIR=$(dirname $0)
p=${DIR}/../../RunResults/$1

for graph_type in best_fitness; do # mutation_rate

# merged stat and ab
s_p="all_zips/comb_graphs/"${graph_type}
# bi_arr=("fit_stat_0" "fit_bi_5000" "fit_bi_500" "fit_bi_50" "fit_bi_5")
# pm_arr=("fit_stat_0" "fit_pm_5000" "fit_pm_500" "fit_pm_50" "fit_pm_5")
bi_arr=("fit_stat_0" "fit_bi_100" "fit_bi_50")
fun_ids=(1 4 7 9)

n_bi_arr=()
n_pm_arr=()

for fun_id in ${fun_ids[@]}; do
    for elem in ${bi_arr[@]}; do
        n_bi_arr+=("${p}/${fun_id}/${s_p}/${elem}.png")
    done
done

for fun_id in ${fun_ids[@]}; do
    for elem in ${pm_arr[@]}; do
        n_pm_arr+=("${p}/${fun_id}/${s_p}/${elem}.png")
    done
done

mkdir ${p}/${graph_type}
mkdir ${p}/${graph_type}/OM
mkdir ${p}/${graph_type}/OM/merged
# montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_bi_arr[@]} ${p}/${graph_type}/OM/merged/OM_bi_${graph_type}.png
# montage -geometry 1280x960 -tile ${#pm_arr[@]}x${#fun_ids[@]} ${n_pm_arr[@]} ${p}/${graph_type}/OM/merged/OM_pm_${graph_type}.png

bi_arr=("fit_stat_0" "fit_bi_100" "fit_bi_50")
dyn_arr=("_bi_1" "_bi_2" "_bi_3" "_bi_4" "_bi_5" "_pm")
freq_arr=("_5000" "_500" "_50" "_5")

dyn_arr=("_bi_1_5" "_bi_1_50" "_bi_1_500" "_bi_5_5" "_bi_5_50" "_bi_5_500")
gamma_arr=("1_" "3_" "5_" "10_")

fun_ids=(2)
n_bi_arr=()
n_pm_arr=()

for fun_id in ${fun_ids[@]}; do
    for elem in ${bi_arr[@]}; do
        n_bi_arr+=("${p}/${fun_id}/${s_p}/${elem}.png")
    done
done

for fun_id in ${fun_ids[@]}; do
    for elem in ${pm_arr[@]}; do
        n_pm_arr+=("${p}/${fun_id}/${s_p}/${elem}.png")
    done
done

n_arr=()
# for dyn in ${dyn_arr[@]}; do
#     n_arr+=("${p}/2/${s_p}/fit_stat_0.png")
#     for fr in ${freq_arr[@]}; do
#         n_arr+=("${p}/2/${s_p}/fit${dyn}${fr}.png")
#     done
# done
for gm in ${gamma_arr[@]}; do
    for dyn in ${dyn_arr[@]}; do
        n_arr+=("${p}/2/${s_p}/${gm}fit${dyn}.png")
    done
done

mkdir ${p}/${graph_type}/LO
mkdir ${p}/${graph_type}/LO/merged
# montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_bi_arr[@]} ${p}/${graph_type}/LO/merged/LO_bi_${graph_type}.png
# montage -geometry 1280x960 -tile ${#pm_arr[@]}x${#fun_ids[@]} ${n_pm_arr[@]} ${p}/${graph_type}/LO/merged/LO_pm_${graph_type}.png
# montage -geometry 1280x1440 -tile 5x6 ${n_arr[@]} ${p}/${graph_type}/LO/merged/LO_${graph_type}.png
montage -geometry 1280x1440 -tile 6x4 ${n_arr[@]} ${p}/${graph_type}/LO/merged/LO_${graph_type}.png

done
