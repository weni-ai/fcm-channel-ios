//
//  ChatViewController.swift
//  FCM Channel
//
// Created by Yves Bastos on 09/08/2018.
// Copyright © 2018 Ilhasoft. All rights reserved.
// 

import UIKit
import Reusable
import IGListKit

class ChatViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var composeView: UIView!
    @IBOutlet var composeViewHeightConstraint: NSLayoutConstraint!

    private var presenter: ChatPresenter!

    private var adapter: ListAdapter!
    private var messages: [FCMChannelMessage] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ChatPresenter(view: self, dataSource: ChatRepository())
        setupCollectionview()

    }

    private func setupCollectionview() {
        collectionView.register(cellType: ChatCell.self)

        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        }
    }

    // MARK: - Actions
    @objc private func didPullToRefresh() {

    }
}

extension ChatViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return messages
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {

    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
    }
}

extension ChatViewController: ChatViewContract {

}
