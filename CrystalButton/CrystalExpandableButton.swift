//
//  CrystalButton.swift
//  ButtonDemo
//
//  Created by Robert Cole on 7/22/22.
//

import SwiftUI

extension CGFloat {
    static let standardSpacing: CGFloat = 8
    static let menuCornerRadius: CGFloat = 10
    static let icon: CGFloat = 44
}

/*
 TODO: Below
 x1. Add optional action for button touch
 x2. Make content into view builder
 x3. Make title optional
 x4. Make content optional, EmptyView as internal default.
 5. Add previews and tests for the new previews added.
 6. Add additional inits to make this cleaner?
 7. Remove expanded width
 8. Allow for other views for the icon. Will need to add another generic for this.
 */
public struct CrystalExpandableButton<Content>: View where Content: View {
    @ScaledMetric(relativeTo: .title)
    var iconSize: CGFloat = .icon

    @ScaledMetric(relativeTo: .title)
    var menuCornerRadius: CGFloat = .menuCornerRadius

    public init(
        expanded: Binding<Bool>,
        iconName: String,
        title: String? = nil,
        color: Color = .crystalForegroundDefault,
        @ViewBuilder content: () -> Content,
        action: CrystalExpandableButton<Content>.Action? = nil
    ) {
        _expanded = expanded
        self.iconName = iconName
        self.title = title
        self.color = color
        self.content = content()
        self.action = action
    }

    public typealias Action = () -> Void

    @Binding var expanded: Bool

    private var nonEmptyViewExpanded: Bool {
        !(content is EmptyView) && expanded
    }

    let iconName: String
    let title: String?
    let color: Color
    let content: Content
    let action: Action?

    var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    // add action and pass in expansion state to it.
                    expanded.toggle()
                    action?()
                } label: {
                    SFSymbolIcon(iconName: iconName)
                }
                .buttonStyle(.plain)

                if nonEmptyViewExpanded {
                    HStack(spacing: 0) {
                        if let title {
                            Text(title)
                                .font(.headline)
                        }

                        Spacer()

                        CloseButton(color: color) {
                            self.expanded.toggle()
                        }
                    }
                    .transition(.opacity)
                }

                Spacer(minLength: 0)
            }

            if nonEmptyViewExpanded {
                Separator(style: .horizontal)
            }
        }
        .frame(width: nonEmptyViewExpanded ? nil : iconSize, height: iconSize + (expanded ? 1 : 0))
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
            VStack(spacing: 0) {
                header
                    .frame(maxWidth: .infinity)

                if nonEmptyViewExpanded {
                    content
                        .transition(.opacity)

                    Spacer()
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: nonEmptyViewExpanded ? menuCornerRadius : .infinity))
        .animation(.spring(), value: expanded)
        .fixedSize()
    }
}

public extension CrystalExpandableButton where Content == EmptyView {
    init(
        expanded: Binding<Bool>,
        iconName: String,
        title: String? = nil,
        color: Color = .crystalForegroundDefault,
        action: CrystalExpandableButton<Content>.Action? = nil
    ) {
        self.init(
            expanded: expanded,
            iconName: iconName,
            title: title,
            color: color,
            content: { EmptyView() },
            action: action
        )
    }
}

struct CrystalExpandableButton_PreviewWrapper: View {
    @State var expanded: Bool
    var title: String?

    var body: some View {
        CrystalExpandableButton(
            expanded: $expanded,
            iconName: "questionmark",
            title: title
        ) {
            Text(LoremIpsum.paragraphs(1))
                .font(.system(size: 18.0))
                .padding(.standardSpacing)
                .frame(width: 300)
                .foregroundColor(.crystalForegroundDefault)
        }
        action: {} // Need to make an init to fix this
    }
}

struct CrystalExpandableButton_Previews: PreviewProvider {
    static var previews: some View {
        CenteredPreview(content: CrystalExpandableButton_PreviewWrapper(expanded: true, title: nil))

        CenteredPreview(content: CrystalExpandableButton_PreviewWrapper(expanded: false, title: "Information"))
    }
}
