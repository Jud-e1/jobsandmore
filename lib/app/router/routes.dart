/// Route paths. Web URLs mirror these, so keep them stable and readable.
abstract final class Routes {
  // Public
  static const home = '/';
  static const signIn = '/sign-in';
  static const getStarted = '/get-started';
  static const register = '/register';
  static const welcome = '/welcome'; // mobile welcome screen (M01)
  static const jobs = '/jobs';
  static String jobDetail(String id) => '/jobs/$id';
  static String apply(String id) => '/jobs/$id/apply';
  static const tools = '/career-tools';
  static const business = '/business';
  static const academy = '/academy';
  static String course(String id) => '/academy/$id';
  static const pricing = '/pricing';
  static String employerProfile(String slug) => '/employers/$slug';

  // Signed in (job seeker)
  static const onboarding = '/app/personalise';
  static const dashboard = '/app';
  static const profile = '/app/profile';
  static const ats = '/app/cv-check';
  static const alerts = '/app/alerts';
  static const inbox = '/app/inbox';
  static const applications = '/app/applications';
  static const myCourses = '/app/learning';
  static const interview = '/app/interview-coach';
  static const notifications = '/app/notifications';
  static const settings = '/app/settings';

  // Employer
  static const employer = '/employer';
  static const postVacancy = '/employer/vacancies/new';
  static const pipeline = '/employer/pipeline';

  // Business owner
  static const businessDashboard = '/business/dashboard';

  // Staff
  static const admin = '/admin';

  static const devPrefix = '/dev';
  static const gallery = '/dev/gallery';

  /// Paths that require a signed-in user. The employer landing ("/employer")
  /// itself is the employer dashboard, so it is protected too; the public
  /// "Hire Talent" marketing lives on /pricing.
  static const List<String> protectedPrefixes = [
    '/app',
    employer,
    admin,
    businessDashboard,
  ];
}
