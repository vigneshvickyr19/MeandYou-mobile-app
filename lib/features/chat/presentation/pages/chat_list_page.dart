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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ChatListController();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ChatListController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppColors.black,
            appBar: AppBar(
              backgroundColor: AppColors.black,
              elevation: 0,
              title: controller.isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: controller.searchUsers,
                    )
                  : const Text(
                      'Chats',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    controller.isSearching ? Icons.close : Icons.search,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    controller.toggleSearch();
                    if (!controller.isSearching) {
                      _searchController.clear();
                    }
                  },
                ),
              ],
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
                                  color: AppColors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No chats yet',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
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
}
