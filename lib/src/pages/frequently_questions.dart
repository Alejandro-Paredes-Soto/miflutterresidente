import 'dart:developer';

import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dostop_v2/src/providers/questions_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FrequentlyQuestionsScreen extends StatefulWidget {
  @override
  _FrequentlyQuestionsScreenState createState() =>
      _FrequentlyQuestionsScreenState();
}

class _FrequentlyQuestionsScreenState extends State<FrequentlyQuestionsScreen> {
  final questionsProvider = QuestionsProvider();
  Future<void>? _launched;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarLogo(titulo: 'Preguntas frecuentes'),
      floatingActionButton: Container(
        margin: EdgeInsets.all(15),
        width: double.infinity,
        child: FloatingActionButton.extended(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onPressed: () {
            Navigator.pushNamed(context, 'contactSupport');
          },
          label: const Text(
            'Contáctanos',
            style: TextStyle(fontSize: 16),
          ),
          icon: SvgPicture.asset(
            utils.rutaIconoWhastApp,
            height: 30,
            color: Colors.white,
          ),
          backgroundColor: utils.colorAcentuado,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Expanded(child: _createQuestions(context)),
          SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _createQuestions(BuildContext context) {
    return FutureBuilder(
      future: questionsProvider.cargaQuestions(),
      builder:
          (BuildContext context, AsyncSnapshot<List<QuestionModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length > 0) {
            return Container(
              child: ListView.separated(
                padding: EdgeInsets.all(15),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Color.fromARGB(255, 1, 22, 205)),
                  child: ExpansionTile(
                    childrenPadding: EdgeInsets.all(10),
                    textColor: utils.colorAcentuado,
                    iconColor: utils.colorAcentuado,
                    title: Text(
                      snapshot.data![index].nameFAQ,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _content(snapshot.data![index].descriptionFAQ
                                .replaceAll("|", "\n\n")),
                            Visibility(
                                visible:
                                    (snapshot.data![index].note != 'No note'),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    _content(snapshot.data![index].note),
                                  ],
                                )),
                            Visibility(
                                visible: (snapshot.data![index].linkYT !=
                                    'No video'),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    _linkVideo(snapshot.data![index].linkYT),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(height: 15.0),
              ),
            );
          } else {
            return Center(
              child: Text('No hay preguntas disponibles por el momento',
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget _linkVideo(String link) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      onPressed: () => setState(() {
        _launched = _launchInBrowser(Uri.parse(link));
      }),
      icon: Icon(Icons.play_arrow_outlined),
      label: const Text('Ver video'),
    );
  }

  Widget _content(String data) {
    return Text(
      data,
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.start,
    );
  }
}
