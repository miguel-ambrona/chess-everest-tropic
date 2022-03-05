open Reachability

(* Color Tests *)

let test_color_of_string () =
  assert (Color.of_string "w" = Color.White) ;
  assert (Color.of_string "b" = Color.Black)

let test_color_to_string () =
  assert (Color.(to_string White) = "w") ;
  assert (Color.(to_string Black) = "b")

let tests_color =
  Alcotest.
    ( "Color",
      [
        test_case "of_string" `Quick test_color_of_string;
        test_case "to_string" `Quick test_color_to_string;
      ] )

(* Board.Square Tests *)

let files = ["a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"]

let ranks = ["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"]

let square_names = List.map (fun r -> List.map (fun f -> f ^ r) files) ranks

let squares = List.map (List.map Board.Square.of_string) square_names

let test_square_rank () =
  let open Board.Square in
  List.iteri
    (fun i rs -> assert (List.for_all (fun s -> rank s = i) rs))
    squares

let test_square_file () =
  let open Board.Square in
  List.iter (List.iteri (fun j s -> assert (file s = j))) squares

let test_square_color () =
  List.iteri
    (fun i ->
      List.iteri (fun j s ->
          let color = if (i + j) mod 2 = 1 then Color.White else Color.Black in
          assert (color = Board.Square.color s)))
    squares

let test_square_of_int () =
  let open Board.Square in
  List.iteri (fun i s -> assert (equal s @@ of_int i)) (List.concat squares)

let test_square_to_int () =
  let open Board.Square in
  List.iteri (fun i s -> assert (i = to_int s)) (List.concat squares)

let test_square_of_string () =
  let open Board.Square in
  List.iter2
    (fun s n -> assert (equal s @@ of_string n))
    (List.concat squares)
    (List.concat square_names)

let test_square_to_string () =
  let open Board.Square in
  List.iter2
    (fun s n -> assert (n = to_string s))
    (List.concat squares)
    (List.concat square_names)

let tests_board_square =
  Alcotest.
    ( "Board.Square",
      [
        test_case "rank" `Quick test_square_rank;
        test_case "file" `Quick test_square_file;
        test_case "color" `Quick test_square_color;
        test_case "of_int" `Quick test_square_of_int;
        test_case "to_int" `Quick test_square_to_int;
        test_case "of_string" `Quick test_square_of_string;
        test_case "to_string" `Quick test_square_to_string;
      ] )

(* Board.Piece Tests *)

let test_piece_of_char () =
  let open Board.Piece in
  List.iter
    (fun c -> assert (c = to_char @@ of_char c))
    ['K'; 'Q'; 'R'; 'B'; 'N'; 'P'; 'k'; 'q'; 'r'; 'b'; 'n'; 'p']

let test_piece_to_char () =
  let open Board.Piece in
  (* White pieces *)
  assert ('K' = to_char {piece_type = King; piece_color = Color.White}) ;
  assert ('Q' = to_char {piece_type = Queen; piece_color = Color.White}) ;
  assert ('R' = to_char {piece_type = Rook; piece_color = Color.White}) ;
  assert ('B' = to_char {piece_type = Bishop; piece_color = Color.White}) ;
  assert ('N' = to_char {piece_type = Knight; piece_color = Color.White}) ;
  assert ('P' = to_char {piece_type = Pawn; piece_color = Color.White}) ;
  (* Black pieces *)
  assert ('k' = to_char {piece_type = King; piece_color = Color.Black}) ;
  assert ('q' = to_char {piece_type = Queen; piece_color = Color.Black}) ;
  assert ('r' = to_char {piece_type = Rook; piece_color = Color.Black}) ;
  assert ('b' = to_char {piece_type = Bishop; piece_color = Color.Black}) ;
  assert ('n' = to_char {piece_type = Knight; piece_color = Color.Black}) ;
  assert ('p' = to_char {piece_type = Pawn; piece_color = Color.Black})

let tests_board_piece =
  Alcotest.
    ( "Board.Piece",
      [
        test_case "of_char" `Quick test_piece_of_char;
        test_case "to_char" `Quick test_piece_to_char;
      ] )

(* Board.Piece Tests *)

let board_fens_and_pieces =
  let parse_piece_square (c, s) = Board.(Piece.of_char c, Square.of_string s) in
  [
    ("4k3/8/8/4K3/8/8/8/4R3", [('R', "e1"); ('K', "e5"); ('k', "e8")]);
    ( "8/8/8/1Kp5/2Pk4/8/8/8",
      [('P', "c4"); ('k', "d4"); ('K', "b5"); ('p', "c5")] );
  ]
  |> List.map (fun (fen, l) -> (fen, List.map parse_piece_square l))

let test_board_of_fen () =
  let initial_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR" in
  assert (Board.(equal initial @@ of_fen initial_fen)) ;
  assert (Board.(equal empty @@ of_fen "8/8/8/8/8/8/8/8")) ;
  List.iter
    (fun (fen, pieces) ->
      assert (Board.(equal (of_pieces pieces) (of_fen fen))))
    board_fens_and_pieces

let test_board_to_fen () =
  List.iter
    (fun (fen, pieces) -> assert (fen = Board.(to_fen @@ of_pieces pieces)))
    board_fens_and_pieces

let tests_board =
  Alcotest.
    ( "Board",
      [
        test_case "of_fen" `Quick test_board_of_fen;
        test_case "to_fen" `Quick test_board_to_fen;
      ] )

(* Position Tests *)

let position_fens =
  [
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3";
    "r1b1kb1r/6pp/p1pppn2/4P1B1/8/q1N5/P1PQ2PP/1R2KB1R b Kkq -";
  ]

let test_position_of_fen () =
  let initial_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -" in
  assert (Position.(equal initial @@ of_fen initial_fen))

let test_position_to_fen () =
  List.iter
    (fun fen -> assert (fen = Position.(to_fen @@ of_fen fen)))
    position_fens

let tests_position =
  Alcotest.
    ( "Position",
      [
        test_case "of_fen" `Quick test_position_of_fen;
        test_case "to_fen" `Quick test_position_to_fen;
      ] )

let () =
  let open Alcotest in
  run
    "Position"
    [
      tests_color;
      tests_board_square;
      tests_board_piece;
      tests_board;
      tests_position;
    ]

(* let board_fens =
 *   [
 *     "1R6/1bNB2n1/pk2P3/pN2p2p/3pP2K/3P3p/5B1P/6n1";
 *     "8/5PQ1/6P1/4B1P1/3P1PP1/4kP1N/B3P3/RN2K2R";
 *     "1K6/2R1p3/r1P5/1N6/1Nk5/P1nnP3/3P4/2b5";
 *     "8/7Q/8/4BB2/2PP1P2/3NkN2/PP2P1P1/4K2R";
 *     "8/3R2K1/4kP1P/3R3P/3P2BP/4N1BP/7P/8";
 *     "8/8/2Q1N3/3B4/2PP4/3Nk2P/2P5/B2RK2R";
 *     "4b1n1/3pPk2/3PpN1P/5PBK/6p1/8/8/8";
 *     "8/5p2/5P2/8/1p6/kP2pp2/1pKpP3/3B4";
 *     "8/8/8/p7/P5p1/4p1Pk/P3P2P/5bBK";
 *     "6br/4Bp1k/5P2/5PpK/4B1P1/8/8/8";
 *     "5bk1/4p1p1/4P1P1/7K/8/8/8/8";
 *     "8/8/8/8/7R/7R/3RR1B1/R3K1kB";
 *     "8/8/8/8/6P1/5N1p/5K1P/4N1Bk";
 *     "8/8/8/pN1k4/3p1PB1/1K6/8/8";
 *     "3k4/8/8/1N3P2/3B4/8/3K4/8";
 *   ] *)
