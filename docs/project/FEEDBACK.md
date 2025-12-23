# iPhone Feedback (12/20/2025)

## Original User Reports
- 아이폰에서 편집시 키보드에 키보드 내리기 버튼이 없어서 키보드가 계속 떠있어서 하단의 저장버튼이 보이지 않아 편집후 저장이 불가능함.
- 가로보기시 왼쪽 카메라홀까지 카드가 보이게 되어 가로로 휴대폰을 세우면 카드왼쪽 끝부분이 보이지 않음. 가로보기시 카드 좌우를 좀 띄워야할듯.
- 가로보기시 상단의 app bar가 너무 높게 보이게 되어 가로로 휴대폰을 세우면 카드위쪽의 여백이 너무 커보임
- 편집 화면에서 각 콘트롤들이 검정색배경 흰글씨라 하이라이트적용시 가독성이 떨어짐. input control들의 안쪽 배경색과 폰트색은 카드와 동일하게 가면 좋을듯.
- 리스트에서 스와이프메뉴위치를 좌/우 변경하는게 좋아보임 좌측에 삭제, 우측에 편집으로. 스크롤을 내리다가 자꾸 삭제 팝업이 뜨는 문제가 발생. 스와이프 민감도도 조금 낮은게 더 좋을듯?
- original text와 translation text의 개별카드 출력시 줄간격이 조금만 더 좁으면 좋겠다.

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

# iPhone Feedback (12/22/2025)

## Original User Reports
- 문장 전환모드 기본값을 translation으로 변경하고 싶음
- 정렬에 옵션에서 difficulty 옵션을 삭제하는걸 고려중
- 정렬, 필터, 전환모드등의 리스트뷰 상단바 메뉴 설정값을 저장하고 앱을 종료하고 다시 실행해도 그 설정값이 유지되어야 함
- 리스트 뷰 상단우측의 플레이 버튼을 클릭시 study mode로 진입하는대신 test mode로 진입하고 기본적으로 study mode와 같으나 5초타이머를 사용하여 자동으로 다음문장으로 넘어가게끔 수정하고 싶음. 추가로 우측하단에 5초타이머 카운트다운 UI를 추가하고 싶음. 하지만 리스트 뷰에서 카드를 클릭해서 study mode로 진입할때는 5초타이머를 사용하지 않음
