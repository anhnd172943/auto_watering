import 'dart:convert';
import 'package:auto_watering/views/devicelist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'package:http/http.dart' as http;


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //thuoc tinh va controller
  String email = '';
  String password = '';
  String _notify = '';
  final emailEditController = new TextEditingController();
  final passwordEditController = new TextEditingController();
  final String loginUrl = 'https://back-end-iot.herokuapp.com/v1/auth/login';
  final notifyEditController = new TextEditingController();


   signIn(String email, password) async{
    Map data ={
      'email': email,
      'password': password
    };
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(loginUrl),
      body:json.encode(data),
      headers:{'Content-Type': 'application/json; charset=UTF-8'}
    );

    if (response.statusCode == 401){
      setState(() {
        _notify = "Incorrect email or password";
      });
    }
    if (response.statusCode == 400){
      setState(() {
        _notify = 'Username or Password is not allowed to be empty';
      });
    }
    else {

      var myResponse = json.decode(response.body);


      sharedPreferences.setString('accessToken', myResponse['tokens']['access']['token']) ;
      sharedPreferences.setString('refreshToken', myResponse['tokens']['refresh']['token']);
      sharedPreferences.setString('email', email);
      setState(() {
        _notify = 'Loading...';
      });

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => DeviceList()),
              (Route<dynamic> route) => false);
    }

  }






  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    Colors.white,
                    Color(0x96e8ff)
                  ]
              )
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 60,),
              Container(
                child: Text('Login',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                  ),),
              ),
              SizedBox(
                height: 40,
              ),
              //Username
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 30,
                child: TextFormField(
                  onChanged: (val){
                    email = val;
                  },
                  controller: emailEditController,
                  style: TextStyle(
                      color: Colors.black45
                  ),
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: "Email:",
                    labelStyle: TextStyle(
                        color: Colors.black45
                    ),
                    border: OutlineInputBorder(
                      borderRadius: (BorderRadius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black45
                        )
                    ),
                  ),
                ),
              ),
              SizedBox (height: 10,),
              //Password
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 30,
                child: TextFormField(
                  onChanged: (val){
                    password = val;
                  },
                  controller: passwordEditController,
                  style: TextStyle(
                      color: Colors.black45
                  ),
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password:",
                      labelStyle: TextStyle(
                          color: Colors.black45
                      ),
                      border: OutlineInputBorder(
                        borderRadius: (
                            BorderRadius.circular(10)
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black45
                          )
                      )
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //SignInButton
              TextButton(
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text("Login".toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                onPressed: (){
                  signIn(emailEditController.text, passwordEditController.text);
                },
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width-50,
                child: Text(
                  _notify,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}

