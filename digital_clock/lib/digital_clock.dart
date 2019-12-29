// Developer email : dev.mahakeemmk@gmail.com
import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _TimeOfDay {
  MID_NIGHT, // 00H - 03H (24H time)
  EARLY_DAWN, // 03H - 06H
  DAWN, // 06H - 09H
  MORNING, // 09H - 12H
  NOON, // 12H - 15H
  AFTERNOON, // 15H - 18H
  DUSK, // 18H - 20H
  NIGHT // 20H - 24H
}

/// A digital clock simulating various sun lighting based on time of day.
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with TickerProviderStateMixin {
  var top;
  var bottom;
  var skyColors;
  AnimationController _controller;
  Animation<Offset> _animation;
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // Animation controller for the jumping card animation.
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _animation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.1))
        .animate(_controller);

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
// sun position and light color based on time of day.
  void _setTimeOfDay(_TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case _TimeOfDay.MID_NIGHT:
        top = FractionalOffset.bottomLeft;
        bottom = FractionalOffset.topRight;
        skyColors = [Colors.black, Colors.black45];
        break;
      case _TimeOfDay.EARLY_DAWN:
        top = FractionalOffset.centerLeft;
        bottom = FractionalOffset.centerRight;
        skyColors = [Colors.yellow[100], Colors.blueGrey];
        break;
      case _TimeOfDay.DAWN:
        top = FractionalOffset.centerLeft;
        bottom = FractionalOffset.centerRight;
        skyColors = [Colors.yellow[200], Colors.blueAccent];
        break;
      case _TimeOfDay.MORNING:
        top = FractionalOffset.topLeft;
        bottom = FractionalOffset.topRight;
        skyColors = [Colors.yellow[200], Colors.blueAccent];
        break;
      case _TimeOfDay.NOON:
        top = FractionalOffset.topCenter;
        bottom = FractionalOffset.bottomCenter;
        skyColors = [Colors.yellow[200], Colors.blueAccent];
        break;
      case _TimeOfDay.AFTERNOON:
        top = FractionalOffset.topRight;
        bottom = FractionalOffset.bottomLeft;
        skyColors = [Colors.yellow[200], Colors.blueAccent];
        break;
      case _TimeOfDay.DUSK:
        top = FractionalOffset.centerRight;
        bottom = FractionalOffset.centerLeft;
        skyColors = [Colors.red[200], Colors.blueGrey[100]];
        break;
      case _TimeOfDay.NIGHT:
        top = FractionalOffset.bottomRight;
        bottom = FractionalOffset.topLeft;
        skyColors = [Colors.black, Colors.grey];
        break;
      default:
    }
  }
// jumping card animation.
  void _animate() {
    _controller.forward();
    Timer(Duration(milliseconds: 100), () => _controller.reverse());
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _animate();
      _dateTime = DateTime.now();
      int _h = _dateTime.hour;
      // setting time of day to simulate sun positions.
      if (_h >= 0 && _h < 3) {
        _setTimeOfDay(_TimeOfDay.MID_NIGHT);
      } else if (_h >= 3 && _h < 6) {
        _setTimeOfDay(_TimeOfDay.EARLY_DAWN);
      } else if (_h >= 6 && _h < 9) {
        _setTimeOfDay(_TimeOfDay.DAWN);
      } else if (_h >= 9 && _h < 12) {
        _setTimeOfDay(_TimeOfDay.MORNING);
      } else if (_h >= 12 && _h < 15) {
        _setTimeOfDay(_TimeOfDay.NOON);
      } else if (_h >= 15 && _h < 18) {
        _setTimeOfDay(_TimeOfDay.AFTERNOON);
      } else if (_h >= 18 && _h < 20) {
        _setTimeOfDay(_TimeOfDay.DUSK);
      } else if (_h >= 20 && _h < 24) {
        _setTimeOfDay(_TimeOfDay.NIGHT);
      }

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
    // time formatting based on clock setting (24h/12h).
    final time =
        DateFormat(widget.model.is24HourFormat ? 'Hm' : 'jm').format(_dateTime);
    //font size for digital clock text.
    final fontSize = 105.0;
    final defaultStyle = TextStyle(
      fontFamily: 'roboto-condensed',
      fontSize: fontSize,
    );
// Animated container for simulating sun movements and color.
    return AnimatedContainer(
      //Animation duration for the simulation.
      duration: Duration(minutes: 3),
      decoration: BoxDecoration(
        //gradient to represent sun light.
        gradient: LinearGradient(
          begin: top,
          end: bottom,
          colors: skyColors,
          stops: [0.0, 1.0],
        ),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    time,
                    style: defaultStyle,
                  ),
                ),
              ),
              SlideTransition(
                position: _animation,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      time,
                      style: defaultStyle,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
