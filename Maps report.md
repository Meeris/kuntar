

# Maps

By Meeri Seppä

[TOC]

## 1. Introduction 

This project aims to create a solution for the problem imposed by municipality mergers  when working with historical data. Firstly, I have created crosswalks that connect two (or more) years together. Secondly, I have created areas that stay the same trhoughout the years, that is, there are no changes in the municipalitiy borders within this area. 

The main tool that I used is the programming language R which provides many useful functions for manipulating geospatial data.  In order to have the functionalities provided by the code files open to everyone regardless of programming skills, I have created a simple user interface which can be found here: https://meeri.shinyapps.io/kuntar/.  

In this report, I will go trhough how the original data have been manipulated, how the new data are created and what they consist of, and how they should be used.



## 2. Towards error free maps

In this section I go trough the process of how I created the new shapefiles from the original ones. I will also present the various ways in which I tried to identify as many errors as I can and how I tried to solve them,. This list, however, is not complete, and it is very likely, that the maps still contain errors that have stayed unnoticed.  

### 2.1 Shapefiles

This project is based on maps that represent the municipality division in Finland. There are twelve maps in total, and they repesent years 1860, 1901, 1910, 1930, 1970 and 2013 — 2019.  The first five maps are from ? and the latter 7 are provided by Statistics Finland. The maps are saved as "shapefiles" which is a common way of dealing with geospatial data. In these files, each municipality is representered by one or multiple polygons.

The original shapefile of year 1901 includes sea areas surrounding Finland. I deleted them manually with QGIS software by plotting the 1901 map at the same time with the 1910 map.  After doing this, the unwanted polygons are easy to spot and delete. 

The five first maps include some polygons that self intersect, that is, they are "invalid". In all of the cases, these intersections are very small and insignificant for this project. Nevertheless, they must be removed before proceeding to manipulate the data as most of the functions for geometric operations require valid polygons. This problem can be easily solved by "buffering" all the polygons in each map. This creates new, valid borders for them. 

The maps of 1901— 1970 consist of multiple shapefiles. Files with "region" suffix contain the most of the information. Files with "Ellipse" suffix  contain a few circle shaped polygons which represent certain municipalities. I merged the two shapefiles into one. 

The new maps contain three variables: the name of the municipality,  municipality identifiaction number and polygon identification number.. The municipality level identifiation is not enough as some of the municipalities are repesented by multiple polygons.  

A more detailed version of the erros and how they were fixed, can be found at the end of this document. 

### 2.2 Errors and mistakes in the maps 

There are some mistakes in all of the first five maps. These mistakes are, but not limited to, overlapping of two polygons, mispelling or other way erroneously named polygons, and missing municipalities. It is important to identify and remove all mistakes in order to have valid outcome.  The multipliers in crosswalks are based on the area of the polygons. CONSTANT. This means that mistakes in the maps lead to mistakes in the crosswalks and in the constant areas. 

There are some easy ways to verify the correctness of the maps. For example, the programming language R contains many functions that can be used to verify if two or more poygons share common space. One of these operations checks whether a polygon lies completely within another polygon. One can also check for partial overlap but this results in a huge amount of very small partial overlaps, and I did not figure out a way of solving them. One potential way could be to calculate the area of the overlaps and filter them so that only bigger overlaps appear. 

A more difficult problems appears when the maps are corrects in geometrical sense but contain some historical inconsistencies. These problems cannot be found by simple lines of code. How I tried to verify the historical correctness was to create crosswalks and compare their results to the list of municipality mergers provided by Statistics Finland. Any inconsistencies between these two lists indicate a problem. I studied the borders of the problem area in each year and tried to identify the cause of the problem.

#### 2.2.1 Overlapping of the polygons

To identify complete overlaps I ran a code that tells whether a polygons lies completelty in another polygon. This allowed me to identify three types of errors. 

In the maps, some of the towns are represented by a circle. The most common overlap is due to the fact that this circle appears twice but with a different name. Almost in every case it relates to the fact that a new town was founded from the surrounding municipality. So one of the circles has the name of the new town and the other has the name of the surrounding municipality. In each case, I verified when the town was founded and deleted the incorrect circle accordingly. The information about the founding years can be found on the towns' Wikipedia pages. 

Another type of complete overlap is when the circle represeting a town is placed directly on top of the surrounding municipality's polygon.  This results in the double counting of the circle's area. This kind of a problem is solved by creating a new polygon for the surrounding municipality that has a "hole" for the circle town.  I assume that this problem has been tried to solve before as this could explain why the maps consist of multiple shapefiles. 

The third type of error is some of the municipalities appearing twice. These double entries seem to be completely identicial. Therefore this kind of a problem is easily solved by deleting either one of the double entries. 

#### 2.2.2 Other/historical  errors

The maps contain some historical inconsistencies. For example, some of the municipalities disappear in one year and reappear the following year. There are also some naming inconsistencies, for instance, two neighbourghing municipalities have each other's names instead of their own. 

  

## 3. Crosswalk files

 

Crosswalk files are based on the maps presented above. A crosswalk will tell how the borders of municipalities have changed between two years. The integral part of a crosswalk is the multiplier that it contains. This variable allows us to know wheter a municipality has merged to another,  either partially or entirely, or stayed the same. The multiplier is created by comparaing the areas of the intersections of the two maps to the first year municipalities' areas. A more detailed explanationis provided later.

An example: The city of Akaa was split in two parts in 1947. It was divided into two municipalities, Kylmäkoski and Toijala. Now if we compare the areas, we can see that 61% of Akaa was merged with Kylmäkoski. The remaining 39% was renamed as the municipality of Toijala.

 <img src="/Users/meeri/Duuni/kuntaR_git/example 1a.png" style="zoom:70%;" />  <img src="/Users/meeri/Duuni/kuntaR_git/example 1b.png" style="zoom:70%;" /> 

$$
\begin{aligned}
& \frac { 65 \ km^2}{107 \  km^2 }   =0,61

& \frac {42 \ km^2}{107 \ km^2 }  =0,39
\end{aligned}
$$



### 3.1 Filtering the crosswalk files

The crosswalk files contain a many observations whose multiplier is either very close to, or equals to zero.  It is extremely likely that such small values do not represent any actual changes in the borders of the municipalities. They are present in the data, as the borders are not exactly identical between the years. However, it is not straightforward to say what is "too small" of an change.I have excluded all of the observations that take values less than 1 percent. The user interface will allow the user to select their preferred filtering.  

### 3.2 Using the crosswalk files

In this section, I illustrate with examples how to use the crosswalk files.  The data used for this example contains three variables: the name of the municipality, municipality identification code and a random variable. As I don't have any real historical data, I generated random dataset that take values between 80 and 120. 



#### 3.2.1 Entirely merging municipality

This example illustrates a complete municipality merger. I have chosen the use the merging of the municipality of Uskela with the municipality of Salo in 1967.



*Fictional data of 1930* 

| **name_1930** | **id_1930** | **random_variable** |
| :------------ | ----------- | ------------------- |
| Uskela        | 571         | 112                 |
| Salo          | 237         | 100                 |

*Fictional data of 1970* 

| **name_1970** | **id_1970** | **random_variable** |
| ------------- | ----------- | ------------------- |
| Salo          | 237         | 94                  |

*Crosswalk for 1930 – 1970* 

| **name_1970** | **id_1970** | **name_1930** | **id_1930** | **multiplier** |
| ------------- | ----------- | ------------- | ----------- | -------------- |
| Salo          | 237         | Uskela        | 571         | 1              |
| Salo          | 237         | Salo          | 237         | 1              |

1. The first step is to merge the crosswalk with the 1930 data. As the merging variables one should use the variables "name_1930" and "id_1930"

 

*Crosswalk and the 1930 data:* 

| **name_1930** | **id_1930** | **random_variable** | **multiplier** | **name_1970** | **id_1970** |
| ------------- | ----------- | ------------------- | -------------- | ------------- | ----------- |
| Uskela        | 571         | 112                 | 1              | Salo          | 237         |
| Salo          | 237         | 100                 | 1              | Salo          | 237         |

2. Next group the data by the variables "name_1970" and "id_1970". Then multiply the values of  the random variable by the multiplier and sum them up. 

| **name_1970** | **id_1970** | **random_variable** |
| ------------- | ----------- | ------------------- |
| Salo          | 237         | 100*1 + 112*1 = 212 |



3. Now this can be merged with the 1970 data. The final outcome will look like this:

   

*1930 and 1970 data consistent with the municipalities in 1970:*

| **name** | **id** | **year** | **random_variable** |
| -------- | ------ | -------- | ------------------- |
| Salo     | 237    | 1930     | 212                 |
| Salo     | 237    | 1970     | 94                  |

 

#### 3.2.2 Partially merging municipality



The partial merger of an municipalitity works in the same priciple as the complete merger. Let us return to the first example.



*1930 data*

| **nimi_1930** | **id_1930** | **muuttuja** |
| ------------- | ----------- | ------------ |
| Akaa          | 001         | 82           |
| Kylmäkoski    | 421         | 97           |

*1970 data*

| **nimi_1970** | **id_1970** | **muuttuja** |
| ------------- | ----------- | ------------ |
| Kylmäkoski    | 421         | 101          |
| Toijala       | 562         | 118          |

*Crosswalk of 1930–1970:*

| **nimi_1930** | **id_1930** | **nimi_1970** | **id_1970** | **kerroin** |
| ------------- | ----------- | ------------- | ----------- | ----------- |
| Akaa          | 001         | Kylmäkoski    | 421         | 0,61        |
| Akaa          | 001         | Toijala       | 562         | 0,39        |
| Kylmäkoski    | 421         | Kylmäkoski    | 421         | 1,00        |

 

1. Again, the first step is to merge the crosswalk with the 1930 data. As the merging variables one should use the variables "name_1930" and "id_1930"

 

*Crosswalk  and the 1930 data:* 

| **nimi_1930** | **id_1930** | **muuttuja** | **kerroin** | **nimi_1970** | **id_1970** |
| ------------- | ----------- | ------------ | ----------- | ------------- | ----------- |
| Akaa          | 001         | 82           | 0,61        | Kylmäkoski    | 421         |
| Akaa          | 001         | 82           | 0,39        | Toijala       | 562         |
| Kylmäkoski    | 421         | 97           | 1,00        | Kylmäkoski    | 421         |

2. Next group the data by the variables "name_1970" and "id_1970". Then multiply the values of  the random variable by the multiplier and sum them up.

| **nimi_1970** | **id_1970** | **muuttuja**             |
| ------------- | ----------- | ------------------------ |
| Kylmäkoski    | 421         | $82*0,61 + 97*1 =147,02$ |
| Toijala       | 562         | $82*0,39 = 31,98$        |

3. Now this can be merged with the 1970 data. The final outcome will look like this:

   

*1930 and 1970 data consistent with the municipalities in 1970:*

| **nimi**     | **id** | **vuosi** | **muuttuja** |
| ------------ | ------ | --------- | ------------ |
| ”Kylmäkoski” | 421    | 1930      | 147          |
| ”Toijala”    | 562    | 1930      | 32           |
| Kylmäkoski   | 421    | 1970      | 212          |
| Toijala      | 562    | 1970      | 94           |





## 4. Consistent areas



The purpose of the consistent areas is to find such areas within which there are no changes in the municipality borders. This task could be done in many different ways, and as I am no algorithm desinger, mine is not the most elegant solution, but it seems to work. Next, I will present how the consistent area finding algorith works. I will use the evolution of Helsinki from 1910 to1970 as an example. 

The consistent areas are based on the crosswalk files presented above. I merged all the crosswalks into one big dataset.  The table below illustrates how Helsinki is presented in it.  Similarly as using the crosswalks, one has to choose the optimal filtering. For this purpose, I have decided to exlude all the observations whose multiplier is below 7 %. 



*A part of the dataset "kuntamuutokset_1860_2019.csv"*


| time      | name             | name_merged            | id   | Id_merged | multiplier | multiplier % |
| --------- | ---------------- | ---------------------- | ---- | --------- | ---------- | ------------ |
| 1910-1930 | Helsinki         | Helsinki               | 034  | 034       | 0.41957342 | 41.96        |
| 1910-1930 | Haaga            | Helsinki               | 333  | 034       | 0.07833964 | 7.83         |
| 1910-1930 | Huopalahti       | Helsinki               | 348  | 034       | 0.0891742  | 8.92         |
| 1910-1930 | Helsingin pitäjä | Helsinki               | 675  | 034       | 0.1255271  | 12.55        |
| 1910-1930 | Helsingin pitäjä | Helsingin pitäjä       | 675  | 675       | 0.9904906  | 99.05        |
| 1910-1930 | Oulunkylä        | Helsinki               | 472  | 034       | 0.1535952  | 15.36        |
| 1930-1970 | Helsinki         | Helsinki               | 034  | 034       | 0.87536887 | 87.54        |
| 1930-1970 | Helsinki         | Haaga                  | 034  | 333       | 1.00000000 | 100.00       |
| 1930-1970 | Helsinki         | Huopalahti             | 034  | 348       | 0.46449519 | 46.45        |
| 1930-1970 | Helsinki         | Brändön huvilakaupunki | 034  | 692       | 0.99999995 | 100.00       |
| 1930-1970 | Helsinki         | Helsingin pitäjä       | 034  | 675       | 0.36287831 | 36.29        |
| 1930-1970 | Helsinki         | Oulunkylä              | 034  | 472       | 1.00000000 | 100.00       |
| 1930-1970 | Helsingin mlk    | Helsingin pitäjä       | 696  | 675       | 0.6371212  | 63.71        |

The first thing that the algortim does is to group the data by the variable "id_merged". It then collects the id-numbers of the municipalites that the particular observation has changed borders with in a specific time period. It then takes all of these changes and keeps only the identical values. This is the variable "changes_all". The table below tells that there has been some changes in borders of Helsinki and 4 different other municipalities between years 1910 and 1970.

| name_merged            | Id_merged | changes_1910_1930       | changes_1930_1970 | changes_all             |
| ---------------------- | --------- | ----------------------- | ----------------- | ----------------------- |
| Helsinki               | 034       | 034, 333, 348, 675, 472 | 034               | 034, 333, 348, 675, 472 |
| Helsingin pitäjä       | 675       | 675                     | 034,  696         | 034,  696               |
| Haaga                  | 333       |                         | 034               | 034                     |
| Huopalahti             | 348       |                         | 034               | 034                     |
| Brändön huvilakaupunki | 692       |                         | 034               | 034                     |
| Oulunkylä              | 472       |                         | 034               | 034                     |

As a final step the algorithm goes trhough the variable "changes all", check if any of the observations share a common id number, if yes, it combines those observations and removes duplicates. This process is repeated so many times that the variable has the id-numbers appearing exaclty once. 

| Consistent_area | ids                          |
| --------------- | ---------------------------- |
| "Helsinki"      | 034, 333, 348, 675, 472, 696 |

*Helsinki 1910–1970:*

 <img src="/Users/meeri/Library/Application Support/typora-user-images/image-20191110220704579.png" alt="image-20191110220704579" style="zoom: 60%;" />  <img src="/Users/meeri/Library/Application Support/typora-user-images/image-20191110220634123.png" alt="image-20191110220634123" style="zoom: 60%;" />  <img src="/Users/meeri/Library/Application Support/typora-user-images/image-20191110220610891.png" alt="image-20191110220610891" style="zoom: 60%;" />



*1910 -1930 consistent Helsinki*

<img src="/Users/meeri/Library/Application Support/typora-user-images/image-20191110223506201.png" alt="image-20191110223506201" style="zoom:70%;" />






## Appendix

A more detailed list of how I fixed the errors. Unfortunately this part is still in Finnish.

#### Year 1860

| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Iisalmen maalaiskunta ja kaupunki  | Kartassa kaupunki ja maalaiskunta päällekkäin. Iisalmen kaupunki perustettiin vasta vuonna 1891 (kauppala 1860), jolloin se erotettiin ympäröivästä Iisalmen maalaiskunnasta. Kauppalana Iisalmi oli epäitsenäinen kauppala ja kuului Iisalmen maalaiskuntaan. Säilytetään maalaiskunta ja poistetaan kaupunkia kuvaava ympyrä. |
| Kemin maalaiskunta ja kaupunki     | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Kemin kaupunki perustettiin vasta vuonna 1869, joten poistetaan havainto Kemin kaupungista ja säilytetään vain maalaiskunta. Muutetaan myös kahden saaren nimet "Kemistä" "Kemin maalaiskunnaksi". |
| Nurmeksen maalaiskunta ja kaupunki | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Täysin itsenäinen ja erillisenä kauppalana toiminut Nurmeksen kauppala perustettiin vasta vuonna 1876. Säilytetään maalaiskunta ja poistetaan kaupunkia kuvaava ympyrä. |

  

#### Year 1901


| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Kymi ja Kotka         | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Kymistä erotettiin ensin Kotkan kaupunki vuonna 1879. Säilytetään Kotkan kaupunki, ja poistetaan Kymi-niminen ympyrä. |
| Kristiinankaupunki x2 | Kartassa on kaksi identtistä Kristiinankaupunkia kuvaavaa ympyrää. Poistetaan niistä toinen. |
| Messukylä & Tampere   | Kartassa nämä kuntaa kaupunkia ovat päällekkäin. Tampere perustettu 1700-luvulla ja Messukylä jo 1600-luvulla, joten säilytetään molemmat kunnat. Poistetaan vain se osa Messukylää, joka menee päällekkäin Tampereen kanssa. |
| Hamina & Vehkalahti   | Kartassa nämä kuntaa kaupunkia ovat päällekkäin. Kumpikin on perustettu jo kauan ennen vuotta 1901, joten säilytetään molemmat kunnat. Poistetaan vain se osa Vehkalahtea, joka menee päällekkäin Haminan kanssa. |

#### Year 1910


| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Pietarsaaren maalaiskunta ja kaupunki | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Kaupunki perustettu jo 1652, joten säilytetään Pietarsaaren kaupunki ja poistetaan maalaiskunnan ympyrä. |
| Iisalmen maalaiskunta ja kaupunki     | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Kaupunki perustettu vuonna 1891, joten säilytetään se. Poistetaan maalaiskunnan ympyrä. |
| Nurmeksen maalaiskunta ja kaupunki    | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Täysin itsenäinen ja erillisenä kauppalana toiminut Nurmeksen kauppala perustettiin vuonna 1876. Säilytetään kaupunki ja poistetaan maalaiskunnan ympyrä. |
| Kymi ja Kotka                         | Ks. edellinen vuosi.                                         |
| Lahti ja Hollola                      | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Lahti perustettiin vuonna 1878, säilytetään se ja poistetaan Hollola-niminen ympyrä. |
| Salo ja Uskela                        | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Salon kauppalasta tuli itsenäinen kunta vuonna 1891. Säilytetään Salo ja poistetaan Uskela-niminen ympyrä. |
| Kristiinankaupunki x2                 | Ks. edellinen vuosi.                                         |
| Messukylä & Tampere                   | Ks. edellinen vuosi.                                         |
| Hamina & Vehkalahti                   | Ks. edellinen vuosi.                                         |
| Vuolijoki                             | Kartassa on neljä suoraa, joilla on nimi "Vuolijoki". Kunta perustettiin kuitenkin vasta 1915, joten riittää, että poistetaan viivat. |



#### Year 1930

This map contains duplicates of some municipalities (type three error). The municipalities that appear twice are: 

> Jäppilä, Anttola, Haukivuori, Degerby, Somerniemi, Mietoinen, Pihlajavesi, Sahalahti, Viljakkala, Metsämaa, Vanaja, Kullaa, Jurva, Ylimarkku, Alaveteli, Teerijärvi, Hyvinkää,  Lohja, Koivisto, Pieksämäki

Other errors:

| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Kouvola ja Valkeala                 | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Kouvola irrotettiin vuonna 1922 Valkealan kunnasta, joten säilytetään se, ja poistetaan Valkeala-niminen ympyrä. |
| Valkeakoski ja Sääksmäki            | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Valkeakoski on perustettu vuonna 1923, joten säilytetään se, ja poistetaan Sääksmäki-niminen ympyrä. |
| Tuusula ja Kerava                   | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Kerava itsenäistyi Tuusulasta vuonna. 1924, joten säilytetään se, ja poistetaan Tuusula-niminen ympyrä. |
| Jaakkima ja Lahdenpohja             | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Lahdenpohja itsenäistyi Jaakkimasta vuonna 1924, joten säilytetään se, ja poistetaan Jaakkima-niminen ympyrä. |
| Grankulla ja Espoo                  | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Grankulla erosi Espoosta vuonna 1920 joten säilytetään se, ja poistetaan Espoo-niminen ympyrä. |
| Rovaniemen maalaiskunta ja kaupunki | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Rovaniemi itsenäistyi maalaiskunnasta vuonna 1929, joten säilytetään se, ja poistetaan maalaiskunnan ympyrä. |
| Karjaan maalaiskunta ja kaupunki    | Kartassa on kaksi kaupunkia kuvaavaa ympyrää. Karjaa itsenäistyi maalaiskunnasta 1930, joten säilytetään se, ja poistetaan maalaiskunnan ympyrä. |
| Kristiinankaupunki ja Tiukka        | Kartassa kaupunki ja sitä ympäröivä kunta päällekkäin. Kristiinankaupunki perustettiin jo 1600-luvulla, joten poistetaan se osa Tiukkaa, joka jää Kristiinankaupungin alle. |
| Hamina & Vehkalahti                 | Ks. vuosi 1901                                               |
| Pietarsaaren mlk ja kaupunki        | Kartassa kaupunki ja sitä ympäröivä maalaiskunta ovat päällekkäin. Pietarsaari perustettiin jo 1600-luvulla, joten poistetaan se osa maalaiskunnasta, joka jää kaupungin alle. Tämän lisäksi poistetaan kartasta Pietarsaari-niminen viiva. |



### Other inconsistencies


#### Year 1970

| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Sääksmäki ja Valkeakoski                 | Kuntien nimet ovat vaihtuneet keskenään vuoden 1970 kartassa. Vaihdetaan nimet oikeinpäin. |
| Uudenkaupungin mlk ja kaupunki / Pyhämaa | Vuoden 1970 kartassa ei ole ollenkaan Uudenkaupungin kaupunkia tai maalaiskuntaa. Niiden alueet on kartassa merkitty kuuluvan Pyhämaan kuntaan. Uudenkaupungin maalaiskunta liitettiin Uuteenkaupunkiin vuonna 1969, joten jaetaan pyhämaa kahteen. |



####  Year 1930


| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Kullaa ja Ulvila | Kuntien nimet ovat vaihtuneet keskenään vuoden 1930 kartassa. Vaihdetaan nimet oikeinpäin |
| Yli-Ii           | Yli-Iin nimi on kirjoitettu väärin vuoden 1930 kartassa. Korjataan oikeaan muotoon. |
| Uusikirkko       | Suomessa oli kaksi Uusikirkko-nimistä kuntaa. Ne erotettiin toisistaan kirjainlyhenteillä Tl ja Vl. Lisätään täsmennys vuoden 1930 karttaan. |



#### Year 1910


| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Uusikirkko | Ks. edellinen vuosi. |



#### Year 1901

| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Uusikirkko | Ks. vuosi 1930. |



#### Year 1860


| Kunta/kunnat | Ratkaisu |
| ------------ | -------- |
| Sonkajärvi ja Vieremä / Iisalmen mlk | Sonkajärven ja Vieremän kunnat on perustettu vasta 1922, joten niiden ei pitäisi esiintyä kartassa lainkaan. Muutetaan niiden nimeksi Iisalmen maalaiskunta. |


