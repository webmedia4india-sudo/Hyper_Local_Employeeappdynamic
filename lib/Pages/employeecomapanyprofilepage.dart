import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/company_profile_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../utils/app-colorpage.dart';
import 'package:hyper_local_employee/Pages/employeehomepage.dart';
import 'package:hyper_local_employee/Pages/employeedashboardpage.dart';
import 'package:hyper_local_employee/Pages/alljobspage.dart';
import 'package:hyper_local_employee/Pages/employeeapplicationpage.dart';

class EmployeeCompanyProfilePage extends StatefulWidget {
  const EmployeeCompanyProfilePage({super.key});

  @override
  State<EmployeeCompanyProfilePage> createState() =>
      _EmployeeCompanyProfilePageState();
}

class _EmployeeCompanyProfilePageState extends State<EmployeeCompanyProfilePage> {
  bool _isLoading = true;
  String? _errorMessage;
  CompanyProfileModel? _companyProfile;

  // Cached locations & industries for dropdowns
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _cities = [];
  List<String> _industries = [];

  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.wait([
      _fetchProfile(),
      _fetchDropdownData(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiService.getMyCompanyProfile();
      if (!mounted) return;

      if (res['success'] == true && res['company_profile'] != null) {
        final profileMap = res['company_profile'] as Map<String, dynamic>;
        setState(() {
          _companyProfile = CompanyProfileModel.fromJson(profileMap);
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              res['message']?.toString() ?? 'Failed to load company profile';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading company profile: $e';
        });
      }
    }
  }

  Future<void> _fetchDropdownData() async {
    try {
      final results = await Future.wait([
        ApiService.getStates(),
        ApiService.getCities(),
        ApiService.fetchIndustries(),
      ]);

      if (mounted) {
        setState(() {
          _states = results[0] as List<Map<String, dynamic>>;
          _cities = results[1] as List<Map<String, dynamic>>;
          _industries = results[2] as List<String>;
        });
      }
    } catch (e) {
      debugPrint('[CompanyProfilePage] Error fetching lookup data: $e');
    }
  }

  String _getStateName(int? stateId) {
    if (stateId == null) return '';
    final found = _states.firstWhere(
      (s) => s['id'] == stateId,
      orElse: () => {},
    );
    return found['state_name']?.toString() ?? '';
  }

  String _getCityName(int? cityId) {
    if (cityId == null) return '';
    final found = _cities.firstWhere(
      (c) => c['id'] == cityId,
      orElse: () => {},
    );
    return found['city_name']?.toString() ?? '';
  }

  String get _displayCompanyName {
    if (_companyProfile != null) {
      final name = _companyProfile!.effectiveName;
      if (name.isNotEmpty && name != 'Company Profile') return name;
    }
    final sessionComp = UserSession.companyName;
    if (sessionComp.isNotEmpty) return sessionComp;
    return 'TechNova Solutions';
  }

  String get _displayInitials {
    if (_companyProfile != null) {
      final ini = _companyProfile!.initials;
      if (ini.isNotEmpty) return ini;
    }
    final sessionIni = UserSession.companyInitials;
    if (sessionIni.isNotEmpty) return sessionIni;
    return 'TN';
  }

  String get _displayAddress {
    if (_companyProfile != null) {
      final sName = _getStateName(_companyProfile!.stateId);
      final cName = _getCityName(_companyProfile!.cityId);
      final formatted =
          _companyProfile!.formattedAddress(stateName: sName, cityName: cName);
      if (formatted != 'Address not specified') {
        return formatted;
      }
    }
    return 'Hinjewadi IT Park, Pune';
  }

  bool get _isVerifiedDocument {
    if (_companyProfile == null) return false;
    final cert = _companyProfile!.companyRegistrationCertificate;
    final status = _companyProfile!.status;
    return (cert != null && cert.trim().isNotEmpty) || status == 'active';
  }

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
          "Company Profile",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null && _companyProfile == null) ...[
                      _buildErrorCard(),
                      const SizedBox(height: 16),
                    ],

                    // Company header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          // Company logo
                          _buildLogoWidget(),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayCompanyName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _displayAddress,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 15, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "4.6",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "(250 Reviews)",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Profile Completion Card
                    _buildProfileCompletionCard(),

                    const SizedBox(height: 16),

                    // Menu list card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _profileTile(
                            icon: Icons.badge_outlined,
                            label: "Company Details",
                            onTap: () => _showCompanyDetailsSheet(),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _profileTile(
                            icon: Icons.account_tree_outlined,
                            label: "Branches",
                            onTap: () => _showBranchesSheet(),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _profileTile(
                            icon: Icons.groups_outlined,
                            label: "Departments",
                            onTap: () => _showDepartmentsSheet(),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _profileTile(
                            icon: Icons.photo_library_outlined,
                            label: "Company Photos",
                            onTap: () => _showPhotosSheet(),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _profileTile(
                            icon: Icons.description_outlined,
                            label: "Documents & Verification",
                            trailingBadge:
                                _isVerifiedDocument ? "Verified" : "Pending",
                            onTap: () => _showDocumentsSheet(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Edit Profile button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => _openEditProfileSheet(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomDock(context),
    );
  }

  Widget _buildProfileCompletionCard() {
    final completion = _companyProfile?.profileCompletionPercentage ?? 0;
    final is100 = completion >= 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: is100
              ? AppColors.mint.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                is100 ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                size: 20,
                color: is100 ? AppColors.mint : AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Company Profile Completion",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: is100
                      ? AppColors.mint.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$completion%",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: is100 ? AppColors.mint : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (completion / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                is100 ? AppColors.mint : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            is100
                ? "Your company profile is 100% complete! You are eligible to post jobs."
                : "100% profile completion is required to post jobs. Please complete missing information in Overview, Address, Contact, and Verification.",
            style: TextStyle(
              fontSize: 12,
              color: is100 ? AppColors.mint : AppColors.textSecondary,
              fontWeight: is100 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget() {
    final logoPath = _companyProfile?.companyLogo;
    final hasLogo = logoPath != null && logoPath.trim().isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: hasLogo
              ? Image.network(
                  ApiService.resolveImageUrl(logoPath),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Text(
                    _displayInitials,
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Text(
                  _displayInitials,
                  style: const TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: InkWell(
            onTap: () => _showLogoUploadDialog(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primaryDeep,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? 'Failed to load profile',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadAllData,
            child: const Text('Retry',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String label,
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
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
            if (trailingBadge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trailingBadge == "Verified"
                      ? AppColors.mintSoft
                      : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailingBadge,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: trailingBadge == "Verified"
                        ? AppColors.mint
                        : const Color(0xFF856404),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ] else
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // BOTTOM SHEETS & ACTIONS
  // =========================================================================

  /// 1. Company Details Modal Sheet
  void _showCompanyDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildBottomSheetContainer(
        title: "Company Details",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                "Legal Name", _companyProfile?.legalName ?? 'Not specified'),
            _buildDetailRow("Display Name",
                _companyProfile?.displayName ?? 'Not specified'),
            _buildDetailRow("Organization Type",
                _companyProfile?.organizationType ?? 'Not specified'),
            _buildDetailRow("Industry Domain",
                _companyProfile?.industryDomain ?? 'Not specified'),
            _buildDetailRow("Company Size",
                _companyProfile?.companySize ?? 'Not specified'),
            _buildDetailRow("Date of Incorporation",
                _companyProfile?.dateOfIncorporation ?? 'Not specified'),
            _buildDetailRow("Official Website",
                _companyProfile?.officialWebsite ?? 'Not specified'),
            _buildDetailRow("Company Tagline",
                _companyProfile?.companyTagline ?? 'Not specified'),
            _buildDetailRow("PAN",
                _companyProfile?.organizationPan ?? 'Not specified'),
            _buildDetailRow("GSTIN",
                _companyProfile?.gstinNumber ?? 'Not specified'),
            _buildDetailRow("CIN", _companyProfile?.cin ?? 'Not specified'),
            _buildDetailRow("Official Email",
                _companyProfile?.officialCompanyEmail ?? 'Not specified'),
            _buildDetailRow("Phone / WhatsApp",
                _companyProfile?.companyMobileWhatsapp ?? 'Not specified'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openEditProfileSheet();
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit Company Details"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Branches Sheet
  void _showBranchesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildBottomSheetContainer(
        title: "Company Branches",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _companyProfile?.branchTitle ?? "Main Branch / HQ",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_companyProfile?.isCorporateHq == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.mintSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Corporate HQ",
                            style: TextStyle(
                              color: AppColors.mint,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _displayAddress,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (_companyProfile?.branchPhone != null &&
                      _companyProfile!.branchPhone!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          _companyProfile!.branchPhone!,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openEditProfileSheet();
                },
                icon: const Icon(Icons.edit_location_alt, size: 18),
                label: const Text("Edit Branch Details"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Departments Sheet
  void _showDepartmentsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildBottomSheetContainer(
        title: "Departments",
        child: Column(
          children: [
            const Icon(Icons.groups_outlined,
                size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              "Departments & Teams",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage hiring departments and recruiters for your organization.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                "Human Resources",
                "Technology",
                "Operations",
                "Sales & Marketing",
                "Finance"
              ].map((dept) {
                return Chip(
                  label: Text(dept,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 4. Photos Sheet
  void _showPhotosSheet() {
    final logoPath = _companyProfile?.companyLogo;
    final bannerPath = _companyProfile?.bannerUrl;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildBottomSheetContainer(
        title: "Company Photos & Brand",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Company Logo",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: (logoPath != null && logoPath.isNotEmpty)
                      ? Image.network(
                          ApiService.resolveImageUrl(logoPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            _displayInitials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        )
                      : Text(
                          _displayInitials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showLogoUploadDialog();
                  },
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text("Change Logo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            if (bannerPath != null && bannerPath.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("Company Banner",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  ApiService.resolveImageUrl(bannerPath),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 5. Documents & Verification Sheet
  void _showDocumentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DocumentsUploadSheet(
        companyProfile: _companyProfile,
        onUploaded: (updated) {
          setState(() {
            _companyProfile = updated;
          });
        },
      ),
    );
  }

  /// Quick Logo Upload Dialog
  Future<void> _showLogoUploadDialog() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Uploading company logo..."),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final res = await ApiService.uploadCompanyDocuments(
        logoPath: image.path,
        logoFileName: image.name,
      );

      if (!mounted) return;

      if (res['success'] == true && res['company_profile'] != null) {
        final profileMap = res['company_profile'] as Map<String, dynamic>;
        setState(() {
          _companyProfile = CompanyProfileModel.fromJson(profileMap);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.mint,
            content: Text("Company logo updated successfully!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(res['message']?.toString() ?? "Failed to upload logo"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text("Upload error: $e"),
        ),
      );
    }
  }

  /// Open Complete Edit Company Profile Form Sheet
  void _openEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditCompanyProfileSheet(
        initialProfile: _companyProfile,
        states: _states,
        cities: _cities,
        industries: _industries,
        onProfileUpdated: (updated) {
          setState(() {
            _companyProfile = updated;
          });
        },
      ),
    );
  }

  Widget _buildBottomSheetContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.divider),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(context, Icons.style_rounded, "Cards", 0,
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeHomePage()),
                );
              }),
              _buildDockItem(context, Icons.dashboard_rounded, "Dashboard", 1,
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EmployeeDashboardPage()),
                );
              }),
              _buildDockItem(context, Icons.work_rounded, "Jobs", 2, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllJobsPage()),
                );
              }),
              _buildDockItem(
                  context, Icons.description_rounded, "Applications", 3,
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EmployeeApplicationPage()),
                );
              }),
              _buildDockItem(context, Icons.person_rounded, "Profile", 4,
                  onTap: () {
                // Already on Company Profile page
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(
    BuildContext context,
    IconData icon,
    String label,
    int index, {
    required VoidCallback onTap,
  }) {
    final bool isActive = index == 4;
    final Color color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// EDIT COMPANY PROFILE BOTTOM SHEET
// ===========================================================================
class _EditCompanyProfileSheet extends StatefulWidget {
  final CompanyProfileModel? initialProfile;
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> cities;
  final List<String> industries;
  final ValueChanged<CompanyProfileModel> onProfileUpdated;

  const _EditCompanyProfileSheet({
    required this.initialProfile,
    required this.states,
    required this.cities,
    required this.industries,
    required this.onProfileUpdated,
  });

  @override
  State<_EditCompanyProfileSheet> createState() =>
      _EditCompanyProfileSheetState();
}

class _EditCompanyProfileSheetState extends State<_EditCompanyProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  late TextEditingController _legalNameCtrl;
  late TextEditingController _displayNameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _panCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _regNumberCtrl;
  late TextEditingController _cinCtrl;
  late TextEditingController _llpinCtrl;
  late TextEditingController _branchTitleCtrl;
  late TextEditingController _address1Ctrl;
  late TextEditingController _address2Ctrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _officialEmailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _landlineCtrl;
  late TextEditingController _branchPhoneCtrl;
  late TextEditingController _contactPersonCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _facebookCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _twitterCtrl;
  late TextEditingController _dateOfIncorpCtrl;

  // Dropdown values
  String? _selectedOrgType;
  String? _selectedIndustry;
  String? _selectedCompanySize;
  String? _selectedCompanyType;
  int? _selectedStateId;
  int? _selectedCityId;
  bool _isCorporateHq = false;

  final List<String> _orgTypes = const [
    'Private Limited Company',
    'Public Limited Company',
    'Limited Liability Partnership (LLP)',
    'Partnership Firm',
    'Sole Proprietorship',
    'One Person Company (OPC)',
    'Non-Governmental Organization (NGO) / Trust',
    'Other',
  ];

  final List<String> _companySizes = const [
    '1-10 employees',
    '11-50 employees',
    '51-200 employees',
    '201-500 employees',
    '501-1000 employees',
    '1000+ employees',
  ];

  final List<String> _companyTypes = const [
    'Corporate',
    'Startup',
    'SME / SMB',
    'Enterprise',
    'Government',
    'Agency',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;

    _legalNameCtrl = TextEditingController(text: p?.legalName ?? '');
    _displayNameCtrl = TextEditingController(text: p?.displayName ?? '');
    _taglineCtrl = TextEditingController(text: p?.companyTagline ?? '');
    _descriptionCtrl = TextEditingController(text: p?.companyDescription ?? '');
    _websiteCtrl = TextEditingController(text: p?.officialWebsite ?? '');
    _panCtrl = TextEditingController(text: p?.organizationPan ?? '');
    _gstinCtrl = TextEditingController(text: p?.gstinNumber ?? '');
    _regNumberCtrl =
        TextEditingController(text: p?.registrationNumber ?? '');
    _cinCtrl = TextEditingController(text: p?.cin ?? '');
    _llpinCtrl = TextEditingController(text: p?.llpin ?? '');
    _branchTitleCtrl = TextEditingController(text: p?.branchTitle ?? '');
    _address1Ctrl = TextEditingController(text: p?.addressLine1 ?? '');
    _address2Ctrl = TextEditingController(text: p?.addressLine2 ?? '');
    _countryCtrl = TextEditingController(text: p?.country ?? 'India');
    _pincodeCtrl = TextEditingController(text: p?.pincode ?? '');
    _officialEmailCtrl =
        TextEditingController(text: p?.officialCompanyEmail ?? '');
    _phoneCtrl =
        TextEditingController(text: p?.companyMobileWhatsapp ?? '');
    _landlineCtrl = TextEditingController(text: p?.landlinePhone ?? '');
    _branchPhoneCtrl = TextEditingController(text: p?.branchPhone ?? '');
    _contactPersonCtrl =
        TextEditingController(text: p?.authorizedContactPerson ?? '');
    _designationCtrl =
        TextEditingController(text: p?.designationRole ?? '');
    _linkedinCtrl =
        TextEditingController(text: p?.linkedinCompanyPage ?? '');
    _facebookCtrl = TextEditingController(text: p?.facebookPageUrl ?? '');
    _instagramCtrl =
        TextEditingController(text: p?.instagramProfileUrl ?? '');
    _twitterCtrl =
        TextEditingController(text: p?.twitterXProfileUrl ?? '');
    _dateOfIncorpCtrl =
        TextEditingController(text: p?.dateOfIncorporation ?? '');

    _selectedOrgType = p?.organizationType;
    _selectedIndustry = p?.industryDomain;
    _selectedCompanySize = p?.companySize;
    _selectedCompanyType = p?.companyType;
    _selectedStateId = p?.stateId;
    _selectedCityId = p?.cityId;
    _isCorporateHq = p?.isCorporateHq ?? false;
  }

  @override
  void dispose() {
    _legalNameCtrl.dispose();
    _displayNameCtrl.dispose();
    _taglineCtrl.dispose();
    _descriptionCtrl.dispose();
    _websiteCtrl.dispose();
    _panCtrl.dispose();
    _gstinCtrl.dispose();
    _regNumberCtrl.dispose();
    _cinCtrl.dispose();
    _llpinCtrl.dispose();
    _branchTitleCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _countryCtrl.dispose();
    _pincodeCtrl.dispose();
    _officialEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _landlineCtrl.dispose();
    _branchPhoneCtrl.dispose();
    _contactPersonCtrl.dispose();
    _designationCtrl.dispose();
    _linkedinCtrl.dispose();
    _facebookCtrl.dispose();
    _instagramCtrl.dispose();
    _twitterCtrl.dispose();
    _dateOfIncorpCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCities {
    if (_selectedStateId == null) return widget.cities;
    return widget.cities
        .where((c) => c['state_id'] == _selectedStateId)
        .toList();
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    if (_dateOfIncorpCtrl.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_dateOfIncorpCtrl.text);
      if (parsed != null) initial = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dateOfIncorpCtrl.text = formatted;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final payload = <String, dynamic>{
      'legal_name': _legalNameCtrl.text.trim(),
      'display_name': _displayNameCtrl.text.trim(),
      if (_selectedOrgType != null && _selectedOrgType!.isNotEmpty)
        'organization_type': _selectedOrgType,
      if (_selectedIndustry != null && _selectedIndustry!.isNotEmpty)
        'industry_domain': _selectedIndustry,
      if (_dateOfIncorpCtrl.text.trim().isNotEmpty)
        'date_of_incorporation': _dateOfIncorpCtrl.text.trim(),
      if (_panCtrl.text.trim().isNotEmpty)
        'organization_pan': _panCtrl.text.trim().toUpperCase(),
      if (_gstinCtrl.text.trim().isNotEmpty)
        'gstin_number': _gstinCtrl.text.trim().toUpperCase(),
      if (_regNumberCtrl.text.trim().isNotEmpty)
        'registration_number': _regNumberCtrl.text.trim(),
      if (_cinCtrl.text.trim().isNotEmpty) 'cin': _cinCtrl.text.trim(),
      if (_llpinCtrl.text.trim().isNotEmpty) 'llpin': _llpinCtrl.text.trim(),
      if (_selectedCompanySize != null && _selectedCompanySize!.isNotEmpty)
        'company_size': _selectedCompanySize,
      if (_selectedCompanyType != null && _selectedCompanyType!.isNotEmpty)
        'company_type': _selectedCompanyType,
      if (_taglineCtrl.text.trim().isNotEmpty)
        'company_tagline': _taglineCtrl.text.trim(),
      if (_descriptionCtrl.text.trim().isNotEmpty)
        'company_description': _descriptionCtrl.text.trim(),
      if (_websiteCtrl.text.trim().isNotEmpty)
        'official_website': _websiteCtrl.text.trim(),
      if (_branchTitleCtrl.text.trim().isNotEmpty)
        'branch_title': _branchTitleCtrl.text.trim(),
      'is_corporate_hq': _isCorporateHq ? 1 : 0,
      if (_address1Ctrl.text.trim().isNotEmpty)
        'address_line_1': _address1Ctrl.text.trim(),
      if (_address2Ctrl.text.trim().isNotEmpty)
        'address_line_2': _address2Ctrl.text.trim(),
      if (_countryCtrl.text.trim().isNotEmpty)
        'country': _countryCtrl.text.trim(),
      if (_selectedStateId != null) 'state_id': _selectedStateId,
      if (_selectedCityId != null) 'city_id': _selectedCityId,
      if (_pincodeCtrl.text.trim().isNotEmpty)
        'pincode': _pincodeCtrl.text.trim(),
      if (_officialEmailCtrl.text.trim().isNotEmpty)
        'official_company_email': _officialEmailCtrl.text.trim().toLowerCase(),
      if (_phoneCtrl.text.trim().isNotEmpty)
        'company_mobile_whatsapp': _phoneCtrl.text.trim(),
      if (_landlineCtrl.text.trim().isNotEmpty)
        'landline_phone': _landlineCtrl.text.trim(),
      if (_branchPhoneCtrl.text.trim().isNotEmpty)
        'branch_phone': _branchPhoneCtrl.text.trim(),
      if (_contactPersonCtrl.text.trim().isNotEmpty)
        'authorized_contact_person': _contactPersonCtrl.text.trim(),
      if (_designationCtrl.text.trim().isNotEmpty)
        'designation_role': _designationCtrl.text.trim(),
      if (_linkedinCtrl.text.trim().isNotEmpty)
        'linkedin_company_page': _linkedinCtrl.text.trim(),
      if (_facebookCtrl.text.trim().isNotEmpty)
        'facebook_page_url': _facebookCtrl.text.trim(),
      if (_instagramCtrl.text.trim().isNotEmpty)
        'instagram_profile_url': _instagramCtrl.text.trim(),
      if (_twitterCtrl.text.trim().isNotEmpty)
        'twitter_x_profile_url': _twitterCtrl.text.trim(),
    };

    try {
      final res = await ApiService.updateMyCompanyProfile(payload);
      if (!mounted) return;

      if (res['success'] == true && res['company_profile'] != null) {
        final updated =
            CompanyProfileModel.fromJson(res['company_profile'] as Map<String, dynamic>);
        widget.onProfileUpdated(updated);

        // Update UserSession company name if changed
        if (updated.displayName != null && updated.displayName!.isNotEmpty) {
          UserSession.saveSession(
            employee: UserSession.currentEmployee,
            token: UserSession.token,
          );
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.mint,
            content: Text("Company profile updated successfully!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(res['message']?.toString() ??
                "Failed to update company profile"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text("Update error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Company Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionHeader("1. Company Overview"),
                    _inputField(
                      label: "Legal Name *",
                      hint: "e.g. TechNova Solutions Pvt Ltd",
                      controller: _legalNameCtrl,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Legal Name is required" : null,
                    ),
                    _inputField(
                      label: "Display Name *",
                      hint: "e.g. TechNova",
                      controller: _displayNameCtrl,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Display Name is required" : null,
                    ),
                    _dropdownField(
                      label: "Organization Type",
                      hint: "Select organization type",
                      value: _selectedOrgType,
                      items: _orgTypes,
                      onChanged: (val) => setState(() => _selectedOrgType = val),
                    ),
                    _dropdownField(
                      label: "Industry Domain",
                      hint: "Select industry",
                      value: _selectedIndustry,
                      items: widget.industries.isNotEmpty
                          ? widget.industries
                          : [
                              "IT & Software",
                              "Manufacturing",
                              "Healthcare",
                              "Retail",
                              "Finance",
                              "Logistics",
                              "Education"
                            ],
                      onChanged: (val) => setState(() => _selectedIndustry = val),
                    ),
                    _dateField(
                      label: "Date of Incorporation",
                      hint: "YYYY-MM-DD",
                      controller: _dateOfIncorpCtrl,
                      onTap: _pickDate,
                    ),
                    _dropdownField(
                      label: "Company Size",
                      hint: "Select company size",
                      value: _selectedCompanySize,
                      items: _companySizes,
                      onChanged: (val) => setState(() => _selectedCompanySize = val),
                    ),
                    _dropdownField(
                      label: "Company Type",
                      hint: "Select company type",
                      value: _selectedCompanyType,
                      items: _companyTypes,
                      onChanged: (val) => setState(() => _selectedCompanyType = val),
                    ),
                    _inputField(
                      label: "Company Tagline",
                      hint: "e.g. Innovating Hyper Local Solutions",
                      controller: _taglineCtrl,
                    ),
                    _inputField(
                      label: "Official Website",
                      hint: "https://www.example.com",
                      controller: _websiteCtrl,
                      keyboardType: TextInputType.url,
                    ),
                    _inputField(
                      label: "Company Description",
                      hint: "Brief description of the company and services",
                      controller: _descriptionCtrl,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),
                    _sectionHeader("2. Statutory & Registration Details"),
                    _inputField(
                      label: "Organization PAN",
                      hint: "ABCDE1234F",
                      controller: _panCtrl,
                    ),
                    _inputField(
                      label: "GSTIN Number",
                      hint: "22AAAAA0000A1Z5",
                      controller: _gstinCtrl,
                    ),
                    _inputField(
                      label: "Registration Number",
                      hint: "e.g. U12345MH2020PTC123456",
                      controller: _regNumberCtrl,
                    ),
                    _inputField(
                      label: "Corporate Identity Number (CIN)",
                      hint: "e.g. CIN",
                      controller: _cinCtrl,
                    ),
                    _inputField(
                      label: "LLPIN (for LLPs)",
                      hint: "e.g. AAA-1234",
                      controller: _llpinCtrl,
                    ),

                    const SizedBox(height: 16),
                    _sectionHeader("3. Address & Branch"),
                    _inputField(
                      label: "Branch Title",
                      hint: "e.g. Head Office / Hinjewadi Branch",
                      controller: _branchTitleCtrl,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Is Corporate Headquarters",
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      activeThumbColor: AppColors.primary,
                      value: _isCorporateHq,
                      onChanged: (v) => setState(() => _isCorporateHq = v),
                    ),
                    _inputField(
                      label: "Address Line 1",
                      hint: "Building, Street address",
                      controller: _address1Ctrl,
                    ),
                    _inputField(
                      label: "Address Line 2",
                      hint: "Area, Landmark",
                      controller: _address2Ctrl,
                    ),
                    _stateDropdown(),
                    _cityDropdown(),
                    _inputField(
                      label: "Pincode",
                      hint: "e.g. 411057",
                      controller: _pincodeCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    _inputField(
                      label: "Country",
                      hint: "India",
                      controller: _countryCtrl,
                    ),

                    const SizedBox(height: 16),
                    _sectionHeader("4. Contact Information"),
                    _inputField(
                      label: "Official Company Email",
                      hint: "contact@company.com",
                      controller: _officialEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _inputField(
                      label: "Mobile / WhatsApp",
                      hint: "e.g. 9876543210",
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    _inputField(
                      label: "Landline Phone",
                      hint: "e.g. 020-12345678",
                      controller: _landlineCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    _inputField(
                      label: "Branch Phone",
                      hint: "e.g. 020-87654321",
                      controller: _branchPhoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    _inputField(
                      label: "Authorized Contact Person",
                      hint: "e.g. Rajesh Sharma",
                      controller: _contactPersonCtrl,
                    ),
                    _inputField(
                      label: "Designation / Role",
                      hint: "e.g. Managing Director / HR Head",
                      controller: _designationCtrl,
                    ),

                    const SizedBox(height: 16),
                    _sectionHeader("5. Social Media Pages"),
                    _inputField(
                      label: "LinkedIn Company Page",
                      hint: "https://linkedin.com/company/...",
                      controller: _linkedinCtrl,
                      keyboardType: TextInputType.url,
                    ),
                    _inputField(
                      label: "Facebook Page URL",
                      hint: "https://facebook.com/...",
                      controller: _facebookCtrl,
                      keyboardType: TextInputType.url,
                    ),
                    _inputField(
                      label: "Instagram Profile URL",
                      hint: "https://instagram.com/...",
                      controller: _instagramCtrl,
                      keyboardType: TextInputType.url,
                    ),
                    _inputField(
                      label: "Twitter / X Profile URL",
                      hint: "https://x.com/...",
                      controller: _twitterCtrl,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: IgnorePointer(
              child: TextFormField(
                controller: controller,
                style:
                    const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  suffixIcon: const Icon(Icons.calendar_today,
                      size: 18, color: AppColors.primary),
                  hintStyle:
                      const TextStyle(fontSize: 13, color: AppColors.textHint),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final effectiveValue = items.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: effectiveValue,
            isExpanded: true,
            hint: Text(hint,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textHint)),
            style:
                const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _stateDropdown() {
    final validState =
        widget.states.any((s) => s['id'] == _selectedStateId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "State",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            initialValue: validState ? _selectedStateId : null,
            isExpanded: true,
            hint: const Text("Select State",
                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
            style:
                const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: widget.states.map((s) {
              return DropdownMenuItem<int>(
                value: s['id'] as int,
                child: Text(s['state_name']?.toString() ?? ''),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedStateId = val;
                _selectedCityId = null; // reset city when state changes
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _cityDropdown() {
    final filtered = _filteredCities;
    final validCity = filtered.any((c) => c['id'] == _selectedCityId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "City",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            initialValue: validCity ? _selectedCityId : null,
            isExpanded: true,
            hint: const Text("Select City",
                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
            style:
                const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: filtered.map((c) {
              return DropdownMenuItem<int>(
                value: c['id'] as int,
                child: Text(c['city_name']?.toString() ?? ''),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCityId = val;
              });
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// DOCUMENTS & VERIFICATION UPLOAD SHEET
// ===========================================================================
class _DocumentsUploadSheet extends StatefulWidget {
  final CompanyProfileModel? companyProfile;
  final ValueChanged<CompanyProfileModel> onUploaded;

  const _DocumentsUploadSheet({
    required this.companyProfile,
    required this.onUploaded,
  });

  @override
  State<_DocumentsUploadSheet> createState() => _DocumentsUploadSheetState();
}

class _DocumentsUploadSheetState extends State<_DocumentsUploadSheet> {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedLogo;
  PlatformFile? _selectedCertificate;

  bool _isUploading = false;

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedLogo = image;
      });
    }
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result.isNotEmpty) {
      setState(() {
        _selectedCertificate = result.first;
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (_selectedLogo == null && _selectedCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a logo or certificate to upload."),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final certBytes = _selectedCertificate != null
          ? await _selectedCertificate!.xFile.readAsBytes()
          : null;

      final res = await ApiService.uploadCompanyDocuments(
        logoPath: _selectedLogo?.path,
        logoBytes: _selectedLogo != null ? await _selectedLogo!.readAsBytes() : null,
        logoFileName: _selectedLogo?.name,
        certPath: _selectedCertificate?.path,
        certBytes: certBytes,
        certFileName: _selectedCertificate?.name,
      );

      if (!mounted) return;

      if (res['success'] == true && res['company_profile'] != null) {
        final updated =
            CompanyProfileModel.fromJson(res['company_profile'] as Map<String, dynamic>);
        widget.onUploaded(updated);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.mint,
            content: Text("Documents uploaded successfully!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(res['message']?.toString() ?? "Upload failed"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text("Upload error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLogo = widget.companyProfile?.companyLogo;
    final currentCert =
        widget.companyProfile?.companyRegistrationCertificate;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Documents & Verification",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.divider),

              // 1. Company Logo section
              const Text("1. Company Logo",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: _selectedLogo != null
                          ? (kIsWeb
                              ? FutureBuilder<Uint8List>(
                                  future: _selectedLogo!.readAsBytes(),
                                  builder: (_, snap) => snap.hasData
                                      ? Image.memory(snap.data!,
                                          fit: BoxFit.cover,
                                          width: 54,
                                          height: 54)
                                      : const SizedBox.shrink(),
                                )
                              : Image.file(File(_selectedLogo!.path),
                                  fit: BoxFit.cover, width: 54, height: 54))
                          : (currentLogo != null && currentLogo.isNotEmpty
                              ? Image.network(
                                  ApiService.resolveImageUrl(currentLogo),
                                  fit: BoxFit.cover,
                                  width: 54,
                                  height: 54,
                                  errorBuilder: (_, _, _) => const Icon(
                                      Icons.business,
                                      color: Colors.white),
                                )
                              : const Icon(Icons.business, color: Colors.white)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLogo != null
                                ? _selectedLogo!.name
                                : (currentLogo != null && currentLogo.isNotEmpty
                                    ? "Logo uploaded"
                                    : "No logo selected"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "PNG, JPG or WEBP (Max 5MB)",
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _pickLogo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(_selectedLogo != null || currentLogo != null
                          ? "Change"
                          : "Select"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Company Registration Certificate section
              const Text("2. Registration Certificate",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.verified_user_rounded,
                          color: AppColors.mint, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCertificate != null
                                ? _selectedCertificate!.name
                                : (currentCert != null && currentCert.isNotEmpty
                                    ? "Certificate uploaded"
                                    : "Certificate not uploaded"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "PDF, JPG or PNG (Max 5MB)",
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _pickCertificate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(_selectedCertificate != null || currentCert != null
                          ? "Change"
                          : "Upload"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadDocuments,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_rounded, size: 20),
                  label: Text(_isUploading ? "Uploading..." : "Save Documents"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}