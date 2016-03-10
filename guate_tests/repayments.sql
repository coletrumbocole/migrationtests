-- -----------------
-- Tests for Loan Repayment History
-- -----------------

#SELECT * FROM `mifos-guat`.m_payment_detail; # just id and payment type. HThis id is referenced in m_loan_transaction

SELECT * FROM `guat`.repayment;
SHOW COLUMNS FROM `guat`.repayment;
show create table `guat`.repayment;


SELECT * FROM `mifos-guat`.m_loan_repayment_schedule;
SHOW COLUMNS FROM `mifos-guat`.m_loan_repayment_schedule;

-- What should I expect to be different from one db to another?






-- 1) Do loans have the correct number of repayments?

SELECT
	mambu.parentaccountkey
    ,mambu.repayments
    ,mifos.rpymnts
    ,IF(mambu.repayments = mifos.rpymnts,
		"yes",
		mambu.parentaccountkey)							AS matching
    ,COUNT(*)											AS count
FROM
	(
		SELECT # the loan and the number of repayments under that loan.
			parentaccountkey
			,COUNT(*)									AS repayments
		FROM
			`guat`.repayment
 		GROUP BY
			parentaccountkey
	)													AS mambu
	,(
		SELECT # the loan and the number of repayments under that loan. And the loan it came from in the other db.
			m_r.loan_id
			,COUNT(m_r.id)								AS rpymnts
			,m_l.external_id
		FROM # the loans and the repayment that corresponds.
			`mifos-guat`.m_loan_repayment_schedule		AS m_r
			,(
				SELECT
					external_id
					,id
				FROM
					`mifos-guat`.m_loan
			)											AS m_l
		WHERE
			m_r.loan_id = m_l.id
        GROUP BY
			m_r.loan_id # or if I want to see how many repaymnets are attached to the mambu loan: m_l.external_id
	)													AS mifos
WHERE
	mambu.parentaccountkey = mifos.external_id
GROUP BY
	matching
; #yes 2933


-- 2) Do repayments match up (amount)?

SELECT 
	IF(r.principalpaid = mifos.principal_amount,
		"yes",
        "no")											AS matching
		#r.parentaccountkey)								AS matching
    ,COUNT(*)											AS count
FROM
	`guat`.repayment									AS r
	,(SELECT 
		m_l.external_id
        ,m_r.principal_amount
	FROM
		`mifos-guat`.m_loan_repayment_schedule			AS m_r
	
		LEFT JOIN
			`mifos-guat`.m_loan							AS m_l
		ON
			m_r.loan_id = m_l.id
	)													AS mifos
WHERE
		mifos.external_id = r.parentaccountkey
GROUP BY
	matching
ORDER BY
	count DESC
;


-- 3) Are they the same interest amount, etc?

SELECT
	IF(r.principalpaid = mifos.principal_completed_derived,
		"yes",
        "no")											AS prin_matching
	,IF(r.interestpaid = mifos.interest_completed_derived,
		"yes",
        "no")											AS int_matching
	,IF(r.duedate = mifos.duedate,
		"yes",
		"no")											AS duedate_matching
	,IF(r.feespaid = mifos.fee_charges_completed_derived,
		"yes",
		"no")											AS fee_matching
	,IF(r.penaltypaid = mifos.penalty_charges_completed_derived,
		"yes",
		"no")											AS penalty_matching
	,IF(r.repaiddate = mifos.obligations_met_on_date,
		"yes",
		"no")											AS repaid_matching
	,IF(r.lastpaiddate = mifos.lastmodified_date,
		"yes",
		"no")											AS modified_matching
	,COUNT(*)
FROM
	`guat`.repayment									AS r
	,(SELECT 
		m_l.external_id
        ,m_r.principal_completed_derived
        ,m_r.interest_completed_derived
        ,m_r.duedate
        ,m_r.fee_charges_completed_derived
        ,m_r.penalty_charges_completed_derived
        ,m_r.obligations_met_on_date
        ,m_r.lastmodified_date
	FROM
		`mifos-guat`.m_loan_repayment_schedule			AS m_r
	
		LEFT JOIN
			`mifos-guat`.m_loan							AS m_l
		ON
			m_r.loan_id = m_l.id
	)													AS mifos
WHERE
		mifos.external_id = r.parentaccountkey
GROUP BY
	prin_matching
    ,int_matching
    ,duedate_matching
    ,fee_matching
    ,penalty_matching
    ,repaid_matching
    ,modified_matching
;


-- Are the same ones repaid/not?



-- --------------------------------------------------------
-- by field


-- id
# see if Fineract has repeat values

SELECT 
	COUNT(distinct id)							AS distinct_id_count
    ,COUNT(id)									AS id_count
	,IF(COUNT(distinct id) = COUNT(id), 
		"Equal", 
        "Not Equal")							AS equal
FROM `mifos-guat`.m_loan_repayment_schedule
;

show columns FROM `mifos-guat`.m_loan_repayment_schedule;
show columns FROM `mifos-guat`.m_loan_repayment_schedule_history;

select * FROM `mifos-guat`.m_loan_repayment_schedule_history;


-- loan_id
# see if each loan_id corresponds to the correct loan

# maybe look at the repayment's corresponding loan, then see if

