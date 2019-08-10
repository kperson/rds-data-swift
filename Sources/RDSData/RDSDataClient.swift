//
//  RDSDataClient.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/5/19.
//

import AWSSDKSwiftCore
import NIO
import Foundation


public class RDSDataClient {
    
    public static let sleepErrorMessage = "Communications link failure\n\nThe last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server."
    
    public let client: AWSClient
    public let resourceArn: String
    public let database: String
    public let secretArn: String
    public let retryOnSleep: Bool
    
    public let errorEventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    
    public init(
        secretArn: String,
        resourceArn: String,
        database: String,
        retryOnSleep: Bool = false,
        accessKeyId: String? = nil,
        secretAccessKey: String? = nil,
        region: AWSSDKSwiftCore.Region? = nil,
        endpoint: String? = nil
    ) {
        self.client = AWSClient(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            region: region,
            amzTarget: nil,
            service: "rds-data",
            serviceProtocol: ServiceProtocol(type: .json, version: ServiceProtocol.Version(major: 1, minor: 0)),
            apiVersion: "",
            endpoint: endpoint,
            serviceEndpoints: [:],
            middlewares: [],
            possibleErrorTypes: []
        )
        self.resourceArn = resourceArn
        self.database = database
        self.secretArn = secretArn
        self.retryOnSleep = retryOnSleep
    }
    
    public func send<Output: AWSShape, Input: AWSShape>(
        path: String,
        input: Input,
        remainingAttempts: Int = 3,
        backOffTime: Int = 2000
    ) throws -> Future<Output> {
        let f: Future<Output> = try client.send(
            operation: "",
            path: path,
            httpMethod: "POST",
            input: input
        )
        return f.thenIfError { error in
            if
                let e = error as? AWSSDKSwiftCore.AWSError,
                e.message == RDSDataClient.sleepErrorMessage,
                self.retryOnSleep,
                remainingAttempts > 0
            {
                let delayed = self.errorEventLoopGroup.next().scheduleTask(in: TimeAmount.microseconds(backOffTime)) { () -> EventLoopFuture<Output> in
                     let f: Future<Output> = try self.send(
                        path: path,
                        input: input,
                        remainingAttempts: remainingAttempts - 1,
                        backOffTime: backOffTime * 2
                    )
                    return f
                }
                return delayed.futureResult.then { $0 }
            }
            else {
                return self.errorEventLoopGroup.next().newFailedFuture(error: error)
            }
        }
    }

}
