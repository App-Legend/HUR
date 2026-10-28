const pool = require('../db');

const BLOCK_KINDS = ['block', 'mute'];
const REPORT_REASONS = ['스팸/광고', '부적절한 내용', '저작권/도용', '기타'];

// 차단(block) 또는 제한(mute). 이미 있으면 종류만 바꾼다.
// 차단하면 서로의 팔로우 관계도 함께 끊는다.
const blockUser = async (req, res) => {
    try {
        const me = req.user.id;
        const target = parseInt(req.params.id);
        const kind = req.body?.kind || 'block';

        if (Number.isNaN(target)) return res.status(400).json({ message: '잘못된 계정이에요.' });
        if (target === me) return res.status(400).json({ message: '나 자신은 차단하거나 제한할 수 없어요.' });
        if (!BLOCK_KINDS.includes(kind)) return res.status(400).json({ message: '잘못된 요청이에요.' });

        const { rows: [user] } = await pool.query('SELECT 1 FROM users WHERE user_id = $1', [target]);
        if (!user) return res.status(404).json({ message: '계정을 찾을 수 없어요.' });

        await pool.query(
            `INSERT INTO user_blocks (blocker_id, blocked_id, kind) VALUES ($1, $2, $3)
             ON CONFLICT (blocker_id, blocked_id) DO UPDATE SET kind = EXCLUDED.kind, created_at = CURRENT_TIMESTAMP`,
            [me, target, kind]
        );
        if (kind === 'block') {
            await pool.query(
                `DELETE FROM follow
                 WHERE (follower_id = $1 AND following_id = $2) OR (follower_id = $2 AND following_id = $1)`,
                [me, target]
            );
        }
        res.json({ kind });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const unblockUser = async (req, res) => {
    try {
        await pool.query('DELETE FROM user_blocks WHERE blocker_id = $1 AND blocked_id = $2', [
            req.user.id,
            parseInt(req.params.id),
        ]);
        res.json({ kind: null });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 내가 차단/제한한 계정 목록
const listBlocked = async (req, res) => {
    try {
        const { rows } = await pool.query(
            `SELECT b.blocked_id AS id, u.nickname, u.profile_image, b.kind
             FROM user_blocks b
             JOIN users u ON b.blocked_id = u.user_id
             WHERE b.blocker_id = $1
             ORDER BY b.created_at DESC`,
            [req.user.id]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 게시물 신고. 같은 게시물은 한 사람이 한 번만 신고할 수 있다. 내용은 저장만 하고 운영자가 확인한다.
const reportPost = async (req, res) => {
    try {
        const postId = parseInt(req.params.id);
        const reason = req.body?.reason;
        if (Number.isNaN(postId)) return res.status(400).json({ message: '잘못된 게시물이에요.' });
        if (!REPORT_REASONS.includes(reason)) return res.status(400).json({ message: '신고 사유를 선택해주세요.' });

        const { rows: [post] } = await pool.query('SELECT user_id FROM posts WHERE post_id = $1', [postId]);
        if (!post) return res.status(404).json({ message: '게시물이 없습니다' });
        if (post.user_id === req.user.id) return res.status(400).json({ message: '내 게시물은 신고할 수 없어요.' });

        await pool.query(
            'INSERT INTO post_reports (post_id, reporter_id, reason) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING',
            [postId, req.user.id, reason]
        );
        res.json({ reported: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { blockUser, unblockUser, listBlocked, reportPost };
