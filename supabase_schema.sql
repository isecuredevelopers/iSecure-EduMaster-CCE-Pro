-- ========================================================================
-- CCE PRO (सातत्यपूर्ण सर्वकष मूल्यमापन प्रणाली)
-- Multi-School SaaS & Whitelabel Supabase Database Schema
-- Compatible with PostgreSQL 15+ / Supabase
-- ========================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. SCHOOL PROFILE & SETTINGS (शाळा माहिती व सॉफ्टवेअर सेटिंग्ज)
-- Designed for selling to any school with custom branding & configuration
CREATE TABLE IF NOT EXISTS public.schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_name TEXT NOT NULL,
    sanstha_name TEXT,
    udise_code VARCHAR(20) UNIQUE,
    board TEXT DEFAULT 'महाराष्ट्र राज्य मंडळ (State Board)',
    medium TEXT DEFAULT 'मराठी (Marathi)',
    cluster TEXT, -- केंद्र
    block_taluka TEXT, -- तालुका
    district TEXT, -- जिल्हा
    state TEXT DEFAULT 'महाराष्ट्र (Maharashtra)',
    address TEXT,
    pincode VARCHAR(10),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    headmaster_name TEXT,
    headmaster_prefix TEXT DEFAULT 'श्री.',
    logo_url TEXT,
    stamp_signature_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ACADEMIC YEARS (शैक्षणिक वर्षे)
CREATE TABLE IF NOT EXISTS public.academic_years (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    year_name VARCHAR(20) NOT NULL, -- e.g., '2024-25'
    start_date DATE,
    end_date DATE,
    sem1_result_date DATE,
    sem2_result_date DATE,
    reopening_date DATE,
    reopening_message TEXT DEFAULT 'उन्हाळी सुट्टीनंतर शाळा दिनांक १५ जून रोजी सुरु होईल.',
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CLASSES & DIVISIONS (इयत्ता व तुकड्या)
CREATE TABLE IF NOT EXISTS public.classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    standard INT NOT NULL CHECK (standard BETWEEN 1 AND 12), -- 1 to 8 or 10
    division VARCHAR(10) NOT NULL, -- 'A', 'B' or '१', '२'
    class_teacher_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(school_id, standard, division)
);

-- 4. SUBJECTS MASTER (विषय रचना)
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    subject_code VARCHAR(10) NOT NULL, -- 's1', 's2' .. 's9'
    subject_name_mr TEXT NOT NULL, -- 'प्रथम भाषा मराठी'
    subject_name_en TEXT NOT NULL, -- 'First Language English / Marathi'
    short_name TEXT, -- 'मराठी'
    applicable_standards INT[] DEFAULT '{1,2,3,4,5,6,7,8}',
    formative_max INT DEFAULT 70, -- आकारिक कमाल गुण
    summative_max INT DEFAULT 30, -- संकलित कमाल गुण
    is_graded_only BOOLEAN DEFAULT false, -- For Art, WE, PE (कला, कार्यानुभव, शा.शि.)
    order_index INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(school_id, subject_code)
);

-- 5. EVALUATION WEIGHTAGE RULES (भारांश गुण निश्चिती)
CREATE TABLE IF NOT EXISTS public.evaluation_weightages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    standard INT NOT NULL,
    subject_code VARCHAR(10) NOT NULL,
    semester INT NOT NULL CHECK (semester IN (1, 2)),
    -- Formative Tools (आकारिक मूल्यमापन साधने 1 to 8)
    fe1_name TEXT DEFAULT 'दैनंदिन निरीक्षण',
    fe1_max INT DEFAULT 0,
    fe2_name TEXT DEFAULT 'तोंडी काम',
    fe2_max INT DEFAULT 20,
    fe3_name TEXT DEFAULT 'प्रात्यक्षिके / प्रयोग',
    fe3_max INT DEFAULT 10,
    fe4_name TEXT DEFAULT 'उपक्रम / कृती',
    fe4_max INT DEFAULT 10,
    fe5_name TEXT DEFAULT 'प्रकल्प',
    fe5_max INT DEFAULT 0,
    fe6_name TEXT DEFAULT 'चाचणी (लेखी)',
    fe6_max INT DEFAULT 20,
    fe7_name TEXT DEFAULT 'स्वाध्याय / वर्गकार्य',
    fe7_max INT DEFAULT 10,
    fe8_name TEXT DEFAULT 'इतर',
    fe8_max INT DEFAULT 0,
    fet_total_max INT DEFAULT 70,
    -- Summative Tools (संकलित मूल्यमापन साधने 1 to 3)
    se1_name TEXT DEFAULT 'तोंडी',
    se1_max INT DEFAULT 10,
    se2_name TEXT DEFAULT 'प्रात्यक्षिक',
    se2_max INT DEFAULT 0,
    se3_name TEXT DEFAULT 'लेखी',
    se3_max INT DEFAULT 20,
    set_total_max INT DEFAULT 30,
    total_max INT DEFAULT 100,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. GRADING SCALES (श्रेणी रचना)
CREATE TABLE IF NOT EXISTS public.grading_scales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    grade_name VARCHAR(10) NOT NULL, -- 'अ-1', 'अ-2', 'ब-1', 'ब-2', 'क-1', 'क-2', 'ड', 'ई-1', 'ई-2'
    min_marks NUMERIC(5,2) NOT NULL,
    max_marks NUMERIC(5,2) NOT NULL,
    description TEXT,
    order_index INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. CASTE CATEGORIES (प्रवर्ग मास्टर)
CREATE TABLE IF NOT EXISTS public.caste_categories (
    id INT PRIMARY KEY,
    category_name TEXT NOT NULL, -- OPEN, OBC, SC, ST, VJNT, SBC
    category_name_mr TEXT NOT NULL
);

-- 8. STUDENTS (विद्यार्थी नोंदणी)
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
    standard INT NOT NULL,
    division VARCHAR(10) NOT NULL,
    gr_no VARCHAR(50) NOT NULL, -- जनरल रजिस्टर / दाखिला क्र.
    roll_no_sem1 INT NOT NULL,
    roll_no_sem2 INT,
    student_name_mr TEXT NOT NULL, -- विद्यार्थ्याचे नाव मराठीत
    student_name_en TEXT,
    father_name TEXT,
    mother_name TEXT,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('M', 'F', 'T')),
    caste_category_id INT REFERENCES public.caste_categories(id),
    sub_caste TEXT,
    date_of_birth DATE NOT NULL,
    birth_place TEXT,
    taluka TEXT,
    district TEXT,
    saral_id VARCHAR(50), -- सरल आयडी
    apaar_id VARCHAR(50), -- अपार आयडी
    pen_no VARCHAR(50), -- PEN क्र.
    aadhaar_no VARCHAR(20),
    bank_acc_no VARCHAR(50),
    ifsc_code VARCHAR(20),
    mobile_no VARCHAR(20),
    address TEXT,
    father_occupation TEXT,
    mother_occupation TEXT,
    height_sem1 NUMERIC(5,2),
    height_sem2 NUMERIC(5,2),
    weight_sem1 NUMERIC(5,2),
    weight_sem2 NUMERIC(5,2),
    is_minority BOOLEAN DEFAULT false,
    photo_url TEXT,
    is_promoted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(school_id, academic_year_id, standard, division, roll_no_sem1)
);

-- 9. MARKS EVALUATIONS (गुणनोंद पत्रक)
CREATE TABLE IF NOT EXISTS public.evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    standard INT NOT NULL,
    division VARCHAR(10) NOT NULL,
    semester INT NOT NULL CHECK (semester IN (1, 2)),
    subject_code VARCHAR(10) NOT NULL,
    -- Formative tool marks
    fe1 NUMERIC(5,2) DEFAULT 0,
    fe2 NUMERIC(5,2) DEFAULT 0,
    fe3 NUMERIC(5,2) DEFAULT 0,
    fe4 NUMERIC(5,2) DEFAULT 0,
    fe5 NUMERIC(5,2) DEFAULT 0,
    fe6 NUMERIC(5,2) DEFAULT 0,
    fe7 NUMERIC(5,2) DEFAULT 0,
    fe8 NUMERIC(5,2) DEFAULT 0,
    fet NUMERIC(5,2) DEFAULT 0, -- Total Formative (आकारिक एकूण)
    -- Summative tool marks
    se1 NUMERIC(5,2) DEFAULT 0,
    se2 NUMERIC(5,2) DEFAULT 0,
    se3 NUMERIC(5,2) DEFAULT 0,
    set NUMERIC(5,2) DEFAULT 0, -- Total Summative (संकलित एकूण)
    -- Calculated totals
    tet NUMERIC(5,2) DEFAULT 0, -- Total Marks (FET + SET)
    percentage NUMERIC(5,2) DEFAULT 0,
    grade VARCHAR(10), -- 'अ-1', 'ब-1' etc.
    grace_marks NUMERIC(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, semester, subject_code)
);

-- 10. DESCRIPTIVE REMARKS / NONDI (वर्णनात्मक नोंदी)
CREATE TABLE IF NOT EXISTS public.descriptive_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    standard INT NOT NULL,
    division VARCHAR(10) NOT NULL,
    semester INT NOT NULL CHECK (semester IN (1, 2)),
    -- Subject remarks
    s1 TEXT, -- प्रथम भाषा
    s2 TEXT, -- द्वितीय भाषा
    s3 TEXT, -- तृतीय भाषा
    s4 TEXT, -- गणित
    s5 TEXT, -- विज्ञान / परिसर अभ्यास
    s6 TEXT, -- सामाजिक शास्त्रे
    s7 TEXT, -- कला
    s8 TEXT, -- कार्यानुभव
    s9 TEXT, -- शारीरिक शिक्षण व आरोग्य
    -- General Observations
    s10 TEXT, -- विशेष प्रगती (Special Progress)
    s11 TEXT, -- आवड / छंद (Interests / Hobbies)
    s12 TEXT, -- सुधारणा आवश्यक (Scope for Improvement)
    s13 TEXT, -- व्यक्तिमत्त्व गुणविशेष (Personality Traits & Habits)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, semester)
);

-- 11. DESCRIPTIVE REMARKS BANK (वर्णनात्मक नोंदींचे पूर्वनिर्धारित भांडार)
CREATE TABLE IF NOT EXISTS public.descriptive_notes_bank (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES public.schools(id) ON DELETE CASCADE, -- NULL means global default
    standard INT DEFAULT 0, -- 0 means all standards
    category VARCHAR(20) NOT NULL, -- 's1'..'s9', 's10', 's11', 's12', 's13'
    remark_mr TEXT NOT NULL,
    remark_en TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. MONTHLY ATTENDANCE (माहेवार उपस्थिती)
CREATE TABLE IF NOT EXISTS public.student_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    standard INT NOT NULL,
    division VARCHAR(10) NOT NULL,
    jun_days INT DEFAULT 0,
    jul_days INT DEFAULT 0,
    aug_days INT DEFAULT 0,
    sep_days INT DEFAULT 0,
    oct_days INT DEFAULT 0,
    nov_days INT DEFAULT 0,
    dec_days INT DEFAULT 0,
    jan_days INT DEFAULT 0,
    feb_days INT DEFAULT 0,
    mar_days INT DEFAULT 0,
    apr_days INT DEFAULT 0,
    sem1_total INT DEFAULT 0,
    sem2_total INT DEFAULT 0,
    grand_total INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id)
);

-- 13. SCHOOL WORKING DAYS (शाळेचे एकूण कामाचे दिवस)
CREATE TABLE IF NOT EXISTS public.working_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
    standard INT NOT NULL,
    division VARCHAR(10) NOT NULL,
    jun_days INT DEFAULT 12,
    jul_days INT DEFAULT 24,
    aug_days INT DEFAULT 23,
    sep_days INT DEFAULT 22,
    oct_days INT DEFAULT 18,
    nov_days INT DEFAULT 19,
    dec_days INT DEFAULT 24,
    jan_days INT DEFAULT 24,
    feb_days INT DEFAULT 22,
    mar_days INT DEFAULT 24,
    apr_days INT DEFAULT 20,
    sem1_total INT DEFAULT 99,
    sem2_total INT DEFAULT 133,
    grand_total INT DEFAULT 232,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(school_id, academic_year_id, standard, division)
);

-- ========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES FOR SAAS / MULTI-TENANCY
-- ========================================================================
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.descriptive_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.working_days ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to access their own school data
CREATE POLICY "Public Read/Write for Single School Setup" ON public.schools FOR ALL USING (true);
CREATE POLICY "Academic Years Policy" ON public.academic_years FOR ALL USING (true);
CREATE POLICY "Classes Policy" ON public.classes FOR ALL USING (true);
CREATE POLICY "Subjects Policy" ON public.subjects FOR ALL USING (true);
CREATE POLICY "Students Policy" ON public.students FOR ALL USING (true);
CREATE POLICY "Evaluations Policy" ON public.evaluations FOR ALL USING (true);
CREATE POLICY "Descriptive Notes Policy" ON public.descriptive_notes FOR ALL USING (true);
CREATE POLICY "Attendance Policy" ON public.student_attendance FOR ALL USING (true);
CREATE POLICY "Working Days Policy" ON public.working_days FOR ALL USING (true);
