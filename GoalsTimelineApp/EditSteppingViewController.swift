//
//  EditSteppingViewController.swift
//  GoalsTimelineApp
//
//  Created by Olga on 10/31/17.
//  Copyright © 2017 Carlo Namoca. All rights reserved.
//

import UIKit

class EditSteppingViewController: UIViewController {

    @IBOutlet weak var edtitSteppingStoneTitleView: UITextField!
    @IBOutlet weak var editSteppingStoneNotesView: UITextView!
    @IBOutlet weak var editSteppingStoneDeadline: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveStappingStoneChanges(_ sender: UIButton) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
