import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bam_bam_vendor/app/utils/asset_constants.dart';
import 'package:vibration/vibration.dart';
import 'package:bam_bam_vendor/domain/repositories/local_storage_keys.dart';
import 'package:bam_bam_vendor/domain/repositories/repository.dart';
import 'package:get/get.dart';

class AudioService {
  static AudioPlayer? _audioPlayer;
  static final RxBool isPlaying = false.obs;
  static final RxString playingUrl = "".obs;
  static Timer? _ringtoneTimer;

  static Future<void> playRingtone({String? url}) async {
    try {
      // 1. Get user preferences from Repository
      String? savedUrl = url;
      bool isEnabled = true;

      if (Get.isRegistered<Repository>()) {
        final repo = Get.find<Repository>();
        isEnabled = repo.getStringValue(LocalKeys.ringtoneEnabled) != 'false';
        if (savedUrl == null || savedUrl.isEmpty) {
          savedUrl = repo.getStringValue(LocalKeys.selectedRingtoneUrl);
        }
      }

      if (!isEnabled) {
        print("AudioService: Ringtone is disabled by user");
        return;
      }

      // Treat "default" as null so we fall through to asset
      final effectiveUrl = (savedUrl == null || savedUrl.isEmpty || savedUrl == "default") ? null : savedUrl;
      final targetPlayingUrl = effectiveUrl ?? "default";

      // If already playing the requested ringtone and the player is active, do nothing
      if (_audioPlayer != null && isPlaying.value && _audioPlayer!.state == PlayerState.playing && playingUrl.value == targetPlayingUrl) {
        print("AudioService: Already playing requested ringtone: $targetPlayingUrl");
        return;
      }

      // Clean up previous player and vibration before playing a new one
      await stopRingtone();

      isPlaying.value = true;
      playingUrl.value = targetPlayingUrl;

      print("AudioService: Attempting to play ringtone (Source: $targetPlayingUrl) and vibration...");

      // 2. Vibration
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 1000],
          repeat: 0,
        );
      }

      // Create a fresh player instance to prevent native state corruption
      final player = AudioPlayer();
      _audioPlayer = player;

      // 3. Audio Context — critical for iOS to play audio in silent mode (wrapped in try-catch to never block playback)
      try {
        await player.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.notificationRingtone,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ));
      } catch (contextError) {
        print("AudioService: ⚠️ Failed to set AudioContext (proceeding with default): $contextError");
      }

      // 4. Ringtone Source
      Source source;

      // Auto-prepend base URL if it's a relative path
      String? playUrl = effectiveUrl;
      if (playUrl != null && !playUrl.startsWith('http') && playUrl.contains('/uploads/')) {
        playUrl = "https://apis.bambamcabs.com${playUrl.startsWith('/') ? '' : '/'}$playUrl";
      }

      if (playUrl != null && playUrl.startsWith('http')) {
        print("AudioService: Playing custom ringtone from URL: $playUrl");
        source = UrlSource(playUrl);
      } else {
        print("AudioService: Playing default asset ringtone (alarm_clock.mp3)");
        // AssetSource needs path WITHOUT 'assets/' prefix
        final assetPath = AssetConstants.ringtone.replaceFirst('assets/', '');
        source = AssetSource(assetPath);
      }

      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(1.0); // Ensure player volume is at maximum
      await player.play(source);
      print("AudioService: ✅ Ringtone started playing successfully");

      // 5. Auto-stop after 15 seconds
      _ringtoneTimer?.cancel();
      _ringtoneTimer = Timer(const Duration(seconds: 15), () {
        stopRingtone();
      });

    } catch (e, stack) {
      isPlaying.value = false;
      playingUrl.value = "";
      print("AudioService: ❌ Error playing ringtone: $e");
      print("AudioService: Stack trace: $stack");
      await stopRingtone();
    }
  }

  static Future<void> stopRingtone() async {
    try {
      print("AudioService: Stopping ringtone and vibration");
      isPlaying.value = false;
      playingUrl.value = "";
      _ringtoneTimer?.cancel();
      Vibration.cancel();
      
      if (_audioPlayer != null) {
        final playerToDispose = _audioPlayer!;
        _audioPlayer = null; // unset reference immediately
        await playerToDispose.stop();
        await playerToDispose.dispose();
      }
    } catch (e) {
      print("AudioService: Error stopping ringtone: $e");
    }
  }
}
