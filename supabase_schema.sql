-- 0pinion Database Schema & RLS Policies

-- 1. PROFILES (Extends auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_seed INTEGER NOT NULL DEFAULT 1,
    reputation_score INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. ZEROES (Topics/Categories)
CREATE TABLE public.zeroes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    opinions_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. OPINIONS (Main Posts)
CREATE TABLE public.opinions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    zero_id UUID REFERENCES public.zeroes(id) ON DELETE SET NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT false,
    is_cooking BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. ARGUMENTS (Responses)
CREATE TABLE public.arguments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opinion_id UUID NOT NULL REFERENCES public.opinions(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('support', 'oppose', 'question')),
    content TEXT NOT NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. LIVE ROOMS & MESSAGES
CREATE TABLE public.live_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    topic TEXT NOT NULL,
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    participant_count INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.live_rooms(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-------------------------------------------------------------------
-- ROW-LEVEL SECURITY (RLS)
-------------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zeroes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opinions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arguments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- PROFILES
-- Anyone can read profiles
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (true);
-- Users can only insert/update their own profile
CREATE POLICY "Users can insert their own profile" ON public.profiles
    FOR INSERT WITH CHECK ((select auth.uid()) = id);
CREATE POLICY "Users can update their own profile" ON public.profiles
    FOR UPDATE USING ((select auth.uid()) = id) WITH CHECK ((select auth.uid()) = id);

-- ZEROES
-- Anyone can read zeroes
CREATE POLICY "Zeroes are viewable by everyone" ON public.zeroes
    FOR SELECT USING (true);

-- OPINIONS
-- Anyone can read opinions
CREATE POLICY "Opinions are viewable by everyone" ON public.opinions
    FOR SELECT USING (true);
-- Authenticated users can insert their own opinions
CREATE POLICY "Users can insert own opinions" ON public.opinions
    FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = author_id);
-- Authenticated users can update their own opinions
CREATE POLICY "Users can update own opinions" ON public.opinions
    FOR UPDATE TO authenticated USING ((select auth.uid()) = author_id) WITH CHECK ((select auth.uid()) = author_id);
-- Authenticated users can delete their own opinions
CREATE POLICY "Users can delete own opinions" ON public.opinions
    FOR DELETE TO authenticated USING ((select auth.uid()) = author_id);

-- ARGUMENTS
-- Anyone can read arguments
CREATE POLICY "Arguments are viewable by everyone" ON public.arguments
    FOR SELECT USING (true);
-- Authenticated users can insert their own arguments
CREATE POLICY "Users can insert own arguments" ON public.arguments
    FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = author_id);
-- Authenticated users can delete their own arguments
CREATE POLICY "Users can delete own arguments" ON public.arguments
    FOR DELETE TO authenticated USING ((select auth.uid()) = author_id);

-- LIVE ROOMS & MESSAGES
-- Public read
CREATE POLICY "Live rooms viewable by everyone" ON public.live_rooms FOR SELECT USING (true);
CREATE POLICY "Chat messages viewable by everyone" ON public.chat_messages FOR SELECT USING (true);
-- Authenticated insert
CREATE POLICY "Users can insert rooms" ON public.live_rooms FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = host_id);
CREATE POLICY "Users can insert messages" ON public.chat_messages FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = author_id);

-------------------------------------------------------------------
-- ANONYMITY VIEW
-------------------------------------------------------------------
-- Instead of reading directly from the 'opinions' table, the client 
-- can read from this view, which securely strips the author_id if is_anonymous=true.
CREATE VIEW public.public_opinions WITH (security_invoker = true) AS
SELECT 
    id,
    title,
    content,
    zero_id,
    is_anonymous,
    is_cooking,
    created_at,
    CASE WHEN is_anonymous THEN NULL ELSE author_id END AS author_id
FROM public.opinions;

CREATE VIEW public.public_arguments WITH (security_invoker = true) AS
SELECT 
    id,
    opinion_id,
    type,
    content,
    is_anonymous,
    created_at,
    CASE WHEN is_anonymous THEN NULL ELSE author_id END AS author_id
FROM public.arguments;

-------------------------------------------------------------------
-- REPUTATION SYSTEM TRIGGERS & FUNCTIONS
-------------------------------------------------------------------

-- Function to handle reputation changes based on opinions
CREATE OR REPLACE FUNCTION public.handle_opinion_reputation()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.profiles
        SET reputation_score = reputation_score + 5
        WHERE id = NEW.author_id;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.profiles
        SET reputation_score = reputation_score - 5
        WHERE id = OLD.author_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for opinions
CREATE OR REPLACE TRIGGER on_opinion_reputation
AFTER INSERT OR DELETE ON public.opinions
FOR EACH ROW EXECUTE FUNCTION public.handle_opinion_reputation();

-- Function to handle reputation changes based on arguments
CREATE OR REPLACE FUNCTION public.handle_argument_reputation()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.profiles
        SET reputation_score = reputation_score + 10
        WHERE id = NEW.author_id;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.profiles
        SET reputation_score = reputation_score - 10
        WHERE id = OLD.author_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for arguments
CREATE OR REPLACE TRIGGER on_argument_reputation
AFTER INSERT OR DELETE ON public.arguments
FOR EACH ROW EXECUTE FUNCTION public.handle_argument_reputation();

-------------------------------------------------------------------
-- STANCE UNIQUE INDEX
-------------------------------------------------------------------
-- Ensures each user can have at most one active position (Support or Oppose) per opinion.
-- If they want to change their stance, they must delete their existing stance argument first.
CREATE UNIQUE INDEX unique_user_stance_per_opinion 
ON public.arguments (opinion_id, author_id) 
WHERE (type IN ('support', 'oppose'));


