
drop view if exists glrimon_misc.cwm_site_export;
create view glrimon_misc.cwm_site_export as

with fish_ibi as (
select distinct on (site) table_id as site, score
  from glrimon.fi_ibi_static_score
       join glrimon.fi_ibi_attr using (ibi_attr)
 where table_name = 'Fi_sampling' and
       fi_ibi_attr.name = 'Site fish IBI total score'
), 

veg_ibi as (
select distinct on (site) site, score
  from glrimon.fi_ibi_static_score
       join glrimon.fi_ibi_attr using (ibi_attr),
       glrimon.v_sampling
 where table_name = 'V_sampling' and
       fi_ibi_attr.name = 'Veg. IBI'
       and table_id = sampling
), 

invert_ibi as (
select distinct on (site) table_id as site, score
  from glrimon.fi_ibi_static_score
       join glrimon.fi_ibi_attr using (ibi_attr)
 where table_name = 'Fi_sampling' and
       fi_ibi_attr.name = 'Site invert. IBI total score'
),

sample_year as (

    select site, min(year) as year from (
           -- veg.
    select site, year from glrimon.v_sampling where qa_done
    union  -- fish
    select site, date_part('year', date_set)
      from glrimon.f_fish_total
           join glrimon.fi_zone_fyke using (zone_fyke)
           join glrimon.fi_sampling_zone using (sampling_zone)
           join glrimon.fi_sampling on (fi_sampling_zone.sampling=fi_sampling.sampling)
     where fi_zone_fyke.qa_done
    union  -- invert
    select site, date_part('year', fi_zone_invert.date)
      from glrimon.fi_bug_obs
           join glrimon.fi_lab_invert using (lab_invert)
           join glrimon.fi_zone_invert using (zone_invert)
           join glrimon.fi_sampling_zone using (sampling_zone)
           join glrimon.fi_sampling on (fi_sampling_zone.sampling=fi_sampling.sampling)
     where fi_zone_invert.qa_done
     union  -- birds
     select site, date_part('year', date) from glrimon.b_point where qa_done
     union  -- amph
     select site, date_part('year', date) from glrimon.a_point where qa_done
     
     union  -- to be done
     
     select site, year
       from glrimon.site_status
            join glrimon.workflow using (workflow)
      where workflow.data_level >= 0 and year > date_part('year', current_date)

    ) x group by site
)

select site, 
       name, 
       year,
       veg_ibi.score as veg_ibi,
       fish_ibi.score as fish_ibi,
       invert_ibi.score as invert_ibi,
       st_y(st_centroid(simp_geom)) as lat,
       st_x(st_centroid(simp_geom)) as lon,
       (select substring(tagging_tag.name from 8)
          from glrimon.tagging_taggeditem, glrimon.tagging_tag
         where tag_id = tagging_tag.id and object_id = site and 
               tagging_tag.name ~ 'class: ') as geomorph
    
  from glrimon.site
       join sample_year using (site)
       left join veg_ibi using (site)
       left join fish_ibi using (site)
       left join invert_ibi using (site)
-- -- filtering by join to sample_year
--  where exists (
--        select 1 
--          from glrimon.tagging_taggeditem
--               join glrimon.tagging_tag on (tagging_taggeditem.tag_id =
--                 tagging_tag.id)
--         where tagging_taggeditem.object_id = site.site and
--               tagging_tag.name ~ 'in-year: '
--        )
 order by site
;


SQL="select site, 'plant' as taxa, v_taxa.name
     from glrimon.v_taxa
          join glrimon.v_observation using (taxa)
          join glrimon.v_point using (point)
          join glrimon.v_transect using (transect)
          join glrimon.v_sampling using (sampling)
          join glrimon.site using (site)
    where $USE_SITE and qa_done
   union
   select site, 'bird', common
     from glrimon.site
          join glrimon.b_point using (site)
          join glrimon.b_observation using (point)
          join glrimon.b_taxa using (taxa)
    where $USE_SITE and qa_done
   union
   select site, 'amphibian', common
     from glrimon.site
          join glrimon.a_point using (site)
          join glrimon.a_observation using (point)
          join glrimon.a_taxa using (taxa)
    where $USE_SITE and qa_done
   union
   select site, 'fish', common
     from glrimon.site
          join glrimon.Fi_sampling using (site)
          join glrimon.Fi_sampling_zone using (sampling)
          join glrimon.Fi_zone_fyke using (sampling_zone)
          join glrimon.F_fish_total using (zone_fyke)
          join glrimon.F_taxa using (taxa)
    where $USE_SITE and Fi_zone_fyke.qa_done
   union
   select site, 'invertebrate', taxa
     from glrimon.Site
          join glrimon.Fi_sampling using (site)
          join glrimon.Fi_sampling_zone using (sampling)
          join glrimon.Fi_zone_invert using (sampling_zone)
          join glrimon.Fi_lab_invert using (zone_invert)
          join glrimon.Fi_bug_obs using (lab_invert)
          join glrimon.F_invert_taxa using (invert_taxa)
    where $USE_SITE and Fi_zone_invert.qa_done
  "
  
echo -e "\n-- species\n\n$SQL\n" >>"$OUT_DIR/00README.TXT"

ogr2ogr -f 'ESRI Shapefile' "$OUT_DIR/species.dbf" "$CONSPEC" \
  -lco SHPT=NULL -sql "$SQL"
