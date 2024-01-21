import Foundation
import RealmSwift

final class NavigationRouter: ObservableObject {
    @MainActor @Published var navigationPath: [Path] = []
  
    enum Path: Hashable {
        case list // タスク一覧画面
        case start // タスクスタート画面
        case setting // 設定画面
    }
}

class RealmHelper {

    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error.localizedDescription)")
        }
    }

    func add(_ name: String) {
        let newTask = Task()
        newTask.name = name

        do {
            try realm.write {
                realm.add(newTask)
            }
        } catch {
            print("Error adding YourObject: \(error.localizedDescription)")
        }
    }

    func update(_ task: Task, name: String) {
        do {
            try realm.write {
                task.name = name
            }
        } catch {
            print("Error updating YourObject: \(error.localizedDescription)")
        }
    }

    func delete(_ task: Task, deleteID: ObjectId) {
        let deleteData = realm.objects(Task.self).filter("id == \(deleteID)")
        do {
            try realm.write {
                realm.delete(deleteData)
            }
        } catch {
            print("Error deleting YourObject: \(error.localizedDescription)")
        }
    }
}
