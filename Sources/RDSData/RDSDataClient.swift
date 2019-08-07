//
//  RDSDataClient.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/5/19.
//

import AWSSDKSwiftCore


public class RDSDataClient {
    
    let client: AWSClient
    let resourceArn: String
    let database: String
    let secretArn: String
    
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
