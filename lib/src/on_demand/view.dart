import 'package:flutter/material.dart';
import 'package:ctwr_midtown_radio_app/src/on_demand/controller.dart';
import 'package:intl/intl.dart';
import 'package:ctwr_midtown_radio_app/src/on_demand/episode_list.dart';

// This page displays list of podcasts, for user to click and see list of episodes per podcast
/// The list of episodes has been moved to [EpisodeListPage]
class OnDemandPage extends StatefulWidget {
  const OnDemandPage({super.key});
  static const routeName = '/on_demand';
  final String title = 'On Demand';

  @override
  State<OnDemandPage> createState() => _OnDemandPageState();
}

class _OnDemandPageState extends State<OnDemandPage> {
  late Future<OnDemand> _onDemandFuture;

  @override
  void initState() {
    super.initState();
    _onDemandFuture = OnDemand.create();
  }

  String _formatShowDisplayDate(
      final DateTime? sortableDate,
      final String? originalDateString
      ) {
    if (sortableDate != null) {
      return DateFormat('MMM d, yyyy').format(sortableDate);
    }
    if (originalDateString != null && originalDateString.isNotEmpty) {
      return originalDateString.length > 16
          ? "${originalDateString.substring(0, 16)}..."
          : originalDateString;
    }
    return 'Date N/A';
  }

  // force refresh data - used on pulldown
  Future<void> _loadShows({bool forceRefresh = false}) async {
    setState(() {
      _onDemandFuture = OnDemand.create(forceRefresh: forceRefresh);
    });
  }

  @override
  Widget build(BuildContext context) {

    // Text scaling calculations -- if text is large we increase the number of rows it can take up
    // so that it still displays enough info
    final TextScaler textScaler = MediaQuery.of(context).textScaler;
    final double textScaleFactor = textScaler.scale(1);

    // Define dynamic maxLines based on textScaleFactor
    int titleMaxLines = 1; 
    if (textScaleFactor > 1.7) {
      titleMaxLines = 3;
    } else if (textScaleFactor > 1.3) {
      titleMaxLines = 2;
    }

    int descriptionMaxLines = 2;
    if (textScaleFactor > 1.7) {
      descriptionMaxLines = 4;
    } else if (textScaleFactor > 1.3) {
      descriptionMaxLines = 3;
    }

    return Scaffold(
      // List of shows using futurebuilder
      body: RefreshIndicator(
        onRefresh: () => _loadShows(forceRefresh: true),
        child: FutureBuilder<OnDemand>(
          future: _onDemandFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: "Loading On Demand Shows.",
                  )
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("An unexpected error has occured. Please try again later."));
            } else if (!snapshot.hasData || snapshot.data!.shows.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No shows available. \nPlease ensure you are connected to the internet.', 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 18)
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.refresh),
                        label: Text(
                          "Try Again",
                          style: TextStyle(fontSize: 18)
                        ),
                        onPressed: () => _loadShows(forceRefresh: true),
                      )
                    ],
                  )
                ),
              );
            } else {
              final List<PodcastShow> shows = snapshot.data!.shows;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: shows.length,
                itemBuilder: (context, index) {
                  final show = shows[index];
                  // Unique tag for hero animation. Using feedUrl as it should be unique per show.
                  final String heroTag = "showImage_${show.feedUrl}";
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    elevation: 2.5,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // When user clicks on a show we take them to the page with all the episodes
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EpisodeListPage(show: show, heroTag: heroTag),
                          ),
                        );
                      },
                      child: Semantics(
                        button: true,
                        label: "View episodes of ${show.title}",
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Hero(
                                  tag: heroTag,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      semanticLabel: "Art cover for ${show.title}",
                                      show.imageUrl,
                                      fit: BoxFit.cover,
                                      width: 80, // Ensure image tries to fill
                                      height: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image_not_supported_outlined, size: 30, color: Colors.grey[400]),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      show.title,
                                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w900),
                                      maxLines: titleMaxLines,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (show.description != null && show.description!.isNotEmpty)
                                      Text(
                                        show.description!,
                                        maxLines: descriptionMaxLines,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Updated: ${_formatShowDisplayDate(show.sortablePublishDate, show.publishDate)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[400] : Colors.grey[850], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}