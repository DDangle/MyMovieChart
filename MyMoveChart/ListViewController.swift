//
//  ListViewController.swift
//  MyMoveChart
//
//  Created by 한규철 on 3/24/R4.
//

import UIKit

class ListViewController: UITableViewController {
    
    var page = 1
 
    
    
    //테이블 뷰를 구성할 리스트 데이터
    lazy var list: [MovieVO] = {
        var datalist = [MovieVO]()
        return datalist
    }()
    //더보기 버튼을 눌럿을때 호출되는 메소드
    @IBAction func more(_ sender: Any) {
        //현재 페이지 값에 1추가
        self.page += 1
        //영화차트 API를 호출한다.
        self.callMovieAPI()
        //데이터를 다시 읽어오도록 테이블 뷰를 갱신한다.
        self.tableView.reloadData()
    }
    
    //뷰가 처음 메모리에 로드될때 호출되는 메소드
    override func viewDidLoad() {
        //영화차트 API를 호출한다.
        self.callMovieAPI()
    }
    
    //영화 차트 API를 호출해주는 메소드
    func callMovieAPI() {
        
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=1&count=30&genreId=&order=releasedateasc"
        let apiURI: URL! = URL(string: url)
        print("apiURI : \(apiURI)")
        let apidata = try! Data(contentsOf: apiURI)
        
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue)
        
        NSLog("API Result=\(log)")
        
        //json 객체를 파싱하여 NSDictionary 객체로 변환
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: [] ) as! NSDictionary
            
            //데이터 구조에 따라 차례대로 캐스팅하며 읽어온다.
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            
            //순회 처리를 하면서 API 데이터를 MovieVo 객체에 저장한다
            for row in movie {
                //  순회 상수를 NSDictionary 타입으로 캐스팅
                let r = row as! NSDictionary
                
                //테이블 뷰 리스트를 구성할 데이터 형식
                let mvo = MovieVO()
                
                //movie 배열의 각 데이터를 mvo 상수의 속성에 대입
                mvo.title = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail = r["thumbnailImage"] as? String
                mvo.detail = r["linkUrl"] as? String
                mvo.rating = r["ratingAverage"] as? Double
                
                //웹상에 있는 이미지를 읽어와 UIImage 객체로 생성
                let url: URL! = URL(string: mvo.thumbnail!)
                let imageData = try! Data(contentsOf: url)
                mvo.thumbnailImage = UIImage(data:imageData)
                
                //list 배열에 추가
                self.list.append(mvo)
                //데이터를 다시 읽어오도록 테이블 뷰를 갱신한다.
                self.tableView.reloadData()
                
                //전체 데이터 카운트를 얻는다.
                let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue
                //totalCount가 읽어온 데이터 크기와 같거나 클 경우 더보기 버튼을 막는다.
                if (self.list.count >= totalCount) {
//                    self.moreBtn.isHidden = true
                }
            }
        } catch {}
            NSLog("Parse Error!!")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 주어진 행에 맞는 데이터소스를 읽어온다.
        let row = self.list[indexPath.row]
        
        
        //로그 출력
        NSLog("제목:\(row.title!),호출된 행번호:\(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        
        cell.title?.text = row.title
        cell.desc?.text = row.description
        cell.opendate?.text = row.opendate
        cell.rating?.text = "\(row.rating ?? 0.0)"
        
        
        //비동기 방식으로 섬네일 이미지를 읽어옴
        DispatchQueue.main.async(execute: {
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        })
    
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다")
        
        let row = indexPath.row
        
        //API영화 데이터 배열 중에서 선택된 행에 대한 데이터를 추출한다.
        let movieinfo = self.list[row]
        
        //행정보를 통해 선택된 영화 데이터를 찾은 다음, 목적지 뷰 컨트롤러의 mvo변수에 대입한다.
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.mvo = self.list[row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getThumbnailImage(_ index: Int) -> UIImage {
        //인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        
        let mvo = self.list[index]
        
        //메모이제이션 : 저장된 이미지가 있으면 그것을 반환하고, 없을 경우 내려받아 저장한 후 반환
        if let savedImage = mvo.thumbnailImage {
            return savedImage
        } else {
            let url: URL! = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data: imageData) //UIImage MovieVO 객체에 우선 저장
            
            return mvo.thumbnailImage! //저장된 이미지를 반환
            
        }
    }
       
}
