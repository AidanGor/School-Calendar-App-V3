import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/full_schedule.dart';
import '../models/day_model.dart';

class YearCalendarScreen extends StatefulWidget {
  final FullSchedule fullSchedule;
  final int year; 

  const YearCalendarScreen({
    Key? key,
    required this.fullSchedule,
    required this.year,
  }) : super(key: key);

  @override
  State<YearCalendarScreen> createState() => _YearCalendarScreenState();
}

class _YearCalendarScreenState extends State<YearCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Year View: ${widget.year}"),
      ),
      body: Column(
        children: [
          _buildViewSelector(context),
          Expanded(
            child: _buildYearGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/day');
            },
            child: const Text('Day'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/week');
            },
            child: const Text('Week'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/month');
            },
            child: const Text('Month'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Already on Year view!")),
              );
            },
            child: const Text('Year'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearGrid() {
    // Builds a list of 12 months
    final months = List.generate(12, (i) => DateTime(widget.year, i + 1, 1));

    // Displays them in a 3x4 grid
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        childAspectRatio: 1.3, // can be adjusted
      ),
      itemBuilder: (context, index) {
        final monthDate = months[index];
        return _buildMonthTile(monthDate);
      },
    );
  }

  Widget _buildMonthTile(DateTime monthDate) {
    final monthName = DateFormat('MMMM').format(monthDate); 
    return InkWell(
      onTap: () {
        
        Navigator.pushNamed(context, '/month'); 
       
      },
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Center(
          child: Text(
            monthName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}