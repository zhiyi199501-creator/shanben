import SwiftData
import SwiftUI

struct DeedEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let deed: Deed?
    @State private var content: String
    @State private var occurredAt: Date
    @FocusState private var writing: Bool

    init(deed: Deed?, defaultDate: Date = .now) {
        self.deed = deed
        _content = State(initialValue: deed?.content ?? "")
        _occurredAt = State(initialValue: deed?.occurredAt ?? defaultDate)
    }

    private var trimmed: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                DatePicker("", selection: $occurredAt, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Theme.accent)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                ZStack(alignment: .topLeading) {
                    if trimmed.isEmpty {
                        Text("做了什么，对人有什么益处")
                            .font(Theme.body(18))
                            .foregroundStyle(Theme.muted.opacity(0.55))
                            .padding(.horizontal, 28)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $content)
                        .font(Theme.body(18))
                        .foregroundStyle(Theme.ink)
                        .lineSpacing(6)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .focused($writing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(deed == nil ? "记一善" : "改一笔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("记下") { save() }
                        .disabled(trimmed.isEmpty)
                        .fontWeight(.semibold)
                }
                if deed != nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button("删除", role: .destructive, action: remove)
                    }
                }
            }
            .onAppear { writing = true }
        }
        .tint(Theme.accent)
    }

    private func save() {
        guard !trimmed.isEmpty else { return }
        if let deed {
            deed.content = trimmed
            deed.occurredAt = occurredAt
            deed.updatedAt = .now
        } else {
            modelContext.insert(Deed(content: trimmed, occurredAt: occurredAt))
        }
        dismiss()
    }

    private func remove() {
        if let deed {
            modelContext.delete(deed)
        }
        dismiss()
    }
}
