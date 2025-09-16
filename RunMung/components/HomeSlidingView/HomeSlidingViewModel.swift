//
//  HomeSlidingViewModel.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//

import SwiftUI

@Observable class HomeSlidingViewModel {
    var selection: Int = 0
    var slides: [SlideItem] = [
        SlideItem(imageURL: "http://211.188.62.13:9000/miniotest/HomeSliderIcon1.png", title: "런멍이랑 함께하는\nAI 강아지 산책"),
        SlideItem(
            imageURL: "http://211.188.62.13:9000/miniotest/HomeSliderIcon2.png",
            title: "리워드를 얻어보세요~\n함께 달리며 포인트 적립!"
        ),
        SlideItem(
            imageURL: "http://211.188.62.13:9000/miniotest/HomeSliderIcon3.png",
            title: "나의 건강도 함께 관리하세요!\n런멍과 건강 체크"
        ),
        SlideItem(
            imageURL: "http://211.188.62.13:9000/miniotest/HomeSliderIcon4.png",
            title: "간식 주문도 런멍과 함께!\n강아지와 행복한 시간"
        )
    ]
}
