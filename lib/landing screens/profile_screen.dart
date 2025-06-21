import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  String? name;
  String? profileImageUrl;
  User? user = FirebaseAuth.instance.currentUser;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    nameController.text = name ?? '';
  }

  void fetchUserData() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

    if (snapshot.exists) {
      Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
      setState(() {
        name = userData?['name'];
        profileImageUrl = userData?['profileImageUrl'];
      });
    }
  }

  void saveNameChanges() {
    String updatedName = nameController.text;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'name': updatedName})
        .then((value) {
          print('Name changes saved successfully');
        })
        .catchError((error) {
          print('Error saving name changes: $error');
        });
  }

  void updateProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          isUploadingImage = true; // Start image uploading process
        });

        final firebase_storage.Reference storageRef = firebase_storage
            .FirebaseStorage
            .instance
            .ref()
            .child('profile_images');

        final task = await storageRef
            .child(user!.uid)
            .putFile(File(pickedImage.path));

        if (task.state == firebase_storage.TaskState.success) {
          final downloadUrl = await task.ref.getDownloadURL();

          setState(() {
            profileImageUrl = downloadUrl;
            isUploadingImage = false; // Stop image uploading process
          });

          saveImageChanges();
          // saveChanges(); // Call saveChanges() to update the image URL in Firestore

          print('Profile image updated successfully');
        } else {
          setState(() {
            isUploadingImage = false; // Stop image uploading process
          });

          print('Failed to upload profile image');
        }
      }
    } catch (e) {
      setState(() {
        isUploadingImage = false; // Stop image uploading process
      });
      print('Error picking image: $e');
    }
  }

  void saveImageChanges() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'profileImageUrl': profileImageUrl})
        .then((value) {
          print('Image changes saved successfully');
        })
        .catchError((error) {
          print('Error saving image changes: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder:
          (context, child) => Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 215, 139, 25),
              title: Text('Profile'),
            ),
            body: ListView(
              children: [
                FutureBuilder<User?>(
                  future: FirebaseAuth.instance.authStateChanges().first,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<User?> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text('No user found. Please sign in.'),
                      );
                    }

                    // User is signed in
                    final User user = snapshot.data!;
                    return StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Center(child: Text('No user data found.'));
                        }

                        // User data is available
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        String? name = userData?['name'];
                        final String? email = userData?['email'];
                        final String? currentProfileImageUrl =
                            userData?['profileImageUrl'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap:
                                  updateProfileImage, // Trigger image update on tap
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60.r,
                                    backgroundImage:
                                        profileImageUrl != null
                                            ? NetworkImage(profileImageUrl!)
                                            : null,
                                    backgroundColor: Colors.grey[200],
                                    child:
                                        profileImageUrl == null
                                            ? Icon(
                                              Icons.add_a_photo,
                                              size: 30,
                                              color: Colors.grey,
                                            )
                                            : null,
                                  ),
                                  if (isUploadingImage) // Display progress indicator while uploading
                                    Positioned.fill(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 215, 139, 25),
                              ),
                              title: TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: '${name ?? ''}',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 215, 139, 25),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            ListTile(
                              leading: Icon(
                                Icons.email,
                                color: Color.fromARGB(255, 215, 139, 25),
                              ),
                              title: Text(email ?? ''),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  215,
                                  139,
                                  25,
                                ),
                              ),
                              onPressed: () {
                                saveNameChanges(); // Save name changes
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Profile updated!')),
                                );
                              },
                              child: Text(
                                'Update Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Toggle the theme by accessing the provider and calling the toggleTheme() function
                                Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).toggleTheme();
                              },
                              child: Text('Switch Theme'),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Current Theme: ${Provider.of<ThemeProvider>(context).isDarkMode ? 'Dark' : 'Light'}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}
