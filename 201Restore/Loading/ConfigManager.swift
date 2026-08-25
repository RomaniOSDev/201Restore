//
//  ConfigManager.swift
//  1TrulbargrovarStrinel
//
//  Запрос к эндпоинту конфига: сбор тела (конверсия AppsFlyer + af_id, bundle_id, os, store_id, locale, опционально push_token, firebase_project_id),
//  POST, разбор ответа, сохранение url и expires.
//

import Foundation
import AppsFlyerLib

/// Ответ эндпоинта конфига
struct ConfigResponse {
    let statusCode: Int
    let ok: Bool
    let url: String?
    let expires: Int64?
    let message: String?
}

/// Ключи для сохранения url и expires
enum ConfigManagerKeys {
    static let savedURL = "ConfigManagerSavedURL"
    static let savedExpires = "ConfigManagerSavedExpires"
}

/// Провайдер опциональных данных (Firebase). Установите из AppDelegate при инициализации Firebase.
enum ConfigManagerOptionalData {
    static var pushToken: String?
    static var firebaseProjectId: String?
}

/// Менеджер запроса конфига: формирует тело, отправляет POST, сохраняет url/expires.
final class ConfigManager {

    static let shared = ConfigManager()

    /// URL эндпоинта конфига.
    var configEndpointURL: URL? = URL(string: "https://golyntys-zestore.com/config.php")

    /// Store ID приложения (iOS — с префиксом "id"). 
    var storeId: String = "id6792845978"

    private init() {}

    // MARK: - Сохранённые url и expires

    var savedURL: URL? {
        guard let raw = UserDefaults.standard.string(forKey: ConfigManagerKeys.savedURL) else { return nil }
        return URL(string: raw)
    }

    var savedExpires: Int64? {
        guard let raw = UserDefaults.standard.object(forKey: ConfigManagerKeys.savedExpires) else { return nil }
        let value: Int64?
        if let n = raw as? NSNumber {
            value = n.int64Value
        } else if let n = raw as? Int64 {
            value = n
        } else if let n = raw as? Int {
            value = Int64(n)
        } else {
            value = nil
        }
        return value.map(Self.normalizedExpires)
    }

    /// Ссылка действительна, если сохранена и expires ещё больше текущего unix-времени устройства (секунды).
    var isSavedURLValid: Bool {
        guard savedURL != nil, let exp = savedExpires else { return false }
        return exp > Int64(Date().timeIntervalSince1970)
    }

    /// Unix seconds. Values that look like milliseconds are converted.
    static func normalizedExpires(_ exp: Int64) -> Int64 {
        exp > 9_999_999_999 ? exp / 1000 : exp
    }

    private func saveResponse(url: String, expires: Int64?) {
        UserDefaults.standard.set(url, forKey: ConfigManagerKeys.savedURL)
        if let expires {
            UserDefaults.standard.set(Self.normalizedExpires(expires), forKey: ConfigManagerKeys.savedExpires)
        } else {
            UserDefaults.standard.removeObject(forKey: ConfigManagerKeys.savedExpires)
        }
        UserDefaults.standard.synchronize()
    }

    // MARK: - Формирование тела запроса

    /// Собирает JSON тела запроса: данные конверсии (без изменений) + af_id, bundle_id, os, store_id, locale; при наличии — push_token, firebase_project_id.
    func buildRequestBody() -> Data? {
        var body: [String: Any] = [:]

        // Данные конверсии (и UDL) — все параметры в неизменённом виде
        if let conversionString = AppsFlyerManager.shared.conversionDataString,
           let data = conversionString.data(using: .utf8),
           let conversion = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for (key, value) in conversion {
                body[key] = value
            }
        }

        // Дополнительные параметры (не перезаписываем существующие ключи из конверсии)
        if body["af_id"] == nil {
            body["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        }
        if body["bundle_id"] == nil {
            body["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        }
        if body["os"] == nil {
            body["os"] = "iOS"
        }
        if body["store_id"] == nil {
            body["store_id"] = storeId
        }
        if body["locale"] == nil {
            body["locale"] = Locale.current.identifier
        }
        if let token = ConfigManagerOptionalData.pushToken, body["push_token"] == nil {
            body["push_token"] = token
        }
        if let projectId = ConfigManagerOptionalData.firebaseProjectId, body["firebase_project_id"] == nil {
            body["firebase_project_id"] = projectId
        }

        return try? JSONSerialization.data(withJSONObject: body)
    }

    // MARK: - Запрос к конфигу

    /// Выполняет POST к эндпоинту конфига. При HTTP 200 сохраняет url и expires.
    func requestConfig(completion: @escaping (Result<ConfigResponse, Error>) -> Void) {
        guard let endpoint = configEndpointURL else {
            completion(.failure(ConfigError.missingEndpoint))
            return
        }
        guard let body = buildRequestBody() else {
            completion(.failure(ConfigError.failedToBuildBody))
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 10

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            let http = response as? HTTPURLResponse
            let statusCode = http?.statusCode ?? 0
            let parsed = self?.parseConfigResponse(data: data, statusCode: statusCode) ?? .failure(ConfigError.invalidResponse)
            if case .success(let config) = parsed, config.statusCode == 200, let url = config.url, !url.isEmpty {
                self?.saveResponse(url: url, expires: config.expires)
            }
            DispatchQueue.main.async {
                switch parsed {
                case .success(let c):
                    completion(.success(c))
                case .failure(let e):
                    completion(.failure(e))
                }
            }
        }
        task.resume()
    }

    private func parseConfigResponse(data: Data?, statusCode: Int) -> Result<ConfigResponse, Error> {
        guard let data = data else {
            return .failure(ConfigError.invalidResponse)
        }
        let ok = (statusCode == 200)
        var url: String?
        var expires: Int64?
        var message: String?
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let s = json["url"] as? String {
                let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
                url = trimmed.isEmpty ? nil : trimmed
            }
            expires = Self.parseExpires(json["expires"])
            message = json["message"] as? String
        }
        return .success(ConfigResponse(statusCode: statusCode, ok: ok, url: url, expires: expires, message: message))
    }

    private static func parseExpires(_ raw: Any?) -> Int64? {
        guard let raw else { return nil }
        let value: Int64?
        if let n = raw as? NSNumber {
            value = n.int64Value
        } else if let n = raw as? Int64 {
            value = n
        } else if let n = raw as? Int {
            value = Int64(n)
        } else if let d = raw as? Double {
            value = Int64(d)
        } else if let s = raw as? String {
            value = Int64(s.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            value = nil
        }
        return value.map(normalizedExpires)
    }
}

enum ConfigError: LocalizedError {
    case missingEndpoint
    case failedToBuildBody
    case invalidResponse
    var errorDescription: String? {
        switch self {
        case .missingEndpoint: return "Config endpoint URL not set"
        case .failedToBuildBody: return "Failed to build request body"
        case .invalidResponse: return "Invalid config response"
        }
    }
}
