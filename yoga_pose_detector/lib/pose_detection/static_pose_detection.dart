import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Pose detection App - Raadco'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image; // The selected image from gallery or camera.
  late ImagePicker imagePicker; // Used to pick/capture images.
  late PoseDetector poseDetector; // ML Kit's object to detect poses.
  dynamic image; // Holds the decoded image (to draw on canvas).
  List<Pose> poses = []; // List of detected poses (Usually just one per image).

  @override
  void initState() {
    super.initState();

    imagePicker = ImagePicker(); // Initialize the image picker

    final options = PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.single, // Pose detector in single image mode.
    );
    poseDetector = PoseDetector(options: options); // Initialize the pose detector with accurate model in single image mode.
  }

  _chooseImage() async {
    // Pick image from gallery
    XFile? selectedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage != null) {
      _image = File(selectedImage.path); // Convert to File
      _doPoseDetection();
    }
  }

  _captureImage() async {
    XFile? selectedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (selectedImage != null) {
      _image = File(selectedImage.path);
      _doPoseDetection();
    }
  }

  _doPoseDetection() async {
    _drawPose();
    InputImage inputImage = InputImage.fromFile(_image!); // Converts the image into an `InputImage` format

    poses = await poseDetector.processImage(inputImage); // Runs pose detection using ML Kit.
    setState(() {
      poses;
    });

    setState(() {
      _image;
    });
  }

  _drawPose() async {
    var bytes = await _image!.readAsBytes();
    image = await decodeImageFromList(bytes); // Decodes the image file into a format that can be draw using Canvas.
    setState(() {
      image;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Displaying Image
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: Center(
                  child:
                      _image == null
                          ? Icon(Icons.image_outlined)
                          : FittedBox(
                            child: SizedBox(
                              width: image.width.toDouble(),
                              height: image.height.toDouble(),
                              child: CustomPaint(
                                painter: PosePainter(image, poses),
                              ),
                            ),
                          ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Button for choose image from device
            ElevatedButton(
              onPressed: () => _chooseImage(),
              onLongPress: () => _captureImage(),
              child: Text('Choose / Capture'),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PosePainter extends CustomPainter {
  dynamic image;
  List<Pose> poses;

  PosePainter(this.image, this.poses);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint()); // Draw the original image.

    Paint paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;

    Paint leftPaint = Paint();
    leftPaint.color = Colors.white;
    leftPaint.style = PaintingStyle.stroke;
    leftPaint.strokeWidth = 6;

    Paint rightPaint = Paint();
    rightPaint.color = Colors.white;
    rightPaint.style = PaintingStyle.stroke;
    rightPaint.strokeWidth = 6;

    for (Pose pose in poses) {
      // to access all landmarks
      pose.landmarks.forEach((_, landmark) {
        // final type = landmark.type;
        // final x = landmark.x;
        // final y = landmark.y;

        canvas.drawCircle(Offset(landmark.x, landmark.y), 3, paint); // Draws each landmark as a small circle.
      });

      /*
      * -- Draws lines between key landmark pairs like:
      * -- Right & left arm
      * -- Shoulders to hips
      * -- Hips to knees to ankles
      * -- Connects body points for a skeleton-like visualisation
      * -- Paints are separated into leftPaint, rightPaint, and paint to allow styling differentiation.
      */
      void drawCustomLine(
        PoseLandmarkType point1,
        PoseLandmarkType point2,
        Paint linePaint,
      ) {
        PoseLandmark poseLandMark1 = pose.landmarks[point1]!;
        PoseLandmark poseLandMark2 = pose.landmarks[point2]!;

        canvas.drawLine(
          Offset(poseLandMark1.x, poseLandMark1.y),
          Offset(poseLandMark2.x, poseLandMark2.y),
          linePaint,
        );
      }

      // Drawing arms - Right side
      drawCustomLine(
        PoseLandmarkType.rightWrist,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightWrist,
        PoseLandmarkType.rightShoulder,
        rightPaint,
      );

      // Drawing arms - Left side
      drawCustomLine(
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftShoulder,
        leftPaint,
      );

      // Drawing body
      drawCustomLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        leftPaint,
      );

      drawCustomLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.leftHip,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftShoulder,
        leftPaint,
      );

      // Drawing legs
      drawCustomLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );

      drawCustomLine(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
