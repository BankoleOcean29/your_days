import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/custom_paint_expo.dart';

class YourYearScreen extends StatefulWidget {
  const YourYearScreen({super.key});

  @override
  State<YourYearScreen> createState() => _YourYearScreenState();

}



class _YourYearScreenState extends State<YourYearScreen> {


  @override
  Widget build(BuildContext context) {

    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final currentDayOfYear = now.difference(firstDayOfYear).inDays + 1;

    // Calculate percentage of year left
    final daysLeft = 365 - currentDayOfYear;
    final percentageLeft = (daysLeft / 365 * 100).round();


    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50,),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 400,
              child: CustomPaint(
                painter: DotPainter(currentDayOfYear: currentDayOfYear),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0, left: 15),
              child: Row(
                children: [
                  Text(
                    now.year.toString(), style: GoogleFonts.bebasNeue(
                fontSize: 20,
                fontWeight: FontWeight.w600
                  ),
                  ),
                  SizedBox(
                    width: 200,
                  ),
                  Text(
                    "$percentageLeft% left", style: GoogleFonts.bebasNeue(
                      fontSize: 30,
                      fontWeight: FontWeight.w600
                  ),
                  ),

                ],
              ),
            )
          ],
        ),
      )
    );
  }


}