import 'package:faithful_workspace/screens/homepage.dart';
import 'package:faithful_workspace/widgets/custom_primary_button.dart';
import 'package:faithful_workspace/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var MAX_HEIGHT = MediaQuery.of(context).size.height;
    var PRIMARY_COLOR = Theme.of(context).primaryColor;

    final colors = [
      const Color(0xFF00BBF9),
      PRIMARY_COLOR,
    ];

    const _durations = [
      5000,
      4000,
    ];

    const _heightPercentages = [
      0.65,
      0.66,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: SizedBox(
        height: MAX_HEIGHT,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Text(
                "LOGIN",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: PRIMARY_COLOR),
              ),
              const SizedBox(
                height: 50,
              ),
              CustomTextFormField(
                textEditingController: emailController,
                labelText: 'Email',
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextFormField(
                textEditingController: passwordController,
                labelText: 'Password',
                hintText: 'Password',
                prefixIcon: Icons.key,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomPrimaryButton(onPressed: () {
                if (emailController.text == "sazzad-zaag@gmail.com" &&
                    passwordController.text == "abc123def") {
                  final storage = GetStorage();
                  storage.write("loggedIn", true);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
                }
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 250,
        child: WaveWidget(
          config: CustomConfig(
            colors: colors,
            durations: _durations,
            heightPercentages: _heightPercentages,
          ),
          backgroundColor: Colors.white,
          size: const Size(double.infinity, double.infinity),
          waveAmplitude: 0,
        ),
      ),
    );
  }
}
