import 'package:flutter/material.dart';
import '../pickgame.dart';
import 'components/dead_piece.dart';
import 'components/piece.dart';
import 'components/square.dart';
import 'values/colors.dart'; 

class Gameboard extends StatefulWidget {
  const Gameboard({super.key});

  @override
  State<Gameboard> createState() => _GameBoardState();
}

class _GameBoardState extends State<Gameboard> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: "assets/images/blackpawn.png");

      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: "assets/images/whitepawn.png");
    }

    // Place other pieces (rooks, knights, bishops, queen, king)
    _placeMajorPieces(newBoard);

    board = newBoard;
  }

  void _placeMajorPieces(List<List<ChessPiece?>> newBoard) {
    final pieceOrder = [
      ChessPieceType.rook,
      ChessPieceType.knight,
      ChessPieceType.bishop,
      ChessPieceType.queen,
      ChessPieceType.king,
      ChessPieceType.bishop,
      ChessPieceType.knight,
      ChessPieceType.rook
    ];

    for (int i = 0; i < 8; i++) {
      newBoard[0][i] = ChessPiece(
          type: pieceOrder[i],
          isWhite: false,
          imagePath: "assets/images/black${pieceOrder[i].name}.png");
      newBoard[7][i] = ChessPiece(
          type: pieceOrder[i],
          isWhite: true,
          imagePath: "assets/images/white${pieceOrder[i].name}.png");
    }
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;

          validMoves =
              calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;

        validMoves =
            calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);

        if (!isWhiteTurn) {
          Future.delayed(const Duration(milliseconds: 500), makeAIMove);
        }
      } else {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
      }
    });
  }

  void makeAIMove() {
    List<Map<String, dynamic>> allValidMoves = [];

    // Collect all valid moves for AI's pieces
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == false) {
          List<List<int>> moves = calculateRealValidMoves(i, j, board[i][j], true);
          for (var move in moves) {
            allValidMoves.add({
              "piece": board[i][j],
              "startRow": i,
              "startCol": j,
              "endRow": move[0],
              "endCol": move[1]
            });
          }
        }
      }
    }

    if (allValidMoves.isNotEmpty) {
      // Heuristic: Prefer capturing pieces or random move otherwise
      allValidMoves.sort((a, b) {
        ChessPiece? targetA = board[a["endRow"]][a["endCol"]];
        ChessPiece? targetB = board[b["endRow"]][b["endCol"]];

        int valueA = targetA != null ? getPieceValue(targetA.type) : 0;
        int valueB = targetB != null ? getPieceValue(targetB.type) : 0;

        return valueB.compareTo(valueA); // Higher value first
      });

      var bestMove = allValidMoves.first;

      movePiece(bestMove["endRow"], bestMove["endCol"],
          startRow: bestMove["startRow"], startCol: bestMove["startCol"]);
    }
  } 

   /// **Get Piece Value**: Assigns heuristic values to chess pieces
  int getPieceValue(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.pawn:
        return 1;
      case ChessPieceType.knight:
      case ChessPieceType.bishop:
        return 3;
      case ChessPieceType.rook:
        return 5;
      case ChessPieceType.queen:
        return 9;
      case ChessPieceType.king:
        return 1000; // Arbitrary high value for king
      default:
        throw Exception('Unhandled ChessPieceType: $type');
    }
  }

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    if (piece == null) return [];

    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    if (!checkSimulation) {
      return candidateMoves;
    }

    List<List<int>> validMoves = [];
    for (var move in candidateMoves) {
      int endRow = move[0];
      int endCol = move[1];

      if (simulatedMoveIsSafe(piece, row, col, endRow, endCol)) {
        validMoves.add(move);
      }
    }

    return validMoves;
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece piece) {
    List<List<int>> moves = [];
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          moves.add([row + direction, col]);
        }
        if ((row == 6 && piece.isWhite) || (row == 1 && !piece.isWhite)) {
          if (board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            moves.add([row + 2 * direction, col]);
          }
        }
        for (int dc in [-1, 1]) {
          if (isInBoard(row + direction, col + dc)) {
            ChessPiece? target = board[row + direction][col + dc];
            if (target != null && target.isWhite != piece.isWhite) {
              moves.add([row + direction, col + dc]);
            }
          }
        }
        break;

      case ChessPieceType.rook:
        moves.addAll(getStraightLineMoves(row, col));
        break;

      case ChessPieceType.bishop:
        moves.addAll(getDiagonalMoves(row, col));
        break;

      case ChessPieceType.knight:
        const knightOffsets = [
          [-2, -1], [-2, 1], [2, -1], [2, 1],
          [-1, -2], [-1, 2], [1, -2], [1, 2]
        ];
        for (var offset in knightOffsets) {
          int newRow = row + offset[0];
          int newCol = col + offset[1];
          if (isInBoard(newRow, newCol) &&
              (board[newRow][newCol] == null ||
                  board[newRow][newCol]!.isWhite != piece.isWhite)) {
            moves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPieceType.queen:
        moves.addAll(getStraightLineMoves(row, col));
        moves.addAll(getDiagonalMoves(row, col));
        break;

      case ChessPieceType.king:
        const kingOffsets = [
          [-1, -1], [-1, 0], [-1, 1],
          [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]
        ];
        for (var offset in kingOffsets) {
          int newRow = row + offset[0];
          int newCol = col + offset[1];
          if (isInBoard(newRow, newCol) &&
              (board[newRow][newCol] == null ||
                  board[newRow][newCol]!.isWhite != piece.isWhite)) {
            moves.add([newRow, newCol]);
          }
        }
        break;

      default:
        break;
    }

    return moves;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? capturedPiece = board[endRow][endCol];
    List<int>? originalKingPosition;

    if (piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = capturedPiece;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return !kingInCheck;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  List<List<int>> getStraightLineMoves(int row, int col) {
    List<List<int>> moves = [];
    const directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1]
    ];

    for (var direction in directions) {
      int step = 1;
      while (true) {
        int newRow = row + direction[0] * step;
        int newCol = col + direction[1] * step;

        if (!isInBoard(newRow, newCol)) break;

        if (board[newRow][newCol] != null) {
          if (board[newRow][newCol]!.isWhite != board[row][col]!.isWhite) {
            moves.add([newRow, newCol]);
          }
          break;
        }

        moves.add([newRow, newCol]);
        step++;
      }
    }
    return moves;
  }

  List<List<int>> getDiagonalMoves(int row, int col) {
    List<List<int>> moves = [];
    const directions = [
      [-1, -1], [-1, 1], [1, -1], [1, 1]
    ];

    for (var direction in directions) {
      int step = 1;
      while (true) {
        int newRow = row + direction[0] * step;
        int newCol = col + direction[1] * step;

        if (!isInBoard(newRow, newCol)) break;

        if (board[newRow][newCol] != null) {
          if (board[newRow][newCol]!.isWhite != board[row][col]!.isWhite) {
            moves.add([newRow, newCol]);
          }
          break;
        }

        moves.add([newRow, newCol]);
        step++;
      }
    }
    return moves;
  }

  void movePiece(int newRow, int newCol, {int? startRow, int? startCol}) {
    int moveStartRow = startRow ?? selectedRow;
    int moveStartCol = startCol ?? selectedCol;

    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if (board[moveStartRow][moveStartCol]!.type == ChessPieceType.king) {
      if (board[moveStartRow][moveStartCol]!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    board[newRow][newCol] = board[moveStartRow][moveStartCol];
    board[moveStartRow][moveStartCol] = null;

    checkStatus = isKingInCheck(!isWhiteTurn);

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    isWhiteTurn = !isWhiteTurn;
  }

  @override
  Widget build(BuildContext context) {
    double boardSize = MediaQuery.of(context).size.width * 0.5;

    return Scaffold( 
       appBar: AppBar(
        title: const Text("Chess", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, 
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Pickgame
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Pickgame()),
            );
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),
          Text(
            checkStatus ? "CHECK!" : "",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Center(
            child: Container(
              width: boardSize,
              height: boardSize,
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                itemCount: 64,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;

                  bool isSelected = selectedRow == row && selectedCol == col;
                  bool isValidMove = validMoves.any(
                      (move) => move[0] == row && move[1] == col);

                  return Square(
                    isWhite: (row + col) % 2 == 0,
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

