import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AdaptiveScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text(title)),
        child: SafeArea(child: body),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: body,
      );
    }
  }
}