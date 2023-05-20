//
//  PhotoWriter.swift
//  Combinstagram
//
//  Created by bjke on 2023/5/20.
//
import Foundation
import Photos
import RxSwift
import UIKit

class PhotoWriter {
  enum Errors: Error {
    case couldNotSavePhoto
  }

  static func save(_ image: UIImage) -> Single<String> {
    return Single.create { observer in
      var savedAssetId: String?
      PHPhotoLibrary.shared().performChanges({
        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
        savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
      }, completionHandler: { success, error in
        DispatchQueue.main.async {
          if success, let id = savedAssetId {
            observer(.success(id))
          } else {
            observer(.failure(error ?? Errors.couldNotSavePhoto))
          }
        }
      })
      return Disposables.create()
    }
  }
}
