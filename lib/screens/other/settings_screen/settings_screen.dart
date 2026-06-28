import 'package:flutter/material.dart';  
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import 'package:go_router/go_router.dart';  
import 'package:hugeicons/hugeicons.dart';  
import 'package:netmirror/constants.dart';  
import 'package:netmirror/data/options.dart';  
import 'package:netmirror/downloader/downloader.dart';  
import 'package:netmirror/log.dart';  
import 'package:netmirror/provider/AudioTrackProvider.dart';  
import 'package:netmirror/screens/other/settings_screen/audios_preview_widget.dart';  
import 'package:netmirror/widgets/windows_titlebar_widgets.dart';  
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerStatefulWidget {  
  const SettingsScreen({super.key});

  @override  
  ConsumerState createState() => _SettingsScreenState();  
}

const l = L("Settings_Screen");

class _SettingsScreenState extends ConsumerState {  
  final _resolutionController = TextEditingController();  
  final _maxDownloadLimitController = TextEditingController(  
    text: Downloader.maxDownloadLimit.toString(),  
  );

  // Variabile per gestire l'evidenziazione del telecomando sulla TV  
  int _focusedIndex = -1;

  @override  
  Widget build(BuildContext context) {  
    final labelStyle = Theme.of(context).textTheme.titleMedium;  
    return Scaffold(  
      backgroundColor: Colors.black,  
      appBar: AppBar(  
        surfaceTintColor: Colors.black,  
        backgroundColor: Colors.black,  
        automaticallyImplyLeading: !isDesk,  
        title: windowDragAreaWithChild([const Text('Impostazioni TV')]),  
      ),  
      body: Padding(  
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),  
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.start,  
          crossAxisAlignment: CrossAxisAlignment.start,  
          mainAxisSize: MainAxisSize.min,  
          children: [  
            // Opzione 1: Player esterno streaming (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 0,  
              child: _buildSwitch(  
                "Usa Player Esterno per lo Streaming",  
                SettingsOptions.externalPlayer,  
                (value) {  
                  SettingsOptions.externalPlayer = value;  
                  setState(() {});  
                },  
              ),  
            ),  
            // Opzione 2: Player esterno download (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 1,  
              child: _buildSwitch(  
                "Usa Player Esterno per i Download",  
                SettingsOptions.externalDownloadPlayer,  
                (value) {  
                  SettingsOptions.externalDownloadPlayer = value;  
                  setState(() {});  
                },  
              ),  
            ),  
            // Opzione 3: Modalità veloce audio (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 2,  
              child: _buildSwitch(  
                "Modalità Veloce (Filtra Audio)",  
                SettingsOptions.fastModeByAudio,  
                (value) {  
                  if (!SettingsOptions.fastModeByAudio &&  
                      ref.read(audioTrackProvider).isEmpty) {  
                    showMssg("Seleziona prima una traccia audio preferita.");  
                  }  
                  SettingsOptions.fastModeByAudio = value;  
                  setState(() {});  
                },  
              ),  
            ),  
            // Opzione 4: Modalità veloce video (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 3,  
              child: _buildSwitch(  
                "Modalità Veloce (Filtra Video)",  
                SettingsOptions.fastModeByVideo,  
                (value) {  
                  if (!SettingsOptions.fastModeByVideo &&  
                      SettingsOptions.defaultResolution == "") {  
                    showMssg("Seleziona prima una qualità video predefinita.");  
                  }  
                  SettingsOptions.fastModeByVideo = value;  
                  setState(() {});  
                },  
              ),  
            ),  
            // Opzione 5: Selezione qualità video (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 4,  
              child: Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  
                child: Row(  
                  children: [  
                    Text("Qualità Video Predefinita", style: labelStyle),  
                    const Spacer(),  
                    DropdownMenu(  
                      controller: _resolutionController,  
                      menuStyle: const MenuStyle(),  
                      enableFilter: false,  
                      enableSearch: false,  
                      width: 135,  
                      alignmentOffset: const Offset(15, 8),  
                      inputDecorationTheme: InputDecorationTheme(  
                        isDense: true,  
                        suffixIconConstraints: const BoxConstraints(  
                          maxHeight: 42,  
                          maxWidth: 40,  
                        ),  
                        contentPadding: const EdgeInsets.symmetric(  
                          horizontal: 32.0,  
                          vertical: 0.0,  
                        ),  
                        border: OutlineInputBorder(  
                          borderRadius: BorderRadius.circular(8.0),  
                        ),  
                      ),  
                      trailingIcon: const Icon(  
                        HugeIcons.strokeRoundedAbacus,  
                        size: 20,  
                      ),  
                      requestFocusOnTap: false,  
                      initialSelection: SettingsOptions.defaultResolution,  
                      onSelected: (value) {  
                        if (value != null) {  
                          if (value.isEmpty) {  
                            SettingsOptions.fastModeByVideo = false;  
                          }  
                          _resolutionController.text = value;  
                          SettingsOptions.defaultResolution = value;  
                          setState(() {});  
                        }  
                      },  
                      dropdownMenuEntries: const [  
                        DropdownMenuEntry(  
                          value: "1080p",  
                          label: "1080p",  
                          trailingIcon: Icon(Icons.high_quality),  
                        ),  
                        DropdownMenuEntry(  
                          value: "720p",  
                          label: "720p",  
                          trailingIcon: Icon(Icons.hd),  
                        ),  
                        DropdownMenuEntry(  
                          value: "480p",  
                          label: "480p",  
                          trailingIcon: Icon(Icons.sd),  
                        ),  
                        DropdownMenuEntry(  
                          value: "",  
                          label: "Nessuna",  
                          trailingIcon: Icon(Icons.do_not_disturb),  
                        ),  
                      ],  
                    ),  
                  ],  
                ),  
              ),  
            ),  
            // Opzione 6: Limite massimo download (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 5,  
              child: Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  
                child: Row(  
                  children: [  
                    Text("Limite Massimo Download", style: labelStyle),  
                    const Spacer(),  
                    TextButton(  
                      style: TextButton.styleFrom(foregroundColor: Colors.yellow),  
                      onPressed: () {  
                        showPopupTextField(  
                          context,  
                          "Limite Massimo Download",  
                          _maxDownloadLimitController,  
                          () {  
                            SettingsOptions.maxDownloadLimit = int.parse(  
                              _maxDownloadLimitController.text,  
                            );  
                            Navigator.of(context).pop();  
                            setState(() {});  
                            return true;  
                          },  
                        );  
                      },  
                      child: Text(  
                        Downloader.maxDownloadLimit.toString(),  
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
                      ),  
                    ),  
                  ],  
                ),  
              ),  
            ),  
            // Opzione 7: Gestione tracce audio (Ottimizzato TV con Focus)  
            _buildTvItem(  
              index: 6,  
              child: InkWell(  
                borderRadius: BorderRadius.circular(8),  
                onTap: () {  
                  GoRouter.of(context).push('/settings-audio-tracks');  
                },  
                child: Padding(  
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),  
                  child: SizedBox(  
                    width: double.infinity,  
                    child: Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: [  
                        Text("Tracce Audio Preferite", style: labelStyle),  
                        const SizedBox(height: 4),  
                        const AudiosPreviewWidget(),  
                      ],  
                    ),  
