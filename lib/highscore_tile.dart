import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighscoreTile extends StatelessWidget {
  final String documentId;
  const HighscoreTile({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //get the coll of higsc
    CollectionReference highscores =
        FirebaseFirestore.instance.collection('highscores');

    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Row(
            children: [
              Text(
                data['score'].toString(),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                data['name'],
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                ),
              ),
            ],
          );
        } else {
          return const Text('Loading...');
        }
      },
    );
  }
}
