import 'package:chewie/chewie.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:widgets_pack/widgets_pack.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayer extends StatelessWidget {
  final String source;
  final bool autoPlay;
  final bool muted;
  final bool showControls;
  final WPVideoPlayerConfig? config;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const VideoPlayer({
    required this.source,
    this.autoPlay = false,
    this.muted = false,
    this.showControls = true,
    this.config,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String source,
    bool autoPlay = false,
    bool muted = false,
    bool showControls = true,
    WPVideoPlayerConfig? config,
    Color barrierColor = const Color(0xA604181F),
    double aspectRatio = 16 / 9,
  }) async {
    return showDialog(
      context: context,
      barrierColor: barrierColor,
      builder: (_) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: VideoPlayer(
                source: source,
                autoPlay: autoPlay,
                muted: muted,
                showControls: showControls,
                config: config ?? context.wpWidgetsConfig.videoPlayer,
                aspectRatio: aspectRatio,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isYouTube(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  Widget build(BuildContext context) {
    final videoConfig = config ?? context.wpWidgetsConfig.videoPlayer;

    if (_isYouTube(source)) {
      return _YoutubePlayer(
        key: ValueKey(source),
        videoUrl: source,
        autoPlay: autoPlay,
        muted: muted,
        showControls: showControls,
        aspectRatio: aspectRatio,
      );
    } else if (source.isUrl) {
      return _NetworkPlayer(
        key: ValueKey(source),
        videoUrl: source,
        autoPlay: autoPlay,
        muted: muted,
        showControls: showControls,
        aspectRatio: aspectRatio,
        headers: videoConfig?.headers,
      );
    } else {
      return _AssetPlayer(
        key: ValueKey(source),
        videoPath: source,
        autoPlay: autoPlay,
        muted: muted,
        showControls: showControls,
        aspectRatio: aspectRatio,
      );
    }
  }
}

class _YoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool muted;
  final bool showControls;
  final double aspectRatio;

  const _YoutubePlayer({
    required this.videoUrl,
    required this.autoPlay,
    required this.muted,
    required this.showControls,
    required this.aspectRatio,
    super.key,
  });

  @override
  State<_YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<_YoutubePlayer> {
  YoutubePlayerController? _controller;

  bool _hasError = false;
  bool _loading = true;

  static String? getYoutubeIdRegex(String url) {
    const pattern =
        r'(?:https?:\/\/)?(?:youtu\.be\/|(?:www\.)?youtube\.com\/(?:embed\/|v\/|shorts\/|watch\?v=|watch\?.+&v=))([\w-]{11})\S*';

    final regExp = RegExp(pattern, caseSensitive: false);

    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    debugPrint('Initializing YoutubePlayer with videoUrl: ${widget.videoUrl}');

    final videoId = getYoutubeIdRegex(widget.videoUrl);

    debugPrint('YoutubePlayer videoId: $videoId');

    if (videoId == null) {
      debugPrint('YoutubePlayer videoId is null');

      _loading = false;
      _hasError = true;
    } else {
      debugPrint('Initializing YoutubePlayerController with videoId: $videoId');

      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: widget.autoPlay,
        params: YoutubePlayerParams(
          showControls: widget.showControls,
          showVideoAnnotations: false,
          strictRelatedVideos: true,
          mute: widget.muted,
        ),
      );
      _loading = false;

      debugPrint('YoutubePlayerController initialized');

      _controller?.stream.firstWhere((data) {
        if (data.hasError) {
          debugPrint('YoutubePlayer stream error: ${data.error}');

          setState(() {
            _loading = false;
            _hasError = true;
          });
        }

        return data.hasError;
      });
    }
  }

  @override
  void dispose() {
    _controller?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _controller == null
          ? _loading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                  ? const Center(child: Text('Error loading video'))
                  : const SizedBox()
          : YoutubePlayer(
              controller: _controller!,
              aspectRatio: widget.aspectRatio,
              backgroundColor: Colors.black,
            ),
    );
  }
}

class _NetworkPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool muted;
  final bool showControls;
  final double aspectRatio;
  final Map<String, String>? headers;

  const _NetworkPlayer({
    required this.videoUrl,
    required this.autoPlay,
    required this.muted,
    required this.showControls,
    required this.aspectRatio,
    this.headers,
    super.key,
  });

  @override
  State<_NetworkPlayer> createState() => _NetworkPlayerState();
}

class _NetworkPlayerState extends State<_NetworkPlayer> {
  late VideoPlayerController _videoPlayerController;
  late bool muted = widget.muted;
  late bool paused = !widget.autoPlay;

  ChewieController? _chewieController;

  bool get _controllerInitialized {
    return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized;
  }

  @override
  void initState() {
    super.initState();

    initializePlayer().then(
      (_) => setAudio(mute: muted),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();

    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: {
        ...?widget.headers,
      },
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      allowFullScreen: widget.showControls,
      showControls: widget.showControls,
      showOptions: false,
      autoPlay: widget.autoPlay,
      looping: true,
      aspectRatio: widget.aspectRatio,
    );

    setState(() {});
  }

  void setAudio({required bool mute}) {
    _chewieController?.setVolume(mute ? 0 : 1);
    _videoPlayerController.setVolume(mute ? 0 : 1);
    setState(() => muted = mute);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: AppFocusDetector(
        onFocusGained: () {
          if (_controllerInitialized && widget.autoPlay) {
            _chewieController!.play();
          }
        },
        onFocusLost: () {
          if (_controllerInitialized && mounted) {
            _chewieController!.pause();
          }
        },
        child: _controllerInitialized
            ? Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _chewieController!.videoPlayerController.value.size.width,
                        height: _chewieController!.videoPlayerController.value.size.height,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.showControls
                              ? null
                              : () {
                                  _chewieController!.togglePause();
                                  setState(() => paused = !paused);
                                },
                          child: Chewie(
                            controller: _chewieController!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!widget.showControls)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          muted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.grey,
                        ),
                        onPressed: () => setAudio(mute: !muted),
                      ),
                    ),
                  if (!widget.showControls && paused)
                    Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey,
                          size: 48,
                        ),
                        onPressed: () {
                          _chewieController!.play();
                          setState(() => paused = false);
                        },
                      ),
                    ),
                ],
              )
            : const Center(child: AppCircularLoader()),
      ),
    );
  }
}

class _AssetPlayer extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool muted;
  final bool showControls;
  final double aspectRatio;

  const _AssetPlayer({
    required this.videoPath,
    required this.autoPlay,
    required this.muted,
    required this.showControls,
    required this.aspectRatio,
    super.key,
  });

  @override
  State<_AssetPlayer> createState() => _AssetPlayerState();
}

class _AssetPlayerState extends State<_AssetPlayer> {
  late VideoPlayerController _videoPlayerController;
  late bool muted = widget.muted;

  ChewieController? _chewieController;

  bool get _controllerInitialized {
    return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized;
  }

  @override
  void initState() {
    super.initState();

    initializePlayer().then(
      (_) => setAudio(mute: muted),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();

    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset(
      widget.videoPath,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      allowFullScreen: widget.showControls,
      showControls: widget.showControls,
      showOptions: false,
      autoPlay: widget.autoPlay,
      looping: true,
      aspectRatio: widget.aspectRatio,
    );

    setState(() {});
  }

  void setAudio({required bool mute}) {
    _chewieController?.setVolume(mute ? 0 : 1);
    _videoPlayerController.setVolume(mute ? 0 : 1);
    setState(() => muted = mute);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: AppFocusDetector(
        onFocusGained: () {
          if (_controllerInitialized && widget.autoPlay) {
            _chewieController!.play();
          }
        },
        onFocusLost: () {
          if (_controllerInitialized && mounted) {
            _chewieController!.pause();
          }
        },
        child: _controllerInitialized
            ? Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _chewieController!.videoPlayerController.value.size.width,
                        height: _chewieController!.videoPlayerController.value.size.height,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.showControls ? null : _chewieController!.togglePause,
                          child: Chewie(
                            controller: _chewieController!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!widget.showControls)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          muted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.grey,
                        ),
                        onPressed: () => setAudio(mute: !muted),
                      ),
                    ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
