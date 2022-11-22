/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation
import XCEArrayExt

//---

/// Array-like (and Array-based) data container that allows to store list of elements
/// with built-in selection tracking.
public
struct Selectable<Element>
{
    // MARK: - Private members

    fileprivate
    let onCheckEquality: (Element, Element) -> Bool
    
    fileprivate
    var selection: Set<Int> = [] // indexes in 'elements'
    
    // MARK: - Initializers
    
    public
    init(
        _ initialValues: [Element] = [],
        multiSelection: Bool = false,
        onCheckEquality: @escaping (Element, Element) -> Bool
        )
    {
        self.allowMultipleSelection = multiSelection
        self.onCheckEquality = onCheckEquality
        
        self.elements = initialValues
    }

    // MARK: - Public members

    public
    var elements: [Element] = []
    {
        didSet
        {
            // ensure that selection always contains valid indexes only
            
            let oldSelectedElements = selection.map{ oldValue[$0] }
            
            let newSelectedIndexes = oldSelectedElements.compactMap{
                
                oldElement in
                
                //---
                
                elements.firstIndex{
                    
                    newElement in
                    
                    //---
                    
                    onCheckEquality(newElement, oldElement)
                }
            }
            
            selection = Set(newSelectedIndexes)
        }
    }
    
    public
    subscript(elementIndex: Int) -> Element?
    {
        get
        {
            return elements.xce.isValidIndex(elementIndex) ?
                elements[elementIndex] : nil
        }
    }
    
    public
    let allowMultipleSelection: Bool
}

// MARK: - Special initializer for Equatable elements

public
extension Selectable where Element: Equatable
{
    init(
        _ initialValues: [Element] = [],
        multiSelection: Bool = false
        )
    {
        self.init(
            initialValues,
            multiSelection: multiSelection,
            onCheckEquality: ==
        )
    }
}

// MARK: - Selection management

public
extension Selectable
{
    var selectedIndexes: [Int]
    {
        return Array(selection)
    }
    
    var selectedElements: [Element]
    {
        return selectedIndexes.map{ elements[$0] }
    }
    
    var selectedElement: Element?
    {
        if
            allowMultipleSelection
        {
            return nil
        }
        else
        {
            return selectedElements.first
        }
    }
    
    @discardableResult
    mutating
    func select(_ element: Element) throws -> Self
    {
        guard
            let index = elements.firstIndex(where: { self.onCheckEquality($0, element) })
        else
        {
            throw Errors.invalidElement
        }
        
        //---
        
        if
            !allowMultipleSelection
        {
            selection.removeAll()
        }
        
        //---
        
        selection.insert(index)
        
        //---
        
        return self
    }
    
    @discardableResult
    mutating
    func select(at index: Int) throws -> Self
    {
        guard
            elements.xce.isValidIndex(index)
        else
        {
            throw Errors.invalidIndex
        }
        
        //---
        
        if
            !allowMultipleSelection
        {
            selection.removeAll()
        }
        
        //---
        
        selection.insert(index)
        
        //---
        
        return self
    }
    
    @discardableResult
    mutating
    func deselect(_ element: Element) throws -> Self
    {
        guard
            let index = elements.firstIndex(where: { self.onCheckEquality($0, element) })
        else
        {
            throw Errors.invalidElement
        }
        
        //---
        
        selection.remove(index)
        
        //---
        
        return self
    }
    
    @discardableResult
    mutating
    func deselect(at index: Int) throws -> Self
    {
        guard
            elements.xce.isValidIndex(index)
        else
        {
            throw Errors.invalidIndex
        }
        
        //---
        
        selection.remove(index)
        
        //---
        
        return self
    }
    
    @discardableResult
    mutating
    func deselectAll() -> Self
    {
        selection.removeAll()
        
        //---
        
        return self
    }
}
