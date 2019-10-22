import UIKit

final class AnimationListViewController: UITableViewController {
    private var scenes: [Scene]!
    private let cellIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        scenes = allScenes()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        scenes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = String(indexPath.item)
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ViewController(scene: scenes[indexPath.item])
        vc.navigationItem.title = String(indexPath.item)
        navigationController?.pushViewController(vc, animated: true)
    }
}
