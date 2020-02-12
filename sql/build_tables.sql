-- Create STATUS_ENUM ENUM
DO $$ BEGIN
    CREATE TYPE STATUS_ENUM AS ENUM ('Wt', 'Mut');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create UNIT_ENUM ENUM
DO $$ BEGIN
    CREATE TYPE UNIT_ENUM AS ENUM ('Count', 'Fraction', 'Per Megabase', 'Score', 'Year' );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
