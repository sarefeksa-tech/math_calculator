import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MathApp());
}

class MathApp extends StatelessWidget {
  const MathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الآلة الحاسبة الشاملة',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _funcController = TextEditingController(text: "2*x + 3*x");
  final TextEditingController _aController = TextEditingController(text: "3");
  final TextEditingController _bController = TextEditingController(text: "6");
  
  String _funcResult = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _calculateFunction() {
    try {
      String expStr = _funcController.text.replaceAll('×', '*').replaceAll('÷', '/');
      double a = double.parse(_aController.text);
      double b = double.parse(_bController.text);

      GrammarParser p = GrammarParser();
      Expression exp = p.parse(expStr);
      ContextModel cm = ContextModel();

      cm.bindVariable(Variable('x'), Number(a));
      double fa = exp.evaluate(EvaluationType.REAL, cm);

      cm.bindVariable(Variable('x'), Number(b));
      double fb = exp.evaluate(EvaluationType.REAL, cm);

      double avgRate = (fb - fa) / (b - a);

      int n = 1000;
      double h = (b - a) / n;
      double sum = 0.5 * (fa + fb);
      for (int i = 1; i < n; i++) {
        double xi = a + i * h;
        cm.bindVariable(Variable('x'), Number(xi));
        sum += exp.evaluate(EvaluationType.REAL, cm);
      }
      double integral = sum * h;

      setState(() {
        _funcResult = '''
نتائج الدراسة للفترة [$a , $b]:
• f($a) = ${fa.toStringAsFixed(2)}
• f($b) = ${fb.toStringAsFixed(2)}
• متوسط معدل التغير = ${avgRate.toStringAsFixed(2)}
• المساحة (التكامل) ≈ ${integral.toStringAsFixed(2)}
''';
      });
    } catch (e) {
      setState(() {
        _funcResult = "خطأ في صيغة الدالة أو الأرقام! تأكد من استخدام x كمتغير وقيد الضرب بـ * (مثال: 2*x)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الآلة الحاسبة الذكية'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.functions), text: "حساب الدوال ق(س)"),
            Tab(icon: Icon(Icons.calculate), text: "حاسبة بسيطة"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('أدخل الدالة ق(س):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _funcController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'مثال: 2*x + 3*x أو x^2 + 5',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _aController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'بداية الفترة (أ)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _bController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'نهاية الفترة (ب)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculateFunction,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                    child: const Text('احسب النتائج', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Text(
                      _funcResult.isEmpty ? 'ستظهر النتائج هنا...' : _funcResult,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                      textDirection: TextDirection.rtl,
                    ),
                  )
                ],
              ),
            ),
          ),
          const Center(child: Text('حاسبة الأرقام العادية (+، -، ×، ÷)', style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
