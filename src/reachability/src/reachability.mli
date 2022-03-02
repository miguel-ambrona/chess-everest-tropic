module Color : sig
  type t = White | Black

  val equal : t -> t -> bool

  val of_string : string -> t

  val to_string : t -> string
end

module Board : sig
  module Square : sig
    type t

    (** Rank of a square, integer from 0 to 7 *)
    val rank : t -> int

    (** File of a square, integer from 0 to 7 *)
    val file : t -> int

    (** Color of a square *)
    val color : t -> Color.t

    val equal : t -> t -> bool

    val compare : t -> t -> int

    val of_int : int -> t

    val to_int : t -> int

    val of_string : string -> t

    val to_string : t -> string
  end

  module Piece : sig
    type piece_type = King | Queen | Rook | Bishop | Knight | Pawn

    type t = {piece_type : piece_type; piece_color : Color.t}

    val equal : t -> t -> bool

    val of_char : Char.t -> t

    val to_char : t -> Char.t
  end

  (** Type of position *)
  type t

  val equal : t -> t -> bool

  (** Empty board *)
  val empty : t

  (** Initial board *)
  val initial : t

  (** Parse a FEN (Forsyth-Edwards Notation) string *)
  val of_fen : string -> t

  (** Convert a position to FEN *)
  val to_fen : t -> string

  (** Create a board from a list of pieces and their location *)
  val of_pieces : (Piece.t * Square.t) list -> t
end

module Position : sig
  type castling_rights

  type t = {
    board : Board.t;
    turn : Color.t;
    castling_rights : castling_rights;
    en_passant : Board.Square.t option;
  }

  (** Initial position of a chess game *)
  val initial : t

  val equal : t -> t -> bool

  val of_fen : string -> t

  val to_fen : t -> string
end

module Predecessors : sig
  open Board

  val predecessors : Piece.t -> Square.t -> Square.t list
end
