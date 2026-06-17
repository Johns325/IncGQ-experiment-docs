MATCH (:FORUM)-[membership:HASMEMBER]->(:PERSON)
SET membership.postCount = 0;
