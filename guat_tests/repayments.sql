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




-- 1) Count relevant fields

SELECT
	"Mambu"												AS db,
    COUNT(DUEDATE)										AS duedates,
    COUNT(DISTINCT DUEDATE)								AS distinct_dds,
	COUNT(encodedkey) - COUNT(DUEDATE)					AS null_dds,

	COUNT(PRINCIPALDUE)									AS prin_dues,
	COUNT(DISTINCT PRINCIPALDUE)						AS dist_pds,
    COUNT(encodedkey) - COUNT(PRINCIPALDUE)				AS null_pds,

	COUNT(PRINCIPALPAID)								AS prin_paids,
	COUNT(DISTINCT PRINCIPALPAID)						AS dist_pps,
	COUNT(encodedkey) - COUNT(PRINCIPALPAID)			AS null_pps,

	COUNT(INTERESTDUE)									AS int_dues,
	COUNT(DISTINCT INTERESTDUE)							AS dist_intds,
	COUNT(encodedkey) - COUNT(INTERESTDUE)				AS null_intds,

	COUNT(INTERESTPAID)									AS int_paids,
	COUNT(DISTINCT INTERESTPAID)						AS dist_ips,
	COUNT(encodedkey) - COUNT(INTERESTPAID)				AS null_ips,

	COUNT(FEESDUE)										AS fee_dues,
	COUNT(DISTINCT FEESDUE)								AS dist_fds,
	COUNT(encodedkey) - COUNT(FEESDUE)					AS null_fds,

	COUNT(FEESPAID)										AS fees_paids,
	COUNT(DISTINCT FEESPAID)							AS dist_fps,
	COUNT(encodedkey) - COUNT(FEESPAID)					AS null_fps,

	COUNT(PENALTYDUE)									AS pen_dues,
	COUNT(DISTINCT PENALTYDUE)							AS dist_pends,
	COUNT(encodedkey) - COUNT(PENALTYDUE)				AS null_pends,

	COUNT(PENALTYPAID)									AS pen_paid,
	COUNT(DISTINCT PENALTYPAID)							AS dist_penps,
	COUNT(encodedkey) - COUNT(PENALTYPAID)				AS null_penps,

	COUNT(REPAIDDATE)									AS repaiddates,
	COUNT(DISTINCT REPAIDDATE)							AS dist_rpds,
	COUNT(encodedkey) - COUNT(REPAIDDATE)				AS null_rpds,

	COUNT(LASTPAIDDATE)									AS last_paids,
	COUNT(DISTINCT LASTPAIDDATE)						AS dist_lps,
	COUNT(encodedkey) - COUNT(LASTPAIDDATE)				AS null_lps

FROM
	`guat`.repayment

UNION
(SELECT
	"Mifos"												AS db,
    COUNT(duedate)										AS duedates,
    COUNT(DISTINCT duedate)								AS distinct_dds,
	COUNT(id) - COUNT(duedate)							AS null_dds,

	COUNT(principal_amount)								AS prin_dues,
	COUNT(DISTINCT principal_amount)					AS dist_pds,
    COUNT(id) - COUNT(principal_amount)					AS null_pds,

	COUNT(principal_completed_derived)					AS prin_paids,
	COUNT(DISTINCT principal_completed_derived)			AS dist_pps,
	COUNT(id) - COUNT(principal_completed_derived)			AS null_pps,

	COUNT(interest_amount)								AS int_dues,
	COUNT(DISTINCT interest_amount)						AS dist_intds,
	COUNT(id) - COUNT(interest_amount)					AS null_intds,

	COUNT(interest_completed_derived)					AS int_paids,
	COUNT(DISTINCT interest_completed_derived)			AS dist_ips,
	COUNT(id) - COUNT(interest_completed_derived)		AS null_ips,

	COUNT(fee_charges_amount)							AS fee_dues,
	COUNT(DISTINCT fee_charges_amount)					AS dist_fds,
	COUNT(id) - COUNT(fee_charges_amount)				AS null_fds,

	COUNT(fee_charges_completed_derived)				AS fees_paids,
	COUNT(DISTINCT fee_charges_completed_derived)		AS dist_fps,
	COUNT(id) - COUNT(fee_charges_completed_derived)	AS null_fps,

	COUNT(penalty_charges_amount)						AS pen_dues,
	COUNT(DISTINCT penalty_charges_amount)				AS dist_pends,
	COUNT(id) - COUNT(penalty_charges_amount)			AS null_pends,

	COUNT(penalty_charges_completed_derived)			AS pen_paid,
	COUNT(DISTINCT penalty_charges_completed_derived)	AS dist_penps,
	COUNT(id) - COUNT(penalty_charges_completed_derived)	AS null_penps,

	COUNT(obligations_met_on_date)						AS repaiddates,
	COUNT(DISTINCT obligations_met_on_date)				AS dist_rpds,
	COUNT(id) - COUNT(obligations_met_on_date)			AS null_rpds,

	COUNT(lastmodified_date)							AS last_paids,
	COUNT(DISTINCT lastmodified_date)					AS dist_lps,
	COUNT(id) - COUNT(lastmodified_date)				AS null_lps

FROM
	`mifos-guat`.m_loan_repayment_schedule
)
;


-- 2) Totals of relevant money fields

SELECT
	"Mambu"												AS db,
	SUM(PRINCIPALDUE)									AS prin_dues,
	SUM(DISTINCT PRINCIPALDUE)							AS dist_pds,

	SUM(PRINCIPALPAID)									AS prin_paids,
	SUM(DISTINCT PRINCIPALPAID)							AS dist_pps,

	SUM(INTERESTDUE)									AS int_dues,
	SUM(DISTINCT INTERESTDUE)							AS dist_intds,

	SUM(INTERESTPAID)									AS int_paids,
	SUM(DISTINCT INTERESTPAID)							AS dist_ips,

	SUM(FEESDUE)										AS fee_dues,
	SUM(DISTINCT FEESDUE)								AS dist_fds,

	SUM(FEESPAID)										AS fees_paids,
	SUM(DISTINCT FEESPAID)								AS dist_fps,

	SUM(PENALTYDUE)										AS pen_dues,
	SUM(DISTINCT PENALTYDUE)							AS dist_pends,

	SUM(PENALTYPAID)									AS pen_paid,
	SUM(DISTINCT PENALTYPAID)							AS dist_penps
FROM
	`guat`.repayment

UNION
(SELECT
	"Mifos"												AS db,
	SUM(principal_amount)								AS prin_dues,
	SUM(DISTINCT principal_amount)						AS dist_pds,

	SUM(principal_completed_derived)					AS prin_paids,
	SUM(DISTINCT principal_completed_derived)			AS dist_pps,

	SUM(interest_amount)								AS int_dues,
	SUM(DISTINCT interest_amount)						AS dist_intds,

	SUM(interest_completed_derived)						AS int_paids,
	SUM(DISTINCT interest_completed_derived)			AS dist_ips,

	SUM(fee_charges_amount)								AS fee_dues,
	SUM(DISTINCT fee_charges_amount)					AS dist_fds,

	SUM(fee_charges_completed_derived)					AS fees_paids,
	SUM(DISTINCT fee_charges_completed_derived)			AS dist_fps,

	SUM(penalty_charges_amount)							AS pen_dues,
	SUM(DISTINCT penalty_charges_amount)				AS dist_pends,

	SUM(penalty_charges_completed_derived)				AS pen_paid,
	SUM(DISTINCT penalty_charges_completed_derived)		AS dist_penps
FROM
	`mifos-guat`.m_loan_repayment_schedule
)
;


-- 2) Do loans have the correct number of repayments?

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
		SELECT # the loan and the number of repayments under that loan (mifos). And the loan it came from in the other db.
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


-- 3) Do repayments match up (amount)?

SELECT 
	IF(r.principalpaid = mifos.principal_amount,
		"yes",
		"no")											AS matching
		#r.parentaccountkey)								AS matching
    ,COUNT(*)											AS count
FROM
	`guat`.repayment									AS r
	,(SELECT # each repayment's amount and the external id of the loan it goes to.
		m_l.external_id
        ,m_r.principal_amount # what if two repayments for the same loan have the same amount?
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


-- 4) Are they the same interest amount, etc?

SELECT
	IF(mambu.principaldue = mifos.principal_amount,
		"yes",
        "no")											AS prindue_matching
	,IF(mambu.principalpaid = mifos.principal_completed_derived,
		"yes",
        "no")											AS prinpaid_matching
	,IF(mambu.interestdue = mifos.interest_amount,
		"yes",
        "no")											AS intdue_matching
	,IF(mambu.interestpaid = mifos.interest_completed_derived,
		"yes",
        "no")											AS intpaid_matching
	,IF(mambu.feesdue = mifos.fee_charges_amount,
		"yes",
		"no")											AS feedue_matching
	,IF(mambu.feespaid = mifos.fee_charges_completed_derived,
		"yes",
		"no")											AS feepaid_matching
	,IF(mambu.penaltydue = mifos.penalty_charges_amount,
		"yes",
		"no")											AS penaltydue_matching
	,IF(mambu.penaltypaid = mifos.penalty_charges_completed_derived,
		"yes",
		"no")											AS penaltypaid_matching
	,IF(mambu.repaiddate = mifos.obligations_met_on_date,
		"yes",
		"no")											AS repaiddate_matching
	,IF(mambu.lastpaiddate = mifos.lastmodified_date,
		"yes",
		"no")											AS modifieddate_matching
	,COUNT(*)
FROM
	`guat`.repayment									AS mambu
	,(SELECT 
		m_l.external_id
        ,m_r.duedate
        ,m_r.principal_amount
        ,m_r.principal_completed_derived
        ,m_r.interest_amount
        ,m_r.interest_completed_derived
        ,m_r.fee_charges_amount
        ,m_r.fee_charges_completed_derived
        ,m_r.penalty_charges_amount
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
		mifos.external_id = mambu.parentaccountkey # the problem is many r. records have the same parentaccountkey, and many mifos. records have the same external_id. This will multiply the records a ton, plus they aren't matching to the correct record, they are matching to all the records with same key.
		AND
		mifos.duedate = mambu.duedate
GROUP BY
	prindue_matching
    ,prinpaid_matching
    ,intdue_matching
    ,intpaid_matching
    ,feedue_matching
    ,feepaid_matching
    ,penaltydue_matching
    ,penaltypaid_matching
    ,repaiddate_matching
    ,modifieddate_matching
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

