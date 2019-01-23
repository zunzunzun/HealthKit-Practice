//
//  ViewController.swift
//  HealthKitPractice
//
//  Created by zun on 22/01/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
  
  @IBOutlet weak var totalSteps: UILabel!
  
  let healthStore = HKHealthStore()
  
  @IBAction func authoriseHealthKitAccess(_ sender: Any) {
    //걸음을 얻기위해 step count 정의
    let stepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    
    //권한을 요청하기 위해 Set으로 만듬
    let healthKitTypes: Set = [
      // access step count
      stepCount
    ]
    
    //만약에 권한을 얻지 못했다면 실행될 조건문
    if healthStore.authorizationStatus(for: stepCount) == .sharingDenied {
      //do something
    }
    
    //health 앱에 권한 요청.
    healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (bool, error) in
      if let e = error {
        print("oops something went wrong during authorisation \(e.localizedDescription)")
      } else {
        print("User has completed the authorization flow")
      }
    }
  }
  
  //오늘 걸음을 구함.
  func getTodaysSteps(completion: @escaping (Double) -> Void) {
    
    let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    let now = Date()
    let startOfDay = Calendar.current.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
    
    let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
      var resultCount = 0.0
      guard let result = result else {
        print("Failed to fetch steps rate")
        completion(resultCount)
        return
      }
      if let sum = result.sumQuantity() {
        resultCount = sum.doubleValue(for: HKUnit.count())
      }
      
      DispatchQueue.main.async {
        completion(resultCount)
      }
    }
    healthStore.execute(query)
  }
  
  //버튼을 눌러 걸음을 표시.
  @IBAction func getTotalSteps(_ sender: Any) {
    getTodaysSteps { (result) in
      print("\(result)")
      DispatchQueue.main.async {
        self.totalSteps.text = "\(result)"
      }
    }
  }
  
  //건강 앱으로 가는 버튼.
  @IBAction func jumpButtonTap(_ sender: UIButton) {
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(URL(string: "x-apple-health://sources")!)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //앱에 처음 시작될때 alert를 띄움.
    let alert = UIAlertController.alert(title: "안녕", message: "하이하이", style: .alert)
    alert.action(title: "dd", style: .default, handler: nil)
    self.present(alert, animated: true, completion: nil)
  }
  
}

