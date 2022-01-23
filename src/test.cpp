#include "solver.h"
#include "stockfish.h"
#include "util.h"
#include <assert.h>
#include <iostream>
#include <stdio.h>

int main() {

  init_stockfish();

  Position pos;
  StateListPtr states(new std::deque<StateInfo>(1));
  static UTIL::Search search = UTIL::Search();

  UTIL::Test tests[] = {
      // Jeff Coakley, 1977 (ChessCafe.com in 2013)
      UTIL::Test("8/4K2k/4P2p/8/5q2/2b5/8/8 b - - 0 1", 6, 1),

      // Sam Loyd, 1860 (Chess Monthly)
      UTIL::Test("6R1/7q/8/5k2/5B2/8/5Kbb/8 b - - 0 1", 6, 1),

      // Josef Jána, 1928 (Neues Grazer Tagblatt)
      UTIL::Test("r3k3/3N4/2N5/8/1K6/8/7p/8 b q - 0 1", 6, 1),

      // Chris Feather, 1975 (Schach)
      UTIL::Test("1RrB2b1/8/4n3/2n3p1/2K2b2/1p1rk3/6BR/8 b - - 0 1", 4, 2),

      // Milan Vukcevich, 1996 (CHM avec 6 pieces Bad Pyrmont)
      UTIL::Test("4K2n/3P1P2/4k3/3p4/8/8/8/8 b - - 0 1", 4, 1),

      // Roddy McKay, 2021 (Matplus.net)
      UTIL::Test("8/1B6/3p1P1q/4ppB1/1p3b2/1Pk3p1/2P4p/1K6 b - -", 4, 1),

      // Neal Turner, 1995 (Problemist Supplement)
      UTIL::Test("q1b1n1K1/2P1P3/8/3k4/8/8/8/8 b - -", 6, 1),

      // Miguel Ambrona, 2021 (Matplus.net)
      UTIL::Test("8/4K2k/4P2p/8/5q2/2b5/8/8 b - - 0 1", 6, 1)};

  for (int i = 0; i < 8; ++i) {
    std::string fen = tests[i].test_fen();
    Depth n = tests[i].test_depth();
    int expected_nsols = tests[i].test_nsols();

    search.init();
    pos.set(fen, false, &states->back(), Threads.main());

    std::cout << "h#" << (n / 2) << " " << fen << std::endl;
    int nsols = SOLVER::helpmate(pos, n, search);
    std::cout << "finished nsols " << nsols << std::endl;
    assert(nsols == expected_nsols);
  };

  std::cout << "Tests were successful!" << std::endl;

  return 0;
};