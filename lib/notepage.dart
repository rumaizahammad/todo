import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CollectionReference note =
      FirebaseFirestore.instance.collection('note');
  TextEditingController itemname = TextEditingController();
  ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());

  void addnote() {
    final data = {
      'item': itemname.text,
      'date': selectdate,
    };
    note.add(data);
  }

  void deletenote(docId) {
    note.doc(docId).delete();
  }

  DateTime selectdate = DateTime.now();
  String a = "select date";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          title: const Text(
            "TO DO",
            
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 0, 27, 94)),
          backgroundColor: Color.fromARGB(255, 233, 182, 86),
        ),
        backgroundColor: Color.fromARGB(255, 71, 80, 97),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                actions: [
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            final DateTime? dateTime = await showDatePicker(
                                    context: context,
                                    initialDate: selectdate,
                                    firstDate: DateTime(1995),
                                    lastDate: DateTime(2050))
                                .then((value) {
                              selectdate = value!;
                            });
                          },
                          child: ValueListenableBuilder(
                            valueListenable: date,
                            builder: (context, value, child) {
                              return Text(
                                  '${value.day}/${value.month}/${value.year}');
                            },
                          )),
                      TextField(
                        controller: itemname,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text(" add a note"),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            addnote();
                            Navigator.pop(context);
                          },
                          child: Text("submit"))
                    ],
                  )
                ],
                title: const Text("Add note list"),
                contentPadding: const EdgeInsets.all(20.0),
              ),
            );
          },
          child: Icon(Icons.note),
        ),
        body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEGVMFNZXmDl0TqX2eh0tyRFcKqFZPiJgPdQ&usqp=CAU", // Replace with your background image URL
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
         StreamBuilder<QuerySnapshot>(
          stream: note.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot notesnap =
                        snapshot.data!.docs[index];
                    DateTime date = (notesnap['date'] as Timestamp).toDate();

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white60,
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(255, 239, 220, 220),
                                  blurRadius: 50,
                                  spreadRadius: 20)
                            ]),
                        height: 90,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            title: Text(notesnap['item']),
                            subtitle: Text(
                                '${date.day.toString()}/${date.month.toString()}/${date.year.toString()}'),
                            trailing: IconButton(
                              color: Color.fromARGB(255, 255, 53, 39),
                              onPressed: () {
                                deletenote(notesnap.id);
                              },
                              icon: Icon(Icons.delete),
                            
                          
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        )]));
  }
}