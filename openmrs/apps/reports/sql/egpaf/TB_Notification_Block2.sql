select patient_type, 
	IF(id is null, 0,SUM(IF(outcome = '< 1',1,0))) AS "<1",
	IF(id is null, 0,SUM(IF(outcome = '1 - 4 yrs',1,0))) AS "1-4yrs",
	IF(id is null, 0,SUM(IF(outcome = '5 -9 yrs',1,0))) AS "5-9yrs",
    IF(id is null, 0,SUM(IF(outcome = '10 - 14 yrs',1,0))) AS "10-14yrs",
	IF(id is null, 0,SUM(IF(outcome = '15 - 19 yrs',1,0))) AS "15-19yrs",
	IF(id is null, 0,SUM(IF(outcome = '20 - 24 yrs',1,0))) AS "20-24yrs",
    IF(id is null, 0,SUM(IF(outcome = '25- 34 yrs',1,0))) AS "25-34yrs",
	IF(id is null, 0,SUM(IF(outcome = '35 - 44 yrs',1,0))) AS "35-44yrs",
	IF(id is null, 0,SUM(IF(outcome = '45 - 49 yrs',1,0))) AS "45-49yrs",
    IF(id is null, 0,SUM(IF(outcome = '50 - 54 yrs',1,0))) AS "50-54yrs",
	IF(id is null, 0,SUM(IF(outcome = '55 - 64 yrs',1,0))) AS "55-64yrs",
	IF(id is null, 0,SUM(IF(outcome = '65+ yrs',1,0))) AS "65+yrs",
  	IF(id is null, 0,SUM(1)) AS "Total"




from(
select id, outcome, patient_type
from
(    
    -- MALE NEW AND RELAPSE CLIENTS LIST
    ( 
        select distinct o.person_id as id, '< 1' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/30.4) < 12
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
									)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))				
    )
    UNION
    (
        select distinct o.person_id as id, '1 - 4 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 1year and 4years
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 1 and 4
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '5 -9 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 5 - 9years
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 5 and 9
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )
    UNION
    (
        select distinct o.person_id as id, '10 - 14 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 10 - 14 years
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 10 and 14
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '15 - 19 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 15 - 19 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 15 and 19
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '20 - 24 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 20 - 24 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 20 and 24

                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '25- 34 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 25 - 34 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 25 and 34
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '35 - 44 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 35 - 44 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 35 and 44
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )
    UNION
    (
        select distinct o.person_id as id, '45 - 49 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 45 - 49 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 45 and 49
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '50 - 54 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 50 - 54 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 50 and 54
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )
    UNION
    (
        select distinct o.person_id as id, '55 - 64 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 55 - 64  yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 55 and 64
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '65+ yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- Age between 65+ yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) >=65
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    -- MALE NEW AND RELAPSE CLIENTS LIST
    UNION
    ( 
        select distinct o.person_id as id, '< 1' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/30.4) < 12
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
    )
    UNION
    (
        select distinct o.person_id as id, '1 - 4 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- Age between 1year and 4years
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 1 and 4
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '5 -9 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- Age between 5 - 9years
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 5 and 9
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
    )
    UNION
    (
        select distinct o.person_id as id, '10 - 14 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- Age between 10 - 14 years
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 10 and 14
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
    )

    UNION
    (
        select distinct o.person_id as id, '15 - 19 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- Age between 15 - 19 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 15 and 19
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
    )

    UNION
    (
        select distinct o.person_id as id, '20 - 24 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- Age between 20 - 24 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 20 and 24

                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                inner join patient_identifier pi on pi.patient_id = o.person_id 
                and pi.identifier_type = 3
														AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

    )

    UNION
    (
        select distinct o.person_id as id, '25- 34 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- Age between 25 - 34 yrs
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 25 and 34
                and o.person_id in (
                                    -- New and Relapse Clients
                                    select distinct person_id
                                        from obs
                                        where concept_id = 3785
                                        and value_coded = 1034 or value_coded =1084
																				AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										)
                    inner join patient_identifier pi on pi.patient_id = o.person_id 
                    and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
        )

        UNION
        (
            select distinct o.person_id as id, '35 - 44 yrs' as outcome, 'Female' as patient_type
	    			from obs o inner join person p
                   on o.person_id = p.person_id 
                    and p.voided = 0 
                    and p.gender = 'F'
                    -- Age between 35 - 44 yrs
                    and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 35 and 44
                    and o.person_id in (
                                    -- New and Relapse Clients
                                        select distinct person_id
                                            from obs
                                            where concept_id = 3785
                                            and value_coded = 1034 or value_coded =1084
																					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
											)
                    inner join patient_identifier pi on pi.patient_id = o.person_id 
                    and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
        )
    UNION
        (
            select distinct o.person_id as id, '45 - 49 yrs' as outcome, 'Female' as patient_type
    				from obs o inner join person p
                    on o.person_id = p.person_id 
                    and p.voided = 0 
                    and p.gender = 'F'
                    -- Age between 45 - 49 yrs
                    and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 45 and 49
                   and o.person_id in (
                                        -- New and Relapse Clients
                                        select distinct person_id
                                            from obs
                                            where concept_id = 3785
                                            and value_coded = 1034 or value_coded =1084
																					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
											)
                    inner join patient_identifier pi on pi.patient_id = o.person_id 
                    and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
        )

        UNION
        (
            select distinct o.person_id as id, '50 - 54 yrs' as outcome, 'Female' as patient_type
		    		from obs o inner join person p
                    on o.person_id = p.person_id 
                    and p.voided = 0 
                    and p.gender = 'F'
                    -- Age between 50 - 54 yrs
                    and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 50 and 54
                    and o.person_id in (
                                        -- New and Relapse Clients
                                        select distinct person_id
                                            from obs
                                            where concept_id = 3785
                                            and value_coded = 1034 or value_coded =1084
																					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
											)
                    inner join patient_identifier pi on pi.patient_id = o.person_id 
                    and pi.identifier_type = 3
															AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

        )
        UNION
        (
            select distinct o.person_id as id, '55 - 64 yrs' as outcome, 'Female' as patient_type
		    		from obs o inner join person p
                    on o.person_id = p.person_id 
                    and p.voided = 0 
                    and p.gender = 'F'
                    -- Age between 55 - 64  yrs
                    and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 55 and 64
                    and o.person_id in (
                                        -- New and Relapse Clients
                                        select distinct person_id
                                            from obs
                                            where concept_id = 3785
                                            and value_coded = 1034 or value_coded =1084
																					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
											)
                    inner join patient_identifier pi on pi.patient_id = o.person_id 
                    and pi.identifier_type = 3
										AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
        )

        UNION
        (
            select distinct o.person_id as id, '65+ yrs' as outcome, 'Female' as patient_type
	    			from obs o inner join person p
                    on o.person_id = p.person_id 
                    and p.voided = 0 
                    and p.gender = 'F'
                    -- Age between 65+ yrs
                    and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) >=65
                    and o.person_id in (
                                        -- New and Relapse Clients
                                        select distinct person_id
                                            from obs
                                            where concept_id = 3785
                                            and value_coded = 1034 or value_coded =1084
																					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
											)
                        inner join patient_identifier pi on pi.patient_id = o.person_id 
                        and pi.identifier_type = 3
																AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

        )
) allDataRows
) pivotTable
group by patient_type
