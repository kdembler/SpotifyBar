import KeychainAccess
import ServiceManagement

let spotifyAccessTokenKeychainId = "spotify_access_token"
let spotifyRefreshTokenKeychainId = "spotify_refresh_token"
let spotifyApiClientKeychainId = "spotify_api_client"
let spotifyApiSecretKeychainId = "spotify_api_secret"

class Store {
    static let shared = Store()

    private var _spotifyAccessToken: String?
    private var _spotifyRefreshToken: String?
    private var _spotifyApiClient: String?
    private var _spotifyApiSecret: String?
    private var _startupEnabled: Bool = false
    private var keychain: Keychain;

    var spotifyAccessToken: String? {
        get {
            _spotifyAccessToken
        }
        set {
            _spotifyAccessToken = newValue
            keychain[spotifyAccessTokenKeychainId] = newValue
        }
    }
    var spotifyRefreshToken: String? {
        get {
            _spotifyRefreshToken
        }
        set {
            _spotifyRefreshToken = newValue
            keychain[spotifyRefreshTokenKeychainId] = newValue
        }
    }
    var spotifyApiClient: String? {
        get {
            _spotifyApiClient
        }
        set {
            _spotifyApiClient = newValue
            keychain[spotifyApiClientKeychainId] = newValue
        }
    }
    var spotifyApiSecret: String? {
        get {
            _spotifyApiSecret
        }
        set {
            _spotifyApiSecret = newValue
            keychain[spotifyApiSecretKeychainId] = newValue
        }
    }
    var startupEnabled: Bool {
        get {
            _startupEnabled
        }
        set {
            _startupEnabled = newValue
            SMLoginItemSetEnabled(launcherIdentifier as CFString, newValue)
        }
    }

    var spotifyApiDetailsSet: Bool {
        get {
            _spotifyApiClient != nil && _spotifyApiSecret != nil
        }
    }

    init() {
        self.keychain = Keychain(service: appIdentifier)
        readAllFields()
    }

    private func readAllFields() {
        _spotifyAccessToken = keychain[spotifyAccessTokenKeychainId]
        _spotifyRefreshToken = keychain[spotifyRefreshTokenKeychainId]
        _spotifyApiClient = keychain[spotifyApiClientKeychainId]
        _spotifyApiSecret = keychain[spotifyApiSecretKeychainId]
        _startupEnabled = readStartupStatus()
    }

    private func readStartupStatus() -> Bool {
        guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
            return false
        }

        let job = jobs.first { $0["Label"] as! String == launcherIdentifier }

        return job?["OnDemand"] as? Bool ?? false
    }
}
