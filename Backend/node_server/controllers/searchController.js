const pool = require('../db');

const MAX_KEYWORD_LENGTH = 30;
const MAX_RECENT = 10;
const TRENDING_SIZE = 10;

// 검색 기록이 아직 적을 때 급상승 검색어 자리를 채우는 기본 키워드
const DEFAULT_TRENDING = ['선크림', '립', '쿠션', '클렌징밀크', '틴트', '네일', '샴푸', '립글로스', '파운데이션', '마스카라'];

// 앞뒤 공백 제거, 연속 공백 하나로, 소문자 통일, 길이 제한
const normalizeKeyword = (raw) => {
    if (typeof raw !== 'string') return '';
    return raw.trim().replace(/\s+/g, ' ').toLowerCase().slice(0, MAX_KEYWORD_LENGTH);
};

// 검색어 기록 (최근 검색어 + 전체 로그)
const logSearch = async (req, res) => {
    const keyword = normalizeKeyword(req.body.keyword);
    if (!keyword) {
        return res.status(400).json({ message: '검색어가 없습니다.' });
    }

    const userId = req.user.id;
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        await client.query(
            `INSERT INTO search_history (user_id, keyword) VALUES ($1, $2)
             ON CONFLICT (user_id, keyword) DO UPDATE SET searched_at = CURRENT_TIMESTAMP`,
            [userId, keyword]
        );

        // 유저당 최근 10개만 유지
        await client.query(
            `DELETE FROM search_history
             WHERE user_id = $1
               AND keyword NOT IN (
                 SELECT keyword FROM search_history
                 WHERE user_id = $1 ORDER BY searched_at DESC LIMIT $2
               )`,
            [userId, MAX_RECENT]
        );

        // 급상승 집계: 같은 유저가 같은 단어를 반복해도 1시간에 1번만 센다
        await client.query(
            `INSERT INTO search_log (user_id, keyword)
             SELECT $1::int, $2::varchar
             WHERE NOT EXISTS (
               SELECT 1 FROM search_log
               WHERE user_id = $1 AND keyword = $2
                 AND searched_at > LOCALTIMESTAMP - INTERVAL '1 hour'
             )`,
            [userId, keyword]
        );

        await client.query('COMMIT');
        res.json({ message: '기록 완료' });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error('[logSearch error]', err.message);
        res.status(500).json({ error: err.message });
    } finally {
        client.release();
    }
};

const getRecent = async (req, res) => {
    try {
        const { rows } = await pool.query(
            `SELECT keyword FROM search_history
             WHERE user_id = $1 ORDER BY searched_at DESC LIMIT $2`,
            [req.user.id, MAX_RECENT]
        );
        res.json({ keywords: rows.map((r) => r.keyword) });
    } catch (err) {
        console.error('[getRecent error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

const deleteRecent = async (req, res) => {
    try {
        const keyword = normalizeKeyword(req.params.keyword);
        await pool.query(
            'DELETE FROM search_history WHERE user_id = $1 AND keyword = $2',
            [req.user.id, keyword]
        );
        res.json({ message: '삭제 완료' });
    } catch (err) {
        console.error('[deleteRecent error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

const clearRecent = async (req, res) => {
    try {
        await pool.query('DELETE FROM search_history WHERE user_id = $1', [req.user.id]);
        res.json({ message: '전체 삭제 완료' });
    } catch (err) {
        console.error('[clearRecent error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

// hoursAgo시간 전 시점 기준 급상승 순위.
// 점수 = 최근 1시간 검색 수 / (그 직전 23시간의 시간당 평균 + 1).
// 최근 1시간 검색이 없으면 점수가 0이라 자연스럽게 24시간 검색 수 순으로 정렬된다.
const trendingKeywordsAt = async (hoursAgo) => {
    const { rows } = await pool.query(
        `WITH anchor AS (SELECT LOCALTIMESTAMP - make_interval(hours => $1::int) AS t),
         counts AS (
           SELECT keyword,
                  COUNT(*) FILTER (WHERE searched_at > anchor.t - INTERVAL '1 hour') AS c1,
                  COUNT(*) AS c24
           FROM search_log, anchor
           WHERE searched_at > anchor.t - INTERVAL '24 hours' AND searched_at <= anchor.t
           GROUP BY keyword
         )
         SELECT keyword FROM counts
         ORDER BY c1::float / ((c24 - c1)::float / 23 + 1) DESC, c24 DESC, keyword ASC
         LIMIT $2`,
        [hoursAgo, TRENDING_SIZE]
    );
    return rows.map((r) => r.keyword);
};

const getTrending = async (req, res) => {
    try {
        const current = await trendingKeywordsAt(0);
        const previous = await trendingKeywordsAt(1);

        const result = current.map((keyword, i) => {
            const prevIndex = previous.indexOf(keyword);
            let status = '-';
            if (prevIndex === -1) status = 'up';          // 직전 순위권 밖에서 새로 진입
            else if (prevIndex > i) status = 'up';
            else if (prevIndex < i) status = 'down';
            return { rank: i + 1, keyword, status };
        });

        // 데이터가 적으면 기본 키워드로 10개를 채운다
        for (const keyword of DEFAULT_TRENDING) {
            if (result.length >= TRENDING_SIZE) break;
            if (!result.some((r) => r.keyword === keyword)) {
                result.push({ rank: result.length + 1, keyword, status: '-' });
            }
        }

        res.json({ keywords: result });
    } catch (err) {
        console.error('[getTrending error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

module.exports = { logSearch, getRecent, deleteRecent, clearRecent, getTrending };
