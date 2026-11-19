-- =============================================================================
-- JobsAndMore: DEMO SEED DATA (local development and staging only)
--
-- * Every organisation, job, course, opportunity, service and plan here is
--   fictional and flagged is_demo = true. Descriptions say so explicitly.
-- * Demo rows are invisible unless the `show_demo_content` feature flag is on.
--   This file turns it on at the end; production never runs seed.sql, so the
--   flag stays off there (product rule 1).
-- * Opportunity links point to example.org (reserved for documentation), never
--   to real programmes.
-- * Taxonomy (states, industries, skills) is real reference data, not demo.
-- =============================================================================

begin;

-- ------------------------------------------------------------ taxonomy ----

insert into public.taxonomy_states (code, name, capital, geo_zone, neighbours) values
  ('AB', 'Abia', 'Umuahia', 'south_east', '{AN,EN,EB,CR,AK,RI,IM}'),
  ('AD', 'Adamawa', 'Yola', 'north_east', '{BO,GO,TA}'),
  ('AK', 'Akwa Ibom', 'Uyo', 'south_south', '{AB,CR,RI}'),
  ('AN', 'Anambra', 'Awka', 'south_east', '{DE,EN,IM,KO,AB}'),
  ('BA', 'Bauchi', 'Bauchi', 'north_east', '{KN,JI,YO,GO,PL,KD,TA}'),
  ('BY', 'Bayelsa', 'Yenagoa', 'south_south', '{DE,RI}'),
  ('BE', 'Benue', 'Makurdi', 'north_central', '{NA,TA,CR,EB,EN,KO}'),
  ('BO', 'Borno', 'Maiduguri', 'north_east', '{YO,AD,GO}'),
  ('CR', 'Cross River', 'Calabar', 'south_south', '{AK,AB,EB,BE}'),
  ('DE', 'Delta', 'Asaba', 'south_south', '{ED,AN,IM,RI,BY,ON}'),
  ('EB', 'Ebonyi', 'Abakaliki', 'south_east', '{BE,CR,AB,EN}'),
  ('ED', 'Edo', 'Benin City', 'south_south', '{KO,ON,DE}'),
  ('EK', 'Ekiti', 'Ado-Ekiti', 'south_west', '{KW,KO,ON,OS}'),
  ('EN', 'Enugu', 'Enugu', 'south_east', '{KO,BE,EB,AB,AN,IM}'),
  ('FC', 'Federal Capital Territory', 'Abuja', 'north_central', '{NI,KD,NA,KO}'),
  ('GO', 'Gombe', 'Gombe', 'north_east', '{BA,YO,BO,AD,TA}'),
  ('IM', 'Imo', 'Owerri', 'south_east', '{AN,AB,RI,DE,EN}'),
  ('JI', 'Jigawa', 'Dutse', 'north_west', '{KN,KT,BA,YO}'),
  ('KD', 'Kaduna', 'Kaduna', 'north_west', '{KT,KN,BA,PL,NA,FC,NI,ZA}'),
  ('KN', 'Kano', 'Kano', 'north_west', '{KT,JI,BA,KD}'),
  ('KT', 'Katsina', 'Katsina', 'north_west', '{ZA,KD,KN,JI}'),
  ('KE', 'Kebbi', 'Birnin Kebbi', 'north_west', '{SO,ZA,NI}'),
  ('KO', 'Kogi', 'Lokoja', 'north_central', '{FC,NA,BE,EN,AN,ED,ON,EK,KW,NI}'),
  ('KW', 'Kwara', 'Ilorin', 'north_central', '{NI,KO,EK,OS,OY}'),
  ('LA', 'Lagos', 'Ikeja', 'south_west', '{OG}'),
  ('NA', 'Nasarawa', 'Lafia', 'north_central', '{FC,KD,PL,TA,BE,KO}'),
  ('NI', 'Niger', 'Minna', 'north_central', '{KE,ZA,KD,FC,KO,KW}'),
  ('OG', 'Ogun', 'Abeokuta', 'south_west', '{LA,OY,OS,ON}'),
  ('ON', 'Ondo', 'Akure', 'south_west', '{OG,OS,EK,KO,ED,DE}'),
  ('OS', 'Osun', 'Osogbo', 'south_west', '{OY,KW,EK,ON,OG}'),
  ('OY', 'Oyo', 'Ibadan', 'south_west', '{OG,OS,KW}'),
  ('PL', 'Plateau', 'Jos', 'north_central', '{BA,KD,NA,TA}'),
  ('RI', 'Rivers', 'Port Harcourt', 'south_south', '{BY,DE,IM,AB,AK}'),
  ('SO', 'Sokoto', 'Sokoto', 'north_west', '{KE,ZA}'),
  ('TA', 'Taraba', 'Jalingo', 'north_east', '{AD,GO,BA,PL,NA,BE}'),
  ('YO', 'Yobe', 'Damaturu', 'north_east', '{BO,GO,BA,JI}'),
  ('ZA', 'Zamfara', 'Gusau', 'north_west', '{SO,KE,NI,KD,KT}')
on conflict (code) do nothing;

insert into public.taxonomy_industries (slug, name, position) values
  ('agriculture', 'Agriculture & Agritech', 1),
  ('banking-finance', 'Banking & Financial Services', 2),
  ('fintech', 'Fintech', 3),
  ('technology', 'Technology & Software', 4),
  ('telecoms', 'Telecommunications', 5),
  ('oil-gas', 'Oil, Gas & Energy', 6),
  ('healthcare', 'Healthcare & Pharmaceuticals', 7),
  ('education', 'Education & Training', 8),
  ('logistics', 'Logistics & Supply Chain', 9),
  ('manufacturing', 'Manufacturing', 10),
  ('retail', 'Retail & FMCG', 11),
  ('professional-services', 'Professional Services & Consulting', 12),
  ('construction', 'Construction & Real Estate', 13),
  ('media', 'Media & Creative', 14),
  ('hospitality', 'Hospitality & Tourism', 15),
  ('public-sector', 'Government & Public Sector', 16),
  ('ngo', 'NGO & Development', 17),
  ('maritime', 'Maritime & Ports', 18)
on conflict (slug) do nothing;

insert into public.taxonomy_skills (slug, name, category, aliases) values
  ('excel', 'Microsoft Excel', 'Business tools', '{spreadsheets}'),
  ('power-bi', 'Power BI', 'Data', '{}'),
  ('sql', 'SQL', 'Data', '{postgres,mysql}'),
  ('python', 'Python', 'Engineering', '{}'),
  ('javascript', 'JavaScript', 'Engineering', '{js,typescript}'),
  ('flutter', 'Flutter', 'Engineering', '{dart}'),
  ('react', 'React', 'Engineering', '{}'),
  ('figma', 'Figma', 'Design', '{}'),
  ('user-research', 'User Research', 'Design', '{ux research}'),
  ('product-management', 'Product Management', 'Product', '{}'),
  ('project-management', 'Project Management', 'Management', '{pmp,prince2}'),
  ('customer-service', 'Customer Service', 'Operations', '{customer support}'),
  ('sales', 'B2B Sales', 'Commercial', '{business development}'),
  ('digital-marketing', 'Digital Marketing', 'Marketing', '{social media marketing}'),
  ('content-writing', 'Content Writing', 'Marketing', '{copywriting}'),
  ('accounting', 'Accounting', 'Finance', '{bookkeeping}'),
  ('ifrs', 'IFRS Reporting', 'Finance', '{}'),
  ('taxation', 'Taxation (Nigeria)', 'Finance', '{firs,paye,vat}'),
  ('audit', 'Audit', 'Finance', '{}'),
  ('hr-generalist', 'HR Generalist', 'People', '{human resources}'),
  ('recruitment', 'Recruitment', 'People', '{talent acquisition}'),
  ('payroll', 'Payroll', 'People', '{}'),
  ('supply-chain', 'Supply Chain Management', 'Operations', '{procurement}'),
  ('fleet-management', 'Fleet Management', 'Operations', '{}'),
  ('hse', 'Health, Safety & Environment', 'Engineering', '{hse,hseq}'),
  ('electrical-engineering', 'Electrical Engineering', 'Engineering', '{}'),
  ('mechanical-engineering', 'Mechanical Engineering', 'Engineering', '{}'),
  ('nursing', 'Nursing', 'Healthcare', '{rn}'),
  ('pharmacy', 'Pharmacy', 'Healthcare', '{}'),
  ('agronomy', 'Agronomy', 'Agriculture', '{}'),
  ('networking', 'Network Engineering', 'Engineering', '{ccna}'),
  ('cybersecurity', 'Cybersecurity', 'Engineering', '{}'),
  ('graphic-design', 'Graphic Design', 'Design', '{}'),
  ('public-speaking', 'Public Speaking', 'Soft skills', '{}'),
  ('negotiation', 'Negotiation', 'Soft skills', '{}'),
  ('hausa', 'Hausa (spoken)', 'Languages', '{}'),
  ('yoruba', 'Yoruba (spoken)', 'Languages', '{}'),
  ('igbo', 'Igbo (spoken)', 'Languages', '{}'),
  ('french', 'French', 'Languages', '{}'),
  ('data-analysis', 'Data Analysis', 'Data', '{analytics}')
on conflict (slug) do nothing;

-- ------------------------------------------------------- organisations ----
-- Fixed ids so jobs/courses/services can reference them.

insert into public.organisations
  (id, type, name, slug, industry, size, state, city, website, description, culture,
   verification_level, verified_at, is_demo)
values
  ('00000000-0000-4000-a000-000000000e01', 'employer', 'Lagoonline Payments', 'lagoonline-payments',
   'fintech', '201-500', 'LA', 'Lekki', 'https://example.org/demo/lagoonline',
   'Demo organisation for development. Payments infrastructure for small merchants.',
   'Hybrid teams, quarterly learning budgets and a no-meetings Wednesday.',
   'verified', now(), true),
  ('00000000-0000-4000-a000-000000000e02', 'employer', 'Arewa Freight & Logistics', 'arewa-freight-logistics',
   'logistics', '501-1000', 'KN', 'Kano', 'https://example.org/demo/arewa-freight',
   'Demo organisation for development. Haulage and last-mile delivery across the North.',
   'Safety first, promote from within.',
   'details_reviewed', now(), true),
  ('00000000-0000-4000-a000-000000000e03', 'employer', 'Garden City Energy Services', 'garden-city-energy-services',
   'oil-gas', '201-500', 'RI', 'Port Harcourt', 'https://example.org/demo/gces',
   'Demo organisation for development. Field services for onshore energy assets.',
   'Rotational field work with structured HSE training.',
   'verified', now(), true),
  ('00000000-0000-4000-a000-000000000e04', 'employer', 'Coal City Agritech', 'coal-city-agritech',
   'agriculture', '11-50', 'EN', 'Enugu', null,
   'Demo organisation for development. Connects smallholder farmers to buyers.',
   null,
   'email_verified', now(), true),
  ('00000000-0000-4000-a000-000000000e05', 'employer', 'Oluyole Health Partners', 'oluyole-health-partners',
   'healthcare', '51-200', 'OY', 'Ibadan', 'https://example.org/demo/oluyole-health',
   'Demo organisation for development. Community clinics and diagnostics.',
   'Patient-centred care and paid CPD.',
   'details_reviewed', now(), true),
  ('00000000-0000-4000-a000-000000000e06', 'employer', 'Capital Ledger Advisory', 'capital-ledger-advisory',
   'professional-services', '51-200', 'FC', 'Abuja', 'https://example.org/demo/capital-ledger',
   'Demo organisation for development. Audit, tax and advisory for SMEs and NGOs.',
   'Exam support for ICAN/ACCA and clear promotion criteria.',
   'verified', now(), true),
  ('00000000-0000-4000-a000-000000000e07', 'employer', 'Eko Retail Collective', 'eko-retail-collective',
   'retail', '11-50', 'LA', 'Ikeja', null,
   'Demo organisation for development. Neighbourhood grocery stores.',
   null,
   'none', null, true),
  ('00000000-0000-4000-a000-000000000e08', 'employer', 'Savannah Telecoms Infrastructure', 'savannah-telecoms-infrastructure',
   'telecoms', '201-500', 'FC', 'Abuja', 'https://example.org/demo/savannah-telecoms',
   'Demo organisation for development. Tower maintenance and fibre rollout.',
   null,
   'email_verified', now(), true),
  ('00000000-0000-4000-a000-000000000e09', 'employer', 'Bonny Marine & Port Services', 'bonny-marine-port-services',
   'maritime', '51-200', 'RI', 'Port Harcourt', null,
   'Demo organisation for development. Vessel support and port logistics.',
   null,
   'none', null, true),
  ('00000000-0000-4000-a000-000000000e10', 'employer', 'Sabon Gari Textiles', 'sabon-gari-textiles',
   'manufacturing', '201-500', 'KN', 'Kano', 'https://example.org/demo/sabon-gari-textiles',
   'Demo organisation for development. Fabric production and finishing.',
   'Apprenticeships for school leavers.',
   'details_reviewed', now(), true),
  -- Training providers
  ('00000000-0000-4000-a000-0000000000c1', 'training_provider', 'Brightpath Skills Academy', 'brightpath-skills-academy',
   'education', '11-50', 'LA', 'Yaba', 'https://example.org/demo/brightpath',
   'Demo training provider for development. Practical digital and business skills.',
   null, 'details_reviewed', now(), true),
  ('00000000-0000-4000-a000-0000000000c2', 'training_provider', 'Northern Digital Skills Hub', 'northern-digital-skills-hub',
   'education', '11-50', 'KN', 'Kano', null,
   'Demo training provider for development. Digital skills taught in Hausa and English.',
   null, 'email_verified', now(), true),
  ('00000000-0000-4000-a000-0000000000c3', 'training_provider', 'Enterprise Growth Institute', 'enterprise-growth-institute',
   'professional-services', '11-50', 'FC', 'Abuja', null,
   'Demo training provider for development. Courses for founders and SME managers.',
   null, 'none', null, true),
  -- Business (service provider)
  ('00000000-0000-4000-a000-0000000000b1', 'business', 'Mainland Growth Consulting', 'mainland-growth-consulting',
   'professional-services', '1-10', 'LA', 'Surulere', null,
   'Demo business for development. HR and operations support for growing SMEs.',
   null, 'email_verified', now(), true)
on conflict (id) do nothing;

-- ---------------------------------------------------------------- jobs ----
-- 30 open demo jobs across Lagos, Abuja, Port Harcourt, Kano, Ibadan and
-- Enugu. Closing and posting dates are relative to today so the seed never
-- goes stale. Salaries are monthly gross in Naira.

with org(k, id) as (
  values
    ('e01', '00000000-0000-4000-a000-000000000e01'::uuid),
    ('e02', '00000000-0000-4000-a000-000000000e02'::uuid),
    ('e03', '00000000-0000-4000-a000-000000000e03'::uuid),
    ('e04', '00000000-0000-4000-a000-000000000e04'::uuid),
    ('e05', '00000000-0000-4000-a000-000000000e05'::uuid),
    ('e06', '00000000-0000-4000-a000-000000000e06'::uuid),
    ('e07', '00000000-0000-4000-a000-000000000e07'::uuid),
    ('e08', '00000000-0000-4000-a000-000000000e08'::uuid),
    ('e09', '00000000-0000-4000-a000-000000000e09'::uuid),
    ('e10', '00000000-0000-4000-a000-000000000e10'::uuid)
),
j(k, title, jt, arr, lvl, ind, st, city, smin, smax, disc, close_in, posted_ago, sponsored, summary, resp, req, skills) as (
  values
  ('e01', 'Senior Flutter Engineer', 'full_time', 'hybrid', 'senior', 'fintech', 'LA', 'Lekki',
   900000, 1400000, true, 21, 1, true,
   'Build and ship the merchant app used by thousands of small businesses.',
   array['Own features end to end in the Flutter merchant app', 'Review code and mentor two mid-level engineers', 'Work with design on accessible, offline-friendly flows'],
   array['4+ years building production mobile apps, 2+ in Flutter', 'Experience with state management and automated testing', 'Comfortable with REST or GraphQL APIs'],
   array['flutter', 'javascript', 'sql']),
  ('e01', 'Customer Support Associate', 'full_time', 'on_site', 'entry', 'fintech', 'LA', 'Lekki',
   180000, 220000, true, 10, 2, false,
   'Help merchants resolve payment and settlement questions by chat and phone.',
   array['Resolve merchant tickets within agreed response times', 'Escalate failed settlements with clear notes', 'Suggest help-centre improvements from common questions'],
   array['OND/HND or B.Sc. in any field', 'Clear written and spoken English; Yoruba is a plus', 'Patience and attention to detail'],
   array['customer-service', 'yoruba']),
  ('e01', 'Data Analyst', 'full_time', 'hybrid', 'mid', 'fintech', 'LA', 'Lekki',
   550000, 750000, true, 28, 4, false,
   'Turn transaction data into weekly insights for the growth and risk teams.',
   array['Build and maintain Power BI dashboards', 'Write SQL to answer product questions', 'Present findings to non-technical stakeholders'],
   array['2+ years in a data role', 'Strong SQL and Excel; Python is a plus', 'Experience with payments or e-commerce data'],
   array['sql', 'power-bi', 'excel', 'python']),
  ('e01', 'Product Designer', 'full_time', 'remote', 'mid', 'fintech', 'LA', 'Lekki',
   null, null, false, 18, 6, false,
   'Design simple, trustworthy payment experiences for first-time digital merchants.',
   array['Run usability sessions with merchants in markets and shops', 'Ship high-fidelity designs in Figma', 'Maintain our design system components'],
   array['3+ years in product design', 'Portfolio showing research-led work', 'Experience designing for low-bandwidth users'],
   array['figma', 'user-research']),
  ('e02', 'Fleet Operations Supervisor', 'full_time', 'on_site', 'mid', 'logistics', 'KN', 'Kano',
   300000, 380000, true, 14, 3, false,
   'Keep 60+ trucks moving safely and on schedule across the North-West corridor.',
   array['Plan daily dispatch and driver rotas', 'Track fuel, maintenance and incident reports', 'Coach drivers on safety procedures'],
   array['3+ years in fleet or transport operations', 'Working knowledge of Hausa', 'Valid driver''s licence'],
   array['fleet-management', 'hausa', 'excel']),
  ('e02', 'Warehouse Assistant', 'full_time', 'on_site', 'entry', 'logistics', 'KN', 'Kano',
   95000, 120000, true, 9, 1, false,
   'Receive, store and dispatch goods accurately in our Kano hub.',
   array['Check incoming goods against delivery notes', 'Pick and pack orders', 'Keep the warehouse clean and safe'],
   array['SSCE/WAEC', 'Able to lift and move goods safely', 'Basic numeracy'],
   array['supply-chain']),
  ('e02', 'Logistics Graduate Trainee', 'internship', 'on_site', 'entry', 'logistics', 'KN', 'Kano',
   120000, null, true, 25, 5, false,
   'A 12-month rotation across dispatch, warehousing and customer service.',
   array['Rotate through three operations teams', 'Deliver a process-improvement project', 'Present learnings to the leadership team'],
   array['B.Sc./HND completed in the last two years', 'NYSC completed or exempted', 'Strong Excel skills'],
   array['excel', 'supply-chain']),
  ('e03', 'HSE Officer', 'full_time', 'on_site', 'mid', 'oil-gas', 'RI', 'Port Harcourt',
   650000, 850000, true, 20, 2, true,
   'Lead site safety for onshore maintenance crews.',
   array['Conduct toolbox talks and site inspections', 'Investigate incidents and track corrective actions', 'Maintain permit-to-work records'],
   array['NEBOSH IGC or equivalent', '4+ years HSE experience in energy or construction', 'Willing to work rotational shifts'],
   array['hse']),
  ('e03', 'Instrumentation Technician', 'contract', 'on_site', 'mid', 'oil-gas', 'RI', 'Port Harcourt',
   450000, 600000, true, 12, 7, false,
   'Maintain and calibrate field instrumentation on onshore facilities.',
   array['Calibrate pressure, flow and level instruments', 'Diagnose faults and complete maintenance logs', 'Follow site safety rules at all times'],
   array['OND/HND in Instrumentation or Electrical', '3+ years field experience', 'BOSIET is a plus'],
   array['electrical-engineering', 'hse']),
  ('e03', 'Procurement Analyst', 'full_time', 'hybrid', 'mid', 'oil-gas', 'RI', 'Port Harcourt',
   null, null, false, 30, 10, false,
   'Run competitive sourcing for spares and services.',
   array['Prepare RFQs and evaluate bids', 'Track vendor performance', 'Keep procurement records audit-ready'],
   array['3+ years procurement experience', 'Strong Excel and negotiation skills', 'Knowledge of local content requirements'],
   array['supply-chain', 'negotiation', 'excel']),
  ('e04', 'Field Agronomist', 'full_time', 'on_site', 'mid', 'agriculture', 'EN', 'Nsukka',
   220000, 300000, true, 16, 3, false,
   'Support 400 smallholder farmers to improve yields and quality.',
   array['Visit farms and give practical advice', 'Run demonstration plots', 'Record farm data in our mobile app'],
   array['B.Sc. Agriculture or Agronomy', '2+ years extension experience', 'Fluent Igbo'],
   array['agronomy', 'igbo']),
  ('e04', 'Social Media & Content Intern', 'internship', 'hybrid', 'entry', 'agriculture', 'EN', 'Enugu',
   60000, null, true, 11, 2, false,
   'Tell farmers'' stories and grow our online community.',
   array['Plan and post weekly content', 'Take photos and short videos on farm visits', 'Report on engagement monthly'],
   array['Current student or recent graduate', 'Good writing in English', 'Own a smartphone with a good camera'],
   array['digital-marketing', 'content-writing']),
  ('e05', 'Registered Nurse', 'full_time', 'on_site', 'mid', 'healthcare', 'OY', 'Ibadan',
   280000, 350000, true, 19, 1, false,
   'Provide outpatient and community care in our Bodija clinic.',
   array['Triage and care for outpatients', 'Run community health outreach days', 'Keep accurate patient records'],
   array['RN with current NMCN licence', '2+ years clinical experience', 'Fluent Yoruba'],
   array['nursing', 'yoruba']),
  ('e05', 'Pharmacist', 'full_time', 'on_site', 'mid', 'healthcare', 'OY', 'Ibadan',
   400000, 500000, true, 22, 8, false,
   'Run dispensing and stock control for two clinic pharmacies.',
   array['Dispense and counsel patients', 'Manage stock and expiries', 'Train pharmacy technicians'],
   array['B.Pharm with PCN licence', '2+ years post-internship', 'Inventory management experience'],
   array['pharmacy']),
  ('e05', 'Front Desk Officer', 'part_time', 'on_site', 'entry', 'healthcare', 'OY', 'Ibadan',
   80000, 100000, true, 8, 2, false,
   'Welcome patients and manage appointments on weekday afternoons.',
   array['Register patients and book appointments', 'Handle phone and WhatsApp enquiries', 'Keep the reception area organised'],
   array['OND or higher', 'Friendly and organised', 'Basic computer skills'],
   array['customer-service']),
  ('e06', 'Audit Senior', 'full_time', 'hybrid', 'senior', 'professional-services', 'FC', 'Abuja',
   600000, 800000, true, 24, 4, true,
   'Lead audit fieldwork for SME and NGO clients.',
   array['Plan and run audit engagements', 'Supervise and review associates'' work', 'Draft management letters'],
   array['ACA/ACCA qualified', '4+ years audit experience', 'IFRS and IPSAS knowledge'],
   array['audit', 'ifrs', 'accounting']),
  ('e06', 'Tax Associate', 'full_time', 'hybrid', 'entry', 'professional-services', 'FC', 'Abuja',
   250000, 320000, true, 15, 3, false,
   'Prepare VAT, PAYE and company income tax filings for clients.',
   array['Prepare monthly and annual tax returns', 'Reconcile client records', 'Research changes to Nigerian tax rules'],
   array['B.Sc. Accounting or Economics', 'ICAN/CITN in progress', 'Strong Excel'],
   array['taxation', 'accounting', 'excel']),
  ('e06', 'HR Generalist', 'full_time', 'on_site', 'mid', 'professional-services', 'FC', 'Abuja',
   350000, 450000, true, 13, 9, false,
   'Run recruitment, onboarding and payroll inputs for a 120-person firm.',
   array['Manage end-to-end recruitment', 'Prepare monthly payroll inputs', 'Keep HR policies up to date'],
   array['3+ years HR experience', 'CIPM membership is a plus', 'Good knowledge of Nigerian labour law'],
   array['hr-generalist', 'recruitment', 'payroll']),
  ('e06', 'Finance Intern', 'internship', 'on_site', 'entry', 'professional-services', 'OY', 'Ibadan',
   70000, null, true, 12, 3, false,
   'Support the Ibadan office with bookkeeping and client files.',
   array['Post transactions and reconcile accounts', 'Prepare client files for review', 'Assist with audit fieldwork'],
   array['Final-year student or recent graduate in Accounting', 'Good Excel', 'Eager to learn'],
   array['accounting', 'excel']),
  ('e07', 'Store Supervisor', 'full_time', 'on_site', 'mid', 'retail', 'LA', 'Ikeja',
   150000, 200000, true, 12, 2, false,
   'Run day-to-day operations in a busy neighbourhood store.',
   array['Lead a team of six sales associates', 'Manage stock counts and cash reconciliation', 'Keep shelves full and the store clean'],
   array['2+ years retail supervision', 'Comfortable with POS systems', 'Honest and reliable'],
   array['customer-service', 'excel']),
  ('e07', 'Sales Associate', 'part_time', 'on_site', 'entry', 'retail', 'LA', 'Surulere',
   70000, 90000, true, 7, 1, false,
   'Serve customers and keep the store running smoothly on weekends.',
   array['Serve customers at the till', 'Restock shelves', 'Keep the store tidy'],
   array['SSCE/WAEC', 'Friendly and punctual', 'Available Saturdays and Sundays'],
   array['customer-service']),
  ('e08', 'Network Field Engineer', 'full_time', 'on_site', 'mid', 'telecoms', 'FC', 'Abuja',
   450000, 600000, true, 17, 4, false,
   'Keep tower sites and fibre links running across the FCT and Nasarawa.',
   array['Respond to site outages within SLA', 'Carry out preventive maintenance', 'Document every site visit'],
   array['B.Eng. Electrical/Electronic', 'CCNA or equivalent', 'Valid driver''s licence'],
   array['networking', 'electrical-engineering']),
  ('e08', 'NOC Analyst', 'full_time', 'on_site', 'entry', 'telecoms', 'FC', 'Abuja',
   250000, 300000, true, 10, 6, false,
   'Monitor network health 24/7 and coordinate field fixes.',
   array['Watch dashboards and raise tickets', 'Coordinate field engineers during outages', 'Write shift handover reports'],
   array['B.Sc./HND in a technical field', 'Willing to work shifts', 'Basic networking knowledge'],
   array['networking']),
  ('e08', 'Cybersecurity Analyst', 'full_time', 'hybrid', 'senior', 'telecoms', 'FC', 'Abuja',
   null, null, false, 26, 12, false,
   'Protect our network management systems and respond to incidents.',
   array['Monitor alerts and investigate incidents', 'Run vulnerability assessments', 'Improve access controls'],
   array['5+ years security experience', 'Relevant certification (e.g. CompTIA Security+, CISSP)', 'Experience with SIEM tools'],
   array['cybersecurity', 'networking']),
  ('e09', 'Marine Logistics Coordinator', 'full_time', 'on_site', 'mid', 'maritime', 'RI', 'Onne',
   400000, 520000, true, 15, 3, false,
   'Coordinate vessel schedules, berthing and cargo documentation.',
   array['Plan vessel calls with port authorities', 'Prepare and check cargo documents', 'Keep clients updated on schedules'],
   array['3+ years in shipping or port operations', 'Strong communication', 'Knowledge of NPA processes'],
   array['supply-chain']),
  ('e09', 'Deck Cadet (NYSC)', 'nysc', 'on_site', 'entry', 'maritime', 'RI', 'Port Harcourt',
   80000, null, true, 20, 5, false,
   'A service-year placement supporting vessel operations.',
   array['Assist the deck team with daily operations', 'Learn safety and watchkeeping procedures', 'Keep logs accurate'],
   array['Currently serving NYSC corps member', 'Nautical science background preferred', 'Physically fit'],
   array['hse']),
  ('e10', 'Production Supervisor', 'full_time', 'on_site', 'mid', 'manufacturing', 'KN', 'Kano',
   280000, 360000, true, 18, 2, false,
   'Lead a shift of 40 operators on our finishing line.',
   array['Plan shift output and staffing', 'Track quality and waste', 'Coach operators on safe working'],
   array['HND/B.Sc. in Textile or Mechanical Engineering', '3+ years in manufacturing', 'Fluent Hausa'],
   array['mechanical-engineering', 'hausa']),
  ('e10', 'Maintenance Technician', 'full_time', 'on_site', 'mid', 'manufacturing', 'KN', 'Kano',
   180000, 240000, true, 14, 4, false,
   'Keep looms and finishing machines running.',
   array['Carry out planned maintenance', 'Fix breakdowns quickly and safely', 'Keep spare parts records'],
   array['OND/HND Mechanical or Electrical', '2+ years industrial maintenance', 'Able to read technical drawings'],
   array['mechanical-engineering', 'electrical-engineering']),
  ('e10', 'Quality Control Officer', 'contract', 'on_site', 'entry', 'manufacturing', 'KN', 'Kano',
   150000, 180000, true, 9, 1, false,
   'Inspect fabric at each stage and record defects.',
   array['Inspect samples against specifications', 'Record and report defects', 'Support root-cause investigations'],
   array['OND or higher in a science field', 'Good eyesight and attention to detail', 'Basic Excel'],
   array['excel']),
  ('e04', 'Agribusiness Sales Executive', 'full_time', 'hybrid', 'mid', 'agriculture', 'EN', 'Enugu',
   200000, 280000, true, 21, 7, false,
   'Win and grow relationships with produce buyers in the South-East.',
   array['Find and sign new buyers', 'Negotiate prices and delivery terms', 'Report weekly on the sales pipeline'],
   array['2+ years B2B sales', 'Own network in food distribution is a plus', 'Fluent Igbo and English'],
   array['sales', 'negotiation', 'igbo'])
)
insert into public.jobs (
  org_id, title, slug, summary, description, responsibilities, requirements, skills,
  benefits, job_type, arrangement, experience_level, industry, state, city,
  salary_min, salary_max, salary_disclosed, closing_date, status, published_at,
  is_sponsored, sponsored_until, screening_questions, is_demo
)
select
  org.id,
  j.title,
  trim(both '-' from regexp_replace(lower(j.title), '[^a-z0-9]+', '-', 'g')) || '-' || lower(j.st),
  j.summary,
  j.summary || E'\n\nDemo listing for development and testing. This is not a real vacancy.',
  j.resp,
  j.req,
  j.skills,
  array['Health insurance (HMO)', 'Pension (PFA) contributions', 'Paid annual leave'],
  j.jt::public.job_type,
  j.arr::public.work_arrangement,
  j.lvl::public.experience_level,
  j.ind,
  j.st,
  j.city,
  j.smin,
  j.smax,
  j.disc,
  current_date + j.close_in,
  'published',
  now() - make_interval(days => j.posted_ago),
  j.sponsored,
  case when j.sponsored then now() + interval '14 days' end,
  case when j.lvl = 'entry' then
    '[{"id":"q1","question":"Are you legally able to work in Nigeria?","type":"yes_no","knockout":{"answer":"no"}},
      {"id":"q2","question":"When could you start?","type":"text"}]'::jsonb
  else
    '[{"id":"q1","question":"How many years of relevant experience do you have?","type":"choice","options":["Less than 2","2-4","5+"]}]'::jsonb
  end,
  true
from j join org on org.k = j.k;

-- Two extra jobs that must stay hidden from the public: one past its closing
-- date (product rule 6) and one draft. Used by the RLS checks.
insert into public.jobs (org_id, title, slug, description, job_type, arrangement,
  experience_level, industry, state, city, closing_date, status, published_at, is_demo)
values
  ('00000000-0000-4000-a000-000000000e07', 'Cashier (closed)', 'cashier-closed-la',
   'Demo listing for development and testing. Past its closing date.',
   'full_time', 'on_site', 'entry', 'retail', 'LA', 'Ikeja', current_date - 3, 'published',
   now() - interval '40 days', true),
  ('00000000-0000-4000-a000-000000000e01', 'Engineering Manager (draft)', 'engineering-manager-draft-la',
   'Demo draft for development and testing.',
   'full_time', 'hybrid', 'manager', 'fintech', 'LA', 'Lekki', current_date + 30, 'draft',
   null, true);

-- END JOBS

-- ------------------------------------------------------------- courses ----
-- 12 demo courses from the three demo training providers. Prices in kobo
-- (0 = free). Every course gets modules and lessons; the first lesson of
-- each course is a free preview.

with p(k, id) as (
  values
    ('c1', '00000000-0000-4000-a000-0000000000c1'::uuid),
    ('c2', '00000000-0000-4000-a000-0000000000c2'::uuid),
    ('c3', '00000000-0000-4000-a000-0000000000c3'::uuid)
),
c(k, slug, title, summary, topic, lvl, fmt, lang, minutes, label, price, cert, outcomes, skills) as (
  values
  ('c1', 'intro-to-sql-for-analysts', 'Intro to SQL for Analysts',
   'Learn to query, filter and summarise business data so you can build reports without waiting on IT.',
   'Data & tech', 'beginner', 'self_paced', 'English', 480, '8 hours · 6 modules', 0, true,
   array['Write SELECT queries with filters and sorting', 'Join two or more tables correctly', 'Summarise data with GROUP BY', 'Build a weekly KPI query for a report'],
   array['sql', 'data-analysis']),
  ('c1', 'power-bi-essentials', 'Power BI Essentials',
   'Turn spreadsheets into interactive dashboards your manager will actually use.',
   'Data & tech', 'beginner', 'video', 'English', 600, '10 hours', 1500000, true,
   array['Import and clean data', 'Build visuals and slicers', 'Publish and share a dashboard'],
   array['power-bi', 'data-analysis']),
  ('c1', 'excel-for-data-reporting', 'Excel for Data Reporting',
   'From messy exports to clear weekly reports with formulas, pivot tables and charts.',
   'Data & tech', 'beginner', 'self_paced', 'English', 360, '6 hours', 0, true,
   array['Clean data with formulas', 'Summarise with pivot tables', 'Present results in clear charts'],
   array['excel', 'data-analysis']),
  ('c1', 'data-storytelling', 'Data Storytelling',
   'Present analysis so decision-makers understand it and act on it.',
   'Data & tech', 'intermediate', 'live_cohort', 'English', null, '4 weeks · live cohort', 3500000, true,
   array['Structure a data story', 'Choose the right chart', 'Present with confidence'],
   array['data-analysis', 'public-speaking']),
  ('c1', 'python-basics', 'Python Basics',
   'A gentle first programming course using real business examples.',
   'Data & tech', 'beginner', 'video', 'English', 720, '12 hours', 2000000, true,
   array['Write and run Python scripts', 'Work with lists and dictionaries', 'Automate a small spreadsheet task'],
   array['python']),
  ('c1', 'interview-confidence-bootcamp', 'Interview Confidence Bootcamp',
   'Practise the questions Nigerian employers ask and answer with clear, honest examples.',
   'Career readiness', 'all_levels', 'blended', 'English', 240, '4 modules', 750000, true,
   array['Prepare STAR examples', 'Handle competency questions', 'Follow up professionally'],
   array['public-speaking']),
  ('c2', 'workplace-readiness', 'Workplace Readiness',
   'Professional habits, communication and tools for your first job.',
   'Career readiness', 'all_levels', 'self_paced', 'English', 180, '3 hours', 0, false,
   array['Write professional emails', 'Manage your time', 'Work well in a team'],
   array['customer-service']),
  ('c2', 'customer-service-excellence-hausa-english', 'Customer Service Excellence (Hausa & English)',
   'Handle calls, chats and complaints confidently in Hausa and English.',
   'Career readiness', 'beginner', 'video', 'Hausa', 300, '5 hours', 0, true,
   array['Greet and diagnose customer needs', 'De-escalate complaints', 'Write clear follow-up messages'],
   array['customer-service', 'hausa']),
  ('c2', 'digital-skills-for-beginners', 'Digital Skills for Beginners',
   'Email, documents, spreadsheets and staying safe online.',
   'Data & tech', 'beginner', 'self_paced', 'Hausa', 240, '4 hours', 0, true,
   array['Use email and cloud documents', 'Create a simple spreadsheet', 'Spot common online scams'],
   array['excel']),
  ('c3', 'small-business-finance-basics', 'Small Business Finance Basics',
   'Understand cash flow, pricing and simple bookkeeping for your business.',
   'Business & entrepreneurship', 'beginner', 'self_paced', 'English', 300, '5 hours', 0, true,
   array['Track cash in and out', 'Price products profitably', 'Prepare simple monthly accounts'],
   array['accounting']),
  ('c3', 'hr-basics-for-small-teams', 'HR Basics for Small Teams',
   'Hire fairly, write simple contracts and stay on the right side of Nigerian labour law.',
   'HR & leadership', 'beginner', 'video', 'English', 270, '4.5 hours', 1200000, true,
   array['Write a clear job description', 'Run a fair interview', 'Set up a basic staff file and contract'],
   array['hr-generalist', 'recruitment']),
  ('c3', 'digital-marketing-for-smes', 'Digital Marketing for SMEs',
   'Reach more customers with WhatsApp, Instagram and a simple content plan.',
   'Business & entrepreneurship', 'intermediate', 'live_cohort', 'English', null, '3 weeks · live cohort', 2500000, true,
   array['Plan a month of content', 'Run a small paid campaign', 'Measure what works'],
   array['digital-marketing', 'content-writing'])
)
insert into public.courses (
  provider_org_id, title, slug, summary, description, topic, level, format, language,
  duration_minutes, duration_label, price_kobo, has_certificate, outcomes, skills,
  status, published_at, is_demo
)
select
  p.id, c.title, c.slug, c.summary,
  c.summary || E'\n\nDemo course for development and testing.',
  c.topic, c.lvl::public.course_level, c.fmt::public.course_format, c.lang,
  c.minutes, c.label, c.price, c.cert, c.outcomes, c.skills,
  'published', now() - interval '30 days', true
from c join p on p.k = c.k;

-- Intro to SQL: the full six-module syllabus from the course design.
insert into public.course_modules (course_id, title, position)
select co.id, m.title, m.pos
from public.courses co
cross join (values
  ('Why analysts use SQL', 1), ('Selecting and filtering', 2), ('Joining tables', 3),
  ('Summarising data', 4), ('Dates and KPIs', 5), ('Final practical task', 6)
) as m(title, pos)
where co.slug = 'intro-to-sql-for-analysts';

-- Every other course: three modules.
insert into public.course_modules (course_id, title, position)
select co.id, m.title, m.pos
from public.courses co
cross join (values ('Getting started', 1), ('Core skills', 2), ('Putting it into practice', 3)) as m(title, pos)
where co.is_demo and co.slug <> 'intro-to-sql-for-analysts';

-- Two lessons per module: a video/text lesson and a short quiz. The very
-- first lesson of each course is a free preview.
insert into public.lessons (module_id, title, kind, content, duration_minutes, is_preview, position)
select
  m.id,
  m.title || ': ' || l.title,
  l.kind,
  case l.kind
    when 'quiz' then '{"questions": [], "pass_mark": 70}'::jsonb
    else '{"markdown": "Demo lesson content."}'::jsonb
  end,
  l.mins,
  (m.position = 1 and l.pos = 1),
  l.pos
from public.course_modules m
cross join (values ('Lesson', 'video', 20, 1), ('Check your understanding', 'quiz', 10, 2)) as l(title, kind, mins, pos);

-- END COURSES

-- ------------------------------------------------------- opportunities ----
-- 15 demo opportunities, kept separate from jobs (product rule 7). Sources
-- point to example.org, never to real programmes.

insert into public.opportunities (
  type, title, slug, provider_name, summary, description, source_url,
  eligibility, benefits, funding_amount, state, country, is_remote, deadline,
  status, is_featured, is_demo, last_checked_at
)
select
  o.type::public.opportunity_type, o.title, o.slug, o.provider, o.summary,
  o.summary || E'\n\nDemo opportunity for development and testing. Always check the official source before applying.',
  'https://example.org/demo/opportunities/' || o.slug,
  o.elig::jsonb, o.benefits, o.funding, o.st, o.country, o.remote,
  current_date + o.days, 'published', o.featured, true, now() - interval '3 days'
from (values
  ('scholarship', 'Undergraduate STEM Scholarship', 'undergraduate-stem-scholarship', 'Demo Education Trust',
   'Tuition support for 200-level students in science and engineering.',
   '{"education": "200-level undergraduate", "fields": ["Engineering", "Sciences"], "min_cgpa": "3.5/5.0", "nationality": "Nigerian"}',
   'Tuition and a book allowance', 'Up to ₦500,000 per year', null, 'Nigeria', false, 35, true),
  ('scholarship', 'MSc Economics Scholarship (UK)', 'msc-economics-scholarship-uk', 'Demo University Fund',
   'A one-year master''s scholarship in economics or development studies.',
   '{"education": "First degree, Second Class Upper or above", "fields": ["Economics", "Development"], "nationality": "Nigerian"}',
   'Tuition, stipend and flights', 'Fully funded', null, 'United Kingdom', false, 60, true),
  ('scholarship', 'Women in Tech Bootcamp Scholarship', 'women-in-tech-bootcamp-scholarship', 'Demo Tech Foundation',
   'Free places on a 12-week software bootcamp for women.',
   '{"gender": "Female", "min_age": 18, "max_age": 35}',
   'Full bootcamp fee and a laptop loan', 'Full tuition', 'LA', 'Nigeria', false, 21, false),
  ('fellowship', 'Public Policy Fellowship', 'public-policy-fellowship', 'Demo Policy Institute',
   'A 9-month fellowship placing graduates in state ministries.',
   '{"education": "Graduate, NYSC completed", "max_age": 30}',
   'Monthly stipend and mentoring', '₦250,000 monthly stipend', 'FC', 'Nigeria', false, 28, false),
  ('fellowship', 'Climate Innovation Fellowship', 'climate-innovation-fellowship', 'Demo Green Network',
   'Support for early-stage founders working on climate solutions.',
   '{"stage": "Idea or prototype", "nationality": "African"}',
   'Coaching, workspace and a grant', 'Up to $10,000', null, 'Nigeria', true, 45, false),
  ('grant', 'Women-led SME Growth Grant', 'women-led-sme-growth-grant', 'Demo Enterprise Fund',
   'Grants for women-owned businesses ready to expand.',
   '{"business_age_years": "2+", "ownership": "51% women-owned", "registered": "CAC"}',
   'Grant and business advisory', 'Up to ₦5,000,000', null, 'Nigeria', false, 30, true),
  ('grant', 'Agri-processing Equipment Grant', 'agri-processing-equipment-grant', 'Demo Agric Development Programme',
   'Matching grants for small processors buying equipment.',
   '{"sector": "Agro-processing", "match_funding": "20%"}',
   'Equipment co-funding', 'Up to ₦3,000,000', 'KN', 'Nigeria', false, 40, false),
  ('volunteering', 'Community Literacy Volunteer', 'community-literacy-volunteer', 'Demo Reading Circle',
   'Teach reading to primary pupils on Saturday mornings.',
   '{"min_age": 18, "commitment": "3 hours a week"}',
   'Training and a certificate of service', null, 'OY', 'Nigeria', false, 25, false),
  ('volunteering', 'Health Outreach Volunteer', 'health-outreach-volunteer', 'Demo Health Partners',
   'Support free screening days in Port Harcourt communities.',
   '{"min_age": 18, "preferred": "Health or social science students"}',
   'Training, transport and meals', null, 'RI', 'Nigeria', false, 18, false),
  ('competition', 'Youth Business Plan Competition', 'youth-business-plan-competition', 'Demo Youth Enterprise Hub',
   'Pitch your business plan for seed funding and mentoring.',
   '{"min_age": 18, "max_age": 35, "stage": "Idea to early revenue"}',
   'Cash prizes and mentoring', 'Prizes up to ₦2,000,000', null, 'Nigeria', false, 32, true),
  ('international', 'Graduate Internship Programme (Ghana)', 'graduate-internship-programme-ghana', 'Demo Regional Bank',
   'A 6-month paid internship in Accra for West African graduates.',
   '{"education": "Graduate within 2 years", "languages": ["English"]}',
   'Monthly allowance and accommodation support', null, null, 'Ghana', false, 26, false),
  ('international', 'Short-term Research Exchange (Germany)', 'short-term-research-exchange-germany', 'Demo Academic Exchange',
   'A 3-month research visit for early-career academics.',
   '{"education": "PhD or PhD candidate"}',
   'Monthly stipend and travel', 'Fully funded', null, 'Germany', false, 75, false),
  ('tender', 'Facility Management Services Tender', 'facility-management-services-tender', 'Demo State Procurement Office',
   'Cleaning and maintenance services for public offices.',
   '{"registration": "CAC, tax clearance", "experience": "3+ similar contracts"}',
   null, null, 'LA', 'Nigeria', false, 14, false),
  ('accelerator', 'Agritech Accelerator Cohort', 'agritech-accelerator-cohort', 'Demo Innovation Hub',
   'A 12-week accelerator for agritech startups with early traction.',
   '{"stage": "Pre-seed to seed", "sector": "Agriculture"}',
   'Mentoring, investor demo day and equity-free support', 'Equity-free support', 'EN', 'Nigeria', false, 38, false),
  ('internship_programme', 'Banking Graduate Internship', 'banking-graduate-internship', 'Demo Finance Academy',
   'A 6-month rotation for graduates interested in banking operations.',
   '{"education": "B.Sc. with Second Class Lower or above", "nysc": "Completed"}',
   'Monthly stipend and training', '₦150,000 monthly stipend', 'LA', 'Nigeria', false, 20, false)
) as o(type, title, slug, provider, summary, elig, benefits, funding, st, country, remote, days, featured);

-- ---------------------------------------------------------------- plans ----
-- Demo plans. Prices are placeholders for development only; admins set real
-- prices in the console (no prices are hard-coded in the app).

insert into public.plans (code, name, audience, description, price_kobo, interval, entitlements, features, is_highlighted, sort_order, is_demo) values
  ('starter_seeker', 'Starter', 'job_seeker', 'Everyone looking for work', 0, 'month',
   '{"ai_credits_per_month": 10, "cv_versions": 2}',
   array['Career profile & applications', 'Job alerts by email & app', '10 AI credits / month', 'Selected free courses'], false, 1, true),
  ('career_plus', 'Career Plus', 'job_seeker', 'Active job seekers & graduates', 450000, 'month',
   '{"ai_credits_per_month": 100, "cv_versions": 10, "interview_coach": true}',
   array['Everything in Starter', 'Expanded AI credits', 'Multiple CV versions & advanced CV analysis', 'Career roadmap & interview coach', 'Premium course discounts'], true, 2, true),
  ('employer_professional', 'Employer Professional', 'employer', 'SMEs and growing teams', 4500000, 'month',
   '{"vacancy_credits_per_month": 10, "team_seats": 5, "analytics": true}',
   array['10 vacancy credits / month', 'Full ATS pipeline & screening', '5 team seats', 'Analytics & branded page'], true, 3, true),
  ('employer_enterprise', 'Employer Enterprise', 'employer', 'Large organisations & agencies (custom pricing)', 0, 'year',
   '{"custom_pricing": true, "team_seats": "unlimited", "candidate_search": true}',
   array['Unlimited seats & permissions', 'Candidate search', 'Integrations & reporting', 'Dedicated support'], false, 4, true),
  ('business_growth', 'Business Growth', 'business_owner', 'SMEs and founders', 1500000, 'month',
   '{"showcase": "enhanced", "opportunity_alerts": true}',
   array['Enhanced showcase listing', 'Opportunity alerts', 'Premium business courses', 'Priority consultancy access'], true, 5, true),
  ('provider_pro', 'Provider Pro', 'training_provider', 'Training organisations', 2500000, 'month',
   '{"paid_courses": true, "cohorts": true, "certificate_workflows": true}',
   array['Paid course sales', 'Cohorts & bulk enrolment', 'Learner analytics', 'Certificate workflows'], true, 6, true)
on conflict (code) do nothing;

-- ----------------------------------------------------------------- FAQs ----
-- Real product answers (not demo content), as shown on the homepage.

insert into public.faqs (category, question, answer_markdown, position) values
  ('General', 'Is JobsAndMore free for job seekers?',
   'Yes. Profile, search, applications, alerts and selected AI tools are free. Career Plus adds more AI credits and advanced tools.', 1),
  ('Trust', 'What does "Verified employer" mean?',
   'It means the employer passed email, business-details and authorised-representative checks. Partial checks get their own label.', 2),
  ('AI', 'Will an AI score decide if I get hired?',
   'No. Scores are estimates to help you improve. Employers make decisions, and no one is auto-rejected on an AI score.', 3),
  ('Safety', 'How do I report a suspicious job?',
   'Use "Report listing" on any job. Never pay a fee to apply for a job.', 4);

-- ------------------------------------------------------------ demo flag ----
-- Local/staging only: make the demo rows above visible.
update public.feature_flags set enabled = true where key = 'show_demo_content';

commit;
