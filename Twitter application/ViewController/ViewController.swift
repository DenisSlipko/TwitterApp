//
//  ViewController.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlet privates
    
    @IBOutlet private weak var imageButton: RoundedButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var locationTextField: UITextField!
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var bioTextField: UITextField!
    
    @IBOutlet private weak var currentNameLabel: UILabel!
    @IBOutlet private weak var currentLocationLabel: UILabel!
    @IBOutlet private weak var currentURLLabel: UILabel!
    @IBOutlet private weak var currentBioLabel: UILabel!
    
    @IBOutlet private weak var updateButton: UIButton!
    
    // MARK: - Properties
    
    var profileManager: ProfileManager!
    var authManager: AuthManager!
    
    private lazy var photosProvider = PhotosProvider(presentPhotosFrom: self)
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.startAnimating()
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Actions
    
    @IBAction func updateButtonAction(_ sender: UIButton) {
        updateProfile()
    }
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
        let alert = UIAlertController.photos { [weak weakSelf = self] sourceType in
            guard let `self` = weakSelf else { return }
            self.photosProvider.getPhoto(sourceType: sourceType, completion: { image in
                guard let image = image else { return }
                self.upload(photo: image)
            })
        }
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Setup
private extension ViewController {
    func setup() {
        authenticateIfNeeded()
        addViewInterraction()
        setupActivityIndicator()
        setupComponents()
    }
    
    func authenticateIfNeeded() {
        startIndicating()
        authManager.logIn { [weak weakSelf = self] result in
            guard let `self` = weakSelf else { return }
            switch result {
            case .success:
                self.fetchProfileData()
            case .failure(let error):
                self.display(error: error)
            }
        }
    }
    
    func fetchProfileData() {
        startIndicating()
        profileManager.getProfile { [weak weakSelf = self] result in
            guard let `self` = weakSelf else { return }
            self.stopIndicating()
            switch result {
            case .success(let profile):
                self.updateComponents(with: profile)
            case .failure(let error):
                self.display(error: error)
            }
        }
    }
    
    func updateProfile() {
        let profile = UserProfile(name: nameTextField.text ?? "",
                                  location: locationTextField.text ?? "",
                                  bio: bioTextField.text ?? "",
                                  url: urlTextField.text ?? "",
                                  imageURL: nil)
        self.startIndicating()
        profileManager.update(profile: profile) { [weak weakSelf = self] result in
            guard let `self` = weakSelf else { return }
            self.stopIndicating()
            switch result {
            case .success(let profile):
                self.updateComponents(with: profile)
            case .failure(let error):
                self.display(error: error)
            }
        }
    }
    
    func upload(photo: UIImage) {
        let currentImage = imageButton.backgroundImage(for: .normal)?.copy() as? UIImage
        imageButton.setBackgroundImage(photo, for: .normal)
        startIndicating()
        profileManager.upload(image: photo) { [weak weakSelf = self] result in
            guard let `self` = weakSelf else { return }
            self.stopIndicating()
            switch result {
            case .success(let profile):
                self.updateComponents(with: profile, placeholder: photo)
            case .failure(let error):
                self.display(error: error)
                self.imageButton.setBackgroundImage(currentImage, for: .normal)
            }
        }
    }
    
    func addViewInterraction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endViewEditing))
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: .UIKeyboardWillChangeFrame,
            object: nil
        )
    }
    
    func setupActivityIndicator() {
        let activityItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = activityItem
    }
    
    func setupComponents() {
        imageButton.imageView?.contentMode = .scaleAspectFill
    }
}

// MARK: - UI Update
private extension ViewController {
    func updateComponents(with profile: UserProfile, placeholder: UIImage? = nil) {
        currentNameLabel.text = profile.name
        currentLocationLabel.text = profile.location
        currentBioLabel.text = profile.bio
        currentURLLabel.text = profile.url
        if let imageURL = profile.imageURL {
            let normalImageURL = imageURL.replacingOccurrences(of: "_normal", with: "")
            if let url = URL(string: normalImageURL) {
                imageButton.setImage(withURL: url, placeholder: placeholder)
            }
        }
    }
    
    func display(error: Error) {
        let alert: UIAlertController = .with(error)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func endViewEditing() {
        view.endEditing(true)
    }
    
    func startIndicating() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        view.isUserInteractionEnabled = false
    }
    
    func stopIndicating()  {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let context = KeyboardChangeContext(userInfo)
        UIView.animate(withDuration: context.animationDuration) {
            let keyboardY = context.endFrame.origin.y
            let viewHeight = self.view.bounds.height
            let constant = viewHeight - keyboardY
            self.scrollView.contentInset.bottom = constant
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
        }
    }
}
