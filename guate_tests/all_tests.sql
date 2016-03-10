#########################################################################################
-- -----------------
-- Tests for Staff and Office
-- -----------------

SELECT * FROM `guat`.user;
SELECT * FROM `mifos-guat`.m_staff;


-- see if names match

SELECT 
	u.FIRSTNAME
    ,s.firstname    
FROM 
	`guat`.user u
LEFT JOIN
	`mifos-guat`.m_staff s
	ON
    u.firstname = s.firstname
;


-- look at offices

SELECT * FROM `mifos-guat`.m_office;
SELECT * FROM `guat`.branch;

-- check that each branch has correct loan officer


#########################################################################################
-- -----------------
-- Tests for Clients
-- -----------------

SELECT * FROM `mifos-guat`.m_client;
SELECT * FROM `guat`.client;


-- 1) compare counts

SELECT
	"Mambu"								AS data_source
	,COUNT(encodedkey) 					AS clients #13591
	,COUNT(firstname) 					AS clients_firstnames #13591
    ,COUNT(DISTINCT firstname) 			AS clients_distinct_firstnames #3985
    ,COUNT(*)-COUNT(firstname)			AS null_firstnames
    ,COUNT(lastname) 					AS clients_lastnames #13591
    ,COUNT(birthdate)					AS clients_bdays #12373
FROM
	`guat`.client

UNION
SELECT
	"Migrated"							AS data_source
	,COUNT(id) 							AS clients
	,COUNT(firstname) 					AS clients_firstnames
    ,COUNT(DISTINCT firstname) 			AS clients_distinct_firstnames
    ,COUNT(*)-COUNT(firstname)			AS null_firstnames
    ,COUNT(lastname) 					AS clients_lastnames
    ,COUNT(date_of_birth)				AS clients_bdays
FROM
	`mifos-guat`.m_client
;


# 2) which firstnames were not matching?

SELECT
	*
FROM
	(
		SELECT DISTINCT
			firstname
		FROM
			`guat`.client
	)									AS mambu_names

LEFT JOIN
	(
		SELECT DISTINCT
			firstname
		FROM
			`mifos-guat`.m_client #926
	)	          						AS migrated
	ON mambu_names.firstname = migrated.firstname

WHERE
	migrated.firstname is null
;


-- 3) create list of clients in Mambu that aren't in Mifos

SELECT
	mamb_cli.firstname
    ,mig_cli.firstname
    ,mamb_cli.lastname
    ,mig_cli.lastname
    ,mamb_cli.encodedkey
    ,mig_cli.external_id
FROM
	`guat`.client										AS mamb_cli

	LEFT JOIN
		`mifos-guat`.m_client  							AS mig_cli
		ON mamb_cli.encodedkey = mig_cli.external_id
WHERE
	mamb_cli.firstname <> mig_cli.firstname
	OR mamb_cli.lastname <> mig_cli.lastname
;


-- 4) the extra clients in mifos.

SELECT 
	* 
FROM 
	`mifos-guat`.m_client l

	LEFT JOIN 
		`guat`.client c
		ON l.external_id = c.encodedkey
WHERE 
	c.firstname is null
; # none
	# try with Even more fields in common: compare the records of each client (after having joined all loans, loan officer, etc) with the migrated records of each client (after having joined the same fields on)


/*
Which fields didn't migrate:
	-- birthday
    
Which relationships didn't migrate:
	-- some clients belonged to a branch office and belonged to a group from a different branch office.

*/    


-- 5) Loan officers have correct number of clients

SELECT
	u.firstname
    ,u.lastname
    ,COUNT(c.ENCODEDKEY)								AS clients
FROM
	`guat`.client										AS c

LEFT JOIN
    `guat`.user  										AS u
	ON
    u.encodedkey = c.assigneduserkey

GROUP BY
	c.ASSIGNEDUSERKEY
;

SELECT
	m_s.firstname
    ,m_s.lastname
    ,COUNT(m_c.id)										AS clients
FROM
	`mifos-guat`.m_client								AS m_c

	LEFT JOIN
		`mifos-guat`.m_staff							AS m_s
		ON
		m_s.id = m_c.staff_id
GROUP BY
	m_c.staff_id
; # staff tbd 3376


#########################################################################################

-- -----------------
-- Tests for Centers
-- -----------------

	# 	goal: if all the centres from mambu go into m_group with the right 
	#	name, staff, office, external_id, creation date, active, level_id = 1, 
    #	then it's good.
    
    #	Staff and office name need to be joined on to centre.


-- 1) count centers

SELECT
	"Mambu"								AS db
	,COUNT(encodedkey) 					AS centres
    ,COUNT(DISTINCT encodedkey) 		AS distinct_centres
FROM
	`guat`.centre

UNION
SELECT
	"Mifos"								AS db
	,COUNT(id) 							AS centres
    ,COUNT(DISTINCT id)					AS distinct_centres
FROM
	`mifos-guat`.m_group
WHERE
	level_id = 1;
;


-- 2) counts for relevant fields in both dbs

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
	`guat`.centre

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
	`mifos-guat`.m_group
WHERE
	level_id = 1
)
;


-- 3) which have same name as another centre but different id?

SELECT 
	*
FROM
	(
		SELECT
			name
			,COUNT(name)				AS count
		FROM
			`guat`.centre
		GROUP BY
			name
		HAVING
			count > 1
	) 									AS repeat_names

	LEFT JOIN
		`guat`.centre				AS c 
		ON c.name = repeat_names.name
;


-- 4) which CENTRES in Mambu didn't show up in Mifos?

SELECT 
	# COUNT(*) #174
    #,COUNT(DISTINCT m_gr.display_name) #174
    *
FROM
	`guat`.centre				AS c

	LEFT JOIN
		`mifos-guat`.m_group		AS m_gr	
		ON m_gr.display_name = c.id
WHERE
	m_gr.display_name is null # where there wasn't a display_name in Mifos for the id in Mambu 
    AND 
	m_gr.level_id = 1
; #none



#########################################################################################

-- -----------------
-- Tests for Groups
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
	"Mambu"								AS data_source,

	COUNT(assignedbranchkey)			AS branches,
	COUNT(DISTINCT assignedbranchkey)	AS dist_branches,
    COUNT(encodedkey) - COUNT(assignedbranchkey) AS null_brchs,

	COUNT(assigneduserkey)				AS users,
	COUNT(DISTINCT assigneduserkey)		AS dist_usrs,
    COUNT(encodedkey) - COUNT(assigneduserkey) AS null_usrs,
	
    COUNT(creationdate)					AS creationdates,
	COUNT(DISTINCT creationdate)		AS dist_crdats,
    COUNT(encodedkey) - COUNT(creationdate) AS null_crdates,

    COUNT(groupname)					AS groupnames,	
    COUNT(DISTINCT groupname)			AS distinct_gropnams,
    COUNT(encodedkey) - COUNT(groupname) AS null_grpnme,

	COUNT(id)							AS ids,
	COUNT(DISTINCT id)					AS distinct_ids,
	COUNT(encodedkey) - COUNT(id)		AS null_ids,

	COUNT(assignedcentrekey)			AS centers,
	COUNT(DISTINCT assignedcentrekey)	AS dist_ctrs,
    COUNT(encodedkey) - COUNT(assignedcentrekey) AS null_ctrs
FROM
	`guat`.`group`

UNION
SELECT
	"Mifos"								AS data_source,
    
    COUNT(office_id)					AS branches,
	COUNT(DISTINCT office_id)			AS dist_branches,
    COUNT(id) - COUNT(office_id) 		AS null_brchs,

	COUNT(staff_id)						AS users,
	COUNT(DISTINCT staff_id)			AS dist_usrs,
	COUNT(id) - COUNT(staff_id) 		AS null_usrs,
    
    COUNT(activation_date)				AS creationdates,
	COUNT(DISTINCT activation_date)		AS dist_crdats,
	COUNT(id) - COUNT(activation_date) 	AS null_crdates,
    
    COUNT(display_name)					AS groupnames,	
    COUNT(DISTINCT display_name)		AS distinct_gropnams,
	COUNT(id) - COUNT(display_name) 		AS null_grpnme,
    
	COUNT(external_id)					AS ids,
	COUNT(DISTINCT external_id)			AS distinct_ids,
	COUNT(id) - COUNT(external_id) 		AS null_ids,
    
	COUNT(parent_id)					AS centers,
	COUNT(DISTINCT parent_id)			AS dist_ctrs,
    COUNT(id) - COUNT(parent_id) 		AS null_ctrs   
FROM
	`mifos-guat`.m_group
WHERE
	level_id = 2
;

-- count mambu fields
-- 
-- SELECT
-- 	COUNT(encodedkey),
--     COUNT(DISTINCT encodedkey),
-- 
-- 	COUNT(assignedbranchkey),
-- 	COUNT(DISTINCT assignedbranchkey),
-- 
-- 	COUNT(assigneduserkey),
-- 	COUNT(DISTINCT assigneduserkey),
-- 	
--     COUNT(creationdate),
-- 	COUNT(DISTINCT creationdate),
-- 
--     COUNT(groupname),	
--     COUNT(DISTINCT groupname),
-- 
-- 	COUNT(id),
-- 	COUNT(DISTINCT id),
-- 
-- 	COUNT(lastmodifieddate),
-- 	COUNT(DISTINCT lastmodifieddate),
-- 
-- 	COUNT(loancycle),
-- 	COUNT(DISTINCT loancycle),
-- 
-- 	COUNT(assignedcentrekey),
-- 	COUNT(DISTINCT assignedcentrekey),
-- 
-- 	COUNT(mobilephone1),
-- 	COUNT(DISTINCT mobilephone1),
-- 
-- 	COUNT(homephone),
-- 	COUNT(DISTINCT homephone),
-- 
-- 	COUNT(emailaddress),
-- 	COUNT(DISTINCT emailaddress)
-- FROM 
-- 	`guat`.`group`
-- ;


-- 2) how many groups have hierarchy?

SELECT
	COUNT(hierarchy)
FROM
	`mifos-guat`.m_group
WHERE
	level_id = 2
; # 997


-- 3) which GROUPNAMES from Mambu did not show up in mifos?

SELECT 
	g.groupname,
    m_g.display_name
FROM
	`guat`.`group`				AS g

	LEFT JOIN
		`mifos-guat`.m_group		AS m_g	
		ON m_g.display_name = g.groupname
WHERE
	m_g.display_name is null
; #none


-- Do groups have the correct center? (check that m_group has parent_id to correct center)
	#	when I put the centre on to each group in mambu, then equivalently I put the parent on to each m_group,
    #	then I match the group to the m_group, does the centre match with the parent?
-- SELECT 
-- 	g.groupname									AS mamb_grpname # this matches m_g.display_name
--     #,g.id										AS mamb_grpid
--     ,g.centre_name								AS mamb_ctrID	-- is this the same?
--     ,m_g.display_name							AS mif_grpname	# this matches
--     #,m_g.external_id							AS mif_extid
--     ,m_g.mif_center								AS mifos_center	-- is this the same?
--     ,IF(g.centre_name = m_g.mif_center, 1, NULL) AS correct
-- FROM
-- 	# every group with its centre
-- 	(
-- 		SELECT
-- 			mambu_grp.groupname
-- 			,mambu_grp.id
--             ,mambu_ctrs.id						AS centre_name
-- 		FROM
-- 			`guat`.`group`				AS mambu_grp	
-- 		LEFT JOIN
-- 			`guat`.centre				AS mambu_ctrs 
-- 		ON mambu_grp.assignedcentrekey = mambu_ctrs.encodedkey
-- 	)											AS g
-- 
-- LEFT JOIN #match group to m_group.
-- 	(# every m_group with its parent
-- 		SELECT
-- 			m_g_grps.display_name
--             ,m_g_grps.external_id
--             ,m_g_ctrs.display_name		AS mif_center
-- 		FROM
-- 			`mifos-guat`.m_group AS m_g_grps
-- 
-- 		LEFT JOIN
-- 			`mifos-guat`.m_group AS m_g_ctrs
-- 			ON m_g_grps.parent_id = m_g_ctrs.id
-- 		WHERE
-- 			m_g_grps.level_id = 2
--     )									AS m_g 
--     ON g.id = m_g.external_id
-- ORDER BY correct
--  # 135 incorrect. 
--  # Some because the mifos group didn't exist. 
--  # some because it did, but didn't have the right center.
--  # some Mambu didn't have center -> null = null comes out to false.
-- ;

/*	-- Do centres and groups add up to m_groups?

SELECT
	"Mambu"								AS data_source
	,COUNT(name)						AS total_centers
FROM
	(
		SELECT
			name						AS name
		FROM
			`guat`.centre

		UNION
		SELECT
			groupname					AS name
		FROM
			`guat`.group
	)									AS `names`

UNION
SELECT
	"Mifos"								AS data_source
	,COUNT(*)							AS groups
FROM
	`mifos-guat`.m_group
;

SELECT
	''									AS dat_source
    ,''									AS tot_count
    ,''									AS centers
    ,''									AS groups
FROM
	(
		
;
*/

#########################################################################################

-- -----------------
-- Tests for Loans
-- -----------------

/* 

totals - make sure entire portfolio balance is there. Total loaned out, total repaid, total etc.
how many loans have interest 0.
loan older than a year with no repayments, still active.

*/

select * from `mifos-guat`.m_loan;
select * from `mifos-guat`.m_loan where group_id is not null;
SELECT * FROM `guat`.loanaccount;
select * from interestratesettings;
select * from loanproduct;


-- 1) TOTALS OF MONEY
#MAMBU
SELECT
	ACCOUNTHOLDERTYPE,
	SUM(LOANAMOUNT),
    SUM(PRINCIPALBALANCE),
    SUM(PRINCIPALPAID),
    SUM(INTERESTPAID),
    SUM(INTERESTBALANCE)
FROM
	`guat`.loanaccount
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
	`mifos-guat`.m_loan
GROUP BY
	ACCOUNTHOLDERTYPE
;

   
-- 2) loans with 0% interest, active with no repayments for a year.

SELECT
	c.firstname
    ,c.lastname
    ,g.groupname
    ,l.accountholdertype
    ,l.accountstate
    ,l.interestrate
    ,l.loanamount
    ,l.loanname
    ,l.principalbalance
    ,l.principalpaid
    ,l.principaldue
    ,l.interestdue
    ,l.feesdue
    ,l.penaltydue
    ,l.lastmodifieddate
    ,l.lastaccountappraisaldate
    ,l.creationdate
    ,l.approveddate
    ,l.disbursementdate
    ,l.firstrepaymentdate
	,l.rescheduledaccountkey
FROM
	`guat`.loanaccount									AS l
    
    LEFT JOIN
		`guat`.client									AS c
        ON c.encodedkey = l.accountholderkey
    
    LEFT JOIN
		`guat`.group									AS g
        ON g.encodedkey = l.accountholderkey
WHERE
		l.interestrate = 0
    AND (l.accountstate = "ACTIVE"
		OR l.accountstate = "ACTIVE_IN_ARREARS")
	AND l.lastmodifieddate < date_sub(curdate(), interval 1 year)
    
ORDER BY
	l.LASTMODIFIEDDATE
;


-- 3) Count relevant fields

SELECT
	"key"								AS field,
	COUNT(encodedkey)					AS count,
	COUNT(DISTINCT encodedkey)			AS count_distinct,
    COUNT(*) - COUNT(encodedkey) 		AS count_null
FROM
	`guat`.loanaccount
UNION
SELECT
	"accountholderkey"					AS field,
	COUNT(accountholderkey)				AS count,
	COUNT(DISTINCT accountholderkey)	AS count_distinct,
    COUNT(*) - COUNT(accountholderkey) 	AS count_null
FROM
	`guat`.loanaccount
UNION
SELECT
	"producttypekey"					AS field,
	COUNT(PRODUCTTYPEKEY)				AS count,
	COUNT(DISTINCT producttypekey)		AS count_distinct,
    COUNT(*) - COUNT(producttypekey) 	AS count_null
FROM
	`guat`.loanaccount
#UNION
#SELECT
#	"lineofcredit"							AS field,
#	COUNT(lineofcredit)					AS count,
#	COUNT(DISTINCT lineofcredit)			AS count_distinct,
#    COUNT(*) - COUNT(lineofcredit) 		AS count_null
#FROM
#	`guat`.loanaccount
UNION
SELECT
	"ASSIGNEDUSERKEY"					AS field,
	COUNT(ASSIGNEDUSERKEY)				AS count,
	COUNT(DISTINCT ASSIGNEDUSERKEY)		AS count_distinct,
    COUNT(*) - COUNT(ASSIGNEDUSERKEY) 	AS count_null
FROM
	`guat`.loanaccount
UNION
SELECT
	"loanamount"						AS field,
	COUNT(loanamount)					AS count,
	COUNT(DISTINCT loanamount)			AS count_distinct,
    COUNT(*) - COUNT(loanamount) 		AS count_null
FROM
	`guat`.loanaccount
UNION
SELECT
	"interestrate"						AS field,
	COUNT(interestrate)					AS count,
	COUNT(DISTINCT interestrate)		AS count_distinct,
    COUNT(*) - COUNT(interestrate) 		AS count_null
FROM
	`guat`.loanaccount
UNION
SELECT
	"INTERESTCALCULATIONMETHOD"			AS field,
	COUNT(INTERESTCALCULATIONMETHOD)	AS count,
	COUNT(DISTINCT INTERESTCALCULATIONMETHOD)			AS count_distinct,
    COUNT(*) - COUNT(INTERESTCALCULATIONMETHOD) 		AS count_null
FROM
	`guat`.loanaccount
UNION
SELECT
	"repaymentinstallments"				AS field,
	COUNT(repaymentinstallments)		AS count,
	COUNT(DISTINCT repaymentinstallments)			AS count_distinct,
    COUNT(*) - COUNT(repaymentinstallments) 		AS count_null
FROM
	`guat`.loanaccount

;

SELECT
	#"Mifos"								AS data_source,
	"accountno"							AS field,
	COUNT(account_no)					AS count,
	COUNT(DISTINCT account_no)			AS count_distinct,
    COUNT(*) - COUNT(account_no) 		AS count_null
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"client_ids"						AS field,
	COUNT(client_id)					AS count,
	COUNT(DISTINCT client_id)			AS count_distinct,
	COUNT(*) - COUNT(client_id) 		AS count_null
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"product_id"						AS field,    
    COUNT(product_id)					AS product_ids,
	COUNT(DISTINCT product_id)			AS dist_prod_ids,
	COUNT(*) - COUNT(product_id) 		AS null_prod_ids
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"fund_id"							AS field,    
    COUNT(fund_id)						AS fund_ids,	
    COUNT(DISTINCT fund_id)				AS distinct_fundid,
	COUNT(*) - COUNT(fund_id) 			AS null_fundid
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"loan_officer_id"					AS field,
	COUNT(loan_officer_id)				AS LO_ids,
	COUNT(DISTINCT loan_officer_id)		AS distinct_LO_ids,
	COUNT(*) - COUNT(loan_officer_id) 	AS null_LO_ids
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"principal_amount_proposed"			AS field,
	COUNT(principal_amount_proposed)	AS proposed,
	COUNT(DISTINCT principal_amount_proposed)	AS dist_proposed,
    COUNT(*) - COUNT(principal_amount_proposed) AS null_proposed
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"principal_amount"					AS field,
    COUNT(principal_amount)				AS amt,
	COUNT(DISTINCT principal_amount)	AS dist_amts,
    COUNT(*) - COUNT(principal_amount) 	AS null_amts
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"approved_principal"				AS field,    
    COUNT(approved_principal)			AS approved,
	COUNT(DISTINCT approved_principal)	AS dist_approved,
    COUNT(*) - COUNT(approved_principal) AS null_approved
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"nominal_interest_rate_per_period"	AS field,
    COUNT(nominal_interest_rate_per_period)	AS nom_int,
	COUNT(DISTINCT nominal_interest_rate_per_period)	AS dist_nom_int,
    COUNT(*) - COUNT(nominal_interest_rate_per_period) AS null_nom_int
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"interest_period_frequency_enum"	AS field,
    COUNT(interest_period_frequency_enum)	AS int_period,
	COUNT(DISTINCT interest_period_frequency_enum)	AS dist_int_period,
    COUNT(*) - COUNT(interest_period_frequency_enum) AS null_int_period
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"annual_nominal_interest_rate"		AS field,
    COUNT(annual_nominal_interest_rate)	AS annual_int,
	COUNT(DISTINCT annual_nominal_interest_rate)	AS dist_annual_int,
    COUNT(*) - COUNT(annual_nominal_interest_rate) AS null_annual_int
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"interest_method_enum"				AS field,
    COUNT(interest_method_enum)			AS int_method,
	COUNT(DISTINCT interest_method_enum)	AS dist_int_method,
    COUNT(*) - COUNT(interest_method_enum) AS null_int_method
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"interest_calculated_in_period_enum"	AS field,
    COUNT(interest_calculated_in_period_enum)	AS int_period,
	COUNT(DISTINCT interest_calculated_in_period_enum)	AS dist_int_period,
    COUNT(*) - COUNT(interest_calculated_in_period_enum) AS null_int_period
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"term_frequency"					AS field,
    COUNT(term_frequency)				AS freq,
	COUNT(DISTINCT term_frequency)		AS dist_freq,
    COUNT(*) - COUNT(term_frequency) 	AS null_freq
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"term_period_frequency_enum"		AS field,
    COUNT(term_period_frequency_enum)	AS freq_enum,
	COUNT(DISTINCT term_period_frequency_enum)	AS dist_freq_enum,
    COUNT(*) - COUNT(term_period_frequency_enum) AS null_freq_enum
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"repay_every"						AS field,
    COUNT(repay_every)					AS repay_every,
	COUNT(DISTINCT repay_every)			AS dist_r_every,
    COUNT(*) - COUNT(repay_every) 		AS null_re_every
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"repayment_period_frequency_enum"	AS field,
    COUNT(repayment_period_frequency_enum)	AS repay_enum,
	COUNT(DISTINCT repayment_period_frequency_enum)	AS dist_re_enum,
    COUNT(*) - COUNT(repayment_period_frequency_enum) AS null_re_enum
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"repayment_frequency_day_of_week_enum"	AS field,
    COUNT(repayment_frequency_day_of_week_enum)	AS day_enum,
	COUNT(DISTINCT repayment_frequency_day_of_week_enum)	AS dist_day,
    COUNT(*) - COUNT(repayment_frequency_day_of_week_enum) AS null_re_day
FROM
	`mifos-guat`.m_loan	
UNION
SELECT
	"number_of_repayments"				AS field,
    COUNT(number_of_repayments)			AS num_repay,
	COUNT(DISTINCT number_of_repayments)	AS dist_num_repay,
    COUNT(*) - COUNT(number_of_repayments)	AS null_num_repay
FROM
	`mifos-guat`.m_loan
;


-- 4) check that INTEREST RATES MATCH UP

SELECT
	IF(l.interestrate = m_l.nominal_interest_rate_per_period, 
		"yes", 
        "no")											AS correct
    ,COUNT(*)											AS count
FROM
	`guat`.loanaccount 									AS l

	LEFT JOIN
		`mifos-guat`.m_loan								AS m_l
		ON
		l.encodedkey = m_l.external_id
GROUP BY
	correct
; # yes 2933

-- SELECT * FROM `guat`.loanaccount la; 	#IDENTIFIERS: 	assigned user,	id, loanamount, 		installments,			assigned centre,	account holder,	assigned branch,	accountholdertype,
-- SELECT * FROM 	`mifos-guat`.m_loan; 	#l				loan ooicer id,	?,	principal_amaount, 	number_of_repayments,	group_id,				 
-- 
-- SELECT
-- 	# IF(mambu.interest = mifos.interest, "match", null)	AS matching_interest
-- 	*
-- FROM
-- (
-- 	SELECT
-- 		'Mambu'										AS src
-- 		,l.ENCODEDKEY
-- 		,l.INTERESTRATE								AS interest
-- 		,l.LOANAMOUNT
-- 		,l.REPAYMENTINSTALLMENTS
-- 		,cntr.name									AS CENTRE_NAME
-- 		,b.name										AS BRANCH_NAME
-- 		,CONCAT(u.FIRSTNAME, " ", u.LASTNAME)		AS USER_NAME
-- 		,if(cli.firstname is null, g.groupname, CONCAT(cli.FIRSTNAME, " ", cli.LASTNAME))	AS CLIENT_NAME
-- 		,l.ACCOUNTHOLDERTYPE						AS ACCOUNTHOLDER_TYPE
-- 	FROM
-- 		`guat`.loanaccount l
-- 
-- 	LEFT JOIN
-- 		`guat`.centre cntr
-- 		ON cntr.encodedkey = l.ASSIGNEDCENTREKEY
-- 
-- 	LEFT JOIN
-- 		`guat`.client cli
-- 		ON cli.encodedkey = l.accountholderkey
-- 
-- 	LEFT JOIN
-- 		`guat`.user u
-- 		ON u.encodedkey = l.ASSIGNEDUSERKEY
-- 
-- 	LEFT JOIN
-- 		`guat`.branch b
-- 		ON b.encodedkey = l.ASSIGNEDBRANCHKEY
-- 
-- 	LEFT JOIN
-- 		`guat`.group g
-- 		ON g.encodedkey = l.accountholderkey
-- )													AS mambu
-- 
-- LEFT JOIN
-- (
-- 	SELECT
-- 		'Mifos'											AS src
-- 		,l.id
-- 		,l.nominal_interest_rate_per_period				AS interest
-- 		,l.principal_amount
-- 		,l.number_of_repayments
-- 		,g.display_name									AS CENTRE_NAME
-- 		,o.name											AS BRANCH_NAME
-- 		,CONCAT(s.FIRSTNAME, " ", s.LASTNAME)			AS USER_NAME
-- 		,if(cli.firstname is null, g.display_name, CONCAT(cli.FIRSTNAME, " ", cli.LASTNAME))	AS CLIENT_NAME
-- 		,IF(l.loan_type_enum = 1, 'CLIENT', 'GROUP')	AS ACCOUNTHOLDER_TYPE
-- 		,if(s.office_id = cli.office_id, 1, null)			AS match_office_id
-- 	FROM
-- 		`mifos-guat`.m_loan l
-- 
-- 	LEFT JOIN
-- 		`mifos-guat`.m_group g
-- 		ON	g.id = l.group_id
-- 
-- 	LEFT JOIN
-- 		`mifos-guat`.m_client cli
-- 		ON cli.id = l.client_id
-- 
-- 	LEFT JOIN
-- 		`mifos-guat`.m_staff s
-- 		ON s.id = l.loan_officer_id
-- 
-- 	LEFT JOIN
-- 		`mifos-guat`.m_office o
-- 		ON o.id = cli.office_id
-- )												AS mifos
-- 	ON
-- 	mambu.loanamount = mifos.principal_amount
--     AND
--     mambu.repaymentinstallments = mifos.number_of_repayments
--     AND
--     mambu.accountholder_type = mifos.accountholder_type
--     #AND
--     #mambu.interest = mifos.interest
--     AND
--     mambu.client_name = mifos.client_name
--     #AND
--     #mambu.user_name = mifos.user_name
--     #AND
--     #mambu.centre_name = mifos.centre_name
--     AND
--     mambu.branch_name = mifos.branch_name
-- WHERE
-- #	mifos.src is null
-- 	mambu.branch_name = 'Patzicía'
-- 
-- ;
-- 
-- 
-- select * from `mifos-guat`.m_client;
-- select * from `mifos-guat`.m_staff;
-- select * from `mifos-guat`.m_office;
-- select * from `mifos-guat`.m_group;
-- select * from `mifos-guat`.m_loan;
-- 
-- ;
-- 
-- -- see if they have the same loan officer. Doesn't work this way.
-- -- SELECT
-- -- la.encodedkey
-- -- FROM
-- -- `guat`.loanaccount la
-- -- LEFT JOIN
-- -- `mifos-guat`.m_loan m_l
-- -- ON
-- -- la.assigneduserkey = m_l.loan_officer_id
-- -- WHERE
-- -- m_l.id is not null
-- -- ;
-- -- 
-- 
-- SELECT
-- 	l.nominal_interest_rate_per_period
--     ,c.display_name
--     ,c.firstname
--     ,c.lastname
--     #,isMatching
-- FROM
-- 	`mifos-guat`.m_loan l
-- 
-- LEFT JOIN
-- 	`mifos-guat`.m_client c
-- 	ON
-- 	c.id = l.client_id
-- ;
-- 
-- SELECT
-- 	interestrate
--     ,nam
-- FROM
-- 	`guat`.loanaccount l
-- 
-- LEFT JOIN
-- 	(
-- 		SELECT
-- 			firstname							AS nam
-- 			,encodedkey							AS encod
-- 		FROM
-- 			`guat`.`client` c
-- 		
-- 		UNION
-- 		SELECT
-- 			groupname							AS nam
-- 			,encodedkey							AS encod
-- 		FROM
-- 			`guat`.`group` g
-- 	)											AS cg
-- 	ON
-- 	cg.encod = l.accountholderkey
-- ;


-- 5) does each client have the right amount of loans?

SELECT
	mambu.disp_name
    ,mambu.loans
    ,mifos.loans
    ,IF (mambu.loans = mifos.loans, "correct", null)	AS correct
FROM
(
	SELECT 
		CONCAT(c.FIRSTNAME,' ',c.LASTNAME)			AS disp_name
		,COUNT(l.ENCODEDKEY)						AS loans
        ,c.ENCODEDKEY								AS mambu_id
	FROM
		`guat`.`client` 						AS c

	LEFT JOIN
		`guat`.loanaccount 					AS l
		ON c.encodedkey = l.ACCOUNTHOLDERKEY
	GROUP BY c.encodedkey
)													AS mambu

LEFT JOIN
(
	SELECT 
		m_c.display_name							AS disp_name
		,COUNT(m_l.id)								AS loans
        ,m_c.external_id
	FROM
		`mifos-guat`.m_client 				AS m_c

	LEFT JOIN
		`mifos-guat`.m_loan 				AS m_l
		ON m_c.id = m_l.client_id
	GROUP BY m_c.id
)													AS mifos
ON 
	mambu.mambu_id = mifos.external_id
ORDER BY
	correct
;


-- 6) does each GROUP have the righ amount of loans?

SELECT
	mambu.disp_name
    ,mambu.loans
    ,mifos.loans
    ,IF (mambu.loans = mifos.loans, "correct", null)	AS correct
FROM
(
	SELECT
		g.groupname										AS disp_name
		,COUNT(l.ENCODEDKEY)							AS loans
        ,g.ENCODEDKEY									AS mambu_id
	FROM
		`guat`.`group` 									AS g

	LEFT JOIN
		`guat`.loanaccount 								AS l
		ON g.encodedkey = l.ACCOUNTHOLDERKEY
	GROUP BY g.encodedkey
)														AS mambu

LEFT JOIN
(
	SELECT 
		m_g.display_name								AS disp_name
		,COUNT(m_l.id)									AS loans
        ,m_g.external_id
	FROM
		`mifos-guat`.m_group 							AS m_g

		LEFT JOIN
			`mifos-guat`.m_loan 						AS m_l
			ON m_g.id = m_l.client_id
	GROUP BY m_g.id
)														AS mifos
ON 
	mambu.mambu_id = mifos.external_id
#WHERE
#	mifos.external_id is null
ORDER BY
	correct
;

-- select * from `guat`.group; #988
-- select * from `mifos-guat`.m_group; #1181
-- #where client_id is null
-- order by group_id, client_id
-- ;




-- ----------------
-- Tests for Loan Transaction
-- -----------------


SELECT * FROM `mifos-guat`.m_loan_transaction;
SELECT * FROM `guat`.loantransaction;

SELECT * FROM `mifos-guat`.m_payment_detail; # just id and payment type. HThis id is referenced in m_loan_transaction

-- enum_id	| enum value					MAMBU's enum
-- -----------------------------------------------------------
-- 1		| Disbursement					-- 'DISBURSMENT'
-- '2', 	|'Repayment',					-- 'REPAYMENT'
-- '3', 	|'Contra', 						
-- '4',	 	|'Waive Interest', 				
-- '5', 	|'Repayment At Disbursement',	
-- '6', 	|'Write-Off',					
-- '7', 	|'Marked for Rescheduling'		
-- '8', 	|'Recovery Repayment'			
-- '9', 	|'Waive Charges'				
-- '10', 	|'Apply Charges'				
-- '11', 	|'Apply Interest' 				-- 'INTEREST_APPLIED'-- 'INTEREST_APPLIED_ADJUSTMENT'
;
SELECT DISTINCT `TYPE` FROM `guat`.loantransaction;
-- 'INTEREST_APPLIED'
											-- 'DEFERRED_INTEREST_PAID'	
-- 'DISBURSMENT'
											-- 'IMPORT'
-- 'REPAYMENT'
											-- 'FEE'
											-- 'FEES_DUE_REDUCED'
											-- 'FEE_ADJUSTMENT'
											-- 'DISBURSMENT_ADJUSTMENT'
-- 'DEFERRED_INTEREST_APPLIED'
-- 'REPAYMENT_ADJUSTMENT'
-- 'INTEREST_DUE_REDUCED'
-- 'DEFERRED_INTEREST_PAID_ADJUSTMENT'
-- 'INTEREST_APPLIED_ADJUSTMENT'
-- 'FEE_REDUCTION_ADJUSTMENT'
-- 'INTEREST_REDUCTION_ADJUSTMENT'
-- 'FEE_LOCKED'
-- 'PENALTY_LOCKED'
-- 'FEE_UNLOCKED'
-- 'PENALTY_UNLOCKED'
-- 'DEFERRED_INTEREST_APPLIED_ADJUSTMENT'
-- 'BRANCH_CHANGED'
-- 'TRANSFER'
-- 'INTEREST_LOCKED'
-- 'INTEREST_UNLOCKED'
-- 'WRITE_OFF'


-- see if mambu matches up with mifos
# same number of records
# same unique ids
#etc.

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
	'Mifos'										AS src,
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


-- see if every loan has a disbursement

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

-- SELECT * FROM `mifos-guat`.m_loan_transaction;
-- SELECT * FROM `guat`.loantransaction;
-- 
-- SELECT * FROM `mifos-guat`.m_loan;
-- SELECT * FROM `guat`.loanaccount;




#########################################################################################

-- -----------------
-- Tests for Loan Repayment History
-- -----------------

#SELECT * FROM `mifos-guat`.m_payment_detail; # just id and payment type. HThis id is referenced in m_loan_transaction

SELECT * FROM `guat`.repayment;
SHOW COLUMNS FROM `guat`.repayment;
show create table `guat`.repayment;

select * from `mifos-guat`.m_loan; 

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

-- loan_id
# see if each loan_id corresponds to the correct loan

# maybe look at the repayment's corresponding loan, then see if





#########################################################################################

-- -----------------
-- Tests for Savings Product
-- -----------------

-- by hand




#########################################################################################

-- -----------------
-- Tests for Savings
-- -----------------

-- matches with mambu

SELECT * FROM `mifos-guat`.m_savings_account; #NULL

SELECT * FROM `mifos-guat`.m_savings_account_charge; #NULL
SELECT * FROM `mifos-guat`.m_savings_account_charge_paid_by; #NULL. has amount field
SELECT * FROM `mifos-guat`.m_savings_account_interest_rate_chart;#NULL
SELECT * FROM `mifos-guat`.m_savings_account_interest_rate_slab;

SELECT * FROM `mifos-guat`.m_savings_account_transaction; #NULL. Has balance, transacitons, etc.

SELECT * FROM `mifos-guat`.m_savings_interest_incentives;
SELECT * FROM `mifos-guat`.m_savings_product;
SELECT * FROM `mifos-guat`.m_savings_product_charge;
SELECT * FROM `mifos-guat`.m_client;
SELECT * FROM `guat`.savingsaccount; #NULL


-- totals match
-- SELECT 
-- 	SUM(BALANCE), # the prolem with this is, if I have the wrong number of records, the total won't be right, and it has to map to the records of the other database, which might only be the transactions. adding the balances of each transaction record will be way different thatn adding balances of savings accounts. 
--     SUM(ACCRUEDINTEREST),
--     SUM(INTERESTDUE)
-- FROM `guat`.savingsaccount; #NULL
-- 
-- SELECT 
-- 	SUM(BALANCE),
--     SUM(ACCRUEDINTEREST),
--     SUM(INTERESTDUE)
-- FROM `mifos-guat`.m_savings_account
-- ;

#########################################################################################

-- -----------------
