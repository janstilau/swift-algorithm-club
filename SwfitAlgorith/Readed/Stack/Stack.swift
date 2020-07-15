/*
 Last-in first-out stack (LIFO)
 Push and pop are O(1) operations.
 */

/*
 Stack 就是操作受限的线性表.
 这里, 是用数组实现的 Stack. 值得注意的是, 下面对于 Sequence 的实现. 利用了已有的类库.
 */
public struct Stack<T> {
  fileprivate var array = [T]()
  
  public var isEmpty: Bool {
    return array.isEmpty
  }
  
  public var count: Int {
    return array.count
  }
  
  public mutating func push(_ element: T) {
    array.append(element)
  }
  
    /*
     如果, 修改了自己的成员变量, 一定要用 mutating 进行修饰.
     */
  public mutating func pop() -> T? {
    return array.popLast()
  }
  
  public var top: T? {
    return array.last
  }
}

extension Stack: Sequence {
  public func makeIterator() -> AnyIterator<T> {
    var curr = self
    return AnyIterator {
      return curr.pop()
    }
  }
}
