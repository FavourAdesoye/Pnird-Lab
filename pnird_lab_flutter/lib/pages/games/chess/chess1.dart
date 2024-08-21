import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart'; 
import 'utils.dart';

class ChessHome extends StatelessWidget {
 

  const ChessHome({super.key});
 
  @override
  Widget build(context) {
    return  MaterialApp(  
      title: 'Chess',
      home: const ChessHome1(), 
      theme: ThemeData( 
        primarySwatch: Colors.amber, 
      )
    );
  }
} 

class ChessHome1 extends StatefulWidget{
  const ChessHome1({super.key});


 
  @override
  
  // ignore: library_private_types_in_public_api
  _ChessHomeState createState() => _ChessHomeState();
} 

class  _ChessHomeState extends State<ChessHome1> { 
  String _fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';  

  @override
  Widget build(BuildContext context) { 
    final size = MediaQuery.of(context).size; 

    return Scaffold( 
      appBar: AppBar( 
        title: const Text("Chess"),
      ), 
      body: Center( 
        child: Chessboard(fen: _fen, 
        size: size.width,

        onMove: (move) { 
          final nextFen = makeMove( 
            _fen, { 
              'from': move.from, 
              'to': move.to, 
              'promotion': 'q',
            }
          ); 

          if (nextFen != null) { 
            setState(() {
              _fen = nextFen;
            }); 

            Future.delayed(const Duration(milliseconds: 300)).then((_){ 
              final nextMove = getRandomMove(_fen);  

              if(nextMove != null) { 
                setState(() {
                  _fen = makeMove(_fen, nextMove)!;
              });
                }
              });
            }
          },
        ),
      ),
    );
  }
}


