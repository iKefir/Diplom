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
