// ignore_for_file: camel_case_types

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/highscore_tile.dart';
import 'package:snake_game/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { up, down, left, right }

class _HomePageState extends State<HomePage> {
  //grid dimensions
  int rowSize = 20;
  int totalNumOfSquares = 400;

  //game settings
  bool gameHasStarted = false;
  final _nameController = TextEditingController();
  //user score
  int currentScore = 0;

  //snake position
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  //snake direction is initialy to the right
  var currentDirection = snake_Direction.right;

  //food position
  int foodPos = 150;
  int foodPos2 = 322;
  //higtscore list
  // ignore: non_constant_identifier_names
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('highscores')
        .orderBy('score', descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //start game
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        //keep the snake moving!
        moveSnake();
        //check if the game is over
        if (gameOver()) {
          timer.cancel();
          //display the message to user
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Game over!'),
                content: Column(
                  children: [
                    Text('Your score is: ${currentScore.toString()}'),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Enter name'),
                    ),
                  ],
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      submitScore();
                      newGame();
                    },
                    color: Colors.pink,
                    child: const Text('Submit'),
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void submitScore() {
    //get accex to the collection
    var database = FirebaseFirestore.instance;
    //add data in firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos == 150;
      foodPos2 == 323;
      currentDirection = snake_Direction.right;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    //making shure the new food is not where the snake is
    while (snakePos.contains(foodPos) || snakePos.contains(foodPos2)) {
      if (snakePos.contains(foodPos)) {
        foodPos = Random().nextInt(totalNumOfSquares);
      } else if (snakePos.contains(foodPos2)) {
        foodPos2 = Random().nextInt(totalNumOfSquares);
      }
    }
  }

  void moveSnake() {
    if (currentDirection == snake_Direction.right) {
      //add a new head
      //if snake is at the right wall, need to re-adjust
      if (snakePos.last % rowSize == 19) {
        snakePos.add(snakePos.last + 1 - rowSize);
      } else {
        snakePos.add(snakePos.last + 1);
      }
    } else if (currentDirection == snake_Direction.left) {
      //add a new head
      //if snake is at the right wall, need to re-adjust
      if (snakePos.last % rowSize == 0) {
        snakePos.add(snakePos.last - 1 + rowSize);
      } else {
        snakePos.add(snakePos.last - 1);
      }
    } else if (currentDirection == snake_Direction.up) {
      //add a new head
      if (snakePos.last < rowSize) {
        snakePos.add(snakePos.last - rowSize + totalNumOfSquares);
      } else {
        snakePos.add(snakePos.last - rowSize);
      }
    } else if (currentDirection == snake_Direction.down) {
      //add a new head
      if (snakePos.last + rowSize > totalNumOfSquares) {
        snakePos.add(snakePos.last + rowSize - totalNumOfSquares);
      } else {
        snakePos.add(snakePos.last + rowSize);
      }
    }
    // snake is eating food

    if (snakePos.last == foodPos || snakePos.last == foodPos2) {
      eatFood();
    } else {
      //remove the tail
      snakePos.removeAt(0);
    }
  }

  // game over
  bool gameOver() {
    //the game is over when the snake runs into itself
    //this occurs when there is a dublicate pos in the snakePos list

    //body of the snake(no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Direction.up) {
            currentDirection = snake_Direction.down;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != snake_Direction.down) {
            currentDirection = snake_Direction.up;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != snake_Direction.right) {
            currentDirection = snake_Direction.left;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Direction.left) {
            currentDirection = snake_Direction.right;
          }
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              //high scores
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // user current score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(children: <Widget>[
                            Text(
                              'Current score',
                              style: TextStyle(
                                fontSize: 13,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 4
                                  ..color = Colors.green[900]!,
                              ),
                            ),
                            Text(
                              'Current score',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.greenAccent[100],
                              ),
                            ),
                          ]),
                          Text(
                            currentScore.toString(),
                            style: const TextStyle(
                                fontSize: 36, color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    ),
                    // highscores, top 10
                    //const Text('highscores...'),
                    Expanded(
                      child: gameHasStarted
                          ? Container()
                          : FutureBuilder(
                              future: letsGetDocIds,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: highscore_DocIds.length,
                                  itemBuilder: ((context, index) {
                                    return HighscoreTile(
                                        documentId: highscore_DocIds[index]);
                                  }),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              //game grid
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != snake_Direction.up) {
                      //print('move down');
                      currentDirection = snake_Direction.down;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != snake_Direction.down) {
                      //print('move up');
                      currentDirection = snake_Direction.up;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != snake_Direction.left) {
                      //print('move right');
                      currentDirection = snake_Direction.right;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != snake_Direction.right) {
                      //print('move left');
                      currentDirection = snake_Direction.left;
                    }
                  },
                  child: GridView.builder(
                      itemCount: totalNumOfSquares,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowSize),
                      itemBuilder: (context, index) {
                        if (snakePos.contains(index)) {
                          return const SnakePixel();
                        } else if (foodPos == index || foodPos2 == index) {
                          return const FoodPixel();
                        } else {
                          return const BlankPixel();
                        }
                      }),
                ),
              ),
              //play button
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: MaterialButton(
                      color: gameHasStarted ? Colors.grey : Colors.pink,
                      onPressed: gameHasStarted ? () {} : startGame,
                      child: const Text('PLAY'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
