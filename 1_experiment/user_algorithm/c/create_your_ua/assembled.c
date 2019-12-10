#define AB

static const size_t INDEPENDENT_RESTARTS =  100 ;

static const size_t BUDGET_MULTIPLIER =  500 ;

/**
 * The random seed. Change it if needed.
 */
static const uint32_t RANDOM_SEED = 1;

/**
 * Amount of offsprings in every generation.
 */
static int lambda = 1;

enum Change_type {
  NO_CHANGE,
  BIT_INVERT,
  PERMUTATION
};
static const enum Change_type CHANGE_TYPE = PERMUTATION;
static const int FITNESS_CHANGE_FREQUENCY = 500;

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
  // for (i = 0; i < dimension; ++i) {
  //   individual_to_send[i] = target_function[permutation[i]];
  // }
  for (i = 0; i < dimension; ++i) {
    // individual_to_send[i] = (individual[i] + (1 - target_function[i])) % 2;
    individual_to_send[i] = (individual[permutation[i]] + (1 - target_function[permutation[i]])) % 2;
  }
}
/**
 * To generate individuals randomly. Elements of a bit-string is generated by a standard Uniform distribution.
 */
void generatingIndividual(int * individuals,
                            const size_t dimension,
                            IOHprofiler_random_state_t *random_generator){
  size_t i;
  for(i = 0; i < dimension; ++i){
    individuals[i] = (int)(IOHprofiler_random_uniform(random_generator) * 2);
  }
}

/**
 * To copy an individual "old" to "new", the length of the bit-string is given by "dimension".
 */
void CopyIndividual(int * old, int * new, const size_t dimension){
  size_t i;
  for(i = 0; i < dimension; ++i){
    new[i] = old[i];
  }
}

/**
 * To sample a random value by a Binomial distribution with "n" trials and a given "probability".
 */
size_t randomBinomial(size_t n, double  probability,IOHprofiler_random_state_t *random_generator)
{
    size_t r, i;
    r = 0;
    for(i = 0; i < n; ++i){
        if(IOHprofiler_random_uniform(random_generator) < probability)
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
size_t mutateIndividual(int * individual,
                      const size_t dimension,
                      double mutation_rate,
                      IOHprofiler_random_state_t *random_generator){
  size_t i, h, l;
  int flag,temp;
  int * flip;

  l = randomBinomial(dimension,mutation_rate,random_generator);
  if (l == 0) {
    l = 1;
  }

  flip = IOHprofiler_allocate_int_vector(l);
  for(i = 0; i < l; ++i){
    while(1){
      flag = 0;
      temp = (int)(IOHprofiler_random_uniform(random_generator) * dimension);
      for(h = 0; h < i; ++h)
      {
        if(temp == flip[h]){
          flag = 1;
          break;
        }
      }
      if(flag == 0)
        break;
    }
    flip[i] = temp;
  }

  for(i = 0; i < l; ++i){
    individual[flip[i]] =  ((int)(individual[flip[i]] + 1) % 2);
  }
  IOHprofiler_free_memory(flip);
  return l;
}

#include <stdio.h>

/**
 * An user defined algorithm.
 *
 * @param "evaluate" The function for evaluating variables' fitness. Invoking the
 *        statement "evaluate(x,y)", then the fitness of 'x' will be stored in 'y[0]'.
 * @param "dimension" The dimension of problem.
 * @param "number_of_objectives" The number of objectives. The default is 1.
 * @param "lower_bounds" The lower bounds of the region of interested (a vector containing dimension values).
 * @param "upper_bounds" The upper bounds of the region of interested (a vector containing dimension values).
 * @param "max_budget" The maximal number of evaluations. You can set it by BUDGET_MULTIPLIER in "config" file.
 * @param "random_generator" Pointer to a random number generator able to produce uniformly and normally
 * distributed random numbers. You can set it by RANDOM_SEED in "config" file
 */
void User_Algorithm(evaluate_function_t evaluate,
                      const size_t dimension,
                      const size_t number_of_objectives,
                      const int *lower_bounds,
                      const int *upper_bounds,
                      const size_t max_budget,
                      IOHprofiler_random_state_t *target_random_generator,
                      IOHprofiler_random_state_t *random_generator) {

  int *parent = IOHprofiler_allocate_int_vector(dimension);
  int *offspring = IOHprofiler_allocate_int_vector(dimension);
  int *offspring_to_send = IOHprofiler_allocate_int_vector(dimension);
  int *permutation = IOHprofiler_allocate_int_vector(dimension);
  get_default_permutation(permutation, dimension);
  int *target_function = IOHprofiler_allocate_int_vector(dimension);
  get_default_target_function(target_function, dimension, target_random_generator);
  int *best = IOHprofiler_allocate_int_vector(dimension);
  double parent_value, best_value = 0.0;
  double *y = IOHprofiler_allocate_vector(number_of_objectives);
  size_t number_of_parameters = 3;
  double *p = IOHprofiler_allocate_vector(number_of_parameters);
  size_t i, j, l;
  double mutation_rate = 1/(double)dimension;
  double min_mutation_rate = 1 / ((double)dimension * (double)dimension);

  int is_fitness_changed;
  l = 0;

  int should_change_fitness = 0;
  int next_budget_to_change_fitness = get_next_budget(0, target_random_generator);
  int times_got_improvement = 0;

  generatingIndividual(parent,dimension,random_generator);
  p[0] = best_value; p[1] = mutation_rate; p[2] = (double)next_budget_to_change_fitness + 1.0;
  // p[0] = mutation_rate; p[1] = (double)FITNESS_CHANGE_FREQUENCY; p[2] = (double)lambda;
  set_parameters(number_of_parameters,p);
  apply_fitness_function_change_to_individual(parent, offspring_to_send, permutation, target_function, dimension);
  evaluate(offspring_to_send,y);

  CopyIndividual(parent,best,dimension);
  parent_value = y[0];
  best_value = y[0];

  for (i = 1; i < max_budget;) {
    if (next_budget_to_change_fitness <= i) {
      should_change_fitness = 1;
      next_budget_to_change_fitness = get_next_budget(i, target_random_generator);
    }
    if (should_change_fitness) {
      is_fitness_changed = change_fitness_function(permutation, target_function, dimension, CHANGE_TYPE, target_random_generator);

      if (is_fitness_changed) {
        best_value = -1.0;
      }

      if (is_fitness_changed) {
        p[0] = best_value; p[1] = mutation_rate; p[2] = (double)next_budget_to_change_fitness + 1.0;
        set_parameters(number_of_parameters,p);
        apply_fitness_function_change_to_individual(parent, offspring_to_send, permutation, target_function, dimension);
        evaluate(offspring_to_send, y);
        parent_value = y[0];
        best_value = y[0];
        ++i;
        if(i == max_budget){
          break;
        }
      }

      should_change_fitness = 0;
    }
    for(j = 0; j < lambda; ++j){

      CopyIndividual(parent,offspring,dimension);
      l = mutateIndividual(offspring,dimension,mutation_rate,random_generator);

      /* Call the evaluate function to evaluate x on the current problem (this is where all the IOHprofiler logging
       * is performed) */
      // p[0] = mutation_rate; p[1] = (double)FITNESS_CHANGE_FREQUENCY; p[2] = (double)lambda;
      p[0] = best_value; p[1] = mutation_rate; p[2] = (double)next_budget_to_change_fitness + 1.0;
      set_parameters(number_of_parameters,p);

      apply_fitness_function_change_to_individual(offspring, offspring_to_send, permutation, target_function, dimension);
      evaluate(offspring_to_send, y);

      if(y[0] > parent_value){
        #ifdef AB
        times_got_improvement += 1;
        #endif

        if (y[0] > best_value) {
          best_value = y[0];
          CopyIndividual(offspring,best,dimension);
        }
      }

      // if (best_value == 3.0) {
        // FILE * fp;
        // fp = fopen("/Users/danil.shkarupin/Study/wonderlog.txt","a");
        // fprintf (fp, "%d: %f  ", i, best_value);
        // for (int iii = 0; iii < dimension; ++iii) {
        //   fprintf (fp, "T %d P %d Ind %d IndToSend %d   ", target_function[iii], permutation[iii], offspring[iii], offspring_to_send[iii]);
        // }
        // fprintf(fp, "\n");
        // fclose (fp);
      // }

      ++i;
      if(i == max_budget){
        break;
      }
      // if (best_value == dimension) {
      //   break;
      // }
    }

    #ifdef AB
    if (times_got_improvement >= 0.05 * lambda) {
      mutation_rate *= 2;
    } else {
      mutation_rate *= 0.5;
    }
    mutation_rate = fmax(fmin(mutation_rate, 0.5), min_mutation_rate);
    times_got_improvement = 0;
    #endif

    parent_value = best_value;
    CopyIndividual(best,parent,dimension);

    // if (best_value == dimension) {
    //   break;
    // }
  }

  IOHprofiler_free_memory(parent);
  IOHprofiler_free_memory(offspring);
  IOHprofiler_free_memory(offspring_to_send);
  IOHprofiler_free_memory(permutation);
  IOHprofiler_free_memory(target_function);
  IOHprofiler_free_memory(best);
  IOHprofiler_free_memory(p);
  IOHprofiler_free_memory(y);
}