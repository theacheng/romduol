import 'package:flutter/material.dart';
import 'package:romduol/widget/theme.dart';

class Date {
  String year, day, month;
  Date({this.year, this.day, this.month});

  Date toKhDate(DateTime date, bool isKH) {
    List<String> month = [
      'មករា',
      'កុម្ភៈ',
      'មីនា',
      'មេសា',
      'ឧសភា',
      'មិថុនា',
      'កក្កដា',
      'សីហា',
      'កញ្ញា',
      'តុលា',
      'វិច្ឆិកា',
      'ធ្នូ',
    ];

    List<String> monthEN = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    Date khDate = Date(
      day: khNum(date.day.toString(), isKH),
      month: isKH ? month[date.month] : monthEN[date.month],
      year: khNum(date.year.toString(), isKH),
    );
    return khDate;
  }

  //get amount of day in a month
  int daysInMonth(DateTime date) {
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = new DateTime(firstDayThisMonth.year,
        firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  //get day length between 2 date
  int getLength(DateTime from, DateTime to) {
    int length;
    if (to.day - from.day >= 0)
      length = to.day - from.day;
    else {
      length = Date().daysInMonth(from) - from.day + to.day;
    }
    return length;
  }

  //get last date from start date + limited date length
  DateTime getLastDate(DateTime selectedDate, int _maxDateLength) {
    int dateLenght = _maxDateLength - 1;
    int _day = selectedDate.day,
        _month = selectedDate.month,
        _year = selectedDate.year;

    int thismonth = Date().daysInMonth(selectedDate);

    //if selected + limit date > day length of this month, example: 28 + 5 = 33 > 31
    if (selectedDate.day + dateLenght > thismonth) {
      _day = selectedDate.day + dateLenght - thismonth;
      _month = selectedDate.month + 1;

      //if it is a last month of year
      if (selectedDate.month == 12) {
        _month = 1;
        _year = selectedDate.year + 1;
      }
    } else {
      _day = selectedDate.day + dateLenght;
    }

    return DateTime(_year, _month, _day);
  }

  //get date of next month which is last date
  DateTime getLastMonth(DateTime selectedDate) {
    int _day = selectedDate.day,
        _month = selectedDate.month,
        _year = selectedDate.year;

    if (selectedDate.day > 28) _day = 28;
    if (selectedDate.month == 12) {
      _year = selectedDate.year + 1;
      _month = 0;
    }
    return DateTime(_year, _month + 1, _day);
  }
}

class Time {
  final int hour, min, sec;
  final String status;
  Time({this.hour, this.min, this.sec, this.status});

  Time toSpecific(TimeOfDay time, bool isKH) {
    int _hour = 0, _min = 0, _sec = 0;
    String _status = isKH ? "ព្រឺក" : "Morning";
    

    _hour = time.hour;

    if (time.minute >= 0 && time.minute < 15) {
      _min = 0;
    }

    if (time.minute >= 15 && time.minute < 30) {
      _min = 15;
    }

    if (time.minute >= 30 && time.minute < 45) {
      _min = 30;
    }

    if (time.minute >= 45 && time.minute < 50) {
      _min = 45;
    }

    if (time.minute >= 50) {
      _min = 0;
      _hour += 1;
    }

    if (_hour > 12) {
      _hour -= 12;
      _status = isKH ? "ល្ងាច" : "Evening";
    }

    return Time(hour: _hour, min: _min, sec: _sec, status: _status);
  }
}
