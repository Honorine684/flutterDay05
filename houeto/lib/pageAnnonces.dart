import 'package:flutter/material.dart';
import 'package:houeto/Sign.dart';

class PageVisites extends StatelessWidget {
  const PageVisites({super.key});

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;

    final hauteurEcran = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ConnexionPage()));
          }, icon: Icon(Icons.arrow_back)),
          title: Text('Annonces de visites', style: TextStyle(fontWeight: FontWeight.bold),),
          bottom: TabBar(tabs: [
            Tab(
              icon: Icon(
                Icons.schedule,
                size: 28,
              ),
              text: 'En cours',
            ),
            Tab(
              icon: Icon(
                Icons.check_circle,
                size: 28,
              ),
              text: 'Réalisées',
            ),
            Tab(
              icon: Icon(
                Icons.cancel,
                size: 28,
              ),
              text: 'Annulées',
            ),
          ]),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                    elevation: 5,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Richard ELISHA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.29,
                                ),
                                Container(
                                  height: hauteurEcran * 0.025,
                                  width: largeurEcran * 0.2,
                                  decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                    'En attente',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, color:  Color.fromRGBO(14, 9, 9, 0.475)),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Appartement T3 - Paris 10ème', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ), 
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Jeudi 28 mars, 14h30', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                 Icon(Icons.phone, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('0165437890', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                              
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.02,
                            ),
                          ],
                        ),
                      ),
                    )), 

                    SizedBox(height: hauteurEcran*0.01,),
                    Card(
                    elevation: 5,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Richard ELISHA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.29,
                                ),
                                Container(
                                  height: hauteurEcran * 0.025,
                                  width: largeurEcran * 0.2,
                                  decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                    'Confirmée',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, color:  Color.fromRGBO(14, 9, 9, 0.475)),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Appartement T3 - Paris 10ème', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ), 
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Jeudi 28 mars, 14h30', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                 Icon(Icons.phone, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('0165437890', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                              
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                    elevation: 5,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Richard ELISHA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.29,
                                ),
                                Container(
                                  height: hauteurEcran * 0.025,
                                  width: largeurEcran * 0.2,
                                  decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                    'Terminée',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, color:  Color.fromRGBO(14, 9, 9, 0.475)),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Appartement T3 - Paris 10ème', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ), 
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Jeudi 28 mars, 14h30', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                 Icon(Icons.phone, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('0165437890', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                              
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.02,
                            ),
                          ],
                        ),
                      ),
                    )), 

                    SizedBox(height: hauteurEcran*0.01,),
                    Card(
                    elevation: 5,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Richard ELISHA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.29,
                                ),
                                Container(
                                  height: hauteurEcran * 0.025,
                                  width: largeurEcran * 0.2,
                                  decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                    'Terminée',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, color:  Color.fromRGBO(14, 9, 9, 0.475)),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Appartement T3 - Paris 10ème', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ), 
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Jeudi 28 mars, 14h30', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                 Icon(Icons.phone, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('0165437890', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                              
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                    elevation: 5,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Richard ELISHA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.29,
                                ),
                                Container(
                                  height: hauteurEcran * 0.025,
                                  width: largeurEcran * 0.2,
                                  decoration: BoxDecoration(
                                      color: Colors.red[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                    'Annulée',
                                    style: TextStyle(fontSize: 12, color: Colors.red ),
                                  )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, color:  Color.fromRGBO(14, 9, 9, 0.475)),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Appartement T3 - Paris 10ème', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ), 
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Jeudi 28 mars, 14h30', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                 Icon(Icons.phone, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('0165437890', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                              
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.02,
                            ),
                          ],
                        ),
                      ),
                    )), 

                    SizedBox(height: hauteurEcran*0.01,),
                    Card(
                    elevation: 5,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Richard ELISHA',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.29,
                                ),
                                Container(
                                  height: hauteurEcran * 0.025,
                                  width: largeurEcran * 0.2,
                                  decoration: BoxDecoration(
                                      color: Colors.red[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                    'Annulée',
                                    style: TextStyle(fontSize: 12, color: Colors.red ),
                                  )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, color:  Color.fromRGBO(14, 9, 9, 0.475)),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Appartement T3 - Paris 10ème', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ), 
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('Jeudi 28 mars, 14h30', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.015,
                            ),
                            Row(
                              children: [
                                 Icon(Icons.phone, color:  Color.fromRGBO(14, 9, 9, 0.475)),
SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text('0165437890', style: TextStyle(color:  Color.fromRGBO(14, 9, 9, 0.475),),)
                              ],
                              
                            ),
                            SizedBox(
                              height: hauteurEcran * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
