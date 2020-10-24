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
  Map<DateTime, List> _events = Map<DateTime, List>();
  List _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        'Event A0',
        'Event B0',
        'Event C0'
      ],
      _selectedDay.subtract(Duration(days: 27, hours: 5)): ['Event A1'],
      _selectedDay: [
        'Event A2',
        'Event B2',
        'Event C2',
        'Event D2',
      ]
    };
    setState(() {
      _selectedEvents = _events[_selectedDay];
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
          TableCalendar(
            events: _events,
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
          ),
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
  
  static _navigateToAddEvent(BuildContext context) async {
    var result = await Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext ctx) => AddScreen(),
      fullscreenDialog: true,)
    );

    Scaffold.of(context).showSnackBar(SnackBar(content: Text("$result"),duration: Duration(seconds: 3),));
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
      _selectedEvents = events;
    });
  }

  Widget _buildEventList() {
    List<dynamic> events = _selectedEvents ?? [];
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: events
          .map((event) => Container(
        decoration: BoxDecoration(
          color: Colors.red[100],
          border: Border(bottom: BorderSide(
              color: Colors.blueAccent,
              width: 0.4
          )),
//          borderRadius: BorderRadius.circular(12.0),
        ),
//        margin:
//        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString()),
          onTap: () => print('$event tapped!'),
        ),
      ))
          .toList(),
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
