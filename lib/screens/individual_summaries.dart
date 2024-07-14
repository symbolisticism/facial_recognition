import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());
var db = FirebaseFirestore.instance;

class IndividualSummaries extends StatefulWidget {
  const IndividualSummaries({super.key});

  @override
  State<IndividualSummaries> createState() => _IndividualSummariesState();
}

class _IndividualSummariesState extends State<IndividualSummaries> {
  Widget? content;
  Map<String, int> employeeHours = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Summaries'),
      ),
      body: FutureBuilder<Widget>(
        future: getAggregateReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              logger.e(snapshot.error);
              return Center(child: Text('${snapshot.error} has occurred.'));
            } else if (snapshot.hasData &&
                content != null &&
                employeeHours.isNotEmpty) {
              return content!;
            } else if (snapshot.hasData &&
                content != null &&
                employeeHours.isEmpty) {
              return const Center(
                child: Text('Nothing to report.'),
              );
            } else {
              return const Center(
                child: Text('An unexpected error has occurred.'),
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<Widget> getAggregateReport() async {
    final QuerySnapshot querySnapshot = await db.collection('clocks').get();

    for (var doc in querySnapshot.docs) {
      final employeeid = doc.get('employeeid') as String;
      final firstname = doc.get('firstname') as String;
      final lastname = doc.get('lastname') as String;
      final fullname = '$firstname $lastname';
      final minutes = doc.get('timeworked-minutes') as int;

      if (employeeHours.containsKey(employeeid)) {
        employeeHours[fullname] = employeeHours[employeeid]! + minutes;
      } else {
        employeeHours[fullname] = minutes;
      }
    }

    return content = Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView.builder(
        itemCount: employeeHours.length,
        itemBuilder: (context, index) {
          String fullname = employeeHours.keys.elementAt(index);
          int totalMinutes = employeeHours[fullname] as int;

          return ListTile(
            title: Text(
              'Name: $fullname',
              style: const TextStyle(color: Colors.black),
            ),
            trailing: Text(
              'Hours worked: ${(totalMinutes / 60).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }
}
