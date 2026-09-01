import SwiftUI

/// 오버레이 아이콘 버튼(일시정지/재개/삭제)에 쓰는 스타일.
/// 눌리는 즉시(터치다운) 스케일이 줄어드는 반응 + 재질(ultraThinMaterial) 배경으로
/// 반투명 칩이 실제 유리 표면처럼 보이게 한다.
struct MaterialIconButtonStyle: ButtonStyle {
    var tint: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 28, height: 28)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 0.5))
            .scaleEffect(configuration.isPressed ? 0.86 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
