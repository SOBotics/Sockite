func broadcastMessage(_ msg: String) {
    for room in rooms {
        room.postMessage(msg)
    }
}
