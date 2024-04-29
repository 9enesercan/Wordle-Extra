// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:yazlab_2_2/features/pages/views/choose_word.dart';

class RoomPage extends StatefulWidget {
  final String roomId;
  final String userId;
  final String username;
  final int letterCount;
  final String gameMode;

  const RoomPage({
    super.key,
    required this.roomId,
    required this.userId,
    required this.username,
    required this.letterCount,
    required this.gameMode,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with WidgetsBindingObserver {
  final String _databaseUrl =
      'https://yazlab-2-2-2929-default-rtdb.europe-west1.firebasedatabase.app';
  DatabaseReference? _dbRef;
  List<Map<String, dynamic>> gameRequests = [];
  List<Map<String, String>> players = [];
  bool isRequestsExpanded = false;
  bool isPlayersExpanded = false;
  String? gameid;
  String? targetid;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    WidgetsBinding.instance.addObserver(this);
    var roomidTmp = widget.roomId;
    var userkeyTmp = widget.userId;
    FirebaseApp app = Firebase.app();

    _dbRef =
        FirebaseDatabase.instanceFor(app: app, databaseURL: _databaseUrl).ref();
    setState(() {});
    _dbRef!
        .child('rooms/$roomidTmp/players/$userkeyTmp')
        .onDisconnect()
        .remove();

    listenToGameRequests();
    listenToPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Oda ${widget.roomId}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await _leaveRoom(widget.roomId, widget.userId);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        // Adds scrolling to the entire page content
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adds spacing between title and content
                  buildGameRequests(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Odadaki Oyuncular",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  buildPlayerList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseApp app = Firebase.app();
    _dbRef =
        FirebaseDatabase.instanceFor(app: app, databaseURL: _databaseUrl).ref();
    setState(() {});
  }

  void listenToGameRequests() {
    try {
      _dbRef!
          .child('rooms/${widget.roomId}/game_requests')
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> updatedRequests = [];
          data.forEach((key, value) {
            if (value['to'] == widget.userId) {
              // Only the requests to me
              updatedRequests.add({
                'from': value['from'],
                'senderName': value['senderName'],
                'status': value['status'],
                'key': key
              });
            }

            if (value['from'] == widget.userId &&
                value['status'] == 'accepted') {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChooseWordPage(
                                letterCount: widget.letterCount,
                                gameId: gameid!,
                                dbRef: _dbRef!,
                                userId: widget.userId,
                              )))
                  .then((value) => _leaveRoom(widget.roomId, widget.userId));
            }
          });
          setState(() {
            gameRequests = updatedRequests;
          });
        } else {
          setState(() {
            gameRequests = [];
          });
        }
      });
    } on Exception {
      setState(() {
        gameRequests = [];
      });
    }
  }

  void listenToPlayers() {
    _dbRef!.child('rooms/${widget.roomId}/players').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, String>> updatedPlayers = [];
        data.forEach((key, value) {
          updatedPlayers.add({
            'key': key,
            'username': value['username'],
            'status': value['status'] != null
                ? value['status'].toString()
                : 'offline',
          });
        });
        setState(() {
          players = updatedPlayers.cast<
              Map<String, String>>(); // Cast the list to the appropriate type
        });
      }
    });
  }

  Future<void> sendGameRequest(String targetUserId) async {
    targetid = targetUserId;
    if (_dbRef == null) {
      print('Database reference is not initialized.');
      return;
    }

    gameid = widget.userId +
        targetUserId; // Unique ID for the game request combining both user IDs.

    try {
      await _dbRef!.child('rooms/${widget.roomId}/game_requests/$gameid').set({
        'to': targetUserId,
        'from': widget.userId,
        'status': 'pending',
        'senderName':
            widget.username, // Assuming you have username field in your widget.
        'timestamp': ServerValue
            .timestamp, // Adds a timestamp for when the request was sent.
      });

      print('Game request sent to user $targetUserId.');

      // Start a timer to delete the game request after 10 seconds
      Timer(Duration(seconds: 10), () async {
        try {
          await _dbRef!
              .child('rooms/${widget.roomId}/game_requests/$gameid')
              .remove();
          print('Game request automatically removed after 10 seconds.');
        } catch (e) {
          print('An error occurred while removing game request: $e');
        }
      });
    } catch (e) {
      print('An error occurred while sending game request: $e');
    }
  }

  Future<void> acceptGameRequest(String requestId, String SenderName) async {
    // First, get the request details.
    DatabaseEvent event = await _dbRef!
        .child('rooms/${widget.roomId}/game_requests/$requestId')
        .once();
    if (!event.snapshot.exists) {
      print("Game request does not exist.");
      return;
    }

    // Extract request data.
    Map<String, dynamic> requestData =
        (event.snapshot.value as Map<dynamic, dynamic>).cast<String, dynamic>();
    String fromUserId = requestData['from'];
    String toUserId = requestData['to'];

    // Update the game request to 'accepted'.
    await _dbRef!
        .child('rooms/${widget.roomId}/game_requests/$requestId')
        .update({'status': 'accepted'});

    Map<String, dynamic> players = {
      fromUserId: {'username': SenderName},
      toUserId: {'username': widget.username}
    };

    // Create a new game session under 'games'.
    String gameId = requestId;
    await _dbRef!.child('games/$gameId').set({
      'players': players,
      'roomId': widget.roomId,
      'gameType': widget.gameMode,
      'letterCount': widget.letterCount,
      // Storing roomId if needed for reference
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChooseWordPage(
                  letterCount: widget.letterCount,
                  gameId: gameId,
                  dbRef: _dbRef!,
                  userId: widget.userId,
                ))).then((value) => _leaveRoom(widget.roomId, widget.userId));

    print('New game created with ID: $gameId');
  }

  Future<void> declineGameRequest(String requestId) async {
    await _dbRef!
        .child('rooms/${widget.roomId}/game_requests/$requestId')
        .remove();
  }

  Future<void> _leaveRoom(String roomId, String userKey) async {
    if (_dbRef == null) {
      print('Database reference is not initialized.');
      return;
    }

    try {
      await _dbRef!.child('rooms/$roomId/players/$userKey').remove();
      print('User successfully removed from the room.');
    } catch (e) {
      print('An error occurred while trying to leave the room: $e');
    }
  }

  Widget buildGameRequests() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Oyun İstekleri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          physics:
              NeverScrollableScrollPhysics(), // Disables scrolling within the ListView itself
          shrinkWrap:
              true, // Allows ListView to take minimum space that fits children
          itemCount: gameRequests.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 4, // Adds shadow under the card
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title:
                    Text('Oyun isteği: ${gameRequests[index]['senderName']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => acceptGameRequest(
                          gameRequests[index]['key'],
                          gameRequests[index]['senderName']),
                      color: Colors.green,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () =>
                          declineGameRequest(gameRequests[index]['key']),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              Divider(), // Adds a divider between items
        ),
      ],
    );
  }

  Widget buildPlayerList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: players.length,
      itemBuilder: (BuildContext context, int index) {
        if (players[index]['key'] == widget.userId) {
          return SizedBox.shrink(); // Skip rendering for the current user
        }

        // Ensure status is interpreted as a boolean correctly
        bool isActive = players[index]['status'] == 'true';

        return ListTile(
          title: Text(
            players[index]['username']!,
            style: TextStyle(color: Colors.black), // Set text color to white
          ),
          trailing: ElevatedButton(
            onPressed:
                isActive ? () => sendGameRequest(players[index]['key']!) : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  // Check if the button is disabled, change color accordingly
                  if (!isActive) return Colors.red; // If not active, show red
                  return Colors.green; // Otherwise, show green
                },
              ),
            ),
            child: Text(
              'Play',
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ),
        );
      },
    );
  }
}
