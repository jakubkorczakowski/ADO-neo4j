LOAD CSV WITH HEADERS FROM "file:///combined_final_last_10_years.csv" AS row
MERGE (
    m:metricsRecord {
        continent: row.continent,
        country: row.country,
        year: date(row.year),
        demox_eiu: toFloat(row.demox_eiu),
        income_per_person: toInteger(row.income_per_person),
        invest_prc_gdp: toFloat(row.invest_prc_gdp),
        tax_prc_gdp: toFloat(row.tax_prc_gdp),
        gini_index: toFloat(row.gini_index)
    }
);


MATCH (m:metricsRecord)
MATCH (mP:metricsRecord)
WHERE m.year = mP.year + duration({years: 1}) and m.country = mP.country
MERGE (mP)-[:FOLLOWS]->(m)
RETURN *;

MATCH (m:metricsRecord), (a:Address)
WHERE  m.country = a.countries
MERGE (a)-[:is_described]->(m)
RETURN *;
