import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/post_item_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/isolated_comment_sheet.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/theme_service.dart';
import '../widgets/connectivity_banner.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<FeedBloc>()..add(const LoadFeedEvent()),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();
  late final FeedBloc _feedBloc;

  @override
  void initState() {
    super.initState();
    _feedBloc = context.read<FeedBloc>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && mounted) {
      _feedBloc.add(const LoadMorePostsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityBanner(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            if (mounted) {
              _feedBloc.add(const LoadFeedEvent(isRefresh: true));
              // Wait for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          },
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: const Text(
                  'Media Feed',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    ThemeService().isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  onPressed: () {
                    ThemeService().toggleTheme();
                  },
                  tooltip: ThemeService().isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                if (state is FeedLoading) {
                  return const LoadingWidget();
                } else if (state is FeedError) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: FeedErrorWidget(
                      message: state.message,
                      onRetry: () {
                        if (mounted) {
                          _feedBloc.add(const LoadFeedEvent());
                        }
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state is FeedLoaded) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: LoadingWidget(),
                        );
                      }

                      final post = state.posts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: PostItemWidget(
                          key: ValueKey('post_${post.id}'), // Stable key to prevent unnecessary rebuilds
                          post: post,
                          feedBloc: _feedBloc,
                          onComment: () {
                            _showCommentsBottomSheet(context, post.id);
                          },
                        ),
                      );
                    },
                    childCount: state.hasReachedMax
                        ? state.posts.length
                        : state.posts.length + 1,
                  ),
                );
              }
              return SliverToBoxAdapter(child: const SizedBox.shrink());
            },
          ),
          ],
          ),
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int postId) {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: IsolatedCommentSheet(
              postId: postId,
              feedBloc: _feedBloc,
            ),
          ),
        );
      },
    );
  }
}