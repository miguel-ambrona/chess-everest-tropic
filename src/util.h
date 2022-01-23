#ifndef UTIL_H_INCLUDED
#define UTIL_H_INCLUDED

namespace UTIL {

constexpr int MAX_VARIATION_LENGTH = 300;

class Search {
public:
  Search() = default;

  void init();

  Depth search_depth() const;

  void push(Move m);
  void pop();

  void print_solution() const;

private:
  Move solution[MAX_VARIATION_LENGTH];
  Color winner;
  Depth depth;
};

inline void Search::init() { depth = 0; }

inline Depth Search::search_depth() const { return depth; }

inline void Search::push(Move m) {
  if (depth < MAX_VARIATION_LENGTH)
    solution[depth] = m;
  depth++;
}

inline void Search::pop() { depth--; }

inline void Search::print_solution() const {
  std::cout << "solution";
  for (int i = 0; i < std::min(depth, MAX_VARIATION_LENGTH); i++)
    std::cout << " " << UCI::move(solution[i], false);
  std::cout << "#";
  std::cout << std::endl;
}

class Test {
public:
  Test() = default;
  Test(std::string fen, Depth depth, int nsols);

  std::string test_fen() const { return fen; }
  Depth test_depth() const { return (Depth)depth; }
  Value test_nsols() const { return (Value)nsols; }

private:
  std::string fen;
  uint8_t depth;
  uint32_t nsols;
};

inline Test::Test(std::string testFen, Depth testDepth, int testNsols) {
  fen = testFen;
  depth = testDepth;
  nsols = testNsols;
}

} // namespace UTIL

#endif // #ifndef UTIL_H_INCLUDED
