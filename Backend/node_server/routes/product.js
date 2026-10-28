const express = require("express");
const { verifyToken, optionalAuth } = require("../middleware/auth");
const {
    getRanking, searchProducts, getProduct, recommendByImage,
    getMyMarks, setMark, listMarkedProducts, getSimilarProducts,
} = require("../controllers/productController");
const { getReviews, saveReview, deleteMyReview } = require("../controllers/reviewController");

const router = express.Router();

router.get("/ranking", optionalAuth, getRanking);
router.get("/search", searchProducts);
router.get("/marks/me", verifyToken, listMarkedProducts);
router.post("/recommend", recommendByImage);
router.get("/:id", getProduct);
router.get("/:id/marks", verifyToken, getMyMarks);
router.put("/:id/mark", verifyToken, setMark);
router.get("/:id/similar", optionalAuth, getSimilarProducts);
router.get("/:id/reviews", getReviews);
router.post("/:id/reviews", verifyToken, saveReview);
router.delete("/:id/reviews", verifyToken, deleteMyReview);

module.exports = router;
