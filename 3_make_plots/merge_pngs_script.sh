

for graph_type in best_fitness changes mutation_rate; do

p='1_experiment/RunResults/experiment_4.5'

s_p='all_zips/graphs/'${graph_type}

# bi_arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_bi_1_stat' 'fit_bi_1_ab' 'fit_bi_5_stat' 'fit_bi_5_ab' 'fit_bi_10_stat' 'fit_bi_10_ab' 'fit_bi_50_stat' 'fit_bi_50_ab' 'fit_bi_100_stat' 'fit_bi_100_ab' 'fit_bi_500_stat' 'fit_bi_500_ab' 'fit_bi_1000_stat' 'fit_bi_1000_ab' 'fit_bi_5000_stat' 'fit_bi_5000_ab')
# pm_arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_pm_1_stat' 'fit_pm_1_ab' 'fit_pm_5_stat' 'fit_pm_5_ab' 'fit_pm_10_stat' 'fit_pm_10_ab' 'fit_pm_50_stat' 'fit_pm_50_ab' 'fit_pm_100_stat' 'fit_pm_100_ab' 'fit_pm_500_stat' 'fit_pm_500_ab' 'fit_pm_1000_stat' 'fit_pm_1000_ab' 'fit_pm_5000_stat' 'fit_pm_5000_ab')
bi_arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_bi_5_stat' 'fit_bi_5_ab' 'fit_bi_50_stat' 'fit_bi_50_ab' 'fit_bi_500_stat' 'fit_bi_500_ab' 'fit_bi_5000_stat' 'fit_bi_5000_ab')
pm_arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_pm_5_stat' 'fit_pm_5_ab' 'fit_pm_50_stat' 'fit_pm_50_ab' 'fit_pm_500_stat' 'fit_pm_500_ab' 'fit_pm_5000_stat' 'fit_pm_5000_ab')

n_bi_arr=()
n_pm_arr=()

for fun_id in 1 4 7 9; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in 1 4 7 9; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}
mkdir ${p}/${graph_type}/OM
mkdir ${p}/${graph_type}/OM/distinct
montage -geometry 1280x960 -tile 12x4 ${n_bi_arr[@]} ${p}/${graph_type}/OM/distinct/OM_bi_${graph_type}.png
montage -geometry 1280x960 -tile 12x4 ${n_pm_arr[@]} ${p}/${graph_type}/OM/distinct/OM_pm_${graph_type}.png

n_bi_arr=()
n_pm_arr=()

for fun_id in 2 11 14 16; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in 2 11 14 16; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}/LO
mkdir ${p}/${graph_type}/LO/distinct
montage -geometry 1280x960 -tile 12x4 ${n_bi_arr[@]} ${p}/${graph_type}/LO/distinct/LO_bi_${graph_type}.png
montage -geometry 1280x960 -tile 12x4 ${n_pm_arr[@]} ${p}/${graph_type}/LO/distinct/LO_pm_${graph_type}.png

# merged stat and ab
s_p='all_zips/comb_graphs/'${graph_type}

# bi_arr=('fit_stat_0' 'fit_bi_5000' 'fit_bi_1000' 'fit_bi_500' 'fit_bi_100' 'fit_bi_50' 'fit_bi_10' 'fit_bi_5' 'fit_bi_1')
# pm_arr=('fit_stat_0' 'fit_pm_5000' 'fit_pm_1000' 'fit_pm_500' 'fit_pm_100' 'fit_pm_50' 'fit_pm_10' 'fit_pm_5' 'fit_pm_1')
bi_arr=('fit_stat_0' 'fit_bi_5000' 'fit_bi_500' 'fit_bi_50' 'fit_bi_5')
pm_arr=('fit_stat_0' 'fit_pm_5000' 'fit_pm_500' 'fit_pm_50' 'fit_pm_5')
# bi_arr=('fit_stat_0' 'fit_bi_1000' 'fit_bi_100' 'fit_bi_10')
# pm_arr=('fit_stat_0' 'fit_pm_1000' 'fit_pm_100' 'fit_pm_10')
# fun_ids=(1)
fun_ids=(1 4 7 9)
# fun_ids=(5 6 8 10)
# fun_ids=(4 5 6 7 8 9 10)

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

mkdir ${p}/${graph_type}/OM/merged
montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_bi_arr[@]} ${p}/${graph_type}/OM/merged/OM_bi_${graph_type}.png
montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_pm_arr[@]} ${p}/${graph_type}/OM/merged/OM_pm_${graph_type}.png
# montage -geometry 1280x960 -tile 2x2 ${n_bi_arr[@]} ${p}/${graph_type}/OM/merged/OM_bi_${graph_type}.png
# montage -geometry 1280x960 -tile 2x2 ${n_pm_arr[@]} ${p}/${graph_type}/OM/merged/OM_pm_${graph_type}.png
# fun_ids=(2)
fun_ids=(2 11 14 16)
# fun_ids=(12 13 15 17)
# fun_ids=(11 12 13 14 15 16 17)
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

mkdir ${p}/${graph_type}/LO/merged
montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_bi_arr[@]} ${p}/${graph_type}/LO/merged/LO_bi_${graph_type}.png
montage -geometry 1280x960 -tile ${#bi_arr[@]}x${#fun_ids[@]} ${n_pm_arr[@]} ${p}/${graph_type}/LO/merged/LO_pm_${graph_type}.png
# montage -geometry 1280x960 -tile 2x2 ${n_bi_arr[@]} ${p}/${graph_type}/LO/merged/LO_bi_${graph_type}.png
# montage -geometry 1280x960 -tile 2x2 ${n_pm_arr[@]} ${p}/${graph_type}/LO/merged/LO_pm_${graph_type}.png

done
