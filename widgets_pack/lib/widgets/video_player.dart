import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:widgets_pack/widgets_pack.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool muted;
  final bool showControls;
  final Map<String, String>? customHeaders;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? placeholderBuilder;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const VideoPlayer({
    required this.videoUrl,
    this.autoPlay = false,
    this.muted = false,
    this.showControls = true,
    this.customHeaders,
    this.loadingBuilder,
    this.placeholderBuilder,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoUrl,
    bool autoPlay = false,
    bool muted = false,
    bool showControls = true,
    Map<String, String>? customHeaders,
    Color barrierColor = const Color(0xA604181F),
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? placeholderBuilder,
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
                videoUrl: videoUrl,
                autoPlay: autoPlay,
                muted: muted,
                showControls: showControls,
                customHeaders: customHeaders ?? context.wpWidgetsConfig.videoPlayerCustomHeaders ?? {},
                loadingBuilder: loadingBuilder,
                placeholderBuilder: placeholderBuilder,
                aspectRatio: aspectRatio,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  PodPlayerController? videoController;
  YoutubePlayerController? youtubeController;

  String get _url => widget.videoUrl;

  Map<String, String> get _customHeaders {
    return widget.customHeaders ?? context.wpWidgetsConfig.videoPlayerCustomHeaders ?? {};
  }

  String? get _vimeoVideoId {
    final regex = RegExp(
      r'(?:https?:\/\/)?(?:player\.)?vimeo\.com\/(?:progressive_redirect\/playback\/)?(\d+)(?:\/|\?|$)',
    );

    return regex.firstMatch(_url)?.group(1);
  }

  bool get _isYouTube {
    return _url.contains('youtube.com') || _url.contains('youtu.be');
  }

  PlayVideoFrom get _playVideoFrom {
    if (_isYouTube) {
      return PlayVideoFrom.youtube(_url);
    } else if (_url.contains('vimeo.com')) {
      final videoId = _vimeoVideoId;

      if (videoId != null) {
        if (_customHeaders.isNotEmpty) {
          return PlayVideoFrom.vimeoPrivateVideos(
            videoId,
            httpHeaders: _customHeaders,
          );
        } else {
          return PlayVideoFrom.vimeo(videoId);
        }
      }
    }

    if (_url.isUrl) {
      return PlayVideoFrom.network(_url);
    } else {
      return PlayVideoFrom.asset(_url);
    }
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb && _isYouTube) {
      youtubeController = YoutubePlayerController.fromVideoId(
        videoId: YoutubePlayerController.convertUrlToId(_url) ?? '',
        autoPlay: widget.autoPlay,
        params: YoutubePlayerParams(
          showControls: widget.showControls,
          mute: widget.muted,
        ),
      );
    } else {
      videoController = PodPlayerController(
        playVideoFrom: _playVideoFrom,
        podPlayerConfig: PodPlayerConfig(
          autoPlay: widget.autoPlay,
        ),
      )..initialise();
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    youtubeController?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoController != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: PodVideoPlayer(
          onLoading: widget.loadingBuilder,
          backgroundColor: Colors.transparent,
          frameAspectRatio: widget.aspectRatio,
          videoAspectRatio: widget.aspectRatio,
          matchVideoAspectRatioToFrame: true,
          alwaysShowProgressBar: widget.showControls,
          overlayBuilder: widget.showControls
              ? null
              : (options) {
                  return ClipRRect(
                    borderRadius: widget.borderRadius ?? BorderRadius.zero,
                    child: Stack(
                      children: [
                        if (!videoController!.isVideoPlaying && widget.placeholderBuilder != null)
                          widget.placeholderBuilder!(context),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (videoController!.currentVideoPosition == videoController!.totalVideoLength) {
                                await videoController!.videoSeekBackward(Duration.zero);
                                videoController!.pause();
                              }

                              videoController!.togglePlayPause();
                            },
                            child: videoController!.isVideoPlaying
                                ? null
                                : const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
          controller: videoController!,
        ),
      );
    }

    if (youtubeController != null) {
      return YoutubePlayer(
        controller: youtubeController!,
        aspectRatio: widget.aspectRatio,
      );
    }

    return const SizedBox();
  }
}
