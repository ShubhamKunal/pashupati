import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _otpController = TextEditingController();
  final _nameController = TextEditingController(text: 'Aarav Sharma');
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        title: const Text('Rescuer Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PashupatiColors.softGreen,
                    border: Border.all(color: PashupatiColors.forestGreen.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/branding/app_logo.png',
                      width: 56,
                      height: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Join the Rescue Network',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PashupatiColors.darkForest,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify your phone number to publish emergencies or accept active rescues in your neighborhood.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: PashupatiColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Phone Number',
                  prefixIcon: Icon(Icons.phone_rounded, color: PashupatiColors.forestGreen),
                  helperText: 'Standard 10-digit Indian mobile number',
                ),
                enabled: !_otpSent,
              ),

              const SizedBox(height: 16),

              if (!_otpSent) ...[
                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final cleanPhone = _phoneController.text.replaceAll(' ', '');
                          final success = await ref
                              .read(authNotifierProvider.notifier)
                              .requestOtp(cleanPhone);
                          if (success && mounted) {
                            setState(() {
                              _otpSent = true;
                              _otpController.text = '123456'; // Default dev OTP
                            });
                          }
                        },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send Verification OTP'),
                ),
              ] else ...[
                // Name Field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Callsign',
                    prefixIcon: Icon(Icons.person_rounded, color: PashupatiColors.forestGreen),
                  ),
                ),
                const SizedBox(height: 16),

                // OTP Field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter 6-Digit OTP',
                    prefixIcon: const Icon(Icons.lock_rounded, color: PashupatiColors.forestGreen),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PashupatiColors.softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        widthFactor: 1,
                        child: Text(
                          'DEV: 123456',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: PashupatiColors.forestGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final cleanPhone = _phoneController.text.replaceAll(' ', '');
                          final success = await ref
                              .read(authNotifierProvider.notifier)
                              .verifyOtp(
                                phone: cleanPhone,
                                otp: _otpController.text.trim(),
                                name: _nameController.text.trim(),
                              );
                          if (success && context.mounted) {
                            context.go('/home');
                          }
                        },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verify & Enter Network'),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                    });
                  },
                  child: const Text(
                    'Change Phone Number',
                    style: TextStyle(color: PashupatiColors.forestGreen),
                  ),
                ),
              ],

              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PashupatiColors.emergencyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authState.errorMessage!,
                    style: const TextStyle(
                      color: PashupatiColors.emergencyRed,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
