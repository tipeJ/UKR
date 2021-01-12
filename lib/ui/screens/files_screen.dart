import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/filelist_provider.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilesScreen extends StatefulWidget {
  final Player _player;
  const FilesScreen(this._player);

  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  static const _animationDuration = Duration(milliseconds: 500);
  late final PageController _controller;
  double _currentPage = 0;

  @override
  void initState() {
    _controller = PageController();
    _controller
        .addListener(() => setState(() => _currentPage = _controller.page!));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _currentPage.round(),
            onTap: (i) => _controller.animateToPage(i,
                curve: Curves.easeInExpo, duration: _animationDuration),
            items: [
              BottomNavigationBarItem(
                  label: "Videos", icon: const Icon(Icons.video_label)),
              BottomNavigationBarItem(
                  label: "Music", icon: const Icon(Icons.headset)),
              BottomNavigationBarItem(
                  label: "Pictures", icon: const Icon(Icons.image)),
            ],
          ),
          Expanded(
              child: PageView(
            controller: _controller,
            children: [
              _FilesSourceListScreen(widget._player, 'video'),
              _FilesSourceListScreen(widget._player, 'music'),
              _FilesSourceListScreen(widget._player, 'pictures'),
            ],
          ))
        ],
    ));
  }
}

class _FilesSourceListScreen extends StatefulWidget {
  final String source;
  final Player player;

  const _FilesSourceListScreen(this.player, this.source);

  @override
  __FilesSourceListScreenState createState() => __FilesSourceListScreenState();
}

class __FilesSourceListScreenState extends State<_FilesSourceListScreen> {
  int? _currentIndex;
  List<File>? _sources;

  Future<void> _getSources() async {
    List<File> files = [];
    await ApiProvider.getFileMediaSources(widget.player, media: widget.source,
      onSuccess: (l) => files = l);
    setState(() {
      _sources = files;
    });
  }

  @override
  void initState() {
    super.initState();
    _getSources();
  }

  @override
  Widget build(BuildContext context) {
    return _sources == null
        ? const Center(child: CircularProgressIndicator())
        : _buildContent(context, _sources!);
  }

  Widget _buildContent(BuildContext context, List<File> files) {
    if (_currentIndex == null) {
      return ListView.builder(
        itemCount: files.length,
        itemBuilder: (_, i) => ListTile(
            title: Text(files[i].label),
            onTap: () => setState(() => _currentIndex = i)),
      );
    } else {
      return WillPopScope(
        onWillPop: () async {
          if (_currentIndex != null) {
            setState(() => _currentIndex = null);
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: ChangeNotifierProvider(
          create: (_) => FilelistProvider(widget.player,
              rootPath: files[_currentIndex!].file,
              title: files[_currentIndex!].label),
          builder: (_, __) => FilelistScreen(),
        ),
      );
    }
  }
}
