import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/your_year_screen.dart';



class InitialHome extends StatefulWidget {
  const InitialHome({super.key});

  @override
  State<InitialHome> createState() => _InitialHomeState();
}

class _InitialHomeState extends State<InitialHome> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Center(
              child: Text("Your Days", style: GoogleFonts.bebasNeue(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                color: Color(0xff000000)
              ),),
            ),
            SizedBox(
              height: 90,
            ),
            SizedBox(height: 60,),
            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => YourYearScreen()),
              );
            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff000000),
                  minimumSize: Size(120, 80)),
                child: Text("Enter", style: TextStyle(
                  color: Colors.white,
                  fontSize: 25
                ),)),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 210),
              child: SizedBox(
                height: 4,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Color(0xff000000),
                ),
              ),
            )
        
          ],
        ),
      ),

    );
  }
}