import 'package:flutter/material.dart';

class BankCard extends StatelessWidget{
  final String balance;

  BankCard({this.balance});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'bankCard',
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                padding: EdgeInsets.fromLTRB(5,35,0,0),
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
                                    fontSize: 40,
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
}