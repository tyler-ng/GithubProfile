//
//  FollowingViewController.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit

class FollowingViewController: UIViewController {
    
    @IBOutlet weak var followingTableView: UITableView!
    private let viewModel = ViewModel()
    private var error: OpenNewError?
    private var following: [Follows]?
    private let refreshControl = UIRefreshControl()
    var following_url: String?
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure the link's value is not nil
        guard let following_url = following_url else {
            return
        }
        
        // fetch following data
        viewModel.fetchFollowsData(following_url)
        
        // set value for UI navigation title
        self.title = "Following"
        
        // set delegate and datasource for followingTableViews
        followingTableView.delegate = self
        followingTableView.dataSource = self
        
        // register a Xib view for the followersTableView's cell
        self.followingTableView.register(UINib(nibName: "ListItemView", bundle: nil), forCellReuseIdentifier: CellIdentifiers.listItemCell.rawValue)
        
        // update value of error variable from view model after finishing the networking request
        viewModel.errorStore.bind { [weak self] error in
            guard let error = error else {
                return
            }
            self?.error = error
            
            if error == OpenNewError.userNotFound {
                self?.followingTableView.removeFromSuperview()
                
                // init an instance of UserNotFoundView if any user profile not found
                let userNotFoundView = UIView.instanceFromNib(nibView: "UserNotFoundView") as! UserNotFoundView
                userNotFoundView.textLabel.text = "Data not found"
                // add a view instance to its superview
                self?.view.addSubview(userNotFoundView)
                
                // make the subview frame in line with its superview
                userNotFoundView.frame = userNotFoundView.superview!.bounds
            }
        }
        
        // update value if followers variable from view model after finishing the networking request
        viewModel.followsStore.bind { [weak self] follows in
            guard let following = follows else {
                return
            }
            self?.following = following
            
            // update the table view with new data
            self?.followingTableView.reloadData()
            
            // end refreshing activity after data replacement
            if self!.refreshControl.isRefreshing {
                self?.refreshControl.endRefreshing()
            }
        }
        
        // add refresh controll to the tableview
        if #available(iOS 10.0, *) {
            followingTableView.refreshControl = refreshControl
        } else {
            followingTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(pullToRefreshFollowingData(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        
        // find a previous selected cell to clear it's seletect background view color
        // when navigating back to the following tableview from the user profile view
        let listItemView = followingTableView.cellForRow(at: selectedIndexPath) as? ListItemView
        
        guard let listItemView = listItemView else { return }
        // the previous selected cell wasn't selected any more
        listItemView.isSelected = false
        followingTableView.reloadData()
    }
    
    @objc func pullToRefreshFollowingData(_ sender: Any) {
        guard let following_url = following_url else {
            return
        }

        viewModel.fetchFollowsData(following_url)
    }
}

extension FollowingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // retain a IndexPath value of the selected row
        // for clearing the selected background color later
        self.selectedIndexPath = indexPath
        
        // check to make sure username is valid before passing it the next view controller
        guard let username = following?[indexPath.row].username else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        destinationVC.username = username
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension FollowingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.listItemCell.rawValue, for: indexPath) as! ListItemView
        
        guard let following = following else { return cell }
        
        // get a following object by an index path row
        let followingItem = following[indexPath.row]
        
        // hide skeleton
        cell.hideSkeleton()
        
        // check the validation of avatar url
        if URLHandler.verifyURL(followingItem.avatar_url) {
            let avatarURL = URL(string: followingItem.avatar_url)
            // render an avatar image on cell
            cell.avatarImageView.kf.setImage(with: avatarURL)
        }
        
        // set username label
        cell.usernameLabel.text = followingItem.username
        
        return cell
    }
}
