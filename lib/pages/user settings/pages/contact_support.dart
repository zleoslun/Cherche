import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/user%20settings/pages/contactus.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class ContactSupport extends StatelessWidget {
  final AppLocalizations tr;
  const ContactSupport({super.key, required this.tr});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var Size(:width, :height) = size;
    return Scaffold(
      appBar: CustomAppBar(title: tr.contactSupportTitle),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            children: [
              Text(tr.contactSupportContent),
              Padding(padding: EdgeInsets.only(top: 30), child: Contactus(tr: tr,)),
            ],
          ),
        ),
      ),
    );
  }
}
