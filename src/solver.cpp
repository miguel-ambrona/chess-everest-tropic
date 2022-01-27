#include "solver.h"
#include "cha.h"
#include "stockfish.h"

// Perform a cooperative search of depth [n] looking for a checkmate
// or a dead draw (depending on the template parameter).
//
// Print in UCI format a line for each solution found.
// It return the total number of solutions.
template <SOLVER::Goal GOAL>
int cooperative(Position &pos, Depth n, UTIL::Search &search) {

  if (GOAL == SOLVER::MATE) {
    if (MoveList<LEGAL>(pos).size() == 0 && pos.checkers()) {
      if (search.search_depth() % 2 == 0)
        search.print_solution();
      return n % 2 == 0 ? 1 : 0;
    };
  }

  if (GOAL == SOLVER::DRAW) {
    if (CHA::is_dead(pos)) {
      if (n == 0)
        search.print_solution();
      return n == 0;
    }
  }

  if (n <= 0)
    return 0;

  // To store an entry from the transposition table (TT)
  TTEntry *tte = nullptr;
  bool found;
  StateInfo st;

  tte = TT.probe(pos.key(), found);

  if (found && tte->depth() == n)
    return tte->eval();

  int cnt = 0;

  // Iterate over all legal moves
  for (const ExtMove &m : MoveList<LEGAL>(pos)) {
    pos.do_move(m, st);
    search.push(m);
    cnt += cooperative<GOAL>(pos, n - 1, search);
    search.pop();
    pos.undo_move(m);
  }

  tte->save(pos.key(), VALUE_NONE, false, BOUND_NONE, n, MOVE_NONE, (Value)cnt);
  return cnt;
}

int SOLVER::helpmate(Position &pos, Depth n, UTIL::Search &search) {
  TT.clear();
  return cooperative<MATE>(pos, n, search);
};

int SOLVER::helpdraw(Position &pos, Depth n, UTIL::Search &search) {
  TT.clear();
  return cooperative<DRAW>(pos, n, search);
};
