//
//  ViewController.swift
//  Combinstagram
//
//  Created by bjke on 2023/5/20.
//

import RxRelay
import RxSwift
import UIKit
import Photos
class MainViewController: UIViewController {
  @IBOutlet var imagePreview: UIImageView!
  @IBOutlet var buttonClear: UIButton!
  @IBOutlet var buttonSave: UIButton!
  @IBOutlet var itemAdd: UIBarButtonItem!
  private let bag = DisposeBag()
  private let images = BehaviorRelay<[UIImage]>(value: [])
  override func viewDidLoad() {
    super.viewDidLoad()
    images
      .subscribe(onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }

        preview.image = photos.collage(size: preview.frame.size)
      })
      .disposed(by: bag)
    images.subscribe { [weak self] photos in
      self?.updateUI(photos: photos)
    }.disposed(by: bag)
  }

  @IBAction func actionClear() {
    images.accept([])
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }

    PhotoWriter.save(image)
      .subscribe(
        onSuccess: { [weak self] id in
          self?.showMessage("Saved with id: \(id)")
          self?.actionClear()
        },
        onFailure: { [weak self] error in
          self?.showMessage("Error", description: error.localizedDescription)
        }
      )
      .disposed(by: bag)
  }

  @IBAction func actionAdd() {
    let photosVC = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    navigationController?.pushViewController(photosVC, animated: true)
    photosVC.selectedPhotos.subscribe { [weak self] newImage in
      guard let images = self?.images else { return }
      images.accept(images.value + [newImage])
    } onDisposed: {
      print("Completed photo selection")
    }.disposed(by: bag)
  }

  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }

  func showMessage(_ title: String, description: String? = nil) {
   alert(title: title, text: description)
      .subscribe()
      .disposed(by: bag)
  }
}
