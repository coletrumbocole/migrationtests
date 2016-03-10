-- -----------------
-- Tests for Loan Repayment History
-- -----------------

#SELECT * FROM `mifostenant-default`.m_payment_detail; # just id and payment type. HThis id is referenced in m_loan_transaction

SELECT * FROM `phil`.repayment;
SHOW COLUMNS FROM `phil`.repayment;
show create table phil.repayment;


SELECT * FROM `mifostenant-default`.m_loan_repayment_schedule;
SHOW COLUMNS FROM `mifostenant-default`.m_loan_repayment_schedule;

# Since there are so many records, I'll try to break it up by staff.


-- CREATE VIEW m_loan_repayment_schedule_sta_cruz
-- AS
-- (
-- 	SELECT 
-- 	* 
--     FROM `mifostenant-default`.m_loan_repayment_schedule
-- 	WHERE 
-- ;
-- 
-- 
-- CREATE VIEW m_loan_repayment_schedule_davao
-- CREATE VIEW m_loan_repayment_schedule_maco
-- CREATE VIEW m_loan_repayment_schedule_pasig
-- CREATE VIEW m_loan_repayment_schedule_mandaluyong
-- CREATE VIEW m_loan_repayment_schedule_quezon_city
-- CREATE VIEW m_loan_repayment_schedule_caloocan
-- CREATE VIEW m_loan_repayment_schedule_san_mateo
-- CREATE VIEW m_loan_repayment_schedule_antipolo
-- CREATE VIEW m_loan_repayment_schedule_manila
-- CREATE VIEW m_loan_repayment_schedule_malabon
-- CREATE VIEW m_loan_repayment_schedule_san_jose_del_monte
-- CREATE VIEW m_loan_repayment_schedule_paranaque
-- CREATE VIEW m_loan_repayment_schedule_mandaue
-- CREATE VIEW m_loan_repayment_schedule_talisay
-- 
-- ;
-- 

-- What should I expect to be different from one db to another?






-- Do loans have the correct number of repayments?

SELECT
	parentaccountkey
    ,mambu.repayments
    ,mifos.rpymts
    ,IF(mambu.repayments = mifos.rpymts, "yes", "no")			AS matching
FROM
	(
		SELECT # the loan and the number of repayments under that loan.
			parentaccountkey
			,COUNT(*)									AS repayments
		FROM
			`phil`.repayment
 		GROUP BY
			parentaccountkey
	)													AS mambu
	,(
		SELECT # the loan and the number of repayments under that loan. And the loan it came from in the other db.
			m_r.loan_id
            ,COUNT(m_r.id)								AS rpymts
            ,m_l.external_id
		FROM # the loans and the repayment that corresponds.
			`mifostenant-default`.m_loan_repayment_schedule AS m_r
			,(
				SELECT
					external_id
					,id
				FROM
					`mifostenant-default`.m_loan
			)											AS m_l
		WHERE
			m_r.loan_id = m_l.id
        GROUP BY
			m_r.loan_id # or if I want to see how many repaymnets are attached to the mambu loan: m_l.external_id
	)													AS mifos
WHERE
	mambu.parentaccountkey = mifos.external_id
	AND
    mambu.repayments <> mifos.rpymts
;


-- Do repayments match up?
# there's no external_id to link between the two dbs. You have to match the repayments to their loans and use the loan's external_id, and the repayment's installment to distinguish from one repayment to another and match.
SELECT 
	*
FROM
	phil.repayment										AS r

    LEFT JOIN
		phil.loanaccount								AS l
	ON
		r.parentaccountkey = l.encodedkey
;
SELECT 
*
FROM
	`mifostenant-default`.m_loan_repayment_schedule		AS r

    LEFT JOIN
		`mifostenant-default`.m_loan					AS l
	ON
		r.loan_id = l.id
;


-- Are they the same principal amount, interest amount, etc?


-- Are the same ones repaid/not?


-- Do the dates match up?


-- -----------------
-- by field


-- id
# see if Fineract has repeat values

SELECT 
	COUNT(distinct id)							AS distinct_id_count
    ,COUNT(id)									AS id_count
	,IF(COUNT(distinct id) = COUNT(id), "Equal", "Not Equal") AS equal
FROM `mifostenant-default`.m_loan_repayment_schedule
;

-- loan_id
# see if each loan_id corresponds to the correct loan

# maybe look at the repayment's corresponding loan, then see if

