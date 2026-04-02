import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/chat_list_controller.dart';
import '../widgets/chat_list_item.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatListController _controller;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = ChatListController();
    _searchController = TextEditingController();
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _controller.loadChatRooms(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    _controller.toggleSearch();
    if (!_controller.isSearching) {
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ChatListController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: _buildModernAppBar(controller, isDarkMode),
            ),
            body: RefreshIndicator(
              onRefresh: () => controller.refreshChatRooms(currentUserId),
              color: AppColors.primary,
              child: controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : controller.chatRooms.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: isDarkMode
                                      ? AppColors.white.withValues(alpha: 0.3)
                                      : AppColors.black.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No chats yet',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.white.withValues(alpha: 0.6)
                                        : AppColors.black.withValues(alpha: 0.6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.chatRooms.length,
                          itemBuilder: (context, index) {
                            final chatRoom = controller.chatRooms[index];
                            final user = controller.getUserForChatRoom(
                              chatRoom,
                              currentUserId,
                            );

                            return ChatListItem(
                              chatRoom: chatRoom,
                              user: user,
                              currentUserId: currentUserId,
                              onTap: () {
                                controller.markAsReadLocally(chatRoom.id, currentUserId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailPage(
                                      chatRoomId: chatRoom.id,
                                      otherUser: user!,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernAppBar(ChatListController controller, bool isDarkMode) {
    final backgroundColor = isDarkMode ? AppColors.black : AppColors.white;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final subtleColor = isDarkMode 
        ? AppColors.white.withValues(alpha: 0.5) 
        : AppColors.black.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode 
                ? AppColors.white.withValues(alpha: 0.1) 
                : AppColors.black.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              // Title or Search Input
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: controller.isSearching
                      ? _buildSearchInput(textColor, subtleColor)
                      : _buildTitle(textColor),
                ),
              ),
              const SizedBox(width: 16),
              // Search Icon Button
              _buildSearchButton(controller, textColor, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(Color textColor) {
    return Align(
      key: const ValueKey('title'),
      alignment: Alignment.centerLeft,
      child: Text(
        'Chats',
        style: TextStyle(
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildSearchInput(Color textColor, Color subtleColor) {
    return Container(
      key: const ValueKey('search'),
      height: 44,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          hintStyle: TextStyle(
            color: subtleColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: subtleColor,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _controller.searchUsers,
      ),
    );
  }

  Widget _buildSearchButton(
    ChatListController controller,
    Color textColor,
    bool isDarkMode,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleSearch,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: controller.isSearching
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : textColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  controller.isSearching ? Icons.close_rounded : Icons.search_rounded,
                  key: ValueKey(controller.isSearching),
                  color: controller.isSearching ? AppColors.primary : textColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
