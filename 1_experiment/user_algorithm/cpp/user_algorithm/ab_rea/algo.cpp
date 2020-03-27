
#include <cstdio>
#include <algorithm>

int hamming_distance(std::vector<int> first, std::vector<int> second) {
    int counter = 0;
    for (int i = 0; i < first.size() && i < second.size(); ++i) {
        if (first[i] != second[i]) {
            ++counter;
        }
    }
    return counter;
}

int uniform_choose(int elems_count)
{
    double measure = 1.0 / (2 * elems_count);
    double random_number = random_generator.IOHprofiler_uniform_rand();
    for (int i = 1; i <= 2 * elems_count; ++i)
    {
        if (random_number < measure * i)
        {
            return i - 1;
        }
    }
    return 2 * elems_count - 1;
}

double evaluate(std::shared_ptr<IOHprofiler_problem<int>> problem,
                std::shared_ptr<IOHprofiler_csv_logger> logger,
                std::vector<int> offspring,
                std::vector<int> permutation,
                std::vector<int> target_function,
                size_t dimension)
{
    std::vector<int> offspring_to_send = apply_fitness_function_change_to_individual(offspring, permutation, target_function, dimension);
    double y = problem->evaluate(offspring_to_send);
    logger->write_line(problem->loggerInfo());
    return y;
}

/**
 * An user defined algorithm.
 *
 * @param "evaluate" The function for evaluating variables' fitness. Invoking the
 *        statement "evaluate(x,y)", then the fitness of 'x' will be stored in 'y'.
 * @param "dimension" The dimension of problem.
 * @param "number_of_objectives" The number of objectives. The default is 1.
 * @param "lower_bounds" The lower bounds of the region of interested (a vector containing dimension values).
 * @param "upper_bounds" The upper bounds of the region of interested (a vector containing dimension values).
 * @param "max_budget" The maximal number of evaluations. You can set it by BUDGET_MULTIPLIER in "config" file.
 * @param "random_generator" Pointer to a random number generator able to produce uniformly and normally
 * distributed random numbers. You can set it by RANDOM_SEED in "config" file
 */
void evolutionary_algorithm(std::shared_ptr<IOHprofiler_problem<int>> problem,
                            std::shared_ptr<IOHprofiler_csv_logger> logger)
{
    size_t dimension = problem->IOHprofiler_get_number_of_variables();
    std::vector<int> parent(dimension);
    std::vector<int> offspring(dimension);
    std::vector<int> permutation = get_default_permutation(dimension);
    std::vector<int> target_function = get_default_target_function(dimension);
    std::vector<int> best(dimension);
    double *best_value = new double(1);
    *best_value = 0.0;
    double y;

    size_t l;
    double *mutation_rate = new double(1);
    *mutation_rate = 1 / (double)dimension;
    double min_mutation_rate = 1 / ((double)dimension * (double)dimension);
    int max_budget = BUDGET_MULTIPLIER * dimension * dimension;

    int is_fitness_changed;
    l = 0;

    bool should_change_fitness = false;
    int next_budget_to_change_fitness = get_next_budget(0);
    int times_got_improvement = 0;

    double *n_b_t_c_f = new double(1);
    *n_b_t_c_f = (double)next_budget_to_change_fitness + 1.0;

    // rea values
    bool rea_mode_on = false;
    double *r_m_on = new double(1);
    *r_m_on = (double)rea_mode_on;
    int gamma = 1;
    int h_dist;
    std::vector<int> old_best(dimension);
    double old_best_value = *best_value;
    std::vector<std::vector<int>> best_solution_for_distance;
    std::vector<double> best_fitness_for_solution_for_distance;

    std::vector<std::shared_ptr<double>> parameters;
    parameters.push_back(std::shared_ptr<double>(best_value));
    parameters.push_back(std::shared_ptr<double>(mutation_rate));
    parameters.push_back(std::shared_ptr<double>(n_b_t_c_f));
    parameters.push_back(std::shared_ptr<double>(r_m_on));
    std::vector<std::string> parameters_name;
    parameters_name.push_back("best_value");
    parameters_name.push_back("mutation_rate");
    parameters_name.push_back("next_budget_to_change_fitness");
    parameters_name.push_back("is_rea_working");
    logger->set_parameters(parameters, parameters_name);

    parent = generatingIndividual(dimension);
    y = evaluate(problem, logger, parent, permutation, target_function, dimension);

    best = parent;
    *best_value = y;

    size_t count = 1;
    while (count <= max_budget)
    {
        if (next_budget_to_change_fitness <= count)
        {
            should_change_fitness = true;
            next_budget_to_change_fitness = get_next_budget(count);
            *n_b_t_c_f = (double)next_budget_to_change_fitness + 1.0;
        }
        if (should_change_fitness)
        {
            is_fitness_changed = change_fitness_function(permutation, target_function, dimension, CHANGE_TYPE);

            if (is_fitness_changed)
            {
                // init rea here
                rea_mode_on = true;
                *r_m_on = (double)rea_mode_on;
                old_best = best;
                old_best_value = *best_value;
                *best_value = evaluate(problem, logger, best, permutation, target_function, dimension);
                ++count;
                if (count == max_budget)
                {
                    break;
                }
                best_solution_for_distance = {best};
                best_fitness_for_solution_for_distance = {*best_value};
                for (int rea_count = 0; rea_count < gamma + 1; ++rea_count)
                {
                    best_solution_for_distance.push_back({-1});
                    best_fitness_for_solution_for_distance.push_back(-1.0);
                }
            }

            should_change_fitness = false;
        }

        // choose parent for rea
        if (rea_mode_on)
        {
            int solutions_count = 0;
            for (int rea_count = 0; rea_count < best_solution_for_distance.size(); ++rea_count)
            {
                if (best_solution_for_distance[rea_count].size() == dimension)
                {
                    ++solutions_count;
                }
            }
            int parent_index = uniform_choose(solutions_count);
            if (parent_index < solutions_count)
            {
                int passed_solutions_count = 0;
                for (int rea_count = 0; rea_count < best_solution_for_distance.size(); ++rea_count)
                {
                    if (best_solution_for_distance[rea_count].size() == dimension)
                    {
                        ++passed_solutions_count;
                        if (passed_solutions_count - 1 == parent_index)
                        {
                            parent = best_solution_for_distance[rea_count];
                        }
                    }
                }
            }
            else
            {
                parent = best;
            }
        }
        offspring = parent;
        l = mutateIndividual(offspring, dimension, *mutation_rate);

        y = evaluate(problem, logger, offspring, permutation, target_function, dimension);

        if (y >= *best_value)
        {
            times_got_improvement += 1;
            best = offspring;
            *best_value = y;
        }

        ++count;
        if (count == max_budget)
        {
            break;
        }
        
        if (rea_mode_on)
        {
            h_dist = hamming_distance(old_best, offspring);
            h_dist = std::min(h_dist, gamma + 1);

            if (y >= best_fitness_for_solution_for_distance[h_dist])
            {
                best_solution_for_distance[h_dist] = offspring;
                best_fitness_for_solution_for_distance[h_dist] = y;
            }

            if (*best_value >= old_best_value) {
                rea_mode_on = false;
                *r_m_on = (double)rea_mode_on;
            }
        }

        if (times_got_improvement == 1)
        {
            *mutation_rate *= 2;
        }
        else
        {
            *mutation_rate *= 0.5;
        }
        *mutation_rate = std::max(std::min(*mutation_rate, 0.5), min_mutation_rate);
        times_got_improvement = 0;
        parent = best;
    }
}

void _run_experiment()
{
    std::string configName = "./configuration.ini";

    IOHprofiler_experimenter<int> experimenter(configName, evolutionary_algorithm);

    experimenter._set_independent_runs(INDEPENDENT_RESTARTS);
    experimenter._run();
}

int main()
{
    _run_experiment();
    return 0;
}
