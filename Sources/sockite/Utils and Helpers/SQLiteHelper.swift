import SQLite

class SQLiteHelper {
    
    private var db: Connection? = nil
    
    private let tumbleweedBadge = Table("tumbleweedBadge")
    private let userId = Expression<String>("userId")
    
    func connect() {
        do {
            db = try Connection(dataDir + "db.sqlite3")
            db?.trace { Log.logInfo($0, consoleOutputPrefix: "SQLite") }
        } catch {
            Log.handle(error: "Error while connecting to db: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
            return
        }
        do {
            try db!.run(tumbleweedBadge.create { t in
                t.column(userId)
            })
        } catch {
            Log.logWarning("Unable to create table, possibly because table already exists", consoleOutputPrefix: "SQLite")
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
    
    func disconnect() {
        db = nil
    }
}
