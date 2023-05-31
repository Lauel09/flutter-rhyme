import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FutureBuilderExampleApp());
}

class FutureBuilderExampleApp extends StatelessWidget {
  const FutureBuilderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FutureBuilderExample(),
    );
  }
}

class FutureBuilderExample extends StatefulWidget {
  const FutureBuilderExample({super.key});

  @override
  State<FutureBuilderExample> createState() => _FutureBuilderExampleState();
}

class _FutureBuilderExampleState extends State<FutureBuilderExample> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController wordController = TextEditingController();
  bool showTable = false;
  String? word;
  bool newWord = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Column(children: [
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0x0fffffff),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle),
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "Enter a word:",
                      alignLabelWithHint: true,
                      floatingLabelStyle: const TextStyle(
                          color: Color(0xFF1cbb7c),
                          fontWeight: FontWeight.w600),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            width: 2, color: Color(0xFF1cbb7c)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      fillColor: Colors.white,
                      filled: true),
                  controller: wordController,
                  keyboardType: TextInputType.name,
                  onSaved: (value) {
                    wordController.text = value!;
                  },
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  if (wordController.text.isNotEmpty) {
                    showTable = true;
                  }
                  word = wordController.text;

                  /// What are we supposed to do here?
                  /// So look, I have created a button, and the text field
                  /// is ready, the button does get pressed and now we need
                  /// to be able to render a table right below the button
                  /// say in case the field is filled, or it has the word
                  /// and it is able to make the request
                  ///
                  /// The current problem I am facing is that the table is not
                  /// rendering properly.
                  /// Maybe it is creating the table DataTable for the rendering
                  /// but it is not able to register it in the List<Widget> that
                  /// these particular widget must be displayed.
                  ///
                  /// Now, the next work I am going to do is to make it possible
                  /// that when the button get pressed, the DataTable is able
                  /// to render itself, while the control being inside the
                  /// ElevatedButton.
                });
              },
              child: const Text("Find Rhyme")),
          wordController.text.isNotEmpty && showTable
              ? BuildPrintTable(word: word!)
              : Container(),
        ]),
      ),
    );
  }
}

class BuildPrintTable extends StatelessWidget {
  const BuildPrintTable({
    super.key,
    required String word,
  }) : _word = word;

  final String _word;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RhymeObj>>(
      future: getData(_word), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<RhymeObj>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
            DataClass(datalist: snapshot.data!),
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: () {
                if (snapshot.error.toString().contains("Range")) {
                  var error = snapshot.error.toString();
                  return Text(
                    error,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  );
                }
              }(),
            ),
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            ),
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }
}

Future<List<RhymeObj>> getData(String word) async {
  const maxRhyme = 10;
  var urlString = "https://api.rhymezone.com/words?arhy=1&max=$maxRhyme&sl=$word";
  var result = await http.get(Uri.parse(urlString));

  List<RhymeObj> list = List.empty(growable: true);
  if (result.statusCode == 200) {
    var jsonDecoded = json.decode(result.body);

    for (num i = 0; i < maxRhyme; i++) {
      list.add(RhymeObj.fromJson(jsonDecoded[i] as Map<String, dynamic>));
    }
    return list;
  }
  throw Exception(result.reasonPhrase);
}

class DataClass extends StatelessWidget {
  const DataClass({Key? key, required this.datalist}) : super(key: key);
  final List<RhymeObj> datalist;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      
        scrollDirection: Axis.vertical,
        child: FittedBox(
            child: DataTable(
          showBottomBorder: true,
          sortColumnIndex: 1,
          showCheckboxColumn: false,
          border: TableBorder.all(width: 1.0),
          columns: const [
            DataColumn(
                label: Text(
              "Word",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            DataColumn(
                label: Text(
              "Score",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            DataColumn(
              label: Text("Number of syllables",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            )
          ],
          rows: datalist
              .map((data) => DataRow(cells: [
                    DataCell(Text(
                      data.word,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    )),
                    DataCell(Text(
                      data.score.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20),
                    )),
                    DataCell(Text(
                      data.numSyllables.toString(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ))
                  ]))
              .toList(),
        )));
  }
}

class RhymeObj {
  String word;
  int score;
  int numSyllables;

  RhymeObj({
    required this.word,
    required this.score,
    required this.numSyllables,
  });

  factory RhymeObj.fromJson(Map<String, dynamic> json) => RhymeObj(
      word: json['word'],
      score: json['score'] as int,
      numSyllables: json["numSyllables"] as int);

  Map<String, dynamic> toJson() => {
        "word": word.toString(),
        "score": score,
        "numSyllables": numSyllables,
      };
}
