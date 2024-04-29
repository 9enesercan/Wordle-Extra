// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yazlab_2_2/features/Auth/controller/auth_controller.dart';
import 'package:yazlab_2_2/features/home/views/home.dart';
import 'package:yazlab_2_2/models/user_model.dart';

import '../../../common/colors.dart';

class SingUpInfo extends StatefulWidget {
  const SingUpInfo({
    super.key,
    required this.email,
  });
  final String email;

  @override
  State<SingUpInfo> createState() => _SingUpInfoState();
}

class _SingUpInfoState extends State<SingUpInfo> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _usernameController.dispose();
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
                              "Bilgi gir",
                              style: TextStyle(color: titleColor, fontSize: 20),
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _usernameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Kullanıcı adı gerekli!";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Kullanıcı Adı",
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
                                  UserModel userModel = UserModel(
                                      email: widget.email,
                                      username: _usernameController.text);
                                  ref
                                      .read(AuthControllerProvider)
                                      .storeUserInfo(userModel)
                                      .whenComplete(
                                          () => Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Home(
                                                  email: widget.email,
                                                ),
                                              ),
                                              (route) => false));
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              color: buttonColor,
                              minWidth: double.infinity,
                              child: Text(
                                "Devam Et",
                                style: TextStyle(
                                  color: containerColor,
                                ),
                              ),
                            );
                          },
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
