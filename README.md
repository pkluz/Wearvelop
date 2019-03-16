# Wearvelop

## Installation

Wearvelop uses CocoaPods for dependency management. Dependencies are checked into the repository, so no extra work is required.

Dependencies can be INSTALLED using:
```
pod install
```

Dependencies can be UPDATED by executing
```
pod update
```

## Application Structure

```
Wearvelop.xcworkspace
Wearvelop.xcproj
Wearvelop/
├── Resources/                       // Assets, Graphics, ML Models
├── Source/                          // Application Source
|   ├── AppDelegate.swift
|   ├── Application Context/         // Application Layer Code
|   ├── Display Context/             // Render Layer Code
|   ├── Node Context/                // Logic Layer Code
|   └── Utilities/                   // Various Extension and Helpers.
├── Supporting/                      // Auxiliary Files
|   └── Info.plist
└── Vendor/                          // Third Party Dependencies (Directly Included)
```

## Extending Wearvelop

### Adding New Nodes

Adding new `Nodes` is a simple process.

1. Open `Wearvelop.xcworkspace`.
2. **Logic:** Consult `Sources/Node Context/Concrete Nodes/ScalarNode.swift` to see how a simple multiplication node is implemented. All your nodes should inherit from `Node`.
3. **Rendering:** _OPTIONAL_ If you want to customize the look of your node, consult `Sources/Display Context/Concrete DisplayNodes/PrintDisplayNode.swift` to see how a simple customized node is implemented. All your display nodes should inherit from `DisplayNode`.
4. **Usage:** In order to make the application aware of your extension, open `Sources/Application Context/Models/NodeDescriptor.swift` and extend the enum with a case for you node. When you attempt to compile the application now, Swift will statically inform you of three more `switch`es where you will need to add a) a display name for your node b) a description for your node c) a way to initialize your node.
5. _OPTIONAL_: In case your node has a more complex setup process and requires user decisions before it can be rendered, compare how `ConstantDisplayNode.swift` is built.
