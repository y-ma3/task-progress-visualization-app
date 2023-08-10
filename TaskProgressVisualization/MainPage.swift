import SwiftUI
import RealmSwift

struct MainPage: View {
    
    private var frameWidth: CGFloat {UIScreen.main.bounds.width}
    @Binding var progressValue:Double
    @Binding var isProgressionTask:Bool
    @State private var isAlert = false
    
    @State private var tasks: Results<Task> = try! Realm().objects(Task.self)
    
    @Binding var taskName:String
    @Binding var taskAmount:Int
    @Binding var taskCompletedAmount:Int
    @Binding var taskAmountToAdvancePerDay:Int
    @Binding var selectionDate:Date
    @Binding var period:Int
    @Binding var daysLeftRatio:Double
    
    @AppStorage("rateOfAchievement") var rateOfAchievement = 0
    
    var body: some View {
        
        let realm = try! Realm()
        let taskSelectionDate = realm.objects(TaskSelectionDate.self)
        
        ZStack {
            
            VStack {
                
                VStack {
                    Text("\(taskName)").font(.title)
                    
                    ZStack {
                        // 外円
                        CircularProgressBar(progress: $progressValue, color: .blue, period: self.$period, selectionDate: self.$selectionDate, daysLeftRatio: self.$daysLeftRatio)
                            .frame(width: frameWidth, height: frameWidth - 130)
                            .padding()
                        // 内円
                        CircularProgressBar(progress: $daysLeftRatio, color: .red, period: self.$period, selectionDate: self.$selectionDate, daysLeftRatio: self.$daysLeftRatio)
                            .frame(width: frameWidth, height: frameWidth - 230)
                        
                    }.padding()
                    
                    HStack {
                        HStack {
                            Text("達成率").font(.title3)
                            Text("\(rateOfAchievement)")
                                .font(.largeTitle)
                            Text("%").font(.title3)
                            Text("|").font(.title)
                            Text("残り\(taskAmount-taskCompletedAmount)")
                        }
                    }
                }.padding(.bottom, 70)
                
                VStack {
                    ButtonView(buttonText: "今日の分クリア！", width: 200, color: Color.blue, action: {
                        
                        taskCompletedAmount += taskAmountToAdvancePerDay
                        rateOfAchievement = taskCompletedAmount * 100 / taskAmount
                        progressValue = Double(taskCompletedAmount*100/taskAmount)/100
                        ForEach(0 ..< tasks.count, id: \.self) { index in
//                        for index in 0 ..< tasks.count {
                            let taskId = tasks[index].id
                            if let nowTask = realm.object(ofType: Task.self, forPrimaryKey: taskId) {
                                do {
                                    try realm.write {
                                        nowTask.setValue(Date(), forKey: "lastDate")
                                    }
                                } catch {
                                    print("データベース更新エラー")
                                }
                            }
                        }
                        
                        // タスク終了時の処理
                        if taskAmount <= taskCompletedAmount {
                            isProgressionTask.toggle()
                            progressValue = 0.0
                            taskAmount = 1
                            taskCompletedAmount = 0
                            rateOfAchievement = 0
                            if let selectionDateToDelete = taskSelectionDate.first {
                                do {
                                    try realm.write {
                                        realm.delete(selectionDateToDelete)
                                    }
                                } catch {
                                    print("データベース削除エラー")
                                }
                            }
                        }
                    }).padding()
                    
                    ButtonView(buttonText: "このタスクをやめる", width: 200, color: .red, action: {
                        isAlert = true
                    })
                    .alert(isPresented: $isAlert) {
                        Alert(title: Text("今回の記録は失われます"), message: Text("本当にタスクを終了しますか？"), primaryButton: .default(Text("いいえ")), secondaryButton: .default(Text("はい"), action: {
                            isProgressionTask = false
                            progressValue = 0.0
                            taskAmount = 1
                            taskCompletedAmount = 0
                            rateOfAchievement = 0
                            // データ削除
                            ForEach(0 ..< tasks.count, id: \.self) { index in
//                            for index in 0 ..< tasks.count {
                                let taskId = tasks[index].id
                                if let taskDelete = realm.object(ofType: Task.self, forPrimaryKey: taskId) {
                                    do {
                                        try realm.write {
                                            realm.delete(taskDelete)
                                        }
                                    } catch {
                                        print("データベース削除エラー")
                                    }
                                }
                            }
                            // ループの外側でtaskSelectionDateを削除
                            if let selectionDateToDelete = taskSelectionDate.first {
                                do {
                                    try realm.write {
                                        realm.delete(selectionDateToDelete)
                                    }
                                } catch {
                                    print("データベース削除エラー")
                                }
                            }
                        }))
                    }
                }
                
                //                Button(action: {
                //                    let realm = try! Realm()
                //                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                //                    let taskTable = realm.objects(TaskSelectionDate.self)
                //                    print(taskTable)
                //                }, label: {
                //                    Text("データベース取得")
                //                }).padding()
                
                                Button(action: {
                                    if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
                                        try! FileManager.default.removeItem(at: fileURL)
                                    }
                                }, label: {
                                    Text("アプリ内からデータベースファイルごと削除")
                                }).padding()
            }
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(progressValue: .constant(0.5), isProgressionTask: .constant(true), taskName: .constant("数学"), taskAmount: .constant(100), taskCompletedAmount: .constant(20), taskAmountToAdvancePerDay: .constant(1), selectionDate: .constant(Date()), period: .constant(20), daysLeftRatio: .constant(0.6))
    }
}
