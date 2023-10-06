import 'package:flutter/material.dart';
import 'package:webproject/constant/constant.dart';

class PageOne extends StatefulWidget {
  const PageOne({super.key});

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  
  bool _isChecked = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  // double _zoomLevel = 1.0; // Initial zoom level
  // double _minZoom = 0.5;
  // double _maxZoom = 2.0;

  // void _updateZoom(double value) {
  //   setState(() {
  //     _zoomLevel = value;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child:Row(
          children: [
            
            // Container(
            //   width: 40,
            //   height: 200,
            //   color: Colors.grey,
            //   child: RotatedBox(
            //    quarterTurns: 1, // Rotate the slider vertically
            //    child: Slider(
            //    value: _zoomLevel,
            //     min: _minZoom,
            //     max: _maxZoom,
            //     onChanged: _updateZoom,
            //     ),
            //    ),
            // ),
            Column(
              children: [
                maincamrea(size),
                container(size)
              ],
            ),
            Column(
              children: [
                buttoncontainer(size)
              ],
            ),
          ],
        ) 
        ),
    );
  }

  Container maincamrea(Size size) {
    return Container(
                width: size.width*0.70,
                height: size.height*0.5,
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: size.width*0.25,
                      height: size.height*0.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:mainColor,
                        ),
                      child: Center(
                        child: Text("Main Camera",
                        style: TextStyle(fontSize: 20,color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                        width: size.width*0.18,
                        height: size.height*0.245,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:mainColor,
                        ),
                        child: Center(child: Text("Selfie Camera",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                        )),
                      ),
                      SizedBox(height: 5),
                      Container(
                       width: size.width*0.18,
                        height: size.height*0.245,
                         decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:mainColor,
                        ),
                        child: Center(child: Text("Item Image",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                        )),
                      ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                     informationcontainer(size),
                 ],
                ),
              );
  }

  Container buttoncontainer(Size size) {
    return Container(
                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                width: size.width*0.19,
                height: size.height*0.9,
                // color: Colors.indigo,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: size.width*0.185,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          
                        ),
                       child: Center(
                        child: Text("Info",style: TextStyle(color: Colors.black),),
                       ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 1, // Spread radius
                          blurRadius: 3, // Blur radius
                          offset: Offset(0, 3), // Offset in (x, y) direction
                            ),
                          ],
                        ),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Broker Return Item"),
                           ],
                         ),
                      ),
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 1, // Spread radius
                          blurRadius: 3, // Blur radius
                          offset: Offset(0, 3), // Offset in (x, y) direction
                            ),
                          ],
                        ),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("New Item"),
                           ],
                         ),
                      ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 1, // Spread radius
                          blurRadius: 3, // Blur radius
                          offset: Offset(0, 3), // Offset in (x, y) direction
                            ),
                          ],
                        ),
                        
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Re-Scan"),
                           ],
                         ),
                      ),
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 1, // Spread radius
                          blurRadius: 3, // Blur radius
                          offset: Offset(0, 3), // Offset in (x, y) direction
                            ),
                          ],
                        ),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Scan"),
                           ],
                         ),
                      ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), 
                          spreadRadius: 1, 
                          blurRadius: 3, 
                          offset: Offset(0, 3), 
                            ),
                          ],
                        ),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Re-Print"),
                           ],
                         ),
                      ),
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), 
                          spreadRadius: 1, 
                          blurRadius: 3,
                          offset: Offset(0, 3), 
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Print"),
                           ],
                         ),
                      ),
                        ],
                      ),
                      SizedBox(height:15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          spreadRadius: 1, // Spread radius
                          blurRadius: 3, // Blur radius
                          offset: Offset(0, 3), // Offset in (x, y) direction
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Delete"),
                           ],
                         ),
                      ),
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), 
                          spreadRadius: 1, 
                          blurRadius: 3, 
                          offset: Offset(0, 3), 
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Edit"),
                           ],
                         ),
                      ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                         
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), 
                          spreadRadius: 1, 
                          blurRadius: 3, 
                          offset: Offset(0, 3), 
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Finished"),
                           ],
                         ),
                      ),
                        ],
                      ),
                      SizedBox(height: 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), 
                          spreadRadius: 1, 
                          blurRadius: 3, 
                          offset: Offset(0, 3), 
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Setting"),
                           ],
                         ),
                      ),
                       Container(
                        width: size.width*0.09,
                        height: size.width*0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: fillColor,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.5), 
                          spreadRadius: 1, 
                          blurRadius: 3, 
                          offset: Offset(0, 3), 
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Camera Setting"),
                           ],
                         ),
                      ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
  }

  Container informationcontainer(Size size) {
    return Container(
                      width: size.width*0.25,
                      height: size.height*0.5,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:mainColor,
                        ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("QR Code",
                               style: TextStyle(fontSize: 16,color: Colors.white),
                              ),
                              Text("123654789512",
                               style: TextStyle(fontSize: 16,color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: size.width*0.25,
                            height: size.height*0.13,
                            padding: EdgeInsets.only(left: 10,top: 10,right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:seconColor,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("KG",style: TextStyle(color: Colors.white),),
                                    Container(
                                      width: size.width*0.13,
                                      height: size.height*0.04,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: fillColor,
                                      ),
                                       child: TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none
                                          )
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("G",style: TextStyle(color: Colors.white),),
                                    Container(
                                      width: size.width*0.13,
                                      height: size.height*0.04,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: fillColor,
                                      ),
                                       child: TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none
                                          )
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5,),
                          Container(
                            width: size.width*0.25,
                            height: size.height*0.25,
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: seconColor
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Width",style: TextStyle(color: Colors.white),),
                                      Container(
                                        width: size.width*0.13,
                                        height: size.height*0.04,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: fillColor,
                                        ),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none
                                            )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Length",style: TextStyle(color: Colors.white),),
                                      Container(
                                        width: size.width*0.13,
                                        height: size.height*0.04,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: fillColor,
                                        ),
                                         child: TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none
                                            )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Height",style: TextStyle(color: Colors.white),),
                                      Container(
                                        width: size.width*0.13,
                                        height: size.height*0.04,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: fillColor,
                                        ),
                                         child: TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none
                                            )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Cubit",style: TextStyle(color: Colors.white),),
                                      Container(
                                        width: size.width*0.13,
                                        height: size.height*0.04,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: fillColor,
                                        ),
                                         child: TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none
                                            )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      
                        ],
                      ),
                    );
    
    
 
  }

  Container container(Size size) {
    return Container(
                width: size.width*0.7,
                height: size.width*0.2,
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                //  margin: EdgeInsets.symmetric(horizontal: 20,),
               decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: seconColor
               ),
               child: SingleChildScrollView(
                 child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          activeColor: mainColor,
                          checkColor: Colors.white,
                          value: _isChecked,
                          onChanged: ( newValue) {
                          setState(() {
                          _isChecked = newValue!;
                           });
                         },
                        ),
                       Container(
                        width: size.width*0.3,
                        height: size.height*0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data"))
                      ],
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: mainColor,
                          checkColor: Colors.white,
                          value: _isChecked1,
                          onChanged: ( newValue) {
                          setState(() {
                          _isChecked1 = newValue!;
                           });
                         },
                        ),
                       Container(
                        width: size.width*0.3,
                        height: size.height*0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data1"))
                      ],
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Checkbox(
                          activeColor:mainColor,
                          checkColor: Colors.white,
                          value: _isChecked2,
                          onChanged: ( newValue) {
                          setState(() {
                          _isChecked2 = newValue!;
                           });
                         },
                        ),
                       Container(
                        width: size.width*0.3,
                        height: size.height*0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data2"))
                      ],
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: mainColor,
                          checkColor: Colors.white,
                          value: _isChecked3,
                          onChanged: ( newValue) {
                          setState(() {
                          _isChecked3 = newValue!;
                           });
                         },
                        ),
                       Container(
                        width: size.width*0.3,
                        height: size.height*0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data3"))
                      ],
                    ),
                  ],
                 ),
               ),
              );
  }
}