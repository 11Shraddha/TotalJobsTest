// AvatarCellViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import UIKit

class AvatarCellViewModel {
    var gitUrl: String
    var login: String
    var avtarUrl: String
    
    
    init(user: GitUser) {
        self.login = user.login
        self.gitUrl = user.html_url
        self.avtarUrl = user.avatar_url
    }
}
