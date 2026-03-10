import 'package:flutter/material.dart';

/// Base class for pages to reduce boilerplate.
abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor(context) ?? theme.scaffoldBackgroundColor,
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: buildFloatingActionButton(context),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  Widget buildBody(BuildContext context);

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget? buildFloatingActionButton(BuildContext context) => null;

  Widget? buildBottomNavigationBar(BuildContext context) => null;

  Color? backgroundColor(BuildContext context) => null;
}
