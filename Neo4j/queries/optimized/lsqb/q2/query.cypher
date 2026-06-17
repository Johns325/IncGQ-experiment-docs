// Uses KNOWS.q2_cnt_fwd/q2_cnt_rev from queries/index/lsqb/q2/index.cypher.
MATCH (:Person)-[knows:KNOWS]->(:Person)
RETURN sum(knows.q2_cnt_fwd + knows.q2_cnt_rev) AS count
