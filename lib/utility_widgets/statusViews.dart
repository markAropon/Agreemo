import 'package:flutter/material.dart';

class Statusviews extends StatefulWidget {
  const Statusviews({super.key});

  @override
  State<Statusviews> createState() => _StatusviewsState();
}

class _StatusviewsState extends State<Statusviews> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
<<<<<<< HEAD
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(color: Colors.blueAccent),
=======
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.blueAccent),
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/ph.png', height: 30, width: 30),
                    const SizedBox(width: 5),
<<<<<<< HEAD
                    const Column(
=======
                    Column(
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '5.5%',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Text('PH LEVEL', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
<<<<<<< HEAD
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
                decoration: const BoxDecoration(color: Colors.blueAccent),
=======
            SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                decoration: BoxDecoration(color: Colors.blueAccent),
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/ppm.png', height: 30, width: 30),
                    const SizedBox(width: 5),
<<<<<<< HEAD
                    const Column(
=======
                    Column(
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '560ppm',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Text('NUTRIENT (NCS)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
<<<<<<< HEAD
        const SizedBox(height: 10),
=======
        SizedBox(height: 10),
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
<<<<<<< HEAD
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(color: Colors.blueAccent),
=======
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.blueAccent),
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/humidity.png',
                        height: 30, width: 30),
                    const SizedBox(width: 5),
<<<<<<< HEAD
                    const Column(
=======
                    Column(
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '62%',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Text('HUMIDITY', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
<<<<<<< HEAD
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(color: Colors.blueAccent),
=======
            SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.blueAccent),
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/temperature.png',
                        height: 30, width: 30),
                    const SizedBox(width: 5),
<<<<<<< HEAD
                    const Column(
=======
                    Column(
>>>>>>> 3f87042ab3e85ba53bb8da5bb8e17ecb2880fed1
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '26°',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Text('TEMPERATURE', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
