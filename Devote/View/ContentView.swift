import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - PROPERTY
    
    @State var task: String = ""
    
    private var isButtonDisabled: Bool {
        task.isEmpty
    }
    
    // FETCHING DATA
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    // MARK: - FUNCTION
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.task = task
            newItem.completion = false
            newItem.id = UUID()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            task = ""
            hideKeyboard()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - BODY
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack(spacing: 16) {
                        TextField("New task", text: $task)
                            .padding()
                            .background(
                                Color(UIColor.systemGray6)
                            )
                            .cornerRadius(10)
                        
                        Button(action: {
                            addItem()
                        }, label: {
                            Spacer()
                            Text("Save".uppercased())
                            Spacer()
                        })
                        .disabled(isButtonDisabled)
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(isButtonDisabled ? Color.gray : Color.pink)
                        .cornerRadius(10)
                    } //: VSTACK
                    .padding()
                    
                    List {
                        ForEach(items) { item in
                            NavigationLink {
                                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.task ?? "")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text(item.timestamp!, formatter: itemFormatter)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                } //: LIST ITEM
                            }
                        } //: LOOP
                        .onDelete(perform: deleteItems)
                    } //: LIST
                    .listStyle(PlainListStyle()) // remove left and rigt padding
                } //: VSTACK
            } //: ZSTACK
            .navigationBarTitle("Daily tasks", displayMode: .large)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
            } //: TOOLBAR
        } //: NAVIGATION
//        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 Pro")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
