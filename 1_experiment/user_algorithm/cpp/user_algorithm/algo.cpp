
#include <cstdio>
#include <algorithm>

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
    size_t number_of_parameters = 3;
    size_t dimension = problem->IOHprofiler_get_number_of_variables();
    std::vector<int> parent(dimension);
    std::vector<int> offspring(dimension);
    std::vector<int> offspring_to_send(dimension);
    std::vector<int> permutation = get_default_permutation(dimension);
    std::vector<int> target_function = get_default_target_function(dimension);
    std::vector<int> best(dimension);
    double parent_value;
    double *best_value = new double(1);
    *best_value = 0.0;
    double y;

    size_t l;
    double *mutation_rate = new double(1);
    *mutation_rate = 1 / (double)dimension;
#ifdef STATMIN
    *mutation_rate = 1 / ((double)dimension * (double)dimension);
#endif
    double min_mutation_rate = 1 / ((double)dimension * (double)dimension);
    int max_budget = BUDGET_MULTIPLIER * dimension * dimension;

    int is_fitness_changed;
    l = 0;

    int should_change_fitness = 0;
    int next_budget_to_change_fitness = get_next_budget(0);
    int times_got_improvement = 0;

    double *n_b_t_c_f = new double(1);
    *n_b_t_c_f = (double)next_budget_to_change_fitness + 1.0;

    std::vector<std::shared_ptr<double>> parameters;
    parameters.push_back(std::shared_ptr<double>(best_value));
    parameters.push_back(std::shared_ptr<double>(mutation_rate));
    parameters.push_back(std::shared_ptr<double>(n_b_t_c_f));
    std::vector<std::string> parameters_name;
    parameters_name.push_back("best_value");
    parameters_name.push_back("mutation_rate");
    parameters_name.push_back("next_budget_to_change_fitness");
    logger->set_parameters(parameters, parameters_name);

    parent = generatingIndividual(dimension);
    offspring_to_send = apply_fitness_function_change_to_individual(parent, permutation, target_function, dimension);
    y = problem->evaluate(offspring_to_send);
    logger->write_line(problem->loggerInfo());

    best = parent;
    parent_value = y;
    *best_value = y;

    size_t count = 1;
    while (count <= max_budget)
    {
        if (next_budget_to_change_fitness <= count)
        {
            should_change_fitness = 1;
            next_budget_to_change_fitness = get_next_budget(count);
            *n_b_t_c_f = (double)next_budget_to_change_fitness + 1.0;
        }
        if (should_change_fitness)
        {
            is_fitness_changed = change_fitness_function(permutation, target_function, dimension, CHANGE_TYPE);

            if (is_fitness_changed)
            {
                *best_value = -1.0;
            }

            if (is_fitness_changed)
            {
                offspring_to_send = apply_fitness_function_change_to_individual(parent, permutation, target_function, dimension);
                y = problem->evaluate(offspring_to_send);
                logger->write_line(problem->loggerInfo());
                parent_value = y;
                *best_value = y;
                ++count;
                if (count == max_budget)
                {
                    break;
                }
            }

            should_change_fitness = 0;
        }
        for (size_t j = 0; j < lambda; ++j)
        {

            offspring = parent;
            l = mutateIndividual(offspring, dimension, *mutation_rate);

            offspring_to_send = apply_fitness_function_change_to_individual(offspring, permutation, target_function, dimension);
            y = problem->evaluate(offspring_to_send);
            logger->write_line(problem->loggerInfo());

            if (y >= parent_value)
            {
#if defined(AB) || defined(ABOPT)
                times_got_improvement += 1;
#endif
#ifdef ABSTRICTINEQUALITY
                if (y > parent_value) {
                    times_got_improvement += 1;
                }
#endif
                if (y >= *best_value)
                {
                    *best_value = y;
                    best = offspring;
                }
            }

            ++count;
            if (count == max_budget)
            {
                break;
            }
            // if (*best_value == dimension) {
            //   break;
            // }
        }

#if defined(AB) || defined(ABSTRICTINEQUALITY)
        if (times_got_improvement >= 0.05 * lambda)
        {
            *mutation_rate *= 2;
        }
        else
        {
            *mutation_rate *= 0.5;
        }
        *mutation_rate = std::max(std::min(*mutation_rate, 0.5), min_mutation_rate);
        times_got_improvement = 0;
#endif
#ifdef ABOPT
        if (times_got_improvement >= 0.05 * lambda)
        {
            *mutation_rate *= 1.683748678554;
        }
        else
        {
            *mutation_rate /= 1.5;
        }
        *mutation_rate = std::max(std::min(*mutation_rate, 0.5), min_mutation_rate);
        times_got_improvement = 0;
#endif
#ifdef ABOPTOPT
        if (times_got_improvement >= 0.05 * lambda)
        {
            *mutation_rate *= 1.0647024398898608;
        }
        else
        {
            *mutation_rate /= 1.05;
        }
        *mutation_rate = std::max(std::min(*mutation_rate, 0.5), min_mutation_rate);
        times_got_improvement = 0;
#endif
        parent_value = *best_value;
        parent = best;

        // if (*best_value == dimension) {
        //   break;
        // }
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
