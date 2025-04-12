import 'dart:math';
import 'package:flutter/material.dart';
import '../utility_widgets/graph.dart';

class Historydata extends StatelessWidget {
  const Historydata({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History Data',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 7, 90, 157),
              fontSize: 30,
              letterSpacing: sqrt1_2),
        ),
        backgroundColor: const Color.fromARGB(255, 88, 208, 252),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color.fromARGB(255, 88, 208, 252),
                Color.fromARGB(255, 248, 241, 241),
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 15, bottom: 10),
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text(
                    'October',
                    style: TextStyle(fontSize: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth data',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 7, 90, 157),
                            fontSize: 18),
                      ),
                      Divider(
                        color: Color.fromARGB(255, 19, 62, 135),
                        thickness: 2,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Graph(),
                  Text(
                    'November',
                    style: TextStyle(fontSize: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth data',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 7, 90, 157),
                            fontSize: 18),
                      ),
                      Divider(
                        color: Color.fromARGB(255, 19, 62, 135),
                        thickness: 2,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Graph(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
