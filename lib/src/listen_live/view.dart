import 'package:audio_service/audio_service.dart';
import 'package:ctwr_midtown_radio_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ListenLivePage extends StatelessWidget {
  const ListenLivePage({super.key});

  static const routeName = '/listen_live';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {

            final bool isPlayingLiveStream =
                audioPlayerHandler.mediaItem.value?.id == 'https://midtownradiokw.out.airtime.pro/midtownradiokw_a' &&
                audioPlayerHandler.isPlaying;

            final String buttonSemanticLabel = isPlayingLiveStream
                ? "Pause Live Radio"
                : "Play Live Radio";

            final IconData currentIcon =
                isPlayingLiveStream ? Icons.pause : Icons.play_arrow;
                
            return Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            
                            if (audioPlayerHandler.mediaItem.value?.id == 'https://midtownradiokw.out.airtime.pro/midtownradiokw_a') {
                              if (audioPlayerHandler.isPlaying) {
                                audioPlayerHandler.pause();
                              } else {
                                audioPlayerHandler.play();
                              }
                            } else {
                              // debugPrint("ran first time");
                              audioPlayerHandler.setMediaItem(
                                MediaItem(
                                  id: 'https://midtownradiokw.out.airtime.pro/midtownradiokw_a',
                                  title: "Midtown Radio KW",
                                  isLive: true
                                ),
                                playWhenReady: true
                              );
                              //audioPlayerHandler.play();
                            }
                            
                          }, 
                          style: ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(Size.fromRadius(100)),
                            padding: WidgetStatePropertyAll(EdgeInsets.all(10))),
                          child: Semantics(
                            label: buttonSemanticLabel,
                            button: true,
                            excludeSemantics: true,
                            child: Stack(alignment: AlignmentDirectional.center,children: [
                              Container(
                                width: 150, 
                                height: 150, 
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xff005c5f),Color(0xff00989d),Color(0xff33cccc)],
                                    begin: Alignment.bottomCenter,
                                    end:Alignment.topCenter,
                                    ),
                                    shape:BoxShape.circle,
                                    ),),
                              Icon(currentIcon,size: 100, color: Color.fromRGBO(217, 217, 216, 0.9),)
                              ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:20),
                          child: Image.asset('assets/images/we-play-local-music.png', width: 300,),
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ),

                  // offset so play button doesnt jitter when bottom player pops up
                  StreamBuilder<MediaItem?>(
                      stream: audioHandler.mediaItem,
                      builder: (context, mediaSnapshot) {
                        final mediaItem = mediaSnapshot.data;
                        return StreamBuilder<PlaybackState>(
                          stream: audioHandler.playbackState,
                          builder: (context, stateSnapshot) {
                            final playbackState = stateSnapshot.data;
                            final processingState = playbackState?.processingState ??
                                AudioProcessingState.idle;
              
                            final showPlayer = mediaItem != null &&
                                processingState != AudioProcessingState.idle;
                            // This is not an ideal solution, but it works okay.
                            if (showPlayer && audioPlayerHandler.mediaItem.value?.isLive == true){
                              return SizedBox(height: 36);
                            } else if (!showPlayer){
                              return SizedBox(height: 127);
                            }
                            return SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  
                ],
              ),
            );
          }
        ),
      ],
    ));
  }
}
