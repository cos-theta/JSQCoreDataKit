//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import CoreData
import UIKit

import JSQCoreDataKit

import ExampleModel

final class EmployeeViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var stack: CoreDataStack!
    var frc: NSFetchedResultsController<Employee>!
    var company: Company!

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        setupFRC()
    }

    // MARK: Actions

    @IBAction func didTapAddButton(_ sender: UIBarButtonItem) {
        stack.mainContext.performAndWait {
            _ = Employee.newEmployee(self.stack.mainContext, company: self.company)
            self.stack.mainContext.saveSync()
        }
    }

    @IBAction func didTapTrashButton(_ sender: UIBarButtonItem) {
        let backgroundChildContext = stack.childContext()
        backgroundChildContext.performAndWait {
            do {
                let objects = try backgroundChildContext.fetch(self.fetchRequest())
                for each in objects {
                    backgroundChildContext.delete(each)
                }
                backgroundChildContext.saveSync()
            } catch {
                print("Error deleting objects: \(error)")
            }
        }
    }

    // MARK: Helpers

    func fetchRequest() -> NSFetchRequest<Employee> {
        let fetch = Employee.fetchRequest
        fetch.predicate = NSPredicate(format: "company == %@", company)
        return fetch
    }

    func setupFRC() {
        frc = NSFetchedResultsController(fetchRequest: fetchRequest(),
                                         managedObjectContext: stack.mainContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc.delegate = self
        fetchData()
    }

    func fetchData() {
        do {
            try frc.performFetch()
            tableView.reloadData()
        } catch {
            assertionFailure("Failed to fetch: \(error)")
        }
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        frc?.fetchedObjects?.count ?? 0
    }

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let employee = frc.object(at: indexPath)
        cell.textLabel?.text = employee.name
        cell.detailTextLabel?.text = "$\(employee.salary).00"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        company.name
    }

    // MARK: Table view delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let obj = frc.object(at: indexPath)
            stack.mainContext.performAndWait {
                self.stack.mainContext.delete(obj)
            }
            stack.mainContext.saveSync()
        }
    }

    // MARK: Fetched results controller delegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)

        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)

        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)

        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)

        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            fatalError("Unknown change type \(type)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
