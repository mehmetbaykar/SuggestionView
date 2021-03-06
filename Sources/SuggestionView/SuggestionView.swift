import UIKit

fileprivate let SEARCH_BAR_TEXT_CLEANED = "searchBarTextCleaned"

open class SuggestionView: UIView {
    // MARK: - Public Properties
    
    public weak var dataSource: SuggestionViewDataSource?
    public weak var delegate: SuggestionViewDelegate?
    
    public var throttleTime: TimeInterval = 0.4
    
    public var shouldHideAfterSelecting = true
    
    public var textAttributes: [NSAttributedString.Key: Any]?
    
    public weak var textField: UITextField? {
        didSet {
            guard let textField = textField else {
                return
            }
            textField.addTarget(self, action: #selector(textFieldEditingBegin), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldEditingEnded), for: .editingDidEnd)
            setupConstraints()
        }
    }
    
    public var suggestionViewCell: SuggestionViewTableViewCell.Type? {
        didSet {
            guard let suggestionViewCell = suggestionViewCell else {
                return
            }
            
            tableView.register(suggestionViewCell, forCellReuseIdentifier: SuggestionView.cellIdentifier)
            tableView.reloadData()
        }
    }
    
    public var rowHeight: CGFloat = 40.0 {
        didSet {
            tableView.rowHeight = rowHeight
        }
    }
    
    open override var backgroundColor: UIColor?{
        didSet{
            self.tableView.backgroundColor = backgroundColor
        }
    }
    
    // MARK: - Private Properties
    
    private let tableView = UITableView()
    private var heightConstraint: NSLayoutConstraint?
    private static let cellIdentifier = "SuggestionViewCellIdentifier"
    private var elements = [String]() {
        didSet {
            tableView.reloadData()
            superview?.layoutIfNeeded()
            tableView.scrollToTop(animated: true)
        }
    }
    
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Functions
    
    private func commonInit() {
        addSubview(tableView)
        attachTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldEditingChanged), name: NSNotification.Name(rawValue: SEARCH_BAR_TEXT_CLEANED), object: nil)
    }
    
    private func attachTableView(){
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SuggestionView.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = rowHeight
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white
        tableView.contentInset = .zero
        tableView.bounces = true
        tableView.allowsMultipleSelection = false
        
    }
    private func setupConstraints() {
        guard let textField = textField else {
            assertionFailure("no textfield found")
            return
        }
        
        guard let attachedSuperView  = superview else{
            assertionFailure("no super view found")
            return
        }
        
        tableView.removeConstraints(tableView.constraints)
        removeConstraints(self.constraints)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        
        let constraints = [
            leadingAnchor.constraint(equalTo: attachedSuperView.leadingAnchor),
            trailingAnchor.constraint(equalTo: attachedSuperView.trailingAnchor),
            topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10.0),
            bottomAnchor.constraint(equalTo: attachedSuperView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.heightAnchor.constraint(equalTo: heightAnchor)
        ]
        self.isHidden = true
        NSLayoutConstraint.activate(constraints)
        attachedSuperView.bringSubviewToFront(attachedSuperView)
    }
    
    @objc private func textFieldEditingChanged() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getElements), object: nil)
        perform(#selector(getElements), with: nil, afterDelay: throttleTime)
    }
    
    @objc private func getElements() {
        guard let dataSource = dataSource else {
            return
        }
        
        guard let text = textField?.text, !text.isEmpty else {
            elements.removeAll()
            return
        }
        
        dataSource.suggestionView(self, elementsFor: text) { [weak self] elements in
            self?.elements = elements
        }
    }
    
    @objc private func textFieldEditingEnded() {
        self.popUpView(show: false)
        self.tableView.reloadData()
        self.elements.removeAll()
    }
    
    @objc private func textFieldEditingBegin() {
        self.popUpView(show: true)
        self.textFieldEditingChanged()
        
    }
}
// MARK: - UITableViewDataSource

extension SuggestionView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !(textField?.text?.isEmpty ?? true) ? elements.count : 0
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionView.cellIdentifier) else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        
        guard indexPath.row < elements.count else {
            assertionFailure("Sanity check")
            return cell
        }
        
        let text = elements[indexPath.row]
        
        guard suggestionViewCell != nil, let customCell = cell as? SuggestionViewTableViewCell  else {
            cell.textLabel?.attributedText = NSAttributedString(string: text, attributes: textAttributes)
            cell.selectionStyle = .default
            cell.backgroundColor = self.backgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 1.0, bottom: 0, right: 0)
            
            return cell
        }
        
        customCell.set(text: text)
        
        return customCell
    }
}

// MARK: - UITableViewDelegate

extension SuggestionView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < elements.count else {
            assertionFailure("Indexpath could not be smaller than the element's count")
            return
        }
        
        if shouldHideAfterSelecting {
            self.popUpView(show: false)
        }
        textField?.text = elements[indexPath.row]
        delegate?.suggestionView(self, didSelect: elements[indexPath.row])
    }
}
