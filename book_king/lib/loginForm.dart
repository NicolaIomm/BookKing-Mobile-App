import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'main.dart';

class MyForm extends StatefulWidget {

  final _MyFormState state = _MyFormState();

  @override
  _MyFormState createState() => state;
}

class _MyFormState extends State<MyForm> {

  TextEditingController _usernameFieldController;
  TextEditingController _passwordFieldController;

  final _loginForm = GlobalKey<FormState>();
  bool _obscureText = true;

  String getFormEmail(){
    return _usernameFieldController.value.text;
  }

  String getFormPassword(){
    return _passwordFieldController.value.text;
  }

  @override
  void initState() {
    super.initState();

    _usernameFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _loginForm,
        child: Column(
            children: [
              SizedBox(
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
                    controller: _usernameFieldController,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 18.0),
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.account_box),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: (){
                          _usernameFieldController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  )
              ),
              Padding( padding: EdgeInsets.symmetric(vertical: 7.0) ),
              SizedBox(
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
                    obscureText: _obscureText,
                    controller: _passwordFieldController,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 18.0),
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove_red_eye),
                        onPressed: (){
                          setState((){
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  )
              ),
              Padding( padding: EdgeInsets.symmetric(vertical: 12.0) )
            ]
        )
    );
  }

}
