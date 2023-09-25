# Integrating Mux Data in multiple applications

If you intend to use Mux Data across multiple iOS, iPadOS, and Mac Catalyst applications, code specific to Mux Data can be shared using [Swift Package Manager](https://www.swift.org/package-manager/).

This example application installs the Mux Data SDK for AVPlayer as a dependency to a Swift package library target: `MuxDataContainer`.

## Using Swift Package Manager with Xcode

See the Xcode guide for [adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) on how to install Swift Package Manager dependencies for your application using Xcode.

## Best practices when adapting this example

`MuxDataContainer` in this example is only a passthrough wrapper that wraps `MUXSDKStats` APIs for starting and stopping player monitoring. When using this pattern for your own applications, `MuxDataContainer` is where you'd place code intended to be used alongside Mux Data that is specific to your use case and shared across multiple applications.

For simplicity, this example confgures `MuxDataContainer` as a local package as described in [organizing your code with local packages](https://developer.apple.com/documentation/xcode/organizing-your-code-with-local-packages). A local package is suitable for an initial test and does not require a separate git repository for distribution.

### Not using Swift?

Note: *Although this example is in Swift, Swift Package Manager supports reusing Swift, Objective-C, Objective-C++, C, or C++ components. Generally, as of the time of writing, SPM does not support mixing multiple languages in the same SPM target, consult Apple and SPM documentation linked throughout for more details.*
