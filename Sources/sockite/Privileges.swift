import SwiftChatSE

enum Privileges: Int {
    case owner = 2
    case admin = 1
    case nothing = 0
}

class PrivilegeManager {
    
    static func checkPrivilegeLevel(ofChatUser user: ChatUser) -> Privileges {
        if PrivilegeManager.getPrivilegeLevelOfUserFromDatabase(user) == .owner {
            return .owner
        } else if user.isMod || user.isRO || PrivilegeManager.getPrivilegeLevelOfUserFromDatabase(user) == .admin {
            return .admin
        }
        return .nothing
    }
    
    static func getPrivilegeLevelOfUserFromDatabase(_ user: ChatUser) -> Privileges {
        return .nothing
    }
    
}
