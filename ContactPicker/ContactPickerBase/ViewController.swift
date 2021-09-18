//
//  ViewController.swift
//  ContactPickerBase
//
//  Created by Andy Ibanez on 9/15/21.
//

import UIKit
import ContactsUI

@MainActor
class ContactPicker: NSObject, CNContactPickerDelegate {
    private typealias ContactCheckedContinuation = CheckedContinuation<CNContact?, Never>
    
    private unowned var viewController: UIViewController
    private var contactContinuation: ContactCheckedContinuation?
    private var picker: CNContactPickerViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        picker = CNContactPickerViewController()
        super.init()
        picker.delegate = self
    }
    
    func pickContact() async -> CNContact? {
        viewController.present(picker, animated: true)
        return await withCheckedContinuation({ (continuation: ContactCheckedContinuation) in
            self.contactContinuation = continuation
        })
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        contactContinuation?.resume(returning: contact)
        contactContinuation = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        contactContinuation?.resume(returning: nil)
        contactContinuation = nil
    }
    
    func callAsFunction() async -> CNContact? {
        return await pickContact()
    }
}


class ViewController: UIViewController {
    @IBOutlet weak var contactNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactNameLabel.text = ""
        // Do any additional setup after loading the view.
    }

    @IBAction func chooseContactTouchUpInside(_ sender: Any) {
        pickContact()
    }
    
    func pickContact() {
        Task {
            if let contact = await ContactPicker(viewController: self)() {
                // To format names, use
                // PersonNameComponentsFormatter
                // in a real application
                //
                // https://www.andyibanez.com/posts/formatting-notes-and-gotchas/
                self.contactNameLabel.text = "\(contact.givenName) \(contact.familyName)"
            }
        }
    }
}

