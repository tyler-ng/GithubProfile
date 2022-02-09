//
//  FollowerViewController.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit
import Kingfisher

class FollowersViewController: UIViewController {
    
    @IBOutlet weak var followersTableView: UITableView!
    private let viewModel = ViewModel()
    private var error: OpenNewError?
    private var followers: [Follows]?
    private let refreshControl = UIRefreshControl()
    var followers_url: String?
    var selectedIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure the link's value is not nil
        guard let followers_url = followers_url else {
            return
        }
        
        // fetch followers data
        viewModel.fetchFollowsData(followers_url)
        
        // set value for UI navigation title
        self.title = "Followers"
        
        // set delegate and datasource for followersTableView
        followersTableView.delegate = self
        followersTableView.dataSource = self
        
        
        // register a Xib view for the followersTableView's cell
        self.followersTableView.register(UINib(nibName: "ListItemView", bundle: nil), forCellReuseIdentifier: CellIdentifiers.listItemCell.rawValue)
        
        // update value of error variable from view model after finishing the networking request
        viewModel.errorStore.bind { [weak self] error in
            guard let error = error else {
                return
            }
            self?.error = error
            
            if error == OpenNewError.userNotFound {
                self?.followersTableView.removeFromSuperview()
                
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
            guard let followers = follows else {
                return
            }
            
            self?.followers = followers
            
            // update the table view with new data
            self?.followersTableView.reloadData()
            
            // end refreshing activity after data replacement
            if self!.refreshControl.isRefreshing {
                self?.refreshControl.endRefreshing()
            }
        }
        
        // add refresh controll to the tableview
        if #available(iOS 10.0, *) {
            followersTableView.refreshControl = refreshControl
        } else {
            followersTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(pullToRefreshFollowersData(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        
        // find a previous selected cell to clear it's seletect background view color
        // when navigating back to the following tableview from the user profile view
        let listItemView = followersTableView.cellForRow(at: selectedIndexPath) as? ListItemView
        
        guard let listItemView = listItemView else { return }
        // the previous selected cell wasn't selected any more
        listItemView.isSelected = false
        followersTableView.reloadData()
    }
    
    @objc func pullToRefreshFollowersData(_ sender: Any) {
        guard let followers_url = followers_url else {
            return
        }

        viewModel.fetchFollowsData(followers_url)
    }
}

extension FollowersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // retain a IndexPath value of the selected row
        // for clearing the selected background color later
        self.selectedIndexPath = indexPath
        
        // check to make sure username is valid before passing it the next view controller
        guard let username = followers?[indexPath.row].username else { return }
        
        // init storyboard to init a destination view controller instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        destinationVC.username = username
        
        // navigate to the destination view controller
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension FollowersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.listItemCell.rawValue, for: indexPath) as! ListItemView
        
        guard let followers = followers else { return cell }
        
        // get a follower object by an index path row
        let followerItem = followers[indexPath.row]
        
        // hide skeleton
        cell.hideSkeleton()
        
        let selectedView = UIView()
        selectedView.backgroundColor = .systemGray2
        cell.selectedBackgroundView = selectedView
        
        // check the validation of avatar url
        if URLHandler.verifyURL(followerItem.avatar_url) {
            let avatarURL = URL(string: followerItem.avatar_url)
            // render an avatar image on cell
            cell.avatarImageView.kf.setImage(with: avatarURL)
        }
    
        // set username label
        cell.usernameLabel.text = followerItem.username
        
        return cell
    }
}
