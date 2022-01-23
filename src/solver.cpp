#include "solver.h"
#include "stockfish.h"
#include "util.h"
#include <assert.h>
#include <iostream>
#include <stdio.h>

// Returns the number of possible helpmates in [n] or fewer plies
int SOLVER::helpmate(Position &pos, Depth n, UTIL::Search &search) {

  // To store an entry from the transposition table (TT)
  TTEntry *tte = nullptr;
  bool found;
  StateInfo st;

  // Checkmate!
  if (MoveList<LEGAL>(pos).size() == 0 && pos.checkers()) {
    if (n % 2 == 0)
      search.print_solution();

    return n % 2 == 0 ? 1 : 0;
  }

  if (n <= 0)
    return 0;

  tte = TT.probe(pos.key(), found);

  if (found && tte->depth() == n)
    return tte->eval();

  int cnt = 0;

  // Iterate over all legal moves
  for (const ExtMove &m : MoveList<LEGAL>(pos)) {
    pos.do_move(m, st);
    search.push(m);
    cnt += SOLVER::helpmate(pos, n - 1, search);
    search.pop();
    pos.undo_move(m);
  }

  tte->save(pos.key(), VALUE_NONE, false, BOUND_NONE, n, MOVE_NONE, (Value)cnt);
  return cnt;
};
