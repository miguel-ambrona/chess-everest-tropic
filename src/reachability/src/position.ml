module Color = struct
  type t = White | Black

  let equal = ( = )

  let of_string = function
    | "w" -> White
    | "b" -> Black
    | s -> raise @@ Invalid_argument (Format.sprintf "Unknown color: %s" s)

  let to_string = function White -> "w" | Black -> "b"
end

module Board = struct
  module Square = struct
    type t = int

    let rank s = s / 8

    let file s = s mod 8

    let equal = Int.equal

    let compare = Int.compare

    let color s =
      if (rank s + file s) mod 2 = 1 then Color.White else Color.Black

    let check_range min max v =
      if v < min || v > max then
        raise
        @@ Invalid_argument
             (Format.sprintf "Value %d is outside of range [%d, %d]" v min max)
      else v

    let is_valid s = 0 <= s && s < 64

    let of_int i = check_range 0 63 i

    let to_int s = s

    let of_file_and_rank f r = (8 * r) + f

    let rank_of_char c = check_range 0 7 (Char.code c - 49)

    let char_of_rank r = Char.chr (r + 49)

    let file_of_char c = check_range 0 7 (Char.code c - 97)

    let char_of_file f = Char.chr (f + 97)

    let of_string str =
      of_file_and_rank (file_of_char str.[0]) (rank_of_char str.[1])

    let to_string s =
      Char.escaped (char_of_file @@ file s)
      ^ Char.escaped (char_of_rank @@ rank s)

    let king_distance s1 s2 =
      Int.(max (abs @@ (file s1 - file s2)) (abs @@ (rank s1 - rank s2)))
  end

  module Piece = struct
    type piece_type = King | Queen | Rook | Bishop | Knight | Pawn

    type t = {piece_type : piece_type; piece_color : Color.t}

    let equal t1 t2 =
      t1.piece_type = t2.piece_type && Color.equal t1.piece_color t2.piece_color

    let piece_type_to_char = function
      | King -> 'k'
      | Queen -> 'q'
      | Rook -> 'r'
      | Bishop -> 'b'
      | Knight -> 'n'
      | Pawn -> 'p'

    let piece_type_of_char c =
      match c with
      | 'k' -> King
      | 'q' -> Queen
      | 'r' -> Rook
      | 'b' -> Bishop
      | 'n' -> Knight
      | 'p' -> Pawn
      | _ -> raise @@ Invalid_argument ("Unknown piece_type: " ^ Char.escaped c)

    let to_char t =
      if t.piece_color = Color.Black then piece_type_to_char t.piece_type
      else Char.uppercase_ascii @@ piece_type_to_char t.piece_type

    let of_char c =
      let l = Char.lowercase_ascii c in
      let piece_color = if l = c then Color.Black else Color.White in
      {piece_type = piece_type_of_char l; piece_color}
  end

  module SquareMap = Map.Make (Square)

  (* A position is a map from squares to pieces *)
  type t = Piece.t SquareMap.t

  let equal = SquareMap.equal Piece.equal

  let empty = SquareMap.empty

  let of_pieces : (Piece.t * Square.t) list -> t =
    List.fold_left (fun t (p, s) -> SquareMap.add s p t) SquareMap.empty

  let of_fen fen =
    String.fold_left
      (fun (pos, s) c ->
        if c = '/' then (pos, s - 16)
        else
          match int_of_string_opt (Char.escaped c) with
          | None -> (SquareMap.add s (Piece.of_char c) pos, s + 1)
          | Some i -> (pos, s + i))
      (SquareMap.empty, Square.of_string "a8")
      fen
    |> fst

  let to_fen t =
    let flush_cnt cnt str = if cnt = 0 then str else str ^ string_of_int cnt in
    let rec aux ranks (rank, cnt) sq =
      if not (Square.is_valid sq) then ranks
      else
        let (symb, cnt) =
          match SquareMap.find_opt sq t with
          | None -> ("", cnt + 1)
          | Some p ->
              let p_str = Piece.to_char p |> Char.escaped in
              (flush_cnt cnt "" ^ p_str, 0)
        in
        let rank = rank ^ symb in
        if Square.file sq < 7 then aux ranks (rank, cnt) (sq + 1)
        else aux (flush_cnt cnt rank :: ranks) ("", 0) (sq + 1)
    in
    let ranks = aux [] ("", 0) 0 in
    let fen = String.concat "/" ranks in
    fen

  let initial = of_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

module Position = struct
  type castling_rights = {
    white_long : bool;
    black_long : bool;
    white_short : bool;
    black_short : bool;
  }

  type t = {
    board : Board.t;
    turn : Color.t;
    castling_rights : castling_rights;
    en_passant : Board.Square.t option;
  }

  let equal t1 t2 =
    Board.equal t1.board t2.board
    && Color.equal t1.turn t2.turn
    && t1.castling_rights = t2.castling_rights
    && Option.equal Board.Square.equal t1.en_passant t2.en_passant

  let castling_rights_of_string str =
    {
      white_long = String.contains str 'Q';
      black_long = String.contains str 'q';
      white_short = String.contains str 'K';
      black_short = String.contains str 'k';
    }

  let castling_rights_to_string cr =
    let get b symbol = if b then symbol else "" in
    String.concat
      ""
      [
        get cr.white_short "K";
        get cr.white_long "Q";
        get cr.black_short "k";
        get cr.black_long "q";
      ]

  let en_passant_of_string = function
    | "-" -> None
    | s -> Some (Board.Square.of_string s)

  let en_passant_to_string = function
    | None -> "-"
    | Some s -> Board.Square.to_string s

  let initial =
    {
      board = Board.initial;
      turn = Color.White;
      castling_rights = castling_rights_of_string "KQkq";
      en_passant = None;
    }

  let of_fen fen =
    match String.split_on_char ' ' fen with
    | [board_fen; turn; castling_rights; en_passant] ->
        {
          board = Board.of_fen board_fen;
          turn = Color.of_string turn;
          castling_rights = castling_rights_of_string castling_rights;
          en_passant = en_passant_of_string en_passant;
        }
    | _ ->
        raise @@ Invalid_argument "A valid FEN string must contain 4 components"

  let to_fen t =
    String.concat
      " "
      [
        Board.to_fen t.board;
        Color.to_string t.turn;
        castling_rights_to_string t.castling_rights;
        en_passant_to_string t.en_passant;
      ]
end
