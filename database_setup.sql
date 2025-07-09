-- Database Setup Script for RFID Manager
-- Run this in your Supabase SQL Editor

-- First, temporarily disable RLS to insert test data
ALTER TABLE warehouses DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE readers DISABLE ROW LEVEL SECURITY;
ALTER TABLE tags DISABLE ROW LEVEL SECURITY;
ALTER TABLE scans DISABLE ROW LEVEL SECURITY;
ALTER TABLE settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE reader_user_assignments DISABLE ROW LEVEL SECURITY;

-- Insert test warehouse
INSERT INTO warehouses (id, name, location, created_at, updated_at) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'Main Warehouse', 'Building A, Floor 1', NOW(), NOW());

-- Insert admin user (this should match your demo login)
INSERT INTO users (id, name, username, email, password, role, warehouse_id, status, created_at, updated_at) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'Admin User', 'admin', 'admin@rfidmanager.com', '$2a$10$8K1p/a0dKeCWGYusgOidOU5AklVxEW3fN2UWOIiKHTpNkxAjF8yJa', 'admin', '550e8400-e29b-41d4-a716-446655440001', 'active', NOW(), NOW());

-- Update warehouse manager
UPDATE warehouses SET manager_user_id = '550e8400-e29b-41d4-a716-446655440000' WHERE id = '550e8400-e29b-41d4-a716-446655440001';

-- Insert test readers
INSERT INTO readers (id, serial_number, model, location, warehouse_id, status, last_seen, created_at, updated_at) VALUES 
('550e8400-e29b-41d4-a716-446655440002', 'RDR-001', 'UHF Reader Pro', 'Main Entrance', '550e8400-e29b-41d4-a716-446655440001', 'active', NOW() - INTERVAL '5 minutes', NOW() - INTERVAL '30 days', NOW()),
('550e8400-e29b-41d4-a716-446655440003', 'RDR-002', 'UHF Reader Pro', 'Warehouse Gate', '550e8400-e29b-41d4-a716-446655440001', 'active', NOW() - INTERVAL '2 minutes', NOW() - INTERVAL '25 days', NOW()),
('550e8400-e29b-41d4-a716-446655440004', 'RDR-003', 'UHF Reader Lite', 'Office Door', '550e8400-e29b-41d4-a716-446655440001', 'active', NOW() - INTERVAL '8 minutes', NOW() - INTERVAL '20 days', NOW()),
('550e8400-e29b-41d4-a716-446655440005', 'RDR-004', 'UHF Reader Pro', 'Loading Dock', '550e8400-e29b-41d4-a716-446655440001', 'active', NOW() - INTERVAL '1 minute', NOW() - INTERVAL '15 days', NOW()),
('550e8400-e29b-41d4-a716-446655440006', 'RDR-005', 'UHF Reader Lite', 'Storage Room', '550e8400-e29b-41d4-a716-446655440001', 'maintenance', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '10 days', NOW());

-- Insert test tags
INSERT INTO tags (id, tag_uid, owner_name, description, status, created_at, updated_at) VALUES 
('550e8400-e29b-41d4-a716-446655440007', 'TAG-001-ABC123', 'Office Equipment', 'Laptop Dell XPS 13', 'active', NOW() - INTERVAL '30 days', NOW()),
('550e8400-e29b-41d4-a716-446655440008', 'TAG-002-DEF456', 'Inventory Item', 'Office Chair Ergonomic', 'active', NOW() - INTERVAL '25 days', NOW()),
('550e8400-e29b-41d4-a716-446655440009', 'TAG-003-GHI789', 'Medical Equipment', 'Blood Pressure Monitor', 'active', NOW() - INTERVAL '20 days', NOW()),
('550e8400-e29b-41d4-a716-446655440010', 'TAG-004-JKL012', 'Vehicle Fleet', 'Company Car Honda Civic', 'active', NOW() - INTERVAL '15 days', NOW()),
('550e8400-e29b-41d4-a716-446655440011', 'TAG-005-MNO345', 'Tools', 'Power Drill Professional', 'damaged', NOW() - INTERVAL '10 days', NOW()),
('550e8400-e29b-41d4-a716-446655440012', 'TAG-006-PQR678', 'Security Equipment', 'CCTV Camera Wireless', 'active', NOW() - INTERVAL '8 days', NOW()),
('550e8400-e29b-41d4-a716-446655440013', 'TAG-007-STU901', 'Manufacturing', 'Industrial Robot Arm', 'active', NOW() - INTERVAL '5 days', NOW()),
('550e8400-e29b-41d4-a716-446655440014', 'TAG-008-VWX234', 'Lab Equipment', 'Microscope Digital', 'active', NOW() - INTERVAL '3 days', NOW());

-- Insert test scans
INSERT INTO scans (id, tag_id, reader_id, user_id, timestamp, warehouse_id, area, scan_type, confidence_score, created_at) VALUES 
('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', NOW() - INTERVAL '30 minutes', '550e8400-e29b-41d4-a716-446655440001', 'Main Entrance', 'entry', 95, NOW() - INTERVAL '30 minutes'),
('550e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', NOW() - INTERVAL '1 hour', '550e8400-e29b-41d4-a716-446655440001', 'Warehouse Gate', 'inventory', 98, NOW() - INTERVAL '1 hour'),
('550e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', NOW() - INTERVAL '2 hours', '550e8400-e29b-41d4-a716-446655440001', 'Main Entrance', 'exit', 92, NOW() - INTERVAL '2 hours'),
('550e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', NOW() - INTERVAL '3 hours', '550e8400-e29b-41d4-a716-446655440001', 'Office Door', 'entry', 88, NOW() - INTERVAL '3 hours'),
('550e8400-e29b-41d4-a716-446655440019', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440000', NOW() - INTERVAL '4 hours', '550e8400-e29b-41d4-a716-446655440001', 'Loading Dock', 'inventory', 96, NOW() - INTERVAL '4 hours');

-- Create reader assignments
INSERT INTO reader_user_assignments (id, user_id, reader_id, is_primary, created_at, updated_at) VALUES 
('550e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', true, NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440003', true, NOW(), NOW());

-- Insert some settings
INSERT INTO settings (id, setting_key, setting_value, scope, description, created_at, updated_at) VALUES 
('550e8400-e29b-41d4-a716-446655440022', 'scan_timeout', '30', 'global', 'Default scan timeout in seconds', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440023', 'auto_refresh', 'true', 'global', 'Enable automatic data refresh', NOW(), NOW());

-- Re-enable RLS after inserting test data
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE readers ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reader_user_assignments ENABLE ROW LEVEL SECURITY;

-- For testing purposes, you may want to temporarily make the policies more permissive
-- or create policies that allow anonymous access for testing

-- Alternative: Create more permissive policies for testing
-- DROP POLICY IF EXISTS "Allow anonymous read access for testing" ON readers;
-- CREATE POLICY "Allow anonymous read access for testing" ON readers
--     FOR SELECT TO anon
--     USING (true);

-- You can add similar policies for other tables during development

-- Verify the data
SELECT 'Warehouses' as table_name, count(*) as count FROM warehouses
UNION ALL
SELECT 'Users' as table_name, count(*) as count FROM users
UNION ALL
SELECT 'Readers' as table_name, count(*) as count FROM readers
UNION ALL
SELECT 'Tags' as table_name, count(*) as count FROM tags
UNION ALL
SELECT 'Scans' as table_name, count(*) as count FROM scans; 