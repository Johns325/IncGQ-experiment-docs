// Q20. Recruitment
// UNSUPPORTED in the current Kuzu workload.
// The exact query requires weighted Dijkstra where edge weights are derived from shared university
// class-year differences. Kuzu's SHORTEST path support is unweighted, so it is not equivalent.
