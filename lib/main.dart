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

  int _defaultTimer = DefaultTimer.pomodoro;
  int _duration = DefaultTimer.pomodoro;
  Timer? _timer;

  void _start(){
    if (isStart) return;

    setState((){
      _duration--;
    });

    isStart = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
      if (_duration > 0){
        setState((){
          _duration--;
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
                                      children: [],
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
                                    onPressed: () {
                                      // Aksi yang akan dijalankan saat tombol "Terapkan" diklik
                                      // Misalnya, menyimpan data ke variabel atau database
                                      print('Perubahan diterapkan!');
                                      
                                      // Tutup modal setelah aksi selesai
                                      Navigator.of(context).pop();
                                    },
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
                                    _changeTimerType(CustomColors.primary, DefaultTimer.pomodoro);
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
                                    _changeTimerType(CustomColors.secondary, DefaultTimer.shortBreak);
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
                                    _changeTimerType(CustomColors.accent, DefaultTimer.longBreak);
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
                color: CustomColors.primary,
                child: Center(
                  child: const Text('Hello world')
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
