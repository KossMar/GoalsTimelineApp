//
//  TimelineViewController.swift
//  GoalsTimelineApp
//
//  Created by Carlo Namoca on 2017-10-30.
//  Copyright © 2017 Carlo Namoca. All rights reserved.
//

import UIKit
import CoreData

class TimelineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var timelineTitleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var timelineArray : Array<Timeline> = Array()
    var timeline : Timeline = Timeline ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        timelineTitleLabel.text = timeline.title
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        //Hide navigation bar 
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.fetchTimelineData()
        collectionView.reloadData()
        print("\(String(describing: timeline.steppingStones?.count)) stepping stones in timeline")

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddSteppingStone" {
        let addSteppingStoneVC : AddSteppingStoneViewController = segue.destination as! AddSteppingStoneViewController
        addSteppingStoneVC.timelineObject = timeline
        }
        if segue.identifier == "toEditSteppingStone" {
            let editSteppingStoneVC: EditSteppingViewController = segue.destination as! EditSteppingViewController
            
            let steppingStone : SteppingStone = sender as! SteppingStone
            editSteppingStoneVC.steppingStoneObject = steppingStone
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: check if steppingstone is not empty

        var steppingArray : Array<SteppingStone> = (timeline.steppingStones)?.allObjects as! Array<SteppingStone>
        let selectedItem: SteppingStone = steppingArray[indexPath.item]
        let steppingStone : SteppingStone = selectedItem
        
        performSegue(withIdentifier: "toEditSteppingStone", sender: steppingStone)
        
    }
    
    @objc
    func handleLongGesture(gesture: UILongPressGestureRecognizer){
        switch (gesture.state){
        case UIGestureRecognizerState.began:
            guard
                let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
                else { break }
            
            let began = collectionView.beginInteractiveMovementForItem(at: indexPath)
            print("began \(indexPath): \(began)")
            break
            
        case UIGestureRecognizerState.changed:
            print("changed")
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            break
            
        case UIGestureRecognizerState.ended:
            print("ended")
            //update cell name
            //update cell below/above as well
            
            self.collectionView.reloadData()
            collectionView.endInteractiveMovement()
            break
            
        default:
            print("default")
            collectionView.cancelInteractiveMovement()
            break
        }
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var steppingArray : Array<SteppingStone> = (timeline.steppingStones)?.allObjects as! Array<SteppingStone>
        steppingArray = steppingArray.sorted { $0.deadline?.compare($1.deadline! as Date) == .orderedAscending }
        
        var cell : UICollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCollectionViewCell
        print("\(steppingArray.count)")

        if steppingArray.count > 0 {
            
            // make vvv into function later
            for step : SteppingStone in steppingArray{
                if step.dateIndex == Int16(indexPath.row){
                    
                    let timelineCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "timelineCell", for: indexPath) as! TimelineCollectionViewCell
                    let formatter : DateFormatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let myString : String = formatter.string(from: step.deadline! as Date)
                    timelineCell.dateLabel.text = "\(myString)"
                    timelineCell.titleLabel.text = step.title
                    
                    cell = timelineCell
                }
            }

        }

        return cell
        
    }
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let dateDifference : TimeInterval = (timeline.endDate?.timeIntervalSince(timeline.startDate! as Date))!
        let intDate = Int(dateDifference)/86400
        print("dates \(intDate)")
        return intDate
    }
    
    //    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    //        print("can move")
    //        return true
    //    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("move item \(sourceIndexPath) to \(destinationIndexPath)")
        //update datasource
    }
    
    @IBAction func homeButton(_ sender: Any) {
    }
    @IBAction func editButton(_ sender: Any) {
    }
    @IBAction func addButton(_ sender: Any) {
    }
    
    func fetchTimelineData() {
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer : NSPersistentContainer = appDelegate.persistentContainer
        
        let context : NSManagedObjectContext = persistentContainer.viewContext
        let request : NSFetchRequest = Timeline.fetchRequest()
        timelineArray = try! context.fetch(request)
        print ("there are \(timelineArray.count) items in the array")
        
    }

    
}
