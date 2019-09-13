kuntar
================
Meeri Seppä

This folder contains the following files:

<table>
<colgroup>
<col width="50%" />
<col width="22%" />
<col width="27%" />
</colgroup>
<thead>
<tr class="header">
<th><em>input</em></th>
<th><em>filename </em></th>
<th><em>output</em></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>(old shapefiles)</td>
<td>create_ids</td>
<td>ids.csv, kartoissa_olevat_kunnat.csv, lakkautetut_kunnnat_2019_tilastokesku.csv, olemassa_olevat_kunnnat_2019.csv</td>
</tr>
<tr class="even">
<td>old shapefiles, ids.csv</td>
<td>fix_maps</td>
<td>mapfiles, mapfiles_fixed</td>
</tr>
<tr class="odd">
<td>mapfiles_fixed</td>
<td>remove_overlaps</td>
<td>mapfiles_fixed_no_overlaps</td>
</tr>
<tr class="even">
<td>mapfiles_fixed_no_overlaps</td>
<td>create_changes</td>
<td>kuntamuutokset_1860_1970.csv</td>
</tr>
<tr class="odd">
<td>mapfiles_fixed_no_overlaps, kuntamuutokset_1860_1970.csv, lakkautetut_kunnnat_2019_tilastokeskus.csv</td>
<td>remove_errors</td>
<td>mapfiles_fixed_no_overlaps_or_errors, new_shapfiles (kunnat)</td>
</tr>
<tr class="even">
<td>mapfiles_fixed_no_overlaps_or_errors</td>
<td>update_changes</td>
<td>kuntamuutokset_1860_1970_no_errors.csv</td>
</tr>
<tr class="odd">
<td>mapfiles_fixed_no_overlaps_or_errors, kuntamuutokset_1860_1970.csv</td>
<td>create_consistent</td>
<td>new_shapefiles (consistent)</td>
</tr>
<tr class="even">
<td>mapfiles_fixed_no_overlaps_or_errors</td>
<td>create_crosswalk</td>
<td>crosswalk_files</td>
</tr>
<tr class="odd">
<td>shapefiles (2013-2019)</td>
<td>create_mapfiles_00</td>
<td>mapfiles_00</td>
</tr>
<tr class="even">
<td>ids.csv</td>
<td>create_leikkidata</td>
<td>leikkidata_1930.csv, leikkidata_1970.csv</td>
</tr>
</tbody>
</table>

These files contain functions that are used in the scripts above:

-   functions.R
-   functions\_fix\_maps.R
-   functions\_consistent

This file will update every dataset:

-   update\_files.R

User interface:

-   app.R
