/*
  A binary search tree.

  Each node stores a value and two children. The left child contains a smaller
  value; the right a larger (or equal) value.

  This tree allows duplicate elements.

  This tree does not automatically balance itself. To make sure it is balanced,
  you should insert new values in randomized order, not in sorted order.
*/
/*
 在 Swift 的泛型支持下, 任何可以定义为泛型的数据, 都应该用泛型定义.
 */
public class BinarySearchTree<T: Comparable> {
  fileprivate(set) public var value: T
    /*
     在实际的使用的时候, 记录 parent 节点, 要好的多.
     这个名称, 就叫做 parent, 不要在叫什么 super, father 这种丑陋的名称.
     */
  fileprivate(set) public var parent: BinarySearchTree?
  fileprivate(set) public var left: BinarySearchTree?
  fileprivate(set) public var right: BinarySearchTree?

  public init(value: T) {
    self.value = value
  }
    /*
     public struct DropFirstSequence<Base: Sequence> {
       @usableFromInline
       internal let _base: Base
       @usableFromInline
       internal let _limit: Int
       
       @inlinable
       public init(_ base: Base, dropping limit: Int) {
         _precondition(limit >= 0,
           "Can't drop a negative number of elements from a sequence")
         _base = base
         _limit = limit
       }
     
        这里, 这种延时消耗的序列, 会在产生迭代器的时候, 利用 base 生成迭代器, 然后消耗相应的次数之后, 返回迭代器, 这个时候, 迭代器表现的就是丢失了前几个数据的迭代器了.
        public __consuming func makeIterator() -> Iterator {
          var it = _base.makeIterator()
          var dropped = 0
          while dropped < _limit, it.next() != nil { dropped &+= 1 }
          return it
        }
        Drop 之后, 自身还是可以进行 drop. 返回一个新的延时序列, 延时的进行了累加.
         public __consuming func dropFirst(_ k: Int) -> DropFirstSequence<Base> {
           // If this is already a _DropFirstSequence, we need to fold in
           // the current drop count and drop limit so no data is lost.
           //
           // i.e. [1,2,3,4].dropFirst(1).dropFirst(1) should be equivalent to
           // [1,2,3,4].dropFirst(2).
           return DropFirstSequence(_base, dropping: _limit + k)
         }
     }
     
     /// - Complexity: O(1), with O(*k*) deferred to each iteration of the result,
     ///   where *k* is the number of elements to drop from the beginning of
     ///   the sequence.
     public __consuming func dropFirst(_ k: Int = 1) -> DropFirstSequence<Self> {
       return DropFirstSequence(self, dropping: k)
     }
     */
  public convenience init(array: [T]) {
    precondition(array.count > 0)
    self.init(value: array.first!)
    /*
     这个函数, 会立马返回一个数据结构, 然后将 iterate 的过程, 封装到该数据结构的内部.
     通过利用以后方法构建数据, 让方法统一在一点.
     */
    for v in array.dropFirst() {
      insert(value: v)
    }
  }

    /*
     通过, parent 节点的保存, 以下的操作, 都可以用节点自己进行判断就可以.
     代价就是, 要合适的更新 parent 的节点的指向.
     */
  public var isRoot: Bool {
    return parent == nil
  }

  public var isLeaf: Bool {
    return left == nil && right == nil
  }

  public var isLeftChild: Bool {
    return parent?.left === self
  }

  public var isRightChild: Bool {
    return parent?.right === self
  }

  public var hasLeftChild: Bool {
    return left != nil
  }

  public var hasRightChild: Bool {
    return right != nil
  }

  public var hasAnyChild: Bool {
    return hasLeftChild || hasRightChild
  }

  public var hasBothChildren: Bool {
    return hasLeftChild && hasRightChild
  }

  /* How many nodes are in this subtree. Performance: O(n). */
    /*
     递归实现, 以上的所有属性, 都是计算属性.
     */
  public var count: Int {
    return (left?.count ?? 0) + 1 + (right?.count ?? 0)
  }
}

// MARK: - Adding items

extension BinarySearchTree {
  /*
    Inserts a new element into the tree. You should only insert elements
    at the root, to make to sure this remains a valid binary tree!
    Performance: runs in O(h) time, where h is the height of the tree.
  */
  public func insert(value: T) {

    if value < self.value {
        /*
         通过面向对象的方式, 判断插入到左子树后. 是左子树的左节点, 还是右节点, 稍后由 left.insert 进行处理. 解放了逻辑复杂度.
         */
      if let left = left {
        /*
         左子树的插入, 左子树当过 root 来进行插入.
         */
        left.insert(value: value)
      } else {
        /*
         没有左子树, 生成一个左子树, 设置左子树的 parent 的指向.
         */
        left = BinarySearchTree(value: value)
        left?.parent = self
      }
    } else {
        /*
         如果, insert 值和 当前节点相等, 也会被插入到右节点.
         这个节点, 会是右子树的最左边的数据.
         所以, 在 remove 和 search 的时候, 都要处理下这个问题
         */
      if let right = right {
        right.insert(value: value)
      } else {
        right = BinarySearchTree(value: value)
        right?.parent = self
      }
    }
  }
}

// MARK: - Deleting items

extension BinarySearchTree {
  /*
    Deletes a node from the tree.

    Returns the node that has replaced this removed one (or nil if this was a
    leaf node). That is primarily useful for when you delete the root node, in
    which case the tree gets a new root.

    Performance: runs in O(h) time, where h is the height of the tree.
  */
  @discardableResult public func remove() -> BinarySearchTree? {
    let replacement: BinarySearchTree?

    // Replacement for current node can be either biggest one on the left or
    // smallest one on the right, whichever is not nil
    if let right = right {
      replacement = right.minimum()
    } else if let left = left {
      replacement = left.maximum()
    } else {
      replacement = nil
    }

    replacement?.remove()

    // Place the replacement on current node's position
    replacement?.right = right
    replacement?.left = left
    right?.parent = replacement
    left?.parent = replacement
    reconnectParentTo(node:replacement)

    // The current node is no longer part of the tree, so clean it up.
    parent = nil
    left = nil
    right = nil

    return replacement
  }

  private func reconnectParentTo(node: BinarySearchTree?) {
    if let parent = parent {
      if isLeftChild {
        parent.left = node
      } else {
        parent.right = node
      }
    }
    node?.parent = parent
  }
}

// MARK: - Searching

extension BinarySearchTree {
  /*
    Finds the "highest" node with the specified value.
    Performance: runs in O(h) time, where h is the height of the tree.
  */
  public func search(value: T) -> BinarySearchTree? {
    var node: BinarySearchTree? = self
    /*
     更加优雅的, 判断 node 是不是空的方式.
     这里查找的出来的是最上层的数据.
     */
    while let n = node {
      if value < n.value {
        node = n.left
      } else if value > n.value {
        node = n.right
      } else {
        return node
      }
    }
    return nil
  }

  /*
  // Recursive version of search
     这种才可以尾吊优化
  public func search(value: T) -> BinarySearchTree? {
    if value < self.value {
      return left?.search(value)
    } else if value > self.value {
      return right?.search(value)
    } else {
      return self  // found it!
    }
  }
  */

  public func contains(value: T) -> Bool {
    return search(value: value) != nil
  }

  /*
    Returns the leftmost descendent. O(h) time.
     一路往左.
  */
  public func minimum() -> BinarySearchTree {
    var node = self
    while let next = node.left {
      node = next
    }
    return node
  }

  /*
    Returns the rightmost descendent. O(h) time.
     一路往右.
  */
  public func maximum() -> BinarySearchTree {
    var node = self
    while let next = node.right {
      node = next
    }
    return node
  }

  /*
    Calculates the depth of this node, i.e. the distance to the root.
    Takes O(h) time.
     有了 parent 节点, 计算深度的问题, 简单了很多.
  */
  public func depth() -> Int {
    var node = self
    var edges = 0
    while let parent = node.parent {
      node = parent
      edges += 1
    }
    return edges
  }

  /*
    Calculates the height of this node, i.e. the distance to the lowest leaf.
    Since this looks at all children of this node, performance is O(n).
     递归查找, 这种应该算成, 先统计自己的数据, 然后调用小范围的函数, 最后合并数据. 这种是不能尾吊优化的.
  */
  public func height() -> Int {
    if isLeaf {
      return 0
    } else {
      return 1 + max(left?.height() ?? 0, right?.height() ?? 0)
    }
  }

  /*
    Finds the node whose value precedes our value in sorted order.
  */
  public func predecessor() -> BinarySearchTree? {
    /*
     如果有左子树, 就是左子树的最大值.
     */
    if let left = left {
      return left.maximum()
    } else {
      var node = self
      while let parent = node.parent {
        if parent.value < value { return parent }
        node = parent
      }
      return nil
    }
  }

  /*
    Finds the node whose value succeeds our value in sorted order.
  */
  public func successor() -> BinarySearchTree? {
    if let right = right {
      return right.minimum()
    } else {
      var node = self
      while let parent = node.parent {
        if parent.value > value { return parent }
        node = parent
      }
      return nil
    }
  }
}

// MARK: - Traversal

/*
 函数式编程. 将函数, 当做参数进行传入.
 */
extension BinarySearchTree {
  public func traverseInOrder(process: (T) -> Void) {
    left?.traverseInOrder(process: process)
    process(value)
    right?.traverseInOrder(process: process)
  }

  public func traversePreOrder(process: (T) -> Void) {
    process(value)
    left?.traversePreOrder(process: process)
    right?.traversePreOrder(process: process)
  }

  public func traversePostOrder(process: (T) -> Void) {
    left?.traversePostOrder(process: process)
    right?.traversePostOrder(process: process)
    process(value)
  }

  /*
    Performs an in-order traversal and collects the results in an array.
     这里面, 有着大量的数组的合并工作存在.
  */
  public func map(formula: (T) -> T) -> [T] {
    var a = [T]()
    if let left = left { a += left.map(formula: formula) }
    a.append(formula(value))
    if let right = right { a += right.map(formula: formula) }
    return a
  }
}

/*
  Is this binary tree a valid binary search tree?
*/
extension BinarySearchTree {
  public func isBST(minValue: T, maxValue: T) -> Bool {
    if value < minValue || value > maxValue { return false }
    let leftBST = left?.isBST(minValue: minValue, maxValue: value) ?? true
    let rightBST = right?.isBST(minValue: value, maxValue: maxValue) ?? true
    return leftBST && rightBST
  }
}

// MARK: - Debugging

extension BinarySearchTree: CustomStringConvertible {
  public var description: String {
    var s = ""
    if let left = left {
      s += "(\(left.description)) <- "
    }
    s += "\(value)"
    if let right = right {
      s += " -> (\(right.description))"
    }
    return s
  }

   public func toArray() -> [T] {
      return map { $0 }
   }

}

//extension BinarySearchTree: CustomDebugStringConvertible {
//  public var debugDescription: String {
//   var s = ""
//   if let left = left {
//      s += "(\(left.description)) <- "
//   }
//   s += "\(value)"
//   if let right = right {
//      s += " -> (\(right.description))"
//   }
//   return s
//  }
//}
