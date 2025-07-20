import UIKit

protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

final class SegmentedProgressBar: UIView {
    // MARK: - Properties
    private var totalSegments: Int
    private var duration: TimeInterval
    private var currentIndex: Int = 0
    private var backgroundBars: [UIView] = []
    private var foregroundBars: [UIView] = []
    private var widthConstraints: [NSLayoutConstraint] = []
    
    weak var delegate: SegmentedProgressBarDelegate?
    
    // MARK: - Init
    init(numberOfSegments: Int, duration: TimeInterval) {
        self.totalSegments = numberOfSegments
        self.duration = duration
        super.init(frame: .zero)
        setupSegments()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSegments() {
        let spacing: CGFloat = 5
        backgroundBars.removeAll()
        foregroundBars.removeAll()
        widthConstraints.removeAll()
        
        for i in 0..<totalSegments {
            let bg = UIView()
            bg.backgroundColor = UIColor.white.withAlphaComponent(0.3) // Gray background
            bg.layer.cornerRadius = 2
            bg.clipsToBounds = true
            bg.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bg)
            backgroundBars.append(bg)
            
            let fg = UIView()
            fg.backgroundColor = .white // White progress
            fg.layer.cornerRadius = 2
            fg.clipsToBounds = true
            fg.translatesAutoresizingMaskIntoConstraints = false
            bg.addSubview(fg)
            foregroundBars.append(fg)
            
            let fgWidthConstraint = fg.widthAnchor.constraint(equalTo: bg.widthAnchor, multiplier: 0)
            widthConstraints.append(fgWidthConstraint)
            
            NSLayoutConstraint.activate([
                bg.topAnchor.constraint(equalTo: topAnchor),
                bg.bottomAnchor.constraint(equalTo: bottomAnchor),
                fg.topAnchor.constraint(equalTo: bg.topAnchor),
                fg.bottomAnchor.constraint(equalTo: bg.bottomAnchor),
                fg.leadingAnchor.constraint(equalTo: bg.leadingAnchor),
                fgWidthConstraint
            ])
            
            if i == 0 {
                bg.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                bg.leadingAnchor.constraint(equalTo: backgroundBars[i - 1].trailingAnchor, constant: spacing).isActive = true
            }
            
            if i == totalSegments - 1 {
                bg.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
            }
            
            bg.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / CGFloat(totalSegments), constant: -spacing).isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure layout is updated
        resetAllSegments()
        if currentIndex < totalSegments {
            for i in 0..<currentIndex {
                widthConstraints[i].constant = backgroundBars[i].bounds.width
            }
        }
    }
    
    // MARK: - Controls
    func startAnimation(at index: Int) {
        guard index >= 0, index < totalSegments else { return }
        currentIndex = index
        resetAllSegments()
        for i in 0..<currentIndex {
            widthConstraints[i].constant = backgroundBars[i].bounds.width
        }
        layoutIfNeeded()
        animateSegment(at: currentIndex)
    }
    
    private func animateSegment(at index: Int) {
        guard index < foregroundBars.count else { return }
        
        let bar = foregroundBars[index]
        bar.layer.removeAllAnimations()
        widthConstraints[index].constant = backgroundBars[index].bounds.width
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            self.layoutIfNeeded()
        }, completion: { [weak self] finished in
            guard let self = self, finished else { return }
            if index < self.totalSegments - 1 {
                self.currentIndex += 1
                self.delegate?.segmentedProgressBarChangedIndex(index: self.currentIndex)
                self.animateSegment(at: self.currentIndex)
            } else {
                self.delegate?.segmentedProgressBarFinished()
            }
        })
    }
    
    func skip() {
        guard currentIndex < foregroundBars.count else { return }
        
        foregroundBars[currentIndex].layer.removeAllAnimations()
        widthConstraints[currentIndex].constant = backgroundBars[currentIndex].bounds.width
        layoutIfNeeded()
        
        if currentIndex < totalSegments - 1 {
            currentIndex += 1
            delegate?.segmentedProgressBarChangedIndex(index: currentIndex)
            animateSegment(at: currentIndex)
        } else {
            delegate?.segmentedProgressBarFinished()
        }
    }
    
    func rewind() {
        guard currentIndex > 0 else { return }
        
        foregroundBars[currentIndex].layer.removeAllAnimations()
        widthConstraints[currentIndex].constant = 0
        currentIndex -= 1
        widthConstraints[currentIndex].constant = 0
        for i in (currentIndex + 1)..<totalSegments {
            widthConstraints[i].constant = 0
        }
        layoutIfNeeded()
        
        delegate?.segmentedProgressBarChangedIndex(index: currentIndex)
        animateSegment(at: currentIndex)
    }
    
    private func resetAllSegments() {
        for constraint in widthConstraints {
            constraint.constant = 0
        }
        layoutIfNeeded()
    }
}
