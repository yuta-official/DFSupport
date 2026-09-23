import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DFSupportApp());

class DFSupportApp extends StatelessWidget {
  const DFSupportApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DFSupport',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF245B52),
          scaffoldBackgroundColor: const Color(0xFFF7F8F7),
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _channel = MethodChannel('dfsupport/notifications');
  Timer? _timer;
  Map<String, dynamic>? _notice;
  double? _fee, _minutes, _km;
  bool _fromNotification = false;

  final _feeCtl = TextEditingController();
  final _minCtl = TextEditingController();
  final _kmCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshNotification();
    _timer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => _refreshNotification(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feeCtl.dispose();
    _minCtl.dispose();
    _kmCtl.dispose();
    super.dispose();
  }

  Future<void> _refreshNotification() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'getLatestNotification',
      );
      if (!mounted || raw == null) return;
      final next = Map<String, dynamic>.from(raw);
      if (next['timestamp'] == _notice?['timestamp']) return;

      final joined = [
        next['title'],
        next['text'],
        next['bigText'],
        next['textLines'],
      ].whereType<String>().join(' ');

      final parsed = _parse(joined);
      setState(() {
        _notice = next;
        if (parsed.$1 != null || parsed.$2 != null || parsed.$3 != null) {
          _fee = parsed.$1;
          _minutes = parsed.$2;
          _km = parsed.$3;
          _fromNotification = true;
        }
      });
    } catch (_) {}
  }

  (double?, double?, double?) _parse(String source) {
    final s = source.replaceAll(',', '').replaceAll('，', '');
    final feeMatch = RegExp(r'(?:¥|￥)\s*([0-9]+(?:\.[0-9]+)?)')
        .firstMatch(s);
    final minMatch = RegExp(
      r'([0-9]+(?:\.[0-9]+)?)\s*(?:分|mins?|minutes?)',
      caseSensitive: false,
    ).firstMatch(s);
    final kmMatch = RegExp(
      r'([0-9]+(?:\.[0-9]+)?)\s*(?:km|ｋｍ)',
      caseSensitive: false,
    ).firstMatch(s);

    return (
      double.tryParse(feeMatch?.group(1) ?? ''),
      double.tryParse(minMatch?.group(1) ?? ''),
      double.tryParse(kmMatch?.group(1) ?? ''),
    );
  }

  void _manualChanged() {
    setState(() {
      _fee = double.tryParse(_feeCtl.text.replaceAll(',', ''));
      _minutes = double.tryParse(_minCtl.text);
      _km = double.tryParse(_kmCtl.text);
      _fromNotification = false;
    });
  }

  double? get _hourly =>
      (_fee != null && _minutes != null && _minutes! > 0)
          ? _fee! / _minutes! * 60
          : null;
  double? get _perMinute =>
      (_fee != null && _minutes != null && _minutes! > 0)
          ? _fee! / _minutes!
          : null;
  double? get _perKm =>
      (_fee != null && _km != null && _km! > 0) ? _fee! / _km! : null;

  Future<void> _openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationAccess');
    } catch (_) {}
  }

  Widget _metric(String title, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E6E4)),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              FittedBox(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hourly = _hourly == null ? '—' : '¥${_hourly!.round()}/h';
    final perMin = _perMinute == null
        ? '—'
        : '¥${_perMinute!.toStringAsFixed(1)}/分';
    final perKm = _perKm == null ? '—' : '¥${_perKm!.round()}/km';

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DFSupport', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('Delivery Fee Support', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '通知アクセス設定',
            onPressed: _openNotificationSettings,
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              _metric('時間単価', hourly),
              const SizedBox(width: 8),
              _metric('分単価', perMin),
              const SizedBox(width: 8),
              _metric('距離単価', perKm),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _fromNotification ? '通知から自動計算' : '手動入力',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 22),
          const Text(
            'クイック計算',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _feeCtl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _manualChanged(),
                  decoration: const InputDecoration(
                    labelText: '報酬',
                    prefixText: '¥ ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minCtl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _manualChanged(),
                  decoration: const InputDecoration(
                    labelText: '時間',
                    suffixText: '分',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _kmCtl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _manualChanged(),
                  decoration: const InputDecoration(
                    labelText: '距離',
                    suffixText: 'km',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '通知解析テスト',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _openNotificationSettings,
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('通知アクセス'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E6E4)),
            ),
            child: SelectableText(
              _notice == null
                  ? 'まだ通知を取得していません。\n通知アクセスを許可した後、Uber Driverなどで通知を受信すると、ここに取得内容が表示されます。'
                  : 'Package\n${_notice!['packageName'] ?? ''}\n\n'
                      'Title\n${_notice!['title'] ?? ''}\n\n'
                      'Text\n${_notice!['text'] ?? ''}\n\n'
                      'BigText\n${_notice!['bigText'] ?? ''}\n\n'
                      'TextLines\n${_notice!['textLines'] ?? ''}',
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
