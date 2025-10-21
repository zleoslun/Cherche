import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/providers/locale_provider.dart';
import 'package:dailydevotion/providers/user_provider.dart';
import 'package:dailydevotion/utils/validator.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:dailydevotion/widgets/custom_textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  final AppLocalizations tr;
  const EditProfilePage({super.key, required this.user, required this.tr});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _statusController;

  // keep a local, mutable copy so avatar updates immediately
  late UserModel _localUser;

  bool _isUploadingPic = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _localUser = widget.user;
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _statusController = TextEditingController(
      text: widget.user.professionalStatus ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() => _isUploadingPic = true);

      final uid = FirebaseAuth.instance.currentUser?.uid ?? _localUser.uid;
      final file = File(picked.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Update Firestore directly (optional if you rely on provider only)
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePic': url,
      });

      // Update provider + local state so UI refreshes everywhere
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final updated = _localUser.copyWith(profilePic: url);
      await userProvider.updateUser(updated);

      if (!mounted) return;
      setState(() {
        _localUser = updated;
        _isUploadingPic = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.tr.profilePhotoUpdated)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPic = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.tr.imageUploadFailed}: $e')));
    }
  }

  Future<void> _saveProfile() async {
    final tr = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final updated = _localUser.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      professionalStatus: _statusController.text.trim(),
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateUser(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tr.profileUpdated)));
    Navigator.pop(context, updated); // return updated user if caller wants it
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final avatarRadius = size.width * 0.15;

    return Scaffold(
      appBar: CustomAppBar(title: widget.tr.editProfile),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            left: width * 0.05,
            right: width * 0.05,
            top: height * 0.01,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Avatar + edit button
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: theme.colorScheme.primary,
                          backgroundImage:
                              (_localUser.profilePic != null &&
                                  _localUser.profilePic!.isNotEmpty)
                              ? NetworkImage(_localUser.profilePic!)
                              : null,
                          child:
                              (_localUser.profilePic == null ||
                                  _localUser.profilePic!.isEmpty)
                              ? Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: InkWell(
                            onTap: _isUploadingPic ? null : _pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.colorScheme.secondary,
                              child: _isUploadingPic
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            
                CustomTextformfield(
                  // hint: "Name",
                  hint: widget.tr.nameLabel,
                  labelText: widget.tr.nameLabel,
                  // labelText: "Name",
                  controller: _nameController,
                  textInputType: TextInputType.text,
                  validator: ValidateFields.validateName,
                  prefix: Icon(Icons.person_outline),
                ),

              
                CustomTextformfield(
                  hint: "e.g entrepreneur",
                  // labelText: "Professional Status",
                  labelText: widget.tr.professionalStatus,
                  controller: _statusController,
                  textInputType: TextInputType.text,
                  prefix: Icon(Icons.work_outline),
                ),

           
                //
                CustomTextformfield(
                  // prefix: Icon(Icons.info_outline),
                  hint: "Enter bio",
                  labelText: "Bio",
                  controller: _bioController,
                  textInputType: TextInputType.text,
                  maxLines: 3,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  child: CustomButton(
                    label: Text(
                      widget.tr.save, style: TextStyle(color: Colors.white)),
                    onTap: _saveProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
