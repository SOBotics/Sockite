public struct Queue<T>: ExpressibleByArrayLiteral {
    public private(set) var elements: Array<T> = []
    public mutating func push(value: T) { elements.append(value) }
    public mutating func pop() -> T { return elements.removeFirst() }
    public var isEmpty: Bool { return elements.isEmpty }
    public var count: Int { return elements.count }
    public init(arrayLiteral elements: T...) { self.elements = elements }
}
