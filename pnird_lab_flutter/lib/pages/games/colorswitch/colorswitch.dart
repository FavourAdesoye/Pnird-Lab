import 'package:flame/components.dart';
import 'package:flutter/material.dart'; 
import 'package:flame/game.dart'; 
import 'package:flame/events.dart'; 

// Create a widget that can be used as a screen or inside a tab
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: MyGame()),
    );
  }
}




class MyGame extends FlameGame {  
  late Player myPlayer;
  @override
  Color backgroundColor() => const Color(0xff222222); 


  @override
  void onMount() { 
    add(myPlayer = Player()); 
    super.onMount();
  }  

  @override
  // ignore: override_on_non_overriding_member
  void onTapDown(TapDownEvent event) { 
    myPlayer.jump(); 
  }

}  

class Player extends PositionComponent { 
  final _velocity = Vector2(0, 30.0); 
  final _gravity = 980.0; 
  final _jumpSpeed = 350.0; 


  @override
  void onMount() { 
    position = Vector2(150,100); 
    super.onMount();
  } 

  @override
  void update(double dt) { 
    super.update(dt); 
    position += _velocity * dt; 
    _velocity.y += _gravity * dt;
  } 

  @override
  void render (Canvas canvas) { 
    super.render(canvas); 
    canvas.drawCircle( 
      position.toOffset(), 
      15, 
      Paint()..color = Colors.yellow);
  } 

  void jump() { 
    _velocity.y = -_jumpSpeed;
  }
  }


