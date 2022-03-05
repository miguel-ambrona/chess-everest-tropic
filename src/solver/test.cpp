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

  std::string fen = "8/3R2K1/4kP1P/3R3P/3P3P/4N1BP/7P/3B4 w - - 0 1";
  pos.set(fen, false, &states->back(), Threads.main());

  UTIL::Test helpmate_tests[] = {
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

  std::cout << "Running Helpmate tests:\n";
  for (int i = 0; i < 8; ++i) {
    std::string fen = helpmate_tests[i].test_fen();
    Depth n = helpmate_tests[i].test_depth();
    int expected_nsols = helpmate_tests[i].test_nsols();

    search.init();
    pos.set(fen, false, &states->back(), Threads.main());

    std::cout << "h#" << (n / 2) << " " << fen << std::endl;
    int nsols = SOLVER::helpmate(pos, n, search);
    std::cout << "finished nsols " << nsols << std::endl;
    assert(nsols == expected_nsols);
  };

  UTIL::Test helpdraw_tests[] = {
      // Andrew Buchanan, 2017 (https://pdb.dieschwalbe.de/P1338362)
      UTIL::Test("8/5p2/5P2/8/1p2pP2/kP2p3/1pKpP3/3B4 b - f3", 2, 1),
  };

  std::cout << "\nRunning Helpdraw tests:\n";
  for (int i = 0; i < 1; ++i) {
    std::string fen = helpdraw_tests[i].test_fen();
    Depth n = helpdraw_tests[i].test_depth();
    int expected_nsols = helpdraw_tests[i].test_nsols();

    search.init();
    pos.set(fen, false, &states->back(), Threads.main());

    std::cout << "h=" << (n / 2) << " " << fen << std::endl;
    int nsols = SOLVER::helpdraw(pos, n, search);
    std::cout << "finished nsols " << nsols << std::endl;
    assert(nsols == expected_nsols);
  };

  std::cout << "\nTests were successful!" << std::endl;

  return 0;
};
