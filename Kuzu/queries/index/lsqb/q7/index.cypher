// Source: Neug lsqb/q7/index.cypher.
// Kuzu fallback: the NeuG-style q7_like_cnt/q7_reply_count property
// materialization is not enabled because updating Post.q7_like_cnt currently
// crashes this Kuzu build.
RETURN 'q7 materialization skipped: Kuzu update of Post.q7_like_cnt segfaults' AS note;
