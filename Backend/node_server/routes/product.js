const express = require("express");
const { getRanking, searchProducts, getProduct, recommendByImage } = require("../controllers/productController");

const router = express.Router();

router.get("/ranking", getRanking);
router.get("/search", searchProducts);
router.post("/recommend", recommendByImage);
router.get("/:id", getProduct);

module.exports = router;
