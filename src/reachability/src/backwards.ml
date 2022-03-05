open Position

module Predecessors = struct
  let piece_predecessors deltas sq =
    let open Board.Square in
    List.filter_map
      (fun d ->
        let p = sq + d in
        if is_valid p && king_distance p sq <= 2 then Some p else None)
      deltas

  let predecessors piece =
    let open Board.Piece in
    match piece.piece_type with
    | King -> piece_predecessors [-9; -8; -7; -1; 1; 7; 8; 9]
    | Queen -> piece_predecessors [-9; -8; -7; -1; 1; 7; 8; 9]
    | Rook -> piece_predecessors [-8; -1; 1; 8]
    | Bishop -> piece_predecessors [-9; -7; 7; 9]
    | Knight -> piece_predecessors [-17; -15; -10; -6; 6; 10; 15; 17]
    | Pawn -> assert false
end
