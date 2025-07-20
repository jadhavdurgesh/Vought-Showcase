
import UIKit

final class CarouselViewController: UIViewController {
    private let items: [CarouselItem]
    private var currentIndex: Int = 0

    private var progressBar: SegmentedProgressBar!
    private let containerView = UIView()

    init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        showController(at: currentIndex)
        progressBar.startAnimation(at: currentIndex)
    }

    private func setupUI() {
        progressBar = SegmentedProgressBar(numberOfSegments: items.count, duration: 5) // Changed to 5 seconds
        progressBar.delegate = self
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressBar)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 4),

            containerView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let leftTap = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))

        let leftView = UIView()
        leftView.translatesAutoresizingMaskIntoConstraints = false
        leftView.backgroundColor = .clear
        view.addSubview(leftView)

        NSLayoutConstraint.activate([
            leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftView.topAnchor.constraint(equalTo: view.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])

        let rightView = UIView()
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.backgroundColor = .clear
        view.addSubview(rightView)

        NSLayoutConstraint.activate([
            rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightView.topAnchor.constraint(equalTo: view.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])

        leftView.addGestureRecognizer(leftTap)
        rightView.addGestureRecognizer(rightTap)
        
        // Add swipe-down gesture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    private func showController(at index: Int) {
        guard index >= 0, index < items.count else { return }

        let newVC = items[index].getController()

        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(newVC.view)

        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        newVC.didMove(toParent: self)
    }

    @objc private func handleRightTap() {
        print("Debug: Right tap detected")
        if currentIndex < items.count - 1 {
            progressBar.skip()
        }
    }

    @objc private func handleLeftTap() {
        print("Debug: Left tap detected")
        if currentIndex > 0 {
            progressBar.rewind()
        }
    }
    
    @objc private func handleSwipeDown() {
        print("Debug: Swipe down detected")
        currentIndex = 0
        showController(at: currentIndex)
        progressBar.startAnimation(at: currentIndex)
    }
}

extension CarouselViewController: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        print("Debug: Progress bar changed to index \(index)")
        currentIndex = index
        showController(at: index)
    }

    func segmentedProgressBarFinished() {
        print("Debug: Progress bar finished")
        currentIndex = 0
        showController(at: currentIndex)
        progressBar.startAnimation(at: currentIndex)
    }
}
