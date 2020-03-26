//
//  Interacting.swift
//
//   Created by Pramit Tewari on 13/07/18.
//

import Foundation

/// Base protocol for all Interactors and a common extension point.
protocol Interacting: class {

    /**
     Called when the view has loaded and the
     presenter can start telling the view what to show.
     */
    func viewDidLoad()

    /**
     Called when the view is about to show on the screen.
     Use this as an opportunity to refresh the view
     */
    func viewWillAppear()
    
    /**
     Called when the view is about to leave the screen.
     Use this to clean up any observers and state.
     */
    func viewWillDisappear()

}

extension Interacting {

    /**
     Default impl since not every interactor is hooked into
     the iOS view life cycle. This empty method satisfies the protocol contract
     without having to add the empty method to our Interactor implementation. If
     we want to use the method, we override it in the implementation.
     */
    func viewDidLoad() {
        // Do Nothing by Default
    }

    /**
     Default impl since not every interactor is hooked into
     the iOS view life cycle. This empty method satisfies the protocol contract
     without having to add the empty method to our Interactor implementation. If
     we want to use the method, we override it in the implementation.
     */
    func viewWillAppear() {
        // Do Nothing by Default
    }

    /**
     Default impl since not every interactor is hooked into
     the iOS view life cycle. This empty method satisfies the protocol contract
     without having to add the empty method to our Interactor implementation. If
     we want to use the method, we override it in the implementation.
     */
    func viewWillDisappear() {
        // Do Nothing by Default
    }

}
