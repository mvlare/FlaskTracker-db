  -- Better Auth Tables                                                                                             
  CREATE TABLE "user" (
        "id" text PRIMARY KEY NOT NULL,
        "name" text NOT NULL,                                                                                       
        "email" text NOT NULL, 
        "email_verified" boolean DEFAULT false NOT NULL,
        "image" text,
        "created_at" timestamp DEFAULT now() NOT NULL,
        "updated_at" timestamp DEFAULT now() NOT NULL,
        "is_admin" boolean DEFAULT false NOT NULL,
        CONSTRAINT "user_email_unique" UNIQUE("email")                                                                );                                                                                                                

  CREATE TABLE "session" (
        "id" text PRIMARY KEY NOT NULL,
        "expires_at" timestamp NOT NULL,
        "token" text NOT NULL,
        "created_at" timestamp DEFAULT now() NOT NULL,
        "updated_at" timestamp NOT NULL,
        "ip_address" text,
        "user_agent" text,
        "user_id" text NOT NULL,
        CONSTRAINT "session_token_unique" UNIQUE("token")
  );

  CREATE TABLE "account" (
        "id" text PRIMARY KEY NOT NULL,
        "account_id" text NOT NULL,
        "provider_id" text NOT NULL,
        "user_id" text NOT NULL,
        "access_token" text,
        "refresh_token" text,
        "id_token" text,
        "access_token_expires_at" timestamp,
        "refresh_token_expires_at" timestamp,
        "scope" text,
        "password" text,
        "created_at" timestamp DEFAULT now() NOT NULL,
        "updated_at" timestamp NOT NULL
  );

  CREATE TABLE "verification" (
        "id" text PRIMARY KEY NOT NULL,
        "identifier" text NOT NULL,
        "value" text NOT NULL,
        "expires_at" timestamp NOT NULL,
        "created_at" timestamp DEFAULT now() NOT NULL,
        "updated_at" timestamp DEFAULT now() NOT NULL
  );

  -- Foreign Keys
  ALTER TABLE "account" ADD CONSTRAINT "account_user_id_user_id_fk"
      FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;

  ALTER TABLE "session" ADD CONSTRAINT "session_user_id_user_id_fk"
      FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;

  -- Indexes
  CREATE INDEX "account_userId_idx" ON "account" USING btree ("user_id");
  CREATE INDEX "session_userId_idx" ON "session" USING btree ("user_id");
  CREATE INDEX "verification_identifier_idx" ON "verification" USING btree ("identifier");


  --- begin rename  created_by and updated_by
  ALTER TABLE flasks
    RENAME COLUMN created_by TO created_user_id;

  ALTER TABLE flasks
    RENAME COLUMN updated_by TO updated_user_id;

  -- Add foreign key constraints (optional but recommended)
  ALTER TABLE flasks
    ADD CONSTRAINT flasks_created_user_id_fk
    FOREIGN KEY (created_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  ALTER TABLE flasks
    ADD CONSTRAINT flasks_updated_user_id_fk
    FOREIGN KEY (updated_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  -- boxes table
  ALTER TABLE boxes
    RENAME COLUMN created_by TO created_user_id;

  ALTER TABLE boxes
    RENAME COLUMN updated_by TO updated_user_id;

  ALTER TABLE boxes
    ADD CONSTRAINT boxes_created_user_id_fk
    FOREIGN KEY (created_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  ALTER TABLE boxes
    ADD CONSTRAINT boxes_updated_user_id_fk
    FOREIGN KEY (updated_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  -- flask_ref_type table
  ALTER TABLE flask_ref_type
    RENAME COLUMN created_by TO created_user_id;

  ALTER TABLE flask_ref_type
    RENAME COLUMN updated_by TO updated_user_id;

  ALTER TABLE flask_ref_type
    ADD CONSTRAINT flask_ref_type_created_user_id_fk
    FOREIGN KEY (created_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  ALTER TABLE flask_ref_type
    ADD CONSTRAINT flask_ref_type_updated_user_id_fk
    FOREIGN KEY (updated_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  -- flasks_ref table
  ALTER TABLE flasks_ref
    RENAME COLUMN created_by TO created_user_id;

  ALTER TABLE flasks_ref
    RENAME COLUMN updated_by TO updated_user_id;

  ALTER TABLE flasks_ref
    ADD CONSTRAINT flasks_ref_created_user_id_fk
    FOREIGN KEY (created_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  ALTER TABLE flasks_ref
    ADD CONSTRAINT flasks_ref_updated_user_id_fk
    FOREIGN KEY (updated_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  -- box_content_headers table
  ALTER TABLE box_content_headers
    RENAME COLUMN created_by TO created_user_id;

  ALTER TABLE box_content_headers
    RENAME COLUMN updated_by TO updated_user_id;

  ALTER TABLE box_content_headers
    ADD CONSTRAINT box_content_headers_created_user_id_fk
    FOREIGN KEY (created_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  ALTER TABLE box_content_headers
    ADD CONSTRAINT box_content_headers_updated_user_id_fk
    FOREIGN KEY (updated_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  -- box_content_lines table
  ALTER TABLE box_content_lines
    RENAME COLUMN created_by TO created_user_id;

  ALTER TABLE box_content_lines
    RENAME COLUMN updated_by TO updated_user_id;

  ALTER TABLE box_content_lines
    ADD CONSTRAINT box_content_lines_created_user_id_fk
    FOREIGN KEY (created_user_id) REFERENCES "user"("id") ON DELETE SET NULL;

  ALTER TABLE box_content_lines
    ADD CONSTRAINT box_content_lines_updated_user_id_fk
    FOREIGN KEY (updated_user_id) REFERENCES "user"("id") ON DELETE SET NULL;