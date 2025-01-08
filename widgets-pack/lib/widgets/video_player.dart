import 'package:chewie/chewie.dart';
import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_player/video_player.dart';
import 'package:widgets_pack/widgets_pack.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayer extends StatelessWidget {
  final String source;
  final bool autoPlay;
  final bool muted;
  final WPVideoPlayerConfig? config;
  final double aspectRatio;

  const VideoPlayer({
    required this.source,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
    this.muted = false,
    this.config,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String source,
    bool autoPlay = false,
    bool muted = false,
    WPVideoPlayerConfig? config,
    Color barrierColor = const Color(0xA604181F),
    double aspectRatio = 16 / 9,
  }) async {
    return showDialog(
      context: context,
      barrierColor: barrierColor,
      builder: (_) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ),
              child: VideoPlayer(
                aspectRatio: aspectRatio,
                source: source,
                autoPlay: autoPlay,
                muted: muted,
                config: config ?? context.wpWidgetsConfig.videoPlayer,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isYouTube(String url) => url.contains('youtu');

  bool _isVimeo(String url) => url.contains('vimeo');

  @override
  Widget build(BuildContext context) {
    final videoConfig = config ?? context.wpWidgetsConfig.videoPlayer ?? const WPVideoPlayerConfig();

    if (_isYouTube(source)) {
      return _YoutubePlayer(
        key: ValueKey(source),
        videoUrl: source,
        autoPlay: autoPlay,
        muted: muted,
      );
    } else if (_isVimeo(source)) {
      final authIndicators = ['oauth2_token_id=', 'signature=', '/rendition/', 'progressive_redirect', 'file.mp4'];

      if (!authIndicators.any(source.contains)) {
        return _VimeoPlayer(
          key: ValueKey(source),
          videoUrl: source,
          autoPlay: autoPlay,
          muted: muted,
        );
      }
    }

    if (source.isUrl) {
      return _NetworkPlayer(
        key: ValueKey(source),
        videoUrl: source,
        autoPlay: autoPlay,
        muted: muted,
        headers: videoConfig.headers,
      );
    }

    return _AssetPlayer(
      key: ValueKey(source),
      aspectRatio: aspectRatio,
      videoPath: source,
      autoPlay: autoPlay,
      muted: muted,
    );
  }
}

class _YoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool muted;

  const _YoutubePlayer({
    required this.videoUrl,
    required this.autoPlay,
    required this.muted,
    super.key,
  });

  @override
  State<_YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<_YoutubePlayer> {
  late final YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();

    final videoId = getYoutubeIdRegex(widget.videoUrl);

    controller = YoutubePlayerController.fromVideoId(
      videoId: videoId!,
      autoPlay: widget.autoPlay,
      params: YoutubePlayerParams(
        loop: true,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
        mute: widget.muted,
      ),
    );
  }

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
  void dispose() {
    controller.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(
        controller: controller,
      ),
    );
  }
}

class _VimeoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool muted;

  const _VimeoPlayer({
    required this.videoUrl,
    required this.autoPlay,
    required this.muted,
    super.key,
  });

  @override
  State<_VimeoPlayer> createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<_VimeoPlayer> {
  late final (String, String?) videoData;

  bool isVideoLoading = !kIsWeb;

  @override
  void initState() {
    super.initState();

    final regex = RegExp(r'(?:vimeo\.com/|player\.vimeo\.com/video/)(\d+)(?:/([a-zA-Z0-9]+))?');
    final match = regex.firstMatch(widget.videoUrl);

    videoData = (match!.group(1)!, match.group(2));
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            initialData: InAppWebViewInitialData(
              data: _buildHtmlContent(),
              baseUrl: WebUri('https://player.vimeo.com'),
            ),
            onConsoleMessage: (controller, consoleMessage) {
              final message = consoleMessage.message;
              debugPrint('onConsoleMessage :: $message');
              if (message.startsWith('vimeo:')) {
                _manageVimeoPlayerEvent(message.substring(6));
              }
            },
            onLoadStart: (controller, url) {
              setState(() {
                isVideoLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                isVideoLoading = false;
              });
            },
          ),
          if (isVideoLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
                backgroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the HTML content for the vimeo player
  String _buildHtmlContent() {
    return '''
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            background-color: #000;
          }
          .video-container {
            position: relative;
            width: 100%;
            height: 100vh;
          }
          iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
          }
        </style>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <script src="https://player.vimeo.com/api/player.js"></script>
      </head>
      <body>
        <div class="video-container">
          <iframe 
            id="player"
            src="${_buildIframeUrl()}"
            frameborder="0"
            allow="autoplay; fullscreen; picture-in-picture"
            allowfullscreen 
            webkitallowfullscreen 
            mozallowfullscreen>
          </iframe>
        </div>
        <script>
          const player = new Vimeo.Player('player');
          player.ready().then(() => console.log('vimeo:onReady'));
          player.on('play', () => console.log('vimeo:onPlay'));
          player.on('pause', () => console.log('vimeo:onPause'));
          player.on('ended', () => console.log('vimeo:onFinish'));
          player.on('seeked', () => console.log('vimeo:onSeek'));
        </script>
      </body>
    </html>
    ''';
  }

  /// Builds the iframe URL
  String _buildIframeUrl() {
    final (id, hash) = videoData;

    return 'https://player.vimeo.com/video/$id?'
        '${hash != null ? 'h=$hash&' : ''}'
        'autoplay=${widget.autoPlay ? 1 : 0}'
        '&loop=1'
        '&muted=${widget.muted ? 1 : 0}'
        '&title=0'
        '&byline=0'
        '&controls=1'
        '&playsinline=1';
  }

  /// Manage vimeo player events received from the WebView
  void _manageVimeoPlayerEvent(String event) {
    debugPrint('Vimeo event: $event');
    switch (event) {
      case 'onReady':
        debugPrint('onReady');
      case 'onPlay':
        debugPrint('onPlay');
      case 'onPause':
        debugPrint('onPause');
      case 'onFinish':
        debugPrint('onFinish');
      case 'onSeek':
        debugPrint('onSeek');
    }
  }
}

class _NetworkPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool muted;
  final Map<String, String>? headers;

  const _NetworkPlayer({
    required this.videoUrl,
    required this.autoPlay,
    required this.muted,
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
      allowFullScreen: false,
      autoPlay: widget.autoPlay,
      looping: true,
      aspectRatio: 16 / 9,
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
            ? AspectRatio(
                aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                child: SizedBox(
                  width: _chewieController!.videoPlayerController.value.size.width,
                  height: _chewieController!.videoPlayerController.value.size.height,
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                ),
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
  final double aspectRatio;

  const _AssetPlayer({
    required this.videoPath,
    required this.autoPlay,
    required this.muted,
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
      allowFullScreen: false,
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
            ? SizedBox(
                width: _chewieController!.videoPlayerController.value.size.width,
                height: _chewieController!.videoPlayerController.value.size.height,
                child: Chewie(
                  controller: _chewieController!,
                ),
              )
            : const Center(child: AppCircularLoader()),
      ),
    );
  }
}
