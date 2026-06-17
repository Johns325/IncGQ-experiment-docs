// Q1. Posting summary
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
MATCH (message:POST:COMMENT)
WHERE message.creationDate < $datetime
  AND message.content IS NOT NULL
WITH
  date_part('year', message.creationDate) AS year,
  label(message) = 'COMMENT' AS isComment,
  CASE WHEN message.length < 40 THEN 0 WHEN message.length < 80 THEN 1 WHEN message.length < 160 THEN 2 ELSE 3 END AS lengthCategory,
  count(message) AS messageCount,
  sum(message.length) / CAST(count(message) AS DOUBLE) AS averageMessageLength,
  sum(message.length) AS sumMessageLength,
  CAST(count { MATCH (m:POST:COMMENT) WHERE m.creationDate < $datetime } AS DOUBLE) AS totalMessageCount
RETURN year, isComment, lengthCategory, messageCount, averageMessageLength, sumMessageLength, CAST(messageCount AS DOUBLE) / totalMessageCount AS percentageOfMessages
ORDER BY year DESC, isComment ASC, lengthCategory ASC
