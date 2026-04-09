CREATE TABLE `admin_activity_log` (
	`id` text PRIMARY KEY NOT NULL,
	`actor_user_id` text,
	`actor_role` text,
	`action` text NOT NULL,
	`target_type` text NOT NULL,
	`target_id` text,
	`description` text NOT NULL,
	`metadata_json` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`actor_user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE INDEX `admin_activity_log_actor_user_id_idx` ON `admin_activity_log` (`actor_user_id`);
--> statement-breakpoint
CREATE INDEX `admin_activity_log_action_idx` ON `admin_activity_log` (`action`);
--> statement-breakpoint
CREATE INDEX `admin_activity_log_target_type_idx` ON `admin_activity_log` (`target_type`);
--> statement-breakpoint
CREATE INDEX `admin_activity_log_created_at_idx` ON `admin_activity_log` (`created_at`);
--> statement-breakpoint

CREATE TABLE `import_batch` (
	`id` text PRIMARY KEY NOT NULL,
	`source_type` text NOT NULL,
	`uploaded_filename` text,
	`total_count` integer DEFAULT 0 NOT NULL,
	`success_count` integer DEFAULT 0 NOT NULL,
	`failed_count` integer DEFAULT 0 NOT NULL,
	`created_by_user_id` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE INDEX `import_batch_source_type_idx` ON `import_batch` (`source_type`);
--> statement-breakpoint
CREATE INDEX `import_batch_created_by_user_id_idx` ON `import_batch` (`created_by_user_id`);
--> statement-breakpoint

CREATE TABLE `vehicle` (
	`id` text PRIMARY KEY NOT NULL,
	`plate_number` text NOT NULL,
	`name` text NOT NULL,
	`type` text NOT NULL,
	`is_active` integer DEFAULT true NOT NULL,
	`created_by_user_id` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `vehicle_plate_number_unique` ON `vehicle` (`plate_number`);
--> statement-breakpoint
CREATE INDEX `vehicle_created_by_user_id_idx` ON `vehicle` (`created_by_user_id`);
--> statement-breakpoint

CREATE TABLE `shipment` (
	`id` text PRIMARY KEY NOT NULL,
	`vehicle_id` text NOT NULL,
	`status` text DEFAULT 'DRAFT' NOT NULL,
	`note` text,
	`departure_date` integer,
	`arrival_date` integer,
	`created_by_user_id` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle`(`id`) ON UPDATE no action ON DELETE restrict,
	FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE INDEX `shipment_vehicle_id_idx` ON `shipment` (`vehicle_id`);
--> statement-breakpoint
CREATE INDEX `shipment_status_idx` ON `shipment` (`status`);
--> statement-breakpoint
CREATE INDEX `shipment_created_by_user_id_idx` ON `shipment` (`created_by_user_id`);
--> statement-breakpoint

ALTER TABLE `branch` ADD `china_address` text;
--> statement-breakpoint

PRAGMA defer_foreign_keys=ON;
--> statement-breakpoint
PRAGMA foreign_keys=OFF;
--> statement-breakpoint

ALTER TABLE `cargo` RENAME TO `cargo_old`;
--> statement-breakpoint

CREATE TABLE `cargo` (
	`id` text PRIMARY KEY NOT NULL,
	`customer_id` text,
	`branch_id` text,
	`shipment_id` text,
	`tracking_number` text NOT NULL,
	`description` text,
	`status` text DEFAULT 'CREATED' NOT NULL,
	`payment_status` text DEFAULT 'UNPAID' NOT NULL,
	`fulfillment_type` text,
	`weight_grams` integer,
	`height_cm` integer,
	`width_cm` integer,
	`length_cm` integer,
	`is_fragile` integer DEFAULT false NOT NULL,
	`base_shipping_fee_mnt` integer,
	`calculated_fee_mnt` integer,
	`override_fee_mnt` integer,
	`pricing_method` text,
	`priced_at` integer,
	`priced_by_user_id` text,
	`local_delivery_fee_mnt` integer DEFAULT 0 NOT NULL,
	`total_fee_mnt` integer,
	`import_source` text,
	`import_batch_id` text,
	`placeholder_status` text DEFAULT 'LINKED',
	`delivery_address` text,
	`delivery_phone` text,
	`received_image_url` text,
	`received_image_object_key` text,
	`received_in_china_at` integer,
	`departed_china_at` integer,
	`arrived_in_mongolia_at` integer,
	`fulfillment_selected_at` integer,
	`completed_at` integer,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`customer_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`branch_id`) REFERENCES `branch`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`shipment_id`) REFERENCES `shipment`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`priced_by_user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`import_batch_id`) REFERENCES `import_batch`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint

INSERT INTO `cargo`(
	`id`,
	`customer_id`,
	`branch_id`,
	`shipment_id`,
	`tracking_number`,
	`description`,
	`status`,
	`payment_status`,
	`fulfillment_type`,
	`weight_grams`,
	`height_cm`,
	`width_cm`,
	`length_cm`,
	`is_fragile`,
	`base_shipping_fee_mnt`,
	`calculated_fee_mnt`,
	`override_fee_mnt`,
	`pricing_method`,
	`priced_at`,
	`priced_by_user_id`,
	`local_delivery_fee_mnt`,
	`total_fee_mnt`,
	`import_source`,
	`import_batch_id`,
	`placeholder_status`,
	`delivery_address`,
	`delivery_phone`,
	`received_image_url`,
	`received_image_object_key`,
	`received_in_china_at`,
	`departed_china_at`,
	`arrived_in_mongolia_at`,
	`fulfillment_selected_at`,
	`completed_at`,
	`created_at`,
	`updated_at`
)
SELECT
	`id`,
	CASE WHEN `customer_id` IN (SELECT `id` FROM `user`) THEN `customer_id` ELSE NULL END,
	CASE WHEN `branch_id` IN (SELECT `id` FROM `branch`) THEN `branch_id` ELSE NULL END,
	NULL,
	`tracking_number`,
	`description`,
	`status`,
	`payment_status`,
	`fulfillment_type`,
	`weight_grams`,
	NULL,
	NULL,
	NULL,
	false,
	`base_shipping_fee_mnt`,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	`local_delivery_fee_mnt`,
	`total_fee_mnt`,
	NULL,
	NULL,
	CASE WHEN `customer_id` IS NULL THEN 'UNASSIGNED' ELSE 'LINKED' END,
	`delivery_address`,
	`delivery_phone`,
	`received_image_url`,
	`received_image_object_key`,
	`received_in_china_at`,
	`departed_china_at`,
	`arrived_in_mongolia_at`,
	`fulfillment_selected_at`,
	`completed_at`,
	`created_at`,
	`updated_at`
FROM `cargo_old`;
--> statement-breakpoint

CREATE TABLE `payment_cargo_new` (
	`id` text PRIMARY KEY NOT NULL,
	`payment_id` text NOT NULL,
	`cargo_id` text NOT NULL,
	`amount_mnt` integer NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`payment_id`) REFERENCES `payment`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`cargo_id`) REFERENCES `cargo`(`id`) ON UPDATE no action ON DELETE restrict
);
--> statement-breakpoint

INSERT INTO `payment_cargo_new` (`id`, `payment_id`, `cargo_id`, `amount_mnt`, `created_at`)
SELECT `id`, `payment_id`, `cargo_id`, `amount_mnt`, `created_at`
FROM `payment_cargo`;
--> statement-breakpoint

CREATE TABLE `cargo_status_event_new` (
	`id` text PRIMARY KEY NOT NULL,
	`cargo_id` text NOT NULL,
	`from_status` text,
	`to_status` text NOT NULL,
	`note` text,
	`changed_by_user_id` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`cargo_id`) REFERENCES `cargo`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`changed_by_user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint

INSERT INTO `cargo_status_event_new` (`id`, `cargo_id`, `from_status`, `to_status`, `note`, `changed_by_user_id`, `created_at`)
SELECT `id`, `cargo_id`, `from_status`, `to_status`, `note`, `changed_by_user_id`, `created_at`
FROM `cargo_status_event`;
--> statement-breakpoint

DROP TABLE `payment_cargo`;
--> statement-breakpoint
DROP TABLE `cargo_status_event`;
--> statement-breakpoint
DROP TABLE `cargo_old`;
--> statement-breakpoint

ALTER TABLE `payment_cargo_new` RENAME TO `payment_cargo`;
--> statement-breakpoint
ALTER TABLE `cargo_status_event_new` RENAME TO `cargo_status_event`;
--> statement-breakpoint

PRAGMA foreign_keys=ON;
--> statement-breakpoint

CREATE UNIQUE INDEX `cargo_tracking_number_unique` ON `cargo` (`tracking_number`);
--> statement-breakpoint
CREATE INDEX `cargo_customer_id_idx` ON `cargo` (`customer_id`);
--> statement-breakpoint
CREATE INDEX `cargo_branch_id_idx` ON `cargo` (`branch_id`);
--> statement-breakpoint
CREATE INDEX `cargo_shipment_id_idx` ON `cargo` (`shipment_id`);
--> statement-breakpoint
CREATE INDEX `cargo_status_idx` ON `cargo` (`status`);
--> statement-breakpoint
CREATE INDEX `cargo_payment_status_idx` ON `cargo` (`payment_status`);
--> statement-breakpoint
CREATE INDEX `cargo_tracking_number_idx` ON `cargo` (`tracking_number`);
--> statement-breakpoint
CREATE INDEX `cargo_import_batch_id_idx` ON `cargo` (`import_batch_id`);
--> statement-breakpoint
CREATE INDEX `payment_cargo_payment_id_idx` ON `payment_cargo` (`payment_id`);
--> statement-breakpoint
CREATE INDEX `payment_cargo_cargo_id_idx` ON `payment_cargo` (`cargo_id`);
--> statement-breakpoint
CREATE UNIQUE INDEX `payment_cargo_payment_cargo_unique` ON `payment_cargo` (`payment_id`, `cargo_id`);
--> statement-breakpoint
CREATE INDEX `cargo_status_event_cargo_id_idx` ON `cargo_status_event` (`cargo_id`);
--> statement-breakpoint
CREATE INDEX `cargo_status_event_changed_by_user_id_idx` ON `cargo_status_event` (`changed_by_user_id`);
