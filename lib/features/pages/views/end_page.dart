import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EndPage extends StatelessWidget {
  final DatabaseReference dbRef;
  final String userId;
  final String gameId;

  const EndPage({
    Key? key,
    required this.dbRef,
    required this.userId,
    required this.gameId,
  }) : super(key: key);

  Future<void> deleteGameData(BuildContext context) async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Oyunu Sil'),
              content: const Text(
                  'Oyun verilerini silmek istediğinize emin misiniz?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hayır'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Evet'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      await dbRef.child('games/$gameId').remove();
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Sonu'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.child('games/$gameId/players').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          } else if (snapshot.hasData &&
              snapshot.data!.snapshot.value != null) {
            final playersData =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            List<Widget> playerWidgets = playersData.entries
                .where((entry) =>
                    entry.value != null &&
                    entry.value['username'] != null &&
                    entry.value['guesses'] != null)
                .map((entry) {
              final value = entry.value as Map<dynamic, dynamic>;
              final playerName = value['username'] as String;
              final guessesList = value['guesses'] == null
                  ? []
                  : List<String>.from(value['guesses'] as List);
              return ListTile(
                title: Text(playerName),
                subtitle: Text(guessesList.join(", ")),
              );
            }).toList();
            return Column(
              children: [
                Expanded(
                  child: ListView(children: playerWidgets),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('Ana Menüye Dön'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () => deleteGameData(context),
                    child: const Text('Oyun Verilerini Sil ve Ana Menüye Dön'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Oyuncu verisi bulunamadı'));
          }
        },
      ),
    );
  }
}
