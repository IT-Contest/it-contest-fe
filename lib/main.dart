import 'package:flutter/material.dart';
import 'features/auth/view/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 이 위젯은 애플리케이션의 루트입니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 애플리케이션의 테마입니다.
        // 시도해보세요: "flutter run"으로 애플리케이션을 실행해보세요. 보라색 툴바가 보일 것입니다. 앱을 종료하지 않고 아래 colorScheme의 seedColor를 Colors.green으로 바꾼 후 "hot reload"(저장 또는 IDE의 hot reload 버튼, 또는 커맨드라인에서 r)를 해보세요
        // 카운터가 0으로 초기화되지 않은 것을 확인할 수 있습니다. 애플리케이션 상태는 reload 중에도 유지됩니다. 상태를 초기화하려면 hot restart를 사용하세요.
        // 값뿐만 아니라 코드도 마찬가지입니다. 대부분의 코드 변경은 hot reload로 테스트할 수 있습니다.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/auth': (context) => const LoginScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 이 위젯은 애플리케이션의 홈 화면입니다. 상태를 가지므로 State 객체(아래에 정의됨)가 있으며, 이 객체의 필드는 화면에 영향을 줍니다.

  // 이 클래스는 상태에 대한 설정을 담당합니다. 부모(여기서는 App 위젯)로부터 전달받은 값(여기서는 title)을 보관하며, State의 build 메서드에서 사용됩니다. 위젯의 필드는 항상 "final"로 표시됩니다.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // setState를 호출하면 Flutter 프레임워크에 상태가 변경되었음을 알립니다. 이로 인해 아래 build 메서드가 다시 실행되어 화면이 갱신됩니다. 만약 setState 없이 _counter만 변경하면 build가 다시 호출되지 않아 화면에 변화가 없습니다.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // setState가 호출될 때마다 이 메서드가 다시 실행됩니다. (예: 위의 _incrementCounter 메서드에서)
    //
    // Flutter 프레임워크는 build 메서드의 재실행이 빠르게 동작하도록 최적화되어 있습니다. 따라서 변경이 필요한 부분만 다시 그릴 수 있습니다.
    return Scaffold(
      appBar: AppBar(
        // 시도해보세요: 여기 색상을 특정 색상(예: Colors.amber)으로 바꾼 후 hot reload를 해보세요. AppBar만 색이 바뀌고, 다른 색상은 그대로입니다.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // App.build 메서드에서 생성된 MyHomePage 객체의 값을 사용해 appbar의 제목을 설정합니다.
        title: Text(widget.title),
      ),
      body: Center(
        // Center는 레이아웃 위젯입니다. 하나의 child를 받아 부모의 중앙에 배치합니다.
        child: Column(
          // Column도 레이아웃 위젯입니다. 여러 child를 받아 세로로 배치합니다. 기본적으로 자식의 가로 크기에 맞추고, 부모의 높이에 맞추려 합니다.
          //
          // Column에는 크기와 정렬을 제어하는 다양한 속성이 있습니다. 여기서는 mainAxisAlignment로 자식들을 세로축 중앙에 배치합니다. (Column의 주축은 세로, 교차축은 가로)
          //
          // 시도해보세요: "debug painting"(IDE에서 Toggle Debug Paint 또는 콘솔에서 p)을 실행해 각 위젯의 와이어프레임을 확인해보세요.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/auth');
              },
              child: const Text('로그인 화면으로 이동'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // 이 쉼표는 build 메서드의 자동 포매팅을 더 보기 좋게 만듭니다.
    );
  }
}
