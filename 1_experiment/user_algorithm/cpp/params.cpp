/**
 * The random seed. Change it if needed.
 */
IOHprofiler_random random_generator(1);

/**
 * Amount of offsprings in every generation.
 */
static int lambda = 1;

enum Change_type {
  NO_CHANGE,
  BIT_INVERT,
  PERMUTATION
};
