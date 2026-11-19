/// DEMO CONTENT used by the UI until each screen is wired to Supabase.
///
/// Mirrors the sample content in the approved design. Every organisation and
/// person here is fictional. Screens read it through these classes only, so
/// swapping in repositories later is a one-place change.
library;

class DemoJob {
  const new({
    required this.id,
    required this.ini,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.verification,
    required this.salary,
    required this.posted,
    required this.closes,
    required this.match,
    required this.why,
    this.sponsored = false,
    this.listing = 'Full-time',
  });

  final String id;
  final String ini;
  final String title;
  final String company;
  final String location;
  final String type;
  final String verification;
  final String salary;
  final String posted;
  final String closes;
  final int match;
  final String why;
  final bool sponsored;
  final String listing;
}

class DemoCourse {
  const new({
    required this.id,
    required this.title,
    required this.meta,
    required this.price,
    required this.tint,
    this.provider = 'JobsAndMore Academy',
    this.progress,
  });

  final String id;
  final String title;
  final String meta;
  final String price;

  /// 0 green, 1 amber, 2 blue, 3 purple.
  final int tint;
  final String provider;
  final double? progress;
}

abstract final class Demo {
  static const seekerName = 'Amaka Okafor';
  static const seekerFirst = 'Amaka';

  static const jobs = <DemoJob>[
    DemoJob(
      id: 'operations-analyst',
      ini: 'KL',
      title: 'Operations Analyst',
      company: 'Kobo Logistics Ltd',
      location: 'Lagos',
      type: 'Full-time · Hybrid',
      verification: 'Verified employer',
      salary: '₦350k–₦450k / month',
      posted: '2 days ago',
      closes: '12 Dec',
      match: 82,
      why: 'Excel, reporting and operations experience match; SQL is listed but not in your profile.',
      sponsored: true,
    ),
    DemoJob(
      id: 'data-analyst-graduate',
      ini: 'NH',
      title: 'Data Analyst (Graduate)',
      company: 'Ndani Health',
      location: 'Abuja',
      type: 'Full-time',
      verification: 'Verified employer',
      salary: 'Salary not disclosed',
      posted: 'Today',
      closes: '5 Dec',
      match: 76,
      why: 'Graduate level and data skills match; role is outside your preferred state.',
      listing: 'Graduate',
    ),
    DemoJob(
      id: 'business-analyst',
      ini: 'PB',
      title: 'Business Analyst',
      company: 'Pinnacle Bank Services',
      location: 'Lagos',
      type: 'Full-time · On-site',
      verification: 'Business details reviewed',
      salary: '₦400k–₦550k / month',
      posted: '4 days ago',
      closes: '18 Dec',
      match: 71,
      why: 'Analysis and stakeholder skills match; asks for 3+ yrs experience.',
    ),
    DemoJob(
      id: 'junior-product-analyst',
      ini: 'AS',
      title: 'Junior Product Analyst',
      company: 'Ayo Software Studio',
      location: 'Remote (Nigeria)',
      type: 'Contract · 6 months',
      verification: 'Email verified',
      salary: '₦300k / month',
      posted: '1 week ago',
      closes: '20 Dec',
      match: 68,
      why: 'Remote and entry level; product analytics tools not yet in your profile.',
      listing: 'Contract',
    ),
    DemoJob(
      id: 'supply-chain-analyst',
      ini: 'GR',
      title: 'Supply Chain Analyst',
      company: 'Greenfield Agro',
      location: 'Ogun',
      type: 'Full-time · On-site',
      verification: 'Verified employer',
      salary: 'Salary not disclosed',
      posted: '3 days ago',
      closes: '9 Dec',
      match: 64,
      why: 'Operations background matches; nearby state (Ogun) included in your alert.',
    ),
  ];

  /// Home "Featured opportunities" (design 01).
  static const featured =
      <(String, String, String, String, String, String, String)>[
        (
          'KL',
          'Operations Analyst',
          'Kobo Logistics Ltd',
          'Lagos · Hybrid',
          'Full-time',
          '12 Dec',
          'Verified employer',
        ),
        (
          'NH',
          'Graduate Trainee – Finance',
          'Ndani Health',
          'Abuja',
          'Graduate',
          '5 Dec',
          'Verified employer',
        ),
        (
          'AS',
          'Frontend Developer',
          'Ayo Software Studio',
          'Remote',
          'Contract',
          '20 Dec',
          'Business details reviewed',
        ),
        (
          'OF',
          'Sales Associate',
          'Ola Foods',
          'Ibadan · On-site',
          'Full-time',
          '30 Nov',
          'Email verified',
        ),
      ];

  static const courses = <DemoCourse>[
    DemoCourse(
      id: 'excel-data-reporting',
      title: 'Excel for Data Reporting',
      meta: 'Beginner · 6 hrs · Certificate',
      price: 'Free',
      tint: 0,
      progress: 0.6,
    ),
    DemoCourse(
      id: 'interview-confidence',
      title: 'Interview Confidence Bootcamp',
      meta: 'All levels · 4 modules · Certificate',
      price: '[Price]',
      tint: 1,
      progress: 0.25,
    ),
    DemoCourse(
      id: 'sme-finance-basics',
      title: 'Small Business Finance Basics',
      meta: 'Business · 5 hrs · Certificate',
      price: 'Free',
      tint: 2,
    ),
  ];

  static DemoJob job(String id) =>
      jobs.firstWhere((j) => j.id == id, orElse: () => jobs.first);

  static DemoCourse course(String id) =>
      courses.firstWhere((c) => c.id == id, orElse: () => courses.first);
}
