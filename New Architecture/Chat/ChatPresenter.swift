//
//  ChatPresenter.swift
//  FCM Channel
//
// Created by Yves Bastos on 09/08/2018.
// Copyright © 2018 Ilhasoft. All rights reserved.
//

import Foundation

class ChatPresenter {
    private weak var view: ChatViewContract?
    private var dataSource: ChatDataSource

    init(view: ChatViewContract, dataSource: ChatDataSource) {
        self.dataSource = dataSource
        self.view = view
    }
}
