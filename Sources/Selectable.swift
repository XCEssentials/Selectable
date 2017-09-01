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

// MARK: - Base declarations

/**
 Array-like (and Array-based) data container that allows to store list of elements with built-in selection tracking.
 */
public
struct Selectable<Element>
{
    // MARK: - Private members

    fileprivate
    let isEqual: (Element, Element) -> Bool
    
    fileprivate
    var selection: Set<Int> = [] // indexes in 'elements'
    
    // MARK: - Initializers
    
    public
    init(
        _ initialValues: [Element] = [],
        _ multiSelection: Bool = false,
        _ equalityCheck: @escaping (Element, Element) -> Bool
        )
    {
        self.allowMultipleSelection = multiSelection
        self.isEqual = equalityCheck
        
        self.elements = initialValues
    }

    // MARK: - Public members

    public
    var elements: [Element] = []
    {
        didSet
        {
            let newValue = elements
            
            //---
            
            // ensure that selection always contains valid indexes only
            
            let oldSelectedElements = selection.map{ oldValue[$0] }
            
            let newSelectedIndexes = oldSelectedElements.flatMap{ oldElement in
                
                newValue.index(where: { newElement in
                    
                    isEqual(newElement, oldElement)
                })
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
    
    public
    enum Errors
    {
        struct InvalidElement: Error { }
        
        struct InvalidIndex: Error { }
    }
}

// MARK: - Special initializer for Equatable elements

public
extension Selectable where Element: Equatable
{
    init(
        _ initialValues: [Element] = [],
        _ multiSelection: Bool = false
        )
    {
        self.init(initialValues, multiSelection, ==)
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
    
    //===
    
    var selectedElements: [Element]
    {
        return selectedIndexes.map{ elements[$0] }
    }
    
    //===
    
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
    
    //===
    
    func select(_ element: Element) throws -> Selectable<Element>
    {
        guard
            let index = elements.index(where: { self.isEqual($0, element) })
        else
        {
            throw Errors.InvalidElement()
        }
        
        //---
        
        var result = self
        
        //---
        
        if
            !allowMultipleSelection
        {
            result.selection.removeAll()
        }
        
        //---
        
        result.selection.insert(index)
        
        //---
        
        return result
    }
    
    //===
    
    func select(at index: Int) throws -> Selectable<Element>
    {
        guard
            elements.xce.isValidIndex(index)
        else
        {
            throw Errors.InvalidIndex()
        }
        
        //---
        
        var result = self
        
        //---
        
        if
            !allowMultipleSelection
        {
            result.selection.removeAll()
        }
        
        //---
        
        result.selection.insert(index)
        
        //---
        
        return result
    }
    
    //===
    
    func deselect(_ element: Element) throws -> Selectable<Element>
    {
        guard
            let index = elements.index(where: { self.isEqual($0, element) })
        else
        {
            throw Errors.InvalidElement()
        }
        
        //---
        
        var result = self
        
        //---
        
        result.selection.remove(index)
        
        //---
        
        return result
    }
    
    //===
    
    func deselect(at index: Int) throws -> Selectable<Element>
    {
        guard
            elements.xce.isValidIndex(index)
        else
        {
            throw Errors.InvalidIndex()
        }
        
        //---
        
        var result = self
        
        //---
        
        result.selection.remove(index)
        
        //---
        
        return result
    }
    
    //===
    
    func deselectAll() -> Selectable<Element>
    {
        var result = self
        
        //---
        
        result.selection.removeAll()
        
        //---
        
        return result
    }
    
    //===
    
    func clearSelection() -> Selectable<Element>
    {
        return deselectAll()
    }
}
