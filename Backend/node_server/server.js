const express = require("express");
const cors = require("cors");

const path = require("path");
const authRoutes    = require("./routes/auth");
const userRoutes    = require("./routes/user");
const followRoutes  = require("./routes/follow");
const uploadRoutes  = require("./routes/upload");
const productRoutes = require("./routes/product");

const app = express();
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/", authRoutes);
app.use("/user", userRoutes);
app.use("/user/:id/follow", followRoutes);
app.use("/upload", uploadRoutes);
app.use("/products", productRoutes);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
