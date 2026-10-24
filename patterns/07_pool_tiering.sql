-- Pattern 07: Pool tiering by workload (raster vs database)
-- Place hot database workloads on SSD-backed pools with 3x replication,
-- bulk raster/archive on erasure-coded pools with lower cost.
CREATE POOL IF NOT EXISTS db_pool (size=3, min_size=2, crush_rule=ssd-replicated, pg_autoscale_mode=on);
CREATE POOL IF NOT EXISTS raster_pool (size=2, min_size=1, crush_rule=hdd-ec, pg_autoscale_mode=on, erasure_code_profile=default);
-- Bind applications
-- ceph osd pool application enable db_pool rbd
-- ceph osd pool application enable raster_pool rbd
