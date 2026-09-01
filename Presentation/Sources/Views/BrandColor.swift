import SwiftUI

extension Color {
    /// 앱 아이콘과 통일한 브랜드 레드. 순수 #FF0000보다 살짝 눌러서
    /// 버튼/틴트처럼 넓은 면적에 써도 튀지 않게 했다.
    static let brandRed = Color(red: 0.87, green: 0.11, blue: 0.14)

    static let brandRedSoft = Color(red: 0.87, green: 0.11, blue: 0.14).opacity(0.08)
}

extension View {
    /// 사이드바/디테일 컬럼에 공통으로 쓰는 은은한 브랜드 그라데이션 배경.
    /// 라이트/다크 모드 둘 다 시스템 배경색 위에 살짝만 얹는다.
    func brandedBackground() -> some View {
        background(
            LinearGradient(
                colors: [Color(nsColor: .windowBackgroundColor), Color.brandRedSoft],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
