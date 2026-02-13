-- ============================================
-- UMRE_ONKAYIT Tablosu Oluşturma
-- ============================================
-- Umre ön kayıt formundan gelen kayıtlar.
-- Her afiş/lokasyon için benzersiz link (?ref=xxx) ile ref takibi yapılır.
-- Supabase Dashboard > SQL Editor'da çalıştırın.

CREATE TABLE IF NOT EXISTS public.umre_onkayit (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT now(),

  -- Afiş/lokasyon takibi (QR linkindeki ?ref=xxx)
  ref text,

  -- Form alanları
  ad_soyad text NOT NULL,
  telefon text NOT NULL,
  email text,
  kisiler integer NOT NULL DEFAULT 1 CHECK (kisiler >= 1 AND kisiler <= 20),
  aciklama text,

  CONSTRAINT umre_onkayit_pkey PRIMARY KEY (id)
);

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_umre_onkayit_ref ON public.umre_onkayit(ref);
CREATE INDEX IF NOT EXISTS idx_umre_onkayit_created_at ON public.umre_onkayit(created_at);
CREATE INDEX IF NOT EXISTS idx_umre_onkayit_kisiler ON public.umre_onkayit(kisiler);

-- Yorumlar
COMMENT ON TABLE public.umre_onkayit IS 'Umre ön kayıt formu kayıtları';
COMMENT ON COLUMN public.umre_onkayit.ref IS 'Afiş referansı - QR linkindeki ?ref= parametresi (örn: kadikoy, sube-1)';
COMMENT ON COLUMN public.umre_onkayit.ad_soyad IS 'Kayıt sahibi ad soyad';
COMMENT ON COLUMN public.umre_onkayit.telefon IS 'İletişim telefonu';
COMMENT ON COLUMN public.umre_onkayit.email IS 'E-posta (opsiyonel)';
COMMENT ON COLUMN public.umre_onkayit.kisiler IS 'Kişi sayısı (1-20)';
COMMENT ON COLUMN public.umre_onkayit.aciklama IS 'Ek not/açıklama';

-- ============================================
-- RLS (Row Level Security) Politikaları
-- ============================================
-- Anonim (anon): Sadece INSERT - formu dolduran herkes kayıt ekleyebilir
-- Yetkili (authenticated): SELECT, UPDATE, DELETE - admin panelinden görüntüleme/düzenleme

ALTER TABLE public.umre_onkayit ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "umre_onkayit_insert_anon" ON public.umre_onkayit;
CREATE POLICY "umre_onkayit_insert_anon" ON public.umre_onkayit
  FOR INSERT
  WITH CHECK (true);
-- Anonim kullanıcılar form üzerinden sadece kayıt ekleyebilir

DROP POLICY IF EXISTS "umre_onkayit_select_authenticated" ON public.umre_onkayit;
CREATE POLICY "umre_onkayit_select_authenticated" ON public.umre_onkayit
  FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "umre_onkayit_update_authenticated" ON public.umre_onkayit;
CREATE POLICY "umre_onkayit_update_authenticated" ON public.umre_onkayit
  FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "umre_onkayit_delete_authenticated" ON public.umre_onkayit;
CREATE POLICY "umre_onkayit_delete_authenticated" ON public.umre_onkayit
  FOR DELETE
  USING (auth.role() = 'authenticated');
