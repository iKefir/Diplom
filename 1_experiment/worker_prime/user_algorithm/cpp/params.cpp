/**
 * The random seed. Change it if needed.
 */
#include <random>

int RANDOM_SEED = 1;
IOHprofiler_random random_generator(RANDOM_SEED);
std::mt19937 shuffle_random_generator(RANDOM_SEED);

enum Change_type {
  NO_CHANGE,
  BIT_INVERT_1,
  BIT_INVERT_2,
  BIT_INVERT_3,
  BIT_INVERT_4,
  BIT_INVERT_5,
  PERMUTATION
};
