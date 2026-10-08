-- ==============================================================================
-- KWIZZ DATABASE SCHEMA (CLEAN & SIMPLE)
-- Tables: users, profiles, quiz_results
-- ==============================================================================

-- 1. USERS (Public user identity & emails)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Backfill users from existing auth.users
INSERT INTO public.users (id, email, created_at)
SELECT id, email, created_at FROM auth.users
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

-- 2. PROFILES (Game stats, avatars, and leaderboard scores)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY,
  username TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT DEFAULT 'avatar_7',
  title TEXT DEFAULT 'Student',
  gems INT DEFAULT 30,
  total_score INT DEFAULT 0,
  quizzes_played INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. QUIZ RESULTS (Quiz match history, scores & accuracies)
CREATE TABLE IF NOT EXISTS public.quiz_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  username TEXT DEFAULT 'Player',
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  score INT DEFAULT 0,
  total_questions INT DEFAULT 10,
  correct_answers INT DEFAULT 0,
  gems_earned INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Leaderboard index for fast ranking
CREATE INDEX IF NOT EXISTS idx_profiles_leaderboard ON public.profiles(gems DESC, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_quiz_history ON public.quiz_results(user_id, created_at DESC);

-- 4. AUTO-SYNC TRIGGER (auth.users -> public.users & public.profiles)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into public.users
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

  -- Insert into public.profiles
  INSERT INTO public.profiles (id, username, full_name, avatar_url, title, gems, total_score, quizzes_played)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', 'avatar_7'),
    'Student',
    30,
    0,
    0
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 5. ROW LEVEL SECURITY (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read users" ON public.users;
CREATE POLICY "Allow read users" ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow read profiles" ON public.profiles;
CREATE POLICY "Allow read profiles" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow update own profile" ON public.profiles;
CREATE POLICY "Allow update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Allow insert own profile" ON public.profiles;
CREATE POLICY "Allow insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Allow read quiz_results" ON public.quiz_results FOR SELECT USING (true);
CREATE POLICY "Allow insert quiz_results" ON public.quiz_results FOR INSERT WITH CHECK (true);
