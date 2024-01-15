//
//  MainVC.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 11.01.2024.
//


/*
 Реалізувати додаток для перегляду фотографій з марсоходів використовуючи NASA API
 https://api.nasa.gov/index.html#browseAPI - Mars Rover Photos (auth key можна отримати за формою https://api.nasa.gov (https://api.nasa.gov/) )
 Згідно дизайну - https://www.figma.com/file/hS1HYIVr0lqACogIaZcAIi/Test?type=design&amp;node-id=0%3A1&mode=design&t=cAtOksQkzue9SH2D-1

 - Необхідно дати можливість користувачу обирати тип марсохода, камери та дати.
 - По натисканню на інформацию видображати фулскріново зображення (по можливості кешувати зображення)
 - Результат переглядів зберігати в БД (Realm або CoreData) з можливістю переглянути історію запитів на екрані та використати запит за історії.
 */

import UIKit
import SnapKit
import Lottie

protocol OpenImageDelegate: UIViewController { // sending particular image link from MainVC to FullScreenImageVC
    var delegatedImageURL: URL? { get set }
}

protocol PickerWithToolbarDelegate: AnyObject { // extension of close and done button's methods for picker view
    func onCloseButtonTapped()
    func onDoneButtonTapped(_ title: String?)
}

protocol SendQueryDelegate: AnyObject { // sending queries from roverFilterBtn, cameraFilterBtn and dateFilterBtn to MarsAPIService
    var roverQueryDelegate: String? { get set }
    var cameraQueryDelegate: String? { get set }
    var dateQueryDelegate: String? { get set }
}

class MainVC: UIViewController, OpenImageDelegate, SendQueryDelegate {

    var delegatedImageURL: URL? // OpenImageDelegate variable
    
    var roverQueryDelegate: String?     // SendQueryDelegate variable
    var cameraQueryDelegate: String?    // SendQueryDelegate variable
    var dateQueryDelegate: String?      // SendQueryDelegate variable
        
    private var animationView: LottieAnimationView?
    
    private var roverData: MarsRoverResponseModel?
    
    private let dateLabel = UILabel()
    
    private let photoTableView = UITableView()
    private let roverFilterBtn = UIButton()
    private let cameraFilterBtn = UIButton()
    private let dateFilterBtn = UIButton()
    private let saveFiltersBtn = UIButton()
    
    private var pickerWithToolbar: PickerWithToolbar?
    private var datePickerInstance: CustomDatePicker?

    
    private var roverPicker = UIPickerView()
    private var cameraPicker = UIPickerView()
    private var toolBar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        launchScreen()
    }
    
    private func setupLayout() {
        view.backgroundColor = DS.Colors.backgroundOne
        
        let headerView = UIView()  //Orange header view
        headerView.backgroundColor = DS.Colors.accentOne
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowRadius = 5
        view.addSubview(headerView)
        
        let appTitleNameLabel = UILabel()
        appTitleNameLabel.text = "MARS.CAMERA"
        appTitleNameLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.largeTitle)
        
        dateLabel.text = Methods.dateFormatter.string(from: Date())
        dateLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.body2)

        let headerTitleSV = UIStackView(arrangedSubviews: [appTitleNameLabel, dateLabel])
        headerTitleSV.axis = .vertical
        headerTitleSV.distribution = .fillProportionally
        headerView.addSubview(headerTitleSV)
        
        let btnInsets = DS.SizeOfElements.btnInsets
        
        dateFilterBtn.setImage(DS.Images.calendarIcon, for: .normal)
        dateFilterBtn.addTarget(self, action: #selector(openDatePicker), for: .touchUpInside)
        dateFilterBtn.configuration?.contentInsets = NSDirectionalEdgeInsets(top: btnInsets,
                                                                           leading: btnInsets,
                                                                           bottom: btnInsets,
                                                                           trailing: btnInsets)
        headerView.addSubview(dateFilterBtn)
        
        roverFilterBtn.addTarget(self, action: #selector(openRoverPicker), for: .touchUpInside)
        
        cameraFilterBtn.addTarget(self, action: #selector(openCameraPicker), for: .touchUpInside)
        
        let filterDataArray: [(UIButton, UIImage?, String?)] = [(roverFilterBtn, DS.Images.cpuIcon, "All"),
                                                                (cameraFilterBtn, DS.Images.cameraIcon, "All"),
                                                                (saveFiltersBtn,DS.Images.plusIcon, nil)]
        
        filterDataArray.forEach { filterBtn, img, string in
            filterBtn.layer.cornerRadius = 10
            filterBtn.backgroundColor = DS.Colors.backgroundOne
            filterBtn.setImage(img, for: .normal)
            filterBtn.setTitle(string, for: .normal)
            filterBtn.titleLabel?.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.body2)
            filterBtn.setTitleColor(.black, for: .normal)
        }
        
        [roverFilterBtn, cameraFilterBtn].forEach {
            $0.contentHorizontalAlignment = .leading
            $0.contentEdgeInsets = UIEdgeInsets(top: btnInsets, left: btnInsets, bottom: btnInsets, right: 0)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: btnInsets, bottom: 0, right: 0)
        }
        
        saveFiltersBtn.contentHorizontalAlignment = .center
        saveFiltersBtn.addTarget(self, action: #selector(saveFilters), for: .touchUpInside)
        
        let filterDataSV = UIStackView(arrangedSubviews: [roverFilterBtn, Methods.spacerView(12), cameraFilterBtn, Methods.spacerView(24), saveFiltersBtn])
        filterDataSV.spacing = 0
        headerView.addSubview(filterDataSV)
                
        photoTableView.dataSource = self
        photoTableView.delegate = self
        photoTableView.register(CardTVC.self, forCellReuseIdentifier: CardTVC.reuseIdentifier)
        photoTableView.showsVerticalScrollIndicator = false
        photoTableView.separatorStyle = .none
        view.addSubview(photoTableView)
        
        let historyBtn = UIButton()
        let historyBtnSize: CGFloat = 70
        historyBtn.setImage(DS.Images.historyIcon, for: .normal)
        historyBtn.backgroundColor = DS.Colors.accentOne
        historyBtn.layer.cornerRadius = historyBtnSize / 2
        historyBtn.configuration?.contentInsets = NSDirectionalEdgeInsets(top: btnInsets, leading: btnInsets, bottom: btnInsets, trailing: btnInsets)
        historyBtn.addTarget(self, action: #selector(presentHistoryVC), for: .touchUpInside)
        view.addSubview(historyBtn)
            
        //MARK: - CONSTRAINTS OF MAIN LAYOUT
        
        headerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(view.frame.height / 4.218)
        }
        
        headerTitleSV.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(2)
            $0.leading.equalToSuperview().inset(DS.Paddings.padding)
        }
        
        dateFilterBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(DS.Paddings.padding)
            $0.size.equalTo(DS.SizeOfElements.btnSize)
            $0.centerY.equalTo(headerTitleSV.snp.centerY)
        }
        
        filterDataSV.snp.makeConstraints {
            $0.top.equalTo(headerTitleSV.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(DS.Paddings.padding)
        }
        
        [roverFilterBtn, cameraFilterBtn].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(38)
                $0.width.equalTo(UIScreen.main.bounds.width / 2.8)
            }
        }
        
        saveFiltersBtn.snp.makeConstraints {
            $0.size.equalTo(38)
        }
        
        photoTableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(DS.Paddings.padding)
            $0.horizontalEdges.equalToSuperview().inset(DS.Paddings.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(DS.Paddings.padding)
        }
        
        historyBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(DS.Paddings.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(DS.Paddings.padding)
            $0.size.equalTo(historyBtnSize)
        }
    }
    
    //MARK: - ANIMATION
    
    private func launchScreen() { // Продолжение и анимация Лаунч Скрина
        view.backgroundColor = .white
        let image = DS.Images.launchScreenSquareIcon
        
        let squareIV = UIImageView()
        squareIV.image = image
        view.addSubview(squareIV)
                
        animationView = .init(name: "loader")
        
        guard let animationView = animationView else { return }
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.5
        view.addSubview(animationView)
        
        animationView.play { (finished) in
            if finished {
                squareIV.isHidden = true
                animationView.isHidden = true
                self.setupLayout()
                self.fetch()
            }
        }
    
        //MARK: - CONSTRAINTS OF ANIMATIONS
        
        squareIV.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        animationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100)
            $0.width.equalTo(111)
            $0.height.equalTo(300)
        }
    }

}

//MARK: - TABLEVIEW SETUP

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return roverData?.photos.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTVC.reuseIdentifier, for: indexPath) as? CardTVC else { return UITableViewCell() }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cell.roverImageView.addGestureRecognizer(tapGesture)
        cell.roverData = roverData?.photos[indexPath.section]
        delegatedImageURL = roverData?.photos[indexPath.section].img_src
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
}

//MARK: - Completion of fetch method

extension MainVC {
    private func fetch() {
        MarsAPIService.shared.fetchRoverData { response in
            switch response {
            case .success(let roverData):
                self.roverData = roverData
                self.photoTableView.reloadData()
                print("fetching successed")
            case .failure(let error):
                print(error)
            }
        }
    }
}

//MARK: - @objc METHODS

extension MainVC: PickerWithToolbarDelegate, SendSavedFilterDelegate {
    
    @objc private func imageTapped() {
        let vc = FullScreenImageVC()
        vc.imageDelegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func presentHistoryVC() {
        let vc = HistoryVC()
        vc.sendFilterDelegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func openRoverPicker() {
        roverFilterBtn.isSelected = true
        roverFilterBtn.isUserInteractionEnabled = false
        
        let roverNameDataArray = ["All", "Curiosity", "Opportunity", "Spirit"]

        pickerWithToolbar = PickerWithToolbar(pickerElementsArray: roverNameDataArray)
        
        guard let pickerWithToolbar = pickerWithToolbar else { return }
        roverPicker = pickerWithToolbar.createPickerView(self)
        toolBar = pickerWithToolbar.createToolBar(title: "Rover", self)
        
        pickerWithToolbar.delegate = self
    }
    
    @objc private func openCameraPicker() {
        cameraFilterBtn.isSelected = true
        cameraFilterBtn.isUserInteractionEnabled = false
        
        let cameraNameDataDictionary: [String : String] = [
            "All" : "All",
            "Front Hazard Avoidance Camera" : "FHAZ",
            "Rear Hazard Avoidance Camera" : "RHAZ",
            "Mast Camera" : "MAST",
            "Chemistry and Camera Complex" : "CHEMCAM",
            "Mars Hand Lens Imager" : "MAHLI",
            "Mars Descent Imager" : "MARDI",
            "Navigation Camera" : "NAVCAM",
            "Panoramic Camera" : "PANCAM",
            "Miniature Thermal Emission Spectrometer (Mini-TES)" : "MINITES"]
                
        pickerWithToolbar = PickerWithToolbar(pickerElementsDictionary: cameraNameDataDictionary)
                
        guard let pickerWithToolbar = pickerWithToolbar else { return }
        cameraPicker = pickerWithToolbar.createPickerView(self)
        toolBar = pickerWithToolbar.createToolBar(title: "Camera", self)
        
        pickerWithToolbar.delegate = self
    }
    
    @objc private func openDatePicker() {
        dateFilterBtn.isSelected = true
        
        datePickerInstance = CustomDatePicker()
        
        guard let datePickerInstance = datePickerInstance else { return }
        datePickerInstance.addBlur(self)
        
        _ = datePickerInstance.createDatePicker(self)
        _ = datePickerInstance.createToolBar(title: "Date", self)
        
        datePickerInstance.delegate = self
        
    }
    
    @objc private func saveFilters() {
        let roverName = self.roverFilterBtn.titleLabel?.text
        let cameraName = self.cameraFilterBtn.titleLabel?.text
        let date = self.datePickerInstance?.datePicker?.date
        
        let saveFilterAlert = UIAlertController(title: "Save Filters",
                                                message: "The current filters and the date you have chosen can be saved to the filter history.",
                                                preferredStyle: .alert)
        
        saveFilterAlert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { _ in
            
            switch (roverName, cameraName, date) {
            case (nil, nil, nil):
                RealmService.addBrowseToRealm(roverName: "All", cameraName: "All", date: Date())
            case (nil, nil, let date?):
                RealmService.addBrowseToRealm(roverName: "All", cameraName: "All", date: date)
            case (nil, let cameraName?, nil):
                RealmService.addBrowseToRealm(roverName: "All", cameraName: cameraName, date: Date())
            case (let roverName?, nil, nil):
                RealmService.addBrowseToRealm(roverName: roverName, cameraName: "All", date: Date())
            case (let roverName?, let cameraName?, nil):
                RealmService.addBrowseToRealm(roverName: roverName, cameraName: cameraName, date: Date())
            case (let roverName?, nil, let date?):
                RealmService.addBrowseToRealm(roverName: roverName, cameraName: "All", date: date)
            case (nil, let cameraName?, let date?):
                RealmService.addBrowseToRealm(roverName: "All", cameraName: cameraName, date: date)
            case (let roverName?, let cameraName?, let date?):
                RealmService.addBrowseToRealm(roverName: roverName, cameraName: cameraName, date: date)
            }
            
        }))
        
        saveFilterAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(saveFilterAlert, animated: true)
    }
    
    //MARK: - SendSavedFilterDelegate Method
    
    func sendSavedFilter(roverName: String, cameraName: String, date: Date) {
        roverFilterBtn.setTitle(roverName, for: .normal)
        roverQueryDelegate = roverName
        
        cameraFilterBtn.setTitle(cameraName, for: .normal)
        cameraQueryDelegate = cameraName
        
        dateLabel.text = Methods.dateFormatter.string(from: date)
        
        dateQueryDelegate = date.description

        MarsAPIService.shared.queryDelegate = self
        fetch()
    }

    //MARK: - PickerWithToolbarDelegate Methods
    
    func onCloseButtonTapped() { // PickerWithToolbarDelegate method
        roverFilterBtn.isUserInteractionEnabled = true
        cameraFilterBtn.isUserInteractionEnabled = true
    }
    
    func onDoneButtonTapped(_ title: String?) { // PickerWithToolbarDelegate method
        if roverFilterBtn.isSelected {
            roverFilterBtn.isUserInteractionEnabled = true
            roverFilterBtn.setTitle(title, for: .normal)
            roverQueryDelegate = title
            MarsAPIService.shared.queryDelegate = self
            roverFilterBtn.isSelected = false
            fetch()
        }
        
        if cameraFilterBtn.isSelected {
            cameraFilterBtn.isUserInteractionEnabled = true
            cameraFilterBtn.setTitle(title, for: .normal)
            cameraQueryDelegate = title
            MarsAPIService.shared.queryDelegate = self
            cameraFilterBtn.isSelected = false
            fetch()
        }
        
        if dateFilterBtn.isSelected {
            dateLabel.text = Methods.dateFormatter.string(from: datePickerInstance?.datePicker?.date ?? Date() )
            dateQueryDelegate = datePickerInstance?.datePicker?.date.description
            MarsAPIService.shared.queryDelegate = self
            dateFilterBtn.isSelected = false
            fetch()
        }
    }
}
