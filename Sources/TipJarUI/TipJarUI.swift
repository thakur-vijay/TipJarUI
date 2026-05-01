// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import StoreKit


/// A customizable SwiftUI view that presents a tip jar interface using StoreKit products.
///
/// `TippingView` allows you to display a list of in-app purchase products (typically consumables)
/// so users can support your app via one-time contributions. It provides flexible slots for
/// header, icon, and footer content, along with lifecycle callbacks for purchase events.
///
/// You can fully customize the UI while leveraging built-in StoreKit purchase handling.
///
/// - Note: Requires iOS 17.0 or later.
/// - Important: Product identifiers passed in `ids` must be configured in App Store Connect.
@available(iOS 17.0, *)
public struct TippingView<Header: View, Icon: View, Footer: View>: View {
    private var thankingMessage: String = "Thanks for your support!"
    private var ids: [String]
    private var header: ()-> Header
    private var icon: (Product)-> Icon
    private var footer: ()-> Footer
    
    private var onStart: (Product)->()
    private var onCompletion: (Product, Result<Product.PurchaseResult, any Error>)->()
    private var onDismiss: ()-> ()
    
    /// Creates a new `TippingView`.
    ///
    /// - Parameters:
    ///   - thankingMessage: Message shown after a successful purchase. Defaults to `"Thanks for your support!"`.
    ///   - ids: Array of StoreKit product identifiers to display.
    ///   - header: A view builder that provides the header content.
    ///   - icon: A view builder that provides a custom icon for each product.
    ///   - footer: A view builder that provides the footer content.
    ///   - onStart: Callback triggered when a purchase starts.
    ///   - onCompletion: Callback triggered when a purchase completes with a result.
    ///   - onDismiss: Callback triggered when the view is dismissed.
    public init(
        thankingMessage: String = "Thanks for your support!",
        ids: [String],
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder icon: @escaping (
            Product
        ) -> Icon,
        @ViewBuilder footer: @escaping () -> Footer,
        onStart: @escaping (
            Product
        ) -> () = { _ in },
        onCompletion: @escaping (
            Product,
            Result<
            Product.PurchaseResult,
            any Error
            >
        ) -> () = { _, _ in },
        onDismiss: @escaping () -> () = {},
    ) {
        self.thankingMessage = thankingMessage
        self.ids = ids
        self.header = header
        self.icon = icon
        self.footer = footer
        self.onStart = onStart
        self.onCompletion = onCompletion
        self.onDismiss = onDismiss
    }
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var updatesListener: Task<Void, Error>?
    @Environment(\.colorScheme) private var colorScheme
    /// The content and behavior of the view.
    public var body: some View {
        let glassTint: Color = colorScheme == .dark ? .gray.opacity(0.15) : .white.opacity(0.8)
        VStack(spacing: 10) {
            header()
                .padding(.horizontal, 15)
                .padding(.top, 12)
            
            StoreView(ids: ids) { product in
                icon(product)
            }
            .productViewStyle(.compact)
            .fixedSize(horizontal: false, vertical: true)
            .storeButton(.hidden, for: .cancellation)
            .customGlassButtonStyle()
            
            footer()
             
            
            Button {
                
            } label: {
                Text("Dismiss")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .opacity(isLoading ? 0 : 1)
                    .overlay {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(.white)
                            .opacity(isLoading ? 1 : 0)
                    }
            }
            .customGlassButtonStyle()
            .tint(.red)
            .padding(.horizontal, 15)
            .padding(.bottom, 12)
        }
        .allowsHitTesting(!isLoading)
        .opacity(isLoading ? 0.7 : 1)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .customGlassBackground(shape: .rect(cornerRadius: 25), glassTint: glassTint)
        .geometryGroup()
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
        .onInAppPurchaseStart { product in
            onStart(product)
            isLoading = true
        }
        .onInAppPurchaseCompletion { product, result in
            switch result {
            case .success(let result):
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        await transaction.finish()
                        alertMessage = thankingMessage
                    case .unverified(_, _):
                        alertMessage = "The purchase was successfull but app store couldn't verify it. Please try again."
                    }
                case .userCancelled:
                    alertMessage = "User cancelled the purchase."
                case .pending:
                   alertMessage = "The purchase is pending."
                default: ()
                }
            case .failure(_):
                alertMessage = "There was an error processing your purchase. Please try again."
            }
            onCompletion(product, result)
            showAlert = true
            isLoading = false
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("Done", role: .cancel){
                
            }
        }
        .onAppear {
            updatesListener = Task.detached {
                for await updates in Transaction.updates {
                    if case .verified(let transaction) = updates {
                        await transaction.finish()
                    }
                }
            }
        }
        .onDisappear {
            updatesListener?.cancel()
        }
    }
}

@available(iOS 17, *)
public extension View {
    /// Presents a full-screen tip jar interface using a modifier.
    ///
    /// This modifier provides a convenient way to integrate `TippingView` into any SwiftUI view
    /// using a declarative API similar to native presentation modifiers like `.sheet` or `.fullScreenCover`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls the presentation of the tip jar.
    ///   - ids: Array of StoreKit product identifiers to display.
    ///   - thankingMessage: Message shown after a successful purchase.
    ///   - header: A view builder that provides the header content.
    ///   - icon: A view builder that provides a custom icon for each product.
    ///   - footer: A view builder that provides the footer content.
    ///   - onStart: Callback triggered when a purchase starts.
    ///   - onCompletion: Callback triggered when a purchase completes with a result.
    ///   - onDismiss: Callback triggered when the view is dismissed.
    ///
    /// - Returns: A modified view that presents the tip jar UI.
    @ViewBuilder
    func tipJarUI<Header: View, Footer: View, Icon: View>(
        isPresented: Binding<Bool>,
        ids: [String],
        thankingMessage: String = "Thanks for your support!",
        @ViewBuilder header: @escaping ()->Header,
        @ViewBuilder icon: @escaping (Product)->Icon,
        @ViewBuilder footer: @escaping ()->Footer,
        onStart: @escaping (Product)->() = { _ in },
        onCompletion: @escaping (Product, Result<Product.PurchaseResult, any Error>)->() = { _, _ in },
        onDismiss: @escaping ()->() = { },
    )-> some View {
        self
            .modifier(
                TipJarUIModifier(
                    isPresented: isPresented,
                    ids: ids,
                    thankingMessage: thankingMessage,
                    header: header,
                    icon: icon,
                    footer: footer,
                    onStart: onStart,
                    onCompletion: onCompletion,
                    onDismiss: onDismiss
                )
            )
    }
    
    /// Applies a platform-adaptive prominent button style.
    ///
    /// Uses `.glassProminent` style on supported iOS versions (26+),
    /// otherwise falls back to `.borderedProminent`.
    ///
    /// - Returns: A styled view.
    @ViewBuilder
    func customGlassButtonStyle()-> some View {
        if #available(iOS 26, *){
            self
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
        }else {
            self
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
        }
    }
    
    /// Applies a glass-like background effect with graceful fallback.
    ///
    /// On newer iOS versions, this uses the system glass effect.
    /// On older versions, it falls back to a clipped shape with shadows.
    ///
    /// - Parameters:
    ///   - shape: The shape used for clipping and background.
    ///   - glassTint: Optional tint color for the glass effect.
    ///
    /// - Returns: A view with a styled background.
    @ViewBuilder
    func customGlassBackground<S: Shape>(shape: S, glassTint: Color = .clear)-> some View {
        if #available(iOS 26, *){
            self
                .glassEffect(.regular.tint(glassTint).interactive(), in: shape)
        }else {
            self
                .clipShape(shape)
                .background{
                    shape
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
                }
        }
    }
}

/// A view modifier responsible for presenting `TippingView` as a full-screen cover.
///
/// This is used internally by the `tipJarUI` modifier to handle presentation logic.
@available(iOS 17.0, *)
fileprivate struct TipJarUIModifier<Header: View, Footer: View, Icon: View>: ViewModifier {
    @Binding var isPresented: Bool
    var ids: [String]
    var thankingMessage: String = "Thanks for your support!"
    @ViewBuilder var header: ()-> Header
    @ViewBuilder var icon: (Product)-> Icon
    @ViewBuilder var footer: ()-> Footer
    
    var onStart: (Product)->() = { _ in }
    var onCompletion: (Product, Result<Product.PurchaseResult, any Error>)->() = { _, _ in }
    var onDismiss: ()-> () = { }
    func body(content: Content) -> some View {
        content
            .fullScreenCover(
                isPresented: $isPresented
            ) {
                TippingView(
                    thankingMessage: thankingMessage,
                    ids: ids,
                    header: header,
                    icon: icon,
                    footer: footer,
                    onStart: onStart,
                    onCompletion: onCompletion,
                    onDismiss: onDismiss
                )
            }
    }
}

