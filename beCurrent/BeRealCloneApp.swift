import SwiftUI

@main
struct BeRealCloneApp: App {
    // MARK: - Dependency Container
    private let dependencyContainer = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencyContainer.cameraViewModel)
                .environmentObject(dependencyContainer.feedViewModel)
        }
    }
}

// MARK: - Dependency Injection Container
class DependencyContainer: ObservableObject {
    
    // MARK: - Data Layer
    private lazy var cameraRepository: CameraRepository = {
        AVFoundationCameraRepository()
    }()
    
    private lazy var postRepository: PostRepository = {
        CoreDataPostRepository()
    }()
    
    private lazy var locationRepository: LocationRepository = {
        CoreLocationRepository()
    }()
    
    private lazy var notificationRepository: NotificationRepository = {
        UserNotificationRepository()
    }()
    
    // MARK: - Domain Layer (Use Cases)
    private lazy var captureBeRealUseCase: CaptureBeRealUseCase = {
        CaptureBeRealUseCase(
            cameraRepository: cameraRepository,
            postRepository: postRepository,
            locationRepository: locationRepository
        )
    }()
    
    private lazy var getFeedUseCase: GetFeedUseCase = {
        GetFeedUseCase(postRepository: postRepository)
    }()
    
    private lazy var sendNotificationUseCase: SendNotificationUseCase = {
        SendNotificationUseCase(notificationRepository: notificationRepository)
    }()
    
    // MARK: - Presentation Layer (ViewModels)
    lazy var cameraViewModel: CameraViewModel = {
        CameraViewModel(captureBeRealUseCase: captureBeRealUseCase)
    }()
    
    lazy var feedViewModel: FeedViewModel = {
        FeedViewModel(getFeedUseCase: getFeedUseCase)
    }()
}

// MARK: - Root Content View
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Camera")
                }
                .tag(0)
            
            FeedView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Feed")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.primary)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(DependencyContainer().cameraViewModel)
        .environmentObject(DependencyContainer().feedViewModel)
}