# TipJarUI 💸

A beautifully designed, lightweight SwiftUI package that lets you add a **native tip jar experience** to your app — enabling users to support your work through simple, seamless one-time purchases powered by StoreKit.

Built for modern iOS apps with a focus on **clean API, customization, and developer experience**.

---

## ✨ Why TipJarUI?

TipJarUI is designed to feel like a **native iOS feature**, not a third-party add-on.

- ⚡ Zero boilerplate integration
- 🎨 Fully customizable SwiftUI layout
- 🧠 Clean View + Modifier architecture
- 💰 Built on Apple StoreKit (iOS 17+)
- 🔄 Handles full purchase lifecycle automatically
- 🫧 Adaptive UI (Glass effects on supported iOS versions)
- 🧩 Production-ready API design

---

## 📱 Demo

> 🎬 Add your simulator recording / App Preview here

```
https://your-demo-video-or-github-asset-link.mp4
```

---

## 🚀 Installation

### Swift Package Manager

Add TipJarUI via Xcode:

```
File → Add Package Dependencies
```

Or add manually:

```
https://github.com/your-username/TipJarUI.git
```

---

## 🛠 Requirements

- iOS 17.0+
- SwiftUI
- StoreKit

---

## 💡 Usage

### 1. SwiftUI Modifier (Recommended)

The simplest and cleanest way to present TipJarUI:

```swift
import SwiftUI
import TipJarUI

struct ContentView: View {
    @State private var showTipJar = false

    var body: some View {
        VStack(spacing: 20) {

            Text("Welcome to my app")
                .font(.title)

            Button("Support Developer ❤️") {
                showTipJar = true
            }
            .buttonStyle(.borderedProminent)
        }
        .tipJarUI(
            isPresented: $showTipJar,
            ids: ["tip.small", "tip.medium", "tip.large"],
            thankingMessage: "Thank you for your support ❤️"
        ) {
            Text("Support This App")
                .font(.headline)
        } icon: { product in
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
                .font(.title2)
        } footer: {
            Text("Every tip helps me build better features 🚀")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } onStart: { product in
            print("Started purchase: \(product.id)")
        } onCompletion: { product, result in
            print("Completed purchase: \(product.id)")
        }
    }
}
```

---

### 2. Direct View Usage

Use `TippingView` when you want full control:

```swift
TippingView(
    thankingMessage: "Thanks for supporting the journey ❤️",
    ids: ["tip.small", "tip.medium", "tip.large"]
) {
    Text("Support Developer")
        .font(.headline)
} icon: { product in
    Image(systemName: "star.fill")
        .foregroundStyle(.yellow)
} footer: {
    Text("Your support keeps this app alive 🚀")
}
```

---

## ⚙️ Configuration Options

| Parameter | Description |
|----------|------------|
| `ids` | StoreKit product identifiers |
| `header` | Top section UI |
| `icon` | Custom product representation |
| `footer` | Bottom message UI |
| `onStart` | Called when purchase starts |
| `onCompletion` | Called when purchase completes |
| `thankingMessage` | Success message shown after purchase |

---

## 🧠 How It Works

- Uses `StoreView` to fetch and display products
- Handles StoreKit purchase flow internally
- Automatically verifies transactions
- Finishes purchases securely
- Provides full lifecycle callbacks

---

## 🎯 Best Practices

- Use 3–5 tip amounts (Small / Medium / Large)
- Keep emotional messaging in header/footer
- Use consumable products for tipping
- Keep UI minimal for better conversion

---

## 💎 Philosophy

TipJarUI is built to feel like a **native Apple feature**, not a third-party library.

It focuses on:

- Simplicity over complexity
- Developer experience first
- Clean SwiftUI architecture
- Production-ready design patterns

---

## 🤝 Contributing

Contributions, ideas, and improvements are welcome.  
Feel free to open issues or PRs.

---

## 📄 License

MIT License

---

## ⭐ Support

If you find this project useful:

- ⭐ Star the repository
- 🧃 Or… let users tip you through it 😄

