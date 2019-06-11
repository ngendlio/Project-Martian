import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_martian/models/user_data.dart';
import 'package:flushbar/flushbar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

import 'forms/id_form.dart';
import 'models/planet_data.dart';
import 'services/authentication_check.dart';
import 'models/finance_data.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String email;

  HomePage({this.auth, this.onSignedOut, this.userId, this.email});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _HomePageState extends State<HomePage> {
  UserData userData;
  Finance finance;

  PageController pageController;
  int currentPage = 2;
  double page = 2.0;
  double scaleFraction = 0.7,
      fullScale = 1.0,
      pagerHeight = 200,
      viewportFraction = 0.95;

  String userId,
      firstName = '',
      lastName,
      mother_planet,
      dateOfBirth,
      species,
      reason,
      email,
      gender;
  num gsid;
  String balance;
  bool martian;
  int numOfIds;
  List<Map<String, dynamic>> listOfIds = [];

  String _errorMessage = 'Resending Verification Email',
      _errorDetails =
          'Please check your inbox - LOG OUT and LOG BACK IN to activate your account';
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  bool _status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '$firstName $lastName',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[_showLogOutButton()],
      ),
      body: dataStatus == DataStatus.NOT_DETERMINED
          ? _showLoadingScreen()
          : _showBody(),
    );
  }

  @override
  void initState() {
    super.initState();

    //Initializes the ID cards carousel
    pageController =
        PageController(initialPage: 1, viewportFraction: viewportFraction);

    //Shows email notification if email not verified
    widget.auth.isEmailVerified().then((value) {
      setState(() {
        if (value != null) {
          _status = value;
        }
      });
    });

    //Gets ID data from user
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then((data) {
      setState(() {
        if (data.exists) {
          Firestore.instance
              .collection('users')
              .document(widget.userId)
              .collection('planetary_ids')
              .getDocuments()
              .then((value) {
            setState(() {
              dataStatus = data == null || value == null
                  ? DataStatus.NOT_DETERMINED
                  : DataStatus.DETERMINED;
            });
          });

          //Gets user primary data
          fetchData(data);
        }
      });
    });

    //get financial data from User's database
    finance = Finance(userId: widget.userId);
    finance.getBalance().then((value) {
      setState(() {
        dataStatus = value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if(value != null) {
          balance = value.toStringAsFixed(2);
          print(balance);
        }
      });
    });

    //Gets a list of ids
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('planetary_ids')
        .snapshots()
        .listen((snapshot) {
      snapshot.documents.forEach((doc) {
        listOfIds.add(doc.data);
        setState(() {
          numOfIds = listOfIds.length+1;
          currentPage = 0;
        });
      });
    });
  }

  void fetchData(DocumentSnapshot data) {
    firstName = data.data['firstName'];
    lastName = data.data['lastName'];
    dateOfBirth = data.data['dateOfBirth'];
    gender = data.data['gender'];
    gsid = data.data['gsid'];
    mother_planet = data.data['mother_planet'];
    reason = data.data['reason'];
    species = data.data['species'];
    userId = data.data['userId'];
    email = data.data['email'];
    martian = data.data['martian'];
  }

  Widget _showLoadingScreen() {
    return Scaffold(
      body: Center(
          child: SpinKitThreeBounce(
        color: Colors.deepOrangeAccent,
        duration: Duration(seconds: 3),
      )),
    );
  }

  Widget _showBody() {
    return ListView(children: <Widget>[
      _showUnverifiedEmailNotification(),
      _showHeader('Planetary IDs'),
      _showIdCards(),
      _showHeader('Finance'),
      _showBankCard(),
    ]);
  }

  Widget _showUnverifiedEmailNotification() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration: BoxDecoration(color: Colors.red),
      height: !_status ? 85 : 0,
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Email not verified - Banking, Comms and Social Feed disabled',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  _showVerificationEmailNotification();
                  _sendEmailVerification();
                },
                child: Text(
                  'Resend Verification',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showVerificationEmailNotification() {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      isDismissible: true,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      icon: Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      backgroundColor: Colors.black87,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: 3,
      aroundPadding: EdgeInsets.all(15),
      showProgressIndicator: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
      titleText: Text(
        _errorMessage,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        _errorDetails,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 6),
    ).show(context);
  }

  void _sendEmailVerification() async {
    await widget.auth.sendEmailVerification();
  }

  Widget _showHeader(String text) {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepOrangeAccent,
                  fontFamily: 'SamsungOne',
                  fontWeight: FontWeight.bold),
            )),
        Divider(
          color: Colors.black12,
        ),
      ],
    );
  }

  Widget _showLogOutButton() {
    return FlatButton(
        child: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _signOut();
        });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void _cardInfoBottomSheet(index, context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.white30, Colors.white])),
            child:
                ListView(physics: ClampingScrollPhysics(), children: <Widget>[
              Column(
                children: <Widget>[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    child: Image.asset(
                      _planetImagePicker(listOfIds[index]['planetName']),
                      height: 150,
                      width: 1000,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    //Full Name card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Local Name: ',
                            ),
                          ),
                          Text(
                            '${listOfIds[index]['planetFirstName']} ${listOfIds[index]['planetLastName']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Planet Name: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['planetName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 50),
                            child: Text(
                              'ID Type: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['idType'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'ID Issued On: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['dateIssued'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 25),
                            child: Text(
                              'Date of Expiration: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['dateOfExpiration'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Planetary ID: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['planetaryId'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Criminal Record: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['criminalRecord'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 50),
                            child: Text(
                              'Flying License: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['flyingLicense'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      'Delete ID',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    color: Colors.red,
                    onPressed: listOfIds[index]['planetName'] == 'Mars'
                        ? null
                        : () {
                            PlanetData(
                                    userId: userId,
                                    planetName: listOfIds[index]['planetName'])
                                .deleteId(listOfIds[index]['planetName']);
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext) =>
                                        CheckAuthentication(
                                          auth: widget.auth,
                                          userId: userId,
                                        )));
                          },
                  )
                ],
              ),
            ]),
          );
        });
  }

  Widget _showBankCard() {
    return Hero(
      tag: 'bankCard',
      child: Container(
        height: 260,
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: FractionalOffset.topRight,
                    end: FractionalOffset.bottomLeft,
                    colors: [
                  Colors.redAccent,
                  Colors.deepOrangeAccent,
                  Colors.red
                ])),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        height: 130,
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Bank of',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 10, color: Colors.black87)
                                      ]),
                                ),
                              ),
                              Text(
                                'Mars',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 47,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 10, color: Colors.black87)
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Column(
                                        children: <Widget>[
                                          Text('Acc. Number',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 5,
                                                        color: Colors.black38)
                                                  ])),
                                          Text(
                                            '9876543214111',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 5,
                                                      color: Colors.black38)
                                                ]),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 25,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.end,
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            'Date of Exp.',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 10,
                                                      color: Colors.black38)
                                                ]),
                                          ),
                                          Text(
                                            '03/17/1199',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 10,
                                                      color: Colors.black38)
                                                ]),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 25,
                                  )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Column(
                                          children: <Widget>[
                                            Text('Name on Card',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                          blurRadius: 10,
                                                          color: Colors.black38)
                                                    ])),
                                            Text(
                                              'Tanjimul H. Bhuiyan',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 10,
                                                        color: Colors.black38)
                                                  ]),
                                            ),
                                          ],
                                        )),
                                    SizedBox()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Current Balance: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black38)
                            ]),
                      ),
                      Text(
                        '\$$balance',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black38)
                            ]),
                      ),
//                    Container(
//                      padding: EdgeInsets.only(left: 5),
//                      child: RaisedButton(
//                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                        elevation: 1,
//                        color: Colors.blueAccent,
//                          child: Text('Send',
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  shadows: [
//                                    Shadow(
//                                        blurRadius: 10, color: Colors.black38)
//                                  ])),
//                          onPressed: () {}),
//                    ),
//                    Container(
//                      padding: EdgeInsets.only(left: 5),
//                      child: RaisedButton(
//                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                          elevation: 1,
//                          color: Colors.green,
//                          child: Text(
//                            ' Deposit ',
//                            style: TextStyle(
//                                color: Colors.white,
//                                ),
//                          ),
//                          onPressed: () {}),
//                    ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        width: double.infinity,
                        child: Text(
                          'Most Recent Transaction',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 5),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Vivenddi Corp',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '\$55.87',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _idCards(int index, double scale) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(bottom: 20),
        height: pagerHeight * scale,
        width: 800,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: InkWell(
            onTap: () {
              _cardInfoBottomSheet(index, context);
            },
            child: Container(
              decoration: BoxDecoration(
                  gradient: _colorPicker(listOfIds[index]['planetName'])),
              child: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: QrImage(
                      gapless: true,
                      backgroundColor: Colors.white,
                      data: userId,
                      size: 500,
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'First Name',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        child: Text(
                                          listOfIds[index]['planetFirstName'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Last Name',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        child: Text(
                                          listOfIds[index]['planetLastName'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Planetary ID',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        child: Text(
                                          listOfIds[index]['planetaryId'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Planet Name',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          listOfIds[index]['planetName'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'ID Type',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        child: Text(
                                          listOfIds[index]['idType'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Date of Expiration',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          listOfIds[index]['dateOfExpiration'],
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showAddIdCard(double scale) {
    return InkWell(
      splashColor: Colors.deepOrangeAccent,
      onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => IdForm(
                    userId: widget.userId,
                    auth: widget.auth,
                  ))),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          height: pagerHeight * scale,
          width: 800,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Icon(
                Icons.add_circle_outline,
                size: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showIdCards() {
    return Container(
      height: 200,
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            height: pagerHeight,
            child: NotificationListener<ScrollNotification>(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  final scale = max(scaleFraction,
                      (fullScale - (index - page).abs()) + viewportFraction);
                  return index == numOfIds - 1
                      ? _showAddIdCard(scale)
                      : _idCards(index, scale);
                },
                itemCount: numOfIds,
                controller: pageController,
                onPageChanged: (pos) {
                  setState(() {
                    currentPage = pos;
                  });
                },
                physics: AlwaysScrollableScrollPhysics(),
              ),
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollUpdateNotification) {
                  setState(() {
                    page = pageController.page;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _planetImagePicker(String planetName) {
    switch (planetName.toLowerCase()) {
      case 'mercury':
        return 'assets/mercury.jpg';
        break;
      case 'mars':
        return 'assets/mars.jpg';
        break;
      case 'venus':
        return 'assets/venus.jpg';
        break;
      case 'earth':
        return 'assets/earth.jpg';
        break;
      case 'jupiter':
        return 'assets/jupiter.jpg';
        break;
      case 'neptune':
        return 'assets/neptune.jpg';
        break;
      case 'saturn':
        return 'assets/saturn.jpg';
        break;
      case 'uranus':
        return 'assets/uranus.jpg';
        break;
      default:
        return 'assets/space.jpg';
        break;
    }
  }

  LinearGradient _colorPicker(String planetName) {
    switch (planetName) {
      case 'Mercury':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent]);
        break;
      case 'Mars':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [
              Colors.redAccent,
              Colors.deepOrangeAccent,
              Colors.orangeAccent
            ]);
        break;
      case 'Venus':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.grey, Colors.blueGrey]);
        break;
      case 'Earth':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.greenAccent, Colors.blue]);
        break;
      case 'Jupiter':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.grey, Colors.brown]);
        break;
      case 'Neptune':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.blue, Colors.blueAccent]);
        break;
      case 'Saturn':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.deepOrangeAccent, Colors.brown]);
        break;
      case 'Uranus':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.blueAccent, Colors.lightBlue]);
        break;
      default:
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.grey, Colors.blueGrey]);
        break;
    }
  }
}
