import SwiftChatSE

enum Privileges: Int {
    case owner = 2
    case admin = 1
    case nothing = 0
}

class PrivilegeManager {
    
    static func checkPrivilegeLevel(ofChatUser user: ChatUser) -> Privileges {
        if sqliteHelper.getPrivilegeLevel(ofUser: String(user.id)) == .owner {
            return .owner
        } else if user.isMod || user.isRO || sqliteHelper.getPrivilegeLevel(ofUser: String(user.id)) == .admin {
            return .admin
        }
        return .nothing
    }
    
    static func assertPrivilegeLevel(ofChatUser user: ChatUser, isHigherThan privilege: Privileges) -> Bool {
        if user.isMod || user.isRO {
            if Privileges.admin.rawValue < privilege.rawValue {
                return false
            }
            return true
        }
        if PrivilegeManager.checkPrivilegeLevel(ofChatUser: user).rawValue >= privilege.rawValue {
            return true
        }
        return false
    }
    
}
