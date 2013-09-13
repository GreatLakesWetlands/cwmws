# where to stage files - DELETED on update
OUT_DIR=/home/tbrown/n/proj/GLRI/mon/data/cwm_export

# criteria for exporting site, SQL snippet
USE_SITE="
exists (select 1 
          from glrimon.tagging_taggeditem
               join glrimon.tagging_tag on (tagging_taggeditem.tag_id = tagging_tag.id)
         where tagging_taggeditem.object_id = site.site and
               tagging_tag.name ~ 'in-year: ')
"

# connection spec.
HOST=beaver.nrri.umn.edu
PORT=5432
HOST=127.0.0.1
PORT=15432
DBNAME=nrgisl01
PASSWORD="$(cat ~/.nrpwd)"
CONSPEC="PG:host=$HOST port=$PORT dbname=$DBNAME password=$PASSWORD"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
echo "-- Exported $(date)" >"$OUT_DIR/00README.TXT"

TABLES="
with veg_ibi as (
select distinct on (site) table_id as site, score
  from glrimon.fi_ibi_static_score
       join glrimon.fi_ibi_attr using (ibi_attr)
 where table_name = 'V_sampling' and
       fi_ibi_attr.name = 'Veg. IBI'
), 

fish_ibi as (
select distinct on (site) table_id as site, score
  from glrimon.fi_ibi_static_score
       join glrimon.fi_ibi_attr using (ibi_attr)
 where table_name = 'Fi_sampling' and
       fi_ibi_attr.name = 'Site fish IBI total score'
), 

invert_ibi as (
select distinct on (site) table_id as site, score
  from glrimon.fi_ibi_static_score
       join glrimon.fi_ibi_attr using (ibi_attr)
 where table_name = 'Fi_sampling' and
       fi_ibi_attr.name = 'Site invert. IBI total score'
)
"

# common fields for shapefiles
COMMON_FIELDS="
    site, 
    name, 
    st_y(st_centroid(simp_geom)) as lat,
    st_x(st_centroid(simp_geom)) as lon,
    
    (select substring(tagging_tag.name from 8)
       from glrimon.tagging_taggeditem, glrimon.tagging_tag
      where tag_id = tagging_tag.id and object_id = site and 
            tagging_tag.name ~ 'class: ') as geomorph,
    
    veg_ibi.score as veg_ibi,
    fish_ibi.score as fish_ibi,
    invert_ibi.score as invert_ibi
  "


SQL="
$TABLES
select $COMMON_FIELDS, simp_geom 
  from glrimon.site
       left join veg_ibi using (site)
       left join fish_ibi using (site)
       left join invert_ibi using (site)
 where $USE_SITE
  "

echo -e "\n-- sites\n\n$SQL\n" >>"$OUT_DIR/00README.TXT"

# shapefiles
ogr2ogr -f 'ESRI Shapefile' "$OUT_DIR/sites.shp" "$CONSPEC" \
  -sql "$SQL"

SQL="
$TABLES
select $COMMON_FIELDS, st_centroid(simp_geom) 
  from glrimon.site
       left join veg_ibi using (site)
       left join fish_ibi using (site)
       left join invert_ibi using (site)
 where $USE_SITE
  "

ogr2ogr -f 'ESRI Shapefile' "$OUT_DIR/centroids.shp" "$CONSPEC" \
  -sql "$SQL"
  

# species list
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
