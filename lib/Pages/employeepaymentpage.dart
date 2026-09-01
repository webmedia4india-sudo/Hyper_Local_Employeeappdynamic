import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';

class EmployeePaymentPage extends StatefulWidget {
  const EmployeePaymentPage({super.key});

  @override
  State<EmployeePaymentPage> createState() => _EmployeePaymentPageState();
}

class _EmployeePaymentPageState extends State<EmployeePaymentPage> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Payment",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "₹1,499",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Apply Coupon
            InkWell(
              onTap: () {
                // TODO: hook up apply coupon logic
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Apply Coupon",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Payment Methods card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 14, bottom: 6),
                    child: Text(
                      "Payment Methods",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _paymentMethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.coral,
                    label: "UPI",
                    value: "upi",
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _paymentMethodTile(
                    icon: Icons.credit_card,
                    iconColor: AppColors.primary,
                    label: "Credit / Debit Card",
                    value: "card",
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _paymentMethodTile(
                    icon: Icons.account_balance_outlined,
                    iconColor: AppColors.mint,
                    label: "Net Banking",
                    value: "netbanking",
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _paymentMethodTile(
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.pink,
                    label: "Wallet Balance",
                    value: "wallet",
                    trailingText: "₹250",
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pay Securely button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: hook up payment logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.buttonText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Pay Securely",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? trailingText,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}