import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
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
  String data = '';
  String data1 = '';
  String data2 = '';
  String? portName;
  final List<String> allports = [];
  final List<String> alldata = [];

  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  bool _recording = false;
  bool _recordingTimed = false;
  bool _recordAudio = true;
  bool _previewPaused = false;
  Size? _previewSize;
  ResolutionPreset _resolutionPreset = ResolutionPreset.veryHigh;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  String getStringFromBytes(ByteData data) {
    final buffer = data.buffer;
    var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return utf8.decode(list);
  }

  void _getPortsAndOpen() {
    final List<PortInfo> portInfoLists = SerialPort.getPortsWithFullMessages();
    ports = SerialPort.getAvailablePorts();
    // log(portInfoLists.first.friendlyName.toString());

    ports.forEach((element) {
      allports.add(element.toString());
    });
  }

  void getData(String name) {
    // if (ports.isNotEmpty) {
    print(name);

    port = SerialPort(name,
        openNow: false, ReadIntervalTimeout: 1, ReadTotalTimeoutConstant: 2);
    // if (port.isOpened) {
    //   port.close();
    // }
    port.open();
    port.readBytesOnListen(16, (value) {
      // alldata.addAll([
      //   String.fromCharCode(int.parse(value.toString()) ?? 11),
      //   value.toString(),
      //   utf8.decode(value).toString()
      // ]);
      print(value.toString());
      print(utf8.decode(value).toString());
      setState(() {
        alldata.add("${value.toString()} ${utf8.decode(value).toString()}");
      });

      // print(String.fromCharCode(value));
      log(alldata.toString());
    });
    log(alldata.toString());
    // port.close();
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    port.close();
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
            _recording = false;
            _recordingTimed = false;
            _previewPaused = false;
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

  void _send() async {
    // print(sendData);
    // print(port.writeBytesFromString("AT"));
    // print(await port.readBytesUntil(Uint8List.fromList("\n".codeUnits)));
    log(port.writeBytesFromString("AT").toString());
    log(await port
        .readBytesUntil(Uint8List.fromList("\n".codeUnits))
        .toString());
    // var data = await port.readBytesOnce(10);
    // print(data);
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
      });
    }
  }

  Widget _buildPreview() {
    return CameraPlatform.instance.buildPreview(_cameraId);
  }

  Future<void> _takePicture() async {
    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    log('Picture captured to: ${file.path}');
    _showInSnackBar('Picture captured to: ${file.path}');
  }

  Future<void> _recordTimed(int seconds) async {
    if (_initialized && _cameraId > 0 && !_recordingTimed) {
      unawaited(CameraPlatform.instance
          .onVideoRecordedEvent(_cameraId)
          .first
          .then((VideoRecordedEvent event) async {
        if (mounted) {
          setState(() {
            _recordingTimed = false;
          });

          _showInSnackBar('Video captured to: ${event.file.path}');
        }
      }));

      await CameraPlatform.instance.startVideoRecording(
        _cameraId,
        maxVideoDuration: Duration(seconds: seconds),
      );

      if (mounted) {
        setState(() {
          _recordingTimed = true;
        });
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
          _recording = false;
          _recordingTimed = false;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _toggleRecord() async {
    if (_initialized && _cameraId > 0) {
      if (_recordingTimed) {
        /// Request to stop timed recording short.
        await CameraPlatform.instance.stopVideoRecording(_cameraId);
      } else {
        if (!_recording) {
          await CameraPlatform.instance.startVideoRecording(_cameraId);
        } else {
          final XFile file =
              await CameraPlatform.instance.stopVideoRecording(_cameraId);

          _showInSnackBar('Video captured to: ${file.path}');
        }

        if (mounted) {
          setState(() {
            _recording = !_recording;
          });
        }
      }
    }
  }

  Future<void> _togglePreview() async {
    if (_initialized && _cameraId >= 0) {
      if (!_previewPaused) {
        await CameraPlatform.instance.pausePreview(_cameraId);
      } else {
        await CameraPlatform.instance.resumePreview(_cameraId);
      }
      if (mounted) {
        setState(() {
          _previewPaused = !_previewPaused;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.isNotEmpty) {
      // select next index;
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      if (_initialized && _cameraId >= 0) {
        await _disposeCurrentCamera();
        await _fetchCameras();
        if (_cameras.isNotEmpty) {
          await _initializeCamera();
        }
      } else {
        await _fetchCameras();
      }
    }
  }

  Future<void> _onResolutionChange(ResolutionPreset newValue) async {
    setState(() {
      _resolutionPreset = newValue;
    });
    if (_initialized && _cameraId >= 0) {
      // Re-inits camera with new resolution preset.
      await _disposeCurrentCamera();
      await _initializeCamera();
    }
  }

  Future<void> _onAudioChange(bool recordAudio) async {
    setState(() {
      _recordAudio = recordAudio;
    });
    if (_initialized && _cameraId >= 0) {
      // Re-inits camera with new record audio setting.
      await _disposeCurrentCamera();
      await _initializeCamera();
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: ${event.description}')));

      // Dispose camera on camera error as it can not be used anymore.
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      _showInSnackBar('Camera is closing');
    }
  }

  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final List<DropdownMenuItem<ResolutionPreset>> resolutionItems =
        ResolutionPreset.values
            .map<DropdownMenuItem<ResolutionPreset>>((ResolutionPreset value) {
      return DropdownMenuItem<ResolutionPreset>(
        value: value,
        child: Text(value.toString()),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fillColor,
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            child: Text(_cameraInfo),
          ),
          if (_cameras.isEmpty)
            ElevatedButton(
              onPressed: _fetchCameras,
              child: const Text('Re-check available cameras'),
            ),
          if (_cameras.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton<ResolutionPreset>(
                  value: _resolutionPreset,
                  onChanged: (ResolutionPreset? value) {
                    if (value != null) {
                      _onResolutionChange(value);
                    }
                  },
                  items: resolutionItems,
                ),
                const SizedBox(width: 20),
                const Text('Audio:'),
                Switch(
                    value: _recordAudio,
                    onChanged: (bool state) => _onAudioChange(state)),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      _initialized ? _disposeCurrentCamera : _initializeCamera,
                  child:
                      Text(_initialized ? 'Dispose camera' : 'Create camera'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _initialized ? _takePicture : null,
                  child: const Text('Take picture'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _initialized ? _togglePreview : null,
                  child: Text(
                    _previewPaused ? 'Resume preview' : 'Pause preview',
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _initialized ? _toggleRecord : null,
                  child: Text(
                    (_recording || _recordingTimed)
                        ? 'Stop recording'
                        : 'Record Video',
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: (_initialized && !_recording && !_recordingTimed)
                      ? () => _recordTimed(5)
                      : null,
                  child: const Text(
                    'Record 5 seconds',
                  ),
                ),
                if (_cameras.length > 1) ...<Widget>[
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _switchCamera,
                    child: const Text(
                      'Switch camera',
                    ),
                  ),
                ]
              ],
            ),
          const SizedBox(height: 5),
          if (_initialized && _cameraId > 0 && _previewSize != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Align(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                  ),
                  child: AspectRatio(
                    aspectRatio: _previewSize!.width / _previewSize!.height,
                    child: _buildPreview(),
                  ),
                ),
              ),
            ),
          if (_previewSize != null)
            Center(
              child: Text(
                'Preview size: ${_previewSize!.width.toStringAsFixed(0)}x${_previewSize!.height.toStringAsFixed(0)}',
              ),
            ),
        ],
      ),
      // body: SafeArea(
      //     child: Row(
      //   children: [
      //     Column(
      //       children: [

      //         // cameracontainer(size),
      //         // SizedBox(
      //         //   height: 10,
      //         // ),
      //         // checkcontainer(size)
      //       ],
      //     ),
      //     Column(
      //       children: [buttoncontainer(size)],
      //     )
      //   ],
      // )),
    );
  }

  Container buttoncontainer(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      width: size.width * 0.19,
      height: size.height * 0.85,
      // color: Colors.indigo,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width * 0.185,
              height: size.width * 0.05,
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
                  height: size.width * 0.05,
                  padding: EdgeInsets.symmetric(horizontal: 5),
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
                      Text("Broker Return Item"),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
                Container(
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
                      Text("Re-Scan"),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
                      Text("Scan"),
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
                Container(
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
                  height: size.width * 0.05,
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
                  height: size.width * 0.05,
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
                      Text("Delete"),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: size.width * 0.09,
                  height: size.width * 0.05,
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
                  height: size.width * 0.05,
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

  Container checkcontainer(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: size.width * 0.75,
      height: size.height * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: size.width * 0.4,
            height: size.height * 0.5,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: seconColor),
            child: SingleChildScrollView(
              child: Column(
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
            ),
          ),
          SizedBox(
            width: 10,
          ),

          Container(
            width: size.width * 0.25,
            height: size.height * 0.5,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: mainColor,
            ),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    width: size.width * 0.24,
                    height: size.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: mainColor,
                    ),
                    child: alldata.length > 0
                        ? ListView.builder(
                            itemCount: alldata.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(alldata[index]),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "Data List",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
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
                          value: allport1,
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
                          items: allports.map(allserialports).toList(),
                          onChanged: (value) {
                            setState(() {
                              allport1 = value;
                              getData(value.toString());

                              // portName = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          // Container(
          //   width: size.width * 0.25,
          //   height: size.height * 0.5,
          //   padding: EdgeInsets.symmetric(horizontal: 10),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(20),
          //     color: mainColor,
          //   ),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "QR Code",
          //             style: TextStyle(fontSize: 16, color: Colors.white),
          //           ),
          //           Text(
          //             "123654789512",
          //             style: TextStyle(fontSize: 16, color: Colors.white),
          //           ),
          //         ],
          //       ),
          //       SizedBox(height: 10),
          //       Container(
          //         width: size.width * 0.25,
          //         height: size.height * 0.13,
          //         padding: EdgeInsets.only(left: 10, top: 10, right: 10),
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(10),
          //           color: seconColor,
          //         ),
          //         child: Column(
          //           children: [
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Text(
          //                   "KG",
          //                   style: TextStyle(color: Colors.white),
          //                 ),
          //                 Container(
          //                   width: size.width * 0.13,
          //                   height: size.height * 0.04,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(10),
          //                     color: fillColor,
          //                   ),
          //                   child: TextField(
          //                     controller: _kgController,
          //                     decoration: InputDecoration(
          //                         border: OutlineInputBorder(
          //                             borderSide: BorderSide.none)),
          //                   ),
          //                 )
          //               ],
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Text(
          //                   "G",
          //                   style: TextStyle(color: Colors.white),
          //                 ),
          //                 Container(
          //                   width: size.width * 0.13,
          //                   height: size.height * 0.04,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(10),
          //                     color: fillColor,
          //                   ),
          //                   child: TextField(
          //                     controller: _gController,
          //                     decoration: InputDecoration(
          //                         border: OutlineInputBorder(
          //                             borderSide: BorderSide.none)),
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //       SizedBox(
          //         height: 5,
          //       ),
          //       Container(
          //         width: size.width * 0.25,
          //         height: size.height * 0.25,
          //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //         decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(10),
          //             color: seconColor),
          //         child: SingleChildScrollView(
          //           child: Column(
          //             children: [
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text(
          //                     "Width",
          //                     style: TextStyle(color: Colors.white),
          //                   ),
          //                   Container(
          //                     width: size.width * 0.13,
          //                     height: size.height * 0.04,
          //                     decoration: BoxDecoration(
          //                       borderRadius: BorderRadius.circular(10),
          //                       color: fillColor,
          //                     ),
          //                     child: TextField(
          //                       controller: _widthController,
          //                       decoration: InputDecoration(
          //                           border: OutlineInputBorder(
          //                               borderSide: BorderSide.none)),
          //                     ),
          //                   )
          //                 ],
          //               ),
          //               SizedBox(
          //                 height: 10,
          //               ),
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text(
          //                     "Length",
          //                     style: TextStyle(color: Colors.white),
          //                   ),
          //                   Container(
          //                     width: size.width * 0.13,
          //                     height: size.height * 0.04,
          //                     decoration: BoxDecoration(
          //                       borderRadius: BorderRadius.circular(10),
          //                       color: fillColor,
          //                     ),
          //                     child: TextField(
          //                       controller: _lengthController,
          //                       decoration: InputDecoration(
          //                           border: OutlineInputBorder(
          //                               borderSide: BorderSide.none)),
          //                     ),
          //                   )
          //                 ],
          //               ),
          //               SizedBox(
          //                 height: 10,
          //               ),
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text(
          //                     "Height",
          //                     style: TextStyle(color: Colors.white),
          //                   ),
          //                   Container(
          //                     width: size.width * 0.13,
          //                     height: size.height * 0.04,
          //                     decoration: BoxDecoration(
          //                       borderRadius: BorderRadius.circular(10),
          //                       color: fillColor,
          //                     ),
          //                     child: TextField(
          //                       controller: _heightController,
          //                       decoration: InputDecoration(
          //                           border: OutlineInputBorder(
          //                               borderSide: BorderSide.none)),
          //                     ),
          //                   )
          //                 ],
          //               ),
          //               SizedBox(
          //                 height: 10,
          //               ),
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text(
          //                     "Cubit",
          //                     style: TextStyle(color: Colors.white),
          //                   ),
          //                   Container(
          //                     width: size.width * 0.13,
          //                     height: size.height * 0.04,
          //                     decoration: BoxDecoration(
          //                       borderRadius: BorderRadius.circular(10),
          //                       color: fillColor,
          //                     ),
          //                     child: TextField(
          //                       controller: _cubitController,
          //                       decoration: InputDecoration(
          //                           border: OutlineInputBorder(
          //                               borderSide: BorderSide.none)),
          //                     ),
          //                   )
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Container cameracontainer(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: size.width * 0.75,
      height: size.height * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                width: size.width * 0.24,
                height: size.height * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: mainColor,
                ),
                child: Center(
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
                      items: allports.map(allserialports).toList(),
                      onChanged: (value) => setState(() => allport = value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: size.width * 0.24,
                height: size.height * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: mainColor,
                ),
                child: Center(
                  child: Text(
                    "Selfie Camera",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
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
                      value: allport1,
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
                      items: allports.map(allserialports).toList(),
                      onChanged: (value) => setState(() => allport1 = value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: size.width * 0.24,
                height: size.height * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: mainColor,
                ),
                child: Center(
                  child: Text(
                    "Item Image",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
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
                      value: allport2,
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
                      items: allports.map(allserialports).toList(),
                      onChanged: (value) => setState(() => allport2 = value),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
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
