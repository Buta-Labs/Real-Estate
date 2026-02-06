import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class ProjectVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;

  const ProjectVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  @override
  State<ProjectVideoPlayer> createState() => _ProjectVideoPlayerState();
}

class _ProjectVideoPlayerState extends State<ProjectVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.isNotEmpty) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl.isEmpty || _hasError) {
      return _buildThumbnail();
    }

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        if (!_controller.value.isPlaying) _buildPlayButton(),
      ],
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.thumbnailUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: 200,
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
            ),
          ),
        ),
        if (widget.videoUrl.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              size: 48,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.thumbnailUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const CircularProgressIndicator(color: AppColors.primary),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
