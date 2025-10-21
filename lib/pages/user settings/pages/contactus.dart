import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contactus extends StatefulWidget {
  final AppLocalizations tr;
  const Contactus({super.key, required this.tr});

  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitContactForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final contactData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'new',
          'isRead': false,
        };

        await _firestore.collection('contact_messages').add(contactData);

        _nameController.clear();
        _emailController.clear();
        _messageController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // "Your message has been sent. We'll get back to you soon!",
              widget.tr.messageSent,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // "Could not send your message. Please try again later.",
              widget.tr.messageFailed,
            ),
            backgroundColor: Colors.red,
          ),
        );
        print('Error submitting contact form: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;

    return
    // backgroundColor: bgColor,
    Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              // labelText: 'Full Name',
              labelText: widget.tr.enterFullName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? widget.tr.enterFullName
                : null,
          ),
          const SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              // labelText: 'Email Address',
              labelText: widget.tr.enterEmail,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return widget.tr.enterEmail;
              if (!isEmailValid(value)) return widget.tr.emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Message Field
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: widget.tr.message,
              hintText: widget.tr.typeMessageHere,
              alignLabelWithHint: true, // This moves the label to the top
              contentPadding: EdgeInsets.fromLTRB(
                12,
                24,
                12,
                12,
              ), // Adjust padding as needed
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.tr.enterMessage;
              }
              if (value.length < 10) {
                return widget.tr.messageTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Submit Button
          // Center(
          //   child: _isLoading
          //       ? const CircularProgressIndicator()
          //       : Mybutton(
          //           onTap: _submitContactForm,
          //           label: Text(
          //             "Submit",
          //             style: GoogleFonts.poppins(color: white),
          //           ),
          //         ),
          // ),
          Center(
            child: CustomButton(
              label: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.tr.submit,
                      style: TextStyle(color: Colors.white),
                    ),
              onTap: _submitContactForm,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
