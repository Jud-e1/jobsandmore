-- Run in the Supabase SQL editor (or psql) after at least one staff user
-- exists. Acts as that user through the real RLS policies, then raises its
-- report as an error so every change is rolled back.
-- End-to-end check of the signed-in flows as a real user, through the same
-- security rules the app uses. Everything is rolled back at the end (the
-- block finishes by raising its report as an error).
do $$
declare
  uid uuid := (select s.user_id from public.staff_roles s limit 1);
  job uuid;
  org public.organisations;
  myjob uuid;
  app uuid;
  vr uuid;
  course uuid;
  n int;
  report text := '';
  t2 uuid := gen_random_uuid();
begin
  -- a temporary second user (rolled back with everything else)
  insert into auth.users (id, email, raw_user_meta_data)
  values (t2, 'e2e-applicant@example.invalid', '{"full_name":"E2E Applicant","role":"job_seeker"}');
  perform set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', uid::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  execute 'set local role authenticated';

  -- job seeker
  select id into job from public.job_cards where status = 'published' and apply_method = 'platform' and (closing_date is null or closing_date >= current_date) limit 1;
  insert into public.saved_jobs (user_id, job_id) values (uid, job);
  report := report || 'save job OK; ';
  insert into public.applications (job_id, candidate_id, cover_letter, answers, source)
  values (job, uid, 'Test cover letter', '{}', 'search') returning id into app;
  report := report || 'apply OK; ';
  select count(*) into n from public.applications where candidate_id = uid;
  report := report || 'my applications=' || n || '; ';
  insert into public.job_alerts (user_id, name, keywords, states) values (uid, 'Test alert', '{analyst}', '{LA}');
  report := report || 'alert OK; ';
  update public.candidate_profiles set headline = 'Test headline' where user_id = uid;
  insert into public.skills (user_id, name) values (uid, 'Excel');
  report := report || 'profile+skill OK; ';
  select id into course from public.courses where status = 'published' and price_kobo = 0 limit 1;
  insert into public.enrolments (course_id, user_id) values (course, uid);
  report := report || 'enrol OK; ';

  -- employer
  org := public.create_my_organisation('employer', 'E2E Test Company Ltd', null, 'LA', '1-10', null);
  report := report || 'create company OK (' || org.slug || '); ';
  insert into public.jobs (org_id, created_by, title, slug, description, job_type, arrangement, experience_level, state, status, published_at)
  values (org.id, uid, 'E2E Test Role', 'e2e-test-role', 'A test role created by the automated check.', 'full_time', 'hybrid', 'entry', 'LA', 'published', now())
  returning id into myjob;
  report := report || 'post job OK; ';
  perform set_config('request.jwt.claim.sub', t2::text, true);
  perform set_config('request.jwt.claims', json_build_object('sub', t2, 'role', 'authenticated')::text, true);
  insert into public.applications (job_id, candidate_id) values (myjob, t2) returning id into app;
  perform set_config('request.jwt.claim.sub', uid::text, true);
  perform set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
  update public.applications set stage = 'shortlisted' where id = app;
  select count(*) into n from public.pipeline_cards where id = app and candidate_name = 'E2E Applicant' and stage = 'shortlisted';
  report := report || 'employer sees applicant name + moved stage=' || n || '; ';
  select count(*) into n from public.pipeline_cards where org_id = org.id;
  report := report || 'pipeline rows=' || n || '; ';
  report := report || 'overview=' || public.employer_overview(org.id)::text || '; ';
  update public.jobs set status = 'paused' where id = myjob;
  report := report || 'pause job OK; ';

  -- staff
  report := report || 'is_staff=' || public.is_staff() || '; ';
  insert into public.verification_requests (org_id, submitted_by, requested_level)
  values (org.id, uid, 'details_reviewed') returning id into vr;
  update public.verification_requests
     set status = 'approved', reviewer_id = uid, reviewer_notes = 'E2E check', decided_at = now()
   where id = vr;
  report := report || 'verification decided OK; ';

  -- consents
  perform public.set_consent('marketing_email', true);
  report := report || 'consent OK';

  raise exception 'E2E REPORT (all changes rolled back): %', report;
end $$;
