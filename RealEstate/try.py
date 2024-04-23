# import the necessary libraries
import requests
import multiprocessing 
import time
import pandas as pd 
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from datetime import date
import codecs
import sys
import multiprocessing
import math
import concurrent.futures



# Receive page from a threaded chunker 
# gets all rental ads on the current page and returns them
def pageListingsScrapper(page):
    print(page)
    pageListings = []

    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument("--log-level=3")
    options.add_argument('--ignore-certificate-errors-spki-list')
    options.add_argument('--ignore-ssl-errors')

    driver=webdriver.Chrome(options=options)
         
    driver.get(page)
    driver.implicitly_wait(5)
    # time.sleep(5)
    postingList = driver.find_element(By.XPATH, ".//*[@id='base-layout-main-wrapper']/div[4]/div[4]/div[2]/div[3]/ul")
    listings = postingList.find_elements(By.XPATH, ".//li[starts-with(@data-testid, 'listing-card-list-item-')]")
    
    
    for listing in listings:
        page = listing.find_element(By.XPATH, ".//section/div[1]/div[2]/div[1]/h3/a")
        pageUrl = page.get_attribute("href")
        pageListings.append(pageUrl)

    driver.close()
    return pageListings
        


# This function serves as the distributor of tasks
# 1.Starts by collecting the number of pages the desired search criteria has
# 2.Creates a list of pages from the total number collected
# 3.Sends each page to the pageListing function via concurrent threading (needs work still super slow)
# 4.After all rental links are collected (usually a lot)
# 5.Sends the links to dataListings function to collect the actual needed for future analisation via concurrent threading (again needs work super slow)
# 6.The data collected is return as a list of dictionaries and the made into a dataframe before being saved as a CSV file.
def chunker():

    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--log-level=3')
    options.add_argument('--ignore-certificate-errors-spki-list')
    options.add_argument('--ignore-ssl-errors')

    driver=webdriver.Chrome(options=options)
    
    mainURL = "https://www.kijiji.ca/b-apartments-condos/gta-greater-toronto-area/page-1/c37l1700272?price=900__3000&size-sqft=600__900"
    
    
    driver.get(mainURL)
    driver.implicitly_wait(5)
    # time.sleep(5)
    try:
        numOfPages = driver.find_element(By.XPATH, "//*[@id='base-layout-main-wrapper']/div[4]/div[4]/div[2]/div[3]/div[starts-with(@class, 'sc-63c588db-0')]/div[1]/nav/ul/li[last()-1]/a").text
        
    #     //*[@id="base-layout-main-wrapper"]/div[4]/div[4]/div[2]/div[3]/div[2]/div[1]/nav/ul
    # //*[@id="base-layout-main-wrapper"]/div[4]/div[4]/div[2]/div[3]/div[3]/div[1]/nav/ul
    # #base-layout-main-wrapper > div.sc-fd760fa7-0.hnfPMD > div.sc-71859520-0.iORlYq > div.sc-63c588db-0.fEeWHy > div.sc-63c588db-0.fEeWHy > div.sc-63c588db-0.cPViuC.sc-68931dd3-2.jEGvWu
    # #base-layout-main-wrapper > div.sc-fd760fa7-0.hnfPMD > div.sc-71859520-0.iORlYq > div.sc-63c588db-0.fEeWHy > div.sc-63c588db-0.fEeWHy > div.sc-63c588db-0.cPViuC.sc-68931dd3-2.jEGvWu
    except Exception as e:
        print(f"Trying to get number of pages: {e}")
    
    numOfPages = int(numOfPages.split("\n")[1])
    print(f"Num of pages:  {numOfPages}")
    
    start_time = time.time()
    pages=[f"https://www.kijiji.ca/b-apartments-condos/gta-greater-toronto-area/page-{i+1}/c37l1700272?price=900__3000&size-sqft=600__900" for i in range(numOfPages)]
    
    
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=30) as executor:
        pageListingsResults = executor.map(pageListingsScrapper, pages)
    
    #time.sleep(20)
    # print(list(pageListingsResults))
    pageListings=list(pageListingsResults)
    # print(f"{len(list(pageListings))}")
    time.sleep(20)
    # print(len(list(pageListingsResults)))
    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        dataListingsResults = executor.map(dataListingsScrapper, pageListings)
    
    time.sleep(20)
    returnedLists=[]

    for result in dataListingsResults:
        returnedLists.extend(list(result))
    
    print(f"Num of pages:  {numOfPages}")
    # time.sleep(5)    
    duration = time.time() - start_time
    print(f"Downloaded in {duration} seconds")

    driver.close()
    
    df=pd.DataFrame(returnedLists)
    df.to_csv(f"kijijiRentalData{date.today()}.csv")
    


# Receive page from a threaded chunker 
# gets all the rental ads' actual data
# stores it in a list of dictionaries and returns it to chunke 
def dataListingsScrapper(pages):

    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument("--log-level=3")
    options.add_argument('--ignore-certificate-errors-spki-list')
    options.add_argument('--ignore-ssl-errors')

    driver=webdriver.Chrome(options=options)
    dataRec=[]
    logCount =1

    for currentPage in pages:
        try: 
            driver.get(currentPage.rstrip())
            # print("opened")
        except Exception as e:
            print(f"Error occurred page ({currentPage}) couldn't open :\n {e}")
        try:
            url = driver.current_url
            title = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[1]/h1").text
        except Exception as e:
            title = ""
        try:
            address = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[2]/div[1]/span").text
        except Exception as e:
            address = ""
        try:
            datePosted = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[2]/div[2]/time").get_attribute("datetime")
        except Exception as e:
            datePosted = ""
        try:
            price = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[1]/div/span[1]").text
        except Exception as e:
            price = ""
        try:
            propertyType = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[3]/div/li[1]/span").text
        except Exception as e:
            propertyType = ""
        try:
            bedrooms = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[3]/div/li[2]/span").text
        except Exception as e:
            bedrooms = ""
        try:
            bathrooms = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[2]/div[3]/div/li[3]/span").text
        except Exception as e:
            bathrooms = ""
        try:
            description = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[5]/div/div[1]/div/div/p[1]").text
        except Exception as e:
            description = ""
        try:
            ulElem = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[1]/ul/li[1]/div/ul")
            ilElem = ulElem.find_elements(By.XPATH, "./li")
            listOfUtilities = []
            if ilElem:
                
                # for index, li_element in enumerate(ilElem, start=1):
                for li_element in ilElem:
                    svg_element = li_element.find_element(By.XPATH,".//*[local-name() = 'svg']")  # Assuming the 'aria-label' is in an SVG tag
                    utility = svg_element.get_attribute('aria-label')
                    # print(f"li[{index}] utility:", utility)
                
                
                    listOfUtilities.append(utility)
            else:
                utility = ulElem.text
                # print("tried utility")
                
            listOfUtilities.append(utility)
        except :
            # print(f"utilities causing an issue: {e}")
            listOfUtilities = []
        try:
            parking = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[1]/ul/li[3]/dl/dd").text
        except Exception as e:
            parking = ""
        try:
            aggreementType = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[1]/ul/li[4]/dl/dd").text
        except Exception as e:
            aggreementType = ""
        try:
            petFriendly = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[1]/ul/li[6]/dl/dd").text
        except Exception as e:
            petFriendly = ""
        try:
            size = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[2]/ul/li[1]/dl/dd").text
        except Exception as e:
            size = ""
        try:
            furnished = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[2]/ul/li[2]/dl/dd").text
        except Exception as e:
            furnished = ""
        try:
            appliancesUl = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[2]/ul/li[3]/div/ul")
            appliancesli = appliancesUl.find_elements(By.XPATH, ".//li")
            
            if appliancesli:
                listOfAppliances = []
                for appliance in appliancesli:
                    applianc = appliance.text
                    # print(f"trying to print appliances: {applianc}")
                    listOfAppliances.append(applianc)
            else:
                listOfAppliances = []
        except :
            # print(f"appliance causing an issue: {e}")
            listOfAppliances = []
        try:
            airCon = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[2]/ul/li[4]/dl/dd").text
        except Exception as e:
            airCon = ""
        try:
            outdoorSpace = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[2]/ul/li[5]/div/ul/li[2]").text
        except Exception as e:
            outdoorSpace = ""
        try:
            amenitiesUl = driver.find_element(By.XPATH, "//*[@id='vip-body']/div[3]/div[2]/div/div/div[3]/ul/li/div/ul")
            amenitiesLi = amenitiesUl.find_elements(By.XPATH, ".//li")
            if amenitiesLi:
                listOfAmenities = []
                for amenity in amenitiesLi:
                    amenit = amenity.text
                    # print(f"printing amenities : {amenit}")
                    listOfAmenities.append(amenit)
            else:
                listOfAmenities = []
        except :
            # print(f"amenities causing an issue: {e}")
            listOfAmenities = []

        
        collectedDict = {"url": url, "title": title, "address":address, "datePosted":datePosted, "price":price, "propertyType":propertyType, "bedrooms":bedrooms, "bathrooms":bathrooms, "description":description, "utilities":listOfUtilities, "parking":parking, "aggreementType":aggreementType, "petFriendly":petFriendly, "size":size, "furnished":furnished, "appliances":listOfAppliances, "a/c":airCon, "outdoorSpace":outdoorSpace, "amenities":listOfAmenities}
        # print(sys.getsizeof(collectedDict))
        dataRec.append(collectedDict)
             
    driver.close()
    return dataRec


if __name__ == "__main__":

    chunker()
    