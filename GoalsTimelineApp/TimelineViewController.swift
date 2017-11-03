//
//  TimelineViewController.swift
//  GoalsTimelineApp
//
//  Created by Carlo Namoca on 2017-10-30.
//  Copyright © 2017 Carlo Namoca. All rights reserved.
//

import UIKit
import CoreData

class TimelineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var timelineTitleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var timelineArray : Array<Timeline> = Array()
    var timeline : Timeline = Timeline ()
    var startSec : Int = Int ()
    var stepIndexDict : Dictionary <Int , SteppingStone> = [Int : SteppingStone]()
    var tempStep : SteppingStone? = nil
    
    var todaysDate:NSDate = NSDate()


    
    var steppingStoneArray : Array<SteppingStone> = Array()
    
    //
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        timelineTitleLabel.text = timeline.title
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.collectionView.addGestureRecognizer(swipeRight)
        
        let deleteGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDeleteGesture(gesture:)))
        deleteGesture.direction = UISwipeGestureRecognizerDirection.left
        collectionView.addGestureRecognizer(deleteGesture)

        
        let addStepGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddStepGesture(gesture:)))
        addStepGesture.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(addStepGesture)
        
        let editStepGesture = UITapGestureRecognizer(target: self, action: #selector(handleEditStepGesture(gesture:)))
        collectionView.addGestureRecognizer(editStepGesture)
        
        

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        //Hide navigation bar 
        navigationController?.setNavigationBarHidden(true, animated: true)
        


        startSec = Int((timeline.startDate?.timeIntervalSince(timeline.startDate! as Date))!)

        self.fetchSteppingStone()
        self.fetchTimelineData()
        
        collectionView.reloadData()
        self.updateTimelinetitle()
        print("\(String(describing: timeline.steppingStones?.count)) stepping stones in timeline")
        print("Showing timeline with title: \(String(describing: timeline.title)) ")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddSteppingStone" {
        let addSteppingStoneVC : AddSteppingStoneViewController = segue.destination as! AddSteppingStoneViewController
        addSteppingStoneVC.timelineObject = timeline
        }
        
        if segue.identifier == "tapAddStep" {
            let date = sender as! Date
            let tapAddStepVC : AddSteppingStoneViewController = segue.destination as! AddSteppingStoneViewController
            tapAddStepVC.timelineObject = timeline
            tapAddStepVC.initialDate = date
        }
        
        if segue.identifier == "toEditSteppingStone" {
            let editSteppingStoneVC: EditSteppingViewController = segue.destination as! EditSteppingViewController
            
            let steppingStone : SteppingStone = sender as! SteppingStone
            editSteppingStoneVC.steppingStoneObject = steppingStone
            editSteppingStoneVC.timelineObject = timeline
        }
        if segue.identifier == "toDetailView" {
            let timelineDetailVC : TimelineDetailViewController = segue.destination as! TimelineDetailViewController

            timelineDetailVC.timelineObject = timeline
            
        }

    }
    
    //MARK: GESTURE RECOGNIZERS methods
    
    
    @objc
    func handleEditStepGesture(gesture: UITapGestureRecognizer) {
        guard
            let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
            else {return}
        if collectionView.cellForItem(at: indexPath) is TimelineCollectionViewCell {
            let indexPathDate = NSDate(timeInterval: (TimeInterval(indexPath.row * 86400)), since:timeline.startDate! as Date )
            let formatter : DateFormatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let dateString : String = formatter.string(from: indexPathDate as Date)
            
            let steppingArray : Array<SteppingStone> = (timeline.steppingStones)?.allObjects as! Array<SteppingStone>
            for step : SteppingStone in steppingArray{
                let stepDateString : String = formatter.string(from: step.deadline! as Date)
                if stepDateString == dateString {
                    performSegue(withIdentifier: "toEditSteppingStone", sender: step)
                }
            }
        }
    }
            
    
    @objc
    func handleAddStepGesture(gesture: UITapGestureRecognizer) {
        guard
            let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
            else {return}
        if collectionView.cellForItem(at: indexPath) is EmptyCollectionViewCell {
            let indexPathDate = Date.init(timeInterval: (TimeInterval(indexPath.row * 86400)), since:timeline.startDate! as Date)
            performSegue(withIdentifier: "tapAddStep", sender: indexPathDate)
        }
    }
    
    @objc
    func handleDeleteGesture(gesture: UITapGestureRecognizer) {
        guard
            let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
            else {return}
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer : NSPersistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        tempStep = stepIndexDict[indexPath.row]!
        
        
        if collectionView.cellForItem(at: indexPath) is TimelineCollectionViewCell {
            
            let alert = UIAlertController(title: "This Stepping Stone will be deleted from Timeline", message: nil, preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete Stepping Stone", style: .destructive) { (action) in
                context.delete(self.tempStep!)
                self.tempStep = nil
                                
                self.collectionView.reloadData()
            }
            alert.addAction(deleteAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc
    func handleSwipeRight(gesture: UISwipeGestureRecognizer){
        guard
            let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
            else {return}
        //        let cell : TimelineCollectionViewCell = TimelineCollectionViewCell()
        //        let emptyCell : EmptyCollectionViewCell = self.collectionView.cellForItem(at: indexPath!) as! EmptyCollectionViewCell
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer : NSPersistentContainer = appDelegate.persistentContainer
        tempStep = nil

        if collectionView.cellForItem(at: indexPath) is TimelineCollectionViewCell {
            let cell : TimelineCollectionViewCell = (self.collectionView.cellForItem(at: indexPath) as? TimelineCollectionViewCell)!
            tempStep = stepIndexDict[indexPath.row]!
            
            if tempStep!.isCompleted == false {
                cell.imageView.image = UIImage(named: "completedCell")
                tempStep!.setValue(true, forKey: "isCompleted")

            }
            else {
                cell.imageView.image = UIImage(named: "CustomCell")
                tempStep!.setValue(false, forKey: "isCompleted")
            }
            
            appDelegate.saveContext()
            tempStep = nil
            fetchTimelineData()
            fetchSteppingStone()
            collectionView.reloadData()
            
        }
    }
    
    @objc
    func handleLongGesture(gesture: UILongPressGestureRecognizer){
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer : NSPersistentContainer = appDelegate.persistentContainer
        
//        var tempStep : SteppingStone = SteppingStone ()//(context: persistentContainer.viewContext)
        
        switch (gesture.state){
        case UIGestureRecognizerState.began:
            guard
                let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
                else { break }
            
            if self.collectionView.cellForItem(at: indexPath) is EmptyCollectionViewCell{
                collectionView.cancelInteractiveMovement()
                break
            }
            
            let began = collectionView.beginInteractiveMovementForItem(at: indexPath)
            print("began \(indexPath): \(began)")
            tempStep = stepIndexDict[indexPath.row]!
            break
            
        case UIGestureRecognizerState.changed:
            print("changed")
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
            let indexPathDate = NSDate(timeInterval: (TimeInterval((indexPath?.row)! * 86400)), since:timeline.startDate! as Date )
            print ("\(indexPathDate)")
            
            // breaks if goes beyond
            //need to fix
            
            break
            
        case UIGestureRecognizerState.ended:
            let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
            let indexPathDate = NSDate(timeInterval: (TimeInterval((indexPath?.row)! * 86400)), since:timeline.startDate! as Date ) as NSDate
            
            if tempStep != nil {
            tempStep?.setValue(indexPathDate, forKey:"deadline" )
            print("ended")
            appDelegate.saveContext()
            
            self.fetchSteppingStone()
            self.fetchTimelineData()

            //update cell name
            //update cell below/above as well
            collectionView.reloadData()
            }
            
            tempStep = nil
            collectionView.reloadData()
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
        
        var cell : UICollectionViewCell = UICollectionViewCell()
        let emptyCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCollectionViewCell
        let indexPathDate = NSDate(timeInterval: (TimeInterval(indexPath.row * 86400)), since:timeline.startDate! as Date )
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let dateString : String = formatter.string(from: indexPathDate as Date)
        emptyCell.dateLabel.text = dateString
        print("empty\(dateString)")
        
//        todaysDate = NSDate()
        //USE FOR DEMO
        todaysDate = NSCalendar.current.date(byAdding: .day, value: 1, to: NSDate() as Date, wrappingComponents: false)! as NSDate
        //
        

        let todayString : String = formatter.string(from: todaysDate as Date)
        if dateString == todayString {
            emptyCell.imageView.image = UIImage(named: "TodayEmptyCell")
        }
        else {
            emptyCell.imageView.image = UIImage(named: "EmptyCell")
        }

        cell = emptyCell


        
        print("\(steppingArray.count)")

        if steppingArray.count > 0 {
            
            // make vvv into function later
            for step : SteppingStone in steppingArray{
                
                // vvv lazy comparison. Update to use NSCalendar later
                let stepDateString : String = formatter.string(from: step.deadline! as Date)
                print("occupied " + stepDateString)
                if stepDateString == dateString {
//                    print("occupied\(step.deadline!)")

                    let timelineCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "timelineCell", for: indexPath) as! TimelineCollectionViewCell
                    let myString : String = formatter.string(from: step.deadline! as Date)
                    timelineCell.dateLabel.text = "\(myString)"
                    timelineCell.titleLabel.text = step.title
                    
                    if dateString == todayString && step.isCompleted == true {
                        timelineCell.imageView.image = UIImage(named: "TodayCompletedCell")
                    }
                    else if dateString != todayString && step.isCompleted == true {
                        timelineCell.imageView.image = UIImage(named: "completedCell")
                    }
                    else if dateString == todayString && step.isCompleted == false {
                        timelineCell.imageView.image = UIImage(named: "TodayCollectCell")
                    }
                    else if ((todaysDate.timeIntervalSince1970) > (step.deadline?.timeIntervalSince1970)!) && step.isCompleted == false {
                        timelineCell.imageView.image = UIImage(named: "UnfinishedCell")
                    }
                    else if dateString != todayString && step.isCompleted == false {
                        timelineCell.imageView.image = UIImage(named: "CustomCell")
                    }

                    

                    stepIndexDict[indexPath.row] = step
                    
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let footerView = FooterCollectionReusableView()
        
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath) as! FooterCollectionReusableView
        
        return footerView
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("can move")
        return true
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
    
    func fetchSteppingStone() {
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer : NSPersistentContainer = appDelegate.persistentContainer
        let context : NSManagedObjectContext = persistentContainer.viewContext
        let request : NSFetchRequest = SteppingStone.fetchRequest()
        steppingStoneArray = try! context.fetch(request)
        print ("there are \(steppingStoneArray.count) steppingStones in the array")

    }
    
    func updateTimelinetitle() {
        self.timelineTitleLabel.text = timeline.title
    }

    
}
