-- -----------------
-- Tests for Loans
-- -----------------

/* 

totals - make sure entire portfolio balance is there. Total loaned out, total repaid, total etc.
how many loans have interest 0.
loan older than a year with no repayments, still active.

*/

select * from `mifostenant-default`.m_loan;
select * from `mifostenant-default`.m_loan where group_id is not null;
SELECT * FROM `mambu-guate`.loanaccount;
select * from interestratesettings;
select * from loanproduct;

-- TOTALS OF MONEY
#MAMBU
SELECT
	ACCOUNTHOLDERTYPE,
	SUM(LOANAMOUNT),
    SUM(PRINCIPALBALANCE),
    SUM(PRINCIPALPAID),
    SUM(INTERESTPAID),
    SUM(INTERESTBALANCE)
FROM
	`mambu-guate`.loanaccount
GROUP BY
	ACCOUNTHOLDERTYPE
;

#MIFOS
SELECT
	if(group_id, "group", "individual") ACCOUNTHOLDERTYPE,
    SUM(principal_amount),
    SUM(principal_outstanding_derived),
    SUM(principal_repaid_derived),
    SUM(interest_repaid_derived),
    SUM(interest_outstanding_derived)
FROM
	`mifostenant-default`.m_loan
GROUP BY
	ACCOUNTHOLDERTYPE
;
   
-- loans with 0% interest, active with no repayments for a year.

SELECT
	*
FROM
	`mambu-guate`.loanaccount
WHERE
		interestrate = 0
    AND accountstate <> "CLOSED"
	#AND lastmodifieddate < 2015-01-20
;


-- Count relevant fields, see if there are the right amount of records, nulls,

SELECT
	"key"										AS field,
	COUNT(encodedkey)							AS count,
	COUNT(DISTINCT encodedkey)					AS count_distinct,
    COUNT(*) - COUNT(encodedkey) 				AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"accountholderkey"							AS field,
	COUNT(accountholderkey)						AS count,
	COUNT(DISTINCT accountholderkey)			AS count_distinct,
    COUNT(*) - COUNT(accountholderkey) 			AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"producttypekey"							AS field,
	COUNT(PRODUCTTYPEKEY)						AS count,
	COUNT(DISTINCT producttypekey)				AS count_distinct,
    COUNT(*) - COUNT(producttypekey) 			AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"ASSIGNEDUSERKEY"							AS field,
	COUNT(ASSIGNEDUSERKEY)						AS count,
	COUNT(DISTINCT ASSIGNEDUSERKEY)				AS count_distinct,
    COUNT(*) - COUNT(ASSIGNEDUSERKEY) 			AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"loanamount"								AS field,
	COUNT(loanamount)							AS count,
	COUNT(DISTINCT loanamount)					AS count_distinct,
    COUNT(*) - COUNT(loanamount) 				AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"interestrate"								AS field,
	COUNT(interestrate)							AS count,
	COUNT(DISTINCT interestrate)				AS count_distinct,
    COUNT(*) - COUNT(interestrate) 				AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"INTERESTCALCULATIONMETHOD"					AS field,
	COUNT(INTERESTCALCULATIONMETHOD)			AS count,
	COUNT(DISTINCT INTERESTCALCULATIONMETHOD)	AS count_distinct,
    COUNT(*) - COUNT(INTERESTCALCULATIONMETHOD) AS count_null
FROM
	`mambu-guate`.loanaccount

UNION
SELECT
	"repaymentinstallments"						AS field,
	COUNT(repaymentinstallments)				AS count,
	COUNT(DISTINCT repaymentinstallments)		AS count_distinct,
    COUNT(*) - COUNT(repaymentinstallments) 	AS count_null
FROM
	`mambu-guate`.loanaccount

;

SELECT
	#"Mifos"								AS data_source,
	"accountno"							AS field,
	COUNT(account_no)					AS count,
	COUNT(DISTINCT account_no)			AS count_distinct,
    COUNT(*) - COUNT(account_no) 		AS count_null
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"client_ids"						AS field,
	COUNT(client_id)					AS count,
	COUNT(DISTINCT client_id)			AS count_distinct,
	COUNT(*) - COUNT(client_id) 		AS count_null
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"product_id"						AS field,    
    COUNT(product_id)					AS product_ids,
	COUNT(DISTINCT product_id)			AS dist_prod_ids,
	COUNT(*) - COUNT(product_id) 		AS null_prod_ids
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"fund_id"							AS field,    
    COUNT(fund_id)						AS fund_ids,	
    COUNT(DISTINCT fund_id)				AS distinct_fundid,
	COUNT(*) - COUNT(fund_id) 			AS null_fundid
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"loan_officer_id"					AS field,
	COUNT(loan_officer_id)				AS LO_ids,
	COUNT(DISTINCT loan_officer_id)		AS distinct_LO_ids,
	COUNT(*) - COUNT(loan_officer_id) 	AS null_LO_ids
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"principal_amount_proposed"			AS field,
	COUNT(principal_amount_proposed)	AS proposed,
	COUNT(DISTINCT principal_amount_proposed)	AS dist_proposed,
    COUNT(*) - COUNT(principal_amount_proposed) AS null_proposed
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"principal_amount"					AS field,
    COUNT(principal_amount)				AS amt,
	COUNT(DISTINCT principal_amount)	AS dist_amts,
    COUNT(*) - COUNT(principal_amount) 	AS null_amts
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"approved_principal"				AS field,    
    COUNT(approved_principal)			AS approved,
	COUNT(DISTINCT approved_principal)	AS dist_approved,
    COUNT(*) - COUNT(approved_principal) AS null_approved
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"nominal_interest_rate_per_period"	AS field,
    COUNT(nominal_interest_rate_per_period)	AS nom_int,
	COUNT(DISTINCT nominal_interest_rate_per_period)	AS dist_nom_int,
    COUNT(*) - COUNT(nominal_interest_rate_per_period) AS null_nom_int
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"interest_period_frequency_enum"	AS field,
    COUNT(interest_period_frequency_enum)	AS int_period,
	COUNT(DISTINCT interest_period_frequency_enum)	AS dist_int_period,
    COUNT(*) - COUNT(interest_period_frequency_enum) AS null_int_period
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"annual_nominal_interest_rate"		AS field,
    COUNT(annual_nominal_interest_rate)	AS annual_int,
	COUNT(DISTINCT annual_nominal_interest_rate)	AS dist_annual_int,
    COUNT(*) - COUNT(annual_nominal_interest_rate) AS null_annual_int
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"interest_method_enum"				AS field,
    COUNT(interest_method_enum)			AS int_method,
	COUNT(DISTINCT interest_method_enum)	AS dist_int_method,
    COUNT(*) - COUNT(interest_method_enum) AS null_int_method
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"interest_calculated_in_period_enum"	AS field,
    COUNT(interest_calculated_in_period_enum)	AS int_period,
	COUNT(DISTINCT interest_calculated_in_period_enum)	AS dist_int_period,
    COUNT(*) - COUNT(interest_calculated_in_period_enum) AS null_int_period
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"term_frequency"					AS field,
    COUNT(term_frequency)				AS freq,
	COUNT(DISTINCT term_frequency)		AS dist_freq,
    COUNT(*) - COUNT(term_frequency) 	AS null_freq
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"term_period_frequency_enum"		AS field,
    COUNT(term_period_frequency_enum)	AS freq_enum,
	COUNT(DISTINCT term_period_frequency_enum)	AS dist_freq_enum,
    COUNT(*) - COUNT(term_period_frequency_enum) AS null_freq_enum
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"repay_every"						AS field,
    COUNT(repay_every)					AS repay_every,
	COUNT(DISTINCT repay_every)			AS dist_r_every,
    COUNT(*) - COUNT(repay_every) 		AS null_re_every
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"repayment_period_frequency_enum"	AS field,
    COUNT(repayment_period_frequency_enum)	AS repay_enum,
	COUNT(DISTINCT repayment_period_frequency_enum)	AS dist_re_enum,
    COUNT(*) - COUNT(repayment_period_frequency_enum) AS null_re_enum
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"repayment_frequency_day_of_week_enum"	AS field,
    COUNT(repayment_frequency_day_of_week_enum)	AS day_enum,
	COUNT(DISTINCT repayment_frequency_day_of_week_enum)	AS dist_day,
    COUNT(*) - COUNT(repayment_frequency_day_of_week_enum) AS null_re_day
FROM
	`mifostenant-default`.m_loan	
UNION
SELECT
	"number_of_repayments"				AS field,
    COUNT(number_of_repayments)			AS num_repay,
	COUNT(DISTINCT number_of_repayments)	AS dist_num_repay,
    COUNT(*) - COUNT(number_of_repayments)	AS null_num_repay
FROM
	`mifostenant-default`.m_loan
;


-- check that INTEREST RATES MATCH UP

 # loan | loan in mifos | interestrate | interestrate in mifos

 # take all loans, left join with mifos loans, so the loan is compared side to side with it's migrated version.
SELECT
	COUNT(DISTINCT l.interestrate)
FROM
	`mambu-guate`.loanaccount la
LEFT JOIN
	`mifostenant-default`.m_loan
	ON
	c.id = m_c.external_id
#WHERE
#	m_c.external_id is null
;

SELECT * FROM `mambu-guate`.loanaccount la; 	#IDENTIFIERS: 	assigned user,	id, loanamount, 		installments,			assigned centre,	account holder,	assigned branch,	accountholdertype,
SELECT * FROM 	`mifostenant-default`.m_loan; 	#l				loan ooicer id,	?,	principal_amaount, 	number_of_repayments,	group_id,				 

SELECT
	# IF(mambu.interest = mifos.interest, "match", null)	AS matching_interest
	*
FROM
(
	SELECT
		'Mambu'										AS src
		,l.ENCODEDKEY
		,l.INTERESTRATE								AS interest
		,l.LOANAMOUNT
		,l.REPAYMENTINSTALLMENTS
		,cntr.name									AS CENTRE_NAME
		,b.name										AS BRANCH_NAME
		,CONCAT(u.FIRSTNAME, " ", u.LASTNAME)		AS USER_NAME
		,if(cli.firstname is null, g.groupname, CONCAT(cli.FIRSTNAME, " ", cli.LASTNAME))	AS CLIENT_NAME
		,l.ACCOUNTHOLDERTYPE						AS ACCOUNTHOLDER_TYPE
	FROM
		`mambu-guate`.loanaccount l

	LEFT JOIN
		`mambu-guate`.centre cntr
		ON cntr.encodedkey = l.ASSIGNEDCENTREKEY

	LEFT JOIN
		`mambu-guate`.client cli
		ON cli.encodedkey = l.accountholderkey

	LEFT JOIN
		`mambu-guate`.user u
		ON u.encodedkey = l.ASSIGNEDUSERKEY

	LEFT JOIN
		`mambu-guate`.branch b
		ON b.encodedkey = l.ASSIGNEDBRANCHKEY

	LEFT JOIN
		`mambu-guate`.group g
		ON g.encodedkey = l.accountholderkey
)													AS mambu

LEFT JOIN
(
	SELECT
		'Mifos'											AS src
		,l.id
		,l.nominal_interest_rate_per_period				AS interest
		,l.principal_amount
		,l.number_of_repayments
		,g.display_name									AS CENTRE_NAME
		,o.name											AS BRANCH_NAME
		,CONCAT(s.FIRSTNAME, " ", s.LASTNAME)			AS USER_NAME
		,if(cli.firstname is null, g.display_name, CONCAT(cli.FIRSTNAME, " ", cli.LASTNAME))	AS CLIENT_NAME
		,IF(l.loan_type_enum = 1, 'CLIENT', 'GROUP')	AS ACCOUNTHOLDER_TYPE
		,if(s.office_id = cli.office_id, 1, null)			AS match_office_id
	FROM
		`mifostenant-default`.m_loan l

	LEFT JOIN
		`mifostenant-default`.m_group g
		ON	g.id = l.group_id

	LEFT JOIN
		`mifostenant-default`.m_client cli
		ON cli.id = l.client_id

	LEFT JOIN
		`mifostenant-default`.m_staff s
		ON s.id = l.loan_officer_id

	LEFT JOIN
		`mifostenant-default`.m_office o
		ON o.id = cli.office_id
)												AS mifos
	ON
	mambu.loanamount = mifos.principal_amount
    AND
    mambu.repaymentinstallments = mifos.number_of_repayments
    AND
    mambu.accountholder_type = mifos.accountholder_type
    #AND
    #mambu.interest = mifos.interest
    AND
    mambu.client_name = mifos.client_name
    #AND
    #mambu.user_name = mifos.user_name
    #AND
    #mambu.centre_name = mifos.centre_name
    AND
    mambu.branch_name = mifos.branch_name
WHERE
#	mifos.src is null
	mambu.branch_name = 'Patzicía'
;

SELECT
	nominal_interest_rate_per_period
    ,c.display_name
    ,c.firstname
    ,c.lastname
    #,isMatching
FROM
	`mifostenant-default`.m_loan l

LEFT JOIN
	`mifostenant-default`.m_client c
	ON
	c.id = l.client_id

;

SELECT
	interestrate
    ,nam
FROM
	`mambu-guate`.loanaccount l

LEFT JOIN
	(
		SELECT
			firstname							AS nam
			,encodedkey							AS encod
		FROM
			`mambu-guate`.`client` c
		
		UNION
		SELECT
			groupname							AS nam
			,encodedkey							AS encod
		FROM
			`mambu-guate`.`group` g
	)											AS cg
	ON
	cg.encod = l.accountholderkey
;