-- Drop existing policies if they exist
DROP POLICY IF EXISTS "supervisor_base_access" ON supervisor_profiles;
DROP POLICY IF EXISTS "supervisor_employee_access" ON employee_profiles;
DROP POLICY IF EXISTS "supervisor_time_entries_access" ON time_entries;
DROP POLICY IF EXISTS "supervisor_time_requests_access" ON time_requests;
DROP POLICY IF EXISTS "supervisor_vacation_requests_access" ON vacation_requests;
DROP POLICY IF EXISTS "supervisor_absence_requests_access" ON absence_requests;
DROP POLICY IF EXISTS "supervisor_calendar_events_access" ON calendar_events;
DROP POLICY IF EXISTS "supervisor_holidays_access" ON holidays;

-- Create comprehensive policies for supervisor access
CREATE POLICY "supervisor_base_access"
  ON supervisor_profiles
  FOR ALL
  TO authenticated
  USING (
    id = auth.uid() OR 
    company_id = auth.uid()
  )
  WITH CHECK (company_id = auth.uid());

-- Policy for supervisors to view employee data
CREATE POLICY "supervisor_employee_access"
  ON employee_profiles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      WHERE sp.id = auth.uid()
      AND sp.company_id = employee_profiles.company_id
      AND sp.is_active = true
      AND (
        (sp.supervisor_type = 'center' AND employee_profiles.work_centers && sp.work_centers) OR
        (sp.supervisor_type = 'delegation' AND employee_profiles.delegation = ANY(sp.delegations))
      )
    )
  );

-- Policy for supervisors to view time entries
CREATE POLICY "supervisor_time_entries_access"
  ON time_entries
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      JOIN employee_profiles ep ON ep.id = time_entries.employee_id
      WHERE sp.id = auth.uid()
      AND sp.company_id = ep.company_id
      AND sp.is_active = true
      AND (
        (sp.supervisor_type = 'center' AND ep.work_centers && sp.work_centers) OR
        (sp.supervisor_type = 'delegation' AND ep.delegation = ANY(sp.delegations))
      )
    )
  );

-- Policy for supervisors to view time requests
CREATE POLICY "supervisor_time_requests_access"
  ON time_requests
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      JOIN employee_profiles ep ON ep.id = time_requests.employee_id
      WHERE sp.id = auth.uid()
      AND sp.company_id = ep.company_id
      AND sp.is_active = true
      AND (
        (sp.supervisor_type = 'center' AND ep.work_centers && sp.work_centers) OR
        (sp.supervisor_type = 'delegation' AND ep.delegation = ANY(sp.delegations))
      )
    )
  );

-- Policy for supervisors to view vacation requests
CREATE POLICY "supervisor_vacation_requests_access"
  ON vacation_requests
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      JOIN employee_profiles ep ON ep.id = vacation_requests.employee_id
      WHERE sp.id = auth.uid()
      AND sp.company_id = ep.company_id
      AND sp.is_active = true
      AND (
        (sp.supervisor_type = 'center' AND ep.work_centers && sp.work_centers) OR
        (sp.supervisor_type = 'delegation' AND ep.delegation = ANY(sp.delegations))
      )
    )
  );

-- Policy for supervisors to view absence requests
CREATE POLICY "supervisor_absence_requests_access"
  ON absence_requests
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      JOIN employee_profiles ep ON ep.id = absence_requests.employee_id
      WHERE sp.id = auth.uid()
      AND sp.company_id = ep.company_id
      AND sp.is_active = true
      AND (
        (sp.supervisor_type = 'center' AND ep.work_centers && sp.work_centers) OR
        (sp.supervisor_type = 'delegation' AND ep.delegation = ANY(sp.delegations))
      )
    )
  );

-- Policy for supervisors to view calendar events
CREATE POLICY "supervisor_calendar_events_access"
  ON calendar_events
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      JOIN employee_profiles ep ON ep.id = calendar_events.employee_id
      WHERE sp.id = auth.uid()
      AND sp.company_id = ep.company_id
      AND sp.is_active = true
      AND (
        (sp.supervisor_type = 'center' AND ep.work_centers && sp.work_centers) OR
        (sp.supervisor_type = 'delegation' AND ep.delegation = ANY(sp.delegations))
      )
    )
  );

-- Policy for supervisors to view holidays
CREATE POLICY "supervisor_holidays_access"
  ON holidays
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM supervisor_profiles sp
      WHERE sp.id = auth.uid()
      AND sp.is_active = true
    )
  );

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_supervisor_profiles_type ON supervisor_profiles(supervisor_type);
CREATE INDEX IF NOT EXISTS idx_supervisor_profiles_company ON supervisor_profiles(company_id);
CREATE INDEX IF NOT EXISTS idx_supervisor_profiles_active ON supervisor_profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_delegation ON employee_profiles(delegation);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_work_centers ON employee_profiles USING gin(work_centers);