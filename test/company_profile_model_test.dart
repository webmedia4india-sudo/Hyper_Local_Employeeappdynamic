import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_local_employee/models/company_profile_model.dart';

void main() {
  group('CompanyProfileModel', () {
    test('fromJson and toUpdateJson works correctly and excludes forbidden keys', () {
      final json = {
        'id': 1,
        'employee_id': 2,
        'legal_name': 'TechNova Pvt Ltd',
        'display_name': 'TechNova Solutions',
        'organization_type': 'Private Limited Company',
        'date_of_incorporation': '2021-05-15T00:00:00.000Z',
        'organization_pan': 'ABCDE1234F',
        'gstin_number': '27ABCDE1234F1Z5',
        'registration_number': 'REG123456',
        'industry_domain': 'IT & Software',
        'company_size': '51-200 employees',
        'company_type': 'Corporate',
        'official_website': 'https://technova.io',
        'company_tagline': 'Empowering Hyper Local Growth',
        'company_description': 'Tech provider for businesses',
        'company_logo': '/uploads/company_profiles/logo.png',
        'branch_title': 'Hinjewadi HQ',
        'is_corporate_hq': 1,
        'address_line_1': 'Phase 1, Hinjewadi',
        'address_line_2': 'Near Tech Park',
        'country': 'India',
        'state_id': 14,
        'city_id': 369,
        'pincode': '411057',
        'official_company_email': 'info@technova.io',
        'company_mobile_whatsapp': '9876543210',
        'status': 'active',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-02',
      };

      final model = CompanyProfileModel.fromJson(json);

      expect(model.id, 1);
      expect(model.employeeId, 2);
      expect(model.legalName, 'TechNova Pvt Ltd');
      expect(model.displayName, 'TechNova Solutions');
      expect(model.dateOfIncorporation, '2021-05-15');
      expect(model.isCorporateHq, true);
      expect(model.stateId, 14);
      expect(model.cityId, 369);
      expect(model.initials, 'TS');

      final updateMap = model.toUpdateJson();

      // Ensure forbidden keys are absent
      expect(updateMap.containsKey('id'), false);
      expect(updateMap.containsKey('employee_id'), false);
      expect(updateMap.containsKey('status'), false);
      expect(updateMap.containsKey('created_at'), false);
      expect(updateMap.containsKey('updated_at'), false);

      // Ensure allowed fields are present
      expect(updateMap['legal_name'], 'TechNova Pvt Ltd');
      expect(updateMap['display_name'], 'TechNova Solutions');
      expect(updateMap['state_id'], 14);
      expect(updateMap['city_id'], 369);
      expect(updateMap['is_corporate_hq'], 1);
    });

    test('handles null and empty fields gracefully', () {
      final model = CompanyProfileModel.fromJson({});
      expect(model.id, null);
      expect(model.effectiveName, 'Company Profile');
      expect(model.initials, 'CP');
      expect(model.formattedAddress(), 'Address not specified');
      expect(model.toUpdateJson().containsKey('id'), false);
    });
    test('calculates profileCompletionPercentage correctly', () {
      final emptyModel = CompanyProfileModel.fromJson({});
      expect(emptyModel.profileCompletionPercentage, 0);
      expect(emptyModel.isProfileComplete, false);

      final signupModel = CompanyProfileModel.fromJson({
        'legal_name': 'Tech Corp',
        'display_name': 'Tech Corp',
        'industry_domain': 'IT & Software',
      });
      expect(signupModel.profileCompletionPercentage, 15);
      expect(signupModel.isProfileComplete, false);

      final completeModel = CompanyProfileModel.fromJson({
        'legal_name': 'TechNova Solutions Pvt Ltd',
        'display_name': 'TechNova',
        'organization_type': 'Private Limited Company',
        'industry_domain': 'IT & Software',
        'company_size': '51-200 employees',
        'address_line_1': 'Plot 42, Rajiv Gandhi Infotech Park',
        'state_id': 14,
        'city_id': 369,
        'pincode': '411057',
        'official_company_email': 'contact@technova.com',
        'company_mobile_whatsapp': '9876543210',
        'company_logo': '/uploads/company_profiles/logo.png',
        'company_registration_certificate': '/uploads/company_profiles/cert.pdf',
      });
      expect(completeModel.profileCompletionPercentage, 100);
      expect(completeModel.isProfileComplete, true);

      final activeModel = CompanyProfileModel.fromJson({
        'legal_name': 'TechNova Solutions Pvt Ltd',
        'display_name': 'TechNova',
        'organization_type': 'Private Limited Company',
        'industry_domain': 'IT & Software',
        'company_size': '51-200 employees',
        'address_line_1': 'Plot 42, Rajiv Gandhi Infotech Park',
        'state_id': 14,
        'city_id': 369,
        'pincode': '411057',
        'official_company_email': 'contact@technova.com',
        'company_mobile_whatsapp': '9876543210',
        'company_logo': '/uploads/company_profiles/logo.png',
        'status': 'active',
      });
      expect(activeModel.profileCompletionPercentage, 100);
      expect(activeModel.isProfileComplete, true);
    });
  });
}
