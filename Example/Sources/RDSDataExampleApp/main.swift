import RDSData

let client = RDSDataClient(
    secretArn: "arn:aws:secretsmanager:us-east-1:193125195061:secret:/db/data_api/kelton_test-oansumgril-MTS2M3",
    resourceArn: "arn:aws:rds:us-east-1:193125195061:cluster:tf-20190809173315221100000001",
    database: "kelton_test"
)


let create = client.autoCommit { tx in
    tx.executeStatement(
        sql: """
        CREATE TABLE IF NOT EXISTS person (
            id INT NOT NULL AUTO_INCREMENT,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            age INT NOT NULL,
            PRIMARY KEY (id)
        )
        """,
        continueAfterTimeout: true
    ).map { _ in
        tx.batchExecuteStatement(
            sql:  "INSERT person (first_name, last_name, age) VALUES (:firsName, :lastName, :age)",
            paramsSet: [
                [
                    "firstName": .string("Bob"),
                    "lastName": .string("Smith"),
                    "age": .long(30)
                ],
                [
                    "firstName": .string("Susan"),
                    "lastName": .string("Smith"),
                    "age": .long(31)
                ]
            ]
        )
    }
}

try create.wait()
