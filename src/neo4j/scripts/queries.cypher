MATCH (i:Intermediary)-[io:intermediary_of]->(e)
    WITH i, count(e) as counts, collect(e) as entities
    WHERE counts < 10
    RETURN i, counts, entities LIMIT 50;

MATCH (a:Officer),(b:Officer)
    WHERE a.name CONTAINS 'Trump'
    AND b.name CONTAINS 'John'
    MATCH p=allShortestPaths((a)-[:officer_of|intermediary_of|registered_address*..5]-(b))
    RETURN p
    LIMIT 50;

MATCH (a:Address)
    WITH a.countries as country, count(*) as counts
    WHERE a.countries IS NOT NULL
    RETURN country, counts
    ORDER BY counts DESC;

MATCH (n:metricsRecord)
    WITH n.country as country, max(n.year) as max_year
    RETURN country, max_year;

MATCH (n:metricsRecord)
    WITH n.country as country, max(n.year) as max_year
MATCH (a:Address)-[:is_described]->(m:metricsRecord)
    WHERE m.year = max_year and m.country = country
    RETURN *
    LIMIT 1000;

CALL {
    MATCH (a:Address)
        WITH a.countries as country, count(*) as counts
        WHERE a.countries IS NOT NULL
        RETURN country, counts
        ORDER BY counts DESC
        LIMIT 5
    UNION
    MATCH (a:Address)
        WITH a.countries as country, count(*) as counts
        WHERE a.countries IS NOT NULL
        RETURN country, counts
        ORDER BY counts
        LIMIT 5
}
RETURN country, counts;


CALL apoc.custom.asProcedure('shortestConnection',
  'MATCH (a:Officer),(b:Officer)
    WHERE a.name CONTAINS $nameFirst
    AND b.name CONTAINS $nameSecond
    MATCH p=allShortestPaths((a)-[:officer_of|intermediary_of|registered_address*..5]-(b))
    RETURN p
    LIMIT $limit','read',
  [['p','PATH']],
  [
    ['nameFirst','STRING'], ['nameSecond','STRING'], ['limit', 'INT']
  ],
  'get shortest connection between two officers, limit query with LIMIT param'
);

CALL custom.shortestConnection('John', 'Trump', 50) YIELD p;
