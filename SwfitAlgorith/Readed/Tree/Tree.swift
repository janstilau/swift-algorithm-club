/*
 这里, 定义的不是二叉树, 而是 tree. 所以, 这里是用数组进行的存储.
 因为, 里面要有相同元素的指向的问题, 这个类只能是类, 而不能使结构体.
 */
public class TreeNode<T> {
    public var value: T

    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()

    public init(value: T) {
        self.value = value
    }
    /*
     每次进行 childNode 的添加的时候, 都要进行 node.parent 的改动.
     */
    public func addChild(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self
    }
}

/*
 递归.
 */
extension TreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return s
    }
}

extension TreeNode where T: Equatable {
    public func search(_ value: T) -> TreeNode? {
        if value == self.value {
            return self
        }
        // BFS 的写法, 就是在循环的内部, 进行递归的调用.
        // 二叉树的三种方式, 无非就是 BFS 的二叉树的写法而已.
        for child in children {
            if let found = child.search(value) {
                return found
            }
        }
        return nil
    }
}

