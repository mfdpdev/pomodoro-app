import 'dart:async';
import 'package:flutter/material.dart';

import 'package:pomodoro_app/widgets/custom_colors.dart';
import 'package:pomodoro_app/widgets/default_timer.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi pengaturan platform
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // Ganti 'app_icon' dengan nama ikon Anda
  final iosSettings = DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: iosSettings
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  final bool onboardingSeen = false;

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro App',
      theme: ThemeData(
      ),
      home: onboardingSeen ? Home(title: 'Pomodoro') : OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>{

  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index){
              setState((){
                isLastPage = (index == 2);
              });
            },
            children: [
               IntroPage(
                title: 'Welcome to FocusFlow',
                description: 'Boost your productivity using the proven Pomodoro Technique. Stay focused, take, breaks, and get more done.',
                // imagePath: 'assets/images/intro1.png',
              ),
              IntroPage(
                title: 'Work Smarter, Not Harder',
                description: 'Break your tasks into 25-minute focus sessions with short breaks in between. Say goodbye to burnout and distractions.',
                // imagePath: 'assets/images/intro2.png',
              ),
              IntroPage(
                title: 'Track Your Progress',
                description: 'Monitor your work sessions, set daily goals, and build better habits over time.',
                // imagePath: 'assets/images/intro3.png',
              ),
            ]
          ),
          Container(
            alignment: const Alignment(0.0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    // _controller.jumpToPage(2);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Home(title: 'Pomodoro'),
                      )
                    );
                  },
                  child: const Text('Skip')
                ),

                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const WormEffect(
                    activeDotColor: Colors.blue,
                    dotColor: Colors.grey,
                  ),
                ),

                isLastPage ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Home(title: 'Pomodoro'),
                      )
                    );
                  },
                  child: const Text('Done')
                ) : GestureDetector(
                  onTap: (){
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: const Text('Next')
                )
              ]
            )
          )  
        ]
      )
    );
  }
}

class IntroPage extends StatelessWidget {
  final String title;
  final String description;
  // final String imagePath;
  
  const IntroPage({
    super.key,
    required this.title,
    required this.description,
    // required this.imagePath,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image.asset(imagePath, height: 200),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(description, textAlign: TextAlign.center),
      ]
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

  int pomodoroCounter = 0;

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
        _showNotification();

        if(pomodoroCounter <= 3){
          if(bg == CustomColors.primary){
            pomodoroCounter++;

            if(pomodoroCounter > 3){
              _changeTimerType(CustomColors.accent, _longBreakDuration);
            }else{
              //ke short break
              _changeTimerType(CustomColors.secondary, _shortBreakDuration);
            }
          }else{
            //ke pomodoro
            _changeTimerType(CustomColors.primary, _pomodoroDuration);
          }
        }else{
          if(bg != CustomColors.primary){
            pomodoroCounter = 0;
            //ke pomodoro
            _changeTimerType(CustomColors.primary, _pomodoroDuration);
          }

        }
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

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timer_channel_id', // ID unik
      'Timer Notifications', // Nama channel
      channelDescription: 'Channel for timer end notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosDetails
    );
    
    // Menampilkan notifikasi
    await flutterLocalNotificationsPlugin.show(
      0, // ID notifikasi unik
      'Waktu Selesai!',
      'Timer Anda telah berakhir.',
      platformChannelSpecifics,
      payload: 'timer_ended',
    );
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
                height: 60,
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
                                  child: const Text('SETTING',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    )
                                  )
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 0.5,               // lebar garis
                                      width: double.infinity,             // tinggi garis
                                      color: Colors.black,     // warna garis
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('TIMER',
                                      // style: TextStyle(
                                      //   fontWeight: FontWeight.bold,
                                      // )
                                    ),
                                    const SizedBox(height: 5),
                                    const Text('Time (minutes)',
                                      // style: TextStyle(
                                      //   fontWeight: FontWeight.bold,
                                      // )
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: bg,
                                                    )
                                                  )
                                                ),
                                                cursorColor: bg,
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: bg,
                                                    )
                                                  )
                                                ),
                                                cursorColor: bg,
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: bg,
                                                    )
                                                  )
                                                ),
                                                cursorColor: bg,
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
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        const Text('Auto Start Breaks',
                                          // style: TextStyle(
                                          //   fontWeight: FontWeight.bold,
                                          // )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Text('Auto Start Pomodoros',
                                          // style: TextStyle(
                                          //   fontWeight: FontWeight.bold,
                                          // )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Text('Long Break Interval',
                                          // style: TextStyle(
                                          //   fontWeight: FontWeight.bold,
                                          // )
                                        )
                                      ],
                                    ),
                                  ]
                                ),
                                actions: <Widget>[
                                  // Tombol "Batal"
                                  TextButton(
                                    child: const Text('Batal'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: bg, // Mengubah warna teks tombol OK
                                    ),
                                    onPressed: () {
                                      // Perintah untuk menutup modal tanpa melakukan aksi
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  // Tombol "Terapkan"
                                  TextButton(
                                    child: const Text('Terapkan'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: bg, // Mengubah warna teks tombol OK
                                    ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
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
                                        ),
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                                        )
                                      ),
                                      child: const Text('Pomodoro', 
                                        style: TextStyle(
                                          fontSize: 12.0,
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
                                        ),
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                                        )
                                      ),
                                      child: const Text('Short Break', 
                                        style: TextStyle(
                                          fontSize: 12.0,
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
                                        ),
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                                        )
                                      ),
                                      child: const Text('Long Break', 
                                        style: TextStyle(
                                          fontSize: 12.0,
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
                        ),
                        const SizedBox(height: 10),
                        Text(bg == CustomColors.primary ? "Time to focus!" : "Time for a break!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          )
                        )
                      ]
                    ),
                    Container(
                      height: 40,
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
