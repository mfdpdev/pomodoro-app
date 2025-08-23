import 'package:flutter/material.dart';

import 'package:pomodoro_app/widgets/custom_colors.dart';

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

class Home extends StatelessWidget {

  final String title;

  const Home({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: CustomColors.primary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                )
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: (){

                }
              )
            ]
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: CustomColors.primary,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 3,
                      color: CustomColors.primary,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FilledButton(
                                onPressed: null,
                                style: ButtonStyle(
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
                                onPressed: null,
                                style: ButtonStyle(
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
                                onPressed: null,
                                style: ButtonStyle(
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
                          const Text(
                            '25:00',
                            style: TextStyle(
                              fontSize: 72.0,
                              color: Colors.white,
                            )
                          ),
                          FilledButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)
                                )
                              )
                            ),
                            child: const Text('Start', 
                              style: TextStyle(
                                // fontSize: 10.0,
                                color: CustomColors.primary,
                              )
                            )
                          )
                        ]
                      )
                    )
                  ) 
                )
              )
            ),
            Text('Test')
          ]
        ),
      )
    );
  }
}
