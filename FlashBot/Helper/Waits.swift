import Foundation

struct Waits {

    public static func seconds(seconds: Float) async {
        try? await Task.sleep(nanoseconds: UInt64(Double(seconds) * Double(NSEC_PER_SEC)))
    }

    public static func untilTrue(condition: () -> Bool) async {
        print("Waits.untilTrue ...")
        while !condition() {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
        }
        print("Waits.untilTrue (resolved)")
    }

}
