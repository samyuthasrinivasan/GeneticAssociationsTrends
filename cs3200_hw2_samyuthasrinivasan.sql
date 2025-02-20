-- CS3200: Database Design
-- GAD: The Genetic Association Database


-- Write a query to answer each of the following questions
-- Save your script file as cs3200_hw2_yourname.sql (no spaces)
-- Submit this file for your homework submission


use gad;

-- 1. 
-- Explore the content of the various columns in your gad table.
-- List all genes that are "G protein-coupled" receptors in alphabetical order by gene symbol
-- Output the gene symbol, gene name, and chromosome
-- (These genes are often the target for new drugs, so are of particular interest)


SELECT gene as gene_symbol, gene_name, chromosome
FROM gad
WHERE gene_name LIKE '%G protein-coupled%'
ORDER BY gene_name;

-- 2. 
-- How many records are there for each disease class?
-- Output your list from most frequent to least frequent
 
SELECT disease_class, COUNT(*) AS record_count
FROM gad
GROUP BY disease_class
ORDER BY record_count DESC;

-- 3. 
-- List all distinct phenotypes related to the disease class "IMMUNE"
-- Output your list in alphabetical order

SELECT DISTINCT phenotype
from gad
where disease_class = 'IMMUNE'
ORDER BY phenotype ASC;

-- 4.
-- Show the immune-related phenotypes
-- based on the number of records reporting a positive association with that phenotype.
-- Display both the phenotype and the number of records with a positive association
-- Only report phenotypes with at least 60 records reporting a positive association.
-- Your list should be sorted in descending order by number of records
-- Use a column alias: "num_records"

SELECT phenotype, COUNT(*) AS num_records
FROM gad
WHERE disease_class = 'IMMUNE' 
  AND association = 'Y'
GROUP BY phenotype
HAVING COUNT(*) >= 60
ORDER BY num_records DESC;

-- 5.
-- List the gene symbol, gene name, and chromosome attributes related
-- to genes positively linked to asthma (association = Y).
-- Include in your output any phenotype containing the substring "asthma"
-- List each distinct record once
-- Sort  gene symbol

SELECT DISTINCT gene AS gene_symbol, gene_name, chromosome
from gad
where association = "Y" and phenotype LIKE "%asthma%"
ORDER BY gene_symbol;

-- 6. 
-- For each chromosome, over what range of nucleotides do we find
-- genes mentioned in GAD?
-- Exclude cases where the dna_start value is 0 or where the chromosome is unlisted.
-- Sort your data by chromosome. Don't be concerned that
-- the chromosome values are TEXT. (1, 10, 11, 12, ...)

SELECT chromosome, MIN(dna_start) AS start_range, MAX(dna_end) AS end_range
FROM gad
WHERE dna_start > 0 
  AND chromosome IS NOT NULL
GROUP BY chromosome
ORDER BY chromosome;

-- 7 
-- For each gene, what is the earliest and latest reported year
-- involving a positive association
-- Ignore records where the year isn't valid. (Explore the year column to determine what constitutes a valid year.)
-- Output the gene, min-year, max-year, and number of GAD records
-- order from most records to least.
-- Columns with aggregation functions should be aliased

SELECT gene AS gene_symbol, MIN(year) AS min_year, MAX(year) AS max_year, COUNT(*) AS num_records
FROM gad
WHERE association = 'Y' 
  AND year REGEXP '^[0-9]{4}$'
GROUP BY gene
ORDER BY num_records DESC;

-- 8. 
-- Which genes have a total of at least 100 positive association records (across all phenotypes)?
-- Give the gene symbol, gene name, and the number of associations
-- Use a 'num_records' alias in your query wherever possible

SELECT gene AS gene_symbol, gene_name, COUNT(*) AS num_records
FROM gad
WHERE association = 'Y'
GROUP BY gene, gene_name
HAVING num_records >= 100
ORDER BY num_records DESC;

-- 9. 
-- How many total GAD records are there for each population group?
-- Sort in descending order by count
-- Show only the top five results based on number of records
-- Do NOT include cases where the population is blank

SELECT population, COUNT(*) AS num_records
FROM gad
WHERE population IS NOT NULL AND population <> ''
GROUP BY population
ORDER BY num_records DESC
LIMIT 5;

-- 10. 
-- In question 5, we found asthma-linked genes
-- But these genes might also be implicated in other diseases
-- Output gad records involving a positive association between ANY asthma-linked gene and ANY disease/phenotype
-- Sort your output alphabetically by phenotype
-- Output the gene, gene_name, association (should always be 'Y'), phenotype, disease_class, and population
-- Hint: Use a subselect in your WHERE class and the IN operator

SELECT gene AS gene_symbol, gene_name, association, phenotype, disease_class, population
FROM gad
WHERE association = 'Y' 
  AND gene IN (
      SELECT DISTINCT gene
      FROM gad
      WHERE association = 'Y' 
        AND LOWER(phenotype) LIKE '%asthma%'
  )
ORDER BY phenotype ASC;

-- 11. 
-- Modify your previous query.
-- Let's count how many times each of these asthma-gene-linked phenotypes occurs
-- in our output table produced by the previous query.
-- Output just the phenotype, and a count of the number of occurrences for the top 5 phenotypes
-- with the most records involving an asthma-linked gene (EXCLUDING asthma itself).

SELECT phenotype, COUNT(*) AS num_records
FROM gad
WHERE association = 'Y' 
  AND gene IN (
      SELECT DISTINCT gene
      FROM gad
      WHERE association = 'Y' 
        AND LOWER(phenotype) LIKE '%asthma%'
  )
  AND LOWER(phenotype) NOT LIKE '%asthma%'
GROUP BY phenotype
ORDER BY num_records DESC
LIMIT 5;

-- 12. 
-- Interpret your analysis

-- a) Search the Internet. Does existing biomedical research support a connection between asthma and the
-- top phenotype you identified above? Cite some sources and justify your conclusion!

-- Existing biomedical research does support a connection between asthma and type 1 diabetes.
 
-- Source 1: https://pmc.ncbi.nlm.nih.gov/articles/PMC4616625/#:~:text=Compared%20with%20the%20control%20cohort,than%20twice%20for%20their%20diabetes.
-- According to research published by the NCBI, type 1 diabetes patients with more than 2 ER visits for diabetes had a higher hazard ratio of 17.4 (95% CI = 12.9–23.6) for developing asthma.
-- This demonstrates a connection for patients between their diagnosis of t1 diabetes and their high hazard ratios for astha.

-- Source 2: https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2762680#:~:text=Siblings%20of%20individuals%20with%20asthma,one%20disease%20with%20the%20other.
-- This article highlights data that indicates children who had asthma were shown to be at a higher risk for developing type 1 diabetes. 
-- "Children with asthma had an increased risk of subsequent type 1 diabetes (hazard ratio, 1.16; 95% CI, 1.06-1.27)."
 
-- b) Why might a drug company be interested in instances of such "overlapping" phenotypes?

-- Drug companies might be interested in such overlapping phenotypes because understanding what they have in common can help 
-- them come up with treatments that can target multiple diseases. This can streamline the development of drugs by expanding
-- the applications of various existing and new drugs. 

-- CONGRATULATIONS!!: YOU JUST DID SOME LEGIT DRUG DISCOVERY RESEARCH! :-)

SELECT year, COUNT(*) AS num_records 
    FROM gad 
    WHERE association = 'Y' 
      AND LOWER(phenotype) LIKE '%alzheimer%' 
      AND year REGEXP '^[0-9]{4}$' 
    GROUP BY year 
    ORDER BY year ASC;
    
-- query used for the poster ^^

