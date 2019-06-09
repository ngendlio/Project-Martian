import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:project_martian/services/auth_service.dart';
import '../models/new_planet_id.dart';
import '../services/authentication_check.dart';

class IdForm extends StatefulWidget {
  final String userId;
  final BaseAuth auth;

  IdForm({this.userId, this.auth});

  @override
  State<StatefulWidget> createState() {
    return _IdFormState();
  }
}

class _IdFormState extends State<IdForm> {
  final _formKey = GlobalKey<FormState>();
  String userId,
      planetFirstName,
      planetLastName,
      planetaryId,
      planetName,
      idType,
      idTypeValue,
      dateOfExpiration = 'Expiration Date',
      dateIssued = 'Date Issued',
      criminalRecord,
      criminalRecordValue,
      accessLevel,
      accessLevelValue,
      flyingLicense,
      flyingLicenseValue;
  int issuedMonth, issuedYear, issuedDay;

  FocusNode oNode = FocusNode(),
      tNode = FocusNode(),
      thNode = FocusNode(),
      fNode = FocusNode(),
      fiNode = FocusNode(),
      sNode = FocusNode(),
      seNode = FocusNode(),
      eNode = FocusNode(),
      nNode = FocusNode(),
      teNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext) => CheckAuthentication(auth: widget.auth, userId: widget.userId,))),
      child: Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Add a Planetary ID',
            style: TextStyle(
                color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
          ),
        ),
        body: _showBody(),
      ),
    );
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      AddPlanetData(
          //Submits all the value to the database
          userId: widget.userId,
          accessLevel: accessLevel,
          criminalRecord: criminalRecord,
          dateIssued: dateIssued,
          dateOfExpiration: dateOfExpiration,
          flyingLicense: flyingLicense,
          idType: idType,
          planetaryId: planetaryId,
          planetFirstName: planetFirstName,
          planetLastName: planetLastName,
          planetName: planetName);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext) => CheckAuthentication(auth: widget.auth, userId: widget.userId,)));
    }
  }

  Widget _showBody() {
    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          children: <Widget>[
            _showPlanetaryFirstNameInput(),
            _showPlanetaryLastNameInput(),
            _showPlanetaryIdInput(),
            _showPlanetNameInput(),
            _showDateIssueAndExpPicker(),
            _showSecondaryQueries(),
            _showTertiaryQueries(),
            _showDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _showDoneButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        splashColor: Colors.orangeAccent,
        elevation: 5,
        color: Colors.white,
        child: Text(
          'Done',
          style: TextStyle(
              fontSize: 20,
              color: Colors.deepOrangeAccent,
              fontFamily: 'SamsungOne'),
        ),
        onPressed: _validateAndSubmit,
      ),
    );
  }

  Widget _showPlanetaryFirstNameInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        autofocus: true,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Planetary First Name',
        ),
        validator: (value) => value.isEmpty ? 'First Name is required' : null,
        onSaved: (value) => planetFirstName = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(oNode);
        },
      ),
    );
  }

  Widget _showPlanetaryLastNameInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        focusNode: oNode,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Planetary Last Name',
        ),
        validator: (value) => value.isEmpty ? 'Last Name is required' : null,
        onSaved: (value) => planetLastName = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(tNode);
        },
      ),
    );
  }

  Widget _showPlanetaryIdInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        keyboardType: TextInputType.number,
        focusNode: tNode,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Planetary ID',
        ),
        validator: (value) => value.isEmpty ? 'Planetary ID is required' : null,
        onSaved: (value) => planetaryId = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(thNode);
        },
      ),
    );
  }

  Widget _showPlanetNameInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        focusNode: thNode,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Planet Name',
        ),
        validator: (value) => value.isEmpty ? 'Planet Name is required' : null,
        onSaved: (value) => planetName = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(fNode);
        },
      ),
    );
  }

  Widget _showDateIssueAndExpPicker() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            //So that all the field take up the entire container
            child: Container(
              child: FlatButton(
                child: Text(
                  dateIssued,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2800, 3, 5), //Maximum age 210
                      maxTime: DateTime(3010, 6, 7), onConfirm: (date) {
                    setState(() {
                      issuedDay = date.day;
                      issuedMonth = date.month;
                      issuedYear = date.year;
                      dateIssued =
                          '${date.month}/${date.day}/${date.year}'; //The format at which DOB is submitted to the database as well as output to the user
                    });
                  });
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            //So that all the field take up the entire container
            child: Container(
              child: FlatButton(
                child: Text(
                  dateOfExpiration,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime:
                          DateTime(issuedYear + 10, issuedMonth, issuedDay),
                      //Maximum age 210
                      maxTime: DateTime(issuedYear + 20, 6, 7),
                      onConfirm: (date) {
                    setState(() {
                      dateOfExpiration =
                          '${date.month}/${date.day}/${date.year}'; //The format at which DOB is submitted to the database as well as output to the user
                    });
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showSecondaryQueries() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            //So that all the field take up the entire container
            child: Container(
              //Id Type picker
              child: DropdownButton<String>(
                  isExpanded: true,
                  value: idType,
                  hint: Text('ID Type'),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Tourist',
                      child: Text('Tourist'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Citizen',
                      child: Text('Citizen'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Business',
                      child: Text('Business'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Visitor',
                      child: Text('Visitor'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      idTypeValue = value;
                      idType = value;
                    });
                  }),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            //So that all the field take up the entire container
            child: Container(
              child: DropdownButton<String>(
                  isExpanded: true,
                  value: criminalRecord,
                  hint: Text('Criminal Record'),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Yes',
                      child: Text('Yes'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'No',
                      child: Text('No'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      criminalRecordValue = value;
                      criminalRecord =
                          value; //State changed to update dropdown box value
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showTertiaryQueries() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            //So that all the field take up the entire container
            child: Container(
              //Id Type picker
              child: DropdownButton<String>(
                  isExpanded: true,
                  value: accessLevel,
                  hint: Text('Clearance Level'),
                  items: [
                    DropdownMenuItem<String>(
                      value: '1',
                      child: Text('1'),
                    ),
                    DropdownMenuItem<String>(
                      value: '2',
                      child: Text('2'),
                    ),
                    DropdownMenuItem<String>(
                      value: '3',
                      child: Text('3'),
                    ),
                    DropdownMenuItem<String>(
                      value: '4',
                      child: Text('4'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      accessLevelValue = value;
                      accessLevel = value;
                    });
                  }),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            //So that all the field take up the entire container
            child: Container(
              child: DropdownButton<String>(
                  isExpanded: true,
                  value: flyingLicense,
                  hint: Text('Flying License'),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Yes',
                      child: Text('Yes'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'No',
                      child: Text('No'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      flyingLicenseValue = value;
                      flyingLicense =
                          value; //State changed to update dropdown box value
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }
}