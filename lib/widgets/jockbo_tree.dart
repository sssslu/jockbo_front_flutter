import 'package:flutter/material.dart';
import '../models.dart';

const Color _connectorColor = Color(0xFF3C2317);
const double _connectorStrokeWidth = 3;

// === 세대 정렬을 위해 ‘모두가 공유’할 크기 상수 ===
const double _nodeWidth  = 72;   // 노드 가로
const double _nodeHeight = 44;   // 노드 세로(텍스트 박스 높이)
const double _levelGap   = 32;   // 부모-자식 사이 간격(부모 바닥 ~ 자식 상단)

/// 부모‑자식/형제 연결선 구조체
class _Line {
  final Offset start;
  final Offset end;
  const _Line(this.start, this.end);
}

/// 선 그리기
class _LinePainter extends CustomPainter {
  final List<_Line> lines;
  _LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _connectorColor
      ..strokeWidth = _connectorStrokeWidth;
    for (final l in lines) {
      canvas.drawLine(l.start, l.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) {
    if (identical(lines, old.lines)) return false;
    if (lines.length != old.lines.length) return true;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].start != old.lines[i].start || lines[i].end != old.lines[i].end) {
        return true;
      }
    }
    return false;
  }
}

class JockBoTree extends StatefulWidget {
  final List<JockBoTreeItemInfo> jockBo;
  final int myId;
  final ValueChanged<int> onSelect;

  const JockBoTree({
    Key? key,
    required this.jockBo,
    required this.myId,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<JockBoTree> createState() => _JockBoTreeState();
}

class _JockBoTreeState extends State<JockBoTree> {
  final Map<int, GlobalKey> _nodeKeys = {};
  final GlobalKey _stackKey = GlobalKey();
  List<_Line> _lines = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLines());
  }

  @override
  void didUpdateWidget(covariant JockBoTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLines());
  }

  void _updateLines() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    final List<_Line> next = [];

    void collect(JockBoTreeItemInfo node) {
      final parentKey = _nodeKeys[node.id];
      final parentBox = parentKey?.currentContext?.findRenderObject() as RenderBox?;
      Offset? parentBottom;
      if (parentBox != null) {
        final parentTopLeft = parentBox.localToGlobal(Offset.zero, ancestor: stackBox);
        parentBottom = parentTopLeft + Offset(parentBox.size.width / 2, parentBox.size.height);
      }

      final List<Offset> childTops = [];
      for (final c in node.children) {
        final ck = _nodeKeys[c.id];
        final cb = ck?.currentContext?.findRenderObject() as RenderBox?;
        if (cb != null) {
          final tl = cb.localToGlobal(Offset.zero, ancestor: stackBox);
          childTops.add(tl + Offset(cb.size.width / 2, 0));
          collect(c);
        }
      }

      if (parentBottom != null && childTops.isNotEmpty) {
        final jointY = childTops.first.dy;
        // 부모에서 jointY까지 수직선
        next.add(_Line(parentBottom, Offset(parentBottom.dx, jointY)));
        // jointY 가로선(부모~자식 범위)
        double minX = parentBottom.dx, maxX = parentBottom.dx;
        for (final p in childTops) {
          if (p.dx < minX) minX = p.dx;
          if (p.dx > maxX) maxX = p.dx;
        }
        next.add(_Line(Offset(minX, jointY), Offset(maxX, jointY)));
      }
    }

    for (final root in widget.jockBo) {
      collect(root);
    }

    setState(() => _lines = next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jockBo.isEmpty) return const SizedBox.shrink();

    // 전체 노드의 세대 범위
    final all = <JockBoTreeItemInfo>[];
    void flat(JockBoTreeItemInfo n) { all.add(n); for (final c in n.children) flat(c); }
    for (final r in widget.jockBo) flat(r);
    final saeStart = all.map((e) => e.mySae).reduce((a, b) => a < b ? a : b);
    final saeEnd   = all.map((e) => e.mySae).reduce((a, b) => a > b ? a : b);

    // === ‘세(世) 라벨’도 노드와 동일한 규칙으로 쌓이게 만든다 ===
    // 각 세대 블록 높이 = 노드 높이(_nodeHeight)
    // 세대 간 간격 = _levelGap
    List<Widget> _buildSaeColumn() {
      final List<Widget> list = [];
      for (int sae = saeStart; sae <= saeEnd; sae++) {
        // 라벨 박스(노드 높이와 동일)
        list.add(Container(
          width: 40,
          height: _nodeHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ((sae - saeStart).isEven)
                ? const Color(0xFFF8EDE3)
                : const Color(0xFFDFD3C3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('${sae}世'),
        ));
        if (sae != saeEnd) {
          // 세대 간격(노드가 자식으로 내려갈 때 사용하는 간격과 동일)
          list.add(SizedBox(height: _levelGap));
        }
      }
      return list;
    }

    return Stack(
      key: _stackKey,
      children: [
        // 연결선
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _LinePainter(_lines))),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 세(世) 라벨 컬럼 — 노드와 같은 수직 규칙
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildSaeColumn(),
            ),
            const SizedBox(width: 8),
            // 트리
            _buildTree(context, widget.jockBo),
          ],
        ),
      ],
    );
  }

  /// 트리 재귀 빌더 — ‘세대 간 간격’을 **항상 _levelGap으로 통일**
  Widget _buildTree(BuildContext context, List<JockBoTreeItemInfo> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final index = e.key;
        final item  = e.value;
        final key   = _nodeKeys.putIfAbsent(item.id, () => GlobalKey());

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != 0) const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 노드 박스 — 높이를 상수로 고정
                GestureDetector(
                  key: key,
                  onTap: () => widget.onSelect(item.id),
                  child: Container(
                    width: _nodeWidth,
                    height: _nodeHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.id == widget.myId
                          ? const Color(0xFFC55300)
                          : const Color(0xFF815B5B),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x663C2317),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '${item.myName}\n${item.myNamechi}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                // === 부모-자식 간 일정 간격 보장 ===
                if (item.children.isNotEmpty) SizedBox(height: _levelGap),

                if (item.children.isNotEmpty)
                // 자식이 하나면 들여쓰기 0, 여러 명이면 약간 들여쓰기
                  Padding(
                    padding: EdgeInsets.only(left: item.children.length == 1 ? 0 : 16),
                    child: _buildTree(context, item.children),
                  ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
