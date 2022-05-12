DROP TABLE IF EXISTS @writeDatabaseSchema.@cohortTable;
DROP TABLE IF EXISTS @writeDatabaseSchema.@regimenTable;

CREATE TABLE @writeDatabaseSchema.@regimenTable (
       concept_name varchar,
       drug_era_id bigint,
       person_id bigint not null,
       rn bigint,
       drug_concept_id bigint,
       ingredient_start_date date not null,
       ingredient_end_date date
);
CREATE TABLE @writeDatabaseSchema.@cohortTable (
       concept_name varchar,
       drug_era_id bigint,
       person_id bigint not null,
       rn bigint,
       drug_concept_id bigint,
       ingredient_start_date date not null,
       ingredient_end_date date
);

insert into @writeDatabaseSchema.@cohortTable
with CTE_second as (
select
       lower(c.concept_name) as concept_name,
       de.drug_era_id,
       de.person_id,
       de.drug_concept_id,
       de.drug_era_start_date as ingredient_start_date,
       de.drug_era_end_date as ingredient_end_date
from @cdmDatabaseSchema.drug_era de
--inner join (
--select person_id, min(co.condition_start_date) as index_date
--from @cdmDatabaseSchema.condition_occurrence co
--left join @cdmDatabaseSchema.concept c on c.concept_id = co.condition_concept_id
--where co.condition_concept_id in (
--  SELECT descendant_concept_id AS condition_concept_id FROM @cdmDatabaseSchema.concept_ancestor ca1
--  WHERE ancestor_concept_id IN (36566990,36568015,36541443,42511865,36523730,36532469,36535903,36556071,36533471,44502466,36567589,36547447,36539680,36553840,42539251,36518808,36564140,44504617,36531818,36533160,36529611,36549209,36544817,36547617,36552762,44500348,36562787,36567485,4157454,44505020,36522620,36560935,4246121,44502390,36559870,36556001,36557999,36564925,36561870,44502105,36548690,44502045,36567582,37395649,36524343,36522910,36532553,36517887,44500188,36554751,36534932,44498940,36543337,36557873,45769094,36565786,36554642,36543689,36537547,45768923,36520970,36528207,36543016,36551466,36556975,4094876,44501404,36517990,44502676,36525541,36535086,44500865,4196724,37110033,36521732,44503114,44498975,44501559,36552316,36521727,44505014,36563971,42511704,44502589,36532707,36539370,44499882,44502334,36551018,36520718,36567431,36533751,36561490,42512108,44501471,4314172,44503124,44499741,44500448,36527049,37110031,44503115,36554435,36523412,42512532,36712981,42512060,36531398,44503018,44502711,36520389,36557593,36531338,36524541,36561387,44505033,36564508,36520980,36555975,36559186,36565196,36519142,40489468,36533461,36557711,44499623,44502921,36554446,44505002,36563600,4246027,36533303,36543749,36538201,36567060,44501794,36551506,42512867,36547720,36531856,36533365,44500561,36557751,4311499,42512043,36530167,36532710,36712816,36525925,36567491,36557444,44500647,4197583,36558320,44503138,36556937,36530787,42512265,36567131,44501124,36538830,36530632,36546635,36560854,4151250,44505006,36530340,36518535,36556242,36524452,36563157,36555703,36561406,36532630,44504990,36559641,36717017,44500201,44500183,44501104,36565504,36523740,36517443,42511724,44504995,4140471,36518073,36517187,44503150,36566657,36529692,4162248,44501871,44500001,36524303,36547246,36402603,44502510,36566445,36551621,44500061,44503136,45769035,44500541,4197581,36550669,36526133,36549522,36524183,36561708,45768917,36557506,42511673,44500568,4246805,45769096,44505018,36551342,37110034,42511775,36565831,36539497,36539290,36540571,36547511,36530501,36534747,44503093,36566443,44501438,254583,42512203,36522735,36550125,36553448,36523869,36565647,44501044,36548254,36524292,36518406,36544658,36561385,36541038,44502131,36555776,36554657,36548626,36523825,36544737,44503062,44499688,44501411,36565300,36567102,36561029,36531839,36550124,36547527,36534967,36532293,36567177,44505016,36545612,44499866,36518368,36523887,42512748,36517346,45769097,44499947,36565803,36565014,36520748,36524580,36562007,36530828,36550051,36548201,36534933,36523477,37397538,36522545,36524217,36523848,36540284,36534271,36567502,4092217,36554134,36539299,44499513,36545324,36526857,36537196,36524949,44501617,36539661,36550795,44505008,36716426,36550838,45772938,36552276,36560737,36530476,36559656,36551114,44500614,36561916,44505036,36529848,44499678,36564962,36536008,45768883,44502106,44504615,36566005,36558003,36520827,44502769,44499410,36530839,36526134,36523096,36541640,36558065,42512505,36517425,36557207,44505023,44500573,36526085,36530069,36567609,4092216,42512969,42512747,4112738,36559822,44505041,42511851,36544159,36686538,44499479,42512800,36526440,36525643,42512088,36540926,36529659,4110589,44501810,36545284,44500855,36558400,36518654,36523297,44502426,36560247,36561320,44501061,36564406,36537768,44505003,44501591,256646,44502772,45768886,36556065,36520252,36538582,36534332,36526672,36539842,44502456,36566440,36536903,36547997,42512083,36525269,42511824,42512380,36552074,44500072,36564562,36549370,36543187,36563697,45768918,36554991,36564528,36559237,36544421,4322387,36562844,4307118,36539915,36567811,36556168,36535558,36550952,36538464,36528414,36558877,36520679,36562092,36545668,44501966,36547241,4310448,42512634,42512199,36566035,36548216,44505019,36558610,44503537,4311501,36518168,36561198,36555661,42512258,42511960,36523821,36523265,4246126,36521546,36566369,36553640,36554807,44499941,36538391,44503152,44499422,36565506,42512146,4313200,44503204,36527832,36546243,36563234,40492938,44499438,36560499,45768881,44501310,36526200,44502764,36552458,36528608,36556766,45768927,36557259,36550205,36564894,36557406,36535081,44501926,36547355,36529368,36561068,36567381,36548325,36519174,36552471,44500542,36533515,44502329,36540740,36554594,36531901,44500048,36541362,36525709,36568076,258375,36526693,37109576,36549141,36521072,36565116,36547041,36556612,36520928,42512102,36543365,36555737,36527781,36548970,42511714,36542373,36519531,36560498,44501585,36522395,44505024,36538769,44500984,44500666,45768879,36551824,36528052,36543999,4115276,36519385,36526879,36533788,36538056,36529852,44500325,44500809,44500278,44502876,44503111,36550758,4110706,44505012,36559892,36521457,36712709,36557114,36560866,36521683,36533028,36567546,44500587,44501561,36529884,36525800,4110705,44505029,36541339,45768885,36561439,44502623,42511947,36540203,36551346,36546742,36542314,36526022,4089754,36525951,36518165,36557323,36565708,36527209,36535659,36402516,36556919,44499794,44502427,44499571,36527417,36555136,44502404,36551930,44505013,36531132,44505031,36531433,4246148,44500414,36519975,44502671,42512801,44500239,44500710,36533348,36565772,4208307,36531819,36547828,36539951,36549830,36712815,36526019,44501493,44501887,36551593,44499584,36542395,44500712,36537690,44503004,36517234,36533756,44505025,36556614,44500562,42511847,44501086,36550913,36528862,36550994,4247832,4089756,40391740,36560310,36523285,4312274,36543460,36525639,36520446,36528948,36552710,36556675,44501612,44500933,36526171,36546568,36542618,42512281,36537501,36532026,42511815,36546822,36528949,36567080,36544299,44502341,36539678,36536294,36518822,44502549,36534024,36544401,36403081,36529938,44505038,36517557,36559642,36536832,36517796,36526210,36540537,44499889,36561274,36550415,44500427,36548025,36533647,36540452,45768931,36558543,42512206,44500726,36524776,36525797,36564060,36560910,36537023,36552086,36525617,36540633,36526380,36526507,36563562,36537900,36563719,44499726,36543960,36540768,36524072,44500415,36521556,36526449,4312567,4110587,36533051,36528602,36529051,4143825,36519829,36525950,36529581,36525052,44499730,36561196,36548747,36530830,40490998,36566355,36552939,36542792,42512795,36532265,44499898,44505001,36564845,36533230,44500190,36532996,36532214,44502109,44500086,36524770,4196725,36545286,44499626,36550921,36536329,36535304,44500895,45768919,36522433,44499625,36562863,36529404,36519369,36555957,36518505,44499863,36536407,45768932,44500484,36544137,36564290,36533500,36557194,36552385,36562917,36529321,36533542,36557771,4313751,42512326,44499455,36556287,36562938,36539178,36540207,36523775,36519172,45768930,42512283,36525385,36536126,36555210,36529055,36527749,45769034,36518482,44501613,36560341,36560585,44500693,44499483,44499618,44501707,36518534,36556587,36546205,36560583,36518733,36557330,36540119,765056,4092218,36564790,36545575,44501827,36541243,36522077,36567622,36524711,36530558,44501191,36550225,36565448,45772933,44505037,36564670,36528907,44501516,36541057,45766131,36546410,44502943,36558515,36531543,36549565,36557068,36539223,44505005,42512188,36525066,36532742,36535016,4311997,44501916,36559151,36558216,44499915,42512777,36537874,44503034,44502909,36520186,42512246,36521578,42512336,36545323,36543925,44502142,36562795,36543198,36554873,36536720,42512093,36563105,36541263,44499010,36537041,42512168,36550920,36538432,36556624,36557572,36559321,36538626,36530431,42511643,36527811,36556317,36567225,44499670,36556267,45768921,45768884,36523843,36543150,36561424,36528191,44501709,44502199,42512167,44500114,42512616,36560318,44502949,44499007,36549979,36561652,44501388,44502320,36550031,36540262,36562643,36548457,44503098,4246804,36517751,36537594,44500841,36531136,36523415,36529691,42511197,36538858,36561699,36537646,443388,36529784,44500281,42512133,36552952,44499931,36551030,45769095,36522054,44499488,44505040,36540562,44502374,36527742,4314040,44498996,36527651,36525607,36542709,36522427,36527884,36558542,36544341,36529683,36521607,36553379,36522697,36552199,42511919,36535826,45768929,36567522,36540949,36549769,36526155,44504616,44505022,4312768,36528485,44500303,44500356,4110590,4197582,36539830,45772939,36547553,36545372,36535703,36560720,36553757,36686537,36554307,36546341,36563657,36532190,36560118,44502703,36546138,36536200,36532422,36557631,44500885,36566204,42512620,36559841,36541713,45768880,44500359,36518085,44502238,36517590,36544100,36521209,44500514,36712707,36521617,36554343,36518742,42512028,42511853,36533960,44505030,36526098,36527914,36562727,36534304,36529395,36525101,40492020,36529129,36551818,36559107,36527622,44498992,36543118,36566849,44501318,36520546,36531120,37395650,36536786,36531808,36518438,36526943,36538189,36537250,44501740,44502457,36522773,36525571,36544925,44503538,36518306,36560847,44499686,4310703,36556677,36523587,36530898,44501096,4162252,36566155,36549871,37395648,44502784,36538959,36537885,36541276,36543615,36518396,36562882,36556921,36536089,36543471,44501408,42511869,36524040,36546260,36561693,45768922,42511836,36540691,44504619,42512923,44504994,42512611,36518412,36553442,44502497,36716500,36562068,36542106,36529621,36551142,44500000,36563690,36530344,36537503,36525773,36566494,44505004,36559936,44501357,44502885,36529500,44505011,44500287,36559103,44505026,36532437,4247727,762427,36520977,42512781,36549159,36534701,36564548,36548230,36527609,36519544,44502176,36522061,36538987,44500971,44501567,36530423,36564176,36534648,36533436,36403024,44505027,36562581,36529915,45768928,36536486,36560811,44501360,762426,44501179,4308479,36548953,44505042,36522339,36549175,44502856,36566826,44499900,36544904,44500629,36539726,36542802,36555444,36527952,44499676,36555685,36553358,44505010,36548902,36527572,36713366,36537460,36545406,36529954,44501059,36525197,44499907,44501593,44505032,36528497,36530145,36556789,36542025,36546760,44502543,36535031,36562473,36545785,36546625,36552050,36535830,36560409,36551697,42512186,36403149,36519368,36532434,4111807,36528098,4155293,42512943,44500790,36517535,45768920,42511962,44500896,36532368,36553553,36541364,36537680,44502938,36559148,36554958,36520819,433973,36544914,36530953,258369,36557699,36546060,36542851,36546924,36553953,36540186,36537905,44505028,36560427,42512429,36548390,44505045,42511979,36553787,36531087,42512752,36563139,44503017,37395651,44501558,36526642,42512115,44501421,37110032,45768916,36538057,36518572,36564907,36519384,36526433,36531963,36548001,36712708,36535563,36559098,42512859,44500577,36548193,261236,4112739,36542965,44505021,36520808,36522366,36520293,36543984,36524730,36564097,36559568,44503010,46272955,36522300,36561922,36539786,36540813,36526753,36563418,44501807,4110591,4198434,36555448,36542148,36556450,36561629,44503531,44501791,36545242,36563276,45766129,36556298,36555882,36546119,42512758)
--/*  */
--)
--group by person_id
--) lc on lc.person_id = de.person_id on de.drug_era_start_date >= lc.index_date
inner join @cdmDatabaseSchema.concept_ancestor ca on ca.descendant_concept_id = de.drug_concept_id
inner join @cdmDatabaseSchema.concept c on c.concept_id = ca.ancestor_concept_id
    where c.concept_id in (
          select descendant_concept_id as drug_concept_id from @cdmDatabaseSchema.concept_ancestor ca1
          where ancestor_concept_id in (



          @drugClassificationIdInput


  ) )
and c.concept_class_id = 'Ingredient'
)
select cs.concept_name,
       cs.drug_era_id,
       cs.person_id ,
       c2.rn,
       cs.drug_concept_id,
       cs.ingredient_start_date,
       cs.ingredient_end_date
from CTE_second cs
inner join (select distinct person_id, row_number()over(order by person_id) rn from (SELECT distinct person_id FROM CTE_second) cs) c2 on c2.person_id = cs.person_id
;


insert into  @writeDatabaseSchema.@regimenTable
select *
from @writeDatabaseSchema.@cohortTable;



