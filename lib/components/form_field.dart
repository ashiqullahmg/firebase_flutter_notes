import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    Key? key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType keyboardType,
    required TextInputAction inputAction,
    required String label,
    required String hint,
    required Function(String value) validator,
    required  this.fontSize,
    this.isObscure = false,
    this.isCapitalized = false,
    this.maxLines = 1,
    this.isLabelEnabled = true,
  })  : _emailController = controller,
        _emailFocusNode = focusNode,
        _keyboardType = keyboardType,
        _inputAction = inputAction,
        _label = label,
        _hint = hint,
        _validator = validator,
        super(key: key);

  final TextEditingController _emailController;
  final FocusNode _emailFocusNode;
  final TextInputType _keyboardType;
  final TextInputAction _inputAction;
  final String _label;
  final String _hint;
  final bool isObscure;
  final bool isCapitalized;
  final int maxLines;
  final bool isLabelEnabled;
  final Function(String) _validator;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TextFormField(
        maxLines: null,
        style: TextStyle(
          fontSize: fontSize,
        ),
        controller: _emailController,
        focusNode: _emailFocusNode,
        keyboardType: _keyboardType,
        obscureText: isObscure,
        textCapitalization:
        isCapitalized ? TextCapitalization.words : TextCapitalization.none,
        textInputAction: _inputAction,
        cursorColor: Theme.of(context).brightness == Brightness.dark
            ? Palette.grey
            : Colors.indigo,
        validator: (value) => _validator(value!),
        decoration: InputDecoration(
          labelText: isLabelEnabled ? _label : null,
          labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark
              ? Palette.yellow
              : Colors.black.withOpacity(0.5),),
          hintText: _hint,
          hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Palette.amber
                  : Colors.indigo,
          ),
          errorStyle: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Palette.yellow
                  : Colors.indigo,
              width: 1,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
