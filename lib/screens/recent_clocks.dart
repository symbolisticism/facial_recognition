import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final db = FirebaseFirestore.instance;
var logger = Logger(printer: PrettyPrinter());

class RecentClocks extends StatefulWidget {
  const RecentClocks({super.key});

  @override
  State<RecentClocks> createState() => _RecentClocksState();
}

class _RecentClocksState extends State<RecentClocks> {
  Widget content = const Center(child: Text('Default Content'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Clock History'),
      ),
      body: FutureBuilder<Widget>(
          future: getLastTenClocks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                logger.e(snapshot.error);
                return Center(child: Text('${snapshot.error} has occurred.'));
              } else if (snapshot.hasData) {
                return content;
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<Widget> getLastTenClocks() async {
    final Query query = db
        .collection('clocks')
        .orderBy('firstname', descending: true)
        .limit(10);
    await query.get().then((querySnapshot) {
      logger.d('Query successfully completed');
      var listTiles = <Widget>[];
      for (var docSnapshot in querySnapshot.docs) {
        listTiles.add(ListTile(
          leading: Text(
            docSnapshot.get('employeeid'),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          title: Text(
            '${docSnapshot.get('firstname')} ${docSnapshot.get('lastname')}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            '${docSnapshot.get('hour')}:${docSnapshot.get('minute')}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${docSnapshot.get('month')}/${docSnapshot.get('day')}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ));
      }
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: listTiles),
      );
    });
    return content;
  }
}
