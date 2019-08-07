//
//  BeginTransaction.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/5/19.
//

import Foundation
import AWSSDKSwiftCore
import NIO


public extension RDSDataClient {

    func beginTransaction(schema: String? = nil) throws -> EventLoopFuture<String> {
        let input = CreateTransactionInput(
            database: database,
            resourceArn: resourceArn,
            schema: schema,
            secretArn: secretArn
        )
        let output: EventLoopFuture<CreateTransactionOutput> = try client.send(
            operation: "",
            path: "/BeginTransaction",
            httpMethod: "POST",
            input: input
        )
        return output.map { $0.transactionId }
    }
    
    func commit(transactionId: String) throws -> EventLoopFuture<Void> {
        let input = TransactionInput(
            resourceArn: resourceArn,
            secretArn: secretArn,
            transactionId: transactionId
        )
        let output: EventLoopFuture<TransactionOutput> = try client.send(
            operation: "",
            path: "/CommitTransaction",
            httpMethod: "POST",
            input: input
        )
        return output.map { _ in Void() }
    }
    
    func rollback(transactionId: String) throws -> EventLoopFuture<Void> {
        let input = TransactionInput(
            resourceArn: resourceArn,
            secretArn: secretArn,
            transactionId: transactionId
        )
        let output: EventLoopFuture<TransactionOutput> = try client.send(
            operation: "",
            path: "/RollbackTransaction",
            httpMethod: "POST",
            input: input
        )
        return output.map { _ in Void() }
    }

}


public struct CreateTransactionInput: AWSShape {
    
    public let database: String
    public let resourceArn: String
    public let schema: String?
    public let secretArn: String
    
    public static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "database", required: true, type: .string),
        AWSShapeMember(label: "resourceArn", required: true, type: .string),
        AWSShapeMember(label: "secretArn", required: true, type: .string),
        AWSShapeMember(label: "schema", required: false, type: .string)
    ]
}


public struct CreateTransactionOutput: AWSShape {
    
    public let transactionId: String
    
    public static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "transactionId", required: true, type: .string)
    ]
}

public struct TransactionOutput: AWSShape {
    
    public let transactionStatus: String
    
    public static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "transactionStatus", required: true, type: .string)
    ]
}

public struct TransactionInput: AWSShape {
    
    public let resourceArn: String
    public let secretArn: String
    public let transactionId: String
    
    public static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "resourceArn", required: true, type: .string),
        AWSShapeMember(label: "secretArn", required: true, type: .string),
        AWSShapeMember(label: "transactionId", required: true, type: .string)
    ]
}
