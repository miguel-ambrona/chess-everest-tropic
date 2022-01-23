#include "stockfish.h"
#include "util.h"

#ifndef SOLVER_H_INCLUDED
#define SOLVER_H_INCLUDED

namespace SOLVER {

// Returns the number of possible helpmates in [n] or fewer plies
int helpmate(Position &pos, Depth n, UTIL::Search &search);

} // namespace SOLVER

#endif // #ifndef SOLVER_H_INCLUDED
