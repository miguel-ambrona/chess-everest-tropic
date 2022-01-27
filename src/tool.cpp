#include "solver.h"
#include <sstream>
#include <stdexcept>

enum SearchType { COOPERATIVE, COMPETITIVE };

struct Stipulation {
  SearchType searchType;
  SOLVER::Goal goal;
};

// We expect input commands to be a line of text containing a stipulation,
// followed by a valid FEN string.

Stipulation parse_line(Position &pos, float &nmoves, StateInfo *si,
                       std::string &line) {

  std::string fen, stipulation, token;
  std::istringstream iss(line);

  iss >> stipulation;

  while (iss >> token)
    fen += token + " ";

  pos.set(fen, false, si, Threads.main());

  if (stipulation.substr(0, 2) == "h#") {
    nmoves = std::stof(stipulation.substr(2));
    return {COOPERATIVE, SOLVER::MATE};
  }

  else if (stipulation.substr(0, 2) == "h=") {
    nmoves = std::stof(stipulation.substr(2));
    return {COOPERATIVE, SOLVER::DRAW};
  }

  else if (stipulation.substr(0, 1) == "#") {
    nmoves = std::stof(stipulation.substr(1));
    return {COMPETITIVE, SOLVER::MATE};
  }

  else
    throw std::invalid_argument("unknown stipulation");
};

// loop() waits for a command from stdin or tests file and analyzes it.

void loop(int argc, char *argv[]) {

  Position pos;
  std::string line;
  StateListPtr states(new std::deque<StateInfo>(1));

  uint64_t nodesLimit = 100000;

  for (int i = 1; i < argc; ++i) {

    if (std::string(argv[i]) == "-limit") {
      std::istringstream iss(argv[i + 1]);
      iss >> nodesLimit;
    }
  }

  static UTIL::Search search = UTIL::Search();

  while (getline(std::cin, line)) {

    if (line == "quit")
      break;

    float nmoves;
    Stipulation stipulation = parse_line(pos, nmoves, &states->back(), line);
    search.init();

    int nsols;
    if (stipulation.searchType == COOPERATIVE) {
      int n = (int)(2 * nmoves);
      if (stipulation.goal == SOLVER::MATE)
        nsols = SOLVER::helpmate(pos, n, search);

      else if (stipulation.goal == SOLVER::DRAW)
        nsols = SOLVER::helpdraw(pos, n, search);
    } else if (stipulation.searchType == COMPETITIVE) {
      int n = (int)(2 * nmoves - 1);
      if (stipulation.goal == SOLVER::MATE)
        nsols = SOLVER::mate(pos, n, search);
    }
    std::cout << "finished nsols " << nsols << std::endl;
  }

  Threads.stop = true;
}

int main(int argc, char *argv[]) {

  init_stockfish();
  std::cout << "Retrospective Chess version 1.0" << std::endl;

  CommandLine::init(argc, argv);
  loop(argc, argv);

  Threads.set(0);
  return 0;
}
