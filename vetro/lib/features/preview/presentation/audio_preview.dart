import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vetro/core/models/file_item.dart';

class AudioPreview extends StatefulWidget {
  const AudioPreview({super.key, required this.file});

  final FileItem file;

  @override
  State<AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<AudioPreview> {
  late final AudioPlayer player;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await player.setFilePath(widget.file.path);

    player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });

    player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    player.playerStateStream.listen((state) {
      // Handle state changes if needed
    });

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

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album art placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.music_note,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),

          // File name
          Text(
            widget.file.displayName,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '.${widget.file.extension.toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Progress bar
          Slider(
            value: _duration.inMilliseconds > 0
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0,
            onChanged: (v) {
              player.seek(Duration(
                milliseconds: (v * _duration.inMilliseconds).round(),
              ));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: () {
                  player.seek(Duration(
                    milliseconds: (_position.inMilliseconds - 10000).clamp(
                      0,
                      _duration.inMilliseconds,
                    ),
                  ));
                },
              ),
              const SizedBox(width: 16),
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final playing = state?.playing ?? false;
                  return FilledButton(
                    onPressed: () {
                      if (playing) {
                        player.pause();
                      } else {
                        player.play();
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                    ),
                    child: Icon(playing ? Icons.pause : Icons.play_arrow, size: 36),
                  );
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_30),
                iconSize: 32,
                onPressed: () {
                  player.seek(Duration(
                    milliseconds: (_position.inMilliseconds + 30000).clamp(
                      0,
                      _duration.inMilliseconds,
                    ),
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
