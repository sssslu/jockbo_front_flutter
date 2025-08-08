import 'package:flutter/material.dart';
import '../models.dart';

const Color _connectorColor = Color(0xFF3C2317);
const double _connectorStrokeWidth = 3;


/// 부모‑자식 또는 형제 사이의 선을 그리기 위한 단순 구조체
class _Line {
  final Offset start;
  final Offset end;
  const _Line(this.start, this.end);
}

/// 커스텀 페인터: 선들을 그립니다.
class _LinePainter extends CustomPainter {
  final List<_Line> lines;
  _LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _connectorColor // 진한 갈색 (원본과 유사)
      ..strokeWidth = _connectorStrokeWidth;
    for (final line in lines) {
      canvas.drawLine(line.start, line.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    // 선 목록이 바뀌었는지 비교해 불필요한 리페인트를 막습니다.
    if (identical(lines, oldDelegate.lines)) return false;
    if (lines.length != oldDelegate.lines.length) return true;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].start != oldDelegate.lines[i].start ||
          lines[i].end != oldDelegate.lines[i].end) return true;
    }
    return false;
  }
}

/// 족보 트리를 그리는 StatefulWidget.
/// 세(世) 컬럼과 노드를 렌더링하고, 커스텀 페인터로 연결선까지 그립니다.
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
  // 각 노드를 식별하기 위한 키입니다. 선의 위치를 계산할 때 사용합니다.
  final Map<int, GlobalKey> _nodeKeys = {};
  // 루트 Stack에 부여되는 키 (글로벌 좌표 변환을 위해 필요)
  final GlobalKey _stackKey = GlobalKey();
  // 계산된 선 목록
  List<_Line> _lines = [];

  @override
  void initState() {
    super.initState();
    // 첫 프레임이 끝난 후에 선을 한 번 계산합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLines());
  }

  @override
  void didUpdateWidget(covariant JockBoTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 데이터가 변경될 때마다 선을 다시 계산합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLines());
  }

  /// 각 노드의 화면 상 위치를 계산하여 부모‑자식, 형제 간 연결선을 만듭니다.
  void _updateLines() {
    final RenderBox? stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    final List<_Line> newLines = [];

    void collectLines(JockBoTreeItemInfo node) {
      // 부모 노드의 위치 (하단 중앙)
      final parentKey = _nodeKeys[node.id];
      final parentContext = parentKey?.currentContext;
      final parentBox = parentContext?.findRenderObject() as RenderBox?;
      Offset? parentBottom;
      if (parentBox != null) {
        final parentOffset = parentBox.localToGlobal(Offset.zero, ancestor: stackBox);
        parentBottom = parentOffset + Offset(parentBox.size.width / 2, parentBox.size.height);
      }

      // 자식들의 상단 중앙 좌표를 수집
      final List<Offset> childTopPositions = [];
      for (final child in node.children) {
        final childKey = _nodeKeys[child.id];
        final childContext = childKey?.currentContext;
        final childBox = childContext?.findRenderObject() as RenderBox?;
        if (childBox != null) {
          final childOffset = childBox.localToGlobal(Offset.zero, ancestor: stackBox);
          final childTop = childOffset + Offset(childBox.size.width / 2, 0);
          childTopPositions.add(childTop);
          // 재귀 처리
          collectLines(child);
        }
      }

      // 부모와 자식 사이에 선을 그립니다.
      if (parentBottom != null && childTopPositions.isNotEmpty) {
        // 자식들의 Y 좌표는 모두 동일합니다. 이를 기준으로 가로선 높이를 정합니다.
        final double jointY = childTopPositions[0].dy;
        // 1) 부모에서 수평선까지 수직선
        newLines.add(_Line(
          parentBottom,
          Offset(parentBottom.dx, jointY),
        ));
        // 2) 부모와 모든 자식을 포함하는 가로선
        double minX = parentBottom.dx;
        double maxX = parentBottom.dx;
        for (final pos in childTopPositions) {
          if (pos.dx < minX) minX = pos.dx;
          if (pos.dx > maxX) maxX = pos.dx;
        }
        newLines.add(_Line(
          Offset(minX, jointY),
          Offset(maxX, jointY),
        ));
        // 자식의 상단까지 내려가는 세로선은 jointY와 자식 Y좌표가 동일하므로 필요하지 않습니다.
      }
    }

    // 루트부터 재귀적으로 선을 계산
    for (final node in widget.jockBo) {
      collectLines(node);
    }

    setState(() {
      _lines = newLines;
    });
  }


  @override
  Widget build(BuildContext context) {
    // 데이터가 없으면 아무것도 그리지 않습니다.
    if (widget.jockBo.isEmpty) {
      return const SizedBox.shrink();
    }
    // 세(世) 범위를 계산합니다.
    final allNodes = <JockBoTreeItemInfo>[];
    void collectNodes(JockBoTreeItemInfo node) {
      allNodes.add(node);
      for (final child in node.children) {
        collectNodes(child);
      }
    }
    for (final node in widget.jockBo) {
      collectNodes(node);
    }
    final int saeStart =
    allNodes.map((e) => e.mySae).reduce((a, b) => a < b ? a : b);
    final int saeEnd =
    allNodes.map((e) => e.mySae).reduce((a, b) => a > b ? a : b);

    return Stack(
      key: _stackKey,
      children: [
        // 선을 먼저 그립니다.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _LinePainter(_lines),
            ),
          ),
        ),
        // 그 위에 세(世) 라벨과 노드를 그립니다.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 세(世) 라벨 컬럼
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                saeEnd - saeStart + 1,
                    (index) {
                  final sae = saeStart + index;
                  return Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? const Color(0xFFF8EDE3) // 밝은 베이지
                          : const Color(0xFFDFD3C3), // 어두운 베이지
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${sae}世'),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // 실제 트리 구조
            _buildTreeWithKeys(context, widget.jockBo),
          ],
        ),
      ],
    );
  }

  /// 노드와 자식들을 그리는 재귀 함수.
  /// 각 노드에는 고유한 [GlobalKey]를 할당해 위치를 계산합니다.
  Widget _buildTreeWithKeys(BuildContext context, List<JockBoTreeItemInfo> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final key = _nodeKeys.putIfAbsent(item.id, () => GlobalKey());
        // 형제 사이 간격을 위해 노드 사이에만 SizedBox 추가
        final horizontalSpacing =
        index == 0 ? const SizedBox.shrink() : const SizedBox(width: 8);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            horizontalSpacing,
            // 상하 간격만 두고 좌우는 0으로
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    key: key,
                    onTap: () => widget.onSelect(item.id),
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
                  if (item.children.isNotEmpty)
                    Container(
                      width: 64,
                      height: 16,
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: _connectorStrokeWidth,
                        height: 16,
                        color: _connectorColor,
                      ),
                    ),
                  if (item.children.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        // 자식이 하나일 때는 왼쪽 들여쓰기 없애고, 여러 명일 때는 16
                        left: item.children.length == 1 ? 0.0 : 16.0,
                        top: 8,
                      ),
                      child: _buildTreeWithKeys(context, item.children),
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

}
