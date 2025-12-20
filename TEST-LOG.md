# iPhone Testing Log (12/20/2025)

## Summary of Findings & Fixes

- [x] **Keyboard Dismissal**: No keyboard dismiss button in edit screen? (Access to Save button blocked) -> **Fixed: Added GestureDetector to unfocus on tap.**
- [x] **Landscape View Layout**:
    - [x] Card content obscured by camera notch -> **Fixed: Added SafeArea/Padding in landscape.**
    - [x] App bar height too high in landscape -> **Fixed: Reduced toolbarHeight in landscape.**
- [x] **Edit Screen Readability**: Input controls on dark background have poor readability -> **Fixed: Matched input background/text to card theme.**
- [x] **Swipe Menu UX**: High sensitivity, accidental deletions, menu swap (edit/delete) -> **Fixed: Swapped directions (Right: Delete, Left: Edit) and added dismissThresholds.**
- [x] **Text Line Spacing**: Original/Translation text spacing needs adjustment -> **Fixed: Reduced height to 1.3.**
- [x] **App Name**: Changing from "Flutter Bp" to "English Surf" -> **Fixed: Updated Info.plist and AndroidManifest.**
- [x] **List View Alignment**: Lopsided margin in landscape -> **Fixed: Centralized with ConstrainedBox and Align.centerLeft.**
- [x] **consistent Margins**: Aligned list and card margins with a 1/3 landscape gap reduction (32.0).
- [x] **AppBar Background**: Black background at top/notch area -> **Fixed: Refactored Scaffold and SliverAppBar structure.**
- [x] **Input Field Background**: Difficulty dropdown popup color -> **Fixed: Added dropdownColor.**
- [x] **Subtext Legibility**: Made subtext (translation/original) slightly darker (`grey.shade500`) for better legibility.

## Original User Reports (Korean)
- 아이폰에서 편집시 키보드에 키보드 내리기 버튼이 없어서 키보드가 계속 떠있어서 하단의 저장버튼이 보이지 않아 편집후 저장이 불가능함.
- 가로보기시 왼쪽 카메라홀까지 카드가 보이게 되어 가로로 휴대폰을 세우면 카드왼쪽 끝부분이 보이지 않음. 가로보기시 카드 좌우를 좀 띄워야할듯.
- 가로보기시 상단의 app bar가 너무 높게 보이게 되어 가로로 휴대폰을 세우면 카드위쪽의 여백이 너무 커보임
- 편집 화면에서 각 콘트롤들이 검정색배경 흰글씨라 하이라이트적용시 가독성이 떨어짐. input control들의 안쪽 배경색과 폰트색은 카드와 동일하게 가면 좋을듯.
- 리스트에서 스와이프메뉴위치를 좌/우 변경하는게 좋아보임 좌측에 삭제, 우측에 편집으로. 스크롤을 내리다가 자꾸 삭제 팝업이 뜨는 문제가 발생. 스와이프 민감도도 조금 낮은게 더 좋을듯?
- original text와 translation text의 개별카드 출력시 줄간격이 조금만 더 좁으면 좋겠다.