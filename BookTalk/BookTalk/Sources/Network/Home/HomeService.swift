//
//  HomeService.swift
//  BookTalk
//
//  Created by 김민 on 8/26/24.
//

import Foundation

struct HomeService {

    static func getThisWeekTrend() async throws -> [Book] {
        let params: CustomHotTrendRequestDTO = .init(weekMonth: "week")

        let result: [LoanItemResponseDTO] = try await NetworkService.shared.request(
            target: HomeTarget.getCustomHotTrend(params: params)
        )

        return result.map { $0.toBookModel() }
    }

    static func getThisMonthTrend() async throws -> [Book] {
        let params: CustomHotTrendRequestDTO = .init(weekMonth: "month")

        let result: [LoanItemResponseDTO] = try await NetworkService.shared.request(
            target: HomeTarget.getCustomHotTrend(params: params)
        )

        return result.map { $0.toBookModel() }
    }

    static func getHotTrend() async throws -> [Book] {
        let result: [HotTrendResponseDTO] = try await NetworkService.shared.request(
            target: HomeTarget.getHotTrend
        )

        return result.map { $0.toModel() }
    }

    static func getAgeTrend(of age: String) async throws -> [Book] {
        let params: CustomHotTrendRequestDTO = .init(peerAge: age.isEmpty ? nil : age)

        let result: [LoanItemResponseDTO] = try await NetworkService.shared.request(
            target: HomeTarget.getCustomHotTrend(params: params)
        )

        return result.map { $0.toBookModel() }
    }
}
