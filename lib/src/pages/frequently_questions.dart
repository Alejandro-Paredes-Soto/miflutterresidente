import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:dostop_v2/src/utils/questions_descriptions.dart' as questions;
import 'package:flutter_svg/flutter_svg.dart';

class FrequentlyQuestionsScreen extends StatefulWidget {
  @override
  _FrequentlyQuestionsScreenState createState() =>
      _FrequentlyQuestionsScreenState();
}

class _FrequentlyQuestionsScreenState extends State<FrequentlyQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: utils.appBarLogo(titulo: 'Preguntas frecuentes'),
        floatingActionButton: Container(
          margin: EdgeInsets.all(15),
          width: double.infinity,
          child: FloatingActionButton.extended(
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
              color: Theme.of(context).iconTheme.color,
            ),
            backgroundColor: utils.colorAcentuado,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: [
            Expanded(child: _createQuestion()),
            SizedBox(height: 90),
          ],
        ));
  }

  Widget _createQuestion() {
    return ListView.builder(
      itemCount: questionsList.length,
      itemBuilder: (context, i) {
        return Theme(
          data: Theme.of(context)
              .copyWith(dividerColor: Color.fromARGB(255, 1, 22, 205)),
          child: ExpansionTile(
            childrenPadding: EdgeInsets.all(10),
            textColor: utils.colorAcentuado,
            iconColor: utils.colorAcentuado,
            title: Text(
              questionsList[i].ask,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            children: <Widget>[
              Column(
                children: _buildExpandableContent(questionsList[i]),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildExpandableContent(Questions question) {
    List<Widget> columnContent = [];

    for (String content in question.answer)
      columnContent.add(
        ListTile(
            title: Text(
          content,
        )),
      );

    return columnContent;
  }
}

class Questions {
  final String ask;
  List<String> answer = [];

  Questions(this.ask, this.answer);
}

List<Questions> questionsList = [
  Questions(
    questions.question1,
    [questions.answer1, questions.notes1],
  ),
  Questions(
    questions.question2,
    [questions.answer2, questions.notes2],
  ),
  Questions(
    questions.question3,
    [questions.answer3, questions.notes3],
  ),
  Questions(
    questions.question4,
    [questions.answer4, questions.notes4],
  ),
  Questions(
    questions.question5,
    [questions.answer5, questions.notes5],
  ),
  Questions(
    questions.question6,
    [questions.answer6, questions.notes6],
  ),
];
