/**
 * To generate individuals randomly. Elements of a bit-string is generated by a standard Uniform distribution.
 */
std::vector<int> generatingIndividual(const size_t dimension)
{
    std::vector<int> individuals(dimension);
    for (size_t i = 0; i < dimension; ++i)
    {
        individuals[i] = (int)(random_generator.IOHprofiler_uniform_rand() * 2);
    }
    return individuals;
}

/**
 * To sample a random value by a Binomial distribution with "n" trials and a given "probability".
 */
size_t randomBinomial(size_t n, double probability)
{
    size_t r;
    r = 0;
    for (size_t i = 0; i < n; ++i)
    {
        if (random_generator.IOHprofiler_uniform_rand() < probability)
        {
            ++r;
        }
    }
    return r;
}

/**
 * Mutation Operator.
 * "l" is the number of bits to be flipped, which is sample by Binomial distribution.
 * "l" positions are randomly selected by a uniform distribution.
 * A resampling strategy is applied to make sure that "l" is larger than 0.
 */
size_t mutateIndividual(std::vector<int> &individual,
                        const size_t dimension,
                        double mutation_rate)
{
    size_t l;
    int flag, temp;

    l = 1;

    std::vector<int> flip(l);
    for (size_t i = 0; i < l; ++i)
    {
        while (1)
        {
            flag = 0;
            temp = (int)(random_generator.IOHprofiler_uniform_rand() * dimension);
            for (size_t h = 0; h < i; ++h)
            {
                if (temp == flip[h])
                {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0)
                break;
        }
        flip[i] = temp;
    }

    for (size_t i = 0; i < l; ++i)
    {
        individual[flip[i]] = (individual[flip[i]] + 1) % 2;
    }
    return l;
}
