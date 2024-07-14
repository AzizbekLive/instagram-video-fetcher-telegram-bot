import 'dart:io';
import 'package:teledart/model.dart' as inline;
import 'package:teledart/teledart.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:teledart/telegram.dart';
import 'dart:convert';

void main() async {
  final BOT_TOKEN = 'YOUR TOKEN';
  final RAPIDAPI_KEY = 'YOUR KEY';
  final userMe = (await Telegram(BOT_TOKEN).getMe());
  final teledart = TeleDart(BOT_TOKEN, Event(userMe.username!));

  print('Bot is starting...');
  teledart.start();

  var kanal = inline.InlineKeyboardMarkup(
    inlineKeyboard: [
      [
        inline.InlineKeyboardButton(
            text: '✅ OBUNA BO\'LING', url: 'https://t.me/azizbeklive'),
      ],
      [
        inline.InlineKeyboardButton(
            text: '🔄 OBUNANI TEKSHIRISH', callbackData: 'check_subscription'),
      ],
    ],
  );

  teledart.onCommand('start').listen((message) async {
    var userId = message.chat.id;

    var obunachi = await teledart.getChatMember('@azizbeklive', userId);
    print("teledart = ${obunachi.status}");
    var isSubscribed = obunachi.status == 'member' ||
        obunachi.status == 'administrator' ||
        obunachi.status == 'creator';

    if (isSubscribed) {
      await teledart.sendMessage(
        message.chat.id,
        "VideoSaver live, bot test rejimida ishlamoqda.\n\nBotga link yuboring va videongizni oling!",
      );
    } else {
      await teledart.sendMessage(message.chat.id,
          "Botdan foydalanish uchun siz kanallarga obuna bo'lishingiz kerak!",
          replyMarkup: kanal);
    }
  });

  teledart.onCallbackQuery().listen((callbackQuery) async {
    if (callbackQuery.data == 'check_subscription') {
      var userId = callbackQuery.from.id;

      var obunachi = await teledart.getChatMember('@azizbeklive', userId);
      var isSubscribed = obunachi.status == 'member' ||
          obunachi.status == 'administrator' ||
          obunachi.status == 'creator';

      if (isSubscribed) {
        await teledart.sendMessage(callbackQuery.message!.chat.id,
            "VideoSaver live, bot test rejimida ishlamoqda.\n\nBotga link yuboring va videongizni oling!");
      } else {
        await teledart.sendMessage(callbackQuery.message!.chat.id,
            "Siz hali ham kanallarga obuna bo'lmagansiz. Iltimos, avval obuna bo'ling!",
            replyMarkup: kanal);
      }
    }
  });

  teledart.onUrl().listen((message) async {
    print('Received a message: ${message.text}');
    final instagramUrl = message.text!;
    final videoUrl = await getInstagramVideoUrl(instagramUrl, RAPIDAPI_KEY);

    if (videoUrl != null) {
      print('Video URL: $videoUrl'); // Debug print
      final videoFile = await downloadVideo(videoUrl);
      if (videoFile != null) {
        print('Video downloaded to: $videoFile'); // Debug print
        await teledart.sendDocument(message.chat.id, File(videoFile),
            caption: '$instagramUrl \n\n📥 @videosaverlivebot');
        await File(videoFile).delete();
      } else {
        await teledart.sendMessage(
            message.chat.id, 'Failed to download video.');
      }
    } else {
      await teledart.sendMessage(
          message.chat.id, 'Failed to retrieve video URL.');
    }
  });

  teledart.onMessage().listen((message) async {
    print('Received a message: ${message.text}');
    final instagramUrl = message.text!;
    final videoUrl = await getInstagramVideoUrl(instagramUrl, RAPIDAPI_KEY);

    if (videoUrl != null) {
      print('Video URL: $videoUrl'); // Debug print
      final videoFile = await downloadVideo(videoUrl);
      if (videoFile != null) {
        print('Video downloaded to: $videoFile'); // Debug print
        await teledart.sendDocument(message.chat.id, File(videoFile));
        await File(videoFile).delete();
      } else {
        await teledart.sendMessage(
            message.chat.id, 'Failed to download video.');
      }
    } else {
      await teledart.sendMessage(
          message.chat.id, 'Failed to retrieve video URL.');
    }
  });
}

Future<String?> getInstagramVideoUrl(String instagramUrl, String apiKey) async {
  final uri = Uri.parse(
      'https://instagram-downloader-download-photo-video-reels-igtv.p.rapidapi.com/data?url=$instagramUrl');

  final headers = {
    'x-rapidapi-host':
        'instagram-downloader-download-photo-video-reels-igtv.p.rapidapi.com',
    'x-rapidapi-key': apiKey,
  };

  try {
    print('Sending request to API...');
    final response = await http.get(uri, headers: headers);
    print('Request sent. Awaiting response...');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('API Response: ${data['data']['result']['video_url']}');
      return data['data']['result']['video_url'];
    } else {
      print('Failed to get video URL. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting Instagram video URL: $e');
  }
  return null;
}

Future<String?> downloadVideo(String videoUrl) async {
  try {
    print('Downloading video from URL: $videoUrl');
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode == 200) {
      final tempDir = Directory.systemTemp.createTempSync();
      final videoFile = File(path.join(tempDir.path, 'video.mp4'));
      await videoFile.writeAsBytes(response.bodyBytes);
      print('Video downloaded to: ${videoFile.path}');
      return videoFile.path;
    } else {
      print('Failed to download video. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error downloading video: $e');
  }
  return null;
}
