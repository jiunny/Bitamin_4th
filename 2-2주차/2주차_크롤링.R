install.packages("RSelenium")
install.packages("rvest")
library(RSelenium)
library(rvest)
url_base <- "https://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code=161967&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page="

#주소설정
url<-paste(url_base,1,sep='')
#html 읽어오기
htxt<-read_html(url,encoding="UTF-8")
#node 읽기
table<-html_nodes(htxt,".score_result") 
content<-html_nodes(table,".score_reple")
content2<-
  html_nodes(content,paste("#_filtered_ment_",1,sep=''))
#text읽기
reviews<-html_text(content2) ; reviews

all.reviews<-c()
for(page in 1:10){
  for(num in 1:9){
    url<-paste(url_base,page,sep='')
    htxt<-read_html(url,encoding="UTF-8")
    table<-html_nodes(htxt,".score_result")
    content<-html_nodes(table,".score_reple")
    content2<-html_nodes(content,paste("#_filtered_ment_",num,sep=''))
    reviews<-html_text(content2)
    if(length(reviews)==0){break}
    all.reviews<-c(all.reviews,reviews)
    print(page)
  }
}

all.reviews <- gsub("[[:cntrl:]]","",all.reviews)

remDr<-
  remoteDriver(port=4445,browserName="chrome")
remDr$open()
remDr$navigate("http://www.naver.com")

blogButton<-
  remDr$findElement(using="xpath",
                    value='//*[@id="PM_ID_ct"]/div[1]/div[2]/div[1]/ul[1]/li[3]/a/span[1]')
blogButton$clickElement()

webElemButton<-
  remDr$findElement(using="css selector",
                    value='#header > div.header_common > div > div.area_search > form > fieldset > div > input')
webElemButton$sendKeysToElement(list(key='shift',key='home',key='delete'))
webElemButton$sendKeysToElement(list('최지은'))
clickbutton <- remDr$findElement(using = 'xpath',
                                 value='//*[@id="header"]/div[1]/div/div[2]/form/fieldset/a[1]/i')
clickbutton$clickElement()

html <- read_html(remDr$getPageSource()[[1]]);Sys.sleep(1)
content <- html_nodes(html,'.search_number')
num <- html_text(content)
num

remDr$closeall()
remDr$closeServer()
