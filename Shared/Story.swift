import Foundation
import Observation

struct Grandparent: Identifiable, Hashable {
    let id: String
    /// What the family calls them, e.g. "Papa" or "Grandma Bev".
    let name: String
    /// "his" or "her", for sentences like "after he answers his first question".
    let his: String
}

enum Family {
    /// The starting names. The family can rename anyone on the Family screen.
    private static let defaults: [Grandparent] = [
        Grandparent(id: "papa", name: "Papa", his: "his"),
        Grandparent(id: "bev", name: "Grandma Bev", his: "her"),
        Grandparent(id: "lou", name: "Grandpa Lou", his: "his"),
    ]

    static var grandparents: [Grandparent] {
        defaults.map { grandparent in
            let edit = GrandparentEdits.shared.edits[grandparent.id]
            return Grandparent(id: grandparent.id,
                               name: edit?.name ?? grandparent.name,
                               his: edit?.his ?? grandparent.his)
        }
    }

    static func grandparent(_ id: String) -> Grandparent {
        grandparents.first { $0.id == id } ?? grandparents[0]
    }

    static func rename(_ id: String, to name: String, his: String) {
        GrandparentEdits.shared.edits[id] = .init(name: name, his: his)
    }
}

/// Names and pronouns the family has changed, saved on this phone.
/// Observable, so every screen updates the moment someone is renamed.
@Observable
final class GrandparentEdits {
    struct Edit: Codable { var name: String; var his: String }

    static let shared = GrandparentEdits()
    private static let key = "grandparentEdits"

    var edits: [String: Edit] {
        didSet { UserDefaults.standard.set(try? JSONEncoder().encode(edits), forKey: Self.key) }
    }

    private init() {
        let data = UserDefaults.standard.data(forKey: Self.key)
        edits = data.flatMap { try? JSONDecoder().decode([String: Edit].self, from: $0) } ?? [:]
    }
}

enum AnswerType {
    case voice(seconds: Int)
    case typed
}

struct Story: Identifiable {
    let id: Int
    let grandparentID: String
    /// Asked straight to the grandparent, e.g. "What was your first job?".
    let question: String
    let text: String
    /// Follows "Papa, about ..." in the caption.
    let about: String
    let answerType: AnswerType
    /// How many days ago it was answered. Used to sort the Stories list.
    let answeredDaysAgo: Int

    var grandparent: Grandparent { Family.grandparent(grandparentID) }
    var caption: String { "\(grandparent.name), about \(about)" }
    /// Short title for lists, e.g. "Her first night at Mercy in 1963".
    var title: String { about.prefix(1).uppercased() + about.dropFirst() }
    var isRecording: Bool {
        if case .voice = answerType { true } else { false }
    }
    var answeredDate: Date {
        Calendar.current.date(byAdding: .day, value: -answeredDaysAgo, to: .now) ?? .now
    }
    /// "Recording, 2:34" or "Written", for list rows.
    var formLabel: String {
        switch answerType {
        case .voice(let seconds): "Recording, \(Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond)))"
        case .typed: "Written"
        }
    }
}

enum SampleStories {
    static let all: [Story] = [
        Story(id: 0, grandparentID: "papa",
              question: "What was your first job?",
              text: "Pumping gas at Fenske's Standard on Main Street. I was fifteen. Murray Fenske paid me seventy-five cents an hour and I thought I was rich. You checked the oil, washed the windshield, checked the tires, every car, didn't matter if they only bought a dollar of gas. Murray had a bad leg from the war so I did most of the lifting. He kept a jar of pickled eggs on the counter that I don't believe anybody ever ate.",
              about: "Murray Fenske's station in 1956",
              answerType: .typed, answeredDaysAgo: 2),
        Story(id: 1, grandparentID: "papa",
              question: "How did you meet Grandma?",
              text: "Her cousin Ruthie was going with my buddy Dale Hutchins, and Dale needed somebody to make it four for the drive-in. That was the Starlite out on Highway 63. I don't remember what the picture was. Your grandma would tell you it was Splendor in the Grass and I'd tell you I wasn't watching it. She had a green sweater on. Dale's Ford ran out of gas on the way home and we all walked the last mile and a half, and she didn't complain once, which I noticed.",
              about: "meeting Joan in 1961",
              answerType: .voice(seconds: 154), answeredDaysAgo: 5),
        Story(id: 2, grandparentID: "papa",
              question: "What do you remember about the day Aunt Marci was born?",
              text: "It snowed. Fourteen inches, I want to say, and it was March, so nobody was ready for it. Dr. Peterson couldn't get his car out so he walked to the hospital. I sat in the waiting room with a man named Gil who was having his fifth and he kept telling me it gets easier. Then they came out and said it was a girl, and I went down the hall to the pay phone to call your Grandma Hazel and I didn't have a dime. Had to borrow one off Gil.",
              about: "the night Marci was born in 1964",
              answerType: .voice(seconds: 98), answeredDaysAgo: 9),
        Story(id: 3, grandparentID: "papa",
              question: "What was your first car?",
              text: "A 1949 Chevrolet Fleetline, gray over a sort of maroon. Bought it off Lyle Danner's widow for a hundred and ten dollars in 1958. Needed a battery and a muffler. The heater never did work right so in the winter you drove with a blanket on your lap. I put the wrong oil in it once and Murray about had a fit.",
              about: "his '49 Chevy",
              answerType: .typed, answeredDaysAgo: 12),
        Story(id: 4, grandparentID: "papa",
              question: "Why did you move the family to Waterloo?",
              text: "Deere was hiring. That's most of it. I was making two-ten an hour at Morrell's and Deere was paying three and something, plus they had the insurance. Your mother didn't want to go. Her folks were in Ottumwa and she had her church circle. We drove up on a Sunday to look at houses and found the one on Lafayette Street, the green one, and she walked through the kitchen and said, well, the windows are nice. That was about as excited as she got. We paid fourteen thousand five hundred for that house.",
              about: "moving to Waterloo in 1969",
              answerType: .voice(seconds: 132), answeredDaysAgo: 15),
        Story(id: 5, grandparentID: "papa",
              question: "What did you do on Saturday nights when you were my age?",
              text: "Drove around. Main Street to the river and back, then around again. Gas was twenty-seven cents. If somebody had money we'd get a hamburger at the Canteen.",
              about: "Saturday nights in 1957",
              answerType: .typed, answeredDaysAgo: 19),
        Story(id: 6, grandparentID: "papa",
              question: "What was Grandma's best recipe?",
              text: "Her ham balls. Everybody says her pie but it was the ham balls. Ground ham and ground pork, graham cracker crumbs, I know that, and brown sugar and vinegar and some mustard in the sauce. She made them for every funeral at St. Mary's for about thirty years. I've tried to make them twice since she passed and they were not right. Marci might have the card. Ask Marci.",
              about: "Joan's ham balls",
              answerType: .voice(seconds: 85), answeredDaysAgo: 23),
        Story(id: 7, grandparentID: "papa",
              question: "Did you ever get in trouble at school?",
              text: "Once. Bobby Sands and I let a garter snake loose in Mr. Kearney's room. Well, he taught biology, so we figured he'd like it. He did not like it. I stayed after for two weeks washing blackboards, and my dad found out because Mr. Kearney went to our church. That was worse than the two weeks.",
              about: "Mr. Kearney's biology class",
              answerType: .typed, answeredDaysAgo: 26),
        Story(id: 8, grandparentID: "papa",
              question: "What was your dad like?",
              text: "Quiet. He worked for the Burlington, a car man, which meant he fixed the cars, not drove them. He'd come home and wash up in the basement before he came upstairs, every night, so he didn't track it through the house. He liked the Cardinals on the radio. Harry Caray. He'd take us boys fishing at Lake Wapello and we'd sit there four hours and maybe he'd say, there's one, and that was the conversation.",
              about: "his dad, Walt",
              answerType: .voice(seconds: 141), answeredDaysAgo: 30),
        Story(id: 9, grandparentID: "papa",
              question: "What's the worst winter you remember?",
              text: "Seventy-five. The January one. Blizzard came through on a Friday and the plant shut down Saturday, Sunday and Monday. Drifts were up over the garage door on Lafayette. Me and Ernie Vos from next door shoveled about six hours just to get to the street, and then the plow came by and filled it back in.",
              about: "the blizzard of 1975",
              answerType: .typed, answeredDaysAgo: 34),
        Story(id: 10, grandparentID: "papa",
              question: "What did you actually do at Deere?",
              text: "Started on the line at the Westfield plant doing transmission housings. Then I was a setup man a long time, which means you got the machines ready for the next run. Then foreman the last eleven years. Thirty-four years altogether. My boss for most of it was a fella named Dick Van Dyke, no relation, and he heard that joke every day of his life.",
              about: "thirty-four years at Deere",
              answerType: .voice(seconds: 70), answeredDaysAgo: 38),
        Story(id: 11, grandparentID: "papa",
              question: "Where did you and Grandma go on your honeymoon?",
              text: "Okoboji. We had three days. Stayed at a little place on the east side, eleven dollars a night. Rained two of the three days. We played a lot of cribbage. She'll tell you she won every game. She won most of them.",
              about: "the honeymoon in 1963",
              answerType: .typed, answeredDaysAgo: 41),
        Story(id: 12, grandparentID: "papa",
              question: "What music did you listen to as a teenager?",
              text: "Buddy Holly. The Everly Brothers. I got a transistor radio for graduation and you could pick up WLS out of Chicago at night if you held it just so by the window. Dick Biondi. I don't know if anybody remembers him.",
              about: "the radio in 1959",
              answerType: .voice(seconds: 64), answeredDaysAgo: 45),

        // Grandma Bev
        Story(id: 100, grandparentID: "bev",
              question: "What was your first night as a nurse like?",
              text: "Mercy Hospital, Cedar Rapids, June of 1963. They put me on nights on four-west, which was the men's surgical floor. I had a white cap with one black stripe and I was so scared of losing it I used about eleven bobby pins. Mrs. Kubik was the charge nurse. First thing she said to me was, you'll do. That was all. Then she handed me a bedpan.",
              about: "her first night at Mercy in 1963",
              answerType: .voice(seconds: 88), answeredDaysAgo: 1),
        Story(id: 101, grandparentID: "bev",
              question: "What do you remember about the farm?",
              text: "Chores before school. I had the chickens and your Uncle Dale had the hogs, and I thought I got the better deal until I had to clean the henhouse in August. We were on a party line, three longs and a short was ours, and Mrs. Hagen down the road listened in on everybody. Dad got the first television on our road in 1954. People came over Saturday nights for Lawrence Welk and Mother made popcorn in the big kettle.",
              about: "the farm outside Decorah",
              answerType: .typed, answeredDaysAgo: 6),
        Story(id: 102, grandparentID: "bev",
              question: "How did you meet Grandpa Lou?",
              text: "At a dance at the Danceland ballroom. He asked my friend Carol first. She said no, so he asked me, and I said yes mostly so he'd quit standing there. He stepped on my foot twice. He called the nurses' residence the next Tuesday and the house mother hollered up the stairs, Beverly, there's a boy on the phone, and the whole floor heard it.",
              about: "meeting Lou in 1965",
              answerType: .voice(seconds: 121), answeredDaysAgo: 10),
        Story(id: 103, grandparentID: "bev",
              question: "What were you like in school?",
              text: "Quiet. I liked spelling bees. I made it to the county bee in seventh grade and went out on the word rhythm. I can spell it now.",
              about: "the county spelling bee",
              answerType: .typed, answeredDaysAgo: 17),
        Story(id: 104, grandparentID: "bev",
              question: "What did you cook the most when Mom was little?",
              text: "Goulash. Hamburger, macaroni, a can of tomatoes, whatever else was in the cupboard. Your dad called it Tuesday stew because that's when we had it, every Tuesday, for I'd guess fifteen years. You girls complained about it every Tuesday too.",
              about: "Tuesday goulash",
              answerType: .voice(seconds: 54), answeredDaysAgo: 22),
        Story(id: 105, grandparentID: "bev",
              question: "What were you doing at nineteen?",
              text: "Nursing school at St. Luke's. Three years, and you lived there, in the residence, with a curfew at ten-thirty. Students got eight dollars a month. Carol and I would take the bus downtown on our day off and look at coats at Killian's we couldn't buy.",
              about: "nursing school in 1961",
              answerType: .typed, answeredDaysAgo: 29),
        Story(id: 106, grandparentID: "bev",
              question: "What was the hardest part of nursing?",
              text: "Nights, at first. Then when the kids were small and I went back part-time, I was tired all the time. Lou did bedtimes on the nights I worked. He was not good at braids. You girls went to school with some very interesting braids.",
              about: "going back to work in 1974",
              answerType: .voice(seconds: 97), answeredDaysAgo: 36),

        // Grandpa Lou
        Story(id: 200, grandparentID: "lou",
              question: "What did you do at Collins Radio?",
              text: "Assembly, then test. We built radios for airplanes, some for the government I couldn't tell you about then and don't remember enough to tell you now. You wore a white coat and you weren't supposed to have coffee on the bench. Everybody had coffee on the bench.",
              about: "Collins Radio in 1967",
              answerType: .typed, answeredDaysAgo: 3),
        Story(id: 201, grandparentID: "lou",
              question: "What was your first car?",
              text: "A 1956 Ford Fairlane, green and white. Paid three hundred and twenty-five dollars for it in 1961 with detasseling money and what I made sacking groceries at the Hy-Vee. It burned oil. I kept a case of it in the trunk.",
              about: "his '56 Fairlane",
              answerType: .voice(seconds: 66), answeredDaysAgo: 8),
        Story(id: 202, grandparentID: "lou",
              question: "What did you and Grandma do on dates?",
              text: "The Paramount downtown, mostly. Or we'd drive out to the Dairy Queen on First Avenue and sit in the car. She always got a Dilly Bar. Fifteen cents. I'd get a cone and she'd eat half of it.",
              about: "dates with Bev",
              answerType: .typed, answeredDaysAgo: 14),
        Story(id: 203, grandparentID: "lou",
              question: "What do you remember about the flood?",
              text: "Ninety-three. Water came up over the Second Avenue bridge. We were fine on the hill but your Aunt Sandy's basement went, all of it, the freezer, the Christmas stuff. Gary Novak and I hauled sandbags three days down by the Quaker plant. I didn't have the right boots and I never did get the smell out of the ones I had.",
              about: "the flood of 1993",
              answerType: .voice(seconds: 112), answeredDaysAgo: 20),
        Story(id: 204, grandparentID: "lou",
              question: "How did you ask Grandma Bev's dad for permission?",
              text: "I drove out to the farm on a Sunday after church. Her dad was fixing fence and he didn't stop the whole time I talked. When I got done he said, well, she's twenty-two. Then he handed me the post driver.",
              about: "the farm in 1966",
              answerType: .typed, answeredDaysAgo: 27),
        Story(id: 205, grandparentID: "lou",
              question: "What did you do for fun as a kid?",
              text: "Baseball in the Novaks' lot until it got too dark to see the ball. Then we'd listen to the Cubs on WGN. Jack Brickhouse. We played a lot of games we never finished.",
              about: "summers in 1952",
              answerType: .voice(seconds: 59), answeredDaysAgo: 33),
    ]

    /// Days since a fixed date, so every phone picks the same stories on the same day.
    private static func dayNumber(_ date: Date) -> Int {
        let calendar = Calendar.current
        let reference = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        return calendar.dateComponents([.day],
                                       from: calendar.startOfDay(for: reference),
                                       to: calendar.startOfDay(for: date)).day ?? 0
    }

    /// Today's one story. Grandparents take turns in a shuffled order: each one comes up
    /// once every few days, the order changes every round, and nobody comes up twice in a row.
    /// Everyone in the family, and the widget, gets the same story on the same day.
    static func story(for date: Date = .now) -> Story {
        let grandparents = Family.grandparents.filter { grandparent in
            all.contains { $0.grandparentID == grandparent.id }
        }
        let count = grandparents.count
        let day = dayNumber(date)
        let round = day >= 0 ? day / count : (day - count + 1) / count
        let turn = day - round * count

        let grandparent = grandparents[order(round: round, count: count)[turn]]

        // Each time a grandparent comes up, show their next story.
        let theirs = all.filter { $0.grandparentID == grandparent.id }
        let index = ((round % theirs.count) + theirs.count) % theirs.count
        return theirs[index]
    }

    /// The shuffled order of grandparents for one round.
    private static func order(round: Int, count: Int) -> [Int] {
        var generator = SeededGenerator(seed: UInt64(bitPattern: Int64(round)))
        var order = Array(0..<count).shuffled(using: &generator)
        // Don't let the first of this round repeat the last of the previous round.
        if count > 1 {
            var previous = SeededGenerator(seed: UInt64(bitPattern: Int64(round - 1)))
            if order.first == Array(0..<count).shuffled(using: &previous).last {
                order.swapAt(0, 1)
            }
        }
        return order
    }
}

/// Same seed, same numbers, on every phone.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed &+ 0x9E37_79B9_7F4A_7C15 }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
