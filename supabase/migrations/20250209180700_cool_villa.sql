-- Drop existing type if exists
DROP TYPE IF EXISTS delegation_enum CASCADE;

-- Create new delegation_enum type with updated values
CREATE TYPE delegation_enum AS ENUM (
    'MADRID',
    'ALAVA',
    'SANTANDER',
    'SEVILLA',
    'VALLADOLID',
    'MURCIA',
    'BURGOS',
    'PROFESIONALES',
    'ALICANTE',
    'LA LINEA',
    'CADIZ',
    'PALENCIA',
    'CORDOBA'
);

-- Add delegation column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'employee_profiles' 
        AND column_name = 'delegation'
    ) THEN
        ALTER TABLE employee_profiles
        ADD COLUMN delegation delegation_enum;
    END IF;
END $$;

-- Create function to get delegation for a work center
CREATE OR REPLACE FUNCTION get_work_center_delegation(p_work_center work_center_enum)
RETURNS delegation_enum AS $$
BEGIN
  CASE p_work_center::text
    -- Madrid
    WHEN 'MADRID HOGARES DE EMANCIPACION V. DEL PARDILLO' THEN RETURN 'MADRID';
    WHEN 'MADRID CUEVAS DE ALMANZORA' THEN RETURN 'MADRID';
    WHEN 'MADRID OFICINA' THEN RETURN 'MADRID';
    WHEN 'MADRID ALCOBENDAS' THEN RETURN 'MADRID';
    WHEN 'MADRID JOSE DE PASAMONTE' THEN RETURN 'MADRID';
    WHEN 'MADRID VALDEBERNARDO' THEN RETURN 'MADRID';
    WHEN 'MADRID MIGUEL HERNANDEZ' THEN RETURN 'MADRID';
    WHEN 'MADRID GABRIEL USERA' THEN RETURN 'MADRID';
    WHEN 'MADRID IBIZA' THEN RETURN 'MADRID';
    WHEN 'MADRID DIRECTORES DE CENTRO' THEN RETURN 'MADRID';
    WHEN 'MADRID HUMANITARIAS' THEN RETURN 'MADRID';
    WHEN 'MADRID VIRGEN DEL PUIG' THEN RETURN 'MADRID';
    WHEN 'MADRID ALMACEN' THEN RETURN 'MADRID';
    WHEN 'MADRID PASEO EXTREMADURA' THEN RETURN 'MADRID';
    WHEN 'MADRID HOGARES DE EMANCIPACION SANTA CLARA' THEN RETURN 'MADRID';
    WHEN 'MADRID ARROYO DE LAS PILILLAS' THEN RETURN 'MADRID';
    WHEN 'MADRID AVDA DE AMERICA' THEN RETURN 'MADRID';
    WHEN 'MADRID CENTRO DE DIA CARMEN HERRERO' THEN RETURN 'MADRID';
    WHEN 'MADRID HOGARES DE EMANCIPACION BOCANGEL' THEN RETURN 'MADRID';
    WHEN 'MADRID HOGARES DE EMANCIPACION ROQUETAS' THEN RETURN 'MADRID';
    
    -- Álava
    WHEN 'ALAVA HAZIBIDE' THEN RETURN 'ALAVA';
    WHEN 'ALAVA PAULA MONTAL' THEN RETURN 'ALAVA';
    WHEN 'ALAVA SENDOA' THEN RETURN 'ALAVA';
    WHEN 'ALAVA EKILORE' THEN RETURN 'ALAVA';
    WHEN 'ALAVA GESTIÓN AUKERA' THEN RETURN 'ALAVA';
    WHEN 'ALAVA GESTIÓN HOGARES' THEN RETURN 'ALAVA';
    WHEN 'ALAVA XABIER' THEN RETURN 'ALAVA';
    WHEN 'ALAVA ATENCION DIRECTA' THEN RETURN 'ALAVA';
    WHEN 'ALAVA PROGRAMA DE SEGUIMIENTO' THEN RETURN 'ALAVA';
    
    -- Santander
    WHEN 'SANTANDER OFICINA' THEN RETURN 'SANTANDER';
    WHEN 'SANTANDER ALISAL' THEN RETURN 'SANTANDER';
    WHEN 'SANTANDER MARIA NEGRETE (CENTRO DE DÍA)' THEN RETURN 'SANTANDER';
    WHEN 'SANTANDER ASTILLERO' THEN RETURN 'SANTANDER';
    
    -- Sevilla
    WHEN 'SEVILLA ROSALEDA' THEN RETURN 'SEVILLA';
    WHEN 'SEVILLA CASTILLEJA' THEN RETURN 'SEVILLA';
    WHEN 'SEVILLA PARAISO' THEN RETURN 'SEVILLA';
    WHEN 'SEVILLA VARIOS' THEN RETURN 'SEVILLA';
    WHEN 'SEVILLA OFICINA' THEN RETURN 'SEVILLA';
    WHEN 'SEVILLA JAP NF+18' THEN RETURN 'SEVILLA';
    
    -- Murcia
    WHEN 'MURCIA EL VERDOLAY' THEN RETURN 'MURCIA';
    WHEN 'MURCIA HOGAR DE SAN ISIDRO' THEN RETURN 'MURCIA';
    WHEN 'MURCIA HOGAR DE SAN BASILIO' THEN RETURN 'MURCIA';
    WHEN 'MURCIA OFICINA' THEN RETURN 'MURCIA';
    
    -- Burgos
    WHEN 'BURGOS CERVANTES' THEN RETURN 'BURGOS';
    WHEN 'BURGOS CORTES' THEN RETURN 'BURGOS';
    WHEN 'BURGOS ARANDA' THEN RETURN 'BURGOS';
    WHEN 'BURGOS OFICINA' THEN RETURN 'BURGOS';
    
    -- La Línea
    WHEN 'LA LINEA CAI / CARMEN HERRERO' THEN RETURN 'LA LINEA';
    WHEN 'LA LINEA ESPIGON' THEN RETURN 'LA LINEA';
    WHEN 'LA LINEA MATILDE GALVEZ' THEN RETURN 'LA LINEA';
    WHEN 'LA LINEA GIBRALTAR' THEN RETURN 'LA LINEA';
    WHEN 'LA LINEA EL ROSARIO' THEN RETURN 'LA LINEA';
    WHEN 'LA LINEA PUNTO DE ENCUENTRO' THEN RETURN 'LA LINEA';
    WHEN 'LA LINEA SOROLLA' THEN RETURN 'LA LINEA';
    
    -- Cádiz
    WHEN 'CADIZ CARLOS HAYA' THEN RETURN 'CADIZ';
    WHEN 'CADIZ TRILLE' THEN RETURN 'CADIZ';
    WHEN 'CADIZ GRANJA' THEN RETURN 'CADIZ';
    WHEN 'CADIZ OFICINA' THEN RETURN 'CADIZ';
    WHEN 'CADIZ ESQUIVEL' THEN RETURN 'CADIZ';
    
    -- Alicante
    WHEN 'ALICANTE EL PINO' THEN RETURN 'ALICANTE';
    WHEN 'ALICANTE EMANCIPACION LOS NARANJOS' THEN RETURN 'ALICANTE';
    WHEN 'ALICANTE EMANCIPACION BENACANTIL' THEN RETURN 'ALICANTE';
    WHEN 'ALICANTE EL POSTIGUET' THEN RETURN 'ALICANTE';
    
    -- Palencia
    WHEN 'PALENCIA' THEN RETURN 'PALENCIA';
    
    -- Córdoba
    WHEN 'CORDOBA CASA HOGAR POLIFEMO' THEN RETURN 'CORDOBA';
    
    -- Otros
    WHEN 'PROFESIONALES' THEN RETURN 'PROFESIONALES';
    WHEN 'VALLADOLID MIRLO' THEN RETURN 'VALLADOLID';
    
    ELSE RETURN NULL;
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create trigger function to automatically set delegation based on work centers
CREATE OR REPLACE FUNCTION set_delegation_from_work_centers()
RETURNS TRIGGER AS $$
BEGIN
  -- Get the delegation from the first work center
  IF array_length(NEW.work_centers, 1) > 0 THEN
    NEW.delegation := get_work_center_delegation(NEW.work_centers[1]);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set delegation
DROP TRIGGER IF EXISTS set_delegation_trigger ON employee_profiles;
CREATE TRIGGER set_delegation_trigger
  BEFORE INSERT OR UPDATE OF work_centers ON employee_profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_delegation_from_work_centers();

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_employee_profiles_delegation 
ON employee_profiles(delegation);