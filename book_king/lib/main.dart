import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:geolocator/geolocator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'User.dart';
import 'signIn.dart';
import 'LoginForm.dart';
import 'AddBookForm.dart';

import 'Book.dart';

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

  BookKingUser _loggedUser = BookKingUser();

  FocusScopeNode currentFocus;
  TextEditingController _searchFieldController ;

  TabController _tabController ;

  String _searchFilter = "";

  Widget exploreContent;
  Widget myBooksContent;
  Widget transactionContent;

  List<Book> _books = new List<Book>();

  String currentBook = "a";

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();

    getBooks().then((result) {
        List<Book> retList = getBookFromString(result);
        retList.forEach((book) {
          _books.add(book);
        });
        exploreContent = updateTabContent(retList);
    });

    exploreContent = Text("Search books here.");
    myBooksContent = Text("Here there are your books.");
    transactionContent = Text("Here there are your transactions.");

    _searchFieldController = TextEditingController();

    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    _tabController.addListener( () => currentFocus.unfocus() );
    _tabController.addListener((){
      var tabIndex = _tabController.index;

      switch(tabIndex) {
        case 0:
          getBooks().then((result) {
            setState((){
              List<Book> retList = getBookFromString(result);
              _books = retList;
              exploreContent = updateTabContent(retList);
            });
          });
          break;
        case 1:
          if (!_loggedUser.isLogged) {
            myBooksContent = Text("You have to be logged in to see this tab.");
          }
          else{
            getMyBooks().then((result) {
              setState((){
                List<Book> retList = getBookFromString(result);
                myBooksContent = updateTabContent(retList);
              });
            });
          }
          break;
        case 2:
          if (!_loggedUser.isLogged) {
            transactionContent = Text("You have to be logged in to see this tab.");
          }
          else{
            getTransactions().then((result) {
              setState((){
                List<Book> retList = getBookFromString(result);
                transactionContent = updateTabContent(retList);
              });
            });
          }
          break;
      }
    });

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
              icon: (_loggedUser.isLogged ? Image.network(_loggedUser.getPhotoUrl()) : Icon(Icons.account_circle)),
              onPressed: (_loggedUser.isLogged ? _showUserPageLogged : _showUserPageNotLogged)
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
                                  _searchFilter = "";
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                          ),
                          onSubmitted: onFilterChange(_searchFieldController.text),
                        )
                    ),
                    exploreContent
                  ]
              ),
            ),
  // MyBooks Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myBooksContent,
              ],
            ),
  // Transaction Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  transactionContent,
                ],
              ),
            )
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation){
                  var addBookForm = AddBookForm();
                  var addBookFormState = addBookForm.state;

                  return Scaffold(
                      appBar: AppBar(title: Text('New Book Page')),
                      body: Center(
                        child: Column(
                          children: [
                            addBookForm,
                            OutlineButton(
                              splashColor: Colors.grey,
                              onPressed: () {
                                var isbn = addBookFormState.getFormIsbn();
                                createBookWithISBN(isbn).then((result) {
                                  notifyDialog("Done!", "Your book has been added succesfully!");
                                });
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              highlightElevation: 0,
                              borderSide: BorderSide(color: Colors.grey),
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            'Load info from ISBN',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            )
                                        ),
                                      ]
                                  )
                              )
                            ),
                          Padding( padding: EdgeInsets.symmetric(vertical: 30.0) ),
                          OutlineButton(
                              splashColor: Colors.grey,
                              onPressed: () {
                                var author = addBookFormState.getFormAuthor();
                                var title = addBookFormState.getFormTitle();
                                var year = addBookFormState.getFormYear();
                                var genre = addBookFormState.getFormGenre();
                                var isbn = addBookFormState.getFormIsbn();

                                if (!_loggedUser.isLogged) {
                                  notifyDialog("Required Login", "You have to Log In to add a new book");
                                }
                                else {
                                  createBook(author, title, year, genre, isbn)
                                      .then((result) {
                                    notifyDialog("Done!",
                                        "Your book has been added succesfully!");
                                  });
                                }
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
                                        Text(
                                            'Submit',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.grey,
                                            )
                                        ),
                                      ]
                                  )
                              )
                          ),
                          ]
                       )
                      )
                  );
                 },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = Offset(0.0, 1.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              )
          );
          },
        child: Icon(Icons.add),
      )
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
                              Image.network(_loggedUser.getPhotoUrl()),
                              Padding( padding: const EdgeInsets.only(top: 10.0) ),
                              Text(_loggedUser.getName()),
                              Padding( padding: const EdgeInsets.only(top: 5.0) ),
                              Text(_loggedUser.getEmail()),
                              Padding( padding: const EdgeInsets.only(top: 5.0) ),
                              Text(_loggedUser.getPhone() != null ? _loggedUser.getPhone() : ""),
                              Padding( padding: const EdgeInsets.only(top: 5.0) ),
                              //Text(_loggedUser.getToken())
                            ]
                        ),
                        const SizedBox(height: 12),
                        OutlineButton(
                            splashColor: Colors.grey,
                            onPressed: () {
                              signOutGoogle().then((result) {
                                setState((){
                                  _loggedUser = BookKingUser();
                                  _loggedUser.isLogged = false;
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

    var loginForm = MyForm();
    var loginFormState = loginForm.state;

    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(title: Text('User Page')),
              body: Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        loginForm,
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlineButton(
                                  splashColor: Colors.grey,
                                  onPressed: () {
                                    var email = loginFormState.getFormEmail();
                                    var password = loginFormState.getFormPassword();
                                    setState((){
                                      _loggedUser = BookKingUser();
                                      _loggedUser.isLogged = true;
                                      _loggedUser.setEmail(email);
                                      _loggedUser.setName(email);
                                      _loggedUser.setPhotoUrl("https://cdn4.iconfinder.com/data/icons/small-n-flat/24/user-alt-512.png");
                                      _loggedUser.setPhone("");
                                      doLogin(email, password).then((token){
                                        _loggedUser.setToken(token);
                                      });
                                    });
                                    Navigator.pop(context);
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
                                    _loggedUser = BookKingUser();
                                    _loggedUser.isLogged = true;
                                    _loggedUser.setName(result.displayName);
                                    _loggedUser.setEmail(result.email);
                                    _loggedUser.setPhotoUrl(result.photoURL);
                                    _loggedUser.setPhone(result.phoneNumber);
                                    getGoogleToken(result).then((token){
                                      _loggedUser.setToken(token);
                                    });
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

  notifyDialog(String title, String message){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions:[
              FlatButton(
                child: Text("Close"),
                onPressed: (){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  proposeExchangeDialog(Book target){

    List<DropdownMenuItem<String>> dropdownItems = new List();

    for (String c in ['a', 'b', 'c', 'd', 'e']) {
      dropdownItems.add(
          new DropdownMenuItem(
            value: c,
            child: new Text(c)
          )
      );
    }


    return showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Propose Exchange"),
                content:
                Container(
                  color: Colors.white,
                  child: new Center(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("You are proposing an exchange for:"),
                          Text(target.title),
                          Text("Select one book you want to exchange:"),
                          DropdownButton(
                              value: currentBook,
                              items: dropdownItems,
                              onChanged: (String selected){
                                setState((){
                                  currentBook = selected;
                                });
                              }
                          ),
                        ],
                      )
                  ),
                ),
                actions:[
                  FlatButton(
                    child: Text("Propose"),
                    onPressed: (){
                      print("propose done");
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );


        }
    );
  }

  onFilterChange(String text) {
    getBooksWithFilter(text).then((result) {
      List<Book> retList = getBookFromString(result);
      retList.forEach((book) {
        _books.add(book);
      });
      exploreContent = updateTabContent(retList);
    });
    setState(() {});
  }

  List<Book> getBookFromString(String content){
    String modContent = content.replaceAll("\'", "\"");

    // store json data into list
    var list = convert.jsonDecode(modContent) as List;

    // iterate over the list and map each object in list to Img by calling Book.fromJson
    List<Book> retList = list.map((i) => Book.fromJson(i)).toList();

    return retList;
  }

  Widget updateTabContent(List<Book> list){
    return _buildContent(list);
  }

  Widget _buildContent(List<Book> retList) {
    return Container(
        height: 530,
        child: ListView.separated(
          itemCount: retList.length,
          padding: EdgeInsets.all( 16.0 ),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Colors.grey,
                thickness: 1,
              );
            },
          itemBuilder: (BuildContext context, int index) {
            return _buildRow(retList[index]);
          },
        )
    );
  }

  Widget _buildRow(Book book) {

    if (_searchFilter != ""){
      if (!book.title.contains(_searchFilter)){
        return null;
      }
      else{
        return ListTile(
            title: Text(
              book.title,
            ),
            trailing: Icon(
                Icons.favorite_border,
                color : Colors.black54
            ),
            onTap: () {

            }
        );
      }
    }
    return ListTile(
        title: Text(
          book.title,
        ),
        trailing: Icon(
            Icons.favorite_border,
            color : Colors.black54
        ),
        onTap: () {

        }
    );

  }

  Future<String> doLogin(String email, String password) async {
    var args = <String, String>{
      "email": email,
      "password": password
    };

    var url = Uri.http("bookking.pythonanywhere.com", "/token", args);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      print('[DEBUG] doLogin - Token obtained successfully.');
      return jsonResponse['token'];

    } else {
      print('[DEBUG] doLogin - Request failed with status: ${response
          .statusCode}.');
      return "ERROR TOKEN";
    }
  }

  Future<String> getGoogleToken(User currentUser) async{
    Future<String> token = currentUser.getIdToken();
    return token;
  }

  Future<String> createBook(String author, String  title, String  year, String genre, String isbn) async {

    var a = author;
    var t = title;
    var y = year;
    var g = genre;
    var i = isbn;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var lon = position.longitude;

    var response = await http.post(
        'http://bookking.pythonanywhere.com/books/create',
        headers: <String, String>{
          'Authorization': _loggedUser.getToken()
        },
        body: {
          'author': a,
          'title': t,
          'year': y,
          'genere': g,
          'lat': lat,
          'lon': lon,
          'ISBN': i
        });

    return (response.statusCode.toString());
  }

  Future<String> createBookWithISBN(String isbn) async {

    var i = isbn;
    var lat = "150";
    var lon = "150";

    var response = await http.post(
        'http://bookking.pythonanywhere.com/books/ISBNcreate',
        headers: <String, String>{
          'Authorization': _loggedUser.getToken()
        },
        body: {
          'ISBN': i,
          'lat': lat,
          'lon': lon
        });

    return (response.body);
  }

  Future<String> getBooks() async {

    var url = Uri.http("bookking.pythonanywhere.com", "/books");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;

    } else {
      return "REQUEST ERROR";
    }

  }

  Future<String> getBooksWithFilter(filter) async {
    var args = <String, String>{
      "title": filter
    };

    var url = Uri.http("bookking.pythonanywhere.com", "/books", args);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;

    } else {
      return "REQUEST ERROR";
    }

  }

  Future<String> getMyBooks() async {

    var url = Uri.http("bookking.pythonanywhere.com", "/mybooks");

    final response = await http.get(url, headers: <String, String>{
      'Authorization': _loggedUser.getToken()
    });

    if (response.statusCode == 200) {
      return response.body;
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;

    } else {
      return "REQUEST ERROR";
    }

  }

  Future<String> getTransactions() async {

    var url = Uri.http("bookking.pythonanywhere.com", "/transactions");

    final response = await http.get(url, headers: <String, String>{
      'Authorization': _loggedUser.getToken()
    });

    if (response.statusCode == 200) {
      return response.body;
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;

    } else {
      return "REQUEST ERROR";
    }

  }
}