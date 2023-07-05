import SwiftUI
import RealmSwift

struct MainPage: View {
    
    private var frameWidth: CGFloat {UIScreen.main.bounds.width}
    @AppStorage("progressValue") var progressValue = 0.0
    @Binding var isPregressionTask:Bool
    
    @Binding var taskName:String
    @Binding var amountTask:Int
    @Binding var amountToAdvancePerDay:Int
    @Binding var selectionDate:Date
    
    @Binding var differenceOfDate:Int
    @Binding var storeFirstDifferenceOfDate:Int
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .stroke(lineWidth: 5)
                    .frame(width: frameWidth-30, height: 50)
                Text("\(taskName)").font(.title)
            }
            ZStack {
                // 外円
                CircularProgressBar(progress: $progressValue, color: .blue, selectionDate: self.$selectionDate)
                    .frame(width: frameWidth, height: 270.0)
                    .padding()
                // 内円
                var daysLeftsRatio = Double(differenceOfDate) / Double(storeFirstDifferenceOfDate)
                CircularProgressBar(progress: Binding<Double>(get: { Double(daysLeftsRatio) }, set: { daysLeftsRatio = Double($0) }), color: .red, selectionDate: self.$selectionDate)
                    .frame(width: frameWidth,height: 170)
            }.padding()
            
            HStack {
                Text("\(Int(progressValue*100))%").font(.largeTitle)
                Text("達成中！").font(.title)
            }
            
            ButtonView(buttonText: "今日の分クリア！", width: 170, color: Color.blue, action: {
                let raitoPerDay = Double(amountToAdvancePerDay) / Double(amountTask)
                progressValue += raitoPerDay
                print(Double(storeFirstDifferenceOfDate))
                print(progressValue)
                if progressValue >= 1 {
                    isPregressionTask.toggle()
                    progressValue = 0
                }
            })
            
            Button(action: {
                let realm = try! Realm()
                let taskTable = realm.objects(Task.self)
                print(taskTable)
            }, label: {
                Text("データベース取得")
            }).padding()
            
            Button(action: {
                let realm = try! Realm()
                try! realm.write {
                    let taskTable = realm.objects(Task.self)
                    realm.delete(taskTable)
                }
            }, label: {
                Text("データベース削除")
            }).padding()
            
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

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(isPregressionTask: .constant(true), taskName: .constant("数学"), amountTask: .constant(10), amountToAdvancePerDay: .constant(1), selectionDate: .constant(Date()), differenceOfDate: .constant(1), storeFirstDifferenceOfDate: .constant(1))
    }
}
