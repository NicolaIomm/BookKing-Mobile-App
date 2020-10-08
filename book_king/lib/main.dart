import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signIn.dart';
import 'loginForm.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookKing',
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.white,
          shape: RoundedRectangleBorder(),
          textTheme: ButtonTextTheme.accent,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookKing(),
    );
  }
}

class BookKing extends StatefulWidget {
  @override
  _BookKingState createState() => _BookKingState();
}

class _BookKingState extends State<BookKing> with TickerProviderStateMixin {
  bool _fireInitialized = false;
  bool _fireError = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_fireInitialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _fireInitialized = true;
      });
    } catch(e) {
      // Set `_fireError` state to true if Firebase initialization fails
      setState(() {
        _fireError = true;
      });
    }
  }

  User _loggedUser;
  bool _isLogged;

  FocusScopeNode currentFocus;
  TextEditingController _searchFieldController ;

  TabController _tabController ;

  String _tempMsg = "";



  @override
  void initState() {
    initializeFlutterFire();
    super.initState();

    _searchFieldController = TextEditingController();

    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    _tabController.addListener( () => currentFocus.unfocus() );

  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

  print("[DEBUG] BUILD - Method called.");

  if(_fireError) {
    print("[DEBUG] FIRECORE - Error while initializating FireCore.");
  }
  if (!_fireInitialized) {
    print("[DEBUG] FIRECORE - Waiting for first initialization.. ");
  }

  currentFocus = FocusScope.of(context);

  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
              '         BookKing',
              style: TextStyle(fontSize: 24),
            )
        ),
        actions: [
          IconButton(
              iconSize: 48,
              icon: (_loggedUser != null ? Image.network(_loggedUser.photoURL) : Icon(Icons.account_circle)),
              onPressed: (_loggedUser != null ? _showUserPageLogged : _showUserPageNotLogged)
          )],
        bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.explore), text: 'Explore'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'MyBooks'),
              Tab(icon: Icon(Icons.addchart), text: 'Transactions')
            ]
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
  // Explore Tab
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
              child: Column(
                  children: [
                    SizedBox(
                        height: 40, // set this
                        child: TextField(
                          maxLines: 1,
                          controller: _searchFieldController,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 18.0),
                            hintText: 'Search for books ...',
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: (){
                                _searchFieldController.clear();
                                setState((){
                                  _tempMsg = "";
                                });
                                },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState((){
                              _tempMsg = value;
                            });
                            },
                        )
                    ),
                    Text(_tempMsg)
                  ]
              ),
            ),
  // MyBooks Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Nothing to show."),
              ],
            ),
  // Transaction Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Nothing to show.")
                ],
              ),
            )
          ]
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () => {print(_searchFieldController.text)},
        child: Icon(Icons.search),
      )
      */
      )
  );
  }


  void _showUserPageLogged() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(title: Text('User Page')),
              body: Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                            children: [
                              Image.network(_loggedUser.photoURL),
                              Padding( padding: const EdgeInsets.only(top: 10.0) ),
                              Text(_loggedUser.displayName),
                              Padding( padding: const EdgeInsets.only(top: 5.0) ),
                              Text(_loggedUser.email),
                              Padding( padding: const EdgeInsets.only(top: 5.0) ),
                              Text(_loggedUser.phoneNumber != null ? _loggedUser.phoneNumber : "")
                            ]
                        ),
                        const SizedBox(height: 12),
                        OutlineButton(
                            splashColor: Colors.grey,
                            onPressed: () {
                              signOutGoogle().then((result) {
                                setState((){
                                  _isLogged = false;
                                  _loggedUser = null;
                                });
                                Navigator.pop(context);
                              });
                              },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            highlightElevation: 0,
                            borderSide: BorderSide(color: Colors.grey),
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.grey,
                                          )
                                      )]
                                )
                            )
                        )]
                  )
              )
          );
        })
    );
  }

  void _showUserPageNotLogged() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(title: Text('User Page')),
              body: Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyForm(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              OutlineButton(
                                  splashColor: Colors.grey,
                                  onPressed: () => doLogin(),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                  highlightElevation: 0,
                                  borderSide: BorderSide(color: Colors.grey),
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                'Log in',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.grey,
                                                )
                                            ),
                                          ]
                                      )
                                  )
                              ),
                              Padding( padding: EdgeInsets.symmetric(horizontal: 20.0) ),
                              OutlineButton(
                                  splashColor: Colors.grey,
                                  onPressed: null,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                  highlightElevation: 0,
                                  borderSide: BorderSide(color: Colors.grey),
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                'Register',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.grey,
                                                )
                                            ),
                                          ]
                                      )
                                  )
                              )
                          ]
                        ),
                        Padding( padding: EdgeInsets.symmetric(vertical: 20.0) ),
                        Divider(
                          color: Colors.blue,
                          height: 20,
                          thickness: 4,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Padding( padding: EdgeInsets.symmetric(vertical: 20.0) ),
                        OutlineButton(
                            splashColor: Colors.grey,
                            onPressed: () {
                              signInGoogle().then((result){
                                if (result != null){
                                  setState((){
                                    _isLogged = true;
                                    _loggedUser = result;
                                  });
                                  Navigator.pop(context);
                                }
                              });
                              },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            highlightElevation: 0,
                            borderSide: BorderSide(color: Colors.grey),
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
                                      Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                              'Sign in with Google',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey,
                                              )
                                          )
                                      )
                                    ]
                                )
                            )
                        )]
                  )
              )
          );
        })
    );
  }

  void _findBook(){

  }

  Future<void> doLogin() async {
    var url = "http://bookking.pythonanywhere.com/token";

    var headers = <String, String>{
      'email' : "testuser@test.com",
      'password' : "password"
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var token = jsonResponse['token'];
      print('Here there is your token: $token.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }


}


