# Retrospective Chess

[![Tests](https://github.com/miguel-ambrona/chess-everest-tropic/actions/workflows/c-cpp.yml/badge.svg)](https://github.com/miguel-ambrona/chess-everest-tropic/actions/workflows/c-cpp.yml)

Tool for designing, analyzing and solving retrospective chess compositions

## Installation & Usage

After cloning the repository:

### Install Stockfish

From the `lib/stockfish/` directory:

1. Run `make get-stockfish` to download Stockfish's source code.

2. Compile Stockfish with `make`.

3. Install Stockfish with `make install`.

### Install the tool

From the `src/` directory:

1. Compile the tool with `make`.

2. Run the tests with `make test && ./test`.