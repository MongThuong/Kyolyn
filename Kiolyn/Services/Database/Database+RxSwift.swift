//
//  Database+RxSwift.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/14/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    /// Subscribe to do work on database queue asynchronously.
    ///
    /// - Parameters:
    ///   - db: The database.
    ///   - onNext: The operation.
    /// - Returns: The dispposable.
    func subscribeAsync(onError: ((Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil, _ onNext: @escaping (E) -> Void) -> Disposable {
        return self.subscribe(onNext: { e in
            ServiceProvider.default.database.doAsync {
                onNext(e)
            }
        }, onError: onError, onCompleted: onCompleted, onDisposed: onDisposed)
    }
    
    /// Map to perform asynchronous work on database dispatch queue.
    ///
    /// - Parameters:
    ///   - db: The database.
    ///   - transform: The transform method.
    /// - Returns: The `Observable` of the result.
    func mapAsync<R>(transform: @escaping (E) throws -> R) -> Observable<R> {
        return Observable.create { observer in
            return self
                .subscribe { e in
                    switch e {
                    case .next(let value):
                        ServiceProvider.default.database.doAsync {
                            do {
                                let result = try transform(value)
                                observer.on(.next(result))
                            } catch {
                                observer.on(.error(error))
                            }
                        }
                    case .error(let error):
                        observer.on(.error(error))
                    case .completed:
                        observer.on(.completed)
                    }
            }
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    /// Filter with databased related activity
    ///
    /// - Parameter filter: The filter predicate.
    /// - Returns: Observable of filtered result.
    func filterAsync(filter: @escaping (E) throws -> Bool) -> Observable<E> {
        return Observable.create { observer in
            return self
                .subscribe { e in
                    switch e {
                    case .next(let value):
                        ServiceProvider.default.database.doAsync {
                            do {
                                if try filter(value) {
                                    observer.on(.next(value))
                                }
                            } catch { }
                        }
                    case .error(let error):
                        observer.on(.error(error))
                    case .completed:
                        observer.on(.completed)
                    }
            }
        }.observeOn(MainScheduler.asyncInstance)
    }
}

extension ObservableType where E == String {
    /// Load the model from next string
    func loadAsync<T: BaseModel>() -> Observable<T?> {
        return self.mapAsync { id -> T? in
            ServiceProvider.default.database.load(id)
        }
    }
}

extension Database {
    /// Load async with Single result.
    func loadAsync<T: BaseModel>(id: String) -> Single<T?> {
        return Single<T?>.create { single -> Disposable in
            self.doAsync {
                single(.success(self.load(id)))
            }
            return Disposables.create()
        }
    }
}

