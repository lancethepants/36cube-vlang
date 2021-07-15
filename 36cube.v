enum Color {
	red = 0
	orange
	yellow
	green
	blue
	purple
}

struct Tower {
mut:
	height int
	color  Color
	inuse  bool
}

struct Position {
	row    int
	column int
}

fn initialize_freetowers() []Tower {
	mut towers := []Tower{}

	for i in 1 .. 7 {
		for j in 0 .. 6 {
			towers << Tower{i, Color(j), false}
		}
	}
	return towers
}

fn main() {
	board_height := [[0, 3, 4, 2, 1, 5], [2, 1, 5, 0, 3, 4], [5, 4, 2, 3, 0, 1],
		[4, 1, 3, 0, 5, 2], [3, 5, 1, 4, 2, 0], [1, 2, 0, 5, 4, 3]]

	mut board := [6][6]Tower{}

	mut freetowers := initialize_freetowers()

	mut position := Position{0, 5}

	for freetowers.len > -1 {
		if position.row == -1 || position.column == -1 {
			break
		}

		position = evaluate_cube(mut board, mut freetowers, board_height, position)

		if freetowers.len == 0 {
			print_board(board)
		}
	}
}

fn print_board(board [6][6]Tower) {
	// add if statement to check our two special pieces are in their places
	if board[3][1].color == Color(2) && board[3][3].color == Color(1) {
		for i := 0; i < 6; i++ {
			for j := 0; j < 6; j++ {
				if board[i][j].inuse {
					print(board[i][j].color.str().to_upper()[0..1])
					print(board[i][j].height)
					print(' ')
				} else {
					print('*  ')
				}
			}
			println('')
		}
		println('')
	}
}

fn evaluate_cube(mut board [6][6]Tower, mut freetowers []Tower, board_height [][]int, p Position) Position {
	// is already purple
	if board[p.row][p.column].inuse && board[p.row][p.column].color == Color(5) {
		board[p.row][p.column].inuse = false
		freetowers << board[p.row][p.column]
		return back_position(p)
	}

	mut i := 0
	if board[p.row][p.column].inuse {
		i = int(board[p.row][p.column].color) + 1
	}
	// search for available tower
	for i < 6 {
		// if found available tower
		mut index := find_available_tower(freetowers, Tower{6 - board_height[p.row][p.column], Color(i), false})
		if index > -1 && color_is_free(board, p, Color(i)) {
			if board[p.row][p.column].inuse {
				freetowers << board[p.row][p.column]
			}
			board[p.row][p.column] = Tower{6 - board_height[p.row][p.column], Color(i), true}
			freetowers[index] = freetowers[freetowers.len - 1]
			freetowers.delete_last()
			return advance_position(p)
		}
		i++
	}
	// if no available tower found
	if board[p.row][p.column].inuse {
		board[p.row][p.column].inuse = false
		freetowers << board[p.row][p.column]
	}

	return back_position(p)
}

fn find_available_tower(freetowers []Tower, t Tower) int {
	for i := 0; i < freetowers.len; i++ {
		if freetowers[i].height == t.height && freetowers[i].color == t.color {
			return i
		}
	}
	return -1
}

fn advance_position(p Position) Position {
	if p.row == 5 && p.column == 0 {
		return back_position(p)
	}

	mut column := p.column - 1
	if column < 0 {
		return Position{p.row + 1, 5}
	}
	return Position{p.row, p.column - 1}
}

fn back_position(p Position) Position {
	mut column := p.column + 1
	if column > 5 {
		return Position{p.row - 1, 0}
	}
	return Position{p.row, p.column + 1}
}

fn color_is_free(board [6][6]Tower, p Position, color Color) bool {
	for i := 0; i < 6; i++ {
		if board[p.row][i].color == color && board[p.row][i].inuse == true {
			return false
		}
	}

	for i := 0; i < 6; i++ {
		if board[i][p.column].color == color && board[i][p.column].inuse == true {
			return false
		}
	}
	return true
}
