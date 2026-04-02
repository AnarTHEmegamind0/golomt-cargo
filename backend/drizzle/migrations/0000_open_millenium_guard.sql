CREATE TABLE `account` (
	`id` text PRIMARY KEY NOT NULL,
	`account_id` text NOT NULL,
	`provider_id` text NOT NULL,
	`user_id` text NOT NULL,
	`access_token` text,
	`refresh_token` text,
	`id_token` text,
	`access_token_expires_at` integer,
	`refresh_token_expires_at` integer,
	`scope` text,
	`password` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `account_userId_idx` ON `account` (`user_id`);--> statement-breakpoint
CREATE TABLE `session` (
	`id` text PRIMARY KEY NOT NULL,
	`expires_at` integer NOT NULL,
	`token` text NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`ip_address` text,
	`user_agent` text,
	`impersonated_by` text,
	`user_id` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE UNIQUE INDEX `session_token_unique` ON `session` (`token`);--> statement-breakpoint
CREATE INDEX `session_userId_idx` ON `session` (`user_id`);--> statement-breakpoint
CREATE TABLE `user` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`email` text NOT NULL,
	`email_verified` integer DEFAULT false NOT NULL,
	`image` text,
	`role` text DEFAULT 'customer',
	`banned` integer DEFAULT false,
	`ban_reason` text,
	`ban_expires` integer,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `user_email_unique` ON `user` (`email`);--> statement-breakpoint
CREATE TABLE `verification` (
	`id` text PRIMARY KEY NOT NULL,
	`identifier` text NOT NULL,
	`value` text NOT NULL,
	`expires_at` integer NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE INDEX `verification_identifier_idx` ON `verification` (`identifier`);--> statement-breakpoint
CREATE TABLE `branch` (
	`id` text PRIMARY KEY NOT NULL,
	`code` text NOT NULL,
	`name` text NOT NULL,
	`address` text,
	`phone` text,
	`is_active` integer DEFAULT true NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `branch_code_unique` ON `branch` (`code`);--> statement-breakpoint
CREATE TABLE `cargo` (
	`id` text PRIMARY KEY NOT NULL,
	`customer_id` text NOT NULL,
	`branch_id` text,
	`tracking_number` text NOT NULL,
	`status` text DEFAULT 'CREATED' NOT NULL,
	`payment_status` text DEFAULT 'UNPAID' NOT NULL,
	`fulfillment_type` text,
	`weight_grams` integer,
	`base_shipping_fee_mnt` integer,
	`local_delivery_fee_mnt` integer DEFAULT 0 NOT NULL,
	`total_fee_mnt` integer,
	`delivery_address` text,
	`delivery_phone` text,
	`received_in_china_at` integer,
	`departed_china_at` integer,
	`arrived_in_mongolia_at` integer,
	`fulfillment_selected_at` integer,
	`completed_at` integer,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`customer_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`branch_id`) REFERENCES `branch`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `cargo_tracking_number_unique` ON `cargo` (`tracking_number`);--> statement-breakpoint
CREATE INDEX `cargo_customer_id_idx` ON `cargo` (`customer_id`);--> statement-breakpoint
CREATE INDEX `cargo_branch_id_idx` ON `cargo` (`branch_id`);--> statement-breakpoint
CREATE INDEX `cargo_status_idx` ON `cargo` (`status`);--> statement-breakpoint
CREATE INDEX `cargo_payment_status_idx` ON `cargo` (`payment_status`);--> statement-breakpoint
CREATE INDEX `cargo_tracking_number_idx` ON `cargo` (`tracking_number`);--> statement-breakpoint
CREATE TABLE `cargo_status_event` (
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
CREATE INDEX `cargo_status_event_cargo_id_idx` ON `cargo_status_event` (`cargo_id`);--> statement-breakpoint
CREATE INDEX `cargo_status_event_changed_by_user_id_idx` ON `cargo_status_event` (`changed_by_user_id`);--> statement-breakpoint
CREATE TABLE `payment` (
	`id` text PRIMARY KEY NOT NULL,
	`customer_id` text NOT NULL,
	`status` text DEFAULT 'PENDING' NOT NULL,
	`method` text NOT NULL,
	`provider` text,
	`provider_payment_id` text,
	`total_amount_mnt` integer NOT NULL,
	`currency` text DEFAULT 'MNT' NOT NULL,
	`paid_at` integer,
	`note` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`customer_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `payment_customer_id_idx` ON `payment` (`customer_id`);--> statement-breakpoint
CREATE INDEX `payment_status_idx` ON `payment` (`status`);--> statement-breakpoint
CREATE INDEX `payment_method_idx` ON `payment` (`method`);--> statement-breakpoint
CREATE TABLE `payment_cargo` (
	`id` text PRIMARY KEY NOT NULL,
	`payment_id` text NOT NULL,
	`cargo_id` text NOT NULL,
	`amount_mnt` integer NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`payment_id`) REFERENCES `payment`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`cargo_id`) REFERENCES `cargo`(`id`) ON UPDATE no action ON DELETE restrict
);
--> statement-breakpoint
CREATE INDEX `payment_cargo_payment_id_idx` ON `payment_cargo` (`payment_id`);--> statement-breakpoint
CREATE INDEX `payment_cargo_cargo_id_idx` ON `payment_cargo` (`cargo_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `payment_cargo_payment_id_cargo_id_uidx` ON `payment_cargo` (`payment_id`,`cargo_id`);