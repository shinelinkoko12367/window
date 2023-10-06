import 'package:flutter/material.dart';
import 'package:webproject/HomePage/stockin.dart';
import 'package:webproject/HomePage/stockout.dart';
import 'package:webproject/constant/constant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: fillColor,
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: size.width * 0.1,
                    height: size.width * 0.03,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor,
                    ),
                    child: Text(
                      'English',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    width: size.width * 0.1,
                    height: size.width * 0.03,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor,
                    ),
                    child: Center(
                        child: Text(
                      'Myanmar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ))),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    width: size.width * 0.1,
                    height: size.width * 0.03,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor,
                    ),
                    child: Center(
                        child: Text(
                      'Chinese',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ))),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => StockIn()));
                  },
                  child: Container(
                      width: size.width * 0.1,
                      height: size.width * 0.05,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: mainColor,
                      ),
                      child: Center(
                          child: Text(
                        'Stock In',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ))),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => StockOut()));
                  },
                  child: Container(
                      width: size.width * 0.1,
                      height: size.width * 0.05,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: mainColor,
                      ),
                      child: Center(
                          child: Text(
                        'Stock Out',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ))),
                ),
                Container(
                    width: size.width * 0.1,
                    height: size.width * 0.05,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor,
                    ),
                    child: Center(
                        child: Text(
                      'About Us',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    )))
              ],
            )
          ],
        ),
      ),
    );
  }
}
