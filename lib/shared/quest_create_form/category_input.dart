import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:it_contest_fe/features/quest/viewmodel/quest_tab_viewmodel.dart';

class CategoryInput extends StatefulWidget {
  final List<String>? initialValue;
  const CategoryInput({super.key, required this.onChanged, this.initialValue});
  final ValueChanged<List<String>> onChanged;

  @override
  State<CategoryInput> createState() => _CategoryInputState();
}

class _CategoryInputState extends State<CategoryInput> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _categories;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _categories = List<String>.from(widget.initialValue ?? []);
  }

  void _notifyParent() {
    widget.onChanged(List<String>.from(_categories));
  }

  // 기존 해시태그에서 검색어와 일치하는 항목 찾기
  void _searchHashtags(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final viewModel = context.read<QuestTabViewModel>();
    final allHashtags = <String>{};
    
    // 모든 퀘스트에서 해시태그 수집
    for (final quest in viewModel.allQuests) {
      allHashtags.addAll(quest.hashtags);
    }
    
    // 검색어와 일치하는 해시태그 필터링
    final filtered = allHashtags
        .where((hashtag) => 
            hashtag.toLowerCase().contains(query.toLowerCase()) &&
            !_categories.contains(hashtag)) // 이미 선택된 것은 제외
        .toList();
    
    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  // 제안된 해시태그 선택
  void _selectSuggestion(String hashtag) {
    setState(() {
      _categories.add(hashtag);
      _suggestions = [];
      _showSuggestions = false;
      _controller.clear();
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestTabViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "카테고리 분류",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              onChanged: _searchHashtags,
              onSubmitted: (value) {
                final trimmed = value.trim();
                if (trimmed.isNotEmpty && !_categories.contains(trimmed)) {
                  setState(() {
                    _categories.add(trimmed);
                    _controller.clear();
                    _suggestions = [];
                    _showSuggestions = false;
                  });
                  _notifyParent();
                }
              },
              decoration: InputDecoration(
                hintText: "카테고리를 직접 입력해 주세요",
                hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF7D4CFF), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            
              // 제안된 해시태그 표시
             if (_showSuggestions) ...[
               const SizedBox(height: 12),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   if (_suggestions.length > 3)
                     TextButton(
                       onPressed: () => _showAllSuggestionsDialog(context),
                       child: const Text(
                         "더보기(...)",
                         style: TextStyle(
                           fontSize: 12,
                           color: Color(0xFF643EFF),
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ),
                 ],
               ),
               const SizedBox(height: 8),
               // 한 줄에 최대 3개까지만 표시
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: _suggestions.take(3).map((hashtag) {
                   return GestureDetector(
                     onTap: () => _selectSuggestion(hashtag),
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFF643EFF)),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Text(
                         "#$hashtag",
                         style: const TextStyle(
                           color: Color(0xFF643EFF),
                           fontSize: 14,
                         ),
                       ),
                     ),
                   );
                 }).toList(),
               ),
             ],
            
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._categories.map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF643EFF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("#$category", style: const TextStyle(color: Color(0xFF643EFF))),
                  );
                }),
                if (_categories.isNotEmpty)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF643EFF),
                      side: const BorderSide(color: Color(0xFF643EFF)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity(vertical: -2),
                    ),
                    onPressed: () {
                      setState(() => _categories.removeLast());
                      _notifyParent();
                    },
                    child: const Text("삭제하기", style: TextStyle(fontSize: 14, color: Color(0xFF643EFF))),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 모든 제안된 해시태그를 보여주는 다이얼로그
  void _showAllSuggestionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
                      child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions.map((hashtag) {
                      return GestureDetector(
                        onTap: () {
                          _selectSuggestion(hashtag);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7D4CFF).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFF7D4CFF)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "#$hashtag",
                            style: const TextStyle(
                              color: Color(0xFF7D4CFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7D4CFF)),
                    foregroundColor: const Color(0xFF7D4CFF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("닫기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}