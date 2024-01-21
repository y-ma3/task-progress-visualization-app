import SwiftUI
import RealmSwift

struct TaskListView: View {
    
    @ObservedObject var viewModel: TaskListViewModel
    @ObservedResults(Task.self) var tasks
    
    private var frameWidth: CGFloat {UIScreen.main.bounds.width}
    private var frameHeight: CGFloat {UIScreen.main.bounds.height}
    
    @Binding var taskName:String
    @Binding var taskAmount:Int
    @Binding var taskAmountToAdvancePerDay:Int
    @Binding var selectionDate:Date
    @Binding var period:Int
//    @Binding var numberDoTask:Int
    
    var body: some View {
        VStack {
            Spacer()
            Text("完了タスク一覧")
                .font(.title)
                .padding(.top)
            Spacer()
            Text("達成タスク数：\(tasks.count)個").font(.title3)
            Spacer()
            List(tasks) { task in
                HStack {
                    Image(systemName: "circlebadge.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .padding()
                    Text("\(task.name)")
                        .font(.title3)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        // データベース削除
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
            Spacer()
            ButtonView(buttonText: "新しいタスクを開始する！", width: 300, color: .blue, action: {
                self.viewModel.isShowModal.toggle()
            }).sheet(isPresented: $viewModel.isShowModal) {
                TaskStartPage(showingModal: self.$viewModel.isShowModal, taskName: self.$taskName, taskAmount: self.$taskAmount, taskAmountToAdvancePerDay: self.$taskAmountToAdvancePerDay, selectionDate: self.$selectionDate, period: self.$period)
            }.padding(.bottom)
            Spacer()
        }
    }
}

#Preview {
    TaskListView(viewModel: TaskListViewModel(), taskName: .constant("数学"), taskAmount: .constant(10), taskAmountToAdvancePerDay: .constant(1), selectionDate: .constant(Date()), period: .constant(10))
}
