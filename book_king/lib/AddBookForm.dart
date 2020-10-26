import 'package:flutter/material.dart';

class AddBookForm extends StatefulWidget {


  final _AddBookFormState state = _AddBookFormState();


  @override
  _AddBookFormState createState() => state;
}

class _AddBookFormState extends State<AddBookForm> {

  TextEditingController _authorFieldController;
  TextEditingController _titleFieldController;
  TextEditingController _yearFieldController;
  TextEditingController _genreFieldController;
  TextEditingController _isbnFieldController;

  String getFormAuthor(){
    return _authorFieldController.value.text;
  }
  String getFormTitle(){
    return _titleFieldController.value.text;
  }
  String getFormYear(){
    return _yearFieldController.value.text;
  }
  String getFormGenre(){
    return _genreFieldController.value.text;
  }
  String getFormIsbn(){
    return _isbnFieldController.value.text;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _authorFieldController = TextEditingController();
    _titleFieldController = TextEditingController();
    _yearFieldController = TextEditingController();
    _genreFieldController = TextEditingController();
    _isbnFieldController = TextEditingController();
  }

  SizedBox mySizedBox(TextEditingController controller, String sampleText){
    return SizedBox(
        width: 250,
        height: 40,
        child: TextFormField(
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          maxLines: 1,
          controller: controller,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 18.0),
            hintText: sampleText,
            prefixIcon: Icon(Icons.account_box),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: (){
                controller.clear();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
        return Form(
            key: _formKey,
            child: Column(
                children: [
                  Padding( padding: EdgeInsets.symmetric(vertical: 45.0) ),
                  mySizedBox(_authorFieldController, "Author"),
                  Padding( padding: EdgeInsets.symmetric(vertical: 5.0) ),
                  mySizedBox(_titleFieldController, "Title"),
                  Padding( padding: EdgeInsets.symmetric(vertical: 5.0) ),
                  mySizedBox(_yearFieldController, "Year"),
                  Padding( padding: EdgeInsets.symmetric(vertical: 5.0) ),
                  mySizedBox(_genreFieldController, "Genre"),
                  Padding( padding: EdgeInsets.symmetric(vertical: 5.0) ),
                  mySizedBox(_isbnFieldController, "ISBN"),
                  Padding( padding: EdgeInsets.symmetric(vertical: 20.0) ),
                ]
            )
        );
  }

}
