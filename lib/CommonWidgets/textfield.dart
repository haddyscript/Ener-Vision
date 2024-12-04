import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String placeholderText;
  final bool obscureText;
  final IconData? prefixIcon;
  final int? maxLength;
  final bool showCounter;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputType? inputType;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.maxLength,
    this.showCounter = true,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputType,
    required this.placeholderText,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateClearIconVisibility);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateClearIconVisibility);
    super.dispose();
  }

  void _updateClearIconVisibility() {
    setState(() {
      _showClearIcon = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD1D1D1),
                offset: Offset(0.0, 5.0),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(0.0, 0.0),
                blurRadius: 0.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              maxLength: widget.maxLength,
              buildCounter: (_,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null, // Hide the built-in counter
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                fillColor: Colors.white70,
                filled: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'ProductSans',
                  fontSize: 12.0,
                ),
                prefixIcon:
                    widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                suffixIcon: _showClearIcon
                    ? IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          widget.onChanged?.call('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (widget.maxLength != null && widget.showCounter)
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 4.0),
            child: Text(
              '${widget.controller.text.length}/${widget.maxLength}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String placeholderText;

  final Icon prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    required this.keyboardType,
    required this.placeholderText,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showClearIcon = false;
  bool _isValid = true;
  String? _errorText;

  void _validateField(String value) {
    setState(() {
      if (value.isEmpty) {
        _isValid = false;
        _errorText = "This field cannot be empty.";
      } else if (widget.validator != null) {
        final validationResult = widget.validator!(value);
        _isValid = validationResult == null;
        _errorText = validationResult;
      } else {
        _isValid = true;
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD1D1D1),
            offset: Offset(0.0, 5.0),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          obscureText: widget.obscureText,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: (value) {
            setState(() {
              _showClearIcon = value.isNotEmpty;
            });
            _validateField(value); // Validate field on change
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isValid ? Colors.transparent : Colors.red,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isValid ? Colors.transparent : Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
            fillColor: Colors.white70,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'ProductSans',
              fontSize: 12.0,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _showClearIcon
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showClearIcon = false;
                      });
                      _validateField(
                          ''); // Trigger validation with empty string
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
            errorText: _errorText,
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon prefixIcon;
  final String placeholder;

  final Function(String)? onChanged;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
    required this.placeholder,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showClearIcon = false;
  bool _isValid = true;
  bool _hasStartedTyping = false;
  String? _errorText;
  bool _isPasswordVisible = false;

  final Map<String, bool> _passwordRequirements = {
    "At least 8 characters": false,
    "At least one special character": false,
    "At least one uppercase character": false,
  };

  void _validatePassword(String value) {
    setState(() {
      _hasStartedTyping = value.isNotEmpty;

      _passwordRequirements["At least 8 characters"] = value.length >= 8;
      _passwordRequirements["At least one special character"] =
          RegExp(r'[!@#\$&*~]').hasMatch(value);
      _passwordRequirements["At least one uppercase character"] =
          RegExp(r'[A-Z]').hasMatch(value);

      _isValid = _passwordRequirements.values.every((req) => req);

      if (value.isEmpty) {
        _isValid = false;
        _errorText = null; // No error when the field is empty
      } else if (!_isValid) {
        _errorText = "Password must meet all requirements.";
      } else {
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD1D1D1),
            offset: Offset(0.0, 5.0),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              obscureText: !_isPasswordVisible,
              controller: widget.controller,
              onChanged: (value) {
                setState(() {
                  _showClearIcon = value.isNotEmpty;
                });
                _validatePassword(value);
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isValid ? Colors.transparent : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isValid ? Colors.transparent : Colors.red,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'ProductSans',
                  fontSize: 12.0,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Eye icon for toggling password visibility
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    // Clear icon for clearing the field
                    if (_showClearIcon)
                      IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {
                            _showClearIcon = false;
                            _hasStartedTyping = false;
                          });
                          _validatePassword(widget.controller as String);
                        },
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 8),
            // Show unmet requirements only after the user starts typing
            if (_hasStartedTyping)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _passwordRequirements.entries
                    .where(
                        (entry) => !entry.value) // Only show unmet requirements
                    .map(
                      (entry) => Row(
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
