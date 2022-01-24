#include "solver.h"
#include <sstream>
#include <stdexcept>

enum Stipulation { HELPMATE };

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

  nmoves = std::stof(stipulation.substr(2));

  if (stipulation.substr(0, 2) == "h#")
    return HELPMATE;

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
    Stipulation goal = parse_line(pos, nmoves, &states->back(), line);
    search.init();

    if (goal == HELPMATE) {
      int n = (int)(2 * nmoves);
      int nsols = SOLVER::helpmate(pos, n, search);
      std::cout << "finished nsols " << nsols << std::endl;
    }
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