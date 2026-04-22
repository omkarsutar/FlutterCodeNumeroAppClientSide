-- Fix: Grant 'admin' role access to 'notification_admin' module

-- First, ensure the 'admin' role exists and get its ID
-- (You may need to adjust the role_id based on your actual data)

-- Insert permission for admin role to access notification_admin module
INSERT INTO rbac_permissions (
  role_id,
  module_id,
  can_read,
  can_create,
  can_update,
  can_delete
) VALUES (
  '8b047e14-1569-4eab-83a1-8dd43b960868', -- Replace with your actual admin role_id if different
  'notification_admin',
  true,
  false,
  false,
  false
) ON CONFLICT (role_id, module_id) DO UPDATE SET
  can_read = true,
  can_create = false,
  can_update = false,
  can_delete = false;

-- Verify the permission was added
SELECT * FROM rbac_permissions 
WHERE module_id = 'notification_admin' AND role_id = '8b047e14-1569-4eab-83a1-8dd43b960868';
