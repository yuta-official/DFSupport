import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DFSupportApp());

class DFSupportApp extends StatelessWidget {
  const DFSupportApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'DFSupport',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const channel = MethodChannel('dfsupport/notifications');
  List<dynamic> rows = [];
  String status = '待機中';

  Future<void> refresh() async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>('getNotifications') ?? [];
      if (!mounted) return;
      setState(() {
        rows = result.reversed.toList();
        status = '取得 ${result.length}件';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => status = '取得エラー: $error');
    }
  }

  Future<void> openSettings() async {
    try {
      await channel.invokeMethod<void>('openNotificationAccess');
    } catch (error) {
      if (!mounted) return;
      setState(() => status = '設定エラー: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DFSupport')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('通知取得デバッグ', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(status),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton(onPressed: refresh, child: const Text('通知履歴を更新'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: openSettings, child: const Text('通知アクセス設定'))),
          ]),
          const SizedBox(height: 12),
          const Text('案件が届いた直後に通知履歴を更新してください。ほかのアプリの通知も表示して動作を確認します。'),
          const Divider(height: 24),
          Expanded(
            child: rows.isEmpty
              ? const Center(child: Text('取得した通知はまだありません'))
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final item = Map<dynamic, dynamic>.from(rows[index] as Map);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          "アプリ: ${item['package'] ?? ''}\n"
                          "タイトル: ${item['title'] ?? ''}\n"
                          "本文: ${item['text'] ?? ''}\n"
                          "追加テキスト: ${item['bigText'] ?? ''}\n"
                          "時刻: ${item['time'] ?? ''}",
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    ),
  );
}
