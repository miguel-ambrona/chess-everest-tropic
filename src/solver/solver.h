#include "stockfish.h"
#include "util.h"

#ifndef SOLVER_H_INCLUDED
#define SOLVER_H_INCLUDED

namespace SOLVER {

enum Goal { MATE, DRAW };

// Returns the number of possible helpmates in [n] or fewer plies
int helpmate(Position &pos, Depth n, UTIL::Search &search);

// Returns the number of possible helpdraws in exactly [n] plies
int helpdraw(Position &pos, Depth n, UTIL::Search &search);

// Returns the number of possible forced mates in [n] or fewer plies
int mate(Position &pos, Depth n, UTIL::Search &search);

} // namespace SOLVER

#endif // #ifndef SOLVER_H_INCLUDED
