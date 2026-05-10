import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;
  String? _verificationId;
  bool _otpSent = false;
  String _selectedCode = '+970';

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  void _goToMap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  String get _fullPhoneNumber =>
      '$_selectedCode${_phoneController.text.trim()}';

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  Future<void> _loginWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _authService.signInWithGoogle();
      if (res != null && mounted) _goToMap();
      else setState(() => _error = 'فشل تسجيل الدخول');
    } catch (_) {
      setState(() => _error = 'حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOTP() async {
    final number = _phoneController.text.trim();
    if (number.isEmpty) {
      setState(() => _error = 'أدخل رقم الهاتف');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await _authService.sendOTP(
      phoneNumber: _fullPhoneNumber,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _loading = false;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _otpFocusNodes[0].requestFocus();
        });
      },
      onError: (error) {
        setState(() { _error = error; _loading = false; });
      },
      onAutoVerified: (_) {
        if (mounted) _goToMap();
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return;
    final otp = _otpCode;
    if (otp.length < 6) {
      setState(() => _error = 'أدخل رمز التحقق كاملاً');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _authService.verifyOTP(
        verificationId: _verificationId!,
        otp: otp,
      );
      if (res != null && mounted) _goToMap();
    } catch (e) {
      setState(() => _error = e is String ? e : 'رمز خاطئ، حاول مرة أخرى');
      for (final c in _otpControllers) c.clear();
      _otpFocusNodes[0].requestFocus();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildOtpBox(int index) {
  return SizedBox(
    width: 44,
    height: 54,
    child: TextField(
      controller: _otpControllers[index],
      focusNode: _otpFocusNodes[index],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 24, 89, 26),
        height: 1.0,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14), // centers text vertically
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 24, 89, 26),
            width: 2,
          ),
        ),
      ),
      onChanged: (val) {
        if (val.isNotEmpty && index < 5) {
          _otpFocusNodes[index + 1].requestFocus();
        } else if (val.isEmpty && index > 0) {
          _otpFocusNodes[index - 1].requestFocus();
        }
        if (_otpCode.length == 6) {
          FocusScope.of(context).unfocus();
          _verifyOTP();
        }
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView( 
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            top: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16, // 👈 key fix
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ================= APP LOGO =================
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset('assets/image.png', fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ================= TITLE =================
                  const Text(
                    'مسار',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 24, 89, 26),
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'تابع أخبار الطرق بدقة عالية وسهولة تامة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.55),
                      height: 1.4,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ================= ERROR =================
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // ================= PHONE INPUT =================
                  if (!_otpSent) ...[
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCode,
                              onChanged: (val) =>
                                  setState(() => _selectedCode = val!),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              borderRadius: BorderRadius.circular(14),
                              items: const [
                                DropdownMenuItem(
                                  value: '+970',
                                  child: Text(
                                    '🇵🇸  +970',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '+972',
                                  child: Text(
                                    '🇮🇱  +972',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.black.withOpacity(0.1),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: '591234567',
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.35)),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]

                  // ================= OTP 6 BOXES =================
                  else ...[
                    Text(
                      'أدخل الرمز المرسل إلى $_fullPhoneNumber',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, _buildOtpBox),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ================= SEND OTP BUTTON =================
                  if (!_otpSent)
                    GestureDetector(
                      onTap: _loading ? null : _sendOTP,
                      child: Container(
                        height: 58,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 24, 89, 26),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : const Text(
                                  'إرسال رمز التحقق',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                  if (_otpSent)
                    Column(
                      children: [
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 24, 89, 26),
                              strokeWidth: 2,
                            ),
                          ),
                        TextButton(
                          onPressed: () => setState(() {
                            _otpSent = false;
                            _verificationId = null;
                            for (final c in _otpControllers) c.clear();
                            _error = null;
                          }),
                          child: Text(
                            'تغيير رقم الهاتف',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // ================= DIVIDER =================
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.black.withOpacity(0.15))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'أو',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.4)),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.black.withOpacity(0.15))),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ================= GOOGLE BUTTON =================
                  GestureDetector(
                    onTap: _loading ? null : _loginWithGoogle,
                    child: Container(
                      height: 58,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.black.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: Image.asset('assets/google.webp',
                                fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'تسجيل الدخول باستخدام Google',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'بمساهمتك يتم تحسين تجربة التنقل داخل المنطقة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.4),
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}