SELECT regimen_name,
	IF(Id is null, 0,SUM(IF(outcome = 'drug_count_1' AND Age >= 15,1,0))) AS "1 Month",
    IF(Id is null, 0,SUM(IF(outcome = 'drug_count_3' AND Age >= 15,1,0))) AS "3 Months",
    IF(Id is null, 0,SUM(IF(outcome = 'drug_count_6' AND Age >= 15,1,0))) AS "6 Months",
    IF(Id is null, 0,SUM(IF(outcome = 'drug_count_other' AND Age >= 15,1,0))) AS "Other"

FROM (

SELECT person_id as Id, regimen_name, outcome, Age

FROM
(select person_id, outcome, Age, 
case 
when ARV_regimen = 2201 then '1c=AZT-3TC-NVP'
when ARV_regimen = 2202 then '4c=AZT-3TC-NVP'
when ARV_regimen = 2203 then '1d=AZT-3TC-EFV'
when ARV_regimen = 2204 then '4d=AZT-3TC-EFV'
when ARV_regimen = 2205 then '1e=TDF-3TC-NVP'
when ARV_regimen = 2207 then '1f=TDF-3TC-EFV'
when ARV_regimen = 2209 then '2d=TDF-3TC-LPV/r'
when ARV_regimen = 2210 then '2c=AZT-3TC-LPV/r'
when ARV_regimen = 3672 then '1g=ABC-3TC-NVP'
when ARV_regimen = 3673 then '1h=ABC-3TC-EFV'
when ARV_regimen = 3674 then '2e=AZT-3TC-ATV/r'
when ARV_regimen = 3675 then '2f=TDF-3TC-ATV/r'
when ARV_regimen = 3676 then '2g=ABC-3TC-LPV/r'
when ARV_regimen = 3677 then '2h=ABC-3TC-ATV/r'
when ARV_regimen = 3678 then '2i=AZT-3TC-TDF-LPV/r'
when ARV_regimen = 3679 then '4e=ABC-3TC-NVP'
when ARV_regimen = 3680 then '4f=ABC-3TC-EFV'
when ARV_regimen = 3681 then '5a=AZT-3TC-LPV/r'
when ARV_regimen = 3682 then '5b=ABC-3TC-LPV/r'
when ARV_regimen = 3683 then '3a=RAL-3TC-LPV/r'
when ARV_regimen = 3684 then '3b=TDF-3TC-RAL-DRV/r'
when ARV_regimen = 3685 then '3c=RAL-EFV-DRV/r'
when ARV_regimen = 3686 then '6a=RAL-EFV-LPV/r'
when ARV_regimen = 3687 then '6b=RAL-EFV-DRV/r'
when ARV_regimen = 4678 then '1j=TDF-3TC-DTG'
when ARV_regimen = 4679 then '1k=ABC-3TC-DTG'
when ARV_regimen = 4680 then '1m=AZT-3TC-DTG'
when ARV_regimen = 4681 then '1n=TDF-3TC-LPV/r'
when ARV_regimen = 4682 then '1p=ABC-3TC-LPV/r'
when ARV_regimen = 4683 then '1q=AZT-3TC-LPV/r'
when ARV_regimen = 4684 then '4g=AZT-3TC-LPV/r'
when ARV_regimen = 4685 then '4h=ABC-3TC-LPV/r'
when ARV_regimen = 4686 then '4j=TDF-3TC-DTG (TLD)'
when ARV_regimen = 4687 then '4k=ABC-3TC-DTG'
when ARV_regimen = 4688 then '4l=AZT-3TC-DTG'
when ARV_regimen = 4689 then '2j=TDF-3TC-DRV/r'
when ARV_regimen = 4690 then '2k=ABC-3TC-DRV/r'
when ARV_regimen = 4691 then '2l=AZT-3TC-DRV/r'
when ARV_regimen = 4692 then '2m=TDF-3TC-RAL'
when ARV_regimen = 4693 then '2n=ABC-3TC-RAL'
when ARV_regimen = 4694 then '2o=AZT-3TC-RAL'
when ARV_regimen = 4695 then '2p=TDF-3TC-DTG'
when ARV_regimen = 4696 then '5c=ABC-3TC-DRV/r'
when ARV_regimen = 4697 then '5d=AZT-3TC-DRV/r'
when ARV_regimen = 4698 then '5e=AZT-3TC+ABC'
when ARV_regimen = 4699 then '5f=AZT-3TC-DTG'
when ARV_regimen = 4700 then '5g=AZT-3TC-ATV/r'
when ARV_regimen = 4701 then '5h=ABC-3TC-ATV/r'
when ARV_regimen = 4702 then '6c=RAL+ETV+DRV/r'
when ARV_regimen = 4703 then '6d=TDF-3TC-DRV/r+RAL'
when ARV_regimen = 4704 then '6e=RAL+DRV/r'
when ARV_regimen = 4705 then '6f=AZT+3TC+DRV/r+ETV'
when ARV_regimen = 4706 then '3d=TDF-DRV/r-RAL'
when ARV_regimen = 4707 then '3e=RAL-ETV/r-DRV/r'
when ARV_regimen = 4708 then '3f=DRV/r-DTG'
when ARV_regimen = 4709 then '3g=DRV/r-RAL'
when ARV_regimen = 4710 then '3h=LPV/r-RAL'
when ARV_regimen = 4849 then '2q=AZT-3TC-DTG'
when ARV_regimen = 4850 then '2r=ABC-3TC-DTG'
when ARV_regimen = 4851 then '2s=AZT-3TC-TDF-DTG'
when ARV_regimen = 2143 then 'Other'
else 'NewRegimen' end as regimen_name

FROM

(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen, 'drug_count_1' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen, 
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4175,4243))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4175,4243))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id

							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4175,4243))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id
                
UNION

-- 3 months supply
SELECT person_id as Id, ARV_regimen, outcome, Age
FROM( (
		SELECT person_id, ARV_regimen, outcome, Age 
					FROM( 
						SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen, 'drug_count_3' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4177))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4177))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id

                            LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4177))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id
								)regimen 
								) 
		UNION
		
		(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_3' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
					floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						 INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					
                 LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

                    )regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_3' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
					floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						 INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    )regimen
					)

UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_3' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
					floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4177
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4177
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4177
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	
)
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.person_id not in (
									select distinct(o.person_id)
									from obs o
									where o.person_id in (
											-- FOLLOW UPS
												select firstquery.person_id
												from
												(
												select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, max(oss.value_datetime) as latest_followup_obs
												from obs oss
															where oss.voided=0 
															and oss.concept_id=3752 
															and oss.obs_datetime <= CAST('#endDate#' AS DATE)
															and oss.obs_datetime > DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
															group by oss.person_id) firstquery
												inner join (
															select os.person_id,datediff(max(os.value_datetime), CAST('#endDate#' AS DATE)) as last_ap
															from obs os
															where concept_id = 3752
															and os.obs_datetime <= CAST('#endDate#' AS DATE)
															group by os.person_id
															having last_ap < 0
												) secondquery
												on firstquery.person_id = secondquery.person_id
									) and o.person_id in (
											-- TOUTS
											select distinct(person_id)
											from
											(
												select os.person_id, max(os.value_datetime) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('#endDate#' AS DATE)
											) as TOUTS
									)
		)
AND ARTCurrent_PrevMonths.person_id not in (
						-- Death
									select distinct p.person_id
									from person p
									where dead = 1
									and death_date <= CAST('#endDate#' AS DATE)		
										)
			
UNION
-- 6 months supply
SELECT person_id as Id, ARV_regimen, outcome, Age
FROM( (
		SELECT person_id, ARV_regimen, outcome, Age  
					FROM( 
						SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen, 'drug_count_6' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen,
                            floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
                             INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id

							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id
								)regimen 
								) 
		UNION
		
		(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id)regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                        INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

					)regimen
					)
	   
UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
					
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

					)regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
					
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
					
					)regimen
					)


UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
					
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
					
					)regimen
					)
UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4247
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4247
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					 LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4247
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id


	)regimen
	
)
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.person_id not in (
									select distinct(o.person_id)
									from obs o
									where o.person_id in (
											-- FOLLOW UPS
												select firstquery.person_id
												from
												(
												select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, max(oss.value_datetime) as latest_followup_obs
												from obs oss
															where oss.voided=0 
															and oss.concept_id=3752 
															and oss.obs_datetime <= CAST('#endDate#' AS DATE)
															and oss.obs_datetime > DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
															group by oss.person_id) firstquery
												inner join (
															select os.person_id,datediff(max(os.value_datetime), CAST('#endDate#' AS DATE)) as last_ap
															from obs os
															where concept_id = 3752
															and os.obs_datetime <= CAST('#endDate#' AS DATE)
															group by os.person_id
															having last_ap < 0
												) secondquery
												on firstquery.person_id = secondquery.person_id
									) and o.person_id in (
											-- TOUTS
											select distinct(person_id)
											from
											(
												select os.person_id, max(os.value_datetime) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('#endDate#' AS DATE)
											) as TOUTS
									)
		)
AND ARTCurrent_PrevMonths.person_id not in (
						-- Death
									select distinct p.person_id
									from person p
									where dead = 1
									and death_date <= CAST('#endDate#' AS DATE)		
										)
UNION

-- Other months supply

SELECT person_id as Id, ARV_regimen, outcome, Age
FROM( (
		SELECT person_id, ARV_regimen, outcome, Age 
					FROM( 
						SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen,'drug_count_other' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen,
                            floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
                             INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4176,4245,4246,4820))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4176,4245,4246,4820))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id
								
                            LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id

                                )regimen 
								) 
		UNION
		
		(SELECT person_id, ARV_regimen, outcome, Age
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                          INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4176,4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4176,4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4176,4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)
	   
UNION

(SELECT person_id, ARV_regimen, outcome, Age
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                          INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

                    )regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)


UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)

UNION
(SELECT person_id, ARV_regimen, outcome, Age
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)

UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

	)regimen
	)

UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                     INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4245
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4245
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4245
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	)
		   
UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4246
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4246
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4246
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	)
UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4820
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4820
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	)
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.person_id not in (
									select distinct(o.person_id)
									from obs o
									where o.person_id in (
											-- FOLLOW UPS
												select firstquery.person_id
												from
												(
												select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, max(oss.value_datetime) as latest_followup_obs
												from obs oss
															where oss.voided=0 
															and oss.concept_id=3752 
															and oss.obs_datetime <= CAST('#endDate#' AS DATE)
															and oss.obs_datetime > DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
															group by oss.person_id) firstquery
												inner join (
															select os.person_id,datediff(max(os.value_datetime), CAST('#endDate#' AS DATE)) as last_ap
															from obs os
															where concept_id = 3752
															and os.obs_datetime <= CAST('#endDate#' AS DATE)
															group by os.person_id
															having last_ap < 0
												) secondquery
												on firstquery.person_id = secondquery.person_id
									) and o.person_id in (
											-- TOUTS
											select distinct(person_id)
											from
											(
												select os.person_id, max(os.value_datetime) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('#endDate#' AS DATE)
											) as TOUTS
									)
		)
AND ARTCurrent_PrevMonths.person_id not in (
						-- Death
									select distinct p.person_id
									from person p
									where dead = 1
									and death_date <= CAST('#endDate#' AS DATE)		
										)
)txcurr_with_regimen)as Total_Patients_On_ART_with_Regimen) as Regimen_Report
Group by regimen_name
