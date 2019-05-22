//
//  FunctionalFramework.swift
//  FunWithFunctionalUIKitStyling
//
//  Created by Benjamin Hakes on 5/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//


import Foundation
import Swift


// MARK: - Precedence Groups

/**
 Forward Application Precendence Group "|>"
 
 */
precedencegroup ForwardApplication {
    // Without the associativity assignment below, Swift would not have enough information
    // to evaluate 4 |> incr |> sqre, b/c it wouldn't "know" the order in which to evaluate
    // these. Should it evaluate 4 |> incr, then sqre? Or should it incr |> sqre, then 2 |> to
    // that combined function
    associativity: left
}

precedencegroup ForwardComposition {
    associativity: left
    /* Without the precedence specifier that Forward Composition is "higherThan" ForwardApplication("|>"). Swift would not have enough information to evaluate 2 |> incr >>> sqre, b/c it wouldn't "know" whether to compose the functions first, then plug in the data, or whether to plug in the data, and then compose that result with the other function. That is, should it evaluate 2 |> incr, Forward compose with sqre? (side note, would that make sense?... no) Or should it compose incr with sqre, like: incr >>> sqre, then apply the "Pipe-Forward" operator, aka, plugging in the data.
     
     The higher than is a precedence orderly like PENDAS that specified that >>> is "more important" than |>.*/
    higherThan: EffectfulComposition
}

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: SingleTypeComposition
}

precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: ForwardApplication
}

// MARK: - Helpers for testing code

public func incr(_ x: Int) -> Int {
    return x + 1
}

// MARK: - Infix Operators

/*
 Test for adding new infix operators:
 1. Does this operator shape already exist in Swift? No - Pass. Yes - Fail.
 2. Are we leveraging prior "art" a history of use in other languages? Yes - Pass. No - Fail.
 3. Is the operator solving a universal problem? Yes - Pass. No - Fail.
 
 If `Pass` on all three - Pass. Else - Fail.
 
 */

/**
 "Pipe-forward" Operator
 */
infix operator |>: ForwardApplication // Pipe forward is in the ForwardApplication precedence group

/**
 "Forward Composition" Operator
 */
infix operator >>>: ForwardComposition //  g(f(a)) or f(a) -> g(a) -> h(a)
/**
 "Effect-ful" Composition Operator or "Fish" Operator
 */
infix operator >=>: EffectfulComposition//  g(f(a)) or f(a) -> g(a) -> h(a) with side effect
/**
 "Single-Type" Composition Operator or "Diamond" Operator
 */
infix operator <>: SingleTypeComposition // f(a) -> f(a)


// MARK: - Generic Operator Implementations

/**
 “Pipe-Forward” Operator
 
 - Parameters:
 - a: a generic value you want to operate on
 - f: a generic function that you want to use on the generic value `a`
 - Returns: a generic value
 
 - Note: `|>` is based on prior art: F#, Elixir, and Elm all use this operator for function application.
 With "Pipe-forward", we can take a value and pipe it into our free function.
 */
public func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

/**
 “Pipe-Forward” Inout Operator
 
 - Parameters:
 - a: a generic value you want to operate on
 - f: a generic function that you want to use on the generic value `a`
 - Returns: a generic value
 
 - Note: `|>` is based on prior art: F#, Elixir, and Elm all use this operator for function application.
 With "Pipe-forward", we can take a value and pipe it into our free function.
 */
public func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
    return f(&a)
}

/**
 “Forward-Compose” Operator or "Right Arrow" Operator or "Function Composition" Operator
 
 - Parameters:
 - f: a (@escaping) function that goes from generic type A to generic type B
 - g: a (@escaping) function that goes from generic type B to generic type C
 - Returns: a function that goes from generic type A to generic type C
 
 - Remark: ```swift
 func incr(_ x: Int) -> Int {
 return x + 1
 }
 func sqre<(_ x: Int) -> Int {
 return x * x
 }
 
 //    incr >>> square
 //    square >>> incr
 // even can pipe it into a free function string initializer
 //    incr >>> square >>> String.init // new function from int to string
 //    [1,2,3].map(incr >>> square)
 
 ```
 
 - Note: `>>>` is based on prior art: F#, Elixir, and Elm all use this operator for function application. Forward compose is said to be "generic over 3 parameters".
 */
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}

/**
 “Effect-ful” Composition w/ [String] a.k.a. the "Fish" Operator
 
 - Parameters:
 - f: a (@escaping) function that goes from generic type A to a tuple of a generic type B and an array of strings
 - g: a (@escaping) function that goes from generic type B to a tuple of a generic type C and an array of strings
 - Returns: a function that goes from generic type A to a tuple of a generic type C and an array of strings
 
 - Remark: Effect-ful Composition has a lower precedence than its close cousin, Forward Composition. When you read this, know that we are dealing with the composition of a function that had an effect. The shape of this operator's signature can be applied to a couple types right at this moment.
 - Note: `>=>` is a close cousin of the `>>>` Forward Compose operator, accept that with the Fish operator, it attempts be compatible with functions that have "side effects". `>=>` is based on prior art in other functional languages. Forward compose is said to be "generic over 3 parameters". By
 */
public func >=> <A, B, C>(_ f: @escaping (A) -> (B, [String]), g: @escaping (B) -> (C, [String])) -> ((A) -> (C,[String])) {
    return { a in
        let (b, logs) = f(a)
        let (c, moreLogs) = g(b)
        return (c, logs + moreLogs)
    }
}

/**
 “Effect-ful” Composition w/ Optional a.k.a. the "Fish" Operator
 
 - Parameters:
 - f: a (@escaping) function that goes from generic type A to a generic type optional B
 - g: a (@escaping) function that goes from generic type B to a generic type optional C
 - Returns: a function that goes from generic type A to a generic type optional C
 
 - Remark: Effect-ful Composition has a lower precedence than its close cousin, Forward Composition. When you read this, know that we are dealing with the composition of a function that had an effect. The shape of this operator's signature can be applied to a couple types right at this moment.
 - Note: `>=>` is a close cousin of the `>>>` Forward Compose operator, accept that with the Fish operator, it attempts be compatible with functions that have "side effects". `>=>` is based on prior art in other functional languages. Forward compose is said to be "generic over 3 parameters". By
 */
public func >=> <A, B, C>(_ f: @escaping (A) -> B?, g: @escaping (B) -> C?) -> ((A) -> C?) {
    return { a in
        if let b = f(a){
            if let c = g(b) {
                // the function composed correctly
                return c
            }
        }
        return nil
        // else, the function did not composed correctly
    }
}


/**
 “Effect-ful” Composition w/ Array a.k.a. the "Fish" Operator
 
 - Parameters:
 - f: a (@escaping) function that goes from generic type A to a generic array of B
 - g: a (@escaping) function that goes from generic type B to a generic array of C
 - Returns: a function that goes from generic type A to a generic array of C
 
 - Remark: Effect-ful Composition has a lower precedence than its close cousin, Forward Composition. When you read this, know that we are dealing with the composition of a function that had an effect. The shape of this operator's signature can be applied to a couple types right at this moment.
 - Note: `>=>` is a close cousin of the `>>>` Forward Compose operator, accept that with the Fish operator, it attempts be compatible with functions that have "side effects". `>=>` is based on prior art in other functional languages. Forward compose is said to be "generic over 3 parameters". By
 */
public func >=> <A, B, C>(_ f: @escaping (A) -> [B], g: @escaping (B) -> [C]) -> ((A) -> [C]) {
    return { a in
        let b = f(a)
        var c: [C] = []
        for point in b{ // could I make this more `functional`?
            c += g(point)
        }
        return c
    }
}

/**
 "Single-Type" Composition to Void a.k.a. the "Diamond" Operator to Void
 
 - Parameters:
 - f: a (@escaping) function that goes from generic type A to Void
 - g: a (@escaping) function that goes from generic type A to Void
 - Returns: a function that goes from generic type A to Void
 
 - Note: Motivation: Even though we saw that (A) -> A functions compose using >>>, we shouldn’t reuse this operator because it has way too much freedom. We’re looking at a much more constrained, single-type composition. Prior art for this operator: this operator exists Haskell and PureScript, but also the large languages with big functional programming communities.
 */
public func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

/**
 "Single-Type" Composition to Self a.k.a. the "Diamond" Operator to Self
 
 - Parameters:
 - f: a (@escaping) function that goes from generic type A to itself
 - g: a (@escaping) function that goes from generic type A to itself
 - Returns: a function that goes from generic type A to itself
 
 - Note: Motivation: Even though we saw that (A) -> A functions compose using >>>, we shouldn’t reuse this operator because it has way too much freedom. We’re looking at a much more constrained, single-type composition.
 */
public func <> <A: AnyObject>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
    return f >>> g
}

/**
 Inout "Single-Type" Composition to Void a.k.a. the Inout "Diamond" Operator to Void
 
 - Parameters:
 - f: a (@escaping) function that goes from a generic inout type A to Void
 - g: a (@escaping) function that goes from a generic inout type A to Void
 - Returns: a function that goes from a generic inout type A to Void
 
 - Note: Motivation: Even though we saw that (A) -> A functions compose using >>>, we shouldn’t reuse this operator because it has way too much freedom. We’re looking at a much more constrained, single-type composition. The generic a is constained against the AnyObject is a protocol that all reference types conform to.
 */
public func <> <A: AnyObject>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> ((inout A) -> Void) {
    return { a in
        f(&a)
        g(&a)
    }
}

/**
 2 Parameter "Curry" Function
 
 - Parameters:
 - f: a (@escaping) function that goes from a tuple of a generic A and B to a generic C
 - Returns: a function that goes from generic A to a function from generic B to generic C
 
 - Note: Motivation: When we have a function with multiple parameters, it doesn't compose well with `>>>`, our forward composition operator. Currying mutates the multi-parameter function so that it plays nicer with our exisiting function composition code. It is possible to "Curry" more than two values.
 */
public func curry <A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return {
        a in {
            b in
            f(a, b)
        }
    }
}

/**
 3 Parameter "Curry" Function
 
 - Parameters:
 - f: a (@escaping) function that goes from a 3-tuple of a generic A, B, C to a generic Z
 - Returns: a function that goes from generic A to a generic B to a generic C to a generic Z
 
 - Note: Motivation: When we have a function with multiple parameters, it doesn't compose well with `>>>`, our forward composition operator. Currying mutates the multi-parameter function so that it plays nicer with our exisiting function composition code. It is possible to "Curry" more than two values (in this instance, 3 values).
 */
public func curry <A, B, C, Z>(_ f: @escaping (A, B, C) -> Z) -> (A) -> (B) -> (C) -> Z {
    return {
        a in {
            b in {
                c in
                f(a, b, c)
            }
        }
    }
}

/**
 2 Parameter "Uncurry" Function
 
 - Parameters:
 - f: a (@escaping) function that goes from generic A to a function from generic B to generic C
 - Returns: a function that goes from a tuple of generic A and generic B to a generic C
 
 - Note: Motivation: TODO: "Uncurrying" motivation
 */
public func curry <A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return {
        a,b in
        f(a)(b)
    }
}

/**
 Flip a Function
 
 - Parameters:
 - f: a (@escaping) function that goes from a generic A to a function that goes from a generic B to a generic C
 - Returns: a function that goes from generic B to a function from generic A to generic C
 
 - Note: Motivation: Often times when we are using Curry, the data parameters of a function are put up from with the settings and implementation details of the function placed later afterwards. This presents a problem when we Curry because, often, we'd prefer to specify our implementation and configuration details upfront once, and then just compose or pipe our data into that data parameter of the composed function to get our result. Flip invert the parameter priority which allows us to do just that.

 */
public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return {
        b in {
            a in
            f(a)(b)
        }
    }
}

/**
 Flip a Function - No Parameters
 
 - Parameters:
 - f: a (@escaping) function that goes from a generic A to a function that goes from void to a generic C
 - Returns: a function that goes from void to a function from generic A to generic C
 
 - Note: Motivation: Often times when we are using Curry, the data parameters of a function are put up from with the settings and implementation details of the function placed later afterwards. This presents a problem when we Curry because, often, we'd prefer to specify our implementation and configuration details upfront once, and then just compose or pipe our data into that data parameter of the composed function to get our result. Flip invert the parameter priority which allows us to do just that.
 
 */
public func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
    return {
        { a in
            f(a)()
        }
    }
}

/**
 Zurry a Function - Effectively changes () -> (String) -> String to (String) -> String.
 
 - Parameters:
 - f: a (@escaping) function that goes from Voide to a generic A
 - Returns: a generic A
 
 - Note: Motivation: Often times when we are using Curry, we get in an awkward situation in which we have to execute a function at the end like this: flip(String.uppercased)(). To fix this problem we can Zurry the function: zurry(flip(String.uppercased)). It effectively changes () -> (String) -> String to (String) -> String.
 
 */
public func zurry<A>(_ f: () -> A) -> A {
    return f()
}

/**
 Free Map Function - A generic implementation of the array map.
 
 - Parameters:
 - f: a (@escaping) function named (internally) f that goes from a generic A to a generic B
 - Returns: a function that goes from an array of a generic type A to an array of a generic type B.
 
 - Note: Motivation: We get to use map without having to have any data to deal with.
 
 */
public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { $0.map(f) }
}

/**
 Free Filter Function - A generic implementation of the array filter.
 
 - Parameters:
 - f: a (@escaping) function named (internally) p that goes from a generic A to a Bool
 - Returns: a function that goes from an array of a generic type A to another array of a generic type A.
 
 - Note: Motivation: We get to use filtering without having to have any data to deal with.
 
 */
public func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
    return { $0.filter(p) }
}

// map(incr >>> square >>> String.init)

/**
 Free Reduce Function - A generic implementation of the array reduce.
 
 - Parameters:
 - f: a (@escaping) function named (internally) accumulator that goes from a tuple of a generic R and A to a generic R
 - Returns: a function that goes from an array of a generic type A to another array of a generic type A.
 
 - Note: Motivation: We get to use filtering without having to have any data to deal with.
 
 */
public func reduce<A, R>(_ accumulator: @escaping (R, A) -> R) -> (R) -> ([A]) -> R {
    
    return { initialValue in
        return { collection in
            return collection.reduce(initialValue, accumulator)
        }
    }
}


String.init(utf8String:) >=> URL.init(string:)

curry(URLRequest.init(url:cachePolicy:timeoutInterval:))

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B){
    return { pair in
        (f(pair.0), pair.1)
    }
}

let pair = (42, "Swift")
(incr(pair.0), pair.1)



pair |> first(incr) |> first(incr)
