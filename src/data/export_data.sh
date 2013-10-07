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
select glrimon_misc.cwm_site_export.*, st_centroid(Box2D(simp_geom))
  from glrimon_misc.cwm_site_export 
       join glrimon.site using (site)
"

# species list

ogr2ogr -f 'ESRI Shapefile' "$OUT_DIR/species.dbf" "$CONSPEC" \
  -lco SHPT=NULL glrimon_misc.cwm_spp_export -overwrite
