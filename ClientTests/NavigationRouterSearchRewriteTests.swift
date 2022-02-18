// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import Client

class NavigationRouterSearchRewriteTests: XCTestCase {
    let testString = "testQuery"

    func makeURL(_ url: String) throws -> URL {
        try XCTUnwrap(URL(string: url), "Cannot construct URL from \(url)")
    }

    func makeURLComponents(_ url: String) throws -> URLComponents {
        try XCTUnwrap(URLComponents(string: url), "Cannot construct URL components from \(url)")
    }

    func testGoogle() throws {
        XCTAssertNotNil(
            NavigationPath.maybeRewriteURL(
                try makeURL("https://www.google.com/search?q=\(testString)"),
                try makeURLComponents("https://www.google.com/search?q=\(testString)")
            )
        )
    }

    func testGoogleCA() throws {
        XCTAssertNotNil(
            NavigationPath.maybeRewriteURL(
                try makeURL("https://www.google.ca/search?q=\(testString)"),
                try makeURLComponents("https://www.google.ca/search?q=\(testString)")
            )
        )
    }

    func testYahoo() throws {
        let url =
            "https://search.yahoo.com/search;_ylt=A2KLKi6Zzg1iLIgADQM6ByI5;_ylc=X0kDMDA3bkdERXdMakZfeTFvc1lnM09tUUFuTnpZdU5nQUFBQUF0dEJ5WQRfUwM5NTg1MzEzODYEX3IDMgRhY3RuA2tleWJvYXJkBGNzcmNwdmlkAzAwN25HREV3TGpGX3kxb3NZZzNPbVFBbk56WXVOZ0FBQUFBdHRCeVkEZnIDBGZyMgNzYi10b3AEZ3ByaWQDNWZvNURnVC5Tbk92RVNIaG04UG43QQRuX3JzbHQDMARuX3N1Z2cDMTAEb3JpZ2luA2NhLnNlYXJjaC55YWhvby5jb20EcG9zAzAEcHFzdHIDBHBxc3RybAMwBHFzdHJsAzQEcXVlcnkDdGVzdARzZWMDc2VhcmNoBHNsawNidXR0b24EdDIDc2VhcmNoBHQ0A2tleWJvYXJkBHRfc3RtcAMxNjQ1MDcyMDMxBHZ0ZXN0aWQD?ei=UTF-8&pvid=007nGDEwLjF_y1osYg3OmQAnNzYuNgAAAAAttByY&gprid=&fr=sfp&p=\(testString)"
        XCTAssertNotNil(
            NavigationPath.maybeRewriteURL(
                try makeURL(url),
                try makeURLComponents(url)
            )
        )
    }

    func testBaidu() throws {
        let url =
            "https://www.baidu.com/from=844b/s?word=\(testString)&ts=0&t_kt=0&ie=utf-8&fm_kl=021394be2f&rsv_iqid=3523637623&rsv_t=a2ee48%252Fdyqctl8yfk0HHs3EvHeTMRLVoJXaU1Rukz0fv%252F5RMC5t1EeBEYQ&sa=ib&ms=1&rsv_pq=3523637623&tj=1&rsv_sug4=1645072138140&inputT=1645072140526&sugid=114957450114746&ss=100"
        XCTAssertNotNil(
            NavigationPath.maybeRewriteURL(
                try makeURL(url),
                try makeURLComponents(url)
            )
        )
    }

    func test360() throws {
        let url =
            "https://m.so.com/s?q=\(testString)&src=msearch_next_input&sug_pos=&sug=&nlpv=&ssid=&srcg=home_next"
        XCTAssertNotNil(
            NavigationPath.maybeRewriteURL(
                try makeURL(url),
                try makeURLComponents(url)
            )
        )
    }

    func testSogou() throws {
        let url =
            "https://wap.sogou.com/web/searchList.jsp?from=index&pid=sogou-waps-7880d7226e872b77&t=1645072269031&s_t=1645072275742&s_from=index&pg=webSearchList&inter_index=&keyword=\(testString)&suguuid=cb257b20-1907-4036-b31c-0b5f2066c71d&sugsuv=AAGRqpC8OwAAAAqgKhWrNgIAZAM&sugtime=1645072275742"
        XCTAssertNotNil(
            NavigationPath.maybeRewriteURL(
                try makeURL(url),
                try makeURLComponents(url)
            )
        )
    }
}
