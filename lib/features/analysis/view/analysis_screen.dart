import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/analytics/service/analytics_service.dart';
import '../model/analysis_models.dart';
import '../viewmodel/analysis_viewmodel.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import 'coaching_history_screen.dart';
import 'leaderboard_full_screen.dart';
import '../../quest/view/widgets/quest_type_bottom_sheet.dart';


class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  int? _selectedSpotIndex; // 선택된 지점의 인덱스

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisViewModel>().initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisViewModel>(
      builder: (context, viewModel, child) {

        return Scaffold(
          appBar: const CustomAppBar(),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF3FAFF),
                  Color(0xFFEEEBFF),
                ],
              ),
            ),
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        '분석',
                        style: TextStyle(
                          color: Color(0xFF4C1FFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeframeSelector(viewModel),
                          const SizedBox(height: 16),
                          _buildAnalysisCard(context, viewModel),
                          const SizedBox(height: 24),
                          _buildLeaderboardCard(context, viewModel),
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
  }

  // --- 위젯 빌더 메서드 ---

  // 일일, 주간, 월간, 연간 선택 버튼
  Widget _buildTimeframeSelector(AnalysisViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: AnalysisTimeframe.values.map((timeframe) {
        final isSelected = viewModel.selectedTimeframe == timeframe;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () => viewModel.selectTimeframe(timeframe),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF7958FF) : Colors.white,
                foregroundColor: isSelected ? Colors.white : const Color(0xFF7958FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected 
                    ? BorderSide.none 
                    : const BorderSide(color: Color(0xFF7958FF), width: 1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                timeframe.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 퀘스트 분석 카드
  Widget _buildAnalysisCard(BuildContext context, AnalysisViewModel viewModel) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${viewModel.currentDateStamp} 기준', style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                  _buildDataTypeDropdown(viewModel),
                ],
              ),
              const SizedBox(height: 20),
              // 그래프 영역
              viewModel.isLoadingAnalysis 
                ? const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      _buildLineChartData(viewModel),
                    ),
                  ),
              const SizedBox(height: 20),
              Text(
                '완료 퀘스트 : ${viewModel.completedQuests}개   완료한 뽀모도로 세션 : ${viewModel.completedPomodoros}개',
                style: const TextStyle(color: Color(0xFF7958FF), fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: viewModel.isRequestingCoaching 
                        ? null 
                        : () {
                            // Analytics 이벤트 기록
                            AnalyticsService.logAiCoachingClicked();
                            _showCoachingModal(context, viewModel);
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7958FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: viewModel.isRequestingCoaching 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
                          )
                        : const Text('AI 코칭 받기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {

                        // Analytics 이벤트 기록
                        AnalyticsService.logCoachingHistoryClicked();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CoachingHistoryScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7958FF),
                        side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('코칭 기록 보기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Analytics 이벤트 기록
                    AnalyticsService.logQuestAddFromAnalysis();

                    QuestTypeBottomSheet.show(
                      context,
                      onPersonalQuestTap: () {
                        // 개인 퀘스트 생성 후 콜백 (필요시 분석 데이터 새로고침)
                        print('Personal quest created from analysis tab');
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7958FF),
                    side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text('새 퀘스트 추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  // 데이터 타입 드롭다운
  Widget _buildDataTypeDropdown(AnalysisViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DDFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalysisDataType>(
          value: viewModel.selectedDataType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7958FF)),
          onChanged: (AnalysisDataType? newValue) {
            if (newValue != null) {
              viewModel.selectDataType(newValue);
            }
          },
          items: AnalysisDataType.values.map<DropdownMenuItem<AnalysisDataType>>((AnalysisDataType value) {
            return DropdownMenuItem<AnalysisDataType>(
              value: value,
              child: Text(
                value.displayName,
                style: const TextStyle(
                  color: Color(0xFF7958FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 리더보드 카드
  Widget _buildLeaderboardCard(BuildContext context, AnalysisViewModel viewModel) {
    return Column(
      children: [
        // 리더보드 헤더 (카드 밖)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('리더보드', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4C1FFF))),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardFullScreen(),
                  ),
                );
              },
              child: const Text('전체보기 >', style: TextStyle(color: Color(0xFF7958FF), fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 8),
        // 리더보드 아이템들
        viewModel.isLoadingLeaderboard
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: viewModel.leaderboard.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    shadowColor: const Color(0xFFEDE9FE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 순위 배지
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7958FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                user.rank.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 프로필 이미지
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(user.avatarUrl),
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(width: 16),
                          // 사용자 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user.exp.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} exp',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7958FF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
      ],
    );
  }


  // fl_chart용 LineChartData 생성
  LineChartData _buildLineChartData(AnalysisViewModel viewModel) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45, // ✅ 라벨이 겹치지 않도록 아래 여백 늘림
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index >= 0 && index < viewModel.chartLabels.length) {
                final isCompactLabel = viewModel.selectedTimeframe == AnalysisTimeframe.weekly ||
                    viewModel.selectedTimeframe == AnalysisTimeframe.monthly;

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    viewModel.chartLabels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isCompactLabel ? 9.5 : 12, // ✅ 주간/월간은 글씨 크기만 축소
                      fontWeight: FontWeight.w500,
                      height: 1.2, // ✅ 라벨 간 간격 살짝 조정
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (viewModel.chartData.length - 1).toDouble(),
      minY: 0,
      maxY: _getMaxY(viewModel.chartData),
      lineTouchData: LineTouchData(
        enabled: true,
        touchSpotThreshold: 30, // 터치 감지 거리 증가
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final value = barSpot.y.toInt();
              return LineTooltipItem(
                '${value}개',
                const TextStyle(
                  color: Color(0xFF7958FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            }).toList();
          },
          tooltipBorder: const BorderSide(
            color: Color(0xFF7958FF),
            width: 1,
          ),
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8, // 차트 경계와의 여백
        ),
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: Colors.transparent), // 선 숨김
              FlDotData(show: false), // 점 숨김
            );
          }).toList();
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: viewModel.chartData
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList(),
          isCurved: false,
          color: const Color(0xFF7958FF),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  double _getMaxY(List<double> data) {
    // 항상 20을 최대값으로 고정
    return 20;
  }



  // AI 코칭 모달 표시
  void _showCoachingModal(BuildContext context, AnalysisViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLoadingModal(),
    );

    viewModel.requestAiCoaching().then((result) {
      // 로딩 모달 닫기
      Navigator.of(context).pop();
      
      if (result.success && result.coachingContent != null) {
        // 분석 결과 모달 표시
        _showCoachingResultModal(context, result.coachingContent!);
      } else if (result.errorMessage == 'daily_limit_reached') {
        // 일일 사용 제한 팝업 표시
        _showDailyLimitDialog(context);
      } else {
        // 오류 처리
        _showErrorDialog(context, result.errorMessage ?? '분석 중 오류가 발생했습니다.');
      }
    });
  }

  // 로딩 모달 위젯
  Widget _buildLoadingModal() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '분석 중',
                style: TextStyle(
                  color: Color(0xFF7958FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // 도트 로딩 애니메이션
              const LoadingDots(),
            ],
          ),
        ),
      ),
    );
  }

  // 분석 결과 모달
  void _showCoachingResultModal(BuildContext context, String coachingContent) {
    final parsedContent = _parseCoachingContent(coachingContent);
    
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
                  const Text(
                    '분석 결과',
                    style: TextStyle(
                      color: Color(0xFF7958FF),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<AnalysisViewModel>().saveCoachingResult(parsedContent);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('코칭 결과가 저장되었습니다.'),
                          backgroundColor: Color(0xFF7958FF),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7958FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '저장하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 코칭 내용 파싱 (JSON 또는 일반 텍스트)
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

  // 일일 사용 제한 다이얼로그
  void _showDailyLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 경고 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFD73027),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AI 코칭 기능은 하루 한 번만\n활용이 가능합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7958FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 오류 다이얼로그
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 로딩 도트 애니메이션 위젯
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 순차적으로 애니메이션 시작
    _controller1.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller2.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(_controller1),
        const SizedBox(width: 8),
        _buildDot(_controller2),
        const SizedBox(width: 8),
        _buildDot(_controller3),
      ],
    );
  }

  Widget _buildDot(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final opacity = 0.3 + (controller.value * 0.7);
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF7958FF).withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}