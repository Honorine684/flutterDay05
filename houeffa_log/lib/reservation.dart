import 'package:flutter/material.dart';



class Reservation extends StatefulWidget {
  const Reservation({Key? key}) : super(key: key);

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  DateTime selectedDate = DateTime.now();


  final List<String> days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
  ];


  final List<String> hours = [
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  String? selectedDay;
  String? selectedHour; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            SizedBox(width: 8),
            Text('Réservation'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              (selectedDay == null || selectedHour == null)
                  ? "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
                  : "$selectedDay ${selectedDate.year}-${selectedDate.month}-${selectedDate.day} à $selectedHour",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            
            ElevatedButton(
              child: const Text("Choisir une date"),
              onPressed: () async {
                final DateTime? dateTime = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (dateTime != null) {
                  setState(() {
                    selectedDate = dateTime;
                    
                    selectedDay = null;
                    selectedHour = null;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            
            Text(
              "Jours disponibles :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = days[index];
                          selectedHour = null; 
                        });
                      },
                      child: Chip(
                        label: Text(days[index]),
                        backgroundColor: selectedDay == days[index]
                            ? Colors.deepOrangeAccent
                            : Colors.grey[300],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            
            if (selectedDay != null) ...[
              Text(
                "Heures disponibles :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: hours.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(hours[index]),
                      tileColor: selectedHour == hours[index]
                          ? Colors.deepOrangeAccent.withOpacity(0.2)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedHour = hours[index];
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            
          ],
        ),
      ),
    );
  }
}