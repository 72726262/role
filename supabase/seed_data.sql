-- ================================================
-- SAMPLE DATA FOR TESTING
-- Run AFTER complete_schema.sql
-- ================================================

-- ================================================
-- IMPORTANT: First create users in Authentication
-- ================================================
-- Go to Authentication > Users > Add User
-- Create these test users (note their UUIDs):
-- 1. admin@company.com (Admin)
-- 2. hr@company.com (HR)
-- 3. it@company.com (IT)
-- 4. manager@company.com (Management)
-- 5. employee@company.com (Employee)

-- ================================================
-- STEP 1: INSERT USERS (Replace UUIDs)
-- ================================================
-- Replace these UUIDs with actual UUIDs from Authentication

INSERT INTO public.users (id, email, full_name, role_id) VALUES
    (
        '00000000-0000-0000-0000-000000000001'::uuid, -- Replace with actual UUID
        'admin@company.com',
        'System Administrator',
        (SELECT id FROM public.roles WHERE role_name = 'Admin')
    ),
    (
        '00000000-0000-0000-0000-000000000002'::uuid,
        'hr@company.com',
        'HR Manager',
        (SELECT id FROM public.roles WHERE role_name = 'HR')
    ),
    (
        '00000000-0000-0000-0000-000000000003'::uuid,
        'it@company.com',
        'IT Manager',
        (SELECT id FROM public.roles WHERE role_name = 'IT')
    ),
    (
        '00000000-0000-0000-0000-000000000004'::uuid,
        'manager@company.com',
        'General Manager',
        (SELECT id FROM public.roles WHERE role_name = 'Management')
    ),
    (
        '00000000-0000-0000-0000-000000000005'::uuid,
        'employee@company.com',
        'John Doe',
        (SELECT id FROM public.roles WHERE role_name = 'Employee')
    )
ON CONFLICT (email) DO NOTHING;

-- ================================================
-- STEP 2: INSERT EMPLOYEE PROFILES
-- ================================================
INSERT INTO public.employee_profiles (user_id, job_title, department, hire_date) VALUES
    ('00000000-0000-0000-0000-000000000001'::uuid, 'System Administrator', 'IT', '2020-01-15'),
    ('00000000-0000-0000-0000-000000000002'::uuid, 'HR Manager', 'Human Resources', '2019-03-20'),
    ('00000000-0000-0000-0000-000000000003'::uuid, 'IT Manager', 'IT', '2018-06-10'),
    ('00000000-0000-0000-0000-000000000004'::uuid, 'General Manager', 'Management', '2017-02-01'),
    ('00000000-0000-0000-0000-000000000005'::uuid, 'Software Developer', 'IT', '2021-09-01')
ON CONFLICT (user_id) DO NOTHING;

-- ================================================
-- STEP 3: INSERT NEWS
-- ================================================
INSERT INTO public.news (title, content, is_published, published_at, author_id) VALUES
    (
        'إطلاق نظام الموظفين الجديد',
        'يسعدنا الإعلان عن إطلاق نظام إدارة الموظفين الداخلي الجديد. يوفر النظام واجهة سهلة الاستخدام مع دعم كامل للغة العربية.',
        true,
        NOW() - INTERVAL '2 days',
        '00000000-0000-0000-0000-000000000004'::uuid
    ),
    (
        'سياسات العمل المحدّثة',
        'تم تحديث سياسات الموارد البشرية لعام 2024. يرجى مراجعة قسم السياسات للاطلاع على التغييرات.',
        true,
        NOW() - INTERVAL '5 days',
        '00000000-0000-0000-0000-000000000002'::uuid
    ),
    (
        'New Company Vision 2025',
        'Our company is embarking on a new strategic vision for 2025. Learn about our goals and commitments.',
        true,
        NOW() - INTERVAL '1 day',
        '00000000-0000-0000-0000-000000000004'::uuid
    );

-- ================================================
-- STEP 4: INSERT EVENTS
-- ================================================
INSERT INTO public.events (title, description, event_type, event_date, icon_name) VALUES
    ('عيد ميلاد أحمد', 'الاحتفال بعيد ميلاد أحمد من فريق التسويق', 'birthday', CURRENT_DATE + INTERVAL '3 days', 'cake'),
    ('اجتماع فريق IT', 'اجتماع شهري لفريق تقنية المعلومات', 'meeting', CURRENT_DATE + INTERVAL '7 days', 'groups'),
    ('يوم الشركة السنوي', 'الاحتفال السنوي بتأسيس الشركة', 'celebration', CURRENT_DATE + INTERVAL '30 days', 'celebration'),
    ('تدريب على الأمن السيبراني', 'ورشة عمل حول أفضل ممارسات الأمن السيبراني', 'training', CURRENT_DATE + INTERVAL '14 days', 'security');

-- ================================================
-- STEP 5: INSERT HR POLICIES
-- ================================================
INSERT INTO public.hr_policies (title, description, category, created_by) VALUES
    (
        'سياسة الإجازات',
        'تحدد هذه السياسة أنواع الإجازات المتاحة وكيفية طلبها والموافقة عليها.',
        'Leave Policy',
        '00000000-0000-0000-0000-000000000002'::uuid
    ),
    (
        'قواعد السلوك المهني',
        'معايير السلوك المهني المتوقع من جميع الموظفين في مكان العمل.',
        'Code of Conduct',
        '00000000-0000-0000-0000-000000000002'::uuid
    ),
    (
        'سياسة العمل عن بُعد',
        'القواعد والإرشادات الخاصة بالعمل عن بُعد والمرونة في أوقات العمل.',
        'Remote Work',
        '00000000-0000-0000-0000-000000000002'::uuid
    );

-- ================================================
-- STEP 6: INSERT TRAINING COURSES
-- ================================================
INSERT INTO public.training_courses (title, description, instructor, duration_hours, max_participants, start_date, end_date) VALUES
    (
        'أساسيات إدارة المشاريع',
        'دورة تدريبية شاملة حول منهجيات إدارة المشاريع وأفضل الممارسات.',
        'د. سارة أحمد',
        16,
        25,
        CURRENT_DATE + INTERVAL '20 days',
        CURRENT_DATE + INTERVAL '24 days'
    ),
    (
        'مهارات التواصل الفعّال',
        'تطوير مهارات التواصل اللفظي وغير اللفظي في بيئة العمل.',
        'أ. خالد محمد',
        8,
        30,
        CURRENT_DATE + INTERVAL '15 days',
        CURRENT_DATE + INTERVAL '17 days'
    ),
    (
        'Excel المتقدم',
        'تعلم الوظائف المتقدمة في Excel للتحليل والتقارير.',
        'أ. فاطمة علي',
        12,
        20,
        CURRENT_DATE + INTERVAL '10 days',
        CURRENT_DATE + INTERVAL '12 days'
    );

-- ================================================
-- STEP 7: INSERT IT POLICIES
-- ================================================
INSERT INTO public.it_policies (title, description, policy_type) VALUES
    (
        'سياسة كلمات المرور',
        'متطلبات قوة كلمات المرور وإرشادات تغييرها بشكل دوري.',
        'security'
    ),
    (
        'سياسة استخدام البريد الإلكتروني',
        'القواعد والإرشادات للاستخدام الصحيح للبريد الإلكتروني الخاص بالشركة.',
        'usage'
    ),
    (
        'سياسة حماية البيانات',
        'إجراءات حماية بيانات الشركة والمعلومات السرية.',
        'security'
    ),
    (
        'Acceptable Use Policy',
        'Guidelines for acceptable use of company IT resources and equipment.',
        'compliance'
    );

-- ================================================
-- STEP 8: INSERT MANAGEMENT MESSAGES
-- ================================================
INSERT INTO public.management_messages (title, message, priority, published_by) VALUES
    (
        'تحديث هام: السياسات الجديدة',
        'نود إعلامكم بأنه تم تحديث سياسات الشركة. يرجى مراجعة قسم الموارد البشرية لمزيد من التفاصيل.',
        'high',
        '00000000-0000-0000-0000-000000000004'::uuid
    ),
    (
        'شكر وتقدير',
        'نشكر جميع الموظفين على جهودهم المتميزة في الربع الأخير. عمل رائع!',
        'medium',
        '00000000-0000-0000-0000-000000000004'::uuid
    ),
    (
        'اجتماع عام - عاجل',
        'سيعقد اجتماع عام يوم الأحد القادم الساعة 10 صباحاً. الحضور إلزامي.',
        'urgent',
        '00000000-0000-0000-0000-000000000004'::uuid
    );

-- ================================================
-- STEP 9: INSERT NAVIGATION LINKS
-- ================================================
INSERT INTO public.navigation_links (title, icon_name, url, display_order, is_active) VALUES
    ('دليل الموظف', 'menu_book', 'https://company.com/handbook', 1, true),
    ('نظام الرواتب', 'payments', 'https://payroll.company.com', 2, true),
    ('حجز قاعات الاجتماعات', 'meeting_room', 'https://booking.company.com', 3, true),
    ('خدمة الدعم الفني', 'support_agent', 'https://support.company.com', 4, true),
    ('بوابة التدريب', 'school', 'https://training.company.com', 5, true),
    ('التقويم العام', 'calendar_today', 'https://calendar.company.com', 6, true);

-- ================================================
-- STEP 10: INSERT SAMPLE MOODS
-- ================================================
INSERT INTO public.moods (user_id, mood_type, recorded_at) VALUES
    ('00000000-0000-0000-0000-000000000005'::uuid, 'happy', NOW() - INTERVAL '2 days'),
    ('00000000-0000-0000-0000-000000000005'::uuid, 'normal', NOW() - INTERVAL '1 day');

-- ================================================
-- SUCCESS MESSAGE
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '✅ Sample data inserted successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Data Summary:';
    RAISE NOTICE '- 5 Users with profiles';
    RAISE NOTICE '- 3 News articles';
    RAISE NOTICE '- 4 Events';
    RAISE NOTICE '- 3 HR Policies';
    RAISE NOTICE '- 3 Training Courses';
    RAISE NOTICE '- 4 IT Policies';
    RAISE NOTICE '- 3 Management Messages';
    RAISE NOTICE '- 6 Navigation Links';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 Test Logins:';
    RAISE NOTICE 'admin@company.com - Full access';
    RAISE NOTICE 'hr@company.com - HR Dashboard';
    RAISE NOTICE 'it@company.com - IT Dashboard';
    RAISE NOTICE 'manager@company.com - Management Dashboard';
    RAISE NOTICE 'employee@company.com - Employee Dashboard';
END $$;
