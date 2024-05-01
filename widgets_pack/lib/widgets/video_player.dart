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

  const VideoPlayer({
    required this.videoUrl,
    this.autoPlay = false,
    this.muted = false,
    this.showControls = true,
    this.customHeaders,
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
              aspectRatio: 16 / 9,
              child: VideoPlayer(
                videoUrl: videoUrl,
                autoPlay: autoPlay,
                muted: muted,
                showControls: showControls,
                customHeaders: customHeaders ?? context.wpWidgetsConfig.videoPlayerCustomHeaders ?? {},
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

    return PlayVideoFrom.network(_url);
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb && _isYouTube) {
      youtubeController = YoutubePlayerController.fromVideoId(
        videoId: YoutubePlayerController.convertUrlToId(_url) ?? '',
        autoPlay: widget.autoPlay,
        params: YoutubePlayerParams(
          mute: widget.muted,
          showControls: widget.showControls,
        ),
      );
    } else {
      videoController = PodPlayerController(
        playVideoFrom: _playVideoFrom,
        podPlayerConfig: PodPlayerConfig(
          autoPlay: widget.autoPlay,
        ),
      )..initialise();

      if (widget.muted) {
        videoController?.mute();
      }

      if (!widget.showControls) {
        videoController?.hideOverlay();
      }
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
      return Center(
        child: PodVideoPlayer(
          matchVideoAspectRatioToFrame: true,
          alwaysShowProgressBar: widget.showControls,
          overlayBuilder: widget.showControls
              ? null
              : (options) {
                  return Center(
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
                  );
                },
          controller: videoController!,
        ),
      );
    }

    if (youtubeController != null) {
      return YoutubePlayer(
        controller: youtubeController!,
      );
    }

    return const SizedBox();
  }
}
