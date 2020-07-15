/// Performs the Insertion sort algorithm to a given array
///
/// - Parameters:
///   - array: the array of elements to be sorted
///   - isOrderedBefore: returns true if the elements provided are in the corect order
/// - Returns: a sorted array containing the same elements
func insertionSort<T>(_ array: [T], _ isOrderedBefore: (T, T) -> Bool) -> [T] {
  guard array.count > 1 else { return array }

  var a = array
  for x in 1..<a.count {
    var y = x
    let temp = a[y]
    while y > 0 && isOrderedBefore(temp, a[y - 1]) {
      a[y] = a[y - 1]
      y -= 1
    }
    a[y] = temp
  }
  return a
}

/// Performs the Insertion sort algorithm to a given array
///
/// - Parameter array: the array to be sorted, containing elements that conform to the Comparable protocol
/// - Returns: a sorted array containing the same elements

/*
 T 根据了 Comparable 进行了约束, 这样泛型算法里面, 写 比较 操作符, 可以保证在编译期间就能发现错误.
 这个插入排序的实现, 有点问题, 是冒泡排序的实现.
 */
func insertionSort<T: Comparable>(_ array: [T]) -> [T] {
    guard array.count > 1 else { return array }

    var a = array
    for x in 1..<a.count {
        var y = x
        let temp = a[y]
        while y > 0 && temp < a[y - 1] {
            a[y] = a[y - 1]
            y -= 1
        }
        a[y] = temp
    }
    return a
}

/*
 更加常见的插入算法的实现方式.
 */

func insertSort<T: Comparable>(_ array: [T]) -> [T] {
    guard array.count > 1 else { return array }
    
    var result = array
    for idx in 1..<array.count {
        var insertIdx = idx
        let value = result[idx]
        for i in 0...idx {
            if result[i] > value {
                insertIdx = i
                break
            }
        }
        if insertIdx != idx {
            for i in (insertIdx+1...idx).reversed() {
                result[i] = result[i-1]
            }
        }
        result[insertIdx] = value
    }
    return result
}
