import RDSData

let client = RDSDataClient(
    secretArn: "SECRET_ARN",
    resourceArn: "RESOURCE_ARN",
    database: "DB"
)

let firstNamesFut = client.autoCommit { tx in
    tx.executeStatement(
        sql: "SELECT first_name FROM person WHERE last_name = :last_name",
        params: ["last_name" : .string("Smith")]
    ).map { results in
        results.compactMap { $0["first_name"]?.string }
    }
}

firstNamesFut.whenSuccess { names in
    print(names)
}
