import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showReceiptDialog({
  required BuildContext context,
  required int amount,
  required DateTime date,
  String? paymentId,
}) async {
  final formattedDate = DateFormat('EEE, MMM d, yyyy • HH:mm').format(date);
  final formattedAmount = "€ ${(amount / 100).toStringAsFixed(2)}";

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return SingleChildScrollView(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            // width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Premium Header with Pattern
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A237E),
                            Color(0xFF283593),
                            Color(0xFF3949AB),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Payment Successful",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Transaction completed",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Amount Display
                    Container(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          Text(
                            "Amount Paid",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                            ),
                          ),
                          // const SizedBox(height: 8),
                          Text(
                            formattedAmount,
                            style: const TextStyle(
                              fontSize: 30,
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Receipt Details Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (paymentId != null) ...[
                              _buildPremiumInfoRow(
                                icon: Icons.tag_rounded,
                                label: "Payment ID",
                                value: "#$paymentId",
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildPremiumInfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: "Date & Time",
                              value: formattedDate,
                            ),
                            const SizedBox(height: 16),
                            _buildPremiumInfoRow(
                              icon: Icons.verified_rounded,
                              label: "Status",
                              value: "Completed",
                              valueColor: const Color(0xFF00C853),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 🔹 Close Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildPremiumInfoRow({
  required IconData icon,
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A237E)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
