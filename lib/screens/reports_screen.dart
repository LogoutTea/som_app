import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../managers/cash_manager.dart';
import '../managers/kkm_manager.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  void _closeShift(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _CloseShiftDialog(),
    );
  }

  void _exportReportByDate(BuildContext context) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2020, 1, 1);
    final DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Выберите дату для выгрузки отчета',
      locale: const Locale('ru', 'RU'),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: child!,
      ),
    );

    if (!context.mounted) return;

    if (picked != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _ExportReportDialog(date: picked),
      );
    }
  }

  void _sendXReport(BuildContext context) async {
    final kkmManager = Provider.of<KKMManager>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка X-отчета...')),
    );
    String result;
    try {
      result = await kkmManager.sendXReport();
    } catch (e) {
      result = 'Ошибка отправки X-отчета: $e';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отчеты')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Закрыть смену'),
              onPressed: () => _closeShift(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Выгрузить отчет за дату'),
              onPressed: () => _exportReportByDate(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Снять X-отчет'),
              onPressed: () => _sendXReport(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportReportDialog extends StatefulWidget {
  final DateTime date;
  const _ExportReportDialog({required this.date});

  @override
  State<_ExportReportDialog> createState() => _ExportReportDialogState();
}

class _ExportReportDialogState extends State<_ExportReportDialog> {
  bool _processing = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr =
        '${widget.date.day.toString().padLeft(2, '0')}.${widget.date.month.toString().padLeft(2, '0')}.${widget.date.year}';
    return AlertDialog(
      title: const Text('Выгрузка отчета'),
      content: _processing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Выгрузка отчета...'),
                SizedBox(height: 24),
                CircularProgressIndicator(),
              ],
            )
          : Text('Отчет за $dateStr успешно выгружен.'),
      actions: _processing
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
    );
  }
}

class _CloseShiftDialog extends StatefulWidget {
  const _CloseShiftDialog();

  @override
  State<_CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<_CloseShiftDialog> {
  bool _processing = true;
  double? withdrawnAmount;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cashManager = Provider.of<CashManager>(context, listen: false);
      final amount = cashManager.balance;
      if (amount > 0) {
        cashManager.withdrawCash(amount);
        setState(() {
          withdrawnAmount = amount;
        });
      } else {
        setState(() {
          withdrawnAmount = 0.0;
        });
      }
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Закрытие смены'),
      content: _processing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Смена закрывается...'),
                SizedBox(height: 24),
                CircularProgressIndicator(),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Смена успешно закрыта.'),
                if (withdrawnAmount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Изъято из кассы: ${withdrawnAmount!.toStringAsFixed(2)} руб.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
      actions: _processing
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
    );
  }
}
