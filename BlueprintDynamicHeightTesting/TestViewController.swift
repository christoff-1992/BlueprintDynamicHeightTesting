//
//  TestViewController.swift
//  BlueprintDynamicHeightTesting
//
//  Created by Chris on 30/10/2018.
//

import Blueprints
import UIKit

class TestViewController: UIViewController {

    @IBOutlet private weak var testingCollectionView: UICollectionView!
    let expectedCellWidth: Double = 320
    let sectionInsetSize: CGFloat = 16
    let minimumInteritemSpacing: CGFloat = 10
    let testCellIdentifier = "TestCollectionViewCell"

    let testData = ["orci a scelerisque purus semper",
                    "eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus in ornare",
                    "id venenatis a condimentum vitae sapien pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas sed",
                    "commodo elit at imperdiet dui",
                    "fames ac turpis egestas maecenas pharetra convallis posuere morbi leo urna molestie at elementum eu facilisis sed odio morbi quis commodo odio aenean sed adipiscing",
                    "eget duis at tellus at urna condimentum mattis pellentesque id",
                    "ullamcorper dignissim cras tincidunt lobortis feugiat vivamus at augue eget arcu dictum varius duis at consectetur lorem donec massa sapien faucibus et molestie ac feugiat sed lectus vestibulum mattis ullamcorper",
                    "venenatis urna cursus eget nunc scelerisque viverra mauris in aliquam sem fringilla ut morbi tincidunt",
                    "odio tempor orci dapibus ultrices in iaculis"]

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let layout = self?.configureCollectionViewLayout(forWidth: size.width) else {
                fatalError("Expected Blueprint Layout")
            }
            UIView.animate(withDuration: 0.3, animations: {
                self?.testingCollectionView.collectionViewLayout = layout
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            })
        }
    }
}

extension TestViewController {

    func configureCollectionView() {
        let layout = configureCollectionViewLayout(forWidth: self.view.bounds.width)
        testingCollectionView.collectionViewLayout = layout
        testingCollectionView.dataSource = self
        testingCollectionView.delegate = self
        registerCells()
    }

    private func registerCells() {
        let testCellXib = UINib(nibName: testCellIdentifier,
                                bundle: nil)
        testingCollectionView.register(testCellXib,
                                       forCellWithReuseIdentifier: testCellIdentifier)
    }

    private func configureCollectionViewLayout(forWidth width: CGFloat) -> UICollectionViewLayout {
        let viewWidthDouble = Double(width)
        let numberOfItemsPerRow = expectedItemsPerRow(forViewWidth: viewWidthDouble,
                                                      withItemWidth: expectedCellWidth)

        let blueprintLayout = VerticalBlueprintLayout(
            itemsPerRow: numberOfItemsPerRow,
            minimumInteritemSpacing: 10,
            minimumLineSpacing: 10,
            sectionInset: EdgeInsets(top: sectionInsetSize,
                                     left: sectionInsetSize,
                                     bottom: sectionInsetSize,
                                     right: sectionInsetSize),
            stickyHeaders: true,
            stickyFooters: false)

        return blueprintLayout
    }

    private func expectedItemsPerRow(forViewWidth viewWidth: Double, withItemWidth itemWidth: Double) -> CGFloat {
        let numberOfItemsToBeDisplayed = (viewWidth / itemWidth).rounded(.down)
        return CGFloat(numberOfItemsToBeDisplayed)
    }

    // MARK: - This uses the same calculations that the blueprint layout uses to calculate the width of a cell.
    private func widthForCellInCurrentLayout() -> CGFloat {
        let width = self.view.bounds.width
        let viewWidthDouble = Double(width)
        let itemsPerRow = expectedItemsPerRow(forViewWidth: viewWidthDouble,
                                              withItemWidth: expectedCellWidth)
        var cellWidth = testingCollectionView.frame.size.width
        if itemsPerRow > 1 {
            cellWidth -= minimumInteritemSpacing * (itemsPerRow - 1)
        }
        return floor(cellWidth / itemsPerRow)
    }
}

extension TestViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let testCell = testingCollectionView.dequeueReusableCell(withReuseIdentifier: testCellIdentifier, for: indexPath) as? TestCollectionViewCell else {
            fatalError("Expected TestCollectionViewCell")
        }
        testCell.configure(text: testData[indexPath.row], subText: testData[indexPath.row])
        return testCell
    }
}

extension TestViewController: UICollectionViewDelegateFlowLayout {

    // MARK: - Testing setting the size of the cell, this is fine in the intial layout with one item per row, but when there are multiple items per row the cells overlap.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let testCellForSize = Bundle.main.loadNibNamed(testCellIdentifier, owner: self, options: nil)?.first as? TestCollectionViewCell else {
            fatalError("Expected TestCollectionViewCell")
        }
        testCellForSize.configure(text: testData[indexPath.row], subText: testData[indexPath.row])
        testCellForSize.setNeedsLayout()
        testCellForSize.layoutIfNeeded()

        let cellWidth = widthForCellInCurrentLayout()
        let cellHeight: CGFloat = 0
        let targetSize = CGSize(width: cellWidth,
                                height: cellHeight)

        let size = testCellForSize.contentView.systemLayoutSizeFitting(targetSize,
                                                                       withHorizontalFittingPriority: .defaultHigh,
                                                                       verticalFittingPriority: .fittingSizeLevel)

        return size
    }
}
