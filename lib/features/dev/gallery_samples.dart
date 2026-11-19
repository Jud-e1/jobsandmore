import 'package:jobsandmore/core/widgets/widgets.dart';

/// SAMPLE CONTENT FOR THE DEV GALLERY ONLY.
///
/// These fictional records exist to show components with realistic text
/// lengths. They are never shown outside `/dev/gallery`, which is disabled in
/// production builds, and the Launch Gate check (Phase 11) excludes this file.
abstract final class GallerySamples {
  static final now = DateTime(2026, 11, 17);

  static final jobs = <JmJobCardData>[
    JmJobCardData(
      id: 'sample-1',
      title: 'Senior Product Designer',
      employerName: 'Sample: Kora Fintech',
      verification: JmVerificationLevel.verified,
      location: 'Lekki, Lagos',
      jobType: 'Full-time',
      arrangement: 'Hybrid',
      postedAt: DateTime(2026, 11, 16),
      closingDate: DateTime(2026, 11, 19),
      salaryMin: 850000,
      salaryMax: 1200000,
      salaryDisclosed: true,
      matchPercent: 86,
    ),
    JmJobCardData(
      id: 'sample-2',
      title: 'Customer Success Associate (Hausa & English)',
      employerName: 'Sample: Arewa Logistics',
      verification: JmVerificationLevel.detailsReviewed,
      location: 'Kano',
      jobType: 'Full-time',
      arrangement: 'On-site',
      postedAt: DateTime(2026, 11, 2),
      closingDate: DateTime(2026, 12, 12),
      isSponsored: true,
    ),
    JmJobCardData(
      id: 'sample-3',
      title: 'Data Analyst Intern',
      employerName: 'Sample: Enugu Agritech Hub',
      verification: JmVerificationLevel.emailVerified,
      location: 'Enugu',
      jobType: 'Internship',
      arrangement: 'Remote',
      postedAt: DateTime(2026, 11, 10),
      closingDate: DateTime(2026, 11, 24),
      salaryMin: 120000,
      salaryDisclosed: true,
      matchPercent: 58,
    ),
  ];

  static const courses = <JmCourseCardData>[
    JmCourseCardData(
      id: 'course-excel-analytics',
      title: 'Excel to Power BI: Business Analytics Foundations',
      providerName: 'Sample Academy',
      level: 'Beginner',
      durationLabel: '6 weeks',
      format: 'Self-paced',
      hasCertificate: true,
    ),
    JmCourseCardData(
      id: 'course-interview-confidence',
      title: 'Interview Confidence for Graduates',
      providerName: 'Sample Careers Lab',
      level: 'All levels',
      durationLabel: '3 hours',
      format: 'Video',
      priceLabel: '₦7,500',
    ),
    JmCourseCardData(
      id: 'course-sme-bookkeeping',
      title: 'Bookkeeping for Small Businesses',
      providerName: 'Sample SME Institute',
      level: 'Intermediate',
      durationLabel: '4 weeks',
      format: 'Live cohort',
      progress: 0.42,
    ),
  ];

  static const employers = <JmEmployerCardData>[
    JmEmployerCardData(
      id: 'emp-1',
      name: 'Sample: Kora Fintech',
      industry: 'Financial services',
      location: 'Lagos',
      verification: JmVerificationLevel.verified,
      openRoles: 12,
      tagline: 'Payments infrastructure for merchants across West Africa.',
    ),
    JmEmployerCardData(
      id: 'emp-2',
      name: 'Sample: Arewa Logistics',
      industry: 'Logistics',
      location: 'Kano',
      verification: JmVerificationLevel.detailsReviewed,
      openRoles: 4,
      tagline: 'Last-mile delivery across the North.',
    ),
    JmEmployerCardData(
      id: 'emp-3',
      name: 'Sample: Ibadan Health Partners',
      industry: 'Healthcare',
      location: 'Ibadan',
      verification: JmVerificationLevel.emailVerified,
      openRoles: 1,
    ),
  ];

  static const searchOptions = JmSearchOptions(
    locations: [
      'Abuja (FCT)',
      'Enugu',
      'Ibadan, Oyo',
      'Kano',
      'Lagos',
      'Port Harcourt, Rivers',
    ],
    jobTypes: ['Full-time', 'Part-time', 'Contract', 'Internship', 'NYSC'],
    experienceLevels: [
      'Entry level',
      'Mid level',
      'Senior',
      'Manager',
      'Executive',
    ],
  );

  static Map<String, List<JmCandidateCardData>> pipeline() => {
    'New': const [
      JmCandidateCardData(
        id: 'c1',
        name: 'Adaeze Okafor',
        headline: 'Product Designer · 5 yrs',
        appliedLabel: '2 days ago',
        tags: ['Figma', 'Fintech'],
        unread: true,
      ),
      JmCandidateCardData(
        id: 'c2',
        name: 'Tunde Bakare',
        headline: 'UX Designer · 3 yrs',
        appliedLabel: '3 days ago',
      ),
    ],
    'Shortlisted': const [
      JmCandidateCardData(
        id: 'c3',
        name: 'Halima Yusuf',
        headline: 'Senior UI Designer · 7 yrs',
        appliedLabel: '1 week ago',
        tags: ['Design systems'],
      ),
    ],
    'Interview': const [
      JmCandidateCardData(
        id: 'c4',
        name: 'Chinedu Eze',
        headline: 'Product Designer · 6 yrs',
        appliedLabel: '2 weeks ago',
        tags: ['Research', 'B2B'],
      ),
    ],
    'Offer': const [],
  };
}
