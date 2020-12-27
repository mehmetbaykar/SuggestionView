import Foundation

public protocol SuggestionViewDataSource: AnyObject {
   
    func suggestionView(_ suggestionView: SuggestionView, elementsFor text: String, completion: @escaping ([String]) -> Void)
}
