import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences? sp;
// const int kSmMovieItemWidth;
// const int kSmMovieItemHeight;

const Color kDeskBackgroundColor = Color.fromARGB(255, 20, 20, 20);

const double kLgScreenWidth = 750; // > 750
const double kMdLgScreenWidth = 900; // 750 < 900
const double kXLgScreenWidth = 1100; // > 900
const double kFullScreenBillBoard = 600;

const double kDLgMovieItemHeight = 164; //265 x 149
const double kDLgMovieItemWidth = 291.92;

const double kDMdMovieItemHeight = 120;
const double kDMdMovieItemWidth = 213; // 189 x 106.5

const double kDSmMovieItemHeight = 103;
const double kDSmMovieItemWidth = 183.34;

const double kMbMovieItemHeight = 170;
const double kMbMovieItemWidth = 120;

const apiUrl = "https://net50.cc";
const newApiUrl = "https://netfree2.cc";
const addUrl = "https://net50.cc";
final audioM3u8Exp = RegExp(
  r'https://(?<prefix>[\w\.-]+)\.top/files/(?<id>[\w]+)/a/(?<index>\d+)/\d+\.m3u8',
);

const key =
    "59a05b117809dbe6e0879acb3cac14c3::cb742acc402bbeeeaffbbb5ce48cb86e::1734859034::ni";
const headers = {
  'Origin': apiUrl,
  'Referer': '$apiUrl/',
  'Sec-Fetch-Mode': 'cors',
  'User-Agent':
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
  'Accept': '*/*',
  'cookie': 'hd=on',
  // TRADOTTO: Richiede contenuti in Italiano ai server NetMirror
  'Accept-Language': 'it-IT,it;q=0.9,en;q=0.8', 
};

final headers2 = [
  'Origin: $apiUrl',
  'Referer: $apiUrl/',
  'Sec-Fetch-Mode: cors',
  'Accept: */*',
  // TRADOTTO: Configurato per dare priorità alla lingua italiana
  'Accept-Language: it-IT,it;q=0.9,en;q=0.8',
];

final bool isDesk = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
const Dot = "•";
int parseIdFromUrl(String url) {
  final match = RegExp(r'\d+').firstMatch(url);

  if (match != null) {
    return int.parse(match.group(0)!);
  } else {
    return 1;
  }
}

extension ColorExtensions on Color {
  Color inc(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return lighten(amount);
    }
    return darken(amount);
  }

  Color revInc(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return lighten(amount);
    }
    return lighten(amount);
  }

  Color dec(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return darken(amount);
    }
    return lighten(amount);
  }

  Color revDec(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return darken(amount);
    }
    return darken(amount);
  }

  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }
}
