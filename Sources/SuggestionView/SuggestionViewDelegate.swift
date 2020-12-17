import Foundation

public protocol SuggestionViewDelegate: AnyObject {
    func autocompleteView(_ autocompleteView: SuggestionView, didSelect text: String)
}
