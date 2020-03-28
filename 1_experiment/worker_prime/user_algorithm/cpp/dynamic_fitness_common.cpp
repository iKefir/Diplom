std::vector<int> get_default_permutation(const size_t dimension)
{
    std::vector<int> permutation(dimension);
    for (size_t i = 0; i < dimension; ++i)
    {
        permutation[i] = i;
    }
    return permutation;
}

std::vector<int> get_default_target_function(const size_t dimension)
{
    std::vector<int> target_function(dimension);
    for (size_t i = 0; i < dimension; ++i)
    {
        if (random_generator.IOHprofiler_uniform_rand() > 0.5)
        {
            target_function[i] = 1;
        }
        else
        {
            target_function[i] = 0;
        }
    }
    return target_function;
}

size_t get_next_budget(size_t i)
{
    if (FITNESS_CHANGE_FREQUENCY == 0)
    {
        return 100000009;
    }
    // Here FITNESS_CHANGE_FREQUENCY is actually amount of evaluations during which fitness is unchanged
    return ((i / FITNESS_CHANGE_FREQUENCY) + 1) * FITNESS_CHANGE_FREQUENCY;

    // Here FITNESS_CHANGE_FREQUENCY is probability and we change fitness with probability 1 / FITNESS_CHANGE_FREQUENCY
    // double prob = 1.0 / FITNESS_CHANGE_FREQUENCY;
    // size_t count = 2;
    // while (IOHprofiler_random_uniform(random_generator) > prob) {
    //   ++count;
    // }
    // return i + count;
    // double prob = 1.0 / FITNESS_CHANGE_FREQUENCY;
    // size_t count = 2;
    // double next_rand = IOHprofiler_random_uniform(random_generator);
    // double to_add = floor(log(next_rand) / log(1.0 - prob));
    // return i + count + to_add;
}

bool change_fitness_function(std::vector<int> &permutation,
                             std::vector<int> &target_function,
                             const size_t dimension,
                             const enum Change_type c_t)
{
    if (c_t == BIT_INVERT)
    {
        int flip_index = dimension;
        while (flip_index >= dimension)
        {
            flip_index = (int)(random_generator.IOHprofiler_uniform_rand() * dimension); // if generates from 0 to 100 - have to deal with 100
        }
        target_function[flip_index] = (target_function[flip_index] + 1) % 2;
        return true;
    }
    if (c_t == PERMUTATION)
    {
        int rand_ind = dimension;
        for (int i = dimension - 1; i > -1; --i)
        {
            while (rand_ind >= dimension)
            {
                rand_ind = (int)(random_generator.IOHprofiler_uniform_rand() * dimension); // if generates from 0 to 100 - have to deal with 100
            }
            std::swap(permutation[i], permutation[rand_ind]);
        }
        return true;
    }
    // c_t == NO_CHANGE
    return false;
}

std::vector<int> apply_fitness_function_change_to_individual(std::vector<int> const &individual,
                                                              std::vector<int> const &permutation,
                                                              std::vector<int> const &target_function,
                                                              const size_t dimension)
{
    std::vector<int> individual_to_send(dimension);
    for (size_t i = 0; i < dimension; ++i)
    {
        individual_to_send[i] = (individual[permutation[i]] + (1 - target_function[permutation[i]])) % 2;
    }
    return individual_to_send;
}
