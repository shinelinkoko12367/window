import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:webproject/HomePage/listPage.dart';
import 'package:webproject/constant/constant.dart';

import 'package:camera_platform_interface/camera_platform_interface.dart';

class StockIn extends StatefulWidget {
  const StockIn({super.key});

  @override
  State<StockIn> createState() => _StockInState();
}

class _StockInState extends State<StockIn> {
  bool _isChecked = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  TextEditingController _kgController = TextEditingController(),
      _gController = TextEditingController(),
      _widthController = TextEditingController(),
      _lengthController = TextEditingController(),
      _heightController = TextEditingController(),
      _cubitController = TextEditingController();

  var ports = <String>[];
  late SerialPort port;

  final sendData = Uint8List.fromList(List.filled(4, 1, growable: false));

  String? allport;
  String? allport1;
  String? allport2;
  final List<String> allports = [];

  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  List<String> _camerasList = ["Select Camera"];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  bool _recordAudio = false;
  Size? _previewSize;
  ResolutionPreset _resolutionPreset = ResolutionPreset.veryHigh;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  int _cameraIndex2 = 0;
  int _cameraId2 = -1;
  bool _initialized2 = false;
  Size? _previewSize2;

  String getStringFromBytes(ByteData data) {
    final buffer = data.buffer;
    var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return utf8.decode(list);
  }

  void _getPortsAndOpen() {
    final List<PortInfo> portInfoLists = SerialPort.getPortsWithFullMessages();
    ports = SerialPort.getAvailablePorts();

    // print(portInfoLists);
    allports.clear();
    ports.forEach((element) {
      allports.add(element);
    });
    print(allports);

    setState(() {});
  }

  List<String> getdatalist = [];
  void getData(String post) async {
    final port = SerialPort(post,
        openNow: false, ReadIntervalTimeout: 1, ReadTotalTimeoutConstant: 2);
    try {
      port.open();
      port.readBytesOnListen(16, (Uint8List value) {
        log(value.toString());
        setState(() {
          getdatalist.add("data 1 : $value");
        });
      });
      log(getdatalist.toString());
    } catch (e) {
      print("Error: $e");
    } finally {
      // port.close();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    _fetchCameras();
    _getPortsAndOpen();
  }

  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = _cameraIndex % cameras.length;
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
        _cameraInfo = cameraInfo;
        // _initialized=true;
        _camerasList.addAll(_cameras.map((e) => e.name).toList());
      });
      // _initializeCamera();
    }
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    super.dispose();
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _initialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _initialized = false;
            _cameraId = -1;
            _previewSize = null;
            _cameraInfo = 'Camera disposed';
          });
        }
      } on CameraException catch (e) {
        if (mounted) {
          setState(() {
            _cameraInfo =
                'Failed to dispose camera: ${e.code}: ${e.description}';
          });
        }
      }
    }
  }

  Future<void> _initializeCamera() async {
    assert(!_initialized);

    if (_cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        _resolutionPreset,
        enableAudio: _recordAudio,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );

      if (mounted) {
        setState(() {
          _initialized = true;
          _cameraId = cameraId;
          _cameraIndex = cameraIndex;
          _cameraInfo = 'Capturing camera: ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _previewSize = null;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _initializeCamera2() async {
    assert(!_initialized2);

    if (_cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex2 % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        _resolutionPreset,
        enableAudio: _recordAudio,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      _previewSize2 = Size(
        event.previewWidth,
        event.previewHeight,
      );

      if (mounted) {
        setState(() {
          _initialized2 = true;
          _cameraId2 = cameraId;
          _cameraIndex2 = cameraIndex;
          _cameraInfo = 'Capturing camera: ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized2 = false;
          _cameraId2 = -1;
          _cameraIndex2 = 0;
          _previewSize2 = null;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      // _showInSnackBar('Camera is closing');
    }
  }

  Widget _buildPreview() {
    return CameraPlatform.instance.buildPreview(_cameraId);
  }

  String? _capturedImagePath;
  Future<void> _takePicture() async {
    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    setState(() {
      _capturedImagePath = file.path;
    });
  }

  Future<void> _removePicture() async {
    setState(() {
      _capturedImagePath = null;
    });
  }

  Widget _buildPreview2() {
    return CameraPlatform.instance.buildPreview(_cameraId2);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: Row(
        children: [
          Column(
            children: [maincamrea(size), container(size)],
          ),
          Column(
            children: [buttoncontainer(size)],
          ),
        ],
      )),
    );
  }

  Container maincamrea(Size size) {
    return Container(
      width: size.width * 0.70,
      height: size.height * 0.5,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                width: size.width * 0.25,
                height: size.height * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: mainColor,
                ),
                child: _initialized && _cameraId > 0 && _previewSize != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Align(
                            child: Container(
                          constraints: BoxConstraints(
                              // maxHeight: size.height*0.5,
                              // minHeight: size.height*0.5,
                              ),
                          child: AspectRatio(
                            // aspectRatio: _previewSize!.width / _previewSize!.height,
                            aspectRatio: 4 / 3,
                            child: _buildPreview(),
                          ),
                        )))
                    : Center(
                        child: Text(
                          "Main Camera",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
              ),
              Positioned(
                top: size.height * 0,
                right: size.width * 0,
                child: Container(
                  height: 30,
                  width: 150,
                  decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(20))),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _camerasList[0],
                      isExpanded: true,
                      hint: Text(
                        'Choose Port',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500),
                      ),
                      elevation: 0,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black54,
                      ),
                      dropdownColor: Colors.white,
                      items: _camerasList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        int ind = _camerasList.indexOf(value ?? "");
                        if (ind > 0) {
                          setState(() {
                            _cameraIndex = ind - 1;
                          });
                          _initializeCamera();
                        }

                        print(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 5),
          Container(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.18,
                      height: size.height * 0.245,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: mainColor,
                      ),
                      child: _initialized2 &&
                              _cameraId2 > 0 &&
                              _previewSize2 != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Align(
                                  child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: size.height * 0.5,
                                  minHeight: size.height * 0.5,
                                ),
                                child: AspectRatio(
                                  aspectRatio: _previewSize2!.width /
                                      _previewSize2!.height,
                                  // aspectRatio: 4/3,
                                  child: _buildPreview2(),
                                ),
                              )))
                          : Center(
                              child: Text(
                              "Selfie Camera",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            )),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        width: 150,
                        decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20))),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _camerasList.first,
                            isExpanded: true,
                            hint: Text(
                              'Choose Port',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade500),
                            ),
                            elevation: 0,
                            iconSize: 25,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                            dropdownColor: Colors.white,
                            items: _camerasList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              int ind = _camerasList.indexOf(value ?? "");
                              if (ind > 0) {
                                setState(() {
                                  _cameraIndex2 = ind - 1;
                                });
                                _initializeCamera2();
                              }

                              print(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Stack(
                  children: [
                    Container(
                        width: size.width * 0.18,
                        height: size.height * 0.245,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: mainColor,
                        ),
                        child: _capturedImagePath != null
                            ? Image.file(
                                File(_capturedImagePath!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                child: Center(
                                  child: Text(
                                    "Item Image",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              )
                        // child:Image.file(File(_capturedImagePath!)),
                        //  Center(child: Text("Item Image",
                        // style: TextStyle(fontSize: 16,color: Colors.white),
                        // )),
                        ),
                  ],
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
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: size.width * 0.19,
      height: size.height * 0.85,
      // color: Colors.indigo,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width * 0.185,
              height: size.height * 0.085,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: fillColor,
              ),
              child: Center(
                child: Text(
                  "Info",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
                  padding: EdgeInsets.symmetric(horizontal: 5),
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
                      Text("Broker Return Item"),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
                      Text("New Item"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    _removePicture();
                  },
                  child: Container(
                    width: size.width * 0.09,
                    height: size.height * 0.085,
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
                ),
                InkWell(
                  onTap: _initialized ? _takePicture : null,
                  child: Container(
                    width: size.width * 0.09,
                    height: size.height * 0.085,
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
                        Text("Scan"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
                      Text("Re-Print"),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
                      Text("Delete"),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ListPage(
                    //         // _kgController.text,
                    //         // _gController.text,
                    //         // _widthController.text,
                    //         // _lengthController.text,
                    //         // _heightController.text,
                    //         // _cubitController.text,

                    //         // imageUrl: _capturedImagePath ?? 'default_image_path.png', // Use a default value
                    //         //  text: 'Here is some text to display on the next page.',
                    //         ),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: size.width * 0.09,
                    height: size.height * 0.085,
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
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
                  width: size.width * 0.09,
                  height: size.height * 0.085,
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
      child: Stack(
        children: [
          Container(
            width: size.width * 0.25,
            height: size.height * 0.5,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: mainColor,
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "QR Code",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        "123654789512",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: size.width * 0.25,
                  height: size.height * 0.13,
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: seconColor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "KG",
                            style: TextStyle(color: Colors.white),
                          ),
                          Container(
                            width: size.width * 0.13,
                            height: size.height * 0.04,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: fillColor,
                            ),
                            child: TextField(
                              controller: _kgController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none)),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "G",
                            style: TextStyle(color: Colors.white),
                          ),
                          Container(
                            width: size.width * 0.13,
                            height: size.height * 0.04,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: fillColor,
                            ),
                            child: TextField(
                              controller: _gController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: size.width * 0.25,
                  height: size.height * 0.25,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: seconColor),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Width",
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              width: size.width * 0.13,
                              height: size.height * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: fillColor,
                              ),
                              child: TextField(
                                controller: _widthController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Length",
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              width: size.width * 0.13,
                              height: size.height * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: fillColor,
                              ),
                              child: TextField(
                                controller: _lengthController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Height",
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              width: size.width * 0.13,
                              height: size.height * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: fillColor,
                              ),
                              child: TextField(
                                controller: _heightController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Cubit",
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              width: size.width * 0.13,
                              height: size.height * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: fillColor,
                              ),
                              child: TextField(
                                controller: _cubitController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
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
          ),
          Positioned(
            top: size.height * 0,
            right: size.width * 0,
            child: Container(
              height: 30,
              width: 120,
              decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(20))),
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: allport,
                  isExpanded: true,
                  hint: Text(
                    'Choose Port',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  elevation: 0,
                  iconSize: 25,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black54,
                  ),
                  dropdownColor: Colors.white,
                  items: allports.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      allport = value;
                    });
                    getData(value.toString());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container container(Size size) {
    return Container(
      width: size.width * 0.7,
      height: size.width * 0.2,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: seconColor),
      child: SingleChildScrollView(
        child: Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      activeColor: mainColor,
                      checkColor: Colors.white,
                      value: _isChecked,
                      onChanged: (newValue) {
                        setState(() {
                          _isChecked = newValue!;
                        });
                      },
                    ),
                    Container(
                        width: size.width * 0.3,
                        height: size.height * 0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data")),
                  ],
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Checkbox(
                      activeColor: mainColor,
                      checkColor: Colors.white,
                      value: _isChecked1,
                      onChanged: (newValue) {
                        setState(() {
                          _isChecked1 = newValue!;
                        });
                      },
                    ),
                    Container(
                        width: size.width * 0.3,
                        height: size.height * 0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data1"))
                  ],
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Checkbox(
                      activeColor: mainColor,
                      checkColor: Colors.white,
                      value: _isChecked2,
                      onChanged: (newValue) {
                        setState(() {
                          _isChecked2 = newValue!;
                        });
                      },
                    ),
                    Container(
                        width: size.width * 0.3,
                        height: size.height * 0.03,
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
                      onChanged: (newValue) {
                        setState(() {
                          _isChecked3 = newValue!;
                        });
                      },
                    ),
                    Container(
                        width: size.width * 0.3,
                        height: size.height * 0.03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                        child: Text("Data3"))
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              width: 300,
              height: 500,
              child: ListView.builder(
                itemCount: getdatalist.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(getdatalist[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> allserialports(String allport) => DropdownMenuItem(
        value: allport,
        child: Text(
          allport,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      );
}
