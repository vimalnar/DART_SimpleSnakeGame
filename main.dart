import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for keyboard input

// Entry point of the application.
void main() => runApp(SnakeGame());

// The main widget of the app. It creates a MaterialApp.
class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      home: GamePage(), // The home page of the app is set to GamePage.
    );
  }
}

// StatefulWidget that represents the game's main page.
class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

// State of the GamePage. Contains the game logic.
class _GamePageState extends State<GamePage> {
  final FocusNode focusNode = FocusNode(); // Focus node for keyboard listener.
  final int gridSize = 30; // Defines the size of the grid.
  final int speed = 200; // Speed of the snake's movement in milliseconds.
  int foodCount = 0; // Tracks the number of foods the snake has eaten.

  // Initial positions of the snake. Starts with a length of 2.
  List<Offset> snakePositions = [
    Offset(0, 0), // Head of the snake
  ];
  Offset foodPosition = Offset(5, 5); // Initial position of the food.
  String direction = 'right'; // Initial direction of snake movement.
  Timer? timer; // Timer to control the snake's movement.

  // initState is called when this object is inserted into the tree.
  @override
  void initState() {
    super.initState();
    // Show the start game dialog after the initial build.
    WidgetsBinding.instance?.addPostFrameCallback((_) => showStartDialog(context));
  }

  // Shows a dialog when the game starts.
  void showStartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog must be dismissed by pressing a button.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Start Game'),
          content: Text('Use the arrow keys to move your g reen snake, and try and collect the red food. Click here to start!'),
          actions: <Widget>[
            TextButton(
              child: Text('Start'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog.
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  // Starts the game.
  void startGame() {
    focusNode.requestFocus(); // Sets focus to enable keyboard inputs.
    // Sets up a timer that repeatedly calls moveSnake.
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer t) => moveSnake());
  }

  // Logic for moving the snake.
  void moveSnake() {
    setState(() {
      // Calculate new head position based on current direction.
      Offset newHead;
      switch (direction) {
        case 'up':
          newHead = snakePositions.last.translate(0, -1.0);
          break;
        case 'down':
          newHead = snakePositions.last.translate(0, 1.0);
          break;
        case 'left':
          newHead = snakePositions.last.translate(-1.0, 0);
          break;
        case 'right':
          newHead = snakePositions.last.translate(1.0, 0);
          break;
        default:
          newHead = snakePositions.last;
      }

      // Check if snake has hit the wall or itself.
      if (newHead.dx < 0 || newHead.dy < 0 || newHead.dx >= gridSize || newHead.dy >= gridSize || snakePositions.contains(newHead)) {
        timer?.cancel(); // Stop the game.
        showDialog( // Show game over dialog.
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Game Over'),
            content: Text('You ate $foodCount foods!'), // Display the score.
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: Text('Restart'),
              ),
            ],
          ),
        );
        return;
      }

      // Update the position of the snake.
      snakePositions.add(newHead);
      if (newHead == foodPosition) {
        foodCount++; // Increase food count.
        generateNewFood(); // Generate new food.
      } else {
        snakePositions.removeAt(0); // Move the snake forward by removing the tail.
      }
    });
  }

  // Generates a new food position.
  void generateNewFood() {
    Random random = Random();
    foodPosition = Offset(
      random.nextInt(gridSize).toDouble(),
      random.nextInt(gridSize).toDouble(),
    );
  }

  // Resets the game to its initial state.
  void resetGame() {
    snakePositions = [Offset(0, 0)];
    direction = 'right';
    foodCount = 0;
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer t) => moveSnake());
    generateNewFood();
  }

  // Changes the direction of the snake.
  void changeDirection(String newDirection) {
    // Prevent the snake from reversing on itself.
    if ((direction == 'up' && newDirection != 'down') ||
        (direction == 'down' && newDirection != 'up') ||
        (direction == 'left' && newDirection != 'right') ||
        (direction == 'right' && newDirection != 'left')) {
      direction = newDirection;
    }
  }

  // Builds the UI of the game.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: focusNode,
        onKey: (event) {
          // Keyboard event handling for arrow keys.
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              changeDirection('up');
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              changeDirection('down');
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              changeDirection('left');
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              changeDirection('right');
            }
          }
        },
        child: GridView.builder(
          itemCount: gridSize * gridSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
          ),
          itemBuilder: (BuildContext context, int index) {
            var color;
            // Determine the position and color for each cell in the grid.
            Offset pos = Offset(
              (index % gridSize).toDouble(),
              (index ~/ gridSize).toDouble()
            );

            // Color the cell based on whether it's part of the snake, food, or empty space.
            if (snakePositions.contains(pos)) {
              color = Colors.green[500]; // Snake color
            } else if (pos == foodPosition) {
              color = Colors.red; // Food color
            } else {
              color = Colors.grey[900]; // Empty space color
            }
            return Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
              ),
            );
          },
        ),
      ),
    );
  }
}
