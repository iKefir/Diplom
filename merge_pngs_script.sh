

for graph_type in best_fitness changes; do

p='../IOHProfiler/Results/experiment_3.1'

s_p='all_zips/graphs/'${graph_type}

bi_arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_bi_1_stat' 'fit_bi_1_ab' 'fit_bi_5_stat' 'fit_bi_5_ab' 'fit_bi_10_stat' 'fit_bi_10_ab' 'fit_bi_50_stat' 'fit_bi_50_ab' 'fit_bi_100_stat' 'fit_bi_100_ab' 'fit_bi_500_stat' 'fit_bi_500_ab' 'fit_bi_1000_stat' 'fit_bi_1000_ab' 'fit_bi_5000_stat' 'fit_bi_5000_ab')
pm_arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_pm_1_stat' 'fit_pm_1_ab' 'fit_pm_5_stat' 'fit_pm_5_ab' 'fit_pm_10_stat' 'fit_pm_10_ab' 'fit_pm_50_stat' 'fit_pm_50_ab' 'fit_pm_100_stat' 'fit_pm_100_ab' 'fit_pm_500_stat' 'fit_pm_500_ab' 'fit_pm_1000_stat' 'fit_pm_1000_ab' 'fit_pm_5000_stat' 'fit_pm_5000_ab')

n_bi_arr=()
n_pm_arr=()

for fun_id in 1 4 5 6 7 8 9 10; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in 1 4 5 6 7 8 9 10; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}
mkdir ${p}/${graph_type}/OM
mkdir ${p}/${graph_type}/OM/distinct
montage -geometry 640x480 -tile 18x8 ${n_bi_arr[@]} ${p}/${graph_type}/OM/distinct/bi.png
montage -geometry 640x480 -tile 18x8 ${n_pm_arr[@]} ${p}/${graph_type}/OM/distinct/pm.png

n_bi_arr=()
n_pm_arr=()

for fun_id in 2 11 12 13 14 15 16 17; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in 2 11 12 13 14 15 16 17; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}/LO
mkdir ${p}/${graph_type}/LO/distinct
montage -geometry 640x480 -tile 18x8 ${n_bi_arr[@]} ${p}/${graph_type}/LO/distinct/bi.png
montage -geometry 640x480 -tile 18x8 ${n_pm_arr[@]} ${p}/${graph_type}/LO/distinct/pm.png

# merged stat and ab
s_p='all_zips/comb_graphs/'${graph_type}

bi_arr=('fit_stat_0' 'fit_bi_1' 'fit_bi_5' 'fit_bi_10' 'fit_bi_50' 'fit_bi_100' 'fit_bi_500' 'fit_bi_1000' 'fit_bi_5000')
pm_arr=('fit_stat_0' 'fit_pm_1' 'fit_pm_5' 'fit_pm_10' 'fit_pm_50' 'fit_pm_100' 'fit_pm_500' 'fit_pm_1000' 'fit_pm_5000')

n_bi_arr=()
n_pm_arr=()

for fun_id in 1 4 5 6 7 8 9 10; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in 1 4 5 6 7 8 9 10; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}/OM/merged
montage -geometry 640x480 -tile 9x8 ${n_bi_arr[@]} ${p}/${graph_type}/OM/merged/bi.png
montage -geometry 640x480 -tile 9x8 ${n_pm_arr[@]} ${p}/${graph_type}/OM/merged/pm.png

n_bi_arr=()
n_pm_arr=()

for fun_id in 2 11 12 13 14 15 16 17; do
for elem in ${bi_arr[@]}; do
  n_bi_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

for fun_id in 2 11 12 13 14 15 16 17; do
for elem in ${pm_arr[@]}; do
  n_pm_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

mkdir ${p}/${graph_type}/LO/merged
montage -geometry 640x480 -tile 9x8 ${n_bi_arr[@]} ${p}/${graph_type}/LO/merged/bi.png
montage -geometry 640x480 -tile 9x8 ${n_pm_arr[@]} ${p}/${graph_type}/LO/merged/pm.png

done
