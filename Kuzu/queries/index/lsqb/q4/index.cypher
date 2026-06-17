// Source: Neug lsqb/q4/index.cypher.
// Kuzu fallback: the NeuG-style q4_msg_cnt property materialization is not
// enabled because updating Post.q4_msg_cnt currently crashes this Kuzu build.
RETURN 'q4 materialization skipped: Kuzu update of Post.q4_msg_cnt segfaults' AS note;
