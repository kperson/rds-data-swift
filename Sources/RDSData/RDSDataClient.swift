//
//  RDSDataClient.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/5/19.
//

import AWSSDKSwiftCore
import NIO


public class RDSDataClient {
    
    public let client: AWSClient
    public let resourceArn: String
    public let database: String
    public let secretArn: String
    
    public let errorEventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    public init(
        secretArn: String,
        resourceArn: String,
        database: String,
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
    }

}
