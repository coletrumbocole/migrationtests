#########################################################################################
-- -----------------
-- 1 Tests for Staff and Office
-- -----------------

SELECT * FROM input_db.user;
SELECT * FROM `mifostenant-default`.m_staff;


-- see if names match

SELECT 
	u.FIRSTNAME
    ,s.firstname
FROM 
	input_db.user u
	LEFT JOIN
	`mifostenant-default`.m_staff s
	ON
#    u.firstname = s.firstname
    u.lastname = s.lastname
;


-- look at offices

SELECT * FROM `mifostenant-default`.m_office;
SELECT * FROM input_db.branch;

-- check that each branch has correct loan officer


#########################################################################################
-- -----------------
-- 2 Tests for Clients
-- -----------------

SELECT * FROM `mifostenant-default`.m_client; #13856
SELECT * FROM input_db.client; #13591


-- compare counts

SELECT
	"Mambu"								AS data_source
	,COUNT(encodedkey) 					AS clients #13591
	,COUNT(firstname) 					AS clients_firstnames #13591
    ,COUNT(DISTINCT firstname) 			AS clients_distinct_firstnames #3985
    ,COUNT(*)-COUNT(firstname)			AS null_firstnames
    ,COUNT(lastname) 					AS clients_lastnames #13591
FROM
	input_db.client

UNION
SELECT
	"Migrated"							AS data_source
	,COUNT(id) 							AS clients
	,COUNT(firstname) 					AS clients_firstnames
    ,COUNT(DISTINCT firstname) 			AS clients_distinct_firstnames
    ,COUNT(*)-COUNT(firstname)			AS null_firstnames
    ,COUNT(lastname) 					AS clients_lastnames
FROM
	`mifostenant-default`.m_client
;


-- create list of clients in Mambu that aren't in Mifos

SELECT
	mamb_cli.firstname
    ,mamb_cli.lastname
    ,mamb_cli.id
FROM
	input_db.client								AS mamb_cli
    
	LEFT JOIN
    `mifostenant-default`.m_client  			AS m_cli
	ON 
    -- mamb_cli.firstname = m_cli.firstname
-- 	AND mamb_cli.lastname = m_cli.lastname
-- 	AND 
    mamb_cli.encodedkey = m_cli.external_id
	# result of join is: all records from mambu, and each record has the mifos record that matches it on first, last name, id. If there are more than one matching mifos records, the mambu record is duplicated for each matching mifos record, if there is no matching mifos record, the mambu record is still there but has NULL for all the mifos fields. If there were multiple matching mifos records, the mambu record is duplicated too.
WHERE
-- 	m_cli.firstname is null
-- 	OR m_cli.lastname is null
-- 	OR 
    m_cli.external_id is null
    #result of where statement: only shows records from select statement that have data in mambu fields, but NULL in mifos fields. These happen because of the 	LEFT JOIN. These are records that didn't make it to mifos.
;	


-- the extra clients in mifos.

SELECT
	*
FROM 
	`mifostenant-default`.m_client m_c

	LEFT JOIN 
	input_db.client c
	ON 
	m_c.external_id = c.encodedkey
WHERE 
	c.firstname is null
;
	# try with Even more fields in common: compare the records of each client (after having joined all loans, loan officer, etc) with the migrated records of each client (after having joined the same fields on)


/*
Which fields didn't migrate:
	-- birthday
    
Which relationships didn't migrate:
	-- some clients belonged to a branch office and belonged to a group from a different branch office.

*/    


-- Loan officers have correct number of clients

SELECT
	u.firstname
    ,u.lastname
    ,COUNT(c.ENCODEDKEY)						AS clients
FROM
	input_db.client								AS c

	LEFT JOIN
    input_db.user  								AS u
	ON
    u.encodedkey = c.assigneduserkey

GROUP BY
	c.ASSIGNEDUSERKEY
;

SELECT
	s.firstname
    ,s.lastname
    ,COUNT(c.id)								AS clients
FROM
	`mifostenant-default`.m_client				AS c
	LEFT JOIN
    `mifostenant-default`.m_staff				AS s
	ON
	s.id = c.staff_id
GROUP BY
	c.staff_id
;


#########################################################################################

-- -----------------
-- 3 Tests for Centers
-- -----------------

	# 	goal: if all the centres from mambu go into m_group with the right 
	#	name, staff, office, external_id, creation date, active, level_id = 1, 
    #	then it's good.
    
    #	Staff and office name need to be joined on to centre.

SELECT * FROM input_db.centre;
SELECT * FROM `mifostenant-default`.m_group WHERE level_id = 1;


-- count centers

SELECT
	"Mambu"								AS db
	,COUNT(encodedkey) 					AS centres
    ,COUNT(DISTINCT encodedkey) 		AS distinct_centres
FROM
	input_db.centre

UNION
SELECT
	"Mifos"								AS db
	,COUNT(id) 							AS centres
    ,COUNT(DISTINCT id)					AS distinct_centres
FROM
	`mifostenant-default`.m_group
WHERE
	level_id = 1
;


-- counts for relevant fields in both dbs

SELECT
	"Mambu"								AS db,
    COUNT(name)							AS names,
    COUNT(DISTINCT name)				AS distinct_names,
	COUNT(encodedkey) - COUNT(name)		AS null_names,

	COUNT(assignedbranchkey)			AS branches,
	COUNT(DISTINCT assignedbranchkey)	AS dist_brans,
    COUNT(encodedkey) - COUNT(assignedbranchkey)	AS null_branches,

	COUNT(id)							AS ids,
	COUNT(DISTINCT id)					AS dist_ids,
	COUNT(encodedkey) - COUNT(id)		AS null_ids,

	COUNT(creationdate)					AS crdates,
	COUNT(DISTINCT creationdate)		AS dist_cre,
	COUNT(encodedkey) - COUNT(creationdate)		AS null_creation_dates

FROM
	input_db.centre

UNION
(SELECT
	"Mifos"								AS db,

    COUNT(display_name)					AS names,
    COUNT(DISTINCT display_name)		AS distinct_names,
	COUNT(id) - COUNT(display_name)		AS null_names,

	COUNT(office_id)					AS branches,
	COUNT(DISTINCT office_id)			AS dist_brans,
    COUNT(id) - COUNT(office_id)		AS null_branches,

	COUNT(external_id)					AS ids,
	COUNT(DISTINCT external_id)			AS dist_ids,
	COUNT(id) - COUNT(external_id)		AS null_ids,

	COUNT(activation_date)				AS crdates,
	COUNT(DISTINCT activation_date)		AS dist_cre,
	COUNT(id) - COUNT(activation_date)	AS null_creation_dates
FROM
	`mifostenant-default`.m_group
WHERE
	level_id = 1
)
;


-- which Mambu centers have same name but different id?

SELECT 
	*
FROM
	(
		SELECT
			name
			,COUNT(name)				AS count
		FROM
			input_db.centre
		GROUP BY
			name
		HAVING
			count > 1
	) 									AS repeat_names

	LEFT JOIN
	input_db.centre				AS c ON c.name = repeat_names.name
;


-- 4) which CENTRES in Mambu didn't show up in Mifos? # 0 rows

SELECT 
	# COUNT(*)
    #,COUNT(DISTINCT m_gr.display_name)
    *
FROM
	input_db.centre								AS c

	LEFT JOIN
	`mifostenant-default`.m_group				AS m_gr
    ON 
		m_gr.external_id = c.encodedkey
WHERE
	m_gr.display_name is null # where there wasn't a display_name in Mifos for the id in Mambu 
    AND 
	m_gr.level_id = 1
;



#########################################################################################

-- -----------------
-- 4 Tests for Groups
-- -----------------

	#	successful migration if: 
    #		each group in Mambu had made it to the m_group with level_id = 2
    #		groupname -> name (so count(groupnames in mambu) should be = count(name) in mifos)
    #		branch -> office
    #		user -> staff
    #		center -> parent_id
    #		id -> external_id


-- 1) count relevant fields in groups (level_id = 2)

SELECT
	"Mambu"										AS data_source,

	COUNT(assignedbranchkey)					AS branches,
	COUNT(DISTINCT assignedbranchkey)			AS dist_branches,
    COUNT(encodedkey) - COUNT(assignedbranchkey) AS null_brchs,

	COUNT(assigneduserkey)						AS users,
	COUNT(DISTINCT assigneduserkey)				AS dist_usrs,
    COUNT(encodedkey) - COUNT(assigneduserkey)	AS null_usrs,
	
    COUNT(creationdate)							AS creationdates,
	COUNT(DISTINCT creationdate)				AS dist_crdats,
    COUNT(encodedkey) - COUNT(creationdate) 	AS null_crdates,

    COUNT(groupname)							AS groupnames,	
    COUNT(DISTINCT groupname)					AS distinct_gropnams,
    COUNT(encodedkey) - COUNT(groupname) 		AS null_grpnme,

	COUNT(id)									AS ids,
	COUNT(DISTINCT id)							AS distinct_ids,
	COUNT(encodedkey) - COUNT(id)				AS null_ids,

	COUNT(assignedcentrekey)					AS centers,
	COUNT(DISTINCT assignedcentrekey)			AS dist_ctrs,
    COUNT(encodedkey) - COUNT(assignedcentrekey) AS null_ctrs
FROM
	input_db.group

UNION
SELECT
	"Mifos"										AS data_source,
    
    COUNT(office_id)							AS branches,
	COUNT(DISTINCT office_id)					AS dist_branches,
    COUNT(id) - COUNT(office_id) 				AS null_brchs,

	COUNT(staff_id)								AS users,
	COUNT(DISTINCT staff_id)					AS dist_usrs,
	COUNT(id) - COUNT(staff_id) 				AS null_usrs,
    
    COUNT(activation_date)						AS creationdates,
	COUNT(DISTINCT activation_date)				AS dist_crdats,
	COUNT(id) - COUNT(activation_date) 			AS null_crdates,
    
    COUNT(display_name)							AS groupnames,	
    COUNT(DISTINCT display_name)				AS distinct_gropnams,
	COUNT(id) - COUNT(display_name) 			AS null_grpnme,
    
	COUNT(external_id)							AS ids,
	COUNT(DISTINCT external_id)					AS distinct_ids,
	COUNT(id) - COUNT(external_id) 				AS null_ids,
    
	COUNT(parent_id)							AS centers,
	COUNT(DISTINCT parent_id)					AS dist_ctrs,
    COUNT(id) - COUNT(parent_id) 				AS null_ctrs   
FROM
	`mifostenant-default`.m_group
WHERE
	level_id = 2
;


-- 2) which GROUPNAMES from Mambu did not show up in mifos?

SELECT 
	g.groupname,
    m_g.display_name
FROM
	input_db.`group`								AS g

	LEFT JOIN
	`mifostenant-default`.m_group				AS m_g	
    ON 
		m_g.external_id = g.encodedkey
WHERE
	m_g.display_name is null
;


-- Do groups have the correct center? 
	# doesn't apply. The groups have to be rearranged a little so that all clients in group are under same branch.


-- Do centres and groups add up to m_groups?
-- 
-- SELECT
-- 	"Mambu"										AS data_source
-- #	,SUM(input_db_centers, input_db_groups)				AS centers_and_groups
--     ,COUNT(m_g.id)
-- FROM
-- 	(
-- 		SELECT
-- 			COUNT(c.encodedkey)					AS input_db_centers
--             ,COUNT(g.encodedkey)				AS input_db_groups
-- 		FROM
-- 			input_db.centre						AS c
-- 			
--             FULL OUTER JOIN
-- 			input_db.group							AS g
--             ON
-- 				c.ENCODEDKEY = g.name # nothing should match.
-- 	)									AS `names`
-- 
-- UNION
-- SELECT
-- 	"Mifos"								AS data_source
-- 	,COUNT(*)							AS groups
-- FROM
-- 	`mifostenant-default`.m_group
-- ;
-- 


#########################################################################################

-- -----------------
-- 6 Tests for Loans (configurations, funds etc tested by hand.)
-- -----------------

/* 

totals - make sure entire portfolio balance is there. Total loaned out, total repaid, total etc.
how many loans have interest 0.
loan older than a year with no repayments, still active.

*/

-- select * from `mifostenant-default`.m_loan;
-- select * from `mifostenant-default`.m_loan where group_id is not null;
-- SELECT * FROM input_db.loanaccount;
-- select * from input_db.interestratesettings;
-- select * from input_db.loanproduct;

SELECT #MAMBU
	*
FROM
	input_db.loanaccount
WHERE
	ACCOUNTHOLDERTYPE <> 'CLIENT'
; # why are they all client?


-- TOTALS OF MONEY

SELECT #MAMBU
	"MAMBU"											AS datasource
	,ACCOUNTHOLDERTYPE
	,SUM(LOANAMOUNT)								AS prin
    ,SUM(PRINCIPALBALANCE)							AS bal
    ,SUM(PRINCIPALPAID)								AS paid
    ,SUM(INTERESTPAID)								AS int_paid
    ,SUM(INTERESTBALANCE)							AS int_bal
FROM
	input_db.loanaccount
GROUP BY
	ACCOUNTHOLDERTYPE

UNION
SELECT #MIFOS
	"MIFOS"											AS datasourc
    ,if(group_id, "group", "individual") 			AS ACCOUNTHOLDERTYPE
	,SUM(principal_amount)							AS prin
    ,SUM(principal_outstanding_derived)				AS bal
    ,SUM(principal_repaid_derived)					AS paid
    ,SUM(interest_repaid_derived)					AS int_paid
    ,SUM(interest_outstanding_derived)				AS int_bal
FROM
	`mifostenant-default`.m_loan
GROUP BY
	ACCOUNTHOLDERTYPE
; # Why are balances, principal paid, and int paid not correct?


-- loans with 0% interest, active with no repayments for a year.

SELECT
	*
FROM
	input_db.loanaccount
WHERE
		interestrate = 0
    AND accountstate <> "CLOSED"
	#AND lastmodifieddate < 2015-01-20
    
ORDER BY
	LASTMODIFIEDDATE
;


-- Count relevant fields

SELECT
	IF(mambu.count = mifos.count 
		AND mambu.count_distinct = mifos.count_distinct
        AND mambu.count_null = mifos.count_null
		,"yes", "no")					            AS matches
	,mambu.field									AS field
    ,mambu.count									AS mambu_count
    ,mambu.count_distinct							AS mambu_distinct_count
    ,mambu.count_null								AS mambu_null_count
    ,mifos.count									AS mifos_count
    ,mifos.count_distinct							AS mifos_distinct_count
    ,mifos.count_null								AS mifos_null_count
FROM
(
	SELECT
		"key"								AS field,
		COUNT(encodedkey)					AS count,
		COUNT(DISTINCT encodedkey)			AS count_distinct,
		COUNT(*) - COUNT(encodedkey) 		AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"accountholder"					AS field,
		COUNT(accountholderkey)				AS count,
		COUNT(DISTINCT accountholderkey)	AS count_distinct,
		COUNT(*) - COUNT(accountholderkey) 	AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"product"					AS field,
		COUNT(PRODUCTTYPEKEY)				AS count,
		COUNT(DISTINCT producttypekey)		AS count_distinct,
		COUNT(*) - COUNT(producttypekey) 	AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"loan_officer"					AS field,
		COUNT(ASSIGNEDUSERKEY)				AS count,
		COUNT(DISTINCT ASSIGNEDUSERKEY)		AS count_distinct,
		COUNT(*) - COUNT(ASSIGNEDUSERKEY) 	AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"principal"						AS field,
		COUNT(loanamount)					AS count,
		COUNT(DISTINCT loanamount)			AS count_distinct,
		COUNT(*) - COUNT(loanamount) 		AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"interestrate"						AS field,
		COUNT(interestrate)					AS count,
		COUNT(DISTINCT interestrate)		AS count_distinct,
		COUNT(*) - COUNT(interestrate) 		AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"INTERESTCALCULATIONMETHOD"					AS field,
		COUNT(INTERESTCALCULATIONMETHOD)			AS count,
		COUNT(DISTINCT INTERESTCALCULATIONMETHOD)	AS count_distinct,
		COUNT(*) - COUNT(INTERESTCALCULATIONMETHOD)	AS count_null
	FROM
		input_db.loanaccount
	UNION
	SELECT
		"repaymentinstallments"				AS field,
		COUNT(repaymentinstallments)		AS count,
		COUNT(DISTINCT repaymentinstallments)			AS count_distinct,
		COUNT(*) - COUNT(repaymentinstallments) 		AS count_null
	FROM
		input_db.loanaccount
)													AS mambu

	LEFT JOIN
	(
		SELECT
			"key"											AS field,
			COUNT(id)										AS count,
			COUNT(DISTINCT id)								AS count_distinct,
			COUNT(*) - COUNT(id) 							AS count_null
		FROM
			`mifostenant-default`.m_loan
		UNION
		SELECT
			"accountholder"						AS field,
			COUNT(client_id)					AS count,
			COUNT(DISTINCT client_id)			AS count_distinct,
			COUNT(*) - COUNT(client_id) 		AS count_null
		FROM
			`mifostenant-default`.m_loan	
		UNION
		SELECT
			"product"						AS field,    
			COUNT(product_id)					AS product_ids,
			COUNT(DISTINCT product_id)			AS dist_prod_ids,
			COUNT(*) - COUNT(product_id) 		AS null_prod_ids
		FROM
			`mifostenant-default`.m_loan	
		UNION
		SELECT
			"loan_officer"					AS field,
			COUNT(loan_officer_id)				AS LO_ids,
			COUNT(DISTINCT loan_officer_id)		AS distinct_LO_ids,
			COUNT(*) - COUNT(loan_officer_id) 	AS null_LO_ids
		FROM
			`mifostenant-default`.m_loan	
		UNION
		SELECT
			"principal"					AS field,
			COUNT(principal_amount)				AS amt,
			COUNT(DISTINCT principal_amount)	AS dist_amts,
			COUNT(*) - COUNT(principal_amount) 	AS null_amts
		FROM
			`mifostenant-default`.m_loan	
		UNION
		SELECT
			"interestrate"									AS field,
			COUNT(nominal_interest_rate_per_period)			AS nom_int,
			COUNT(DISTINCT nominal_interest_rate_per_period)	AS dist_nom_int,
			COUNT(*) - COUNT(nominal_interest_rate_per_period) AS null_nom_int
		FROM
			`mifostenant-default`.m_loan
		UNION
		SELECT
			"INTERESTCALCULATIONMETHOD"				AS field,
			COUNT(interest_method_enum)			AS int_method,
			COUNT(DISTINCT interest_method_enum)	AS dist_int_method,
			COUNT(*) - COUNT(interest_method_enum) AS null_int_method
		FROM
			`mifostenant-default`.m_loan
		UNION
		SELECT
			"repaymentinstallments"				AS field,
			COUNT(number_of_repayments)			AS num_repay,
			COUNT(DISTINCT number_of_repayments)	AS dist_num_repay,
			COUNT(*) - COUNT(number_of_repayments)	AS null_num_repay
		FROM
			`mifostenant-default`.m_loan
	)												AS mifos
	ON mambu.field = mifos.field
; # Why are there a different numbre of distinct interest rates? Did any loan's interest rate change?


-- check that INTEREST RATES MATCH UP

SELECT
	b.name
	,IF(
		l.INTERESTRATE = m_l.nominal_interest_rate_per_period
        , "yes"
        ,l.INTERESTRATE
	) 													AS matches
	,COUNT(l.ENCODEDKEY)
#	,l.ENCODEDKEY
#	,l.INTERESTBALANCE
    ,l.INTERESTRATE
#	,m_l.interest_outstanding_derived
    ,m_l.nominal_interest_rate_per_period
FROM
	(input_db.loanaccount AS l, `mifostenant-default`.m_loan AS m_l, input_db.branch AS b)
where
	m_l.external_id = l.encodedkey
	AND
	b.encodedkey = l.assignedbranchkey

GROUP BY
	b.name,
	matches
;


-- does each client have the right amount of loans?

SELECT
	IF (mambu.loans = mifos.loans, "correct", null)	AS correct
    ,COUNT(*)										AS count
    ,mambu.disp_name
    ,mambu.loans
    ,mifos.loans
FROM
(
	SELECT 
		CONCAT(c.FIRSTNAME,' ',c.LASTNAME)			AS disp_name
		,COUNT(l.ENCODEDKEY)						AS loans
        ,c.ENCODEDKEY								AS mambu_id
	FROM
		input_db.`client` 							AS c
		,input_db.loanaccount 						AS l
	WHERE
		c.encodedkey = l.ACCOUNTHOLDERKEY
	GROUP BY 
		c.encodedkey
)													AS mambu
,(
	SELECT 
		m_c.display_name							AS disp_name
		,COUNT(m_l.id)								AS loans
		,m_c.external_id
	FROM
		`mifostenant-default`.m_client 				AS m_c
		,`mifostenant-default`.m_loan 				AS m_l
	WHERE 
		m_c.id = m_l.client_id
	GROUP BY 
		m_c.id
)													AS mifos
WHERE
	mambu.mambu_id = mifos.external_id
GROUP BY
	correct
;


-- does each GROUP have the right amount of loans?

SELECT
	IF (mambu.loans = mifos.loans, "correct", null)	AS correct
    ,COUNT(*)										AS count
    ,mambu.disp_name
    ,mambu.loans
    ,mifos.loans
FROM
(
	SELECT 
		g.groupname									AS disp_name
		,COUNT(l.ENCODEDKEY)						AS loans
        ,g.ENCODEDKEY								AS mambu_id
	FROM
		input_db.`group` 								AS g
		,input_db.loanaccount 						AS l
	WHERE
		g.encodedkey = l.ACCOUNTHOLDERKEY
	GROUP BY 
		g.encodedkey
)													AS mambu
,(
	SELECT 
		m_g.display_name							AS disp_name
		,COUNT(m_l.id)								AS loans
        ,m_g.external_id
	FROM
		`mifostenant-default`.m_group 				AS m_g
		,`mifostenant-default`.m_loan 				AS m_l
	WHERE 
		m_g.id = m_l.client_id
	GROUP BY 
		m_g.id
)													AS mifos
WHERE
	mambu.mambu_id = mifos.external_id
GROUP BY
	correct
; # THere aren't any group loans.


-- Does each loan have the right balance?

SELECT
	IF(
		l.PRINCIPALBALANCE = m_l.principal_outstanding_derived
        ,"yes"
        ,"no"
	)												AS matching
    ,COUNT(*)										AS count
FROM
	(input_db.loanaccount 								AS l, 
    `mifostenant-default`.m_loan 					AS m_l)
WHERE
	m_l.external_id = l.encodedkey
GROUP BY
	matching
;


-- How many were right? Which loans in wich branches have the wrong balance? What were their balaces?

SELECT
	b.name												AS branch
	,IF(
		l.PRINCIPALBALANCE = m_l.principal_outstanding_derived
        , "yes"
        ,l.ENCODEDKEY
	) 													AS matching_balance
    ,IF(
		l.PRINCIPALBALANCE = m_l.principal_outstanding_derived
        , null
        ,m_l.id
	)													AS mifos_id
	,COUNT(l.ENCODEDKEY)								AS count
	,IF(
		l.PRINCIPALBALANCE = m_l.principal_outstanding_derived
        , null
        ,l.PRINCIPALBALANCE
	)													AS mambu_balance
	,IF(
		l.PRINCIPALBALANCE = m_l.principal_outstanding_derived
        , null
        ,m_l.principal_outstanding_derived
	)													AS mifos_balance
FROM
	(input_db.loanaccount 								AS l, 
    `mifostenant-default`.m_loan 					AS m_l, 
    input_db.branch 									AS b)
where
	m_l.external_id = l.encodedkey
	AND
	b.encodedkey = l.assignedbranchkey

GROUP BY
	b.name,
	matching_balance
ORDER BY
	b.name,
    count DESC
;


-- 



###############

-- -----------------
-- Tests for Loan Transactions
-- -----------------
/* from transaction_tests
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
*/

-- SELECT * FROM `mifostenant-default`.m_loan_transaction;
-- SELECT * FROM input_db.loantransaction;
-- 
-- SELECT * FROM `mifostenant-default`.m_payment_detail; # just id and payment type. HThis id is referenced in m_loan_transaction
-- 
-- SELECT DISTINCT `TYPE` FROM input_db.loantransaction;


-- see if principal and interest total to the same thing.

SELECT
	SUM(principalamount)					AS tot_prin
	,SUM(INTERESTAMOUNT)					AS tot_int
FROM
    input_db.loantransaction

UNION
SELECT
	SUM(principal_portion_derived)		AS tot_prin
    ,SUM(interest_portion_derived)		AS tot_int
FROM
	`mifostenant-default`.m_loan_transaction;
;


-- Look at relevant counts.

SELECT
	'MAMBU'											AS src,
	COUNT(CREATIONDATE)								AS cdate,
	COUNT(ENTRYDATE)								AS edate,
	COUNT(PRINCIPALAMOUNT)							AS principal,
	COUNT(INTERESTAMOUNT)							AS interest,
	COUNT(FEESAMOUNT)								AS fees,
	COUNT(PENALTYAMOUNT)							AS penalty,
	COUNT(AMOUNT)									AS amt,
	COUNT(BALANCE)									AS balance
FROM
	input_db.loantransaction
UNION
SELECT
	'Mifos'											AS src,
	COUNT(created_date)								AS cdate,
	#submitted_on_date,
	COUNT(transaction_date)							AS edate,
	COUNT(principal_portion_derived)				AS principal,
	COUNT(interest_portion_derived)					AS interest,
	COUNT(fee_charges_portion_derived)				AS fees,
	COUNT(penalty_charges_portion_derived)			AS penalty,
	COUNT(amount)									AS amt,
	COUNT(outstanding_loan_balance_derived)			AS balance
FROM
	`mifostenant-default`.m_loan_transaction
;


-- see if every loan has a disbursement

SELECT
	'Mambu'											AS src
	,COUNT(DISTINCT l.encodedkey)					AS loans
	,COUNT(DISTINCT lt.parentaccountkey)			AS loan_disbursements
    ,SUM(l.loanamount)								AS disbursed_loans
	,SUM(lt.amount)									AS disbursed_transactions
FROM
	input_db.loanaccount						 		AS l
    
	LEFT JOIN
	(
		SELECT
			parentaccountkey,
            amount
        FROM
			input_db.loantransaction
        WHERE `type` = 'DISBURSMENT'
    )												AS  lt
    ON l.ENCODEDKEY = lt.parentaccountkey

;
#UNION
SELECT
	'Mifos'											AS src
	,COUNT(DISTINCT l.id)							AS loans
	,COUNT(DISTINCT lt.loan_id)						AS loan_disbursements
    ,SUM(l.principal_disbursed_derived)				AS disbursed_loans
	,SUM(lt.amount)									AS disbursed_transactions
FROM
	`mifostenant-default`.m_loan 					AS l
    
	LEFT JOIN
	(
		SELECT
			loan_id,
            amount
        FROM
			`mifostenant-default`.m_loan_transaction
        WHERE transaction_type_enum = 1
    )												AS  lt
    ON l.id = lt.loan_id
;


-- see if every loan balance matches the most recent transaction balance

SELECT
	CREATIONDATE
	,balance # is this the balnce on the record that was MAX creationdate ?
	,PARENTACCOUNTKEY
FROM
	input_db.loantransaction
ORDER BY
	PARENTACCOUNTKEY
;

SELECT
	lt.CREATIONDATE									AS maxdate
	,lt.balance # is this the balnce on the record that was MAX creationdate ? No, it's the first balance of the parentaccountkey.
	,cg.nam
    ,l.ENCODEDKEY
FROM
	input_db.loantransaction lt

	LEFT JOIN
	input_db.loanaccount l
	ON
	l.encodedkey = lt.parentaccountkey
    
	LEFT JOIN
	(
		SELECT
			firstname								AS nam
			,encodedkey								AS encod
		FROM
			input_db.`client` 						AS c
		
		UNION
		SELECT
			groupname								AS nam
			,encodedkey								AS encod
		FROM
			input_db.`group` 							AS g
	)												AS cg
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

SELECT * FROM `mifostenant-default`.m_loan_transaction;
SELECT * FROM input_db.loantransaction;

SELECT * FROM `mifostenant-default`.m_loan;
SELECT * FROM input_db.loanaccount;



#########################################################################################

-- -----------------
-- 7 Tests for Loan Repayment History
-- -----------------




#########################################################################################

-- -----------------
-- 8 Tests for Savings Product
-- -----------------

-- by hand




#########################################################################################

-- -----------------
-- 9 Tests for Savings
-- -----------------

SELECT * FROM `mifostenant-default`.m_savings_account; #NULL

-- SELECT * FROM `mifostenant-default`.m_savings_account_charge; #NULL
-- SELECT * FROM `mifostenant-default`.m_savings_account_charge_paid_by; #NULL. has amount field
-- SELECT * FROM `mifostenant-default`.m_savings_account_interest_rate_chart;#NULL
-- SELECT * FROM `mifostenant-default`.m_savings_account_interest_rate_slab;

SELECT * FROM `mifostenant-default`.m_savings_account_transaction; #NULL. Has balance, transacitons, etc.

-- SELECT * FROM `mifostenant-default`.m_savings_interest_incentives;
-- SELECT * FROM `mifostenant-default`.m_savings_product;
-- SELECT * FROM `mifostenant-default`.m_savings_product_charge;
-- SELECT * FROM `mifostenant-default`.m_client;

SELECT * FROM input_db.savingsaccount; #NULL

SHOW COLUMNS FROM `mifostenant-default`.m_savings_account;
SHOW COLUMNS FROM input_db.savingsaccount;

-- count relevant fields

SELECT 
	COUNT(*)											AS count_records

	,COUNT(balance)										AS bal_count
	,COUNT(DISTINCT balance)							AS dist_bal
	,COUNT(*) - COUNT(balance)							AS null_bal

	,COUNT(accruedinterest)								AS int_count
	,COUNT(DISTINCT accruedinterest)					AS dist_int
	,COUNT(*) - COUNT(accruedinterest)					AS null_int

	,COUNT(interestdue)									AS intdue_count
	,COUNT(DISTINCT interestdue)						AS dist_intdue
	,COUNT(*) - COUNT(interestdue)						AS null_intdue

FROM
	input_db.savingsaccount
;

SELECT 
	COUNT(*)
FROM
`mifostenant-default`.m_savings_account
;


-- totals match

SELECT 
	SUM(BALANCE), # the prolem with this is, if I have the wrong number of records, the total won't be right, and it has to map to the records of the other database, which might only be the transactions. adding the balances of each transaction record will be way different thatn adding balances of savings accounts. 
    SUM(ACCRUEDINTEREST),
    SUM(INTERESTDUE)
FROM input_db.savingsaccount
; #NULL

SELECT 
	SUM(),
    SUM(),
    SUM()
FROM `mifostenant-default`.m_savings_account
; #NULL



-- matches with mambu





#########################################################################################

-- -----------------
-- 10 Tests for Savings Transaction / History
-- -----------------

# none


#########################################################################################

-- -----------------
-- 11 Tests for Fixed Deposit Products
-- -----------------


-- -----------------
-- 12 Tests for Fixed Deposit
-- -----------------


-- -----------------
-- 13 Tests for Recurring Deposit Product
-- -----------------


-- -----------------
-- 14 Tests for Recurring Deposit
-- -----------------


-- -----------------
-- 15 Tests for Recurring Deposit Account transaction history
-- -----------------


-- -----------------
-- 16 Closing (Savings account)
-- -----------------


#########################################################################################

-- -----------------
-- 17 Add Journal Entries
-- -----------------

SELECT * FROM input_db.glaccount;
SELECT * FROM input_db.dailygljournalentry;
SELECT * FROM input_db.glaccount;
SELECT * FROM input_db.glaccountingrule;
SELECT * FROM input_db.gljournalentry;

SELECT * FROM `mifostenant-default`.m_journal;
SELECT * FROM `mifostenant-default`.acc_gl_account;
SELECT * FROM `mifostenant-default`.acc_gl_closure;
SELECT * FROM `mifostenant-default`.acc_gl_financial_activity_account;
SELECT * FROM `mifostenant-default`.acc_gl_journal_entry;
SELECT * FROM `mifostenant-default`.acc_accounting_rule;



#########################################################################################

-- -----------------
-- 18 Add guarantor
-- -----------------

SELECT * FROM input_db.guaranty;

SELECT * FROM `mifostenant-default`.m_guarantor;
SELECT * FROM `mifostenant-default`.m_guarantor_funding_details;
SELECT * FROM `mifostenant-default`.m_guarantor_transaction;






