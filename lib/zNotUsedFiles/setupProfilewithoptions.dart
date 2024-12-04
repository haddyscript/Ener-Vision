import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';

import '../EnergyManagement/Community/energy_effieciency_page.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  File? _profilePicture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countryLineController = TextEditingController();
  final TextEditingController _cityLineController = TextEditingController();
  final TextEditingController _streetLineController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profilePicture = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID is not available.');
      return;
    }

    // Debug prints for each input
    print('UserId: $userId');
    print('Name: ${_nameController.text}');
    print('Gender: ${_genderController.text}');
    print('Occupation: ${_occupationController.text}');
    print('Birth Date: ${_birthDateController.text}');
    print('Mobile Number: ${_mobileNumberController.text}');
    print('Country: ${_countryLineController.text}');
    print('City: ${_cityLineController.text}');
    print('Street: ${_streetLineController.text}');

    final url = Uri.parse("http://10.0.2.2:8080/updateUserProfile");

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['userId'] = userId
        ..fields['name'] = _nameController.text
        ..fields['gender'] = _genderController.text
        ..fields['occupation'] = _occupationController.text
        ..fields['birthDate'] = _birthDateController.text
        ..fields['mobileNumber'] = _mobileNumberController.text
        ..fields['address[countryLine]'] = _countryLineController.text
        ..fields['address[cityLine]'] = _cityLineController.text
        ..fields['address[streetLine]'] = _streetLineController.text;

      // If a profile picture is selected, add it to the request
      if (_profilePicture != null) {
        var picStream =
            http.ByteStream(Stream.castFrom(_profilePicture!.openRead()));
        var picLength = await _profilePicture!.length();
        var picFile = http.MultipartFile('profilePicture', picStream, picLength,
            filename: basename(_profilePicture!.path));
        request.files.add(picFile);
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        // Profile update successful
        var responseData = await response.stream.toBytes();
        var profileData = jsonDecode(String.fromCharCodes(responseData));
        // Handle profile data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const EnergyEfficiencyPage(selectedIndex: 1)),
        );
      } else {
        // Log the response body to debug
        print(
            'Failed to update profile: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Error occurred while updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        body: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/energy1.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 20), // Space between image and form
        Expanded(
          child: SingleChildScrollView(
            child: _formBox(context),
          ),
        ),
      ],
    );
  }

  Widget imageProfile(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundImage: _profilePicture != null
              ? FileImage(_profilePicture!)
              : const AssetImage('assets/profile (2).png') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: ((builder) => bottomSheet(context)));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const Text('Choose Profile Photo'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flatbutton(
                icon: const Icon(Icons.camera),
                label: const Text('Camera'),
                onPressed: () {
                  // Gallery button logic
                },
              ),
              Flatbutton(
                icon: const Icon(Icons.browse_gallery),
                label: const Text('Gallery'),
                onPressed: () {
                  // Gallery button logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formBox(BuildContext context) {
    return Container(
      decoration: greyBoxDecoration(),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          imageProfile(context),
          const SizedBox(height: 20),
          const Text('Customize Your Account'),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _genderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your gender' : null,
                ),
                TextFormField(
                  controller: _occupationController,
                  decoration: const InputDecoration(labelText: 'Occupation'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your occupation' : null,
                ),
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                      labelText: 'Birth Date (YYYY-MM-DD)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your birth date' : null,
                ),
                TextFormField(
                  controller: _countryLineController,
                  decoration: const InputDecoration(labelText: 'Country'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your country' : null,
                ),
                TextFormField(
                  controller: _cityLineController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your city' : null,
                ),
                TextFormField(
                  controller: _streetLineController,
                  decoration: const InputDecoration(labelText: 'Street'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your street' : null,
                ),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your mobile number' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm(context);
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countryLineController.dispose();
    _cityLineController.dispose();
    _streetLineController.dispose();
    _mobileNumberController.dispose();
    _nameController.dispose();
    _genderController.dispose();
    _occupationController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}

class Flatbutton extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final Widget label;

  const Flatbutton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: icon,
      label: label,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
