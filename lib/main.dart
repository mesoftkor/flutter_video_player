import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
        useMaterial3: true,
      ),
      home: const VideoApp(title: 'Flutter Demo Home Page'),
    );
  }
}

class VideoApp extends StatefulWidget {
  const VideoApp({super.key, required this.title});
  final String title;

  @override
  State<VideoApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://vt.tumblr.com/tumblr_o600t8hzf51qcbnq0_480.mp4')) //샘플 영상 주소
      ..initialize().then((value) => {
            _controller.addListener(() {
              //custom Listner
              setState(() {
                if (!_controller.value.isPlaying &&
                    _controller.value.isInitialized &&
                    (_controller.value.duration ==
                        _controller.value.position)) {
                  //checking the duration and position every time
                  setState(() {});
                }
              });
            })
          });
    _controller.addListener(() {
      setState() {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller))
                : Container(),
            const SizedBox(
              height: 5,
            ),
            Positioned(
                child: Slider(
                    min: 0,
                    value: _controller.value.position.inSeconds.toDouble(),
                    max: _controller.value.duration.inSeconds.toDouble(),
                    onChanged: (double positionValue) {
                      _controller
                          .seekTo(Duration(seconds: positionValue.toInt()));
                    })),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 50,
              child: Center(
                child: Text(
                    '${_controller.value.position.toString().substring(0, 7)} / ${_controller.value.duration.toString().substring(0, 7)}',
                    style: TextStyle(color: Colors.white, fontSize: 30)),
              ),
            ),
            Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                IconButton(
                  icon: const Icon(Icons.rotate_left), // const는 Icon에만 적용
                  onPressed: () {
                    seekTo(_controller.value.position -
                        const Duration(milliseconds: 3000));
                  },
                ),
                IconButton(
                  icon: Icon(!_controller.value.isPlaying
                      ? Icons.play_arrow
                      : Icons.stop),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () {
                    seekTo(_controller.value.position +
                        const Duration(milliseconds: 3000));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> seekTo(Duration position) async {
    if (!_controller.value.isInitialized) {
      return;
    } else {
      if (position > _controller.value.duration) {
        position = _controller.value.duration;
      } else if (position < Duration.zero) {
        position = Duration.zero;
      }
    }

    await _controller.seekTo(position);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
