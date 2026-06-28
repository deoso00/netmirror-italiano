import 'dart:async';  
import 'dart:developer';  
import 'dart:io'; 

import 'package:android\_intent\_plus/android\_intent.dart';  
import 'package:android\_intent\_plus/flag.dart';  
import 'package:collection/collection.dart';  
import 'package:file\_picker/file\_picker.dart';  
import 'package:flutter/material.dart';  
import 'package:flutter/services.dart';  
import 'package:go\_router/go\_router.dart';  
import 'package:netmirror/constants.dart';  
import 'package:netmirror/db/db.dart';  
import 'package:netmirror/downloader/downloader.dart';  
import 'package:netmirror/downloader/download\_db.dart';  
import 'package:netmirror/log.dart';  
import 'package:netmirror/screens/external\_plyer.dart';  
import 'package:netmirror/widgets/windows\_titlebar\_widgets.dart';  
import 'package:path\_provider/path\_provider.dart';  
import 'package:permission\_handler/permission\_handler.dart';  
import 'package:url\_launcher/url\_launcher.dart'; 

class DownloadsScreen extends StatefulWidget {  
const DownloadsScreen({super.key, this.seriesId});  
final String? seriesId; 

@override  
State createState() => \_DownloadsScreenState();  
} 

const l = L("download\_screen"); 

class \_DownloadsScreenState extends State {  
List downloads = \[\];  
StreamSubscription? \_progressSubscription;  
int? \_focusedIndex; // Memorizza l'indice dell'elemento selezionato col telecomando 

@override  
void dispose() {  
\_progressSubscription?.cancel();  
\_progressSubscription = null;  
super.dispose();  
} 

@override  
void initState() {  
super.initState();  
loadDownloads();  
\_progressSubscription = Downloader.instance.progressStream.listen((update) {  
final downloadId = update.id; 

l.debug("download id: $downloadId"); 

if (update.newItem && update.seriesId == widget.seriesId) {  
DownloadDb.instance.getDownloadItem(downloadId).then((x) {  
if (mounted) {  
setState(() {  
downloads.add(x);  
});  
}  
});  
return;  
} 

final currItem = downloads.firstWhereOrNull((e) => e.id == downloadId); 

if (currItem == null) return; 

final statusChanged =  
(update.status != null) && update.status != currItem.status; 

final progress = update;  
final progressChanged = progress.isAudio!  
? (progress.progress != currItem.audioProgress)  
: (progress.progress != currItem.videoProgress); 

if ((progressChanged || update.progress == null || statusChanged) &&  
mounted) {  
if (update.totalEpisodesPlus != null) {  
log("Total episodes added in inside IF: ${update.totalEpisodesPlus}");  
}  
setState(() {  
currItem.update(progress);  
});  
}  
});  
} 

Future loadDownloads() async {  
late final List x;  
if (widget.seriesId == null) {  
x = await DownloadDb.instance.getAllDownloads();  
} else {  
x = await DownloadDb.instance.getSeriesEpisodes(widget.seriesId!);  
}  
l.info("downloads count: ${x.length}");  
setState(() {  
downloads = x;  
});  
} 

void openMovie(String id, int ottId) {  
GoRouter.of(context).push("/movie/ottId/id");  
} 

static void \_launchUrl(String url) async {  
final Uri uri = Uri.parse(url);  
if (await canLaunchUrl(uri)) {  
await launchUrl(uri, mode: LaunchMode.externalApplication);  
} else {  
throw 'Could not launch $url';  
}  
} 

Future requestPermission() async {  
final result = await Permission.manageExternalStorage.request();  
return result.isGranted;  
} 

Future playWithAndroidVlc(String file) async {  
requestPermission();  
String subtitlePath = "/storage/emulated/0/Download/80243261-ar.srt";  
final intent = AndroidIntent(  
action: 'action\_view',  
data: file,  
type: "application/x-mpegURL",  
package: 'org.videolan.vlc',  
arrayArguments: {  
'subtitles\_location': \[subtitlePath\],  
'sub\_paths': \[subtitlePath\],  
},  
arguments: {  
'title': "Outlander",  
'from\_start': true,  
'subtitles\_location': subtitlePath,  
'sub\_file': subtitlePath,  
'extra\_subtitles\_file\_path': subtitlePath,  
'position': 1000,  
},  
flags: \[Flag.FLAG\_ACTIVITY\_NEW\_TASK, Flag.FLAG\_GRANT\_READ\_URI\_PERMISSION\],  
);  
await intent.launch();  
} 

void delete(String id, String type, int index) {  
if (type == "series") {  
Downloader.deleteSeries(id);  
} else {  
Downloader.deleteItem(id);  
}  
setState(() {  
downloads.removeAt(index);  
});  
} 

@override  
Widget build(BuildContext context) {  
return Scaffold(  
backgroundColor: Colors.black,  
appBar: AppBar(  
surfaceTintColor: Colors.black,  
backgroundColor: Colors.black,  
automaticallyImplyLeading: !isDesk,  
title: windowDragAreaWithChild(\[  
// TRADOTTO: Titolo della pagina in Italiano e ingrandito per TV  
const Text(  
'Download effettuati',  
style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)  
),  
\]),  
),  
body: downloads.isEmpty  
? const Center(  
child: Text(  
"Nessun download trovato",  
style: TextStyle(color: Colors.white, fontSize: 20),  
),  
)  
: ListView.builder(  
itemCount: downloads.length,  
itemBuilder: (context, i) => buildDownloadItem(downloads\[i\], i),  
),  
);  
} 

Widget \_buildProgressAudioOrVideo(  
DownloadItem item,  
int firstNonDownloadAudioIndex,  
) {  
int fndaIndex = firstNonDownloadAudioIndex;  
bool isAudioDownloading = fndaIndex != -1;  
bool showAudioCount = isAudioDownloading && item.audioLangs.length > 1;  
return RichText(  
text: TextSpan(  
children: \[  
TextSpan(  
// TRADOTTO: Etichette di progresso in Italiano  
text: isAudioDownloading  
? "Avanzamento: Audio showAudioCount ? "{fndaIndex + 1}/item.audioLangs.length" : "" Dot "  
: "Avanzamento: Video $Dot ",  
style: const TextStyle(  
color: Colors.white,  
fontSize: 14, // Carattere leggermente ingrandito per la TV  
),  
),  
TextSpan(  
text: isAudioDownloading  
? "${item.audioProgress}%"  
: "${item.videoProgress}%",  
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
),  
\],  
),  
);  
} 

Widget buildDownloadItem(DownloadItem item, int i) {  
final firstNonDownloadAudioIndex = item.audioLangs.indexWhere(  
(e) => !e.status,  
);  
final isFocused = \_focusedIndex == i; 

// Ottimizzato per TV: Racchiuso in un widget Focus per gestire il telecomando  
return Focus(  
onFocusChange: (hasFocus) {  
setState(() {  
if (hasFocus) {  
\_focusedIndex = i;  
} else if (\_focusedIndex == i) {  
\_focusedIndex = null;  
}  
});  
},  
child: GestureDetector(  
onTap: () async {  
if (item.type == "series") {  
context.push("/downloads", extra: item.id);  
return;  
} 

l.debug("download id: item.id, playlist path: {item.playlistPath}");  
final id = item.seriesId ?? item.id;  
final movie = await DB.movie.get(id, item.ottId);  
if (movie == null) {  
log("Movie not found in DB for id: $id");  
return;  
} 

GoRouter.of(context).push(  
"/player",  
extra: (  
url: item.playlistPath,  
movie: movie,  
watchHistory: null,  
seasonNumber: item.seasonNumber,  
episodeNumber: item.episodeNumber,  
subtitleUrl: null,  
),  
);  
},  
child: AnimatedContainer(  
duration: const Duration(milliseconds: 150),  
margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  
padding: const EdgeInsets.all(12),  
decoration: BoxDecoration(  
// Cambia colore di sfondo e aggiunge un bordo quando selezionato col telecomando  
color: isFocused ? Colors.grey.withValues(alpha: 0.3) : const Color(0xFF1E1E1E),  
borderRadius: BorderRadius.circular(12),  
border: Border.all(  
color: isFocused ? Colors.yellow : Colors.transparent,  
width: 2,  
),  
),  
child: Row(  
children: \[  
// Qui continua la struttura grafica dell'elemento (titolo del film, miniatura, ecc.)  
// che Flutter andrà a riprodurre correttamente attingendo dall'oggetto "item".  
Expanded(  
child: Column(  
crossAxisAlignment: CrossAxisAlignment.start,  
children: \[  
Text(  
item.name,  
style: const TextStyle(  
color: Colors.white,  
fontSize: 18,  
fontWeight: FontWeight.bold,  
),  
),  
const SizedBox(height: 6),  
\_buildProgressAudioOrVideo(item, firstNonDownloadAudioIndex),  
\],  
),  
),  
IconButton(  
icon: const Icon(Icons.delete, color: Colors.red),  
onPressed: () => delete(item.id, item.type, i),  
),  
\],  
),  
),  
),  
);  
}  
}