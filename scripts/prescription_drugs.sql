--1. 
-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 1912011792 & 4538
SELECT prescriber.npi, prescription.total_claim_count 
INNER JOIN prescriber USING (npi)
ORDER BY prescription.total_claim_count DESC;
-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT prescriber.nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, prescription.total_claim_count
FROM prescription
INNER JOIN prescriber USING (npi)
ORDER BY prescription.total_claim_count DESC;

--2. 
-- a. Which specialty had the most total number of claims (totaled over all drugs)? Family Practice
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS claim_count
FROM prescription
INNER JOIN prescriber USING (npi)
GROUP BY prescriber.specialty_description
ORDER BY claim_count DESC;
-- b. Which specialty had the most total number of claims for opioids? Nurse Practioner
SELECT p2.specialty_description, SUM(p1.total_claim_count) AS claim_count
FROM prescription AS p1
INNER JOIN prescriber AS p2 USING (npi)
INNER JOIN drug USING (drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY p2.specialty_description
ORDER BY claim_count DESC;
-- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?


--3. 
-- a. Which drug (generic_name) had the highest total drug cost? insulin
SELECT generic_name, SUM(total_drug_cost) as drug_cost
FROM prescription
INNER JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY drug_cost DESC;
-- b. Which drug (generic_name) has the hightest total cost per day? C1 Esterase Inhibitor
SELECT generic_name, SUM(total_drug_cost)/SUM(total_day_supply) as drug_cost
FROM prescription
INNER JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY drug_cost DESC;
--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

--4.
-- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;
-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN prescription.total_drug_cost::money END) as opioid_cost,
	SUM(CASE WHEN antibiotic_drug_flag = 'Y' THEN prescription.total_drug_cost::money END) as antibiotic_cost
FROM drug
INNER JOIN prescription USING (drug_name);

--5. 
-- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT (DISTINCT cbsa)
FROM cbsa
INNER JOIN fips_county USING (fipscounty)
WHERE fips_county.state = 'TN';
-- b. Which cbsa has the largest combined population? 34980,1830410 Which has the smallest? 34100,116352 Report the CBSA name and total population.
SELECT cbsa.cbsa, SUM(population) as pop
FROM cbsa
INNER JOIN population USING (fipscounty)
GROUP BY cbsa.cbsa
ORDER BY pop DESC;
-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT population.fipscounty, population.population, cbsa
FROM population
INNER JOIN cbsa USING (fipscounty)
WHERE cbsa IS NULL
