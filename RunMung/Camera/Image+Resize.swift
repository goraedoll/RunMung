//
//  Image+Resize.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import UIKit

public extension UIImage {
    /// 긴 변 기준 maxLength 이하가 되도록 리사이즈 (비율 유지)
    func resized(longerSideTo maxLength: CGFloat) -> UIImage {
        let w = size.width, h = size.height
        guard w > 0, h > 0 else { return self }
        let longer = max(w, h)
        let scale = min(1, maxLength / longer)
        if scale == 1 { return self }

        let newSize = CGSize(width: w * scale, height: h * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true // 카메라 사진은 보통 알파 필요 X → 용량/메모리 절약
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
