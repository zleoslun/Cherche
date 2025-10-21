// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

// Future<void> makePayment(String userId, int amount) async {
//   try {
//     // 1. Call Firebase Function
//     final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
//       'createPaymentIntent',
//     );
//     final response = await callable.call({
//       'amount': amount,
//       'currency': 'usd',
//       'userId': userId,
//     });

//     final clientSecret = response.data['clientSecret'];

//     // 2. Init Payment Sheet
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: clientSecret,
//         merchantDisplayName: 'Cherche',
//       ),
//     );

//     // 3. Present Payment Sheet
//     await Stripe.instance.presentPaymentSheet();

//     print("✅ Payment completed");
//   } catch (e) {
//     print("❌ Payment failed: $e");
//   }
// }

// 2
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dailydevotion/stripe/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> makePayment(int amount, BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  try {
    // 1. Call Firebase Function
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createPaymentIntent',
    );
    final response = await callable.call({
      'amount': amount, // send only amount
    });

    final clientSecret = response.data['clientSecret'];
    final paymentIntentId =
        response.data['paymentIntentId']; // optional, if you return it

    // 2. Init Payment Sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Cherche',
      ),
    );
    // Dismiss loading indicator before showing payment sheet
    Navigator.of(context).pop();

    // 3. Present Payment Sheet
    await Stripe.instance.presentPaymentSheet();

    showReceiptDialog(
      context: context,
      amount: amount,
      date: DateTime.now(),
      paymentId: paymentIntentId,
    );
  } catch (e) {
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text("Payment Failed: $e")));

    // Show error popup that dismisses after 3 seconds
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(title: const Text("Payment Failed"), content: Text("$e")),
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }
}
