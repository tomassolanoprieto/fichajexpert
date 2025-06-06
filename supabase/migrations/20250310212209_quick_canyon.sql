/*
  # Fix get_filtered_requests Function

  1. Changes
    - Drop existing function to allow return type change
    - Recreate function with updated parameters and return type
    - Add proper type casting for delegation parameter
    - Improve error handling and type safety

  2. Security
    - Maintain SECURITY DEFINER setting
    - Preserve existing access controls
*/

-- First drop the existing function
DROP FUNCTION IF EXISTS get_filtered_requests(uuid, text, text, timestamp with time zone, timestamp with time zone);

-- Recreate the function with updated signature and implementation
CREATE OR REPLACE FUNCTION get_filtered_requests(
  p_company_id uuid DEFAULT NULL,
  p_work_center text DEFAULT NULL,
  p_delegation text DEFAULT NULL,
  p_start_date timestamp with time zone DEFAULT NULL,
  p_end_date timestamp with time zone DEFAULT NULL
)
RETURNS TABLE (
  request_id uuid,
  request_type text,
  request_status text,
  created_at timestamp with time zone,
  employee_id uuid,
  employee_name text,
  employee_email text,
  work_centers text[],
  delegation delegation_enum,
  details jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_delegation delegation_enum;
BEGIN
  -- Try to cast delegation to enum type if provided
  IF p_delegation IS NOT NULL THEN
    BEGIN
      v_delegation := p_delegation::delegation_enum;
    EXCEPTION WHEN OTHERS THEN
      RAISE EXCEPTION 'Invalid delegation value: %', p_delegation;
    END;
  END IF;

  RETURN QUERY
  -- Time requests
  SELECT 
    tr.id as request_id,
    'time'::text as request_type,
    tr.status as request_status,
    tr.created_at,
    tr.employee_id,
    ep.fiscal_name as employee_name,
    ep.email as employee_email,
    ep.work_centers,
    ep.delegation,
    jsonb_build_object(
      'datetime', tr.datetime,
      'entry_type', tr.entry_type,
      'comment', tr.comment
    ) as details
  FROM time_requests tr
  JOIN employee_profiles ep ON tr.employee_id = ep.id
  WHERE (p_company_id IS NULL OR ep.company_id = p_company_id)
    AND (p_work_center IS NULL OR ep.work_centers @> ARRAY[p_work_center])
    AND (p_delegation IS NULL OR ep.delegation = v_delegation)
    AND (p_start_date IS NULL OR tr.created_at >= p_start_date)
    AND (p_end_date IS NULL OR tr.created_at <= p_end_date)

  UNION ALL

  -- Planner requests
  SELECT 
    pr.id as request_id,
    'planner'::text as request_type,
    pr.status as request_status,
    pr.created_at,
    pr.employee_id,
    ep.fiscal_name as employee_name,
    ep.email as employee_email,
    ep.work_centers,
    ep.delegation,
    jsonb_build_object(
      'planner_type', pr.planner_type,
      'start_date', pr.start_date,
      'end_date', pr.end_date,
      'comment', pr.comment
    ) as details
  FROM planner_requests pr
  JOIN employee_profiles ep ON pr.employee_id = ep.id
  WHERE (p_company_id IS NULL OR ep.company_id = p_company_id)
    AND (p_work_center IS NULL OR ep.work_centers @> ARRAY[p_work_center])
    AND (p_delegation IS NULL OR ep.delegation = v_delegation)
    AND (p_start_date IS NULL OR pr.created_at >= p_start_date)
    AND (p_end_date IS NULL OR pr.created_at <= p_end_date)
  ORDER BY created_at DESC;
END;
$$;