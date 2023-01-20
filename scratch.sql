select
  metadata->'disk' as disk,
  metadata->'vcpus' as vcpus,
  metadata->'memory' as memory,
  avg(jsonb_pretty(((regexp_split_to_array(content, 'http.*\.git'))[2])::jsonb->'metrics'->'http_reqs'->'rate')::float) as rps
  from
    hasura_battery_test
 where true
   and url = 'https://github.com/dventimihasura/battery-test-5.git'
 group by
   disk,
   vcpus,
   memory
 order by vcpus;
