import SwiftUI
import CoreLocation

struct MainView: View {
    @ObservedObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State private var searchQuery = ""
    @State var weather:ResponseBody?
    @State var isLoadingWeather = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color("Green1"), Color("Green2")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
       
                if let weather = weather {
                    TextField("", text: $searchQuery)
                        .padding()
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .cornerRadius(20)
                        .modifier(PlaceholderStyle(showPlaceHolder: searchQuery.isEmpty, placeholder: "Search for a city"))
                        .onSubmit {
                            if !searchQuery.isEmpty {
                                locationManager.geocodeCity(city: searchQuery) { coordinates in
                                    if let coordinates = coordinates{
                                        fetchWeatherData(latitude: coordinates.latitude, longitude: coordinates.longitude)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    Text("\(Date().formatted(.dateTime.month().day().hour().minute()))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                    
                    Text(weather.name)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    

                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.weather[0].icon).png")) { image in
                            image

                        } placeholder: {
                            if isLoadingWeather {
                                ProgressView()
                            }
                        }
                    Text("\(weather.main.temp.formatted()) °C")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                Spacer()
                    HStack(spacing:20){
                        WeatherIconSquare(icon: "thermometer", number: weather.main.tempMax)
                        WeatherIconSquare(icon: "humidity", number: weather.main.humidity)
                    }
                    HStack(spacing:20){
                        WeatherIconSquare(icon: "thermometer.sun", number: weather.main.feelsLike)
                        WeatherIconSquare(icon: "wind", number: weather.wind.speed)
                    }
                }
                else{
                    Button {
                        if let location = locationManager.location{
                            fetchWeatherData(latitude: location.latitude, longitude: location.longitude)
                        }
                    } label: {
                        Text("Fetch weather")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .disabled(isLoadingWeather)
                }
                
            }
            .padding(.top)
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    func fetchWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard let _ = locationManager.location else {
            print("User location is not available")
            return
        }
        
        Task {
            isLoadingWeather = true
            
            do {
                let weatherData = try await weatherManager.getCurrentWeather(latitude: latitude, longitude: longitude)
                weather = weatherData
            } catch {
                print("Error while fetching weather data: \(error.localizedDescription)")
            }
            
            isLoadingWeather = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
            }
            content
                .foregroundColor(.white)
                .padding(5)
        }
    }
}

struct WeatherIconSquare:View{
    let icon: String
      let number: Double
    var body: some View{
        HStack{
            Image(systemName: icon)
            Text("\(number.formatted())")
        }
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
