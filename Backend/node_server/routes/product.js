const express = require("express");
const { verifyToken } = require("../middleware/auth");
const { getRanking, searchProducts, getProduct, recommendByImage } = require("../controllers/productController");
const { getReviews, saveReview, deleteMyReview } = require("../controllers/reviewController");

const router = express.Router();

router.get("/ranking", getRanking);
router.get("/search", searchProducts);
router.post("/recommend", recommendByImage);
router.get("/:id", getProduct);
router.get("/:id/reviews", getReviews);
router.post("/:id/reviews", verifyToken, saveReview);
router.delete("/:id/reviews", verifyToken, deleteMyReview);

module.exports = router;
