
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHelper : NSObject  {
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API

extension IAPHelper {
  
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
//        print("Request Products")
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
  
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
  
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
           print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
//        print("Failed to load list of products.")
        
        let userInfoDict:[String: String] = ["forButton": "iapfail"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
        
//        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

//MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        
        let userInfoDict:[String: String] = ["forButton": "iapfail"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
        
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        if identifier == IAPProducts.NoAds {
            purchasedProductIdentifiers.insert(identifier)
            UserDefaults.standard.set(true, forKey: identifier)
            UserDefaults.standard.synchronize()
            
            let noAdsPurchased = UserDefaults.standard.bool(forKey: "noAdsPurchased")
            if !noAdsPurchased {
                // purchased NoAds
                UserDefaults.standard.set(true, forKey: "noAdsPurchased")
                // remove banner ads
                NotificationCenter.default.post(name: Notification.Name(rawValue: "removeBannerAds"), object: nil)
            }
        } else if identifier == IAPProducts.Ring200 {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "coinNumber") + 200, forKey: "coinNumber")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addedCoins"), object: nil)
        } else if identifier == IAPProducts.Ring500 {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "coinNumber") + 500, forKey: "coinNumber")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addedCoins"), object: nil)
        } else if identifier == IAPProducts.Ring900 {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "coinNumber") + 900, forKey: "coinNumber")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addedCoins"), object: nil)
        }
        
        
    }
}