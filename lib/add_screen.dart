import 'dart:async';

import 'package:calendar_event/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AddScreen extends StatefulWidget {
  final String title;
  AddScreen({Key key, this.title}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController eventNameController = TextEditingController();
  bool _isAllDay = false;
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  static final DateFormat formatter = DateFormat('E, MMM d, y');
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool isScreenDirty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            if (eventNameController.text.isNotEmpty) {
              _createAlertDialog(context).then((value) {
                if (value) {
                  Navigator.pop(context, null);
                }
              });
            } else {
              Navigator.pop(context, null);
            }
          },
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              String name = eventNameController.text.toString();


              DateTime date = DateTime(
                  _selectedStartDate.year, _selectedStartDate.month, _selectedStartDate.day,
                  _selectedStartTime.hour, _selectedStartTime.minute
              );



              Duration duration = _isAllDay ? 0
                  : Duration(hours: _selectedEndTime.hour, minutes: _selectedEndTime.minute) - Duration(hours: _selectedStartTime.hour, minutes: _selectedStartTime.minute);
//              CalendarEvent event = CalendarEvent()

              print('--------------------1');
              print(duration);
              print(name);
              print(date);
              print('--------------------2');
//              Navigator.pop(context, null);
            },
            child: Text("Save"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _createEventTextField(eventNameController, 'Add Title'),
          _createAllDaySwitch(),
          _createDateTimeRow(context, _selectedStartDate, _selectedStartTime,
                  () => _selectStartDate(context),
                  () => _selectStartTime(context)),
          _createDateTimeRow(context, _selectedEndDate, _selectedEndTime,
                  () => _selectEndDate(context),
                  () => _selectEndTime(context)),
        ],

      ),
    );
  }
  
  Future<Null> _selectStartTime(BuildContext context ) async {
    final picked = await showTimePicker(context: context, initialTime: _selectedStartTime);

    print(picked);
    setState(() {
      _selectedStartTime = picked;
    });
  }
  
  Future<Null> _selectEndTime(BuildContext context ) async {
    final picked = await showTimePicker(context: context, initialTime: _selectedEndTime);

    print(picked);
    setState(() {
      _selectedEndTime = picked;
    });
  }
  
  _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedStartDate)
      setState(() {
        _selectedStartDate = picked;
      });
  }
  
  _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedEndDate)
      setState(() {
        _selectedEndDate = picked;
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _createDateTimeRow(BuildContext context, DateTime dateTime, TimeOfDay time,
                         Function onTapDate, Function onTapTime) {

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: GestureDetector(
                onTap: onTapDate,
                child: Center(child: Text(formatter.format(dateTime),
                  style: TextStyle(fontSize: 20.0),),
                )),
          ),Flexible(
            child: Opacity(opacity: !_isAllDay ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: onTapTime,
                child: Center(child: Text(time.format(context),
                  style: TextStyle(fontSize: 20.0),),
                )),
          ),)]);
  }

  Widget _createAllDaySwitch() {
    return SwitchListTile(
      title: const Text('All Day'),
      value: _isAllDay,
      onChanged: (value) {
        setState(() {
          _isAllDay = value;
        });
      },
      secondary: const Icon(Icons.timer),
    );
  }

  Widget _createEventTextField(TextEditingController eventController, String title) {
    return TextField(
      controller: eventController,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Future<bool> _showDiscardChangesDialog() {
    AlertDialog(
        title: Text('Discard this event?'),
        actions: <Widget>[
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(true),
            elevation: 5.0,
            child: Text('Discard'),
          ),
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            elevation: 5.0,
            child: Text('Keep editing'),
          ),
        ]
    );
  }

  static Future<bool> _createAlertDialog(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
          title: Text('Discard this event?'),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(true),
              elevation: 5.0,
              child: Text('Discard'),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(false),
              elevation: 5.0,
              child: Text('Keep editing'),
            ),
          ]
      );
    });
  }
}
