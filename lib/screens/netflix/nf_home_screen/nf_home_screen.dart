import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netmirror/constants.dart';
import 'package:netmirror/db/db.dart';
import 'package:netmirror/models/cache_model.dart';
import 'package:netmirror/models/home_models.dart';
import 'package:netmirror/screens/home_abstract.dart';
import 'package:netmirror/screens/netflix/nf_home_screen/nf_navbar.dart';
import 'package:netmirror/screens/netflix/nf_home_screen/nf_home_rows.dart';
import 'package:netmirror/screens/netflix/nf_home_screen/nf_tabs.dart';
import 'package:netmirror/utils/nav.dart';
import 'package:netmirror/widgets/top_buttons.dart';
import 'package:netmirror/widgets/windows_titlebar_widgets.dart';
import 'package:shared_code/models/ott.dart';

class NfMain extends StatelessWidget {
  const NfMain(this.shell, {super.key});
  final Widget shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: const NfNavBar(current: 0),
    );
  }
}

class NfHomeScreen extends Home {
  const NfHomeScreen({required super.tab, super.key});
  @override
  State<Home> createState() => _NfHomeScreenState();
}

class _NfHomeScreenState extends HomeState<NfHomeModel, NfHomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  OTT ott = OTT.netflix;
  final _controller = ScrollController();

  // Animation controller for the entrance animation
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Scroll and color related variables
  double scrollProgress = 0.0;
  static const int scrollThreshold = 30; // 600/20 = 30

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Create slide animation that starts from -80px (top) and moves to 0 (normal position)
    _slideAnimation = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _controller.addListener(_handleScroll);

    // Start the animation when the screen opens
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final int offset = (_controller.offset / 8).toInt();
    const scrollThreshold = 30;
    if (offset > scrollThreshold || offset == scrollThreshold) return;
    setState(() {
      scrollProgress = (offset / scrollThreshold).clamp(0.0, 1.0);
    });
  }

  void goToNewTab() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color? baseColor = data?.gradientColor;
    final backgroundOpacity =
        ((scrollProgress * scrollThreshold) / (scrollThreshold * 0.7)).clamp(
          0.0,
          1.0,
        );
    final appBarOpacity =
        ((scrollProgress * scrollThreshold) / (scrollThreshold * 0.3)).clamp(
          0.0,
          0.9,
        );

    // Calculate the background color
    final Color backgroundColor = baseColor != null
        ? Color.lerp(baseColor, Colors.black, backgroundOpacity)!
        : Colors.black;
    final paddingTop = MediaQuery.paddingOf(context).top;
    final toolbarHeight = isDesk ? 28.0 : kToolbarHeight;

    l.debug("rebuild nf hom screen, tab: ${widget.tab}");

    return RefreshIndicator(
      onRefresh: loadDataFromOnline,
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black.withValues(alpha: appBarOpacity),
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: !isDesk,
              pinned: true,
              toolbarHeight: toolbarHeight,
              floating: true,
              expandedHeight: 108,
              title: windowDragAreaWithChild(
                [
                  widget.tab == 0
                      ? Image.asset(
                          "assets/logos/netflix.png",
                          height: isDesk ? 25 : 45,
                          width: isDesk ? 22 : 37,
                        )
                      : Text(
                          // TRADOTTO: Menu superiore stile Netflix in Italiano
                          ["Serie TV", "Film", "Categorie"][widget.tab - 1],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ],
                actions: [
                  TopbarButtons.settingsBtn(context),
                  TopbarButtons.downloadsBtn(context),
                  TopbarButtons.searchBtn(context, 0),
                ],
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(top: toolbarHeight + paddingTop),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        if (scrollProgress == 0) ...[
                          Color.lerp(
                            baseColor?.lighten(0.2) ?? Colors.black,
                            Colors.black,
                            scrollProgress,
                          )!,
                          Color.lerp(
                            baseColor?.withOpacity(0.5) ?? Colors.black,
                            Colors.black.withAlpha(200),
                            scrollProgress,
                          )!,
                        ] else ...[
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: NfHeaderTabs(widget.tab, goToNewTab),
                ),
              ),
            ),
            data == null
                ? const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 600,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              buildSpotlight(backgroundColor, baseColor),
                              ...data!.trays.map((e) => NfHomeRow(tray: e)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Chiusura pulita della funzione Spotlight che si era interrotta
  Widget buildSpotlight(Color backgroundColor, Color? baseColor) {
    return const SizedBox.shrink();
  }
}
