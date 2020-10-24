import 'package:calendar_event/add_screen.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  CalendarController _calendarController;
  Map<DateTime, List> _eventsOfTheSelectedDay = Map<DateTime, List>();
  List _selectedCalendarDate = [];
  DateTime _selectedDay = DateTime.now();
//  List users = [
//    const Item('Android',Icon(Icons.android,color:  const Color(0xFF167F67),)),
//    const Item('Flutter',Icon(Icons.flag,color:  const Color(0xFF167F67),)),
//    const Item('ReactNative',Icon(Icons.format_indent_decrease,color:  const Color(0xFF167F67),)),
//    const Item('iOS',Icon(Icons.mobile_screen_share,color:  const Color(0xFF167F67),)),
//  ];

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();

    CalendarEvent event1 = CalendarEvent('name 1', _selectedDay.subtract(Duration(days: 1)), Duration(days: 1), Colors.lightGreen);
    CalendarEvent event2 = CalendarEvent('name 2', _selectedDay.subtract(Duration(days: 2)), Duration(days: 1), Colors.lightGreen);
    CalendarEvent event3 = CalendarEvent('name 3', _selectedDay.subtract(Duration(hours: 2)), Duration(hours: 21), Colors.lightGreen);
    CalendarEvent event4 = CalendarEvent('name 4', _selectedDay.subtract(Duration(hours: 2, minutes: 30)), Duration(hours: 15, minutes: 30), Colors.lightGreen);

    [event1, event2, event3, event4].forEach((event) {

      DateTime formattedDate = DateTime(event.date.year, event.date.month, event.date.day, 0, 0);
      List calendarEvents = _eventsOfTheSelectedDay[formattedDate];
      if (calendarEvents == null) {
        calendarEvents = [];
      }
      calendarEvents.add(event);
      _eventsOfTheSelectedDay[formattedDate] = calendarEvents;

    });

    DateTime formattedDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0, 0);
    setState(() {
      _selectedCalendarDate = _eventsOfTheSelectedDay[formattedDate];
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _createTableCalendar(),
          Expanded(child: _buildEventList()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEvent(context);
        },
        tooltip: 'Add Event',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  
  _navigateToAddEvent(BuildContext context) async {
    CalendarEvent result = await Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext ctx) => AddScreen(),
      fullscreenDialog: true,)
    );

    if (result == null) {
      return;
    }

    DateTime formattedDate = DateTime(result.date.year, result.date.month, result.date.day, 0, 0);
    List events = _eventsOfTheSelectedDay[formattedDate];
    List<dynamic> existingEvents = events != null && events.isNotEmpty? events.toList(): [];
    existingEvents.add(result);

    existingEvents.forEach((event) {
      print(event.name);
    });

    setState(() {
      _eventsOfTheSelectedDay[formattedDate] = existingEvents;
      _selectedCalendarDate = existingEvents;
    });
  }

  Widget _createTableCalendar() {
    return TableCalendar(
      events: _eventsOfTheSelectedDay,
      calendarController: _calendarController,
      onDaySelected: _onDaySelected,
      builders: CalendarBuilders(
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          return children;
        },
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red[800]
      ),
      width: 18.0,
      height: 18.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    print(events);
    setState(() {
      _selectedCalendarDate = events;
    });
  }

  Widget _buildEventList() {
    List events = _selectedCalendarDate ?? [];
    List<Widget> widgetEvents = events.map((event) {

      final int hour = event.duration.inHours;
      final int minutes = event.duration.inMinutes.remainder(60);
      return Container(
        decoration: BoxDecoration(
          color: event.eventColor,
          border: Border(bottom: BorderSide(
              color: Colors.blue[800],
              width: 0.4
          )),
        ),
        child: ListTile(
          title: Text(
              '${hour.toString().padLeft(2, "0")}:${minutes.toString().padLeft(
                  2, "0")} - ${event.name}'),
          onTap: () => print('$event tapped!'),
        ),
      );
    }).toList();
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: widgetEvents,
    );
  }

  static Future<String> createAlertDialog(BuildContext context, String dialogText, String buttonText) {
    TextEditingController eventNameController = TextEditingController();
    TextEditingController dateNameController = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
          title: Text(dialogText),
          content:Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: eventNameController
                ),
                TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: dateNameController
                ),
              ]
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(eventNameController.text.toString());
              },
              elevation: 5.0,
              child: Text(buttonText),
            )
          ]
      );
    });
  }

  showEventDialog(BuildContext context, {
        TextEditingController usernameController,
        TextEditingController loginController,
        Function onPressed, String title, List<Widget> widgets,
        String actionName }) {
    Alert(
        context: context,
        title: title,
        content: Column(
          children: widgets
        ),
        buttons: [
          DialogButton(
            onPressed: onPressed,
            child: Text(
              actionName,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class CalendarEvent {
  int id;
  String name;
  DateTime date;
  Duration duration;
  Color eventColor;

  CalendarEvent(name, date, duration, eventColor) {
    this.name = name;
    this.date = date;
    this.duration = duration;
    this.eventColor = eventColor;
  }

  CalendarEvent build(name, date, duration, eventColor) {
    return CalendarEvent(name, date, duration, eventColor);
  }
}
