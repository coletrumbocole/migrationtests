-- -----------------
-- Tests for Loan Transaction
-- -----------------


SELECT * FROM `mifos-guat`.m_loan_transaction;
SELECT * FROM `guat`.loantransaction;

SHOW COLUMNS FROM `mifos-guat`.m_loan_transaction;
SHOW COLUMNS FROM `guat`.loantransaction;


SELECT * FROM `mifos-guat`.m_payment_detail; # just id and payment type. HThis id is referenced in m_loan_transaction


-- see if mambu matches up with mifos
# same number of records
# same unique ids
#etc.


-- 1) count relevant fields

SELECT
	"Mambu"													AS data_source,

	COUNT(ENTRYDATE)										AS transactiondates,
	COUNT(DISTINCT ENTRYDATE)								AS dist_tds,
    COUNT(encodedkey) - COUNT(ENTRYDATE) 					AS null_tds,

	COUNT(AMOUNT)											AS amounts,
	COUNT(DISTINCT AMOUNT)									AS dist_amts,
    COUNT(encodedkey) - COUNT(AMOUNT)						AS null_amts,

    COUNT(PRINCIPALAMOUNT)									AS principals,
	COUNT(DISTINCT PRINCIPALAMOUNT)							AS dist_prins,
    COUNT(encodedkey) - COUNT(PRINCIPALAMOUNT)				AS null_prins,

    COUNT(INTERESTAMOUNT)									AS interests,
    COUNT(DISTINCT INTERESTAMOUNT)							AS distinct_ints,
    COUNT(encodedkey) - COUNT(INTERESTAMOUNT) 				AS null_ints,

	COUNT(FEESAMOUNT)										AS fees,
	COUNT(DISTINCT FEESAMOUNT)								AS distinct_fees,
	COUNT(encodedkey) - COUNT(FEESAMOUNT)					AS null_fees,

	COUNT(PENALTYAMOUNT)									AS penalties,
	COUNT(DISTINCT PENALTYAMOUNT)							AS dist_pts,
    COUNT(encodedkey) - COUNT(PENALTYAMOUNT)				AS null_pts,

	COUNT(BALANCE)											AS balances,
	COUNT(DISTINCT BALANCE)									AS dist_bals,
    COUNT(encodedkey) - COUNT(BALANCE) 						AS null_bals,

    COUNT(creationdate)										AS creationdates,
	COUNT(DISTINCT creationdate)							AS dist_crdates,
    COUNT(encodedkey) - COUNT(creationdate) 				AS null_crdates
FROM
	`guat`.loantransaction

UNION
SELECT
	"Mifos"													AS data_source,

	COUNT(transaction_date)									AS transactiondates,
	COUNT(DISTINCT transaction_date)						AS dist_tds,
    COUNT(*) - COUNT(transaction_date) 						AS null_tds,

	COUNT(AMOUNT)											AS amounts,
	COUNT(DISTINCT AMOUNT)									AS dist_amts,
    COUNT(*) - COUNT(AMOUNT)								AS null_amts,

    COUNT(principal_portion_derived)						AS principals,
	COUNT(DISTINCT principal_portion_derived)				AS dist_prins,
    COUNT(*) - COUNT(principal_portion_derived)				AS null_prins,

    COUNT(interest_portion_derived)							AS interests,
    COUNT(DISTINCT interest_portion_derived)				AS distinct_ints,
    COUNT(*) - COUNT(interest_portion_derived)				AS null_ints,

	COUNT(fee_charges_portion_derived)						AS fees,
	COUNT(DISTINCT fee_charges_portion_derived)				AS distinct_fees,
	COUNT(*) - COUNT(fee_charges_portion_derived)			AS null_fees,

	COUNT(penalty_charges_portion_derived)					AS penalties,
	COUNT(DISTINCT penalty_charges_portion_derived)			AS dist_pts,
    COUNT(*) - COUNT(penalty_charges_portion_derived)		AS null_pts,

	COUNT(outstanding_loan_balance_derived)					AS balances,
	COUNT(DISTINCT outstanding_loan_balance_derived)		AS dist_bals,
    COUNT(*) - COUNT(outstanding_loan_balance_derived)		AS null_bals,

    COUNT(created_date)										AS creationdates,
	COUNT(DISTINCT created_date)							AS dist_crdates,
    COUNT(*) - COUNT(created_date) 							AS null_crdates
FROM
	`mifos-guat`.m_loan_transaction
;


-- 2) see if every loan balance matches the most recent transaction balance

#problems: if two transactions happen at the same time, which is more recent?
-- # this will check within Mambu only.
-- SELECT
-- #    AVG(l.principalbalance)								AS avg_bal
-- #    ,AVG(ltd.balance)									AS avg_bal_t
--     IF(l.principalbalance = lt.balance,
-- 		"yes",
--         "no")											AS matching
-- 	,COUNT(*)											AS count
-- FROM # every loan in loanaccount joined to its most recent transaction.
--     `guat`.loanaccount									AS l
-- 
-- 	LEFT JOIN
-- 		(SELECT
-- 			parentaccountkey
-- 			,MAX(entrydate)
-- 		FROM
-- 			`guat`.loantransaction						AS lt1
-- 
-- 			LEFT JOIN
-- 				`guat`.loantransaction					AS lt2
-- 				ON lt1.encodedkey = lt2.encodedkey
-- 		)												AS lt
-- 	ON
-- 		l.encodedkey = lt.parentaccountkey
-- GROUP BY
-- 	matching
-- ;
-- #MIFOS
-- SELECT
--     IF(l.principal_outstanding_derived = lbd.bal,
-- 		"yes",
--         "no")											AS matching
-- 	,COUNT(*)											AS count
-- FROM
-- 	# every loan in loanaccount
--     # joined to its most recent transaction.
--     `mifos-guat`.m_loan									AS l
--     
--     LEFT JOIN
-- 		(SELECT
-- 			loan_id
--             ,outstanding_loan_balance_derived			AS bal # this value won't necessarily be from the same record as the max date.
--             ,MAX(transaction_date)						AS `date` #but just because I ask for the MAX here, does that mean I'll get the loan_id and bal that correspond?
-- 		FROM
-- 			`mifos-guat`.m_loan_transaction
-- 		GROUP BY loan_id
-- 		)												AS lbd
-- 	ON
-- 		l.id = lbd.loan_id
-- GROUP BY
-- 	matching
-- ;
-- 


-- 3) see if transactions total to the same as loans.

	#basically I'm checking to see that the total disbursed as seen in the loans is the same as the total disbursed as seen in the transactions.
SELECT
	(SELECT
		SUM(amount)
	FROM
		`mifos-guat`.m_loan_transaction
	WHERE
		transaction_type_enum = 1
	)													AS tot_m_t
	,(SELECT
		SUM(principal_disbursed_derived)
	FROM
		`mifos-guat`.m_loan
	)													AS tot_m_l
	,(SELECT SUM(principalamount)
	FROM `guat`.loantransaction
	WHERE `type` = 'DISBURSMENT' AND reversaltransactionkey is null # It’s null if the transaction wasn’t reversed.
-- 
-- 		(SELECT SUM(principalamount)
-- 		FROM `guat`.loantransaction
-- 		WHERE `type` = 'DISBURSMENT')
--         -
--         (SELECT SUM(principalamount)
-- 		FROM `guat`.loantransaction
-- 		WHERE `type` = 'DISBURSMENT' AND reversal_id is not null)
	)													AS tot_lt
	,(SELECT
		SUM(loanamount)
	FROM
		`guat`.loanaccount
	)													AS tot_l
;

-- 4) see if every loan has a disbursement transaction

	# why is this a test? I shouldn't expect every loan to be disbursed.
	# or if I'm trying to only look at loans that are supposed to be disbursed, how do I know which ones are supposed to be disbursed?

SELECT
# count of loans with disbursement
# count of loans that didn't
# count of disbursement transactions that didn't match a loan
# count of disb. trans. that its loan doesn't say disbursed.
	'Mambu'								AS src
	,COUNT(DISTINCT l.encodedkey)		AS loans
	,COUNT(DISTINCT lt.parentaccountkey)	AS loan_disbursements
    ,SUM(l.loanamount)					AS disbursed_loans
	,SUM(lt.amount)										AS disbursed_transactions
FROM
# all loans that say they have a disbursement in loanaccount
# all transactions that are type disbursement.
	`guat`.loanaccount	 								AS l

LEFT JOIN
	(
		SELECT
			parentaccountkey,
            amount
        FROM
			`guat`.loantransaction
        WHERE `type` = 'DISBURSMENT'
    )									AS  lt
    ON l.ENCODEDKEY = lt.parentaccountkey

UNION
SELECT
	'Mifos'								AS src
	,COUNT(DISTINCT l.id)				AS loans
	,COUNT(DISTINCT lt.loan_id)			AS loan_disbursements
    ,SUM(l.principal_disbursed_derived)	AS disbursed_loans
	,SUM(lt.amount)						AS disbursed_transactions
FROM
	`mifos-guat`.m_loan 		AS l
    
LEFT JOIN
	(
		SELECT
			loan_id,
            amount
        FROM
			`mifos-guat`.m_loan_transaction
        WHERE transaction_type_enum = 1
    )									AS  lt
    ON l.id = lt.loan_id
;


-- 5) see if disbursed amount matches up


-- 6) how many didn't even have a disbursement


-- 7) see if principal and interest total to the same thing.

# total disbursements ?= total principal amount
# total repaymeny ?= total repaid_derived
# etc
