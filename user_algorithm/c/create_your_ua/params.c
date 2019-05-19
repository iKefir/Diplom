/**
 * The maximal budget for evaluations done by an optimization algorithm equals dimension * BUDGET_MULTIPLIER.
 * Increase the budget multiplier value gradually to see how it affects the runtime.
 */
static const size_t BUDGET_MULTIPLIER = 1000;

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
