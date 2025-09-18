//
//  FileManager+Extensions.swift
//  RunMung
//
//  Created by 고래돌 on 9/18/25.
//

import UIKit

extension FileManager {
    /// Documents 폴더에 이미지 저장
    static func saveImageToDocuments(_ image: UIImage, name: String) {
        if let data = image.jpegData(compressionQuality: 0.9) {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(name).jpg")
            do {
                try data.write(to: url)
                print("✅ 이미지 저장 성공:", url.path)
            } catch {
                print("❌ 이미지 저장 실패:", error.localizedDescription)
            }
        }
    }

    /// Documents 폴더에서 이미지 불러오기
    static func loadImageFromDocuments(name: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(name).jpg")

        if FileManager.default.fileExists(atPath: url.path) {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }

    /// Documents 폴더에서 이미지 삭제
    static func deleteImageFromDocuments(name: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(name).jpg")
        do {
            try FileManager.default.removeItem(at: url)
            print("🗑 이미지 삭제 성공:", url.path)
        } catch {
            print("❌ 이미지 삭제 실패:", error.localizedDescription)
        }
    }
}
