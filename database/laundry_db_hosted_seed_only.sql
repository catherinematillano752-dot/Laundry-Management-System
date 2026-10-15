-- Seed data only (tables already exist; the two payments triggers are skipped because Clever Cloud denies SUPER privilege).

-- ============================================================
-- SEED DATA (catalog only; no invented business rules)
-- ============================================================
INSERT INTO inventory_items (name, unit) VALUES
('Detergent', 'sachet'),
('Fabric Conditioner', 'sachet');

INSERT INTO machines (machine_type, label) VALUES
('Washer','Washer 1'),('Washer','Washer 2'),('Washer','Washer 3'),('Washer','Washer 4'),('Washer','Washer 5'),('Washer','Washer 6'),
('Dryer','Dryer 1'),('Dryer','Dryer 2'),('Dryer','Dryer 3'),('Dryer','Dryer 4'),('Dryer','Dryer 5'),('Dryer','Dryer 6');

-- price_per_load holds the rate PER KILO (the column name is kept from the old per-load pricing). Sample rates - set your own in Services.
-- The shop's three services. Supplies are listed per load below; the system multiplies them by the order's loads.
INSERT INTO services (name, service_type, includes_fold, price_per_load) VALUES
('Wash and Dry',              'Standard', FALSE, 45.00),
('Wash, Dry, and Fold',       'Standard', TRUE,  50.00),
('Wash, Dry, Fold, and Iron', 'Standard', TRUE,  55.00);

-- item_id 1 = Detergent, 2 = Fabric Conditioner. Dose PER LOAD (sample values - adjust to the shop's real dosing).
INSERT INTO service_consumables (service_id, item_id, qty) VALUES
(1, 1, 1), (1, 2, 1),   -- Wash and Dry
(2, 1, 1), (2, 2, 1),   -- Wash, Dry, and Fold
(3, 1, 1), (3, 2, 1);   -- Wash, Dry, Fold, and Iron

-- Garment types for the New Order checkboxes (Admin can change these; Heavy ones make the bag count at 6 kg per load).
INSERT INTO garment_types (name, category, sort_order) VALUES
('T-shirts & polos',      'Regular', 1),
('Shorts & light pants',  'Regular', 2),
('Dresses & blouses',     'Regular', 3),
('Underwear & socks',     'Regular', 4),
('Small towels',          'Regular', 5),
('Jeans',                 'Heavy',   6),
('Jackets & hoodies',     'Heavy',   7),
('Bed sheets & blankets', 'Heavy',   8),
('Curtains',              'Heavy',   9);

-- ============================================================
-- SAMPLE DATA (carried over from the old laundry_db.sql, adapted to this schema)
-- Login passwords are stored as bcrypt hashes of the old ones:
--   janessa (Admin) = admin123 | mark (Admin) = admin1234 | maria (Staff) = cashier01 | bernard (Staff) = cashier02
-- ============================================================
INSERT INTO users (full_name, username, password_hash, role) VALUES
('Janessa Reyes',  'janessa', '$2y$10$Xst07Vb4tMtONxih6xpAXeOyRjo5nrfQEwsY8VRj.Xg2z.Y3RNDUq', 'Admin'),
('Mark Santos',    'mark',    '$2y$10$gjttH1dIermJtNxhseneXuKvPmZEwgG5d6uMutv/MWjVJ1OBqU2xO', 'Admin'),
('Maria Cruz',     'maria',   '$2y$10$RdtPYE1T6BqZkuGJE0L.L.qlSz7Y2Eh/3fkj/Es7C9nwOpBOpgM9S', 'Staff'),
('Bernard Lopez',  'bernard', '$2y$10$okAQ/ys76DDAO62NpeECK.gbQxCAjyDHBIwmxsW7sFC/ID/tKI/dq', 'Staff');

INSERT INTO customers (full_name, phone) VALUES
('Jamelle Casandra Rustria', '09912404141'),
('Jillian Tabanganay',       '09912404147'),
('Jewel Segundo',            '09912404144'),
('Catherine Matillano',      '09171234567'),
('Trisha Panganiban',        '09281234567');

-- Pickup-only, pay-at-pickup: every active order is Unpaid; Released orders are Paid.
-- Price = rate per kg x billed kg (minimum charge 3 kg), rounded to the peso. Loads (Regular 7 kg, Heavy 6 kg per load, rounded up) only plan machines.
-- Insert order = order_id 1..8. created_by 2 = Maria.
INSERT INTO orders
  (order_number, customer_id, service_id, weight_kg, load_type, loads, price_per_load, total_amount,
   order_status, payment_status, created_by, created_at, released_at) VALUES
('LDY-20261009-001', 1, 1,  5.00, 'Light', 1, 45.00, 225.00, 'In Progress',      'Unpaid', 2, '2026-10-09 09:15:00', NULL),
('LDY-20261009-002', 2, 2,  6.00, 'Heavy', 2, 50.00, 300.00, 'Pending',          'Unpaid', 2, '2026-10-09 09:40:00', NULL),
('LDY-20261009-003', 3, 2,  4.00, 'Light', 1, 50.00, 200.00, 'Ready for Pickup', 'Unpaid', 2, '2026-10-09 08:30:00', NULL),
('LDY-20261006-001', 4, 1,  5.00, 'Light', 1, 45.00, 225.00, 'Released',         'Paid',   2, '2026-10-06 10:00:00', '2026-10-07 16:20:00'),
('LDY-20261009-004', 5, 2,  6.00, 'Light', 1, 50.00, 300.00, 'Pending',          'Unpaid', 2, '2026-10-09 10:05:00', NULL),
('LDY-20261007-001', 1, 3, 15.00, 'Heavy', 3, 55.00, 825.00, 'Released',         'Paid',   2, '2026-10-07 11:00:00', '2026-10-08 15:45:00'),
('LDY-20261008-001', 2, 1, 12.00, 'Heavy', 2, 45.00, 540.00, 'Ready for Pickup', 'Unpaid', 3, '2026-10-08 13:10:00', NULL),
('LDY-20261005-001', 3, 2,  7.00, 'Light', 1, 50.00, 350.00, 'Released',         'Paid',   3, '2026-10-05 09:00:00', '2026-10-05 17:30:00');

-- Garment types ticked on the sample orders (garment_id 1 = T-shirts, 6 = Jeans, 8 = Bed sheets, 3 = Dresses)
INSERT INTO order_garments (order_id, garment_id) VALUES
(1, 1), (2, 1), (2, 6), (3, 1), (3, 3), (4, 1), (5, 1), (6, 1), (6, 6), (7, 6), (7, 8), (8, 1);

-- Status trail for each order (Pending -> In Progress -> Ready for Pickup -> Released)
INSERT INTO order_status_history (order_id, from_status, to_status, changed_by, changed_at) VALUES
(1, NULL,               'Pending',          2, '2026-10-09 09:15:00'),
(1, 'Pending',          'In Progress',      2, '2026-10-09 09:50:00'),
(2, NULL,               'Pending',          2, '2026-10-09 09:40:00'),
(3, NULL,               'Pending',          2, '2026-10-09 08:30:00'),
(3, 'Pending',          'In Progress',      2, '2026-10-09 08:45:00'),
(3, 'In Progress',      'Ready for Pickup', 2, '2026-10-09 10:30:00'),
(4, NULL,               'Pending',          2, '2026-10-06 10:00:00'),
(4, 'Pending',          'In Progress',      2, '2026-10-06 10:30:00'),
(4, 'In Progress',      'Ready for Pickup', 2, '2026-10-06 14:00:00'),
(4, 'Ready for Pickup', 'Released',         2, '2026-10-07 16:20:00'),
(5, NULL,               'Pending',          2, '2026-10-09 10:05:00'),
(6, NULL,               'Pending',          2, '2026-10-07 11:00:00'),
(6, 'Pending',          'In Progress',      2, '2026-10-07 11:30:00'),
(6, 'In Progress',      'Ready for Pickup', 2, '2026-10-07 17:00:00'),
(6, 'Ready for Pickup', 'Released',         2, '2026-10-08 15:45:00'),
(7, NULL,               'Pending',          3, '2026-10-08 13:10:00'),
(7, 'Pending',          'In Progress',      3, '2026-10-08 13:40:00'),
(7, 'In Progress',      'Ready for Pickup', 3, '2026-10-08 18:00:00'),
(8, NULL,               'Pending',          3, '2026-10-05 09:00:00'),
(8, 'Pending',          'In Progress',      3, '2026-10-05 09:20:00'),
(8, 'In Progress',      'Ready for Pickup', 3, '2026-10-05 13:00:00'),
(8, 'Ready for Pickup', 'Released',         3, '2026-10-05 17:30:00');

-- One full payment per released order, taken at release (receipt_no = OR-<paid date>-NNN)
INSERT INTO payments
  (order_id, receipt_no, method, amount_due, amount_tendered, change_given, reference_no, received_by, paid_at) VALUES
(4, 'OR-20261007-001', 'Cash',  225.00, 250.00, 25.00, NULL,           2, '2026-10-07 16:20:00'),
(6, 'OR-20261008-001', 'GCash', 825.00, 825.00,  0.00, 'GC1234567890', 2, '2026-10-08 15:45:00'),
(8, 'OR-20261005-001', 'Cash',  350.00, 400.00, 50.00, NULL,           3, '2026-10-05 17:30:00');

-- Turnaround promise: one round (180 min) per 2 loads, rounded up (same rule as includes/sla.php; the live system also
-- adds waiting rounds at intake when an order cannot start at once, the sample data has none)
UPDATE orders SET promised_at = DATE_ADD(created_at, INTERVAL (180 * GREATEST(CEIL(CEIL(loads) / 2), 1)) MINUTE);

-- Machine history. Only an In Progress order holds machines (an open row, released_at NULL);
-- Ready for Pickup orders have already given theirs back at Mark Ready, and Pending orders hold none.
INSERT INTO order_machines (order_id, machine_id, reserved_at, released_at) VALUES
(1, 1, '2026-10-09 09:50:00', NULL),                  (1, 7,  '2026-10-09 09:50:00', NULL),
(3, 3, '2026-10-09 08:45:00', '2026-10-09 10:30:00'), (3, 9,  '2026-10-09 08:45:00', '2026-10-09 10:30:00'),
(7, 5, '2026-10-08 13:40:00', '2026-10-08 18:00:00'), (7, 6,  '2026-10-08 13:40:00', '2026-10-08 18:00:00'),
(7, 11,'2026-10-08 13:40:00', '2026-10-08 18:00:00'), (7, 12, '2026-10-08 13:40:00', '2026-10-08 18:00:00');
