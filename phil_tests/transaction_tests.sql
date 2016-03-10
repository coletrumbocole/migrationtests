-- see if every loan has a disbursement

explain SELECT
	* # the loans that didn't have a disbursement
# a count of loans that didn't have a disbursement
# a grouped count that tells me how many did and how many didn't
FROM
	(SELECT 
		l.encodedkey
        ,l.loanamount
        ,lt.amount
	FROM
		`phil`.loanaccount AS l
		,`phil`.loantransaction AS lt
	WHERE
		lt.`type` = 'DISBURSMENT'
		AND
		l.ENCODEDKEY = lt.parentaccountkey
	)												AS mambu

	LEFT JOIN
		(SELECT
			m_l.external_id
			,m_l.id
            ,m_l.principal_amount
            ,lt.amount
		FROM
			`mifostenant-default`.m_loan 			AS m_l
			,`mifostenant-default`.m_loan_transaction	AS lt
		WHERE 
			lt.transaction_type_enum = 1
			AND
			m_l.id = lt.loan_id
		)											AS mifos
	ON
		mambu.encodedkey = mifos.external_id
WHERE
	mifos.id is null
;

explain
SELECT
	m_l.external_id
    ,l.encodedkey
    ,lt.amount
FROM
	`mifostenant-default`.m_loan 					AS m_l
	,`mifostenant-default`.m_loan_transaction 		AS m_lt
    ,`phil`.loanaccount								AS l
    ,`phil`.loantransaction							AS lt
WHERE
	m_l.external_id = l.encodedkey
	AND
    m_l.id = m_lt.loan_id
    AND
    l.encodedkey = lt.parentaccountkey
;


-- see if disbursed amount matches up

SELECT
	IF(lt.amount = l.loanamount, 
		TRUE,
		NULL)										AS matching
	,COUNT(l.encodedkey)							AS count
	,SUM(lt.amount)									AS amt_transaction
	,SUM(l.loanamount)								AS amt_loan
FROM
	`phil`.loanaccount						 		AS l
	,`phil`.loantransaction							AS lt
WHERE 
	lt.`type` = 'DISBURSMENT'
	AND
	l.ENCODEDKEY = lt.parentaccountkey

;

-- how many didn't even have a disbursement


-- did loan have correct number of transactions?
-- Do loans have the correct number of repayments?

SELECT
	parentaccountkey
    ,mambu.transactions
    ,mifos.m_transactions
    ,IF(mambu.transactions = mifos.m_transactions, 
		"yes", 
        "no")										AS matching
FROM
	(
		SELECT # the loan and the number of repayments under that loan.
			parentaccountkey
			,COUNT(*)									AS transactions
		FROM
			`phil`.loantransaction
 		GROUP BY
			parentaccountkey
	)													AS mambu
	,(
		SELECT # the loan and the number of repayments under that loan. And the loan it came from in the other db.
			m_lt.loan_id
            ,COUNT(m_lt.id)								AS m_transactions
            ,m_l.external_id
		FROM # the loans and the repayment that corresponds.
			`mifostenant-default`.m_loan_transaction AS m_lt
			,(
				SELECT
					external_id
					,id
				FROM
					`mifostenant-default`.m_loan
			)											AS m_l
		WHERE
			m_lt.loan_id = m_l.id
        GROUP BY
			m_lt.loan_id # or if I want to see how many repaymnets are attached to the mambu loan: m_l.external_id
	)													AS mifos
WHERE
	mambu.parentaccountkey = mifos.external_id
	AND
    mambu.transactions <> mifos.m_transactions
;