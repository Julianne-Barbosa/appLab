import 'package:flutter/material.dart';

class InputTextos extends StatelessWidget {
  final String rotulo;
  final String label;
  final TextEditingController controller;

  const InputTextos(this.rotulo, this.label,
      {super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: label,
          labelStyle: TextStyle(color: theme.colorScheme.primary),
          hintStyle:
              TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: theme.colorScheme.secondary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
