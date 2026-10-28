import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hyper_local_employee/Pages/candidateprofilepage.dart';
import 'package:hyper_local_employee/services/api_service.dart';
import 'package:hyper_local_employee/services/user_session.dart';

class EmployeeNearbyCandidatesPage extends StatefulWidget {
  const EmployeeNearbyCandidatesPage({super.key});

  @override
  State<EmployeeNearbyCandidatesPage> createState() =>
      _EmployeeNearbyCandidatesPageState();
}

class _EmployeeNearbyCandidatesPageState
    extends State<EmployeeNearbyCandidatesPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;

  List<Map<String, dynamic>> _candidates = [];
  Map<String, dynamic>? _selectedCandidate;
  String _selectedRadius = "10 KM";
  String _selectedArea = "Powai";
  String _searchQuery = "";
  bool _isLoading = false;
  String? _errorMessage;
  double _zoomFactor = 1.0;

  // Map center coordinates (defaults to Amravati, updated from backend/employer profile or area selection)
  double _centerLat = 20.9374;
  double _centerLng = 77.7796;
  double? _employerLat;
  double? _employerLng;

  final List<String> _areaChips = const [
    "Powai",
    "Andheri East",
    "Kurla",
    "Ghatkopar",
    "Rajapeth",
    "MIDC"
  ];

  final List<String> _radii = const ["5 KM", "10 KM", "15 KM", "25 KM", "50 KM"];

  final Map<String, List<double>> _areaCoordinates = const {
    "Powai": [19.1176, 72.9060],
    "Andheri East": [19.1136, 72.8697],
    "Kurla": [19.0726, 72.8845],
    "Ghatkopar": [19.0860, 72.9090],
    "Rajapeth": [20.9258, 77.7554],
    "MIDC": [20.9421, 77.7818],
  };

  final List<Color> _markerColors = const [
    Color(0xFF1E3AE2), // Royal Blue
    Color(0xFF0284C7), // Light Blue
    Color(0xFFEF4444), // Pink/Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Mint Green
  ];

  double get _currentRadiusKm {
    final clean = _selectedRadius.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 10.0;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fetchNearbyCandidates();
  }

  Future<void> _fetchNearbyCandidates() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final double r = _currentRadiusKm;
      final int employerId = await UserSession.getEmployerId();

      // Fetch candidates dynamically from registered backend endpoint:
      // GET /api/jobpost/nearby-users?employer_id=$employerId&radius=$radius
      final response = await ApiService.fetchNearbyCandidates(
        employerId: employerId,
        radius: r,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final List rawList = response['users'] ?? [];
        final List<Map<String, dynamic>> apiCandidates =
            rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

        final List<Map<String, dynamic>> parsed = [];

        for (int i = 0; i < apiCandidates.length; i++) {
          final c = apiCandidates[i];

          // Read candidate coordinates safely from backend
          final double? userLat = double.tryParse(c['user_latitude']?.toString() ?? '');
          final double? userLng = double.tryParse(c['user_longitude']?.toString() ?? '');

          // Update employer coordinates if provided by backend
          if (c['employer_latitude'] != null && c['employer_longitude'] != null) {
            final double? empLat = double.tryParse(c['employer_latitude'].toString());
            final double? empLng = double.tryParse(c['employer_longitude'].toString());
            if (empLat != null && empLng != null && empLat != 0) {
              _employerLat = empLat;
              _employerLng = empLng;
            }
          }

          // If a candidate has no valid coordinates, do not place at an arbitrary location
          if (userLat == null || userLng == null) {
            continue;
          }

          // Compute normalized map coordinates centered on (_centerLat, _centerLng)
          final double dLatKm = (userLat - _centerLat) * 111.0;
          final double dLngKm = (userLng - _centerLng) * 111.0 * cos(_centerLat * pi / 180.0);
          final double scale = r > 0 ? r : 10.0;

          // Map center corresponds to (0.48, 0.44), circle radius is ~0.34
          final double dx = (0.48 + (dLngKm / scale) * 0.34 * _zoomFactor).clamp(0.08, 0.92);
          final double dy = (0.44 - (dLatKm / scale) * 0.34 * _zoomFactor).clamp(0.12, 0.78);

          final userId = c['user_id'] ?? c['id'] ?? (i + 1);
          final name = (c['name'] ?? c['full_name'] ?? c['userName'] ?? 'Candidate ${i + 1}').toString();
          final role = (c['current_role'] ?? c['role'] ?? c['job_role'] ?? c['industry'] ?? 'Candidate').toString();
          final distVal = c['distance_km'] ?? c['distance'];
          final distStr = distVal != null ? '$distVal km away' : 'Nearby';
          final rating = (c['rating'] ?? '4.5').toString();
          final phone = (c['mobile_no'] ?? c['phone'] ?? '').toString();
          final email = (c['email'] ?? '').toString();
          final address = (c['address'] ?? 'Amravati, MH').toString();

          parsed.add({
            'user_id': userId,
            'name': name,
            'role': role,
            'current_role': role,
            'industry': (c['industry'] ?? 'General').toString(),
            'address': address,
            'email': email,
            'user_latitude': userLat,
            'user_longitude': userLng,
            'distance': distStr,
            'distance_km': distVal,
            'rating': rating,
            'color': _markerColors[i % _markerColors.length],
            'phone': phone,
            'dx': dx,
            'dy': dy,
          });
        }

        setState(() {
          _candidates = parsed;
          _isLoading = false;
          _errorMessage = null;

          // Update selected candidate
          if (_candidates.isNotEmpty) {
            final exists = _selectedCandidate != null &&
                _candidates.any((item) => item['user_id'] == _selectedCandidate!['user_id']);
            if (!exists) {
              _selectedCandidate = _candidates.first;
            }
          } else {
            _selectedCandidate = null;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _candidates = [];
          _selectedCandidate = null;
          _errorMessage = response['message']?.toString().isNotEmpty == true
              ? response['message'].toString()
              : 'Failed to fetch nearby candidates';
        });
      }
    } catch (e) {
      debugPrint('Error loading nearby candidates: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _candidates = [];
          _selectedCandidate = null;
          _errorMessage = 'Error loading candidates: $e';
        });
      }
    }
  }

  void _onAreaSelected(String area) {
    setState(() {
      _selectedArea = area;
      if (_areaCoordinates.containsKey(area)) {
        _centerLat = _areaCoordinates[area]![0];
        _centerLng = _areaCoordinates[area]![1];
      }
    });
    _fetchNearbyCandidates();
  }

  void _onRadiusSelected(String radius) {
    setState(() {
      _selectedRadius = radius;
    });
    _fetchNearbyCandidates();
  }

  void _showRadiusBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Search Radius",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Find candidates available within a specific distance from your location.",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _radii.map((r) {
                  final bool isSelected = _selectedRadius == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (val) {
                      Navigator.pop(ctx);
                      if (val) _onRadiusSelected(r);
                    },
                    selectedColor: const Color(0xFF1E3AE2),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCandidates = _candidates.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final name = (c['name'] as String? ?? '').toLowerCase();
      final role = (c['role'] as String? ?? '').toLowerCase();
      final industry = (c['industry'] as String? ?? '').toLowerCase();
      final address = (c['address'] as String? ?? '').toLowerCase();
      return name.contains(q) || role.contains(q) || industry.contains(q) || address.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3AE2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Candidates Near You Map",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchNearbyCandidates,
            tooltip: 'Refresh',
            icon: const Icon(Icons.whatshot_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Grid Map Background Canvas
          Positioned.fill(
            child: CustomPaint(
              painter: _RefMapGridPainter(zoomFactor: _zoomFactor),
            ),
          ),

          // 2. Map Candidate Markers (Colored Letter Pins with Pointer Stem)
          ...filteredCandidates.map((candidate) {
            final double dx = (candidate['dx'] as num?)?.toDouble() ?? 0.5;
            final double dy = (candidate['dy'] as num?)?.toDouble() ?? 0.5;
            final Color color = candidate['color'] as Color? ?? const Color(0xFF1E3AE2);
            final String name = candidate['name'] as String? ?? '';
            final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'C';

            final bool isSelected = _selectedCandidate != null &&
                _selectedCandidate!['user_id'] == candidate['user_id'];

            return Positioned(
              left: MediaQuery.of(context).size.width * dx - 20,
              top: (MediaQuery.of(context).size.height - 180) * dy - 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCandidate = candidate;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isSelected ? 42 : 36,
                      height: isSelected ? 42 : 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.white,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: isSelected ? 12 : 8,
                            spreadRadius: isSelected ? 2 : 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSelected ? 17 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: color,
                      size: isSelected ? 24 : 18,
                    ),
                  ],
                ),
              ),
            );
          }),

          // 3. Search this area Button Pill
          Positioned(
            top: 116,
            right: 16,
            child: GestureDetector(
              onTap: _fetchNearbyCandidates,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E3AE2).withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Color(0xFF1E3AE2), size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Search this area",
                      style: TextStyle(
                        color: Color(0xFF1E3AE2),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Map Control Action Column (Zoom & Location Controls)
          Positioned(
            right: 16,
            top: 175,
            child: Column(
              children: [
                _buildMapControlBtn(Icons.add, () {
                  setState(() {
                    _zoomFactor = (_zoomFactor * 1.25).clamp(0.5, 3.0);
                  });
                }),
                const SizedBox(height: 8),
                _buildMapControlBtn(Icons.remove, () {
                  setState(() {
                    _zoomFactor = (_zoomFactor / 1.25).clamp(0.5, 3.0);
                  });
                }),
                const SizedBox(height: 8),
                _buildMapControlBtn(Icons.center_focus_strong_rounded, () {
                  setState(() {
                    _zoomFactor = 1.0;
                    if (_employerLat != null && _employerLng != null) {
                      _centerLat = _employerLat!;
                      _centerLng = _employerLng!;
                    }
                  });
                }),
                const SizedBox(height: 8),
                _buildMapControlBtn(Icons.my_location_rounded, () {
                  setState(() {
                    if (_employerLat != null && _employerLng != null) {
                      _centerLat = _employerLat!;
                      _centerLng = _employerLng!;
                    }
                  });
                  _fetchNearbyCandidates();
                }),
              ],
            ),
          ),

          // 5. Top Floating Search Bar
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF1E3AE2), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search area, company, or job...',
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 13.5),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: Color(0xFF1E3AE2), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Filter Radius',
                    onPressed: _showRadiusBottomSheet,
                  ),
                ],
              ),
            ),
          ),

          // 6. Area Filter Chips Row
          Positioned(
            top: 68,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Radius Selector Chip
                  GestureDetector(
                    onTap: _showRadiusBottomSheet,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3AE2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3AE2).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.radar_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            _selectedRadius,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  ..._areaChips.map((area) {
                    final bool isSel = _selectedArea == area;
                    return GestureDetector(
                      onTap: () => _onAreaSelected(area),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? const Color(0xFF1E3AE2) : const Color(0xFFCBD5E1),
                            width: isSel ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          area,
                          style: TextStyle(
                            color: isSel ? const Color(0xFF1E3AE2) : const Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 7. Loading Indicator Pill
          if (_isLoading)
            Positioned(
              top: 116,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3AE2)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Finding candidates...",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF1E3AE2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 8. Empty State Card (When no candidates found in radius)
          if (!_isLoading && _candidates.isEmpty && _errorMessage == null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3AE2).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_search_rounded,
                          color: Color(0xFF1E3AE2),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "No candidates found in this area",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No registered candidates found within $_selectedRadius of $_selectedArea. Try expanding your search radius.",
                      style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: ["15 KM", "25 KM", "50 KM"].map((r) {
                        return OutlinedButton(
                          onPressed: () => _onRadiusSelected(r),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            side: const BorderSide(color: Color(0xFF1E3AE2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Try $r",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3AE2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // 9. Error State Card
          if (!_isLoading && _errorMessage != null && _candidates.isEmpty)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchNearbyCandidates,
                      child: const Text("Retry", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // 10. Bottom Selected Candidate Card (When candidate marker is selected)
          if (_selectedCandidate != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Candidate Letter Square Avatar
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _selectedCandidate!['color'] as Color? ?? const Color(0xFF1E3AE2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                (_selectedCandidate!['name'] as String? ?? 'C').substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedCandidate!['role'] as String? ?? _selectedCandidate!['name'] as String? ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified_rounded, color: Color(0xFF1E3AE2), size: 18),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.bookmark_border_rounded, color: Colors.black38, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedCandidate!['name'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Color(0xFF1E3AE2), size: 14),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        "${_selectedCandidate!['distance']} • ${(_selectedCandidate!['address'] as String).isNotEmpty ? _selectedCandidate!['address'] : 'Amravati, MH'}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tag Pills
                      Row(
                        children: [
                          _buildTagPill(Icons.work_outline_rounded, "0-2 yrs"),
                          const SizedBox(width: 8),
                          _buildTagPill(Icons.access_time_rounded, "Full-time"),
                          const Spacer(),
                          const Text(
                            "Available now",
                            style: TextStyle(color: Colors.black38, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Bottom Row: Clean status left + View Profile button right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Available Candidate",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedCandidate != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CandidateProfilePage(
                                      candidate: _selectedCandidate!,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3AE2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "View Profile",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E3AE2), size: 20),
      ),
    );
  }

  Widget _buildTagPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── REFERENCE UI GRID MAP PAINTER ──
class _RefMapGridPainter extends CustomPainter {
  final double zoomFactor;

  _RefMapGridPainter({this.zoomFactor = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Clean Light Background Base
    final bgPaint = Paint()..color = const Color(0xFFF3F6FC);
    canvas.drawRect(rect, bgPaint);

    // 2. Faint Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double step = (60.0 * zoomFactor).clamp(30.0, 120.0);
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 3. Light Purple Radius Circle Outline
    final center = Offset(size.width * 0.48, size.height * 0.44);
    final radiusCirclePaint = Paint()
      ..color = const Color(0xFF818CF8).withOpacity(0.55)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final double circleRadius = (140.0 * zoomFactor).clamp(50.0, 300.0);
    canvas.drawCircle(center, circleRadius, radiusCirclePaint);

    // Center Pulse Dot for Employer
    final centerDotPaint = Paint()
      ..color = const Color(0xFF1E3AE2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, centerDotPaint);

    final centerRingPaint = Paint()
      ..color = const Color(0xFF1E3AE2).withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 9.0, centerRingPaint);

    // 4. Soft Green Organic Density Blob at bottom right
    final greenBlobCenter = Offset(size.width * 0.75, size.height * 0.62);
    final greenBlobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFDCFCE7).withOpacity(0.85),
          const Color(0xFFDCFCE7).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: greenBlobCenter, radius: 100 * zoomFactor));

    canvas.drawCircle(greenBlobCenter, 100 * zoomFactor, greenBlobPaint);
  }

  @override
  bool shouldRepaint(covariant _RefMapGridPainter oldDelegate) =>
      oldDelegate.zoomFactor != zoomFactor;
}