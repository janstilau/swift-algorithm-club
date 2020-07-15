/*
  First-in first-out queue (FIFO)

  New elements are added to the end of the queue. Dequeuing pulls elements from
  the front of the queue.

  Enqueuing and dequeuing are O(1) operations.
*/
public struct Queue<T> {
    /*
     对于, 不需要暴露出去的实现, 应该用范围控制符进行控制.
     */
  fileprivate var array = [T?]()
  fileprivate var head = 0

  public var isEmpty: Bool {
    return count == 0
  }

  public var count: Int {
    return array.count - head
  }

  public mutating func enqueue(_ element: T) {
    array.append(element)
  }

  public mutating func dequeue() -> T? {
    guard let element = array[guarded: head] else { return nil }

    array[head] = nil
    head += 1

    /*
     Removes the specified number of elements from the beginning of the collection.
     这个 API 在之前的 OC 版本 Array 中没有遇到过.
     O(n)的复杂度, 所以还是一个个的删的.
     这里, 就是一个缩容的处理过程.
     */
    
    // 想要得到 Double 的数据, 就要进行 Double 的转换工作. 这种转换, 有时显得特别繁琐.
    let percentage = Double(head)/Double(array.count)
    if array.count > 50 && percentage > 0.25 {
      array.removeFirst(head)
      head = 0
    }
    return element
  }

  public var front: T? {
    if isEmpty {
      return nil
    } else {
      return array[head]
    }
  }
}

extension Array {
    subscript(guarded idx: Int) -> Element? {
        /*
         (startIndex..<endIndex) 这种写法, 如果 startIndex < endIndex, 会崩.
         这样可以帮助程序员, 提早的发现逻辑的问题.
         */
        guard (startIndex..<endIndex).contains(idx) else {
            return nil
        }
        return self[idx]
    }
}
