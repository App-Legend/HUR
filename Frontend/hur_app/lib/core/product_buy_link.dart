/// 구매 링크 사용 여부. false 면 브라우저를 열지 않고 "준비 중이에요" 안내만 보여준다.
/// 다시 켜려면 true 로 바꾼다.
const bool kBuyLinkReady = false;

/// 제품 구매처 검색 주소 만들기. (제품 구매 URL 은 DB 에 없어서 브랜드 + 이름으로 검색한다)
enum BuyStore {
  naver('네이버 쇼핑'),
  coupang('쿠팡');

  final String label;
  const BuyStore(this.label);
}

Uri productBuyUri(BuyStore store, {required String brand, required String name}) {
  final query = '$brand $name'.trim();
  switch (store) {
    case BuyStore.naver:
      return Uri.https('search.shopping.naver.com', '/search/all', {'query': query});
    case BuyStore.coupang:
      return Uri.https('www.coupang.com', '/np/search', {'q': query});
  }
}
