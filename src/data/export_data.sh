# where to stage files - DELETED on update
OUT_DIR=/home/tbrown/n/proj/GLRI/mon/data/cwm_export

# connection spec.
HOST=127.0.0.1
PORT=15432
HOST=beaver.nrri.umn.edu
PORT=5432
DBNAME=nrgisl01
PASSWORD="$(cat ~/.nrpwd)"
CONSPEC="PG:host=$HOST port=$PORT dbname=$DBNAME password=$PASSWORD"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
echo "-- Exported $(date)" >"$OUT_DIR/00README.TXT"


# shapefiles
ogr2ogr -f 'ESRI Shapefile' "$OUT_DIR/sites.shp" "$CONSPEC" \
  -sql "
select glrimon_misc.cwm_site_export.*, simp_geom
  from glrimon_misc.cwm_site_export 
       join glrimon.site using (site)
"
ogr2ogr -f 'ESRI Shapefile' "$OUT_DIR/centroids.shp" "$CONSPEC" \
  -sql "
select glrimon_misc.cwm_site_export.*, st_centroid(simp_geom)
  from glrimon_misc.cwm_site_export 
       join glrimon.site using (site)
"

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
