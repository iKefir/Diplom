
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
                      IOHprofiler_random_state_t *random_generator) {

  int *parent = IOHprofiler_allocate_int_vector(dimension);
  int *offspring = IOHprofiler_allocate_int_vector(dimension);
  int *offspring_to_send = IOHprofiler_allocate_int_vector(dimension);
  int *permutation = IOHprofiler_allocate_int_vector(dimension);
  get_default_permutation(permutation, dimension);
  int *target_function = IOHprofiler_allocate_int_vector(dimension);
  get_default_target_function(target_function, dimension, random_generator);
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
  int next_budget_to_change_fitness = get_next_budget(0, random_generator);
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
      next_budget_to_change_fitness = get_next_budget(i, random_generator);
    }
    if (should_change_fitness) {
      is_fitness_changed = change_fitness_function(permutation, target_function, dimension, CHANGE_TYPE, random_generator);

      if (is_fitness_changed) {
        best_value = 0.0;
      }

      if (is_fitness_changed) {
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
        //   fprintf (fp, "T %d B %d M %d   ", target_function[iii], offspring[iii], offspring_to_send[iii]);
        // }
        // fprintf(fp, "\n");
        // fclose (fp);
      // }

      ++i;
      if(i == max_budget){
        break;
      }
      if (best_value == dimension) {
        break;
      }
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

    if (best_value == dimension) {
      break;
    }
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
