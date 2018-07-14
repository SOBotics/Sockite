import SQLite

class SQLiteHelper {
    
    private var db: Connection? = nil
    
    private let tumbleweedBadge = Table("tumbleweedBadge")
    private let userId = Expression<String>("userId")
    
    private let privileges = Table("privileges")
    private let privilege = Expression<Int>("privilege")
    
    func connect() {
        do {
            db = try Connection(dataDir + "db.sqlite3")
            db?.trace { Log.logInfo($0, consoleOutputPrefix: "SQLite") }
        } catch {
            Log.handle(error: "Error while connecting to db: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
            return
        }
        do {
            try db!.run(tumbleweedBadge.create(ifNotExists: true) { t in
                t.column(userId)
            })
            
            try db!.run(privileges.create(ifNotExists: true) { t in
                t.column(userId)
                t.column(privilege)
            })
        } catch {
            Log.logWarning("Error occured while initializing database connection: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
        }
    }
    
    func searchIfUserChecked(_ user: User) -> Bool {
        if db == nil {
            Log.logWarning("Database not connected, now attempting to connect")
            self.connect()
        }
        do {
            for dbUser in try db!.prepare(tumbleweedBadge) {
                if String(user.user_id!) == dbUser[userId] {
                    return true
                }
            }
        } catch {
            Log.handle(error: "Error while searching if user was checked before: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
        }
        return false
    }
    
    func insertChecked(userId uid: String) {
        if db == nil {
            Log.logWarning("Database not connected, now attempting to connect")
            self.connect()
        }
        do {
            Log.logInfo("Inserting user id into scanned database", consoleOutputPrefix: "SQLite")
            try db!.run(tumbleweedBadge.insert(userId <- uid))
            Log.logInfo("User id inserted into scanned database", consoleOutputPrefix: "SQLite")
        } catch {
            Log.handle(error: "Error while inserting checked user into database: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
        }
    }
    
    func give(user: String, privilege userPriv: Privileges) {
        if db == nil {
            Log.logWarning("Database not connected, now attempting to connect")
            self.connect()
        }
        do {
            for row in try db!.prepare(privileges) {
                if row[userId] == user {
                    let toBeGiven = privileges.filter(userId == user)
                    try db!.run(toBeGiven.update(privilege <- userPriv.rawValue))
                    return
                }
            }
            try db!.run(privileges.insert(userId <- user, privilege <- userPriv.rawValue))
        } catch {
            Log.handle(error: "Error while giving user privileges: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
        }
    }
    
    func getPrivilegeLevel(ofUser user: String) -> Privileges {
        if db == nil {
            Log.logWarning("Database not connected, now attempting to connect")
            self.connect()
        }
        do {
            for row in try db!.prepare(privileges) {
                if row[userId] == user {
                    return Privileges(rawValue: row[privilege])!
                }
            }
        } catch {
            Log.handle(error: "Error while getting user privileges: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
        }
        return .nothing
    }
    
    func disconnect() {
        db = nil
    }
}
