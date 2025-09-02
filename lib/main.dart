import 'dart:async';
import 'package:flutter/material.dart';

import 'package:pomodoro_app/widgets/custom_colors.dart';
import 'package:pomodoro_app/widgets/default_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro App',
      theme: ThemeData(
      ),
      home: const Home(title: 'Pomodoro'),
    );
  }
}

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Color bg = CustomColors.primary;
  bool isStart = false;

  int _pomodoroDuration = DefaultTimer.pomodoro;
  int _shortBreakDuration = DefaultTimer.shortBreak;
  int _longBreakDuration = DefaultTimer.longBreak;

  late int _defaultTimer;
  late int _duration;
  Timer? _timer;

  //progress bar
  double _progressValue = 1.0;

  late final TextEditingController textFieldControllerPomodoro;
  late final TextEditingController textFieldControllerShortBreak;
  late final TextEditingController textFieldControllerLongBreak;

  @override
  void initState(){
    super.initState();
    _defaultTimer = _pomodoroDuration;
    _duration = _defaultTimer;

    textFieldControllerPomodoro = TextEditingController(text: (_pomodoroDuration ~/ 60).toString());
    textFieldControllerShortBreak = TextEditingController(text: (_shortBreakDuration ~/ 60).toString());
    textFieldControllerLongBreak = TextEditingController(text: (_longBreakDuration ~/ 60).toString());
  }


  void _start(){
    if (isStart) return;

    setState((){
      _duration--;
      _progressValue = _duration / _defaultTimer;
    });

    isStart = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
      if (_duration > 0){
        setState((){
          _duration--;
          _progressValue = _duration / _defaultTimer;
        });
      }else{
        _stop();
      }
    });
  }

  void _pause(){
    if (_timer != null){
      _timer!.cancel();
      setState((){
        isStart = false;
      });
    }
  }

  void _stop(){
    _timer?.cancel();
    setState((){
      _duration = _defaultTimer;
      isStart = false;
      _progressValue = 1.0;
    });
  }

  String _formatDuration(int seconds){
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesString:$secondsString';
  }

  void _changeTimerType(Color newBg, int newDuration){
    setState((){
      _defaultTimer = newDuration;
    });
    _stop();
    setState((){
      bg = newBg;
      _duration = newDuration;
      isStart = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    textFieldControllerLongBreak.dispose();
    textFieldControllerShortBreak.dispose();
    textFieldControllerPomodoro.dispose();
  }

  void _applySettings() {
     // Ambil dan coba konversi nilai dari TextField
    final pomodoroInput = int.tryParse(textFieldControllerPomodoro.text);
    final shortBreakInput = int.tryParse(textFieldControllerShortBreak.text);
    final longBreakInput = int.tryParse(textFieldControllerLongBreak.text);

    // Cek apakah semua nilai valid
    final bool isPomodoroValid = pomodoroInput != null && pomodoroInput > 0;
    final bool isShortBreakValid = shortBreakInput != null && shortBreakInput > 0;
    final bool isLongBreakValid = longBreakInput != null && longBreakInput > 0;

    // Jika semua input valid, eksekusi aksi
    print(textFieldControllerPomodoro.text);
    print(pomodoroInput);
    print(isPomodoroValid);
    if (isPomodoroValid && isShortBreakValid && isLongBreakValid) {
      setState(() {
        _pomodoroDuration = pomodoroInput * 60;
        _shortBreakDuration = shortBreakInput * 60;
        _longBreakDuration = longBreakInput * 60;

        if (bg == CustomColors.primary){
          _duration = _pomodoroDuration;
          _defaultTimer = _pomodoroDuration;
        } else if (bg == CustomColors.secondary){
          _duration = _shortBreakDuration;
          _defaultTimer = _shortBreakDuration;
        } else {
          _duration = _longBreakDuration;
          _defaultTimer = _longBreakDuration;
        }

      });

      // Tutup modal
    }else{
      textFieldControllerPomodoro.text = (_pomodoroDuration ~/ 60).toString();
      textFieldControllerShortBreak.text = (_shortBreakDuration ~/ 60).toString();
      textFieldControllerLongBreak.text = (_longBreakDuration ~/ 60).toString();
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: bg,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg, // Warna Container
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Warna bayangan yang samar
                      blurRadius: 2, // Seberapa buram bayangan
                    ),
                  ],
                ),
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        )
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Widget yang akan ditampilkan sebagai modal
                              return AlertDialog(
                                title: Center(
                                  child: const Text('SETTING')
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 0.5,               // lebar garis
                                      width: double.infinity,             // tinggi garis
                                      color: Colors.black,     // warna garis
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    const Text('TIMER'),
                                    const Text('Time (minutes)'),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text('Pomodoro',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  // color: Colors.white,
                                                )
                                              ),
                                              const SizedBox(height: 4),
                                              TextField(
                                                controller: textFieldControllerPomodoro,
                                                keyboardType: TextInputType.number,
                                                autofocus: false,
                                                // inputFormatters: [
                                                //   FilteringTextInputFormatter.digitsOnly,
                                                // ],
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                ),
                                                // decoration: const InputDecoration(
                                                //   hintText: 'Enter your task here...',
                                                //   border: InputBorder.none,
                                                // ),
                                              )
                                            ]
                                          )
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text('Short Break',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  // color: Colors.white,
                                                )
                                              ),
                                              const SizedBox(height: 4),
                                              TextField(
                                                controller: textFieldControllerShortBreak,
                                                keyboardType: TextInputType.number,
                                                autofocus: false,
                                                // inputFormatters: [
                                                //   FilteringTextInputFormatter.digitsOnly,
                                                // ],
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                ),
                                                // decoration: const InputDecoration(
                                                //   hintText: 'Enter your task here...',
                                                //   border: InputBorder.none,
                                                // ),
                                              )
                                            ]
                                          )
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text('Long Break', 
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  // color: Colors.white,
                                                )
                                              ),
                                              const SizedBox(height: 4),
                                              TextField(
                                                controller: textFieldControllerLongBreak,
                                                keyboardType: TextInputType.number,
                                                autofocus: false,
                                                // inputFormatters: [
                                                //   FilteringTextInputFormatter.digitsOnly,
                                                // ],
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                ),
                                                // decoration: const InputDecoration(
                                                //   hintText: 'Enter your task here...',
                                                //   border: InputBorder.none,
                                                // ),
                                              )
                                            ]
                                          )
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Auto Start Breaks')
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Auto Start Pomodoros')
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text('Long Break Interval')
                                      ],
                                    ),
                                  ]
                                ),
                                actions: <Widget>[
                                  // Tombol "Batal"
                                  TextButton(
                                    child: const Text('Batal'),
                                    onPressed: () {
                                      // Perintah untuk menutup modal tanpa melakukan aksi
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  // Tombol "Terapkan"
                                  TextButton(
                                    child: const Text('Terapkan'),
                                    onPressed: _applySettings,
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      )
                    ]
                  )
                )
              ),
              Expanded(
                // child: Container(
                //   width: double.infinity,
                //   color: bg,
                child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.0), // Mengatur radius sudut
                        ),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 3,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FilledButton(
                                  onPressed: (){
                                    _changeTimerType(CustomColors.primary, _pomodoroDuration);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(bg == CustomColors.primary ? CustomColors.primary.withOpacity(0.8) : Colors.transparent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0)
                                      )
                                    )
                                  ),
                                  child: const Text('Pomodoro', 
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                    )
                                  )
                                ),
                                FilledButton(
                                  onPressed: (){
                                    _changeTimerType(CustomColors.secondary, _shortBreakDuration);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(bg == CustomColors.secondary ? CustomColors.secondary.withOpacity(0.8) : Colors.transparent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0)
                                      )
                                    )
                                  ),
                                  child: const Text('Short Break', 
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                    )
                                  )
                                ),
                                FilledButton(
                                  onPressed: (){
                                    _changeTimerType(CustomColors.accent, _longBreakDuration);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(bg == CustomColors.accent ? CustomColors.accent.withOpacity(0.8) : Colors.transparent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0)
                                      )
                                    )
                                  ),
                                  child: const Text('Long Break', 
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                    )
                                  )
                                ),
                              ]
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(
                                fontSize: 72.0,
                                color: Colors.white,
                              )
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (isStart)
                                  FilledButton(
                                    onPressed: _stop,                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0)
                                        )
                                      )
                                    ),
                                    child: Text('Stop', 
                                      style: TextStyle(
                                        // fontSize: 10.0,
                                        color: bg,
                                      )
                                    )
                                  )
                                else SizedBox.shrink(),
                                if (!isStart)
                                  FilledButton(
                                    onPressed: _start,                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0)
                                        )
                                      )
                                    ),
                                    child: Text('Start', 
                                      style: TextStyle(
                                        // fontSize: 10.0,
                                        color: bg,
                                      )
                                    )
                                  )
                                else SizedBox.shrink(),
                                if (isStart)
                                  FilledButton(
                                    onPressed: _pause,                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0)
                                        )
                                      )
                                    ),
                                    child: Text('Pause', 
                                      style: TextStyle(
                                        // fontSize: 10.0,
                                        color: bg,
                                      )
                                    )
                                  )
                                else SizedBox.shrink(),
                              ]
                            )
                          ]
                        )
                      )
                    ) 
                  )
              ),
              Container(
                height: 40,
                color: bg,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: LinearProgressIndicator(
                      value: _progressValue, backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  )
                )
              )
            ]
          )
        ),
      )
    );
  }
}

// Widget _buildModeButton(String text, Color color) {
//   bool isActive = _currentBackgroundColor == color;
//   return FilledButton(
//     onPressed: () {
//       setState(() {
//         _currentBackgroundColor = color;
//       });
//     },
//     style: ButtonStyle(
//       backgroundColor: MaterialStateProperty.all(isActive ? Colors.white : Colors.transparent),
//       shape: MaterialStateProperty.all(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           side: BorderSide(color: Colors.white, width: isActive ? 0 : 1),
//         ),
//       ),
//     ),
//     child: Text(
//       text,
//       style: TextStyle(
//         fontSize: 10.0,
//         color: isActive ? color : Colors.white,
//       ),
//     ),
//   );
// }
