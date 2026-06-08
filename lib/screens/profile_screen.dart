import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/core/state/user_state.dart';
import 'package:tirbushona_loyalty_app/screens/change_phone_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userState = UserState();
  String? _profileImagePath;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImagePath();
    _loadProfileDataFromSupabase();
  }

  /// Load profile data from Supabase database
  Future<void> _loadProfileDataFromSupabase() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('User not authenticated');
        return;
      }

      final profileData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profileData != null && mounted) {
        setState(() {
          userState.userName.value =
              profileData['full_name'] as String? ?? 'Потребител';
          userState.userPhone.value =
              profileData['phone_number'] as String? ?? '';
          userState.userDOB.value =
              profileData['birth_date'] as String? ?? '';
          userState.userLogisticNumber.value =
              profileData['logistic_card_number'] as String? ?? '';
          userState.userPhysicalCard.value =
              profileData['physical_card_number'] as String? ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EDF4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Профил',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar Section - Optimized with Image Caching
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Profile Image or Default Icon
                      if (_profileImagePath != null && File(_profileImagePath!).existsSync())
                        ClipOval(
                          child: Image.file(
                            File(_profileImagePath!),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                          ),
                        )
                      else
                        const Icon(
                          Icons.account_circle_outlined,
                          size: 90,
                          color: Color(0xFF9CA3AF),
                        ),

                      // Loading Overlay
                      if (_isLoadingImage)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),

                      // Camera Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.gradientBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Editable Data Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildDataField(
                      label: 'Име',
                      value: userState.userName.value,
                      controller: null,
                      icon: Icons.person_outline,
                      onEditTap: () {
                        _showEditDialog(
                          'Име',
                          userState.userName.value,
                          (newValue) async {
                            // Update Supabase first
                            await _updateProfileField('full_name', newValue);
                            // Update local state
                            await userState.setUserName(newValue);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDataField(
                      label: 'Телефонен номер',
                      value: userState.userPhone.value,
                      controller: null,
                      icon: Icons.phone_outlined,
                      onEditTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ChangePhoneScreen(
                              currentPhone: userState.userPhone.value,
                            ),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 250),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic,
                              );
                              return FadeTransition(
                                opacity: curvedAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.08, 0.0),
                                    end: Offset.zero,
                                  ).animate(curvedAnimation),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        ).then((newPhone) async {
                          if (newPhone != null) {
                            // Update Supabase first
                            await _updateProfileField('phone_number', newPhone);
                            // Update local state
                            await userState.setUserPhone(newPhone);
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDataField(
                      label: 'Дата на раждане',
                      value: userState.userDOB.value,
                      controller: null,
                      icon: Icons.calendar_today_outlined,
                      onEditTap: _showDatePickerDialog,
                    ),
                    const SizedBox(height: 12),
                    
                    // КОРЕКЦИЯ: Премахнат onEditTap - Картата става нередактируема
                    _buildDataField(
                      label: 'Логистичен номер карта',
                      value: userState.userLogisticNumber.value,
                      controller: null,
                      icon: Icons.card_giftcard,
                      onEditTap: null, 
                    ),
                    const SizedBox(height: 12),
                    
                    // КОРЕКЦИЯ: Премахнат onEditTap - Картата става нередактируема
                    _buildDataField(
                      label: 'Физически номер карта',
                      value: userState.userPhysicalCard.value,
                      controller: null,
                      icon: Icons.credit_card_outlined,
                      onEditTap: null, 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Delete Profile Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: _showDeleteConfirmation,
                  child: const Text(
                    'Изтрий профила',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Update a specific profile field in Supabase
  /// Maps field names to database column names
  Future<void> _updateProfileField(String column, String value) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Грешка: Не е намерена потребителска сесия'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // Perform Supabase update
      await Supabase.instance.client.from('profiles').update({
        column: value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Промяната е запазена успешно!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error message with actual error details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Грешка при запис: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      debugPrint('Error updating profile field $column: $e');
    }
  }

  Widget _buildDataField({
    required String label,
    required String value,
    TextEditingController? controller,
    required IconData icon,
    VoidCallback? onEditTap,
  }) {
    return GestureDetector(
      onTap: onEditTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.gradientBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onEditTap != null)
              const Icon(
                Icons.edit_outlined,
                color: Color(0xFFD1D5DB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave, {
    bool isNumeric = false,
  }) {
    final TextEditingController dialogController =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: dialogController,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Въведи нова стойност',
              hintStyle: const TextStyle(
                color: Color(0xFFC4B5FD),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.gradientBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмени',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onSave(dialogController.text);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Запази',
                style: TextStyle(
                  color: AppColors.gradientBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDatePickerDialog() async {
    // 1. Safe default date
    DateTime initialDate = DateTime(2000, 1, 1);

    // 2. Safe parsing of the current Supabase string
    try {
      final dateValue = userState.userDOB.value;
      if (dateValue.isNotEmpty && dateValue.contains('/')) {
        final parts = dateValue.replaceAll(' ', '').split('/');
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? 2000;
          initialDate = DateTime(year, month, day);
        }
      }
    } catch (e) {
      debugPrint('Date parse error, using default: $e');
    }

    // 3. Show picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.gradientBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // 4. Update Supabase and local state
    if (selectedDate != null) {
      // Format as DD / MM / YYYY
      final formattedDate =
          '${selectedDate.day.toString().padLeft(2, '0')} / ${selectedDate.month.toString().padLeft(2, '0')} / ${selectedDate.year}';
      if (formattedDate != userState.userDOB.value) {
        await _updateProfileField('birth_date', formattedDate);
        await userState.setUserDOB(formattedDate);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Изтрий профила',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Сигурен ли си, че искаш да изтриеш профила си? Това действие е необратимо.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмени',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteSuccess();
              },
              child: const Text(
                'Изтрий',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Профилът е изтрит успешно.'),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Load profile image path from SharedPreferences
  Future<void> _loadProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('profileImagePath');
      if (mounted) {
        setState(() {
          _profileImagePath = savedPath;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile image path: $e');
    }
  }

  /// Show dialog to choose between camera and gallery
  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Избери снимка',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Откъде искаш да качиш снимка?',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getImageFromSource(ImageSource.camera);
              },
              child: const Text(
                'Камера',
                style: TextStyle(
                  color: AppColors.gradientBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getImageFromSource(ImageSource.gallery);
              },
              child: const Text(
                'Галерия',
                style: TextStyle(
                  color: AppColors.gradientBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get image from camera or gallery with optimization
  /// CRITICAL: Uses maxWidth: 500, maxHeight: 500, imageQuality: 85
  Future<void> _getImageFromSource(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      setState(() {
        _isLoadingImage = true;
      });

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _saveProfileImage(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Грешка при качване на снимка'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  /// Save image to Application Documents Directory and persist path
  Future<void> _saveProfileImage(XFile imageFile) async {
    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String profilePhotoPath = '${appDocDir.path}/profile_photo.jpg';

      // Copy file to app documents directory
      final File savedImage = await File(imageFile.path).copy(profilePhotoPath);

      // Save path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', savedImage.path);

      // Update UI
      if (mounted) {
        setState(() {
          _profileImagePath = savedImage.path;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Снимката е качена успешно'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не мога да запиша снимката'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}