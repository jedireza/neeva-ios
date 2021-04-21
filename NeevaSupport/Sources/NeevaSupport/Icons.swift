// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI

extension Image {
    /// Create an image with the provided icon name (as returned from the `suggest` GraphQL endpoint)
    init(neevaIcon: NeevaIcon) {
        self.init(neevaIcon: neevaIcon.rawValue)!
    }

    /// Create an image with the provided icon name (as returned from the `suggest` GraphQL endpoint)
    init?(neevaIcon name: String) {
        if let imageName = iconMapping[name] {
            self.init(imageName, bundle: .module)
        } else {
            return nil
        }
    }

    /// Create an image with the provided icon set (as returned from the `suggest` GraphQL endpoint)
    /// - Parameters:
    ///   - icons: a list of icon names. The first valid icon name will be used.
    init?(icons: [String]) {
        if let name = icons.first(where: { iconMapping[$0] != nil }) {
            self.init(neevaIcon: name)!
        } else {
            return nil
        }
    }
}

/// The icon used for space suggestions
struct SpaceIconView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.spaceIconBackground)
                .frame(width: 20, height: 20)
            Text("S")
                .font(.system(size: 12))
                .foregroundColor(Color.white)
                .fontWeight(.semibold)
        }
    }
}

struct SpaceIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpaceIconView()
        }.previewLayout(.sizeThatFits   )
    }
}


// extracted from `icon-library.ts`
let iconMapping = [
    "gsuite-app": "google",
    "slack-app": "slack",
    "twitter-app": "twitter",
    "dropbox-app": "dropbox",
    "dropbox-paper-app": "dropbox-paper",
    "gcontacts-app": "google-contact",
    "github-app": "github",
    "gdrive-app": "google-drive",
    "gmail-app": "google-mail",
    "gcalendar-app": "google-calendar",
    "office365-app": "o365",
    "o365-calendar-app": "o365-calendar",
    "o365-contacts-app": "o365-contacts",
    "o365-onedrive-app": "o365-onedrive",
    "o365-outlook-app": "o365-outlook",
    "apple-app": "apple",
    "document": "google-doc",
    "event": "google-calendar",
    "file": "google-file",
    "contact": "google-contact",
    "issue": "github-issue-opened",
    "mail": "google-mail",
    "message": "slack",
    "web": "bing",
    "gdrive-archive": "google-zip",
    "gdrive-audio": "google-audio",
    "gdrive-code": "google-code",
    "gdrive-doc": "google-doc",
    "gdrive-drawing": "google-drawing",
    "gdrive-exe": "google-exe",
    "gdrive-event": "google-calendar",
    "gdrive-file": "google-file",
    "gdrive-folder": "google-folder",
    "gdrive-form": "google-forms",
    "gdrive-fusiontable": "google-fusiontable",
    "gdrive-image": "google-image",
    "gdrive-pdf": "google-pdf",
    "gdrive-sheet": "google-sheet",
    "gdrive-slides": "google-slide",
    "gdrive-text": "google-doc",
    "gdrive-video": "google-video",
    "github-archive": "github-zip",
    "github-audio": "github-file",
    "github-code": "github-code",
    "github-doc": "github-text",
    "github-event": "github-file",
    "github-exe": "github-exe",
    "github-file": "github-file",
    "github-folder": "github-folder",
    "github-image": "github-image",
    "github-pdf": "github-pdf",
    "github-sheet": "github-file",
    "github-slides": "github-file",
    "github-text": "github-text",
    "github-video": "github-file",
    "dropbox-archive": "dropbox-zip",
    "dropbox-audio": "dropbox-audio",
    "dropbox-code": "dropbox-code",
    "dropbox-doc": "dropbox-text",
    "dropbox-event": "dropbox-file",
    "dropbox-exe": "dropbox-exe",
    "dropbox-file": "dropbox-file",
    "dropbox-folder": "dropbox-folder",
    "dropbox-image": "dropbox-image",
    "dropbox-pdf": "dropbox-pdf",
    "dropbox-sheet": "dropbox-spreadsheet",
    "dropbox-text": "dropbox-text",
    "dropbox-video": "dropbox-video",
    "onedrive-ai": "onedrive-ai",
    "onedrive-archive": "onedrive-zip",
    "onedrive-audio": "onedrive-audio",
    "onedrive-code": "onedrive-code",
    "onedrive-doc": "onedrive-word",
    "onedrive-exe": "onedrive-exe",
    "onedrive-file": "onedrive-file",
    "onedrive-folder": "onedrive-folder",
    "onedrive-folder-shared": "onedrive-folder.shared",
    "onedrive-font": "onedrive-font",
    "onedrive-image": "onedrive-image",
    "onedrive-keynote": "onedrive-keynote",
    "onedrive-markup": "onedrive-markup",
    "onedrive-numbers": "onedrive-numbers",
    "onedrive-pages": "onedrive-pages",
    "onedrive-pdf": "onedrive-pdf",
    "onedrive-psd": "onedrive-psd",
    "onedrive-sketch": "onedrive-sketch",
    "onedrive-sheet": "onedrive-spreadsheet",
    "onedrive-slides": "onedrive-presentation",
    "onedrive-text": "onedrive-text",
    "onedrive-video": "onedrive-video",
    "slack-archive": "slack-zip",
    "slack-audio": "slack-audio",
    "slack-code": "slack-code",
    "slack-doc": "slack-text",
    "slack-event": "slack-file",
    "slack-exe": "slack-exe",
    "slack-file": "slack-file",
    "slack-folder": "slack-folder",
    "slack-image": "slack-image",
    "slack-pdf": "slack-pdf",
    "slack-sheet": "slack-spreadsheet",
    "slack-text": "slack-text",
    "slack-video": "slack-video",
    "github": "github",
    "github_issue": "github-issue-opened",
    "github_issue-opened": "github-issue-opened",
    "github_issue-closed": "github-issue-closed",
    "github_issue-reopened": "github-issue-reopened",
    "github_pr": "github-pr",
    "github_pr-closed": "github-pr-closed",
    "github_pr-merged": "github-pr-merged",
    "github_pr-unchecked": "github-pr-unchecked",
    "google-calendar": "google-calendar",
    "google-event-01": "google-calendar-1",
    "google-event-02": "google-calendar-2",
    "google-event-03": "google-calendar-3",
    "google-event-04": "google-calendar-4",
    "google-event-05": "google-calendar-5",
    "google-event-06": "google-calendar-6",
    "google-event-07": "google-calendar-7",
    "google-event-08": "google-calendar-8",
    "google-event-09": "google-calendar-9",
    "google-event-10": "google-calendar-10",
    "google-event-11": "google-calendar-11",
    "google-event-12": "google-calendar-12",
    "google-event-13": "google-calendar-13",
    "google-event-14": "google-calendar-14",
    "google-event-15": "google-calendar-15",
    "google-event-16": "google-calendar-16",
    "google-event-17": "google-calendar-17",
    "google-event-18": "google-calendar-18",
    "google-event-19": "google-calendar-19",
    "google-event-20": "google-calendar-20",
    "google-event-21": "google-calendar-21",
    "google-event-22": "google-calendar-22",
    "google-event-23": "google-calendar-23",
    "google-event-24": "google-calendar-24",
    "google-event-25": "google-calendar-25",
    "google-event-26": "google-calendar-26",
    "google-event-27": "google-calendar-27",
    "google-event-28": "google-calendar-28",
    "google-event-29": "google-calendar-29",
    "google-event-30": "google-calendar-30",
    "google-event-31": "google-calendar-31",
    "google-contact": "google-contact",
    "google-email": "google-mail",
    "o365-contact": "o365-contact",
    "o365-email": "o365-mail",
    "o365-calendar": "o365-calendar",
    "o365-event-01": "o365-calendar-1",
    "o365-event-02": "o365-calendar-2",
    "o365-event-03": "o365-calendar-3",
    "o365-event-04": "o365-calendar-4",
    "o365-event-05": "o365-calendar-5",
    "o365-event-06": "o365-calendar-6",
    "o365-event-07": "o365-calendar-7",
    "o365-event-08": "o365-calendar-8",
    "o365-event-09": "o365-calendar-9",
    "o365-event-10": "o365-calendar-10",
    "o365-event-11": "o365-calendar-11",
    "o365-event-12": "o365-calendar-12",
    "o365-event-13": "o365-calendar-13",
    "o365-event-14": "o365-calendar-14",
    "o365-event-15": "o365-calendar-15",
    "o365-event-16": "o365-calendar-16",
    "o365-event-17": "o365-calendar-17",
    "o365-event-18": "o365-calendar-18",
    "o365-event-19": "o365-calendar-19",
    "o365-event-20": "o365-calendar-20",
    "o365-event-21": "o365-calendar-21",
    "o365-event-22": "o365-calendar-22",
    "o365-event-23": "o365-calendar-23",
    "o365-event-24": "o365-calendar-24",
    "o365-event-25": "o365-calendar-25",
    "o365-event-26": "o365-calendar-26",
    "o365-event-27": "o365-calendar-27",
    "o365-event-28": "o365-calendar-28",
    "o365-event-29": "o365-calendar-29",
    "o365-event-30": "o365-calendar-30",
    "o365-event-31": "o365-calendar-31",
    "slack": "slack",
    "bing": "bing",
    "play-video": "play",
    "twitter-verified": "twitter-verified",
    "retweeted": "twitter-retweeted",
]

enum NeevaIcon: String {
    case gsuiteApp = "gsuite-app"
    case slackApp = "slack-app"
    case twitterApp = "twitter-app"
    case dropboxApp = "dropbox-app"
    case dropboxPaperApp = "dropbox-paper-app"
    case gcontactsApp = "gcontacts-app"
    case githubApp = "github-app"
    case gdriveApp = "gdrive-app"
    case gmailApp = "gmail-app"
    case gcalendarApp = "gcalendar-app"
    case office365App = "office365-app"
    case o365CalendarApp = "o365-calendar-app"
    case o365ContactsApp = "o365-contacts-app"
    case o365OnedriveApp = "o365-onedrive-app"
    case o365OutlookApp = "o365-outlook-app"
    case appleApp = "apple-app"
    case document = "document"
    case event = "event"
    case file = "file"
    case contact = "contact"
    case issue = "issue"
    case mail = "mail"
    case message = "message"
    case web = "web"
    case gdriveArchive = "gdrive-archive"
    case gdriveAudio = "gdrive-audio"
    case gdriveCode = "gdrive-code"
    case gdriveDoc = "gdrive-doc"
    case gdriveDrawing = "gdrive-drawing"
    case gdriveExe = "gdrive-exe"
    case gdriveEvent = "gdrive-event"
    case gdriveFile = "gdrive-file"
    case gdriveFolder = "gdrive-folder"
    case gdriveForm = "gdrive-form"
    case gdriveFusiontable = "gdrive-fusiontable"
    case gdriveImage = "gdrive-image"
    case gdrivePdf = "gdrive-pdf"
    case gdriveSheet = "gdrive-sheet"
    case gdriveSlides = "gdrive-slides"
    case gdriveText = "gdrive-text"
    case gdriveVideo = "gdrive-video"
    case githubArchive = "github-archive"
    case githubAudio = "github-audio"
    case githubCode = "github-code"
    case githubDoc = "github-doc"
    case githubEvent = "github-event"
    case githubExe = "github-exe"
    case githubFile = "github-file"
    case githubFolder = "github-folder"
    case githubImage = "github-image"
    case githubPdf = "github-pdf"
    case githubSheet = "github-sheet"
    case githubSlides = "github-slides"
    case githubText = "github-text"
    case githubVideo = "github-video"
    case dropboxArchive = "dropbox-archive"
    case dropboxAudio = "dropbox-audio"
    case dropboxCode = "dropbox-code"
    case dropboxDoc = "dropbox-doc"
    case dropboxEvent = "dropbox-event"
    case dropboxExe = "dropbox-exe"
    case dropboxFile = "dropbox-file"
    case dropboxFolder = "dropbox-folder"
    case dropboxImage = "dropbox-image"
    case dropboxPdf = "dropbox-pdf"
    case dropboxSheet = "dropbox-sheet"
    case dropboxText = "dropbox-text"
    case dropboxVideo = "dropbox-video"
    case onedriveAi = "onedrive-ai"
    case onedriveArchive = "onedrive-archive"
    case onedriveAudio = "onedrive-audio"
    case onedriveCode = "onedrive-code"
    case onedriveDoc = "onedrive-doc"
    case onedriveExe = "onedrive-exe"
    case onedriveFile = "onedrive-file"
    case onedriveFolder = "onedrive-folder"
    case onedriveFolderShared = "onedrive-folder-shared"
    case onedriveFont = "onedrive-font"
    case onedriveImage = "onedrive-image"
    case onedriveKeynote = "onedrive-keynote"
    case onedriveMarkup = "onedrive-markup"
    case onedriveNumbers = "onedrive-numbers"
    case onedrivePages = "onedrive-pages"
    case onedrivePdf = "onedrive-pdf"
    case onedrivePsd = "onedrive-psd"
    case onedriveSketch = "onedrive-sketch"
    case onedriveSheet = "onedrive-sheet"
    case onedriveSlides = "onedrive-slides"
    case onedriveText = "onedrive-text"
    case onedriveVideo = "onedrive-video"
    case slackArchive = "slack-archive"
    case slackAudio = "slack-audio"
    case slackCode = "slack-code"
    case slackDoc = "slack-doc"
    case slackEvent = "slack-event"
    case slackExe = "slack-exe"
    case slackFile = "slack-file"
    case slackFolder = "slack-folder"
    case slackImage = "slack-image"
    case slackPdf = "slack-pdf"
    case slackSheet = "slack-sheet"
    case slackText = "slack-text"
    case slackVideo = "slack-video"
    case github = "github"
    case githubIssue = "github_issue"
    case githubIssueOpened = "github_issue-opened"
    case githubIssueClosed = "github_issue-closed"
    case githubIssueReopened = "github_issue-reopened"
    case githubPr = "github_pr"
    case githubPrClosed = "github_pr-closed"
    case githubPrMerged = "github_pr-merged"
    case githubPrUnchecked = "github_pr-unchecked"
    case googleCalendar = "google-calendar"
    case googleEvent01 = "google-event-01"
    case googleEvent02 = "google-event-02"
    case googleEvent03 = "google-event-03"
    case googleEvent04 = "google-event-04"
    case googleEvent05 = "google-event-05"
    case googleEvent06 = "google-event-06"
    case googleEvent07 = "google-event-07"
    case googleEvent08 = "google-event-08"
    case googleEvent09 = "google-event-09"
    case googleEvent10 = "google-event-10"
    case googleEvent11 = "google-event-11"
    case googleEvent12 = "google-event-12"
    case googleEvent13 = "google-event-13"
    case googleEvent14 = "google-event-14"
    case googleEvent15 = "google-event-15"
    case googleEvent16 = "google-event-16"
    case googleEvent17 = "google-event-17"
    case googleEvent18 = "google-event-18"
    case googleEvent19 = "google-event-19"
    case googleEvent20 = "google-event-20"
    case googleEvent21 = "google-event-21"
    case googleEvent22 = "google-event-22"
    case googleEvent23 = "google-event-23"
    case googleEvent24 = "google-event-24"
    case googleEvent25 = "google-event-25"
    case googleEvent26 = "google-event-26"
    case googleEvent27 = "google-event-27"
    case googleEvent28 = "google-event-28"
    case googleEvent29 = "google-event-29"
    case googleEvent30 = "google-event-30"
    case googleEvent31 = "google-event-31"
    case googleContact = "google-contact"
    case googleEmail = "google-email"
    case o365Contact = "o365-contact"
    case o365Email = "o365-email"
    case o365Calendar = "o365-calendar"
    case o365Event01 = "o365-event-01"
    case o365Event02 = "o365-event-02"
    case o365Event03 = "o365-event-03"
    case o365Event04 = "o365-event-04"
    case o365Event05 = "o365-event-05"
    case o365Event06 = "o365-event-06"
    case o365Event07 = "o365-event-07"
    case o365Event08 = "o365-event-08"
    case o365Event09 = "o365-event-09"
    case o365Event10 = "o365-event-10"
    case o365Event11 = "o365-event-11"
    case o365Event12 = "o365-event-12"
    case o365Event13 = "o365-event-13"
    case o365Event14 = "o365-event-14"
    case o365Event15 = "o365-event-15"
    case o365Event16 = "o365-event-16"
    case o365Event17 = "o365-event-17"
    case o365Event18 = "o365-event-18"
    case o365Event19 = "o365-event-19"
    case o365Event20 = "o365-event-20"
    case o365Event21 = "o365-event-21"
    case o365Event22 = "o365-event-22"
    case o365Event23 = "o365-event-23"
    case o365Event24 = "o365-event-24"
    case o365Event25 = "o365-event-25"
    case o365Event26 = "o365-event-26"
    case o365Event27 = "o365-event-27"
    case o365Event28 = "o365-event-28"
    case o365Event29 = "o365-event-29"
    case o365Event30 = "o365-event-30"
    case o365Event31 = "o365-event-31"
    case slack = "slack"
    case bing = "bing"
    case playVideo = "play-video"
    case twitterVerified = "twitter-verified"
    case retweeted = "retweeted"
}
