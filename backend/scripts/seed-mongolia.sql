PRAGMA foreign_keys = ON;

DELETE FROM payment_cargo;
DELETE FROM payment;
DELETE FROM cargo_status_event;
DELETE FROM cargo;
DELETE FROM branch;
DELETE FROM account;
DELETE FROM session;
DELETE FROM verification;
DELETE FROM user;

INSERT INTO branch (id, code, name, address, phone, is_active) VALUES
  ('branch_ulaanbaatar_central', 'UB-CENTRAL', 'Ulaanbaatar Central Hub', 'Sukhbaatar District, 1st Khoroo, Seoul Street 23', '+976-7000-1101', 1),
  ('branch_bayanzurkh', 'UB-BZK', 'Bayanzurkh Pickup Point', 'Bayanzurkh District, 26th Khoroo, National Park Road', '+976-7000-1102', 1),
  ('branch_khan_uul', 'UB-KHU', 'Khan-Uul Delivery Center', 'Khan-Uul District, 15th Khoroo, Chinggis Avenue 98', '+976-7000-1103', 1),
  ('branch_darkhan', 'DHN-01', 'Darkhan Cargo Desk', 'Darkhan-Uul, 5th Bag, Peace Avenue 11', '+976-7000-2101', 1),
  ('branch_erdenet', 'ERD-01', 'Erdenet Cargo Counter', 'Orkhon, Bayan-Undur, 8th Khoroo, Ikh Mongol Street 7', '+976-7000-3101', 1);

INSERT INTO user (id, name, email, email_verified, role, banned) VALUES
  ('user_admin_01', 'Admin Bat-Erdene', 'admin@cargo.mn', 1, 'admin', 0),
  ('user_china_staff_01', 'China Staff Lkhagva', 'china.staff@cargo.mn', 1, 'china_staff', 0),
  ('user_mn_staff_01', 'Mongolia Staff Nomin', 'mn.staff@cargo.mn', 1, 'mongolia_staff', 0),
  ('user_customer_01', 'Anuujin Tserendorj', 'anuujin@gmail.com', 1, 'customer', 0),
  ('user_customer_02', 'Batmunkh Ganbold', 'batmunkh@gmail.com', 1, 'customer', 0),
  ('user_customer_03', 'Enkhjin Purev', 'enkhjin@gmail.com', 1, 'customer', 0),
  ('user_customer_04', 'Munkhzaya Altangerel', 'munkhzaya@gmail.com', 1, 'customer', 0),
  ('user_customer_05', 'Temuulen Byambaa', 'temuulen@gmail.com', 1, 'customer', 0),
  ('user_customer_06', 'Saruul Erdene', 'saruul@gmail.com', 1, 'customer', 0);

INSERT INTO cargo (
  id, customer_id, branch_id, tracking_number, description, status, payment_status, fulfillment_type,
  weight_grams, base_shipping_fee_mnt, local_delivery_fee_mnt, total_fee_mnt,
  delivery_address, delivery_phone,
  received_in_china_at, departed_china_at, arrived_in_mongolia_at, fulfillment_selected_at, completed_at,
  created_at, updated_at
) VALUES
  (
    'cargo_001', 'user_customer_01', 'branch_ulaanbaatar_central', 'MN-CN-20260228-0001',
    'Women winter jacket, size M', 'COMPLETED_DELIVERY', 'PAID', 'HOME_DELIVERY',
    1800, 28500, 9000, 37500,
    'Khan-Uul District, 18th Khoroo, Zaisan Street 4-1203', '+976-99112233',
    cast((unixepoch('subsecond') - 86400 * 12) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 10) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 7) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 6.8) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 6) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 12.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 6) * 1000 as integer)
  ),
  (
    'cargo_002', 'user_customer_02', 'branch_bayanzurkh', 'MN-CN-20260301-0002',
    'Bluetooth earphones and phone case', 'READY_FOR_PICKUP', 'UNPAID', 'PICKUP',
    650, 16500, 0, 16500,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 11) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 9) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 5) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 4.8) * 1000 as integer),
    NULL,
    cast((unixepoch('subsecond') - 86400 * 11.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 4.8) * 1000 as integer)
  ),
  (
    'cargo_003', 'user_customer_03', 'branch_khan_uul', 'MN-CN-20260301-0003',
    'Kitchen mixer, 220V compatible', 'OUT_FOR_DELIVERY', 'PAID', 'HOME_DELIVERY',
    3200, 46000, 12000, 58000,
    'Bayangol District, 3rd Khoroo, Ard Ayush Avenue 27-54', '+976-88118811',
    cast((unixepoch('subsecond') - 86400 * 9.5) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 7.5) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 2.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 2.1) * 1000 as integer),
    NULL,
    cast((unixepoch('subsecond') - 86400 * 9.6) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 0.4) * 1000 as integer)
  ),
  (
    'cargo_004', 'user_customer_04', 'branch_darkhan', 'MN-CN-20260302-0004',
    'Kids sneakers, size 32', 'AWAITING_FULFILLMENT_CHOICE', 'UNPAID', NULL,
    900, 19500, 0, 19500,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 8) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 6.5) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 1.5) * 1000 as integer),
    NULL,
    NULL,
    cast((unixepoch('subsecond') - 86400 * 8.1) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 1.5) * 1000 as integer)
  ),
  (
    'cargo_005', 'user_customer_05', 'branch_erdenet', 'MN-CN-20260302-0005',
    'Office chair gas lift and wheel set', 'IN_TRANSIT_TO_MN', 'UNPAID', NULL,
    4200, 53000, 0, 53000,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 5.5) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 2.5) * 1000 as integer),
    NULL,
    NULL,
    NULL,
    cast((unixepoch('subsecond') - 86400 * 5.6) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 2.5) * 1000 as integer)
  ),
  (
    'cargo_006', 'user_customer_01', 'branch_ulaanbaatar_central', 'MN-CN-20260303-0006',
    'Car phone holder and USB charger', 'RECEIVED_CHINA', 'UNPAID', NULL,
    350, 12000, 0, 12000,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 1.8) * 1000 as integer),
    NULL,
    NULL,
    NULL,
    NULL,
    cast((unixepoch('subsecond') - 86400 * 1.9) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 1.8) * 1000 as integer)
  ),
  (
    'cargo_007', 'user_customer_06', 'branch_bayanzurkh', 'MN-CN-20260303-0007',
    'Hair dryer with diffuser', 'CREATED', 'UNPAID', NULL,
    0, 0, 0, 0,
    NULL, NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    cast((unixepoch('subsecond') - 86400 * 0.5) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 0.5) * 1000 as integer)
  ),
  (
    'cargo_008', 'user_customer_02', 'branch_khan_uul', 'MN-CN-20260303-0008',
    'Gaming mousepad XL', 'COMPLETED_PICKUP', 'PAID', 'PICKUP',
    780, 15500, 0, 15500,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 14) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 12) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 9) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 8.7) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 8.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 14.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 8.2) * 1000 as integer)
  ),
  (
    'cargo_009', 'user_customer_03', 'branch_ulaanbaatar_central', 'MN-CN-20260304-0009',
    'Stainless thermos bottle 1L', 'ARRIVED_MN', 'UNPAID', NULL,
    540, 14500, 0, 14500,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 4) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 0.6) * 1000 as integer),
    NULL,
    NULL,
    cast((unixepoch('subsecond') - 86400 * 4.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 0.6) * 1000 as integer)
  ),
  (
    'cargo_010', 'user_customer_04', 'branch_darkhan', 'MN-CN-20260304-0010',
    'Baby stroller rain cover', 'IN_TRANSIT_TO_MN', 'UNPAID', NULL,
    860, 17500, 0, 17500,
    NULL, NULL,
    cast((unixepoch('subsecond') - 86400 * 3.2) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 1.2) * 1000 as integer),
    NULL,
    NULL,
    NULL,
    cast((unixepoch('subsecond') - 86400 * 3.3) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 1.2) * 1000 as integer)
  );

INSERT INTO cargo_status_event (id, cargo_id, from_status, to_status, note, changed_by_user_id, created_at) VALUES
  ('event_001', 'cargo_001', NULL, 'CREATED', 'Order declared by customer via app', 'user_customer_01', cast((unixepoch('subsecond') - 86400 * 12.2) * 1000 as integer)),
  ('event_002', 'cargo_001', 'CREATED', 'RECEIVED_CHINA', 'Warehouse check-in at Guangzhou warehouse', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 12) * 1000 as integer)),
  ('event_003', 'cargo_001', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Loaded to weekly truck batch GZ-UB-47', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 10) * 1000 as integer)),
  ('event_004', 'cargo_001', 'IN_TRANSIT_TO_MN', 'ARRIVED_MN', 'Arrived at UB sorting center', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 7) * 1000 as integer)),
  ('event_005', 'cargo_001', 'ARRIVED_MN', 'OUT_FOR_DELIVERY', 'Customer selected home delivery', 'user_customer_01', cast((unixepoch('subsecond') - 86400 * 6.8) * 1000 as integer)),
  ('event_006', 'cargo_001', 'OUT_FOR_DELIVERY', 'COMPLETED_DELIVERY', 'Delivered to customer, signed by receiver', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 6) * 1000 as integer)),

  ('event_007', 'cargo_002', NULL, 'CREATED', 'Tracking registered from Taobao order', 'user_customer_02', cast((unixepoch('subsecond') - 86400 * 11.2) * 1000 as integer)),
  ('event_008', 'cargo_002', 'CREATED', 'RECEIVED_CHINA', 'Package weighed and relabeled in Shenzhen', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 11) * 1000 as integer)),
  ('event_009', 'cargo_002', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Departed from Erenhot border route', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 9) * 1000 as integer)),
  ('event_010', 'cargo_002', 'IN_TRANSIT_TO_MN', 'ARRIVED_MN', 'Arrived in UB and customs cleared', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 5) * 1000 as integer)),
  ('event_011', 'cargo_002', 'ARRIVED_MN', 'READY_FOR_PICKUP', 'Customer selected Bayanzurkh pickup', 'user_customer_02', cast((unixepoch('subsecond') - 86400 * 4.8) * 1000 as integer)),

  ('event_012', 'cargo_003', NULL, 'CREATED', 'Customer pre-alerted shipment', 'user_customer_03', cast((unixepoch('subsecond') - 86400 * 9.6) * 1000 as integer)),
  ('event_013', 'cargo_003', 'CREATED', 'RECEIVED_CHINA', 'Inbound scanned at warehouse shelf C-12', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 9.5) * 1000 as integer)),
  ('event_014', 'cargo_003', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Dispatched with mixed goods route', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 7.5) * 1000 as integer)),
  ('event_015', 'cargo_003', 'IN_TRANSIT_TO_MN', 'ARRIVED_MN', 'Arrived UB, pending customer choice', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 2.2) * 1000 as integer)),
  ('event_016', 'cargo_003', 'ARRIVED_MN', 'OUT_FOR_DELIVERY', 'Customer requested same-day delivery', 'user_customer_03', cast((unixepoch('subsecond') - 86400 * 2.1) * 1000 as integer)),

  ('event_017', 'cargo_004', NULL, 'CREATED', 'Declared from 1688 order', 'user_customer_04', cast((unixepoch('subsecond') - 86400 * 8.1) * 1000 as integer)),
  ('event_018', 'cargo_004', 'CREATED', 'RECEIVED_CHINA', 'China warehouse received parcel', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 8) * 1000 as integer)),
  ('event_019', 'cargo_004', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Cross-border handoff complete', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 6.5) * 1000 as integer)),
  ('event_020', 'cargo_004', 'IN_TRANSIT_TO_MN', 'ARRIVED_MN', 'Arrived Darkhan route transfer', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 1.5) * 1000 as integer)),
  ('event_021', 'cargo_004', 'ARRIVED_MN', 'AWAITING_FULFILLMENT_CHOICE', 'Waiting customer delivery preference', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 1.5) * 1000 as integer)),

  ('event_022', 'cargo_005', NULL, 'CREATED', 'Customer entered tracking manually', 'user_customer_05', cast((unixepoch('subsecond') - 86400 * 5.6) * 1000 as integer)),
  ('event_023', 'cargo_005', 'CREATED', 'RECEIVED_CHINA', 'Item received and consolidated', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 5.5) * 1000 as integer)),
  ('event_024', 'cargo_005', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Freight moved to Mongolia lane', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 2.5) * 1000 as integer)),

  ('event_025', 'cargo_006', NULL, 'CREATED', 'Customer created shipment', 'user_customer_01', cast((unixepoch('subsecond') - 86400 * 1.9) * 1000 as integer)),
  ('event_026', 'cargo_006', 'CREATED', 'RECEIVED_CHINA', 'Received in warehouse and photographed', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 1.8) * 1000 as integer)),

  ('event_027', 'cargo_007', NULL, 'CREATED', 'Pending physical arrival in China warehouse', 'user_customer_06', cast((unixepoch('subsecond') - 86400 * 0.5) * 1000 as integer)),

  ('event_028', 'cargo_008', NULL, 'CREATED', 'Declared by customer', 'user_customer_02', cast((unixepoch('subsecond') - 86400 * 14.2) * 1000 as integer)),
  ('event_029', 'cargo_008', 'CREATED', 'RECEIVED_CHINA', 'Received and packed', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 14) * 1000 as integer)),
  ('event_030', 'cargo_008', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Departed by ground shipment', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 12) * 1000 as integer)),
  ('event_031', 'cargo_008', 'IN_TRANSIT_TO_MN', 'ARRIVED_MN', 'Arrived UB central terminal', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 9) * 1000 as integer)),
  ('event_032', 'cargo_008', 'ARRIVED_MN', 'READY_FOR_PICKUP', 'Pickup selected by customer', 'user_customer_02', cast((unixepoch('subsecond') - 86400 * 8.7) * 1000 as integer)),
  ('event_033', 'cargo_008', 'READY_FOR_PICKUP', 'COMPLETED_PICKUP', 'Picked up with OTP confirmation', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 8.2) * 1000 as integer)),

  ('event_034', 'cargo_009', NULL, 'CREATED', 'Customer submitted tracking from Pinduoduo', 'user_customer_03', cast((unixepoch('subsecond') - 86400 * 4.2) * 1000 as integer)),
  ('event_035', 'cargo_009', 'CREATED', 'RECEIVED_CHINA', 'Received at warehouse rack A-07', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 4) * 1000 as integer)),
  ('event_036', 'cargo_009', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Shipped via Erenhot batch', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 2) * 1000 as integer)),
  ('event_037', 'cargo_009', 'IN_TRANSIT_TO_MN', 'ARRIVED_MN', 'Arrived at UB central sorting', 'user_mn_staff_01', cast((unixepoch('subsecond') - 86400 * 0.6) * 1000 as integer)),

  ('event_038', 'cargo_010', NULL, 'CREATED', 'Customer pre-alert created', 'user_customer_04', cast((unixepoch('subsecond') - 86400 * 3.3) * 1000 as integer)),
  ('event_039', 'cargo_010', 'CREATED', 'RECEIVED_CHINA', 'Inbound checked and weighed', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 3.2) * 1000 as integer)),
  ('event_040', 'cargo_010', 'RECEIVED_CHINA', 'IN_TRANSIT_TO_MN', 'Departed from consolidation hub', 'user_china_staff_01', cast((unixepoch('subsecond') - 86400 * 1.2) * 1000 as integer));

INSERT INTO payment (
  id, customer_id, status, method, provider, provider_payment_id,
  total_amount_mnt, currency, paid_at, note, created_at, updated_at
) VALUES
  (
    'payment_001', 'user_customer_01', 'PAID', 'APP', 'QPAY', 'QPAY-202603-0001',
    37500, 'MNT', cast((unixepoch('subsecond') - 86400 * 6.9) * 1000 as integer),
    'Paid via QPay QR during delivery confirmation',
    cast((unixepoch('subsecond') - 86400 * 6.9) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 6.9) * 1000 as integer)
  ),
  (
    'payment_002', 'user_customer_02', 'PENDING', 'CASH_IN_PERSON', NULL, NULL,
    16500, 'MNT', NULL,
    'Customer will pay at Bayanzurkh branch counter',
    cast((unixepoch('subsecond') - 86400 * 4.7) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 4.7) * 1000 as integer)
  ),
  (
    'payment_003', 'user_customer_03', 'PAID', 'APP', 'SOCIALPAY', 'SP-889120',
    58000, 'MNT', cast((unixepoch('subsecond') - 86400 * 2.0) * 1000 as integer),
    'Instant app payment to release delivery route',
    cast((unixepoch('subsecond') - 86400 * 2.0) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 2.0) * 1000 as integer)
  ),
  (
    'payment_004', 'user_customer_02', 'PAID', 'APP', 'QPAY', 'QPAY-202602-9844',
    15500, 'MNT', cast((unixepoch('subsecond') - 86400 * 8.8) * 1000 as integer),
    'Paid before pickup request was completed',
    cast((unixepoch('subsecond') - 86400 * 8.8) * 1000 as integer),
    cast((unixepoch('subsecond') - 86400 * 8.8) * 1000 as integer)
  );

INSERT INTO payment_cargo (id, payment_id, cargo_id, amount_mnt, created_at) VALUES
  ('payment_cargo_001', 'payment_001', 'cargo_001', 37500, cast((unixepoch('subsecond') - 86400 * 6.9) * 1000 as integer)),
  ('payment_cargo_002', 'payment_002', 'cargo_002', 16500, cast((unixepoch('subsecond') - 86400 * 4.7) * 1000 as integer)),
  ('payment_cargo_003', 'payment_003', 'cargo_003', 58000, cast((unixepoch('subsecond') - 86400 * 2.0) * 1000 as integer)),
  ('payment_cargo_004', 'payment_004', 'cargo_008', 15500, cast((unixepoch('subsecond') - 86400 * 8.8) * 1000 as integer));
