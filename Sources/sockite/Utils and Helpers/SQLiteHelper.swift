import SQLite

class SQLiteHelper {
    
    private var db: Connection? = nil
    
    private let tumbleweedBadge = Table("tumbleweedBadge")
    private let userId = Expression<String>("userId")
    
    func connect() {
        do {
            db = try Connection(creds.sqlite_file_path)
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
            Log.handle(error: "Error while creating table \"tumbleweedBadge\": \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
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
    
    func insertChecked(user: User) {
        if db == nil {
            Log.logWarning("Database not connected, now attempting to connect")
            self.connect()
        }
        do {
            try db!.run(tumbleweedBadge.insert(userId <- String(user.user_id!)))
        } catch {
            Log.handle(error: "Error while inserting checked user into database: \(error.localizedDescription)", consoleOutputPrefix: "SQLite")
        }
    }
    
    func disconnect() {
        db = nil
    }
}
