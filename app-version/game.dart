import 'package:flutter/material.dart';
import 'dart:math';

class Game extends StatefulWidget {
  final String difficulty;
  final ValueChanged<String> setDifficulty;

  const Game({Key? key, required this.difficulty, required this.setDifficulty}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int playerScore = 0;
  int botScore = 0;
  List<Map<String, dynamic>> dots = [];
  int timeLeft = 30;
  int dotGenerationTime = 2000;
  int botResponseTime = 2000;
  List<Map<String, dynamic>> gameHistory = [];
  bool gameStarted = false;
  var intervalId;

  @override
  void dispose() {
    if (gameStarted) {
      endGame();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(Game oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (gameStarted) {
      endGame();
    }
    switch (widget.difficulty) {
      case 'easy':
        setState(() {
          dotGenerationTime = 3000;
          botResponseTime = 3000;
        });
        break;
      case 'medium':
        setState(() {
          dotGenerationTime = 2000;
          botResponseTime = 2000;
        });
        break;
      case 'hard':
        setState(() {
          dotGenerationTime = 1000;
          botResponseTime = 500;
        });
        break;
      default:
        setState(() {
          dotGenerationTime = 2000;
          botResponseTime = 2000;
        });
    }
  }

  void startGame() {
    setState(() {
      playerScore = 0;
      botScore = 0;
      timeLeft = 30;
      gameStarted = true;
      dots = [];
    });
    intervalId = setInterval();
  }

  void endGame() {
    clearInterval();
    setState(() {
      gameStarted = false;
      var winner = 'tie';
      if (playerScore > botScore) {
        winner = 'player';
      } else if (botScore > playerScore) {
        winner = 'bot';
      }
      gameHistory.add({
        'playerScore': playerScore,
        'botScore': botScore,
        'difficulty': widget.difficulty,
        'winner': winner
      });
    });
  }

  void handleDotClick(String id) {
    int dotIndex = dots.indexWhere((dot) => dot['id'] == id);
    if (dotIndex != -1) {
      List<Map<String, dynamic>> newDots = List.from(dots);
      newDots.removeAt(dotIndex);
      setState(() {
        dots = newDots;
        playerScore++;
      });
    }
  }

  void generateDots() {
    const gameAreaWidth = 300.0;
    const gameAreaHeight = 300.0;
    const dotSize = 20.0;
    const dotRadius = dotSize / 2;

    final RenderBox gameAreaRenderBox = gameAreaKey.currentContext!.findRenderObject() as RenderBox;
    final gameAreaOffset = gameAreaRenderBox.localToGlobal(Offset.zero);

    final double gameAreaTop = gameAreaOffset.dy;
    final double gameAreaLeft = gameAreaOffset.dx;
    final double gameAreaBottom = gameAreaOffset.dy + gameAreaHeight;
    final double gameAreaRight = gameAreaOffset.dx + gameAreaWidth;

    List<Map<String, dynamic>> newDots = List.generate(10, (index) {
double x = Random().nextInt((gameAreaWidth - dotSize).floor()).toDouble() + gameAreaLeft + dotRadius;
double y = Random().nextInt((gameAreaHeight - dotSize).floor()).toDouble() + gameAreaTop + dotRadius;
String id = DateTime.now().millisecondsSinceEpoch.toString() + '-' + index.toString();
return {
'id': id,
'x': x,
'y': y,
};
});
setState(() {
dots.addAll(newDots);
});
}

void botClick() {
if (dots.isNotEmpty) {
int index = Random().nextInt(dots.length);
String id = dots[index]['id'];
handleDotClick(id);
botScore++;
}
}

void updateTimer() {
setState(() {
timeLeft--;
});
if (timeLeft == 0) {
endGame();
}
}

int setInterval() {
return Timer.periodic(Duration(milliseconds: dotGenerationTime), (timer) {
if (gameStarted) {
generateDots();
} else {
timer.cancel();
}
});
}

void clearInterval() {
if (intervalId != null) {
intervalId.cancel();
intervalId = null;
}
}

@override
Widget build(BuildContext context) {
return Column(
children: [
SizedBox(
height: 20,
),
Text(
'Time left: $timeLeft',
style: TextStyle(fontSize: 20),
),
SizedBox(
height: 20,
),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
Column(
children: [
Text(
'Player',
style: TextStyle(fontSize: 20),
),
SizedBox(
height: 10,
),
Text(
'$playerScore',
style: TextStyle(fontSize: 30),
),
],
),
Column(
children: [
Text(
'Bot',
style: TextStyle(fontSize: 20),
),
SizedBox(
height: 10,
),
Text(
'$botScore',
style: TextStyle(fontSize: 30),
),
],
),
],
),
SizedBox(
height: 20,
),
Expanded(
child: GestureDetector(
onTapDown: (details) {
if (gameStarted) {
handleDotClick('');
}
},
child: Container(
key: gameAreaKey,
decoration: BoxDecoration(
color: Colors.grey[200],
borderRadius: BorderRadius.circular(20),
),
child: Stack(
children: [
for (var dot in dots)
Positioned(
left: dot['x'] - dotRadius,
top: dot['y'] - dotRadius,
child: GestureDetector(
onTap: () {
if (gameStarted) {
handleDotClick(dot['id']);
}
},
child: Container(
width: dotSize,
height: dotSize,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.blueAccent,
),
),
),
),
],
),
),
),
),
SizedBox(
height: 20,
),
ElevatedButton(
onPressed: () {
if (!gameStarted) {
startGame();
}
},
child: Text(
'Start Game',
style: TextStyle(fontSize: 20),
),
),
SizedBox(
height: 20,
),
ElevatedButton(
onPressed: () {
widget.setDifficulty('');
},
child: Text(key: gameAreaKey,
width: 300,
height: 300,
decoration: BoxDecoration(
border: Border.all(
width: 1,
color: Colors.black,
),
),
child: Stack(
children: [
...dots.map((dot) {
return Positioned(
left: dot['x'] - 10,
top: dot['y'] - 10,
child: GestureDetector(
onTap: () => handleDotClick(dot['id']),
child: Container(
width: 20,
height: 20,
decoration: BoxDecoration(
color: Colors.red,
shape: BoxShape.circle,
),
),
),
);
}).toList(),
],
),
),
),
SizedBox(
height: 20,
),
gameStarted ? SizedBox.shrink() : ElevatedButton(
onPressed: startGame,
child: Text('Start Game'),
),
],
);
}
}










