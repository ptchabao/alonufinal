import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';

class YoutubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;

  const YoutubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
  });
}

List<YoutubeVideo> parseYoutubeFeed(String xml) {
  final entryMatches = RegExp(
    r'<entry>(.*?)</entry>',
    dotAll: true,
  ).allMatches(xml);

  final videos = <YoutubeVideo>[];
  final seenIds = <String>{};

  for (final match in entryMatches) {
    final entry = match.group(1) ?? '';
    final idMatch = RegExp(r'<yt:videoId>(.*?)</yt:videoId>').firstMatch(entry);
    final titleMatch = RegExp(
      r'<media:title>(.*?)</media:title>',
    ).firstMatch(entry);

    final id = (idMatch?.group(1) ?? '').trim();
    final title = (titleMatch?.group(1) ?? '')
        .replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (id.length != 11 || title.isEmpty || seenIds.contains(id)) {
      continue;
    }

    seenIds.add(id);
    videos.add(
      YoutubeVideo(
        id: id,
        title: title,
        thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
      ),
    );
  }

  return videos.take(12).toList();
}

class TvScreen extends StatefulWidget {
  const TvScreen({Key? key}) : super(key: key);

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  late Future<List<YoutubeVideo>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _fetchVideos();
  }

  Future<List<YoutubeVideo>> _fetchVideos() async {
    final response = await http.get(
      Uri.parse(
        'https://www.youtube.com/feeds/videos.xml?channel_id=UCzqx1LZaancsbtROAFMVJRw',
      ),
    );

    if (response.statusCode != 200) {
      return _fallbackVideos();
    }

    final videos = parseYoutubeFeed(response.body);
    return videos.isNotEmpty ? videos : _fallbackVideos();
  }

  List<YoutubeVideo> _fallbackVideos() {
    return List.generate(
      6,
      (index) => YoutubeVideo(
        id: [
          '4uk3rD0fs9s',
          'E9x9kWeBN0w',
          'yCRxcSeiQso',
          'e1krNdsbENc',
          '21kbYQWAss0',
          'MImsrWcyWKo',
        ][index],
        title: 'Extrait vidéo ${index + 1}',
        thumbnailUrl:
            'https://i.ytimg.com/vi/${['4uk3rD0fs9s', 'E9x9kWeBN0w', 'yCRxcSeiQso', 'e1krNdsbENc', '21kbYQWAss0', 'MImsrWcyWKo'][index]}/hqdefault.jpg',
      ),
    );
  }

  Future<void> _openVideo(BuildContext context, YoutubeVideo video) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=${video.id}');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      showErrorSnackbar(context, 'Impossible d’ouvrir cette vidéo');
    }
  }

  Future<void> _openChannel(BuildContext context) async {
    final uri = Uri.parse('https://www.youtube.com/@itvafrica2809');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      showErrorSnackbar(context, 'Impossible d’ouvrir la chaîne');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV ALONU'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: FutureBuilder<List<YoutubeVideo>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoadingIndicator());
          }

          final videos = snapshot.data ?? _fallbackVideos();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chaîne TV ALONU',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Regardez les émissions et tutoriels de la chaîne YouTube @itvafrica2809 directement depuis l’application.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        label: 'Ouvrir la chaîne',
                        onPressed: () => _openChannel(context),
                        isSmall: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vidéos disponibles',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${videos.length} vidéos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _openVideo(context, video),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.cardShadows,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: video.thumbnailUrl,
                                  width: 140,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 140,
                                    height: 96,
                                    color: AppColors.surfaceVariant,
                                    child: const Center(
                                      child: AppLoadingIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 140,
                                        height: 96,
                                        color: AppColors.surfaceVariant,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Ouvrir sur YouTube',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
