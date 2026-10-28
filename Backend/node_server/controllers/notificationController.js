const pool = require('../db');

// 알림 생성. 알림 저장이 실패해도 원래 동작(좋아요/댓글/팔로우)은 막지 않도록 에러는 로그만 남긴다.
// 자기 자신에게는 알림을 만들지 않는다. dedupe=true면 같은 (받는 사람, 보낸 사람, 종류, 게시물) 알림은 한 번만 만든다.
const createNotification = async ({ userId, actorId, type, postId = null, dedupe = false }) => {
  try {
    if (!userId || Number(userId) === Number(actorId)) return;

    if (dedupe) {
      await pool.query(
        `INSERT INTO notifications (user_id, actor_id, type, post_id)
         SELECT $1::int, $2::int, $3::varchar, $4::int
         WHERE NOT EXISTS (
           SELECT 1 FROM notifications
           WHERE user_id = $1::int AND actor_id = $2::int AND type = $3::varchar AND post_id IS NOT DISTINCT FROM $4::int
         )`,
        [userId, actorId, type, postId]
      );
    } else {
      await pool.query(
        'INSERT INTO notifications (user_id, actor_id, type, post_id) VALUES ($1, $2, $3, $4)',
        [userId, actorId, type, postId]
      );
    }
  } catch (err) {
    console.error('[createNotification]', err.message);
  }
};

// 좋아요/팔로우를 취소하면 그때 만든 알림도 지운다.
const removeNotification = async ({ userId, actorId, type, postId = null }) => {
  try {
    await pool.query(
      `DELETE FROM notifications
       WHERE user_id = $1::int AND actor_id = $2::int AND type = $3::varchar AND post_id IS NOT DISTINCT FROM $4::int`,
      [userId, actorId, type, postId]
    );
  } catch (err) {
    console.error('[removeNotification]', err.message);
  }
};

const ALL_TYPES = ['like', 'comment', 'follow'];

// ?types=like,comment 처럼 보고 싶은 종류만 받는다. (설정에서 끈 알림 종류를 앱이 빼고 요청)
// 파라미터가 아예 없으면 전부, 빈 값이면 아무것도 보여주지 않는다.
const parseTypes = (req) => {
  if (req.query.types === undefined) return ALL_TYPES;
  return String(req.query.types).split(',').map((t) => t.trim()).filter((t) => ALL_TYPES.includes(t));
};

// 내 알림 목록 (최근 50개) + 안 읽은 개수
const getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const types = parseTypes(req);
    const { rows } = await pool.query(
      `SELECT n.notification_id, n.type, n.post_id, n.is_read, n.created_at,
              a.user_id AS actor_id, a.nickname AS actor_nickname, a.profile_image AS actor_image,
              p.post_image, p.title, me.nickname AS owner_nickname
       FROM notifications n
       JOIN users a ON n.actor_id = a.user_id
       JOIN users me ON n.user_id = me.user_id
       LEFT JOIN posts p ON n.post_id = p.post_id
       WHERE n.user_id = $1 AND n.type = ANY($2::text[])
       ORDER BY n.created_at DESC
       LIMIT 50`,
      [userId, types]
    );
    const unread = rows.filter((r) => !r.is_read).length;
    res.json({ notifications: rows, unread });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 안 읽은 알림 개수 (홈 벨의 빨간 점용)
const getUnreadCount = async (req, res) => {
  try {
    const { rows: [{ count }] } = await pool.query(
      'SELECT COUNT(*) AS count FROM notifications WHERE user_id = $1 AND is_read = FALSE AND type = ANY($2::text[])',
      [req.user.id, parseTypes(req)]
    );
    res.json({ count: parseInt(count) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 전부 읽음 처리
const markAllRead = async (req, res) => {
  try {
    await pool.query('UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE', [req.user.id]);
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { createNotification, removeNotification, getNotifications, getUnreadCount, markAllRead };
