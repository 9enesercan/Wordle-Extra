import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yazlab_2_2/features/pages/views/end_page.dart';

class GamePage extends ConsumerStatefulWidget {
  final String word;
  final DatabaseReference dbRef;
  final String userId;
  final String gameId;

  const GamePage({
    super.key,
    required this.dbRef,
    required this.word,
    required this.userId,
    required this.gameId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _guesses = [];

  @override
  void initState() {
    super.initState();
    _controller
        .addListener(() => setState(() {})); // Listen to text field changes
  }

  void saveGuesses() {
    widget.dbRef
        .child('games/${widget.gameId}/players/${widget.userId}/guesses')
        .set(_guesses);
  }

  void checkGuess(String guess) {
    if (guess.isEmpty) return; // Prevent empty guesses

    if (guess.length != widget.word.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kelime ${widget.word.length} harfli olmalıdır!")));
      return;
    }

    setState(() {
      _guesses.add(guess);
    });

    if (guess == widget.word) {
      showEndGameDialog('Tebrikler!', 'Doğru kelimeyi buldunuz!');
      return;
    } else if (_guesses.length >= widget.word.length) {
      showEndGameDialog('Oyun Bitti',
          'Maalesef hakkınız bitti. Doğru kelime: ${widget.word}');
      return;
    }

    _controller.clear(); // Clear the text field after each guess
  }

  void showEndGameDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on tap outside
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              saveGuesses();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => EndPage(
                          dbRef: widget.dbRef,
                          userId: widget.userId,
                          gameId: widget.gameId,
                        )),
              );
            },
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Color getLetterColor(int index, String letter) {
    if (letter == widget.word[index]) {
      return Colors.green;
    } else if (widget.word.contains(letter)) {
      return Colors.yellow;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wordle Oyunu'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  hintText: "Kelimenizi girin",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _controller.text.isEmpty
                        ? null
                        : () => checkGuess(_controller.text),
                  )),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _guesses.length,
              itemBuilder: (context, index) {
                String guess = _guesses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(guess.length, (i) {
                        return Container(
                          padding: EdgeInsets.all(8.0),
                          color: getLetterColor(i, guess[i]),
                          child: Text(guess[i].toUpperCase(),
                              style: TextStyle(fontSize: 24)),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
