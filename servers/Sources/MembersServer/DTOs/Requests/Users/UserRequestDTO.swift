import Vapor

struct UserRequestDTO: Content {
    let firstName: String
    let lastName: String
    let email: String
    let waiverSignedOn: Date?
    let emergencyName: String?
    let emergencyPhone: String?
    let emergencyEmail: String?
    let paymentMethod: String?
    let phone: String?
    let currentSkills: String?
    let desiredSkills: String?
    let marketingSource: String?
    let exitReason: String?
    let twitterURL: String?
    let facebookURL: String?
    let githubURL: String?
    let websiteURL: String?
    let emailVisible: Bool
    let phoneVisible: Bool
    let postalCode: String?
}

extension UserRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: .count(1...100))
        validations.add("lastName", as: String.self, is: .count(1...100))
        validations.add("email", as: String.self, is: .email && .count(3...254))
        validations.add("emergencyName", as: String.self, is: .count(1...100), required: false)
        validations.add("emergencyPhone", as: String.self, is: .count(10...20), required: false)
        validations.add(
            "emergencyEmail", as: String.self, is: .email && .count(3...254), required: false)
        validations.add("paymentMethod", as: String.self, is: .count(1...50), required: false)
        validations.add("phone", as: String.self, is: .count(10...20), required: false)
        validations.add("currentSkills", as: String.self, is: .count(1...1000), required: false)
        validations.add("desiredSkills", as: String.self, is: .count(1...1000), required: false)
        validations.add("marketingSource", as: String.self, is: .count(1...200), required: false)
        validations.add("exitReason", as: String.self, is: .count(1...500), required: false)
        validations.add(
            "twitterURL", as: String.self,
            is: .count(1...200) && .url
                && .custom(
                    "valid twitter url",
                    validationClosure: { url in
                        return url.contains("twitter.com")
                    }),
            required: false)
        validations.add(
            "facebookURL", as: String.self,
            is: .count(1...200) && .url
                && .custom(
                    "valid facebook url",
                    validationClosure: { url in
                        return url.contains("facebook.com")
                    }),
            required: false)
        validations.add(
            "githubURL", as: String.self,
            is: .count(1...200) && .url
                && .custom(
                    "valid github url",
                    validationClosure: { url in
                        return url.contains("github.com")
                    }),
            required: false)
        validations.add("websiteURL", as: String.self, is: .count(1...200) && .url, required: false)
        validations.add("postalCode", as: String.self, is: .count(3...10), required: false)
    }
}

extension UserRequestDTO {
    func toUser() -> User {
        return User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            waiverSignedOn: waiverSignedOn,
            emergencyName: emergencyName,
            emergencyPhone: emergencyPhone,
            emergencyEmail: emergencyEmail,
            paymentMethod: paymentMethod,
            phone: phone,
            currentSkills: currentSkills,
            desiredSkills: desiredSkills,
            marketingSource: marketingSource,
            exitReason: exitReason,
            twitterURL: twitterURL,
            facebookURL: facebookURL,
            githubURL: githubURL,
            websiteURL: websiteURL,
            emailVisible: emailVisible,
            phoneVisible: phoneVisible,
            postalCode: postalCode
        )
    }

    func updateUser(_ user: User) {
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.waiverSignedOn = waiverSignedOn
        user.emergencyName = emergencyName
        user.emergencyPhone = emergencyPhone
        user.emergencyEmail = emergencyEmail
        user.paymentMethod = paymentMethod
        user.phone = phone
        user.currentSkills = currentSkills
        user.desiredSkills = desiredSkills
        user.marketingSource = marketingSource
        user.exitReason = exitReason
        user.twitterURL = twitterURL
        user.facebookURL = facebookURL
        user.githubURL = githubURL
        user.websiteURL = websiteURL
        user.emailVisible = emailVisible
        user.phoneVisible = phoneVisible
        user.postalCode = postalCode
    }
}
