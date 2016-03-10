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


-- see if every loan balance matches the most recent transaction balance

SELECT
	# loan balance on loan
	# loan balance on most recent transaction of loan
	# matching
	# count
    l.principalbalance
    ,ltd.balance
    ,IF(l.principalbalance = ltd.balance,
		"yes",
        "no")											AS matching
	,COUNT(*)
FROM
	# every loan in loanaccount
    # joined to its most recent transaction.
    `guat`.loanaccount									AS l
    
    LEFT JOIN
		(SELECT
			parentaccountkey
            ,balance
            ,MAX(entrydate)
		FROM
			`guat`.loantransaction
		GROUP BY parentaccountkey
		)												AS ltd
	ON
		l.encodedkey = ltd.parentaccountkey
GROUP BY
	matching
;

-- see if transactions total to the same as loans.

-- see if disbursed amount matches up
-- how many didn't even have a disbursement
-- did loan have correct number of transactions?
-- Do loans have the correct number of repayments?

-- see if principal and interest total to the same thing.




-- junk

SELECT
	COUNT(*)
FROM
	`mifos-guat`.m_loan_transaction;
;

SELECT 
	COUNT(*) 
FROM 
	`guat`.loantransaction
;

SELECT
	CREATIONDATE,
    ENTRYDATE,
    PRINCIPALAMOUNT,
    INTERESTAMOUNT,
    FEESAMOUNT,
    PENALTYAMOUNT,
    AMOUNT,
    BALANCE
    
FROM
    `guat`.loantransaction
#where creationdate >= entrydate #21630
;

SELECT
	transaction_date,
    submitted_on_date,
    created_date,
    principal_portion_derived,
    interest_portion_derived,
    fee_charges_portion_derived,
    penalty_charges_portion_derived,
    amount,
    outstanding_loan_balance_derived
    
FROM
	`mifos-guat`.m_loan_transaction;
;

SELECT
	SUM(principalamount)					AS tot_prin
	,SUM(INTERESTAMOUNT)					AS tot_int
FROM
    `guat`.loantransaction

UNION
SELECT
	SUM(principal_portion_derived)		AS tot_prin
    ,SUM(interest_portion_derived)		AS tot_int
FROM
	`mifos-guat`.m_loan_transaction;
;

SELECT
	mambu.CREATIONDATE,
    mambu.ENTRYDATE,
    mambu.PRINCIPALAMOUNT,
    mambu.INTERESTAMOUNT,
    mambu.FEESAMOUNT,
    mambu.PENALTYAMOUNT,
    mambu.AMOUNT,
    mambu.BALANCE,
    mifos.transaction_date,
    mifos.submitted_on_date,
    mifos.created_date,
    mifos.principal_portion_derived,
    mifos.interest_portion_derived,
    mifos.fee_charges_portion_derived,
    mifos.penalty_charges_portion_derived,
    mifos.amount,
    mifos.outstanding_loan_balance_derived
FROM
	(SELECT
    	CREATIONDATE,
		ENTRYDATE,
		PRINCIPALAMOUNT,
		INTERESTAMOUNT,
		FEESAMOUNT,
		PENALTYAMOUNT,
		AMOUNT,
		BALANCE
	FROM
        `guat`.loantransaction
 	)									AS mambu

LEFT JOIN
	(SELECT
		transaction_date,
		submitted_on_date,
		created_date,
		principal_portion_derived,
		interest_portion_derived,
		fee_charges_portion_derived,
		penalty_charges_portion_derived,
		amount,
		outstanding_loan_balance_derived
	FROM
        `mifos-guat`.m_loan_transaction
	)									AS mifos
	ON 
		#mambu.principalamount = mifos.principal_portion_derived
		#AND 
		#mambu.interestamount = mifos.interest_portion_derived
        #AND 
        #mambu.amount = mifos.amount
        mambu.creationdate = mifos.created_date
WHERE
	mifos.amount is not null
;



SELECT
	'MAMBU'									AS src,
	COUNT(CREATIONDATE)							AS cdate,
	COUNT(ENTRYDATE)								AS edate,
	COUNT(PRINCIPALAMOUNT)							AS principal,
	COUNT(INTERESTAMOUNT)							AS interest,
	COUNT(FEESAMOUNT)								AS fees,
	COUNT(PENALTYAMOUNT)							AS penalty,
	COUNT(AMOUNT)									AS amt,
	COUNT(BALANCE)									AS balance
FROM
	`guat`.loantransaction
UNION
SELECT
	'Mifos'									AS src,
	COUNT(created_date)							AS cdate,
	#submitted_on_date,
	COUNT(transaction_date)						AS edate,
	COUNT(principal_portion_derived)				AS principal,
	COUNT(interest_portion_derived)				AS interest,
	COUNT(fee_charges_portion_derived)				AS fees,
	COUNT(penalty_charges_portion_derived)			AS penalty,
	COUNT(amount)									AS amt,
	COUNT(outstanding_loan_balance_derived)		AS balance
FROM
	`mifos-guat`.m_loan_transaction
;

SELECT
	'MAMBU'									AS src,
	COUNT(CREATIONDATE)							AS cdate,
	COUNT(ENTRYDATE)								AS edate,
	SUM(PRINCIPALAMOUNT)							AS principal,
	SUM(INTERESTAMOUNT)							AS interest,
	SUM(FEESAMOUNT)								AS fees,
	SUM(PENALTYAMOUNT)							AS penalty,
	SUM(AMOUNT)									AS amt,
	SUM(BALANCE)									AS balance
FROM
	`guat`.loantransaction
UNION
SELECT
	'Mifos'									AS src,
	COUNT(created_date)							AS cdate,
	#submitted_on_date,
	COUNT(transaction_date)						AS edate,
	SUM(principal_portion_derived)				AS principal,
	SUM(interest_portion_derived)				AS interest,
	SUM(fee_charges_portion_derived)				AS fees,
	SUM(penalty_charges_portion_derived)			AS penalty,
	SUM(amount)									AS amt,
	SUM(outstanding_loan_balance_derived)		AS balance
FROM
	`mifos-guat`.m_loan_transaction
;


-- see if every loan has a disbursement transaction

SELECT
	'Mambu'								AS src
	,COUNT(DISTINCT l.encodedkey)		AS loans
	,COUNT(DISTINCT lt.parentaccountkey)	AS loan_disbursements
    ,SUM(l.loanamount)					AS disbursed_loans
	,SUM(lt.amount)						AS disbursed_transactions
FROM
	`guat`.loanaccount	 		AS l
    
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


-- see if every loan balance matches the most recent transaction balance

SELECT
	CREATIONDATE
	,balance # is this the balnce on the record that was MAX creationdate ?
	,PARENTACCOUNTKEY
FROM
	`guat`.loantransaction
ORDER BY
	PARENTACCOUNTKEY
;

SELECT
	lt.CREATIONDATE						AS maxdate
	,lt.balance # is this the balnce on the record that was MAX creationdate ? No, it's the first balance of the parentaccountkey.
	,cg.nam
    ,l.ENCODEDKEY
FROM
	`guat`.loantransaction lt

LEFT JOIN
	`guat`.loanaccount l
	ON
	l.encodedkey = lt.parentaccountkey
    
LEFT JOIN
	(
		SELECT
			firstname							AS nam
			,encodedkey							AS encod
		FROM
			`guat`.`client` c
		
		UNION
		SELECT
			groupname						AS nam
			,encodedkey							AS encod
		FROM
			`guat`.`group` g
	)									AS cg
    ON
    l.accountholderkey = cg.encod
-- GROUP BY
-- 	parentaccountkey

ORDER BY
	maxdate
;



-- see if transactions total to the same as loans.

# total disbursements ?= total principal amount
# total repaymeny ?= total repaid_derived
#etc


select distinct transaction_type_enum from `mifos-guat`.m_loan_transaction;

select * from `mifos-guat`.r_enum_value
where enum_name = 'transaction_type_enum';