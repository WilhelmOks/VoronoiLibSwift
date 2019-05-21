//
//  RBTree.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class RBTreeNode<T> {
    fileprivate(set) var data: T
    fileprivate(set) var left: RBTreeNode<T>?
    fileprivate(set) var right: RBTreeNode<T>?
    fileprivate(set) var parent: RBTreeNode<T>?
    
    //cached ordered traversal
    fileprivate(set) var previous: RBTreeNode<T>?
    fileprivate(set) var next: RBTreeNode<T>?
    
    var red = false
    
    fileprivate init(data: T) {
        self.data = data
        
        left = nil
        right = nil
        parent = nil
        previous = nil
        next = nil
    }
}

final class RBTree<T> {
    private(set) var root: RBTreeNode<T>?
    
    public func insertSuccessor(successorNode: RBTreeNode<T>?, successorData: T) -> RBTreeNode<T> {
        var node: RBTreeNode<T>? = successorNode
        
        let successor = RBTreeNode<T>(data: successorData)
    
        var parent: RBTreeNode<T>?
        
        if node != nil {
            //insert new node between node and its successor
            successor.previous = node
            successor.next = node!.next
            if node!.next != nil {
                node!.next?.previous = successor
            }
            node!.next = successor
            
            //insert successor into the tree
            if node!.right != nil {
                node = type(of: self).getFirst(node?.right)
                node?.left = successor
            } else {
                node?.right = successor
            }
            parent = node
        } else if root != nil {
            //if the node is nil, successor must be inserted
            //into the left most part of the tree
            node = type(of: self).getFirst(root)
            //successor.Previous = nil
            successor.next = node
            node?.previous = successor
            node?.left = successor
            parent = node
        } else {
            //first insert
            //successor.Previous = successor.Next = nil
            root = successor
            parent = nil
        }
        
        //successor.Left = successor.Right = nil
        successor.parent = parent
        successor.red = true
        
        //the magic of the red black tree
        var grandma: RBTreeNode<T>?
        var aunt: RBTreeNode<T>?
        node = successor
        while parent != nil && parent!.red {
            grandma = parent!.parent
            if parent === grandma?.left {
                aunt = grandma?.right
                if aunt != nil && aunt!.red {
                    parent!.red = false
                    aunt!.red = false
                    grandma?.red = true
                    node = grandma
                } else {
                    if node === parent!.right {
                        rotateLeft(parent)
                        node = parent
                        parent = node?.parent
                    }
                    parent?.red = false
                    grandma?.red = true
                    rotateRight(grandma)
                }
            } else {
                aunt = grandma?.left
                if aunt != nil && aunt!.red {
                    parent!.red = false
                    aunt!.red = false
                    grandma?.red = true
                    node = grandma
                } else {
                    if node === parent!.left {
                        rotateRight(parent)
                        node = parent
                        parent = node?.parent
                    }
                    parent?.red = false
                    grandma?.red = true
                    rotateLeft(grandma)
                }
            }
            parent = node?.parent
        }
        root?.red = false
        return successor
    }
    
    //TODO: Clean this up
    public func removeNode(_ nodeToRemove: RBTreeNode<T>?) {
        var node = nodeToRemove
        
        //fix up linked list structure
        if node?.next != nil {
            node?.next?.previous = node?.previous
        }
        if node?.previous != nil {
            node?.previous?.next = node?.next
        }
        
        //replace the node
        //var original = node
        var parent = node?.parent
        let left = node?.left
        let right = node?.right
        
        var next: RBTreeNode<T>?
        //figure out what to replace this node with
        if left == nil {
            next = right
        } else if right == nil {
            next = left
        } else {
            next = type(of: self).getFirst(right)
        }
        
        //fix up the parent relation
        if parent != nil {
            if parent!.left === node {
                parent!.left = next
            } else {
                parent!.right = next
            }
        } else {
            root = next
        }
        
        var red: Bool
        if left != nil && right != nil {
            red = next?.red ?? false
            next?.red = node?.red ?? false
            next?.left = left
            left?.parent = next
            
            // if we reached down the tree
            if next !== right {
                parent = next?.parent
                next?.parent = node?.parent
                
                node = next?.right
                parent?.left = node
                
                next?.right = right
                right?.parent = next
            } else {
                // the direct right will replace the node
                next?.parent = parent
                parent = next
                node = next?.right
            }
        } else {
            red = node?.red ?? false
            node = next
        }
        
        if node != nil {
            node!.parent = parent
        }
        
        if red {
            return
        }
        
        if node != nil && node!.red {
            node!.red = false
            return
        }
    
        //node is nil or black
        
        // fair warning this code gets nasty
        
        //how do we guarantee sibling is not nil
        var sibling: RBTreeNode<T>? = nil
        repeat {
            if node === root {
                break
            }
            if node === parent?.left {
                sibling = parent?.right
                if sibling?.red ?? false {
                    sibling?.red = false
                    parent?.red = true
                    rotateLeft(parent)
                    sibling = parent?.right
                }
                if (sibling?.left != nil && sibling?.left?.red ?? false) || (sibling?.right != nil && sibling?.right?.red ?? false) {
                    //pretty sure this can be sibling.Left != nil && sibling.Left.Red
                    if sibling?.right == nil || !(sibling?.right?.red ?? false) {
                        sibling?.left?.red = false
                        sibling?.red = true
                        rotateRight(sibling)
                        sibling = parent?.right
                    }
                    sibling?.red = parent?.red ?? false
                    parent?.red = false
                    sibling?.right?.red = false
                    rotateLeft(parent)
                    node = root
                    break
                }
            } else {
                sibling = parent?.left
                if sibling?.red ?? false {
                    sibling?.red = false
                    parent?.red = true
                    rotateRight(parent)
                    sibling = parent?.left
                }
                if (sibling?.left != nil && sibling?.left?.red ?? false) || (sibling?.right != nil && sibling?.right?.red ?? false) {
                    if sibling?.left == nil || !(sibling?.left?.red ?? false) {
                        sibling?.right?.red = false
                        sibling?.red = true
                        rotateLeft(sibling)
                        sibling = parent?.left
                    }
                    sibling?.red = parent?.red ?? false
                    parent?.red = false
                    sibling?.left?.red = false
                    rotateRight(parent)
                    node = root
                    break
                }
            }
            sibling?.red = true
            node = parent
            parent = parent?.parent
        } while !(node?.red ?? false)
        
        if node != nil {
            node?.red = false
        }
    }
    
    public static func getFirst(_ node: RBTreeNode<T>?) -> RBTreeNode<T>? {
        var result: RBTreeNode<T>? = node
        while (result?.left != nil) {
            result = result?.left
        }
        return result
    }
    
    public static func getLast(_ node: RBTreeNode<T>?) -> RBTreeNode<T>? {
        var result: RBTreeNode<T>? = node
        while result?.right != nil {
            result = result?.right
        }
        return result
    }
    
    private func rotateLeft(_ node: RBTreeNode<T>?) {
        let p = node
        let q = node?.right
        let parent = p?.parent
        
        if parent != nil {
            if parent!.left === p {
                parent!.left = q
            } else {
                parent!.right = q
            }
        } else {
            root = q
        }
        q?.parent = parent
        p?.parent = q
        p?.right = q?.left
        if p?.right != nil {
            p?.right?.parent = p
        }
        q?.left = p
    }
    
    private func rotateRight(_ node: RBTreeNode<T>?) {
        let p = node
        let q = node?.left
        let parent = p?.parent
        if parent != nil {
            if parent!.left === p {
                parent!.left = q
            } else {
                parent!.right = q
            }
        } else {
            root = q
        }
        q?.parent = parent
        p?.parent = q
        p?.left = q?.right
        if p?.left != nil {
            p?.left?.parent = p
        }
        q?.right = p
    }
}
