import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../friends/viewmodel/friend_viewmodel.dart';

class PartyInvitePage extends StatefulWidget {
  const PartyInvitePage({super.key});

  @override
  State<PartyInvitePage> createState() => _PartyInvitePageState();
}

class _PartyInvitePageState extends State<PartyInvitePage> {
  final Set<int> selectedIndexes = {}; // ✅ 여러 명 선택 가능하도록 변경

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<FriendViewModel>(context, listen: false).fetchFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '모든 친구 보기',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, height: 1, thickness: 1),
        ),
      ),

      body: Consumer<FriendViewModel>(
        builder: (context, viewModel, _) {
          final friends = viewModel.friends;

          if (friends.isEmpty) {
            return SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  Image.asset(
                    'assets/icons/icon1.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '친구가 등록되어 있지 않습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final isSelected = selectedIndexes.contains(index);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedIndexes.remove(index);
                    } else {
                      selectedIndexes.add(index);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6737F4)
                            : Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: (friend.profileImageUrl.isNotEmpty)
                              ? Image.network(
                            friend.profileImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/images/simpson.jpg',
                                  width: 60, height: 60, fit: BoxFit.cover);
                            },
                          )
                              : Image.asset('assets/images/simpson.jpg',
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    friend.nickname,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6737F4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'LV.${friend.level}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: const Color(0xFF6737F4),
                                            width: 2),
                                      ),
                                      child: Stack(
                                        children: [
                                          FractionallySizedBox(
                                            widthFactor:
                                            friend.expPercent / 100,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0x996737F4),
                                                borderRadius:
                                                BorderRadius.circular(14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'EXP ${friend.expPercent}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6737F4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/icons/widget_icon.png',
                                          width: 18, height: 18),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '누적 경험치 ',
                                        style: TextStyle(
                                            color: Color(0xFF6737F4),
                                            fontSize: 13),
                                      ),
                                      Text(
                                        '${friend.totalExp}',
                                        style: const TextStyle(
                                          color: Color(0xFF6737F4),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/icons/gold_icon.png',
                                          width: 18, height: 18),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '골드 ',
                                        style: TextStyle(
                                            color: Color(0xFF6737F4),
                                            fontSize: 13),
                                      ),
                                      Text(
                                        '${friend.gold}',
                                        style: const TextStyle(
                                          color: Color(0xFF6737F4),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // 확인 버튼 (PartyInvitePage와 동일)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedIndexes.isEmpty
              ? null
              : () {
            final friends = context.read<FriendViewModel>().friends;
            final selectedFriends =
            selectedIndexes.map((i) => friends[i]).toList();

            Navigator.pop(context, selectedFriends);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6737F4),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '확인',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}
