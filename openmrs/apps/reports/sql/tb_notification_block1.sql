select patient_type, 
	IF(id is null, 0,SUM(IF(outcome = 'pulmonary_bacteria',1,0))) AS pulmonary_bacteria,
	IF(id is null, 0,SUM(IF(outcome = 'pulmonary_clinical',1,0))) AS pulmonary_clinical,
	IF(id is null, 0,SUM(IF(outcome = 'extra_pulmonary',1,0))) AS extra_pulmonary
    
FROM ( select id, outcome, patient_type
		from (

	(select distinct o.person_id as id, 'pulmonary_bacteria' as outcome, 'new_client' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded = 1034)
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- pulmonary bacterialogically tested 
                where concept_id = 3788 and value_coded = 1018
				and o.person_id in (select person_id from obs where concept_id in (3815, 3814))
)
UNION
(
select distinct o.person_id as id, 'pulmonary_bacteria' as outcome, 'relapse' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded = 1084)
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- pulmonary bacterialogically tested 
                where concept_id = 3788 and value_coded = 1018
				and o.person_id in (select person_id from obs where concept_id in (3815, 3814))
)
UNION
(
select distinct o.person_id as id, 'pulmonary_bacteria' as outcome, 'retreatment' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded in (3786,1037))
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- pulmonary bacterialogically tested 
                where concept_id = 3788 and value_coded = 1018
				and o.person_id in (select person_id from obs where concept_id in (3815, 3814))	
				
				
				
)
UNION
-- pulmonary clinically
(select distinct o.person_id as id, 'pulmonary_clinical' as outcome, 'new_client' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded = 1034)
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- pulmonary clinically confirmed
                where ((concept_id = 3787 and value_coded = 3820)
                        or (concept_id = 3805 and value_coded = 1738)
                        or (concept_id = 3840 and value_coded = 1016))
)
UNION
(
select distinct o.person_id as id, 'pulmonary_clinical' as outcome, 'relapse' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded = 1084)
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- pulmonary clinically confirmed
                where ((concept_id = 3787 and value_coded = 3820)
                        or (concept_id = 3805 and value_coded = 1738)
                        or (concept_id = 3840 and value_coded = 1016))
)
UNION
(
select distinct o.person_id as id, 'pulmonary_clinical' as outcome, 'retreatment' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded in (3786,1037))
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- pulmonary clinically confirmed
                where ((concept_id = 3787 and value_coded = 3820)
                        or (concept_id = 3805 and value_coded = 1738)
                        or (concept_id = 3840 and value_coded = 1016))
		)
UNION
-- extra pulmonary 
(select distinct o.person_id as id, 'extra_pulmonary' as outcome, 'new_client' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded = 1034)
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- extra pulmonary bacterialogically/clinically tested 
                where concept_id = 3788 and value_coded = 2233
)
UNION
(
select distinct o.person_id as id, 'extra_pulmonary' as outcome, 'relapse' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded = 1084)
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- extra pulmonary bacterialogically/clinically tested  
                where concept_id = 3788 and value_coded = 2233
)
UNION
(
select distinct o.person_id as id, 'extra_pulmonary' as outcome, 'retreatment' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id and p.voided = 0 and o.person_id in (
					select person_id from obs 
                    -- new tb patients
                    where concept_id = 3785
					and value_coded in (3786,1037))
				inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
				-- extra pulmonary bacterialogically/clinically tested  
                where concept_id = 3788 and value_coded = 2233


	)
 )AS tb1
) AS tb
group by patient_type