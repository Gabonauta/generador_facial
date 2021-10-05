import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:human_generator/Widgets/drawingarea.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DrawingArea> points = [];
  Widget imageOutput = Text("Image response");
  void saveToImage(List<DrawingArea> points) async {
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(200, 200)));
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint2);
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].point != Offset(0.0, 0.0) &&
          points[i + 1].point != Offset(0.0, 0.0)) {
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);

    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      final listBytes = Uint8List.view(pngBytes.buffer);
      //File file = await writeBytes(listBytes);
      String base64 = base64Encode(listBytes);
      fetchResponse(base64);
    }
  }

  void fetchResponse(var base64Image) async {
    Map<String, String> data = {'Image': base64Image};
    print('Starting request');
    var url = 'http://192.168.100.29:5000/predict';
    Map<String, String> headers = {
      'Content-type': 'application/json;charset=UTF-8',
      'Accept': 'application/json',
      'Connection': 'Keep-Alive',
    };
    var body = json.encode(data);

    try {
      var response =
          await http.post(Uri.parse(url), body: body, headers: headers);

      final Map<String, dynamic> responseData = json.decode(response.body);
      String outputBytes = responseData['Image'];
      print(outputBytes.substring(2, outputBytes.length - 1));
      displayResponseImage(outputBytes.substring(2, outputBytes.length - 1));
    } catch (e) {
      print(e);
    }
  }

  void displayResponseImage(String bytes) async {
    Uint8List convertedBytes = base64Decode(bytes);
    setState(() {
      imageOutput = Container(
        width: 256,
        height: 256,
        child: Image.memory(
          convertedBytes,
          fit: BoxFit.cover,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(138, 35, 135, 1),
                  Color.fromRGBO(255, 64, 87, 1),
                  Color.fromRGBO(242, 113, 33, 1),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1)
                      ],
                    ),
                    child: GestureDetector(
                      onPanDown: (details) {
                        this.setState(() {
                          points.add(
                            DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0),
                          );
                        });
                      },
                      onPanUpdate: (details) {
                        this.setState(() {
                          points.add(
                            DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0),
                          );
                        });
                      },
                      onPanEnd: (details) {
                        saveToImage(points);
                        this.setState(
                          () {
                            points.add(
                              DrawingArea(
                                point: Offset(0.0, 0.0),
                                areaPaint: Paint(),
                              ),
                            );
                          },
                        );
                      },
                      child: SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          child: CustomPaint(
                            painter: MyCustomPainter(points: points),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.layers_clear),
                          color: Colors.black,
                          onPressed: () {
                            this.setState(() {
                              points.clear();
                            });
                          })
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    child: Center(
                      child: Container(
                        width: 256,
                        height: 256,
                        child: imageOutput,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
