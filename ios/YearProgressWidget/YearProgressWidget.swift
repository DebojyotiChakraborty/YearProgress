import WidgetKit
import SwiftUI

// This struct defines the data needed for the widget.
struct YearProgressEntry: TimelineEntry {
    let date: Date
    let progress: Double
}

// This struct is responsible for providing data to the widget.
struct Provider: TimelineProvider {
    // Placeholder is used when WidgetKit doesn't have data yet (e.g., in the widget gallery).
    func placeholder(in context: Context) -> YearProgressEntry {
        YearProgressEntry(date: Date(), progress: 0.5) // Example: 50% progress
    }

    // Snapshot is used for a quick preview in transient situations.
    func getSnapshot(in context: Context, completion: @escaping (YearProgressEntry) -> ()) {
        let entry = YearProgressEntry(date: Date(), progress: calculateYearProgress())
        completion(entry)
    }

    // Timeline provides a series of entries to update the widget over time.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [YearProgressEntry] = []

        // Generate a timeline consisting of one entry.  We'll update every hour.
        let currentDate = Date()
        let progress = calculateYearProgress()
        let entry = YearProgressEntry(date: currentDate, progress: progress)
        entries.append(entry)

        // Create a timeline that reloads after one hour.
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }

    // Helper function to calculate year progress (similar to your Flutter code).
    func calculateYearProgress() -> Double {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1))!
        let totalSeconds = endOfYear.timeIntervalSince(startOfYear)
        let secondsPassed = now.timeIntervalSince(startOfYear)
        return (secondsPassed / totalSeconds) * 100
    }
}

// This struct defines the widget's UI.
struct YearProgressWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.white.gradient)
            VStack {
                Text("\(Int(entry.progress.rounded()))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                ProgressView(value: entry.progress / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .padding(.horizontal)
                Text("Year Progress")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

        }
    }
}

// This is the main configuration for the widget.
struct YearProgressWidget: Widget {
    let kind: String = "YearProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YearProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Year Progress")
        .description("Shows the current year's progress.")
        .supportedFamilies([.systemSmall, .systemMedium]) // Specify supported widget sizes.
    }
}

// Preview for Xcode's canvas.
#Preview(as: .systemSmall) {
    YearProgressWidget()
} timeline: {
    YearProgressEntry(date: Date(), progress: 25)
    YearProgressEntry(date: Date(), progress: 75)
} 