const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());
app.use((req, res, next) => { console.log(`${req.method} ${req.path}`); next(); });

// 이미지 정적 파일 서빙
app.use('/uploads', express.static(path.join(__dirname, 'images/posts')));

// 라우터 연결
app.use('/auth', require('./routes/auth'));
app.use('/post', require('./routes/post'));
app.use('/user', require('./routes/user'));
app.use('/user/:id/follow', require('./routes/follow'));
app.use('/upload', require('./routes/upload'));
app.use('/products', require('./routes/product'));

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
