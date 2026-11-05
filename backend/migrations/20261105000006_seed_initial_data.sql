-- Migration: 000006_seed_initial_data

-- Seed Users
INSERT INTO users (id, phone, name, avatar_url, role, preferred_language)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', '+919876543210', 'Aarav Sharma', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=256&q=80', 'VOLUNTEER', 'en'),
    ('a0000000-0000-0000-0000-000000000002', '+919876543211', 'Dr. Rohan Verma', 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=256&q=80', 'VET', 'en'),
    ('a0000000-0000-0000-0000-000000000003', '+919876543212', 'Priya Patel', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80', 'REPORTER', 'en')
ON CONFLICT (id) DO NOTHING;

-- Seed Volunteer Profiles
INSERT INTO user_volunteer_profiles (user_id, is_available, verification_status, vehicle_type, capabilities, response_radius_km, last_known_location, rescues_completed_count, badge_label)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', TRUE, 'VERIFIED', 'TWO_WHEELER', ARRAY['FIRST_AID', 'TRANSPORT', 'PHYSICAL_AID'], 5, ST_SetSRID(ST_MakePoint(77.6408, 12.9784), 4326), 23, 'Verified First Responder'),
    ('a0000000-0000-0000-0000-000000000002', TRUE, 'VERIFIED', 'TWO_WHEELER', ARRAY['FIRST_AID', 'VET_CARE', 'TRANSPORT'], 8, ST_SetSRID(ST_MakePoint(77.6350, 12.9750), 4326), 48, 'Blue Cross Volunteer Partner')
ON CONFLICT (user_id) DO NOTHING;

-- Seed Notification Preferences
INSERT INTO user_notification_preferences (user_id, emergency_alerts, response_updates, community_updates, radius_km)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', TRUE, TRUE, TRUE, 5),
    ('a0000000-0000-0000-0000-000000000002', TRUE, TRUE, TRUE, 10),
    ('a0000000-0000-0000-0000-000000000003', TRUE, TRUE, TRUE, 3)
ON CONFLICT (user_id) DO NOTHING;

-- Seed Organizations & Trauma Centers (Bengaluru)
INSERT INTO organizations (id, name, org_type, description, address, location, phone, emergency_phone, website, operating_hours, is_24_7, is_verified, facilities)
VALUES 
    ('b0000000-0000-0000-0000-000000000001', 'CUPA Second Chance Sanctuary & Trauma Centre', 'VET_HOSPITAL', 'Dedicated 24/7 veterinary trauma center equipped with veterinary ambulance, full surgical theater and critical ICU care for street animals.', '100 Feet Rd, HAL 2nd Stage, Indiranagar, Bengaluru, Karnataka 560038', ST_SetSRID(ST_MakePoint(77.6412, 12.9716), 4326), '+918022947307', '+918022947307', 'https://cupaindia.org', 'Open 24 Hours / 7 Days', TRUE, TRUE, ARRAY['AMBULANCE', 'ICU', 'SURGERY', 'OPD']),
    ('b0000000-0000-0000-0000-000000000002', 'CARE — Charlie''s Animal Rescue Centre', 'NGO', 'Premier trauma and medical rehabilitation center catering to abandoned, injured and special-needs animals.', 'Survey No. 124, Mitteganahalli Cross, Kogilu Main Rd, Yelahanka, Bengaluru 560064', ST_SetSRID(ST_MakePoint(77.6189, 13.0982), 4326), '+919483916052', '+919483916052', 'https://charlies-care.com', '9:00 AM – 5:30 PM (Emergency Unit on Call)', FALSE, TRUE, ARRAY['AMBULANCE', 'SURGERY', 'BOARDING']),
    ('b0000000-0000-0000-0000-000000000003', 'People For Animals (PFA) Wildlife & Pet Hospital', 'NGO', 'Comprehensive rescue and medical treatment hospital with shelter facilities.', 'Survey No. 67, Uttarahalli Main Road, Kengeri, Bengaluru 560060', ST_SetSRID(ST_MakePoint(77.4892, 12.9067), 4326), '+919900025370', '+919900025370', 'https://pfabengaluru.org', 'Open 24/7 for Emergency Admittance', TRUE, TRUE, ARRAY['AMBULANCE', 'ICU', 'SURGERY', 'OPD']),
    ('b0000000-0000-0000-0000-000000000004', 'Sarvoham Animal Welfare Trust', 'SHELTER', 'Sanctuary offering lifetime care and rescue operations for paralyzed, blind, and old street dogs.', 'Kempapura, Bangalore, Karnataka 560037', ST_SetSRID(ST_MakePoint(77.6780, 12.9550), 4326), '+918073867664', '+918073867664', 'https://sarvoham.org', '9:00 AM – 6:00 PM', FALSE, TRUE, ARRAY['BOARDING', 'OPD'])
ON CONFLICT (id) DO NOTHING;

-- Seed SOS Case 1: Injured Indie Dog (Active Live SOS in Stitch Tracking screen)
INSERT INTO sos_requests (
    id, case_number, reporter_id, status, animal_type, emergency_type,
    location, accuracy_meters, address, landmark, description,
    primary_responder_id, expires_at, created_at, updated_at
)
VALUES (
    'c0000000-0000-0000-0000-000000000001',
    'SOS-BLR-8921',
    'a0000000-0000-0000-0000-000000000003',
    'HELP_ARRIVING',
    'DOG',
    'INJURED',
    ST_SetSRID(ST_MakePoint(77.6418, 12.9772), 4326),
    5.0,
    'Indiranagar 12th Main, Bengaluru',
    'Near Corner House Ice Cream, 100ft Rd Corner under tea stall',
    'Deep leg wound near 12th Main junction, resting calmly under tea stall next to pharmacy. Friendly temperament.',
    'a0000000-0000-0000-0000-000000000002',
    NOW() + INTERVAL '24 hours',
    NOW() - INTERVAL '15 minutes',
    NOW() - INTERVAL '2 minutes'
) ON CONFLICT (id) DO NOTHING;

-- Seed Media for Case 1
INSERT INTO sos_media (id, sos_id, media_type, url, thumbnail_url, caption, sort_order)
VALUES 
    ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'IMAGE', 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=200&q=80', 'Paw injury visible on front right leg', 0)
ON CONFLICT (id) DO NOTHING;

-- Seed Requirements for Case 1
INSERT INTO sos_requirements (id, sos_id, requirement_type)
VALUES 
    ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'FIRST_AID'),
    ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'TRANSPORTATION'),
    ('e0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'PHYSICAL_ASSISTANCE')
ON CONFLICT (id) DO NOTHING;

-- Seed Response for Case 1 (Dr. Rohan Verma)
INSERT INTO sos_responses (id, sos_id, responder_id, response_role, status, eta_minutes, equipment_notes, created_at)
VALUES (
    'f0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000002',
    'PRIMARY',
    'EN_ROUTE',
    6,
    'Contributing: Bringing first-aid kit & sterilized gauze, animal transport crate.',
    NOW() - INTERVAL '10 minutes'
) ON CONFLICT (id) DO NOTHING;

-- Seed Status History for Case 1
INSERT INTO sos_status_history (id, sos_id, previous_status, new_status, actor_id, reason, created_at)
VALUES 
    ('10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', NULL, 'OPEN', 'a0000000-0000-0000-0000-000000000003', 'Emergency alert filed with photo and pinpoint telemetry.', NOW() - INTERVAL '15 minutes'),
    ('10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'OPEN', 'RESPONDING', 'a0000000-0000-0000-0000-000000000002', 'Notified 18 certified volunteers within 3 km radius.', NOW() - INTERVAL '12 minutes'),
    ('10000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'RESPONDING', 'HELP_ARRIVING', 'a0000000-0000-0000-0000-000000000002', 'Responder en route on motorcycle. Estimated arrival 6 mins.', NOW() - INTERVAL '6 minutes')
ON CONFLICT (id) DO NOTHING;

-- Seed Location Sharing for Case 1 (Dr. Rohan current location 1.4km away)
INSERT INTO location_sharing_sessions (id, sos_id, responder_id, current_location, heading, speed_kmh, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000002',
    ST_SetSRID(ST_MakePoint(77.6320, 12.9730), 4326),
    45.0,
    28.5,
    TRUE
) ON CONFLICT (id) DO NOTHING;

-- Seed SOS Case 2: Trapped Kitten (Open Incident in Stitch Home screen)
INSERT INTO sos_requests (
    id, case_number, reporter_id, status, animal_type, emergency_type,
    location, accuracy_meters, address, landmark, description,
    expires_at, created_at, updated_at
)
VALUES (
    'c0000000-0000-0000-0000-000000000002',
    'SOS-BLR-8922',
    'a0000000-0000-0000-0000-000000000003',
    'OPEN',
    'CAT',
    'TRAPPED',
    ST_SetSRID(ST_MakePoint(77.6450, 12.9790), 4326),
    8.0,
    'CMH Road Metro Station, Indiranagar',
    'Storm drain grate near CMH Road metro station entrance gate 2',
    'Small 2-month-old kitten stuck down storm drain grate, meowing constantly. Need flashlight and small carrier.',
    NOW() + INTERVAL '24 hours',
    NOW() - INTERVAL '14 minutes',
    NOW() - INTERVAL '14 minutes'
) ON CONFLICT (id) DO NOTHING;

-- Seed Media for Case 2
INSERT INTO sos_media (id, sos_id, media_type, url, thumbnail_url, caption, sort_order)
VALUES 
    ('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'IMAGE', 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=200&q=80', 'Trapped kitten in drainage area', 0)
ON CONFLICT (id) DO NOTHING;

-- Seed Requirements for Case 2
INSERT INTO sos_requirements (id, sos_id, requirement_type)
VALUES 
    ('e0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', 'CARRIER'),
    ('e0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', 'PHYSICAL_ASSISTANCE')
ON CONFLICT (id) DO NOTHING;

