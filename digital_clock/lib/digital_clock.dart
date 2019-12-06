// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

enum _TimeOfDay {
  MID_NIGHT,  // 12AM - 3AM
  EARLY_DAWN, // 3AM - 6AM
  DAWN,       // 6AM - 9AM 
  MORNING,    // 9AM - 12PM
  NOON,       // 12PM - 3PM
  AFTERNOON,  // 3PM - 6PM
  DUSK,       // 6PM - 9PM
  NIGHT       // 9PM - 12AM
}

final _lightTheme = {
  _Element.background: Colors.grey,
  _Element.text: Colors.black,
  _Element.shadow: Colors.black45,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  int timeFrame = 0;
  var top = FractionalOffset.bottomLeft;
  var bottom = FractionalOffset.topRight;
  var dayColors = [
    Colors.black, Colors.black45
  ];

  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _setTimeOfDay(_TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case _TimeOfDay.MID_NIGHT : 
          top = FractionalOffset.bottomLeft;
          bottom = FractionalOffset.topRight;
          dayColors = [Colors.black, Colors.black45];
        break;
      case _TimeOfDay.EARLY_DAWN :
        top = FractionalOffset.centerLeft;
        bottom = FractionalOffset.centerRight;
        dayColors = [Colors.yellow[100], Colors.blueGrey];   
      break;
      case _TimeOfDay.DAWN :
        top = FractionalOffset.centerLeft;
        bottom = FractionalOffset.centerRight;
        dayColors = [Colors.yellowAccent,Colors.blueAccent];       
      break;
      case _TimeOfDay.MORNING :
        top = FractionalOffset.topLeft;
        bottom = FractionalOffset.topRight;
        dayColors = [Colors.yellowAccent,Colors.blueAccent];      
      break;
      case _TimeOfDay.NOON :
        top = FractionalOffset.topCenter;
        bottom = FractionalOffset.bottomCenter;
        dayColors = [Colors.yellowAccent,Colors.blueAccent];   
      break;
      case _TimeOfDay.AFTERNOON :
        top = FractionalOffset.topRight;
        bottom = FractionalOffset.bottomLeft;
        dayColors = [Colors.redAccent,Colors.blueAccent];    
      break;
      case _TimeOfDay.DUSK :
        top = FractionalOffset.centerRight;
        bottom = FractionalOffset.centerLeft;
        dayColors = [Colors.redAccent,Colors.blueGrey];     
      break;
      case _TimeOfDay.NIGHT :
        top = FractionalOffset.bottomRight;
        bottom = FractionalOffset.topLeft;
        dayColors = [Colors.black,Colors.grey];      
      break;
      default:
    }
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 3.5;
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'roboto-condensed',
      fontSize: fontSize,
    );

    return AnimatedContainer(
      duration: Duration(seconds: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: top,
          end: bottom,
          colors: dayColors,
          stops: [0.0, 1.0],
        ),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        hour,
                        style: TextStyle(fontSize: 64.0),
                      ),
                    ),
                  )
                  // Positioned(left: offset, top: 0, child: Text(hour)),
                  // Positioned(right: offset, bottom: offset, child: Text(minute)),
                ],
              ),
              Stack(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        minute,
                        style: TextStyle(fontSize: 64.0),
                      ),
                    ),
                  )
                ],
              ),
              RaisedButton(
                child: Text("Change"),
                onPressed: () {
                  setState(() {
                    _setTimeOfDay(_TimeOfDay.values[timeFrame]);
                    timeFrame++;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
