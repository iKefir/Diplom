

for graph_type in best_fitness changes; do

p='../IOHProfiler/Results/experiment_3.1'

s_p='all_zips/graphs/'${graph_type}

arr=('fit_stat_0_stat' 'fit_stat_0_ab' 'fit_bi_1_stat' 'fit_bi_1_ab' 'fit_bi_5_stat' 'fit_bi_5_ab' 'fit_bi_10_stat' 'fit_bi_10_ab' 'fit_bi_50_stat' 'fit_bi_50_ab' 'fit_bi_100_stat' 'fit_bi_100_ab' 'fit_bi_500_stat' 'fit_bi_500_ab' 'fit_bi_1000_stat' 'fit_bi_1000_ab' 'fit_bi_5000_stat' 'fit_bi_5000_ab' 'fit_pm_1_stat' 'fit_pm_1_ab' 'fit_pm_5_stat' 'fit_pm_5_ab' 'fit_pm_10_stat' 'fit_pm_10_ab' 'fit_pm_50_stat' 'fit_pm_50_ab' 'fit_pm_100_stat' 'fit_pm_100_ab' 'fit_pm_500_stat' 'fit_pm_500_ab' 'fit_pm_1000_stat' 'fit_pm_1000_ab' 'fit_pm_5000_stat' 'fit_pm_5000_ab')

n_arr=()

for fun_id in 1 2 4 5 6 7 8 9 10 11 12 13 14 15 16 17; do
for elem in ${arr[@]}; do
  n_arr+=(${p}/${fun_id}/${s_p}/${elem}'.png')
done
done

# echo ${n_arr[@]}

montage -geometry 640x480 -tile 34x16 ${n_arr[@]} ${p}/merged_${graph_type}.png

done
