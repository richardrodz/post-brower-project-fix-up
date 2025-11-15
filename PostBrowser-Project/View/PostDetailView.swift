//
//  PostDetailView.swift
//  PostBrowser-Project
//
//  Created by Richard Rodriguez on 11/14/25.
//

import SwiftUI

struct PostDetailView: View {
    var post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(post.title)
                    .font(.title2)
                    .bold()
                Text(post.body)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Detail")
    }
}

