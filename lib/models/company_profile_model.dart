class CompanyProfileModel {
  final int? id;
  final int? employeeId;
  final String? organizationType;
  final String? legalName;
  final String? displayName;
  final String? dateOfIncorporation;
  final String? organizationPan;
  final String? gstinNumber;
  final String? registrationNumber;
  final String? industryDomain;
  final String? companySize;
  final String? companyType;
  final String? officialWebsite;
  final String? companyTagline;
  final String? companyDescription;
  final String? companyBrandIdentity;
  final String? companyLogo;
  final String? branchTitle;
  final bool isCorporateHq;
  final String? addressLine1;
  final String? addressLine2;
  final String? country;
  final int? stateId;
  final int? districtId;
  final int? cityId;
  final int? talukaId;
  final String? pincode;
  final String? googleMapCoordinates;
  final String? branchPhone;
  final double? latitude;
  final double? longitude;
  final String? officialCompanyEmail;
  final String? companyMobileWhatsapp;
  final String? landlinePhone;
  final String? authorizedContactPerson;
  final String? designationRole;
  final String? linkedinCompanyPage;
  final String? facebookPageUrl;
  final String? instagramProfileUrl;
  final String? twitterXProfileUrl;
  final String? llpin;
  final String? cin;
  final String? bannerUrl;
  final String? companyRegistrationCertificate;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const CompanyProfileModel({
    this.id,
    this.employeeId,
    this.organizationType,
    this.legalName,
    this.displayName,
    this.dateOfIncorporation,
    this.organizationPan,
    this.gstinNumber,
    this.registrationNumber,
    this.industryDomain,
    this.companySize,
    this.companyType,
    this.officialWebsite,
    this.companyTagline,
    this.companyDescription,
    this.companyBrandIdentity,
    this.companyLogo,
    this.branchTitle,
    this.isCorporateHq = false,
    this.addressLine1,
    this.addressLine2,
    this.country,
    this.stateId,
    this.districtId,
    this.cityId,
    this.talukaId,
    this.pincode,
    this.googleMapCoordinates,
    this.branchPhone,
    this.latitude,
    this.longitude,
    this.officialCompanyEmail,
    this.companyMobileWhatsapp,
    this.landlinePhone,
    this.authorizedContactPerson,
    this.designationRole,
    this.linkedinCompanyPage,
    this.facebookPageUrl,
    this.instagramProfileUrl,
    this.twitterXProfileUrl,
    this.llpin,
    this.cin,
    this.bannerUrl,
    this.companyRegistrationCertificate,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v == 1;
      final str = v.toString().toLowerCase().trim();
      return str == '1' || str == 'true';
    }

    String? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.contains('T')) {
        return s.split('T').first;
      }
      return s;
    }

    return CompanyProfileModel(
      id: parseInt(json['id']),
      employeeId: parseInt(json['employee_id']),
      organizationType: json['organization_type']?.toString(),
      legalName: json['legal_name']?.toString(),
      displayName: json['display_name']?.toString(),
      dateOfIncorporation: parseDate(json['date_of_incorporation']),
      organizationPan: json['organization_pan']?.toString(),
      gstinNumber: json['gstin_number']?.toString(),
      registrationNumber: json['registration_number']?.toString(),
      industryDomain: json['industry_domain']?.toString(),
      companySize: json['company_size']?.toString(),
      companyType: json['company_type']?.toString(),
      officialWebsite: json['official_website']?.toString(),
      companyTagline: json['company_tagline']?.toString(),
      companyDescription: json['company_description']?.toString(),
      companyBrandIdentity: json['company_brand_identity']?.toString(),
      companyLogo: json['company_logo']?.toString(),
      branchTitle: json['branch_title']?.toString(),
      isCorporateHq: parseBool(json['is_corporate_hq']),
      addressLine1: json['address_line_1']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      country: json['country']?.toString() ?? 'India',
      stateId: parseInt(json['state_id']),
      districtId: parseInt(json['district_id']),
      cityId: parseInt(json['city_id']),
      talukaId: parseInt(json['taluka_id']),
      pincode: json['pincode']?.toString(),
      googleMapCoordinates: json['google_map_coordinates']?.toString(),
      branchPhone: json['branch_phone']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      officialCompanyEmail: json['official_company_email']?.toString(),
      companyMobileWhatsapp: json['company_mobile_whatsapp']?.toString(),
      landlinePhone: json['landline_phone']?.toString(),
      authorizedContactPerson: json['authorized_contact_person']?.toString(),
      designationRole: json['designation_role']?.toString(),
      linkedinCompanyPage: json['linkedin_company_page']?.toString(),
      facebookPageUrl: json['facebook_page_url']?.toString(),
      instagramProfileUrl: json['instagram_profile_url']?.toString(),
      twitterXProfileUrl: json['twitter_x_profile_url']?.toString(),
      llpin: json['llpin']?.toString(),
      cin: json['cin']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      companyRegistrationCertificate:
          json['company_registration_certificate']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Converts model to payload for PATCH /api/company-profiles/my.
  /// Strictly excludes employee_id, id, status, created_at, and updated_at.
  Map<String, dynamic> toUpdateJson() {
    return {
      if (organizationType != null) 'organization_type': organizationType,
      if (legalName != null) 'legal_name': legalName,
      if (displayName != null) 'display_name': displayName,
      if (dateOfIncorporation != null)
        'date_of_incorporation': dateOfIncorporation,
      if (organizationPan != null) 'organization_pan': organizationPan,
      if (gstinNumber != null) 'gstin_number': gstinNumber,
      if (registrationNumber != null)
        'registration_number': registrationNumber,
      if (industryDomain != null) 'industry_domain': industryDomain,
      if (companySize != null) 'company_size': companySize,
      if (companyType != null) 'company_type': companyType,
      if (officialWebsite != null) 'official_website': officialWebsite,
      if (companyTagline != null) 'company_tagline': companyTagline,
      if (companyDescription != null)
        'company_description': companyDescription,
      if (companyBrandIdentity != null)
        'company_brand_identity': companyBrandIdentity,
      if (branchTitle != null) 'branch_title': branchTitle,
      'is_corporate_hq': isCorporateHq ? 1 : 0,
      if (addressLine1 != null) 'address_line_1': addressLine1,
      if (addressLine2 != null) 'address_line_2': addressLine2,
      if (country != null) 'country': country,
      if (stateId != null) 'state_id': stateId,
      if (districtId != null) 'district_id': districtId,
      if (cityId != null) 'city_id': cityId,
      if (talukaId != null) 'taluka_id': talukaId,
      if (pincode != null) 'pincode': pincode,
      if (googleMapCoordinates != null)
        'google_map_coordinates': googleMapCoordinates,
      if (branchPhone != null) 'branch_phone': branchPhone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (officialCompanyEmail != null)
        'official_company_email': officialCompanyEmail,
      if (companyMobileWhatsapp != null)
        'company_mobile_whatsapp': companyMobileWhatsapp,
      if (landlinePhone != null) 'landline_phone': landlinePhone,
      if (authorizedContactPerson != null)
        'authorized_contact_person': authorizedContactPerson,
      if (designationRole != null) 'designation_role': designationRole,
      if (linkedinCompanyPage != null)
        'linkedin_company_page': linkedinCompanyPage,
      if (facebookPageUrl != null) 'facebook_page_url': facebookPageUrl,
      if (instagramProfileUrl != null)
        'instagram_profile_url': instagramProfileUrl,
      if (twitterXProfileUrl != null)
        'twitter_x_profile_url': twitterXProfileUrl,
      if (llpin != null) 'llpin': llpin,
      if (cin != null) 'cin': cin,
      if (bannerUrl != null) 'banner_url': bannerUrl,
    };
  }

  String get effectiveName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (legalName != null && legalName!.trim().isNotEmpty) {
      return legalName!.trim();
    }
    return 'Company Profile';
  }

  String get initials {
    final name = effectiveName;
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      final p = parts[0];
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CP';
  }

  String formattedAddress({String? stateName, String? cityName}) {
    final parts = <String>[];
    if (branchTitle != null && branchTitle!.trim().isNotEmpty) {
      parts.add(branchTitle!.trim());
    }
    if (addressLine1 != null && addressLine1!.trim().isNotEmpty) {
      parts.add(addressLine1!.trim());
    }
    if (addressLine2 != null && addressLine2!.trim().isNotEmpty) {
      parts.add(addressLine2!.trim());
    }
    if (cityName != null && cityName.trim().isNotEmpty) {
      parts.add(cityName.trim());
    }
    if (stateName != null && stateName.trim().isNotEmpty) {
      parts.add(stateName.trim());
    }
    if (pincode != null && pincode!.trim().isNotEmpty) {
      parts.add(pincode!.trim());
    }
    if (parts.isEmpty) {
      return 'Address not specified';
    }
    return parts.join(', ');
  }

  /// Calculates company profile completion percentage based on backend criteria:
  /// - Overview (25%): legalName(5%), displayName(5%), organizationType(5%), industryDomain(5%), companySize(5%)
  /// - Address & Branch (25%): addressLine1(7%), stateId(6%), cityId(6%), pincode(6%)
  /// - Contact (25%): officialCompanyEmail(13%), companyMobileWhatsapp(12%)
  /// - Verification & Brand (25%): companyLogo(12%), companyRegistrationCertificate/active(13%)
  int get profileCompletionPercentage {
    int score = 0;
    bool isPresent(String? v) => v != null && v.trim().isNotEmpty;
    bool isNumPresent(int? v) => v != null && v > 0;

    // 1. Overview (25%)
    if (isPresent(legalName)) score += 5;
    if (isPresent(displayName)) score += 5;
    if (isPresent(organizationType)) score += 5;
    if (isPresent(industryDomain)) score += 5;
    if (isPresent(companySize)) score += 5;

    // 2. Address & Branch (25%)
    if (isPresent(addressLine1)) score += 7;
    if (isNumPresent(stateId)) score += 6;
    if (isNumPresent(cityId)) score += 6;
    if (isPresent(pincode)) score += 6;

    // 3. Contact (25%)
    if (isPresent(officialCompanyEmail)) score += 13;
    if (isPresent(companyMobileWhatsapp)) score += 12;

    // 4. Verification & Brand (25%)
    if (isPresent(companyLogo)) score += 12;
    final isDocVerified =
        isPresent(companyRegistrationCertificate) || status == 'active';
    if (isDocVerified) score += 13;

    return score.clamp(0, 100);
  }

  bool get isProfileComplete => profileCompletionPercentage == 100;
}
