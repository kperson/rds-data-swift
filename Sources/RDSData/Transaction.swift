//
//  AutoCommit.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/7/19.
//

import Foundation
import NIO

public class Transaction {
    
    let transactionId: String
    let client: RDSDataClient
    
    public init(transactionId: String, client: RDSDataClient) {
        self.transactionId = transactionId
        self.client = client
    }
    
    public func executeStatement(
        sql: String,
        params: [String : Field] = [:],
        continueAfterTimeout: Bool = true,
        schema: String? = nil
    ) -> EventLoopFuture<ExecuteStatementOutput> {
        do {
            return try client.executeStatement(
                sql: sql,
                params: params,
                transactionId: transactionId,
                continueAfterTimeout: continueAfterTimeout,
                schema: schema
            )
        }
        catch let error {
            let failed: EventLoopFuture<ExecuteStatementOutput> = client.errorEventLoopGroup.next().newFailedFuture(error: error)
            return failed
        }
    }
    
    public func batchExecuteStatement(
        sql: String,
        paramsSet: [[String : Field]],
        schema: String? = nil
    ) -> EventLoopFuture<BatchExecuteStatementOutput> {
        do {
            return try client.batchExecuteStatement(
                sql: sql,
                paramsSet: paramsSet,
                transactionId: transactionId,
                schema: schema
            )
        }
        catch let error {
            let failed: EventLoopFuture<BatchExecuteStatementOutput> = client.errorEventLoopGroup.next().newFailedFuture(error: error)
            return failed
        }
    }
    
    public func commit() -> EventLoopFuture<Void> {
        do {
            return try client.commit(transactionId: transactionId)
        }
        catch let error {
            let failed: EventLoopFuture<Void> = client.errorEventLoopGroup.next().newFailedFuture(error: error)
            return failed
        }
    }
    
    public func rollback() -> EventLoopFuture<Void> {
        do {
            return try client.rollback(transactionId: transactionId)
        }
        catch let error {
            let failed: EventLoopFuture<Void> = client.errorEventLoopGroup.next().newFailedFuture(error: error)
            return failed
        }
    }
    
    public func rollbackFromError<T>(error: Error) -> EventLoopFuture<T> {
        return rollback().then { _ in
            let errorFuture: EventLoopFuture<T> = self.client.errorEventLoopGroup.next().newFailedFuture(error: error)
            return errorFuture
        }
    }
}


extension RDSDataClient {
    
    public func autoCommit<T>(
        schema: String? = nil,
        _ f: @escaping (Transaction) throws -> EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        return beginTransaction(schema: schema).then { tx in
            do {
                return try f(tx)
                .then { val -> EventLoopFuture<T> in
                    return tx.commit().map { _ in val }
                }.thenIfError { error in
                    let failed: EventLoopFuture<T> = tx.rollbackFromError(error: error)
                    return failed
                }
            }
            catch let error {
                let failed: EventLoopFuture<T> = tx.rollbackFromError(error: error)
                return failed
            }
        }
    }
    
    public func beginTransaction(schema: String?) -> EventLoopFuture<Transaction> {
        do {
            return try createTransaction(schema: schema).map { transactionId in
                return Transaction(transactionId: transactionId, client: self)
            }
        }
        catch let error {
            let failed: EventLoopFuture<Transaction> = errorEventLoopGroup.next().newFailedFuture(error: error)
            return failed
        }
    }
    
}
