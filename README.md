Vuforia SDK 4.0 Streaming Video Playback on Texture
===================

This is a modified version of the original Vuforia Video Playback sample, able to stream remote files and apply them to a texture. 

There is a tutorial that explains the modifications done here:
http://oramind.com/vuforia-sdk-remote-file-streaming-on-ios

----------

Before you download the source, please understand that there are many optimisations to be made to the example. Vuforia's example is constructed to support iOS 4, and as such, if you target iOS 6 and later, you can get it at least half of the code, you can convert the project to ARC (which is certainly advised), and you can also optimise the video playback to use hardware acceleration. I have implemented all of these functionalities to my released applications, however, it would be confusing writing a tutorial here that would cope with many problems at once.

