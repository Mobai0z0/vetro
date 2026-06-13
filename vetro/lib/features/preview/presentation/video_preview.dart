import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vetro/core/models/file_item.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key, required this.file});

  final FileItem file;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late final Player player;
  late final VideoController controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await player.open(Media.file(File(widget.file.path)));
    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Video(
            controller: controller,
            controls: MaterialVideoControls,
          ),
        ),
        _PlayerControls(player: player),
      ],
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.stream.duration,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0,
                  onChanged: (v) {
                    player.seek(Duration(
                      milliseconds: (v * duration.inMilliseconds).round(),
                    ));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position)),
                      Text(_formatDuration(duration)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
