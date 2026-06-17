# LDBC BI materializations

Source Neug setup templates:

- `bi3`: `countryName`, `ROOT_POST`
- `bi5`: `likeCount`, `replyCount` on POST and COMMENT
- `bi6`: `PERSON.likeCount`
- `bi11`, `bi13`: `PERSON.countryName`
- `bi14a`: directional `KNOWS.bi14_case*` counts
- `bi15a`: `KNOWS.bi15_weight`
- `bi17`: `ROOT_POST`, `rootPostId`, `rootForumId`
- `bi19a`: `KNOWS.weight_bi19`

These scripts target the uppercase LDBC BI Kuzu schema in `/mnt/data/imported_data/kuzu/bi-sf1`.

Note: existing Kuzu BI15 query files use `weight_bi15`; Neug's template uses `bi15_weight`. This directory materializes the Neug name `bi15_weight`.
