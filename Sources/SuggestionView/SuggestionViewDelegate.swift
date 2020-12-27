import Foundation

public protocol SuggestionViewDelegate: AnyObject {
    func suggestionView(_ suggestionView: SuggestionView, didSelect text: String)
}
