// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Restaurant/Eat&Drink.dart';
import 'package:ongolf_tech_mamagement_system/constants/strings.dart';
import 'package:ongolf_tech_mamagement_system/manage%20players/player_profile.dart';
import 'package:ongolf_tech_mamagement_system/Club/clubSignUp.dart';
import 'package:ongolf_tech_mamagement_system/homePage.dart';
import 'package:ongolf_tech_mamagement_system/manage%20players/manage%20players.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ongolf_tech_mamagement_system/community/Community.dart';
import 'package:ongolf_tech_mamagement_system/widgets/responsive_widget.dart';
import 'constants/text_styles.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/second': (context) => const ClubSignUp(),
        '/NavToHomePage': (context) => const MyHomePage1(),
        '/PlayerManagement': (context) => const PlayerManagement(),
        '/Community': (context) => const Community(),
        '/FoodAndDrinks': (context) {
          final currentUser = FirebaseAuth.instance.currentUser;
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('clubs').doc(currentUser!.uid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final clubName = snapshot.data!['Club Name'] as String;
              return EatAndDrink(
                clubName: clubName,
              );
            },
          );
        },
        '/playerProfile': (context) {
          final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return playerProfile(
            userName: args?['userName'] ?? '',
            handicap: args?['handicap'] ?? 0,
            profileImageUrl: args?['profileImageUrl'] ?? '',
            homeClub: args?['homeClub'] ?? '',
            playerFullName: args?['playerFullName'] ?? '',
          );
        },
      },
      title: 'Club Management System',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;
  final double _scrollIncrement = 1.0;
  final choiceController = TextEditingController();
  final bodyController = TextEditingController();
  final emailController1= TextEditingController();
   final emailController2= TextEditingController();
  final passwordController1= TextEditingController();



List<String> interestList = ["General",'Inquiry', 'Inverstment', 'Collaboration', 'Partnership', 'Sponsorship'];
  String interest = 'General';
    Widget buildDropdownContainer({
  required String label,
  required String value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  return Container(
    margin: const EdgeInsets.only(left: 8, right: 8),
    width: 375,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}


   String body = 'No Body';
   //body = bodyController;

    Future<int> storeInterests(String body, String senderEmail, String lineOfInterest) async {
  CollectionReference interests = FirebaseFirestore.instance.collection('Interests');
  
  if(body.isNotEmpty && senderEmail.isNotEmpty ){
    try {
    await interests.add({
      'body': body,
      'senderEmail': senderEmail,
      'lineOfInterest': lineOfInterest,
    });
    return 1; // Successfully stored
  } catch (e) {
    print('Error storing interests: $e');
    return 0; // Failed to store
  }
  }
  else return 101;
}

//build popup dialog
void showResultDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Aknowledgemet."),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      _scrollPosition += _scrollIncrement;
      if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
        _scrollPosition = 0.0;
      }
      _scrollController.animateTo(
        _scrollPosition,
        duration: const Duration(milliseconds: 16),
        curve: Curves.linear,
      );
    });
  }




  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    


    Future<void> signUserIn() async {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController2.text.trim(),
          password: passwordController1.text.trim(),
        );
        Navigator.of(context).pop();
        Navigator.pushNamed(context, '/NavToHomePage');
      } catch (e) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sign-in error'),
              content: Text(e.toString()),
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body:SingleChildScrollView(
            child: Column(
              children: [
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Row(
                        children: List.generate(skillImages.length, (index) {
                          return imagesContainer(index);
                        }),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: Container(
                          height: 70,
                          width: 150,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                            image: DecorationImage(
                              image: AssetImage('assets/Logo1.png'),
                              scale: 0.1,
                            ),
                          ),
                        ),
                      ),
                      !ResponsiveWidget.isSmallScreen(context) ? _buildTitle() : Container(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ResponsiveWidget.isSmallScreen(context) ? Center(child: _buildTitle()) : Container(),
              aboutUsContainerBuilder(),
               !ResponsiveWidget.isSmallScreen(context) ? buildLargScreenBody(emailController, passwordController, signUserIn) : buildSmallScreenBody(emailController, passwordController, signUserIn),
              buildFooter(),
            ],
            ),
        ),
    );
  }

   Column buildSmallScreenBody(TextEditingController emailController, TextEditingController passwordController, Future<void> signUserIn()) {
    return Column(
            children: [
              Center(child: buildLoginContainer(emailController, passwordController, signUserIn)),
            const SizedBox(height: 20),
           buildNoteBox(emailController, passwordController, signUserIn),
            ],
          );
  }

  Row buildLargScreenBody(TextEditingController emailController, TextEditingController passwordController, Future<void> signUserIn()) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(child: buildLoginContainer(emailController, passwordController, signUserIn)),
                        Center(child: buildNoteBox(emailController, passwordController, signUserIn)),
                       const SizedBox(height: 580,)
                      ],
                    ),
                  ],
                          
              );
  }



  Center buildNoteBox(TextEditingController emailController, TextEditingController passwordController, Future<void> signUserIn()) {
    return Center(
             child: Container(
                   margin: const EdgeInsets.all(28),
                height: 795,
                width: 220*1.6,
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
               height: 220,
              // width: 300,
              padding: EdgeInsets.all(4),
                margin: const EdgeInsets.only(bottom: 8,),
                decoration:  BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadiusDirectional.only(
                   // bottomEnd: Radius.circular(8),
                    topStart: Radius.circular(8),
                    topEnd: Radius.circular(8),
                    // bottomStart: Radius.circular(8),
                  ),
                  image: const DecorationImage(
                    image:  AssetImage('assets/op2.jpg',
                    ),
                    fit: BoxFit.cover,
                    scale: 0.5,
                    ) 
                ),
                ),
                const SizedBox(height: 10 ),
              //welcome back, you've been missed!
              Text('Leave us a note bellow.',
                style: TextStyle(color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
      buildDropdownContainer(
        label: '  Line of Interest:',
        value: interest,
        items: interestList,
        onChanged: (newValue) {
          setState(() {
            interest = newValue!;
          });
        },
      ),
                const SizedBox(height: 10 ),
                //email textfeild
                
                Container(
                   width: 400,

                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 10.8),
                     child: TextField(
                       keyboardType: TextInputType.emailAddress,
                       maxLines: 1,
                       controller: emailController1,
                         obscureText: false,
                         decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Email.....',
              hintStyle: TextStyle(color: Colors.grey[500] ) 
                         )
                     ),
                   ),
                 ),
                const SizedBox(height: 10 ),
                         
              //passord text field
                
             
                Container(
                   width: 400,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 10.8),
                     child: TextField(
                       keyboardType: TextInputType.text,
                       maxLines: 10,
                       controller: bodyController,
                         obscureText: false,
                         decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Typing area.....',
              hintStyle: TextStyle(color: Colors.grey[500] ) 
                         )
                     ),
                   ),
                 ),
                         
              //forget password
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Thank you for submitting. \n We will contact you soon.', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue, fontSize: 16,),
                    ),
                  ],
                ),
              ),
                     
              // sign in buttom
             GestureDetector(
              onTap: signUserIn,
               child: Container(
                margin: const EdgeInsets.all(8),
                 child: MyButton(
                    onTap: () async {
    int result = await storeInterests(bodyController.text, emailController1.text, interest);
    if (result == 1) {
      showResultDialog(context, "Succes. We will get back to you at the earliest.",);
    } else if (result == 0) {
      showResultDialog(context, "Failed. Please try again.");
    }else {
      showResultDialog(context, "Failed. Please fill all areas.");
    }
  },
                    text: 'SUBMIT',
                  ),
               ),
             ),
                  ],
                ),
               ),
           );
  }


  Stack buildFooter() {
    return Stack(
                  children: [
                    Container(
                      height: 120-35,
                      width: MediaQuery.of(context).size.width,
                      decoration:const BoxDecoration(
                        color: Colors.black,
                      ),
                      
                    ),
                    Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //const SizedBox(height: 1,),
                            Row(
                              children: [
                                Container(
                                   height: 118-37,
                                   width: 180,
                                   decoration: const BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.only(
                                       bottomRight: Radius.circular(50),
                                       topRight: Radius.circular(50)
                                     ),
                                     image: DecorationImage(
                                       image:  AssetImage(
                                         'assets/Logo1.png'
                                       ),
                                       //fit: BoxFit.cover,
                                       scale: 0.1
                                     ),
                                   ),
                                 ),
                                 SizedBox(width: MediaQuery.of(context).size.width-360,),
                              Column(
                                children: [
                                  const SizedBox(height: 1,),
                                  Row(
                                    children: [
                                 GestureDetector(
        onTap: () {
        },
        child: Image.asset(
          'assets/email.png',
          color: Colors.white,
          height: 25.0,
          width: 25.0,
        ),
      ),const SizedBox(width: 4,),
          GestureDetector(
        onTap: () {
          /*html.window
             .open("", "Mobile");*/
        },
        child: Image.asset(
          'assets/WhatsApp.png',
          color: Colors.white,
          height: 25.0,
          width: 25.0,
        ),
      ),const SizedBox(width: 4,),
                                 GestureDetector(
        onTap: () {
          /*html.window.open("https://www.linkedin.com/in/tangeni-matheus", "LinkedIn");*/
        },
        child: Image.asset(
          'assets/LinkedIn.png',
          color: Colors.white,
          height: 25.0,
          width: 25.0,
        ),
      ),const SizedBox(width: 4,),
      GestureDetector(
        onTap: () {
        /*html.window.open("https://www.instagram.com/ongolftech?igsh=YTQwZjQ0NmI0OA==", "Instagram");*/
        },
        child: Image.asset(
          'assets/Instagram.png',
          color: Colors.white,
          height: 25.0,
          width: 25.0,
        ),
      ),
                                    ]
                                  ),
                                  const Text("  |  All rights reserved ©\n  |  ongolftech@gmail.com \n  | +264 81 8031 157 ",
                             style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500
                             ),
                             ),
                                ]
                              )
                              ],
                            ),
                             
                          ],
                        ),
                      ],
                    ),
                  ],
                );
  }

  Container aboutUsContainerBuilder() {
    return Container(
      width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text("About Us", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text("Streamline your golfing world with our all-in-one Namibian platform, integrating mobile and desktop applications for cutting edge techological solutions.\n"
                      ,style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300), textAlign: TextAlign.center,
                      ),
                      Divider(),
                      Text("Mission",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Our mission is to provide sustainable IT solutions for Namibia’s golfing industry. We focus on communication, a unified handicap system, and a club mangement system that works for all clubs in Namibia, via a community-driven innovation to enhance the Namibian golfing ecosystem.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400), textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Text("Vision:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Our vision is to unite Namibia's golfing community, creating an efficient and cohesive ecosystem. By integrating all aspects into a single unit, we aim to enhance the golfing experience and promote sport development across the country.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400), textAlign: TextAlign.center,
                    ),
                     Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    Column(
                      children: [
                        Image(image: AssetImage('assets/unity.png'),height: 70,),
                        Text("Unify",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
                    ),
                      ],
                    ),
                    Column(
                      children: [
                        Image(image: AssetImage('assets/promote.png',),height: 135),
                        Text("Promote",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
                    ),
                      ],
                    ),
                    Column(
                      children: [
                        Image(image: AssetImage('assets/growth.png'),height: 80),
                        Text("Sustainable\n Growth",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
                    ),
                      ],
                    )
                    ],
                    ),
                    Divider(),
                    Text("We are open for:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                   
                    Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    Column(
                      children: [
                        Image(image: AssetImage('assets/collaboration.png'),height: 100,),
                        Text(" Collaboration",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
                    ),
                      ],
                    ),
                    Column(
                      children: [
                        Image(image: AssetImage('assets/inverstment.png',),height: 100),
                        Text("Inverstment",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
                    ),
                      ],
                    ),
                    Column(
                      children: [
                        Image(image: AssetImage('assets/Partner.png'),height: 100),
                        Text("Partnership",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
                    ),
                      ],
                    )
                    ],
                    ),
                    Divider(),
                    ],
                  ),
                 );
  }

  Container buildLoginContainer(TextEditingController emailController, TextEditingController passwordController, Future<void> Function() signUserIn) {
    return Container(
      margin: const EdgeInsets.all(28),
                height: 800,
                width: 352,
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const SizedBox(height:10),
                    Container(
                      height:150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusDirectional.circular(10)
                      ),
                      child: 
                    Image(image: AssetImage('assets/Logo1.png',
                    ),height: 140, ),),
                const SizedBox(height: 10 ),
              //welcome back, you've been missed!
              Text('Welcome to your all in one platform.',
                style: TextStyle(color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
                const SizedBox(height: 50/2.5 ),
                //username text feild
                
                Container(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.8),
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          controller: emailController2,
            obscureText: false,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Email.....',
              hintStyle: TextStyle(color: Colors.grey[500] ) 
            )
        ),
      ),
    ),
                const SizedBox(height: 10 ),
            
              //passord text field
                

                Container(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.8),
        child: TextField(
          maxLines: 1,
          controller: passwordController1,
            obscureText: true,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Password.......',
              hintStyle: TextStyle(color: Colors.grey[500] ) 
            )
        ),
      ),
    ),
            
              //forget password
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Forgot password?',
                    style: TextStyle(color: Colors.blue, fontSize: 16,),
                    ),
                  ],
                ),
              ),
        
              // sign in buttom
             GestureDetector(
              onTap: signUserIn,
               child: Container(
                margin: const EdgeInsets.all(8),
                 child: MyButton(
                    onTap: signUserIn,
                    text: 'Sign In',
                  ),
               ),
             ),
             
            
              //not a member? register now
              GestureDetector(
                onTap: () {
             // Navigator.pushNamed(context, '/second');
            },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: const Text("Not a memeber yet? \n It won't be for long.", style: TextStyle(
                    color: Colors.blue
                  ),textAlign: TextAlign.center,),
                ),
                ),
                  ],
                ),
               );
  }
//Our services widgets -----------------------------------
Widget buildStackContainer(String text, IconData icon) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          height: 150*1.6,
          width: 220*1.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: AssetImage('assets/golfIcon.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
            ),
            Text(
              text,
              style: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.w100),
            )
          ],
        )
      ],
    );
  }
Widget buildEventWidget() {
    return buildStackContainer('Manage Events', Icons.event);
        }

  Widget buildClubPageWidget() {
    return buildStackContainer('Manage Club Page', Icons.web);
    
  }

  Widget buildPlayerManagementWidget() {
    return buildStackContainer('Manage Players', Icons.sports_golf);
  }

  Widget buildEcommerceWidget() {
    return buildStackContainer('E-commerce', Icons.sports_golf);
  }

  Widget buildRestaurantWidget() {
    return buildStackContainer('Manage Restaurant', Icons.dining);
  }

  Widget buildProShopWidget() {
      return buildStackContainer('Manage Pro-Shop', Icons.add_business);
  }

  Widget buildCommunityWidget() {
      return buildStackContainer('Community', Icons.people);
  }

  Widget buildHandicapWidget() {
      return buildStackContainer('Handicap index', 
      Icons.golf_course);
  }




  //appbar widgets ------------------------------
    Widget imagesContainer(int index) {
  return Container(
    margin: const EdgeInsets.all(6),
    height: 120,
    width: 140,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
        //topLeft: Radius.circular(15), 
        bottomRight: Radius.circular(15)),
      image: DecorationImage(
        image: NetworkImage(skillImages[index]),
        fit: BoxFit.cover,
      ),
    ),
  );
}
  final skillImages =[
    
    'https://i.pinimg.com/564x/c9/30/99/c9309901e00844fcad5bf1b00ac99bae.jpg',
    'https://i.pinimg.com/564x/04/8f/7b/048f7bd2986cfd3d5c4b7a49b549fae5.jpg',
    'https://i.pinimg.com/564x/24/8c/53/248c53111d87a6f4e7f8ec2cd2b09a2f.jpg',
    'https://i.pinimg.com/564x/5c/36/96/5c369626ccd3938ad4080fab7e3938bd.jpg',
    'https://i.pinimg.com/564x/fc/49/21/fc49213803b578b28c833d1b9e99195b.jpg',
    'https://i.pinimg.com/564x/8b/1d/e2/8b1de2c77638b342b790f80947cded31.jpg',
    'https://i.pinimg.com/564x/11/a6/df/11a6dfd82d182b46bf5301b671859160.jpg',
    'https://i.pinimg.com/564x/98/4e/67/984e67f9b961882cd12e3d6973e3b003.jpg',
    'https://i.pinimg.com/564x/80/fb/b7/80fbb7ce137092ecd74455ab96890550.jpg',
    'https://i.pinimg.com/564x/11/a6/df/11a6dfd82d182b46bf5301b671859160.jpg',
    'https://i.pinimg.com/564x/9e/01/d2/9e01d217a9e2cae2eefc56e6dfd2e363.jpg',
    'https://i.pinimg.com/564x/c9/30/99/c9309901e00844fcad5bf1b00ac99bae.jpg',
    'https://i.pinimg.com/564x/c8/c5/99/c8c599c7f78f6dc8de6b3d76a6cd2237.jpg',
    'https://i.pinimg.com/236x/d9/f6/d5/d9f6d5c739f0e115647f052d7ba12012.jpg'
    
  ];
   Widget _buildTitle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      //height: 60,
      width: 230,
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                text: Strings.portfoli,
                style: TextStyles.logo,
              ),
              TextSpan(
                text: Strings.o,
                style: TextStyles.logo.copyWith(
                  color: Color.fromARGB(255, 29, 48, 224),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}