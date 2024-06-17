import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:daftar_absenface/src/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'profile_screen.dart';
import 'timer_stream.dart';

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({super.key});
  static const routeName = 'home-screen';

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late CameraController controller;

  final double _screenWidth = 4;
  final double _screenHeight = 7.5;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    // Get screen dimensions on widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // _screenWidth = MediaQuery.of(context).size.width;
        // _screenHeight = MediaQuery.of(context).size.height;
      });
    });
    _preloadSound();
  }

  Future<void> _preloadSound() async {
    //await _audioPlayer.setSource(AssetSource('camera_shutter.wav'));
  }

  @override
  Widget build(BuildContext context) {
    final xFileState = ref.watch(xFileProvider);
    final timerStream = TimerStream(duration: _secondsRemaining);
    double fullRatio = _screenWidth / _screenHeight;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: Image.file(File(xFileState.path)).image,
            ),
            const SizedBox(
              width: 10.0,
            ),
            const Text('Home'),
          ],
        ),
      ),
      body: FutureBuilder(
        future: initializationCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: fullRatio,
                  child: CameraPreview(controller),
                ),
                AspectRatio(
                  aspectRatio: fullRatio,
                  child: Image.asset(
                    'assets/images/xx.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 120.0),
                  child: StreamBuilder<int>(
                    stream: timerStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return const Text('Timer not started');
                      }

                      final remainingSeconds = snapshot.data!;
                      if (remainingSeconds <= 0) {
                        onTakePicture();
                      }
                      return Text(
                        '$remainingSeconds',
                        style: const TextStyle(
                          fontSize: 45.0,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () => onTakePicture(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> initializationCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(
      cameras[EnumCameraDescription.back.index],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
  }

  void onTakePicture() async {
    /*setState(() {
      _secondsRemaining = 10;
    });*/
    await controller.takePicture().then((XFile xfile) {
      if (mounted) {
        ref.read(xFileProvider.notifier).state = xfile;
        context.pushNamed(ProfileScreen.routeName);
      }
      return;
    });
  }
}

enum EnumCameraDescription { front, back }
