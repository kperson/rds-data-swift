//
//  ExecuteStatement.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/6/19.
//

import Foundation
import AWSSDKSwiftCore
import NIO


public extension RDSDataClient {
    
    func executeStatement(
        sql: String,
        params: [String : Field] = [:],
        transactionId: String? = nil,
        continueAfterTimeout: Bool = true,
        schema: String? = nil
    ) throws -> EventLoopFuture<ExecuteStatementOutput> {
        let input = ExecuteStatementInput(
            continueAfterTimeout: continueAfterTimeout,
            database: database,
            includeResultMetadata: true,
            parameters: params.toSqlParams,
            resourceArn: resourceArn,
            schema: schema,
            secretArn: secretArn,
            sql: sql,
            transactionId: transactionId
        )
        let output: EventLoopFuture<ExecuteStatementOutputRaw> = try send(
            path: "/Execute",
            input: input
        )
        return output.map { $0.clean }
    }
    
    func batchExecuteStatement(
        sql: String,
        paramsSet: [[String : Field]],
        transactionId: String? = nil,
        schema: String? = nil
    ) throws -> EventLoopFuture<BatchExecuteStatementOutput> {
        let input = BatchExecuteStatementInput(
            database: database,
            parameterSets: paramsSet.map { $0.toSqlParams },
            resourceArn: resourceArn,
            schema: schema,
            secretArn: secretArn,
            sql: sql,
            transactionId: transactionId
        )
        let output: EventLoopFuture<BatchExecuteStatementOutputRaw> = try send(
            path: "/BatchExecute",
            input: input
        )
        return output.map { $0.clean }
    }
}

public enum Field: Codable, Equatable {
    
    case blob(Data)
    case bool(Bool)
    case double(Double)
    case isNull(Bool)
    case long(Int64)
    case string(String)
    
    enum CodingKeys: String, CodingKey {
        case blobValue
        case booleanValue
        case doubleValue
        case isNull
        case longValue
        case stringValue
    }
    
    public var string: String? {
        switch self {
        case .string(let string): return string
        default: return nil
        }
    }
    
    public var blob: Data? {
        switch self {
        case .blob(let data): return data
        default: return nil
        }
    }
    
    public var double: Double? {
        switch self {
        case .double(let double): return double
        default: return nil
        }
    }
    
    public var isNull: Bool? {
        switch self {
        case .isNull(let isNull): return isNull
        default: return nil
        }
    }
    
    public var long: Int64? {
        switch self {
        case .long(let long): return long
        default: return nil
        }
    }
    
    public var bool: Bool? {
        switch self {
        case .bool(let bool): return bool
        default: return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let bool = try container.decodeIfPresent(Bool.self, forKey: .booleanValue) {
            self = .bool(bool)
        }
        else if let double = try container.decodeIfPresent(Double.self, forKey: .doubleValue) {
            self = .double(double)
        }
        else if let isNull = try container.decodeIfPresent(Bool.self, forKey: .isNull) {
            self = .isNull(isNull)
        }
        else if let long = try container.decodeIfPresent(Int64.self, forKey: .longValue) {
            self = .long(long)
        }
        else if let string = try container.decodeIfPresent(String.self, forKey: .stringValue) {
            self = .string(string)
        }
        else if let blob = try container.decodeIfPresent(String.self, forKey: .blobValue), let data = Data(base64Encoded: blob) {
            self = .blob(data)
        }
        else {
            throw AWSError(message: "unable to decoded sql SQL, unknown type", rawBody: "")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .blob(let data):
            try container.encode(data.base64EncodedString(), forKey: .blobValue)
        case .bool(let bool):
            try container.encode(bool, forKey: .booleanValue)
        case .double(let double):
            try container.encode(double, forKey: .doubleValue)
        case .isNull(let isNull):
            try container.encode(isNull, forKey: .isNull)
        case .long(let long):
            try container.encode(long, forKey: .longValue)
        case .string(let string):
            try container.encode(string, forKey: .stringValue)
        }
    }
    
}


public struct SqlParameter: Codable {

    public let name: String
    public let value: Field
    
}


public struct ExecuteStatementInput: AWSShape {
    
    public static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "continueAfterTimeout", required: true, type: .boolean),
        AWSShapeMember(label: "database", required: true, type: .string),
        AWSShapeMember(label: "includeResultMetadata", required: true, type: .boolean),
        AWSShapeMember(label: "parameters", required: true, type: .list),
        AWSShapeMember(label: "resourceArn", required: true, type: .string),
        AWSShapeMember(label: "secretArn", required: true, type: .string),
        AWSShapeMember(label: "schema", required: false, type: .string),
        AWSShapeMember(label: "sql", required: true, type: .string),
        AWSShapeMember(label: "transactionId", required: false, type: .string)
    ]
    
    public let continueAfterTimeout: Bool
    public let database: String
    public let includeResultMetadata: Bool
    public let parameters: [SqlParameter]
    public let resourceArn: String
    public let schema: String?
    public let secretArn: String
    public let sql: String
    public let transactionId: String?
    
}

public extension Dictionary where Key == String, Value == Field {
    
    var toSqlParams: [SqlParameter] {
        var arr:[SqlParameter] = []
        for (k, v) in self {
            arr.append(SqlParameter(name: k, value: v))
        }
        return arr
    }
    
}

struct ExecuteStatementOutputRaw: AWSShape {
    
    static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "columnMetadata", required: false, type: .list),
        AWSShapeMember(label: "generatedFields", required: false, type: .list),
        AWSShapeMember(label: "records", required: false, type: .list),
        AWSShapeMember(label: "numberOfRecordsUpdated", required: true, type: .long)
    ]
    
    let columnMetadata: [ColumnMetadata]?
    let generatedFields: [Field]?
    let records: [[Field]]?
    let numberOfRecordsUpdated: Int64?
    
    var clean: ExecuteStatementOutput {
        return ExecuteStatementOutput(
            columnMetadata: columnMetadata ?? [],
            generatedFields: generatedFields ?? [],
            records: records ?? [],
            numberOfRecordsUpdated: numberOfRecordsUpdated ?? 0
        )
    }

}

public struct Row {
    
    let records: [Field]
    let names: [String : Int]
    
    public subscript(string: String) -> Field? {
        if let int = names[string.lowercased()] {
            let field = records[int]
            return field
        }
        else {
            return nil
        }
    }
    
//    public subscript(int: Int) -> Field? {
//        return records[int]
//    }
    
}

public struct ExecuteStatementOutput: Sequence, IteratorProtocol {
    
    public typealias Element = Row
    
    public let columnMetadata: [ColumnMetadata]
    public let generatedFields: [Field]
    public let records: [[Field]]
    public let numberOfRecordsUpdated: Int64
    
    var index: Int = 0
    
    let names: [String : Int]
    
    public init(
        columnMetadata: [ColumnMetadata],
        generatedFields: [Field],
        records: [[Field]],
        numberOfRecordsUpdated: Int64
    ) {
        self.columnMetadata = columnMetadata
        self.generatedFields = generatedFields
        self.records = records
        self.numberOfRecordsUpdated = numberOfRecordsUpdated
        var nameDict: [String : Int] = [:]
        var i = 0
        for n in columnMetadata {
            if let name = n.name?.lowercased() {
                nameDict[name] = i
            }
            i = i + 1
        }
        self.names = nameDict
    }
    
    public mutating func next() -> Row? {
        if index < records.count {
            index = index + 1
            return Row(records: records[index - 1], names: names)
        }
        else {
            return nil
        }
        
    }
    
}



public struct ColumnMetadata: Codable {
    
    public let arrayBaseColumnType: Int?
    public let isAutoIncrement: Bool?
    public let isCaseSensitive: Bool?
    public let isCurrency: Bool?
    public let isSigned: Bool?
    public let label: String?
    public let name: String?
    public let nullable: Bool?
    public let precision: Int?
    public let scale: Int?
    public let schemaName: String?
    public let tableName: String?
    public let type: Int?
    public let typeName: String?
    
    
}


public struct BatchExecuteStatementInput: AWSShape {
    
    public static var _members: [AWSShapeMember] = [
        AWSShapeMember(label: "database", required: true, type: .string),
        AWSShapeMember(label: "parameterSets", required: true, type: .list),
        AWSShapeMember(label: "resourceArn", required: true, type: .string),
        AWSShapeMember(label: "schema", required: false, type: .string),
        AWSShapeMember(label: "secretArn", required: true, type: .string),
        AWSShapeMember(label: "sql", required: true, type: .string),
        AWSShapeMember(label: "transactionId", required: false, type: .string)
    ]
    
    public let database: String
    public let parameterSets: [[SqlParameter]]
    public let resourceArn: String
    public let schema: String?
    public let secretArn: String
    public let sql: String
    public let transactionId: String?
    
}

public struct GeneratedFields: Codable {
    
    public let generatedFields: [Field]
    
}

struct GeneratedFieldsRaw: Codable {
    
    let generatedFields: [Field]?
    
}

struct BatchExecuteStatementOutputRaw: AWSShape {
    
    static var _members: [AWSShapeMember] = []
    
    let updateResults: [GeneratedFieldsRaw]?
    
    var clean: BatchExecuteStatementOutput {
        let rs = updateResults ?? []
        let fields = rs.map { GeneratedFields(generatedFields: $0.generatedFields ?? []) }
        return BatchExecuteStatementOutput(updateResults: fields)
    }
    
}

public struct BatchExecuteStatementOutput: AWSShape {
    
    public let updateResults: [GeneratedFields]
    
}
