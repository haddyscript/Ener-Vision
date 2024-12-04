import 'package:flutter/material.dart';
// import 'deviceListPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'device_list_page.dart';

class Category {
  final String name;
  final String imagePath;
  Category({required this.name, required this.imagePath});
}

class CategorySelectionPage extends StatefulWidget {
  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final List<Category> categories = [
    Category(name: 'Cooking', imagePath: 'assets/cooking.jpg'),
    Category(name: 'Lighting', imagePath: 'assets/lights.jpg'),
    Category(name: 'Cooling', imagePath: 'assets/cooling.jpg'),
    Category(name: 'Entertainment', imagePath: 'assets/entertainment.jpg'),
    Category(name: 'Laundry', imagePath: 'assets/laundry.jpg'),
  ];
  Map<String, List<dynamic>> devicesCache = {};
  Map<String, bool> loadingState = {};
  Future<List<dynamic>> fetchDevices(String category) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/category/$category'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['devices'];
    } else {
      throw Exception('Failed to load devices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Energy Efficient Appliances',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 20.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                if (index == 3 || index == 4) {
                  return _buildCategoryCard(categories[index]);
                } else {
                  return _buildCategoryCard(categories[index]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    bool isLoading = loadingState[category.name] ?? false;
    bool isLoaded = devicesCache.containsKey(category.name);
    return InkWell(
      onTap: () async {
        if (!isLoaded && !isLoading) {
          setState(() {
            loadingState[category.name] = true;
          });
          try {
            List<dynamic> devices = await fetchDevices(category.name);
            setState(() {
              devicesCache[category.name] = devices;
              loadingState[category.name] = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceListPage(
                  category: category.name,
                  devices: devices,
                ),
              ),
            );
          } catch (e) {
            setState(() {
              loadingState[category.name] = false;
            });
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load devices: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else if (isLoaded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceListPage(
                  category: category.name,
                  devices: devicesCache[category.name]!),
            ),
          );
        }
      },
      child: Container(
        width: 110,
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(category.imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16, // Font size for category name
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
              textAlign: TextAlign.center, // Centered the text
            ),
          ),
        ),
      ),
    );
  }
}
