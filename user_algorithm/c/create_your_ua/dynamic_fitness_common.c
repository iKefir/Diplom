void get_default_permutation(int *permutation, const size_t dimension) {
  for (size_t i = 0; i < dimension; ++i) {
    permutation[i] = i;
  }
}

void get_default_target_function(int *target_function, const size_t dimension, IOHprofiler_random_state_t *random_generator) {
  for (size_t i = 0; i < dimension; ++i) {
    if (IOHprofiler_random_uniform(random_generator) > 0.5) {
      target_function[i] = 1;
    } else {
      target_function[i] = 0;
    }
  }
}

size_t get_next_budget(size_t i, IOHprofiler_random_state_t *random_generator) {
    if (FITNESS_CHANGE_FREQUENCY == 0) {
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
    // FILE * fp;
    // fp = fopen ("/Users/danil.shkarupin/Study/permlog.txt","a");
    // fprintf (fp, "Random called\n");
    // fclose (fp);
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
    individual_to_send[i] = target_function[permutation[i]];
  }
  for (i = 0; i < dimension; ++i) {
    individual_to_send[i] = (individual[i] + (1 - individual_to_send[i])) % 2;
  }
}
