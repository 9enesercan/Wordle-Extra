// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yazlab_2_2/common/colors.dart';
import 'package:yazlab_2_2/features/pages/views/room_page.dart';

class Home extends StatefulWidget {
  final String email;

  const Home({super.key, required this.email});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = '?';
  String userid = '0';
  final String _databaseUrl =
      'https://yazlab-2-2-2929-default-rtdb.europe-west1.firebasedatabase.app';

  late DatabaseReference _dbRef;

  String? selectedGame;
  int? selectedGameint;
  int? selectedLetterCount;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    getUsernameAndId();
  }

  Future<void> _initializeFirebase() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    // Get FirebaseApp instance
    FirebaseApp app = await Firebase.initializeApp();
    // Initialize FirebaseDatabase with FirebaseApp instance and database URL
    _dbRef =
        FirebaseDatabase.instanceFor(app: app, databaseURL: _databaseUrl).ref();
  }

  void getUsernameAndId() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        if (userDoc.data().containsKey('username')) {
          setState(() {
            username = userDoc.data()['username'];
            userid = userDoc.data()['id'];
          });
        } else {
          print("Kullanıcı adı bulunamadı.");
        }
      } else {
        print("Eşleşen kullanıcı bulunamadı.");
      }
    } catch (e) {
      print("Veri çekerken bir hata oluştu: $e");
    }
  }

  void navigateToRoom() {
    if (selectedGame != null && selectedLetterCount != null) {
      String roomId = "room_$selectedGameint";
      roomId = "${roomId}_$selectedLetterCount";

      joinRoom(roomId, userid.toString(), username);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomPage(
              roomId: roomId,
              userId: userid,
              username: username,
              letterCount: selectedLetterCount!,
              gameMode: selectedGameint.toString()),
        ),
      );
    }
  }

  void joinRoom(String roomId, String userId, String username) {
    // Oyuncu bilgilerini tutan bir map yapısı oluşturuluyor.
    Map<String, dynamic> playerData = {
      userId: {'status': true, 'username': username}
    };

    // Belirtilen oda ID'sinin altında, 'players' düğümüne yeni oyuncu bilgilerini ekleyin.
    _dbRef
        .child('rooms')
        .child(roomId)
        .child('players')
        .update(playerData)
        .then((_) {
      print("Oyuncu eklendi: $userId");
    }).catchError((error) {
      print("Oyuncu eklenirken bir hata oluştu: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Oyunu Seçimleri'),
        backgroundColor: appbarColor,
      ),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            roundedContainer(
              child: Text(
                  'Hoş Geldin, $username!\nLütfen bir oyun modu ve ardından harf sayısını seç.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  )),
            ),
            const SizedBox(height: 30),
            gameOptionButton('Normal Mod', buttonColorGrey),
            const SizedBox(height: 15),
            gameOptionButton('Sabit Harf Modu', buttonColorGrey),
            const SizedBox(height: 30),
            if (selectedGame != null) letterCountSelection(),
            const SizedBox(height: 30),
            continueButton(),
          ],
        ),
      ]),
    );
  }

  Widget roundedContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Adjust opacity as needed
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget gameOptionButton(String gameName, Color color) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedGame == gameName ? buttonColor : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        onPressed: () {
          setState(() {
            selectedGame = gameName;
            if (gameName == 'Normal Mod') {
              selectedGameint = 1;
            } else {
              selectedGameint = 2;
            }
          });
        },
        child: Text(gameName,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: containerColor)),
      ),
    );
  }

  Widget letterCountSelection() {
    return Wrap(
      spacing: 40,
      runSpacing: 20,
      children: List.generate(4, (index) {
        int numLetters = 4 + index;
        bool isSelected = selectedLetterCount == numLetters;
        return ChoiceChip(
          label: Text(
            '$numLetters Harf',
            style: TextStyle(
              fontSize: 18,
              color: isSelected
                  ? Colors.white
                  : Colors
                      .black, // Seçili durumda metin rengi beyaz, değilse siyah
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              selectedLetterCount = selected ? numLetters : null;
            });
          },
          showCheckmark: false, // Tik işaretini gösterme
          selectedColor: buttonColor, // Seçili arka plan rengi
          backgroundColor: Colors.grey[300], // Normal arka plan rengi
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      }),
    );
  }

  Widget continueButton() {
    return ElevatedButton(
      onPressed: (selectedGame != null && selectedLetterCount != null)
          ? navigateToRoom
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
      child: const Text('Devam Et',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: titleColor)),
    );
  }
}
