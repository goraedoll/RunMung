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
        SlideItem(imageURL: "HomeSliderIcon1", title: "댕구랑 함께하는\nAI 강아지 산책"),
        SlideItem(imageURL: "HomeSliderIcon2", title: "리워드를 얻어보세요~\n함께 달리며 포인트 적립!"),
        SlideItem(imageURL: "HomeSliderIcon3", title: "나의 건강도 함께 관리하세요!\n런멍과 건강 체크"),
        SlideItem(imageURL: "HomeSliderIcon4", title: "간식 주문도 댕구과 함께!\n강아지와 행복한 시간")
    ]
}
