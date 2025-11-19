import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/analysis_models.dart';
import '../viewmodel/analysis_viewmodel.dart';

class CoachingHistoryScreen extends StatefulWidget {
  const CoachingHistoryScreen({super.key});

  @override
  State<CoachingHistoryScreen> createState() => _CoachingHistoryScreenState();
}

class _CoachingHistoryScreenState extends State<CoachingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // 코칭 히스토리 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisViewModel>().loadCoachingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              '코칭 기록 보기',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: viewModel.isLoadingCoachingHistory
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7958FF)))
              : viewModel.coachingHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildCoachingList(viewModel),
        );
      },
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '코칭 기록이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI 코칭을 받아보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 코칭 리스트 위젯
  Widget _buildCoachingList(AnalysisViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.coachingHistory.length,
      itemBuilder: (context, index) {
        final history = viewModel.coachingHistory[index];
        return _buildCoachingItem(history, index);
      },
    );
  }

  // 코칭 아이템 위젯
  Widget _buildCoachingItem(CoachingHistoryItem history, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DDFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showCoachingDetailModal(history),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    history.type,
                    style: const TextStyle(
                      color: Color(0xFF7958FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  history.date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getPreviewText(history.content),
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '자세히 보기',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 코칭 내용 미리보기 텍스트
  String _getPreviewText(String content) {
    try {
      // JSON 파싱 시도
      if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
        final Map<String, dynamic> jsonData = jsonDecode(content);
        if (jsonData['key_insights'] != null) {
          return jsonData['key_insights'].toString();
        }
      }
    } catch (e) {
      // JSON 파싱 실패 시 원본 텍스트 사용
    }
    
    return content;
  }

  // 코칭 상세 모달
  void _showCoachingDetailModal(CoachingHistoryItem history) {
    final parsedContent = _parseCoachingContent(history.content);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.type,
                          style: const TextStyle(
                            color: Color(0xFF7958FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          history.date,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (parsedContent['key_insights'] != null) ...[
                        _buildSectionTitle('주요 인사이트'),
                        _buildContentText(parsedContent['key_insights']!),
                        const SizedBox(height: 16),
                      ],
                      if (parsedContent['improvement_suggestions'] != null) ...[
                        _buildSectionTitle('개선 제안사항'),
                        _buildContentText(parsedContent['improvement_suggestions']!),
                        const SizedBox(height: 16),
                      ],
                      if (parsedContent['action_plan'] != null) ...[
                        _buildSectionTitle('실행 계획'),
                        _buildContentText(parsedContent['action_plan']!),
                        const SizedBox(height: 16),
                      ],
                      if (parsedContent['expected_effects'] != null) ...[
                        _buildSectionTitle('기대 효과'),
                        _buildContentText(parsedContent['expected_effects']!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 코칭 내용 파싱
  Map<String, String> _parseCoachingContent(String content) {
    try {
      // JSON 파싱 시도
      if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
        final Map<String, dynamic> jsonData = jsonDecode(content);
        final Map<String, String> result = {};
        
        if (jsonData['key_insights'] != null) {
          result['key_insights'] = jsonData['key_insights'].toString();
        }
        if (jsonData['improvement_suggestions'] != null) {
          result['improvement_suggestions'] = jsonData['improvement_suggestions'].toString();
        }
        if (jsonData['action_plan'] != null) {
          result['action_plan'] = jsonData['action_plan'].toString();
        }
        if (jsonData['expected_effects'] != null) {
          result['expected_effects'] = jsonData['expected_effects'].toString();
        }
        
        return result;
      }
    } catch (e) {
      // JSON 파싱 실패 시 수동 파싱 시도
      try {
        final Map<String, String> parsedData = {};
        final lines = content.split('\n');
        
        for (String line in lines) {
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              final key = parts[0].replaceAll(RegExp(r'[{"}]'), '').trim();
              final value = parts.sublist(1).join(':').replaceAll(RegExp(r'[,"}]'), '').trim();
              
              if (key.isNotEmpty && value.isNotEmpty) {
                // 키 매핑
                if (key == 'key_insights') {
                  parsedData['key_insights'] = value;
                } else if (key == 'improvement_suggestions') {
                  parsedData['improvement_suggestions'] = value;
                } else if (key == 'action_plan') {
                  parsedData['action_plan'] = value;
                } else if (key == 'expected_effects') {
                  parsedData['expected_effects'] = value;
                }
              }
            }
          }
        }
        
        if (parsedData.isNotEmpty) {
          return parsedData;
        }
      } catch (e2) {
        // 수동 파싱도 실패
      }
    }
    
    // 일반 텍스트인 경우 전체를 주요 인사이트로 처리
    return {'key_insights': content};
  }

  // 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7958FF),
        ),
      ),
    );
  }

  // 내용 텍스트 위젯
  Widget _buildContentText(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8DDFF), width: 1),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Colors.black87,
        ),
      ),
    );
  }
}