// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yazlab_2_2/features/home/views/home.dart';

import '../../../common/colors.dart';
import '../repository/auth_repository.dart';
import 'sing_up.dart';

class SingIn extends StatefulWidget {
  const SingIn({super.key});

  @override
  State<SingIn> createState() => _SingInState();
}

class _SingInState extends State<SingIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 80, // Yukarıdan boşluk ayarı
            left: 0,
            right: 0,
            child: Text(
              'Wordle Extra', // Başlık metni
              textAlign: TextAlign.center, // Metni ortala
              style: TextStyle(
                fontSize: 48, // Font büyüklüğü
                fontWeight: FontWeight.bold, // Font kalınlığı
                color: Colors.white, // Metin rengi
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)),
                ),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: Text(
                              "Giriş Yap",
                              style: TextStyle(color: titleColor, fontSize: 20),
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Email gerekli!";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    )),
                              ),
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Şifre gerekli!";
                                }
                                return null;
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Şifre",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    )),
                              ),
                            )),
                        Consumer(
                          builder: (context, ref, child) {
                            return MaterialButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ref
                                      .read(AuthRepositoryProvider)
                                      .signInWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      )
                                      .then(
                                        (value) => Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => Home(
                                                email: _emailController.text,
                                              ),
                                            ),
                                            (route) => true),
                                      );
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              color: buttonColor,
                              minWidth: double.infinity,
                              child: Text(
                                "Giriş Yap",
                                style: TextStyle(
                                  color: containerColor,
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Hesabın yok mu ?",
                                style: TextStyle(
                                  color: textButtonTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                  child: Text("Kayıt Ol"),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SingUp()))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}
