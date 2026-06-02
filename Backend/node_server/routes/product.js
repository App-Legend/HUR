const express = require("express");
const { getRanking, searchProducts, getProduct } = require("../controllers/productController");

const router = express.Router();

router.get("/ranking", getRanking);
router.get("/search", searchProducts);
router.get("/:id", getProduct);

module.exports = router;
