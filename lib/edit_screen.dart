import 'dart:async';

import 'package:calendar_event/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EditScreen extends StatefulWidget {
  final String title;
  final CalendarEvent event;
  EditScreen({Key key, this.title, this.event}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  CalendarEvent event;
  TextEditingController eventNameController;
  bool _isAllDay = false;
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  static final DateFormat formatter = DateFormat('E, MMM d, y');
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  Color _selectedEventColor = Colors.blueAccent;

  final eventColors = {
    Colors.lightGreen: 'Light Green',
    Colors.blueAccent: 'Blue Accent',
    Colors.amberAccent: 'Amber Accent',
  };

  @override
  void initState() {
    super.initState();
    event = widget.event;
    setState(() {
      _selectedEventColor = event.eventColor;
      int hoursLimitPerDay = 23;
      if (event.duration < Duration(hours: 24)) {
        _selectedStartTime = _selectedStartTime.replacing(hour: event.duration.inHours.remainder(24), minute: event.duration.inMinutes.remainder(60));
        if (_selectedStartTime.hour < hoursLimitPerDay) {
          _selectedEndTime =
              _selectedStartTime.replacing(hour: _selectedStartTime.hour + 1);
        } else {
          _selectedEndTime =
              _selectedStartTime.replacing(hour: 0);
        }
      } else if (event.duration == Duration(hours: 24)) {
        _isAllDay = true;
        _selectedEndTime =
            _selectedStartTime.replacing(hour: 0);
      } else {
        _selectedEndTime =
            _selectedStartTime.replacing(hour: 0);
      }
      _selectedStartDate = event.date;
      eventNameController = TextEditingController(text: event.name);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            if (eventNameController.text.isNotEmpty) {
              _showDiscardAlertDialog(context).then((value) {
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
              if (name == null || name.isEmpty) {
                _showEmptyTitleAlertDialog(context).then((value) {
                  return;
                });
                return;
              }

              DateTime date = DateTime(
                  _selectedStartDate.year, _selectedStartDate.month, _selectedStartDate.day,
                  _selectedStartTime.hour, _selectedStartTime.minute
              );

              Duration duration = _isAllDay ? Duration(hours: 24)
                  : Duration(hours: _selectedStartTime.hour, minutes: _selectedStartTime.minute);
              CalendarEvent event = CalendarEvent(name, date, duration, _selectedEventColor);
              Navigator.pop(context, event);
            },
            child: Text("Save"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _createEventTextField(eventNameController, 'Add Title'),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Calendar Event'),
                Flexible(
                    child: Center(child: DropdownButton(
                        value: _selectedEventColor,
                        items:
                        [Colors.lightGreen, Colors.blueAccent, Colors.amberAccent].map((color) {
                          return DropdownMenuItem(
                            value: color,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: color,
                                  size: 24.0,
                                  semanticLabel: 'Text to announce in accessibility modes',
                                ),
                                Text(eventColors[color]),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            _selectedEventColor = value;
                          });
                        }),)),]
          ),
            ]),
        ),
          _createAllDaySwitch(),
          GestureDetector(
            onTap: () => _selectStartDate(context),
            child: Center(child: Text(formatter.format(_selectedStartDate),
              style: TextStyle(fontSize: 20.0),),
            )),
          _createDateTimeRow(context, _selectedStartTime, _selectedEndTime,
                  () => _selectStartTime(context),
                  () => _selectEndTime(context)),
        ],
      ),
    );
  }
  
  Future<Null> _selectStartTime(BuildContext context ) async {
    final picked = await showTimePicker(context: context, initialTime: _selectedStartTime);

    print(_selectedStartTime);
    if (picked != null && picked != _selectedStartTime) {
      int nextHour = _selectedStartTime.hour + 1;
      TimeOfDay nextTimeOfDay = _selectedStartTime.replacing(hour: nextHour);
      setState(() {
        _selectedStartTime = picked;
        _selectedEndTime = nextTimeOfDay;
      });
    }
  }
  
  Future<Null> _selectEndTime(BuildContext context ) async {
    int nextHour = _selectedStartTime.hour + 1;
    TimeOfDay initial = _selectedStartTime.replacing(hour: nextHour);
    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
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

  Widget _createDateTimeRow(BuildContext context, TimeOfDay start, TimeOfDay end,
                         Function onTapStartTime, Function onTapEndTime) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Opacity(opacity: !_isAllDay ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: onTapStartTime,
                child: Center(child: Text(start.format(context),
                  style: TextStyle(fontSize: 20.0),),
                )),
          ),),Flexible(
            child: Opacity(opacity: !_isAllDay ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: onTapEndTime,
                child: Center(child: Text(end.format(context),
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

  static Future<bool> _showDiscardAlertDialog(BuildContext context) {
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

  static Future<bool> _showEmptyTitleAlertDialog(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
          title: Text('Event title is required.'),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(true),
              elevation: 5.0,
              child: Text('Ok'),
            ),
          ]
      );
    });
  }
}
