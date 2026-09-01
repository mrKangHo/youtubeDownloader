public enum DownloadOutcome {
    case completed
    case failed(String)
    /// 사용자가 명시적으로 일시정지/취소한 경우: 리포지토리는 종료 사유를 판단할 수 없으므로
    /// 상위(유스케이스/뷰모델)에서 기대한 상태였다면 이 값을 무시한다.
    case terminatedByClient
}
