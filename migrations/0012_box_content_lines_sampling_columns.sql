-- Migration 0012: Add sampling data columns to box_content_lines
-- Adds fields to capture in-field gas sampling measurements (GPS, pressure, timing, wind/ship)

ALTER TABLE box_content_lines
    ADD COLUMN sampled_at                    TIMESTAMPTZ,
    ADD COLUMN sampled_lat_raw               TEXT,
    ADD COLUMN sampled_lon_raw               TEXT,
    ADD COLUMN sampled_lat                   DOUBLE PRECISION,
    ADD COLUMN sampled_lon                   DOUBLE PRECISION,
    ADD COLUMN sampled_initial_pressure      DOUBLE PRECISION,
    ADD COLUMN sampled_local_start_time      TIME,
    ADD COLUMN sampled_local_stop_flush_time TIME,
    ADD COLUMN sampled_final_pressure        DOUBLE PRECISION,
    ADD COLUMN sampled_wind_speed_direction  TEXT,
    ADD COLUMN sampled_ship_speed_direction  TEXT;

COMMENT ON COLUMN box_content_lines.sampled_at                    IS 'Sampled data in UTC time';
COMMENT ON COLUMN box_content_lines.sampled_lat_raw               IS 'Sampled latitude string in Degrees and Decimal Minutes (DDM)';
COMMENT ON COLUMN box_content_lines.sampled_lon_raw               IS 'Sampled longitude string in Degrees and Decimal Minutes (DDM)';
COMMENT ON COLUMN box_content_lines.sampled_lat                   IS 'Sampled latitude in decimal degrees';
COMMENT ON COLUMN box_content_lines.sampled_lon                   IS 'Sampled longitude in decimal degrees';
COMMENT ON COLUMN box_content_lines.sampled_initial_pressure      IS 'Initial pressure';
COMMENT ON COLUMN box_content_lines.sampled_local_start_time      IS 'Sampled local start time';
COMMENT ON COLUMN box_content_lines.sampled_local_stop_flush_time IS 'Sampled local stop flush time';
COMMENT ON COLUMN box_content_lines.sampled_final_pressure        IS 'Sampled final pressure';
COMMENT ON COLUMN box_content_lines.sampled_wind_speed_direction  IS 'Sampled wind speed direction';
COMMENT ON COLUMN box_content_lines.sampled_ship_speed_direction  IS 'Sampled ship speed direction';
