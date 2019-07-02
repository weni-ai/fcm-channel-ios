//
//  FCMChannelError.swift
//  Alamofire
//
//  Created by Alexandre Azevedo on 02/07/19.
//

import Foundation

enum FCMChannelError: Error {
    case notFound(message: String?)
    case defaultError(message: String?)
    case mappingError
    case noContact
}

extension FCMChannelError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFound(let message):
            return message ?? "Um erro ocorreu"
        case .defaultError(let message):
            return message ?? "Um erro ocorreu"
        case .mappingError:
            return "Erro ao decodificar contato"
        case .noContact:
            return "Nenhum contato encontrado"
        default:
            return "Um erro ocorreu"
        }
    }
}
