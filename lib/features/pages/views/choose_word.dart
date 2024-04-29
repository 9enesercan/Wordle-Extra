// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: library_private_types_in_public_api, empty_catches, avoid_print, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:yazlab_2_2/features/pages/views/game_page.dart';

class ChooseWordPage extends StatefulWidget {
  final int letterCount;
  final String gameId;
  final DatabaseReference dbRef;
  final String userId;

  const ChooseWordPage({
    super.key,
    required this.letterCount,
    required this.gameId,
    required this.dbRef,
    required this.userId,
  });

  @override
  _ChooseWordPageState createState() => _ChooseWordPageState();
}

class _ChooseWordPageState extends State<ChooseWordPage> {
  bool userReady = false;
  bool opponentReady = false;
  String opponentWord = '';
  String? targetid;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    listenToOpponentWord();

    widget.dbRef
        .child('games/${widget.gameId}/players')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (key != widget.userId) {
            targetid = key;
          }
        });
      }
    });
  }

  void listenToOpponentWord() {
    widget.dbRef
        .child('games/${widget.gameId}/players')
        .orderByKey()
        .equalTo(widget.userId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        Map<dynamic, dynamic>? userData = data[widget.userId];
        if (userData != null && userData.containsKey('Word')) {
          setState(() {
            opponentWord = userData['Word'];

            if (opponentWord != '') {
              opponentReady = true;
              checkAndNavigate();
            }
          });
        }
      }
    });
  }

  void checkAndNavigate() {
    if (userReady && opponentReady) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GamePage(
                  word: opponentWord,
                  dbRef: widget.dbRef,
                  gameId: widget.gameId,
                  userId: widget.userId,
                )),
      );
    }
  }

  void _submitWord() async {
    final String word = _controller.text.trim();
    if (word.length == widget.letterCount) {
      try {
        await widget.dbRef
            .child('games/${widget.gameId}/players/$targetid/Word')
            .set(word);
        setState(() {
          userReady = true;
          checkAndNavigate();
        });
      } catch (error) {
        _showSnackBar('Failed to submit the word: $error');
      }
    } else {
      _showSnackBar('Word must be exactly ${widget.letterCount} letters long.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a Word"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a word with ${widget.letterCount} letters',
              ),
              maxLength: widget.letterCount,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitWord,
              child: Text('Submit Word'),
            ),
          ],
        ),
      ),
    );
  }
}
