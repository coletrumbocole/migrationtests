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

SELECT * FROM input_db.savingsaccount;

SHOW COLUMNS FROM `mifostenant-default`.m_savings_account;
SHOW COLUMNS FROM phil.savingsaccount;

SHOW CREATE TABLE `mifostenant-default`.m_savings_account;

-- count relevant fields
	-- ENCODEDKEY
	-- ACCOUNTHOLDERKEY
	-- PRODUCTTYPEKEY
	-- ASSIGNEDUSERKEY
	-- ACCOUNTSTATE
	-- ACCOUNTTYPE
	-- APPROVEDDATE
	-- INTERESTRATE
	-- INTERESTCALCULATIONFREQUENCY
	-- ACTIVATIONDATE
	-- CLOSEDDATE
	-- ALLOWOVERDRAFT
	-- OVERDRAFTLIMIT
	-- OVERDRAFTINTERESTRATE
	-- MATURITYDATE
	-- ACCRUEDINTEREST
	-- OVERDRAFTINTERESTACCRUED
	-- BALANCE
	-- APPROVEDDATE
	-- INTERESTRATE
	-- INTERESTCALCULATIONFREQUENCY
	-- ACTIVATIONDATE
	-- CLOSEDDATE
	-- ALLOWOVERDRAFT
	-- OVERDRAFTLIMIT
	-- OVERDRAFTINTERESTRATE
	-- MATURITYDATE
	-- ACCRUEDINTEREST
	-- OVERDRAFTINTERESTACCRUED
	-- BALANCE

SELECT
	"Mambu"												AS src
	,COUNT(encodedkey)									AS count_records

	,COUNT(accountholderkey)							AS cli_ids
	,COUNT(DISTINCT accountholderkey)					AS dist_cli
	,COUNT(*) - COUNT(accountholderkey)					AS null_cli

	,COUNT(producttypekey)								AS prod_ids
	,COUNT(DISTINCT producttypekey)						AS dist_prod
	,COUNT(*) - COUNT(producttypekey)					AS null_prod

	,COUNT(assigneduserkey)								AS usr_ids
	,COUNT(DISTINCT assigneduserkey)					AS dist_usr
	,COUNT(*) - COUNT(assigneduserkey)					AS null_usr

	,COUNT(accountstate)								AS states
	,COUNT(DISTINCT accountstate)						AS dist_state
	,COUNT(*) - COUNT(accountstate)						AS null_state

	,COUNT(accounttype)									AS types
	,COUNT(DISTINCT accounttype)						AS dist_type
	,COUNT(*) - COUNT(accounttype)						AS null_type

	,COUNT(approveddate)								AS appr
	,COUNT(DISTINCT approveddate)						AS dist_appr
	,COUNT(*) - COUNT(approveddate)						AS null_appr

	,COUNT(interestrate)								AS rates
	,COUNT(DISTINCT interestrate)						AS dist_rates
	,COUNT(*) - COUNT(interestrate)						AS null_rates

	,COUNT(INTERESTCALCULATIONFREQUENCY)				AS freq
	,COUNT(DISTINCT INTERESTCALCULATIONFREQUENCY)		AS dist_freq
	,COUNT(*) - COUNT(INTERESTCALCULATIONFREQUENCY)		AS null_freq

	,COUNT(activationdate)								AS actdates
	,COUNT(DISTINCT activationdate)						AS dist_actdates
	,COUNT(*) - COUNT(activationdate)					AS null_actdates

	,COUNT(closeddate)									AS closedates
	,COUNT(DISTINCT closeddate)							AS dist_closedates
	,COUNT(*) - COUNT(closeddate)						AS null_closedates

	,COUNT(allowoverdraft)								AS allow
	,COUNT(DISTINCT allowoverdraft)						AS dist_allow
	,COUNT(*) - COUNT(allowoverdraft)					AS null_allow

	,COUNT(overdraftlimit)								AS limits
	,COUNT(DISTINCT overdraftlimit)						AS dist_limits
	,COUNT(*) - COUNT(overdraftlimit)					AS null_limits

	,COUNT(overdraftinterestrate)						AS odints
	,COUNT(DISTINCT overdraftinterestrate)				AS dist_odints
	,COUNT(*) - COUNT(overdraftinterestrate)			AS null_odints

	,COUNT(maturitydate)								AS maturities
	,COUNT(DISTINCT maturitydate)						AS dist_maturities
	,COUNT(*) - COUNT(maturitydate)						AS null_maturities

	,COUNT(accruedinterest)								AS int_count
	,COUNT(DISTINCT accruedinterest)					AS dist_int
	,COUNT(*) - COUNT(accruedinterest)					AS null_int

	,COUNT(OVERDRAFTINTERESTACCRUED)					AS odintaccrueds
	,COUNT(DISTINCT OVERDRAFTINTERESTACCRUED)			AS dist_odintaccrueds
	,COUNT(*) - COUNT(OVERDRAFTINTERESTACCRUED)			AS null_odintaccrueds

	,COUNT(balance)										AS bal_count
	,COUNT(DISTINCT balance)							AS dist_bal
	,COUNT(*) - COUNT(balance)							AS null_bal

FROM
	phil.savingsaccount

UNION
SELECT
	"mifos"												AS src
	,COUNT(id)											AS count_records

	,COUNT(client_id)									AS cli_ids
	,COUNT(DISTINCT client_id)							AS dist_cli
	,COUNT(*) - COUNT(client_id)						AS null_cli

	,COUNT(product_id)									AS prod_ids
	,COUNT(DISTINCT product_id)							AS dist_prod
	,COUNT(*) - COUNT(product_id)						AS null_prod

	,COUNT(field_officer_id)							AS usr_ids
	,COUNT(DISTINCT field_officer_id)					AS dist_usr
	,COUNT(*) - COUNT(field_officer_id)					AS null_usr

	,COUNT(status_enum)									AS states
	,COUNT(DISTINCT status_enum)						AS dist_state
	,COUNT(*) - COUNT(status_enum)						AS null_state

	,COUNT(account_type_enum)							AS types
	,COUNT(DISTINCT account_type_enum)					AS dist_type
	,COUNT(*) - COUNT(account_type_enum)				AS null_type

	,COUNT(approvedon_date)								AS appr
	,COUNT(DISTINCT approvedon_date)					AS dist_appr
	,COUNT(*) - COUNT(approvedon_date)					AS null_appr

	,COUNT(nominal_annual_interest_rate)				AS rates
	,COUNT(DISTINCT nominal_annual_interest_rate)		AS dist_rates
	,COUNT(*) - COUNT(nominal_annual_interest_rate)		AS null_rates

	,COUNT(interest_compounding_period_enum)			AS freq
	,COUNT(DISTINCT interest_compounding_period_enum)	AS dist_freq
	,COUNT(*) - COUNT(interest_compounding_period_enum)	AS null_freq

	,COUNT(activatedon_date)							AS actdates
	,COUNT(DISTINCT activatedon_date)					AS dist_actdates
	,COUNT(*) - COUNT(activatedon_date)					AS null_actdates

	,COUNT(closedon_date)								AS closedates
	,COUNT(DISTINCT closedon_date)						AS dist_closedates
	,COUNT(*) - COUNT(closedon_date)					AS null_closedates

	,COUNT(allow_overdraft)								AS allow
	,COUNT(DISTINCT allow_overdraft)					AS dist_allow
	,COUNT(*) - COUNT(allow_overdraft)					AS null_allow

	,COUNT(overdraft_limit)								AS limits
	,COUNT(DISTINCT overdraft_limit)					AS dist_limits
	,COUNT(*) - COUNT(overdraft_limit)					AS null_limits

	,COUNT(nominal_annual_interest_rate_overdraft)		AS odints
	,COUNT(DISTINCT nominal_annual_interest_rate_overdraft)	AS dist_odints
	,COUNT(*) - COUNT(nominal_annual_interest_rate_overdraft)	AS null_odints

	,COUNT(lockedin_until_date_derived)					AS maturities
	,COUNT(DISTINCT lockedin_until_date_derived)		AS dist_maturities
	,COUNT(*) - COUNT(lockedin_until_date_derived)		AS null_maturities

	,COUNT(total_interest_earned_derived)				AS int_count
	,COUNT(DISTINCT total_interest_earned_derived)		AS dist_int
	,COUNT(*) - COUNT(total_interest_earned_derived)	AS null_int

	,COUNT(total_overdraft_interest_derived)			AS odintaccrueds
	,COUNT(DISTINCT total_overdraft_interest_derived)	AS dist_odintaccrueds
	,COUNT(*) - COUNT(total_overdraft_interest_derived)	AS null_odintaccrueds

	,COUNT(account_balance_derived)						AS bal_count
	,COUNT(DISTINCT account_balance_derived)			AS dist_bal
	,COUNT(*) - COUNT(account_balance_derived)			AS null_bal
FROM
	`mifostenant-default`.m_savings_account
;


-- totals match

SELECT
	accountHOLDERtype								AS acchldrtype
	,SUM(BALANCE)									AS tot_balance
    ,SUM(ACCRUEDINTEREST)							AS tot_interest
    ,SUM(overdraftinterestaccrued)					AS tot_odinterest
    #,SUM(INTERESTDUE)								AS tot_intdue
    ,SUM(feesdue)									AS tot_feedue
FROM phil.savingsaccount
GROUP BY acchldrtype
;

SELECT 
	IF(group_id is null
		AND
        client_id is not null,
        "CLIENT",
        "GROUP")									AS acchldrtype
	,SUM(account_balance_derived)					AS tot_balance
    ,SUM(total_interest_earned_derived)				AS tot_interest
    ,SUM(total_overdraft_interest_derived)			AS tot_odinterest
	#,SUM(INTERESTDUE)								AS tot_intdue
    ,SUM(total_fees_charge_derived)					AS tot_feedue
FROM `mifostenant-default`.m_savings_account
GROUP BY acchldrtype
;


-- Does it preserve CLIENT and GROUP?

SELECT
	COUNT(*)											AS count_CLIENT
	,COUNT(IF(m_sav.client_id is not null, 1, NULL))	AS count_cli_id
FROM
	phil.savingsaccount									AS sa
	,`mifostenant-default`.m_savings_account			AS m_sav
WHERE
	m_sav.external_id = sa.encodedkey
	AND
    sa.accountholdertype = 'CLIENT'
;

SELECT
	COUNT(*)											AS count_GROUP
	,COUNT(IF(m_sav.group_id is not null, 1, NULL))		AS count_gr_id
FROM
	phil.savingsaccount									AS sa
	,`mifostenant-default`.m_savings_account			AS m_sav
WHERE
	m_sav.external_id = sa.encodedkey
	AND
    sa.accountholdertype = 'GROUP'
;

#?
SELECT
    sa.accountholdertype
    ,IF(
		m_sav.client_id IS NOT NULL
			AND
			sa.accountholdertype = "CLIENT",
        "yes",
        "no"
    )													AS matching_client_type
    ,IF(
		m_sav.group_id IS NOT NULL
			AND
			sa.accountholdertype = "GROUP",
        "yes",
        "no"
    )													AS matching_group_type
FROM
	phil.savingsaccount									AS sa
	,`mifostenant-default`.m_savings_account			AS m_sav
WHERE
	m_sav.external_id = sa.encodedkey
;


-- see if totals are correct by account holder

SELECT
	accountholdertype
	,accountholderkey
    ,SUM(sa.balance)									AS tot_balance
    ,SUM(m_sav.account_balance_derived)					AS tot_m_balance
FROM
	phil.savingsaccount									AS sa
	,`mifostenant-default`.m_savings_account			AS m_sav
WHERE
	m_sav.external_id = sa.encodedkey
GROUP BY 
	accountholdertype, 
    accountholderkey
;



-- matches with mambu

