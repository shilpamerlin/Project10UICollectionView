//
//  ViewController.swift
//  Project10UICollectionView
//
//  Created by Shilpa Joy on 2021-03-20.
//

import UIKit

class ViewController: UICollectionViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var people = [Person]()

    override func viewDidLoad() {
       
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        var result = UIImagePickerController.isSourceTypeAvailable(.camera)
        print("Result is \(result)")
        // Do any additional setup after loading the view.
    }
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true //user to crop the picture they select.
       // picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }

        let person = people[indexPath.item]

        cell.name.text = person.name

        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)

        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    
    //returns when the user selected an image and it's being returned to you
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        
        // UIImage containing an image and a path where we want to save it,
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        //Convert it to a JPEG, then write that JPEG to disk
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]

        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.people.remove(at: indexPath.row)
            
            collectionView.indexPathsForSelectedItems?
                .forEach { self.collectionView.deselectItem(at: $0, animated: false) }
            collectionView.reloadData()
        } )
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(deleteAction)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName

            self?.collectionView.reloadData()
        })

        present(ac, animated: true)
    }

}

