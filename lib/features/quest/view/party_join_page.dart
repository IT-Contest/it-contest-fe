import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/service/party_service.dart';

import '../../../shared/alarm/widgets/party_invitation_card.dart';

class PartyJoinPage extends StatefulWidget {
  const PartyJoinPage({super.key});

  @override
  State<PartyJoinPage> createState() => _PartyJoinPageState();
}

class _PartyJoinPageState extends State<PartyJoinPage> {
  final PartyService _partyService = PartyService();
  List<Map<String, dynamic>> invitations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    if (token != null) {
      final list = await _partyService.fetchInvitedParties(token);
      setState(() {
        invitations = list;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          '파티 초대장',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : invitations.isEmpty
          ? const Center(
        child: Text(
          '받은 파티 초대장이 없습니다.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          return PartyInvitationCard(partyData: invitations[index]);
        },
      ),
    );
  }
}