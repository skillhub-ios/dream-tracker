import SwiftUI

struct OnboardingView: View {
    @State private var step = 0
    @State private var dreamFeelings: [String] = []
    @State private var lifeFocus: [String] = []
    @State private var ageRange: String = ""
    @State private var gender: String = "Not to say"
    @State private var dreamMeaning: String = ""
    @State private var reminders: Bool = false
    @State private var bedtime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
    @State private var wakeup: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @State private var faceID: Bool = false
    @State private var language: String = "ru"
    @Environment(\.dismiss) private var dismiss
    @Binding var hasCompletedOnboarding: Bool
    @State var showingAgeOptions = false
    @State var showingGenderOptions = false
    @State private var selectedLanguage = ""
    @State private var showLanguagePicker = false
    
    let feelingsOptions = ["Vivid", "Weird", "Emotional", "Spiritual", "Dark", "Symbolic", "Lucid", "Realistic"]
    let focusOptions = ["Love & Relationships", "Career Growth", "Mental Health", "Spirituality", "Past Trauma", "Creativity", "Personal Growth"]
    let ageOptions = ["Under 18", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    let genderOptions = ["Not to say", "Male", "Female", "Non-binary", "Trans man", "Trans woman", "Other"]
    let dreamMeaningOptions = ["Yes", "Somewhat", "Not really"]
    let languageOptions = ["ru", "en"]
    
    var body: some View {
        ZStack{
            Image(step > 0 ? "background2" : "background")
                   .resizable()
                   .scaledToFill()
                   .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 10){
                if step == 0 {
                    Spacer()
                    VStack{
                        Text("🌙 Uncover Your Dreams with AI")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.white)
                            .bold()
                         Text("Explore your subconscious. One dream at a time.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                     
                    Button(action: {
                        step += 1
                    }) {
                        Text("Next")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.32, green: 0.24, blue: 0.36), // начальный цвет
                                        Color(red: 0.36, green: 0.22, blue: 0.44)  // конечный цвет
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color(hex: "#545458").opacity(0.65), lineWidth: 1.5)
                            )
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    HStack{
                        Button(action: {
                            saveProfileAndFinish()
                        }) {
                            Text("Do you already have an account? Sign in")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .frame(maxWidth: .infinity)
                     .padding(.bottom,40)
                    

                } else if step == 1 {
                    Spacer()

                         Text("Hi there 👋")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 22))
                         Text("Let’s help you get more accurate dream insights")
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                     VStack(alignment: .leading, spacing: 10){
                        Text("🔮 How do your dreams usually feel?")
                            .foregroundColor(.white)
                            .font(.system(size: 17))
                        ForEach(feelingsOptions, id: \.self) { feeling in
                            Button(action: {
                                if dreamFeelings.contains(feeling) {
                                    dreamFeelings.removeAll { $0 == feeling }
                                } else {
                                    dreamFeelings.append(feeling)
                                }
                            }) {
                                HStack {
                                    Text(feeling)
                                        .foregroundColor(.white)
                                        .font(.system(size: 17))
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if dreamFeelings.contains(feeling) {
                                            Circle()
                                                .fill(Color.purple)
                                                .frame(width: 24, height: 24)
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                    }
                                     
                                }
                                .padding(.vertical,10)
                                .contentShape(Rectangle()) // чтобы тап был по всей ширине
                             }
                            .buttonStyle(PlainButtonStyle()) // чтобы кнопка не имела стилей по умолчанию
                        }
                     }
                    .padding()
                    .background(Color(UIColor(red: 35/255, green: 24/255, blue: 40/255, alpha: 1)))
                    .cornerRadius(13)
                    Spacer()

                    Button(action: {
                        step += 1
                    }) {
                        Text("Next")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.32, green: 0.24, blue: 0.36), // начальный цвет
                                        Color(red: 0.36, green: 0.22, blue: 0.44)  // конечный цвет
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color(hex: "#545458").opacity(0.65), lineWidth: 1.5)
                            )
                            .cornerRadius(13)
                            .padding(.horizontal)
 
                    }
                    Button(action: {
                        step += 1
                    }) {
                        Text("Skip")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 30)

                } else if step == 2 {
                    Spacer()
                    VStack(alignment: .leading, spacing: 10){
                        Text("Life Focus")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 22))
                         Text("To understand your dreams better")
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                     }
                     VStack(alignment: .leading, spacing: 10){
                        Text("💫 What’s currently top of mind for you?")
                            .foregroundColor(.white)
                            .font(.system(size: 17))
                        ForEach(focusOptions, id: \.self) { focus in
                            Button(action: {
                                if lifeFocus.contains(focus) {
                                    lifeFocus.removeAll { $0 == focus }
                                } else {
                                    lifeFocus.append(focus)
                                }
                            }) {
                                HStack {
                                    Text(focus)
                                        .foregroundColor(.white)
                                        .font(.system(size: 17))
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if lifeFocus.contains(focus) {
                                            Circle()
                                                .fill(Color.purple)
                                                .frame(width: 24, height: 24)
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                     }
                    .padding()
                    .background(Color(UIColor(red: 35/255, green: 24/255, blue: 40/255, alpha: 1)))
                    .cornerRadius(13)
                    Spacer()
                    Button(action: {
                        step += 1
                    }) {
                        Text("Next")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.32, green: 0.24, blue: 0.36), // начальный цвет
                                        Color(red: 0.36, green: 0.22, blue: 0.44)  // конечный цвет
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color(hex: "#545458").opacity(0.65), lineWidth: 1.5)
                            )
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    Button(action: {
                        step += 1
                    }) {
                        Text("Skip")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 30)

 
                } else if step == 3 {
                    Spacer()
                    Text("Quick Personalization")
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size: 22))
                    VStack{
                        HStack{
                            Text("Age range")
                                .foregroundColor(.white)
                            Spacer()
                            Picker("Age range", selection: $ageRange) {
                                ForEach(ageOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .foregroundColor(.gray)
                         }
                        .padding(.horizontal)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(13)

                        
                        HStack{
                            Text("gender")
                                .foregroundColor(.white)
                            Spacer()
                            Picker("Age range", selection: $gender) {
                                ForEach(genderOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(13)

                    }
                    .padding()
                    .background(Color(UIColor(red: 35/255, green: 24/255, blue: 40/255, alpha: 1)))
                    .cornerRadius(13)


                    VStack{
                        VStack{
                            ForEach(dreamMeaningOptions, id: \.self) { option in
                                Button(action: {
                                    dreamMeaning = option
                                }) {
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.white)
                                            .font(.system(size: 17))
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .stroke(Color.gray, lineWidth: 2)
                                                .frame(width: 24, height: 24)

                                            if dreamMeaning == option {
                                                Circle()
                                                    .fill(Color.purple)
                                                    .frame(width: 24, height: 24)
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14, weight: .bold))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(13)

                    }
                    .padding()
                    .background(Color(UIColor(red: 35/255, green: 24/255, blue: 40/255, alpha: 1)))
                    .cornerRadius(13)
                    Spacer()
                    Spacer()
                    Button(action: {
                        step += 1
                    }) {
                        Text("Next")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.32, green: 0.24, blue: 0.36), // начальный цвет
                                        Color(red: 0.36, green: 0.22, blue: 0.44)  // конечный цвет
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color(hex: "#545458").opacity(0.65), lineWidth: 1.5)
                            )
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    Button(action: {
                        step += 1
                    }) {
                        Text("Skip")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                } else if step == 4 {
                    Spacer()
                    Text("Notifications")
                        .font(.system(size: 22))
                        .bold()
                        .foregroundColor(.white)
                    VStack{
                        HStack{
                            Text("Reminder")
                                .font(.system(size: 17))
                                 .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $reminders)
                                .tint(.purple)

                        }
                         
                        if reminders{
                            HStack{
                                Text("Bedtime")
                                        .foregroundColor(.white) // Цвет текста метки
                                Spacer()

                                DatePicker("", selection: $bedtime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                            .colorScheme(.dark) // Чтобы колесо было светлым на тёмном фоне
                                            .accentColor(.purple)
                                }
                            HStack{
                                Text("Wake-up")
                                        .foregroundColor(.white)
                                Spacer()
                                    DatePicker("", selection: $wakeup, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .accentColor(.purple)
                            }
                            
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(13)
                     
                    Text("Privacy")
                        .font(.system(size: 17))
                        .bold()
                        .foregroundColor(.white)
                    
                    HStack{
                        Text("Face ID")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                        Toggle("", isOn: $faceID)
                            .tint(.purple)


                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(13)
                    Text("Privacy")
                        .font(.system(size: 17))
                        .bold()
                        .foregroundColor(.white)
                    HStack{
                        Button(action: {
                                   showLanguagePicker = true
                               }) {
                                   HStack {
                                       Text(selectedLanguage.isEmpty ? "🇬🇧Language" : (selectedLanguage == "ru" ? "Русский" : "English"))
                                           .foregroundColor(selectedLanguage.isEmpty ? .gray : .white)
                                       Spacer()
                                       Image(systemName: "chevron.right")
                                           .foregroundColor(.gray)
                                   }
                                   .padding()
                                   .background(Color.purple.opacity(0.1))
                                   .cornerRadius(13)
                               }
                               .sheet(isPresented: $showLanguagePicker) {
                                   LanguagePickerView(selectedLanguage: $selectedLanguage)
                               }
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                     Button(action: {
                         saveProfileAndFinish()
                    }) {
                        Text("Next")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.32, green: 0.24, blue: 0.36), // начальный цвет
                                        Color(red: 0.36, green: 0.22, blue: 0.44)  // конечный цвет
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color(hex: "#545458").opacity(0.65), lineWidth: 1.5)
                            )
                            .cornerRadius(13)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                     
                }
            }
            .padding()
        }
        
    }
    
    private func saveProfileAndFinish() {
        let notifications = NotificationsSettings(reminders: reminders, bedtime: bedtime, wakeup: wakeup, faceID: faceID)
        let profile = UserProfile(
            dreamFeelings: dreamFeelings,
            lifeFocus: lifeFocus,
            ageRange: ageRange,
            gender: gender,
            dreamMeaning: dreamMeaning,
            notifications: notifications,
            language: language
        )
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
        hasCompletedOnboarding = true // <-- это скроет онбординг
    }
}
struct LanguagePickerView: View {
    static let customGrayOverlay = Color(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: 0.36)
    static let customLightGray = Color(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: 0.6)
    @Binding var selectedLanguage: String
    @Environment(\.dismiss) var dismiss

    let options = [("Русский", "ru"), ("English", "en")]

    var body: some View {
        ZStack{
            Color.customBackground
                .ignoresSafeArea()
            VStack{
                VStack(spacing: 20) {
                    ForEach(options, id: \.1) { label, tag in
                        Button(action: {
                            selectedLanguage = tag
                            dismiss()
                        }) {
                            HStack {
                                  ZStack {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 2)
                                        .frame(width: 24, height: 24)

                                    if selectedLanguage == tag {
                                        Circle()
                                            .fill(Color.purple)
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                Text(label)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                 }
                .padding(.top)
                .padding(.horizontal)
                .background(Color.customSecondaryBackground)
                .cornerRadius(13)
                Spacer()
            }
             

         }
     
 
    }
}

