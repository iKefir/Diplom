void get_default_permutation(int *permutation, const size_t dimension) {
  for (size_t i = 0; i < dimension; ++i) {
    permutation[i] = i;
  }
}

void get_default_target_function(int *target_function, const size_t dimension) {
  for (size_t i = 0; i < dimension; ++i) {
    target_function[i] = 1;
  }
}

size_t get_next_budget(size_t i) {
    if (FITNESS_CHANGE_FREQUENCY) {
      return ((i / FITNESS_CHANGE_FREQUENCY) + 1) * FITNESS_CHANGE_FREQUENCY;
    }
    return 50001;
}

int change_fitness_function(int *permutation,
                             int *target_function,
                             const size_t dimension,
                             enum Change_type c_t,
                             IOHprofiler_random_state_t *random_generator){
  if (c_t == NO_CHANGE) {
    return 0;
  }
  if (c_t == BIT_INVERT) {
    int flip_index = dimension;
    while (flip_index >= dimension) {
      flip_index = (int)(IOHprofiler_random_uniform(random_generator) * dimension); // if generates from 0 to 100 - have to deal with 100
    }
    target_function[flip_index] = (target_function[flip_index] + 1) % 2;
    return 1;
  }
  if (c_t == PERMUTATION) {
    int rand_ind = dimension;
    int tmp;
    for (int i = dimension - 1; i > -1; --i) {
        while (rand_ind >= dimension) {
          rand_ind = (int)(IOHprofiler_random_uniform(random_generator) * dimension); // if generates from 0 to 100 - have to deal with 100
        }
        tmp = permutation[i];
        permutation[i] = permutation[rand_ind];
        permutation[rand_ind] = tmp;
    }
    return 1;
  }
}

void apply_fitness_function_change_to_individual(int *individual,
                                                 int *individual_to_send,
                                                 int *permutation,
                                                 int *target_function,
                                                 const size_t dimension) {
  size_t i;
  for (i = 0; i < dimension; ++i) {
    individual_to_send[permutation[i]] = individual[i];
  }
  for (i = 0; i < dimension; ++i) {
    individual_to_send[i] = (individual_to_send[i] + (1 - target_function[i])) % 2;
  }
}
