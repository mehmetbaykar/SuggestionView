import Foundation

public protocol SuggestionViewDataSource: AnyObject {
   
    func autocompleteView(_ autocompleteView: SuggestionView, elementsFor text: String, completion: @escaping ([String]) -> Void)
}
