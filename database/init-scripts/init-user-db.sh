#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO
    \$\$
    BEGIN
        IF EXISTS (
            SELECT FROM pg_catalog.pg_roles WHERE  rolname = '$POSTGRES_USER')
        THEN
            RAISE NOTICE 'Role $POSTGRES_USER already exists.';
        ELSE
            CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
        END IF;

        CREATE EXTENSION IF NOT EXISTS dblink;
        IF EXISTS 
            (SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB') 
        THEN
            RAISE NOTICE 'Database already exists';
        ELSE
            PERFORM dblink_connect('host=localhost user=' || $POSTGRES_USER || ' password=' || $POSTGRES_PASSWORD || ' dbname=' || current_database());
            PERFORM dblink_exec('CREATE DATABASE ' || $POSTGRES_DB);
        END IF;
    END
    \$\$;

    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;


CREATE SEQUENCE public.banned_users_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.email_auth_accounts_id_seq;

CREATE SEQUENCE public.email_auth_accounts_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.kyc_statuses_id_seq;

CREATE SEQUENCE public.kyc_statuses_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.livestream_status_logs_id_seq;

CREATE SEQUENCE public.livestream_status_logs_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.reset_password_tokens_id_seq;

CREATE SEQUENCE public.reset_password_tokens_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.user_live_tream_statuses_id_seq;

CREATE SEQUENCE public.user_live_tream_statuses_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.users_id_seq;

CREATE SEQUENCE public.users_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.video_statuses_id_seq;

CREATE SEQUENCE public.video_statuses_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;-- public.banned_users definition

-- Drop table

-- DROP TABLE banned_users;

CREATE TABLE banned_users (
	id bigserial NOT NULL,
	uid int8 NULL,
	admin_id int8 NULL,
	description varchar(1000) NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT banned_users_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_admin_id ON public.banned_users USING btree (admin_id);
CREATE INDEX idx_banned_users_deleted_at ON public.banned_users USING btree (deleted_at);
CREATE INDEX idx_created_at ON public.banned_users USING btree (created_at);
CREATE INDEX idx_user ON public.banned_users USING btree (uid);


-- public.kyc_statuses definition

-- Drop table

-- DROP TABLE kyc_statuses;

CREATE TABLE kyc_statuses (
	id bigserial NOT NULL,
	uid int8 NULL,
	admin_id int8 NULL,
	description varchar(1000) NULL,
	status int2 NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT kyc_statuses_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_kyc_statuses_deleted_at ON public.kyc_statuses USING btree (deleted_at);


-- public.livestream_status_logs definition

-- Drop table

-- DROP TABLE livestream_status_logs;

CREATE TABLE livestream_status_logs (
	id bigserial NOT NULL,
	uid int8 NULL,
	feed_id int8 NULL,
	admin_id int8 NULL,
	description varchar(1000) NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT livestream_status_logs_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_feed_id ON public.livestream_status_logs USING btree (feed_id);


-- public.user_live_tream_statuses definition

-- Drop table

-- DROP TABLE user_live_tream_statuses;

CREATE TABLE user_live_tream_statuses (
	id bigserial NOT NULL,
	uid int8 NULL,
	admin_id int8 NULL,
	description varchar(1000) NULL,
	deleted_at timestamptz NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	video_id int8 NULL,
	CONSTRAINT user_live_tream_statuses_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_user_live_tream_statuses_deleted_at ON public.user_live_tream_statuses USING btree (deleted_at);
CREATE INDEX idx_video ON public.user_live_tream_statuses USING btree (video_id);
CREATE INDEX idx_video_id ON public.user_live_tream_statuses USING btree (video_id);


-- public.users definition

-- Drop table

-- DROP TABLE users;

CREATE TABLE users (
	id bigserial NOT NULL,
	uid int8 NULL,
	role_id int8 NULL,
	"name" varchar(255) NULL,
	username varchar(255) NULL,
	description varchar(1000) NULL,
	resources jsonb NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX idx_user_id ON public.users USING btree (uid);


-- public.video_statuses definition

-- Drop table

-- DROP TABLE video_statuses;

CREATE TABLE video_statuses (
	id bigserial NOT NULL,
	uid int8 NULL,
	video_id int8 NULL,
	admin_id int8 NULL,
	description varchar(1000) NULL,
	unbanned int8 NULL,
	banned int8 NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT video_statuses_pkey PRIMARY KEY (id)
);


-- public.email_auth_accounts definition

-- Drop table

-- DROP TABLE email_auth_accounts;

CREATE TABLE email_auth_accounts (
	id bigserial NOT NULL,
	user_id int8 NULL,
	email varchar(255) NULL,
	"password" varchar(255) NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT email_auth_accounts_pkey PRIMARY KEY (id),
	CONSTRAINT fk_email_auth_accounts_user FOREIGN KEY (user_id) REFERENCES users(uid)
);
CREATE UNIQUE INDEX idx_email ON public.email_auth_accounts USING btree (email);


-- public.reset_password_tokens definition

-- Drop table

-- DROP TABLE reset_password_tokens;

CREATE TABLE reset_password_tokens (
	id bigserial NOT NULL,
	user_id int8 NULL,
	"token" varchar(255) NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL,
	CONSTRAINT reset_password_tokens_pkey PRIMARY KEY (id),
	CONSTRAINT fk_reset_password_tokens_user FOREIGN KEY (user_id) REFERENCES users(uid)
);
INSERT INTO public.users (uid,role_id,"name",username,description,resources,created_at,updated_at) VALUES
	 (1535108099596095488,0,'Trịnh quang tiến','','','null','2022-06-10 10:54:26.53089+07','2022-06-10 10:54:26.53089+07');
EOSQL