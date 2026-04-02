import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../providers/productivity_provider.dart';
import 'report_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  String _name = '';
  String _email = '';
  String _profilePhoto = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _apiService.getProfile();
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _name = profile['name'] ?? prefs.getString('user_name') ?? 'User';
        _email = profile['email'] ?? prefs.getString('user_email') ?? '';
        _profilePhoto = profile['profilePhoto'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _name = prefs.getString('user_name') ?? 'User';
        _email = prefs.getString('user_email') ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    try {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      await _apiService.updateProfile(profilePhoto: base64Image);

      setState(() {
        _profilePhoto = base64Image;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated!'),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.softPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    await _apiService.logout();
    if (mounted) {
      context.read<ProductivityProvider>().clearData();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Profile', style: AppTextStyles.h1),
                    ),
                    const SizedBox(height: 32),

                    // Avatar & Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppShadows.buttonShadow,
                      ),
                      child: Column(
                        children: [
                          // Profile Photo
                          GestureDetector(
                            onTap: _pickAndUploadPhoto,
                            child: Stack(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _profilePhoto.isNotEmpty &&
                                            _profilePhoto.startsWith('data:image')
                                        ? Image.memory(
                                            base64Decode(
                                                _profilePhoto.split(',').last),
                                            fit: BoxFit.cover,
                                            width: 88,
                                            height: 88,
                                          )
                                        : const Icon(
                                            Icons.person_rounded,
                                            size: 44,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: AppShadows.softShadow,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _name,
                            style: AppTextStyles.h2.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Stats row from provider
                          Consumer<ProductivityProvider>(
                            builder: (context, provider, _) {
                              final totalSlots = provider.slots.length;
                              final productiveSlots = provider.slots
                                  .where((s) => s.type == ProductivityType.productive)
                                  .length;
                              final prodPercent = totalSlots > 0
                                  ? ((productiveSlots / totalSlots) * 100).toStringAsFixed(0)
                                  : '0';
                              final tasksCompleted = provider.tasks
                                  .where((t) => t.isCompleted)
                                  .length;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _profileStat('$totalSlots', 'Slots Today'),
                                    Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.white24),
                                    _profileStat('$prodPercent%', 'Focus'),
                                    Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.white24),
                                    _profileStat('$tasksCompleted', 'Tasks Done'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Menu Items
                    _menuItem(Icons.bar_chart_rounded, 'Productivity Report',
                        AppColors.primaryBlue, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    _menuItem(Icons.category_rounded, 'Manage Categories',
                        AppColors.primaryPurple, () {}),
                    const SizedBox(height: 10),
                    _menuItem(Icons.psychology_rounded, 'AI Insights',
                        AppColors.primaryGreen, () {}),
                    const SizedBox(height: 10),
                    _menuItem(Icons.logout_rounded, 'Sign Out',
                        AppColors.softPink, _handleSignOut),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.h3
                .copyWith(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _menuItem(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTextStyles.bodyBold),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
