SELECT DISTINCT
	user_session_id,
	metadata #>> '{url}' as url,
	(
		SELECT
			COUNT(ubt_sub.user_session_id)
		FROM
			user_behavior_trackings AS ubt_sub
		WHERE
			ubt_sub.event_name = 'visit_donation_page'
			AND ubt_sub.metadata ->> 'url' = ubt_main.metadata #>> '{url}'
			AND ubt_sub.user_session_id = ubt_main.user_session_id
		GROUP BY
			ubt_sub.user_session_id) AS num_page_visits,
	COALESCE((
		SELECT
			COUNT(ubt_sub.user_session_id)
			FROM user_behavior_trackings AS ubt_sub
		WHERE
			ubt_sub.event_name = 'create_donation'
			AND ubt_sub.metadata ->> 'url' = ubt_main.metadata #>> '{url}'
			AND ubt_sub.user_session_id = ubt_main.user_session_id
		GROUP BY
			ubt_sub.user_session_id), 0) AS num_contributions
FROM
  user_behavior_trackings AS ubt_main
WHERE
  event_name IN('visit_donation_page', 'create_donation')