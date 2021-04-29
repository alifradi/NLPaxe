# Scraping modules

def BBC_link(url):
  texts =  list()
  titles=  list()
  data= {}
  try:
    requete = requests.get(url) 
    page = requete.content # Récuprer le contenu de la page 
    soup = BeautifulSoup(page,"html.parser")
    titre = soup.find("h1", {"id": "main-heading"}).text 
    paragraphe = [pr.get_text() for pr in soup.find_all("div", {"data-component": "text-block"})]
    Text = ''
    for i in range(0,len(paragraphe)):
      Text = str(Text + paragraphe[i]) + '\n '
  except:
    pass
    
    
  data = {'Title' : titre , 'Text' : Text}
  df = pd.DataFrame(data,columns=['Title', 'Text'], index=[0])  
  return df  
def EMR_link(url):
  texts =  list()
  titles=  list()
  data= {}
  try:
    requete = requests.get(url) 
    page = requete.content # Récuprer le contenu de la page 
    soup = BeautifulSoup(page,"html.parser")
    titre = soup.find("h1",{}).text
    paragraphe = [pr.get_text() for pr in soup.find_all("p", {})]
    Text = ''
    for i in range(0,len(paragraphe)):
      Text = str(Text + paragraphe[i]) + '\n '
  except:
    pass
  data = {'Title' : titre , 'Text' : Text}
  df = pd.DataFrame(data,columns=['Title', 'Text'], index=[0])  
  return df  
def JZR_link(url):
  texts =  list()
  titles=  list()
  data= {}
  requete = requests.get(url) 
  page = requete.content # Récuprer le contenu de la page 
  soup = BeautifulSoup(page,"html.parser")
  titre = soup.find("h1",{}).text
  paragraphe = [pr.get_text() for pr in soup.find_all("p", {})]
  Text = ''
  for i in range(0,len(paragraphe)):
    Text = str(Text + paragraphe[i]) + '\n '
    
  data = {'Title' : titre , 'Text' : Text}
  df = pd.DataFrame(data,columns=['Title', 'Text'], index=[0])  
  return df  
# pagination starts with 0
def MEE_link(url):
  texts =  list()
  titles =  list()
  data= {}
  try:
    requete = requests.get(url) 
    page = requete.content # Récuprer le contenu de la page 
    soup = BeautifulSoup(page,"html.parser")
    titre = soup.find("h1", {}).text
    paragraphe = [pr.get_text() for pr in soup.find_all("p", {})]
    Text = ''
    for i in range(0,len(paragraphe)):
      Text = str(Text + paragraphe[i]) + '\n '
  except:
    pass
  data = {'Title' : titre , 'Text' : Text}
  df = pd.DataFrame(data,columns=['Title', 'Text'], index=[0])  
  return df  
def WSP_link(url):
  texts =  list()
  titles=  list()
  data= {}
  try:
    requete = requests.get(url) 
    page = requete.content # Récuprer le contenu de la page 
    soup = BeautifulSoup(page,"html.parser")
    titre = soup.find("h1",{}).text
    paragraphe = [pr.get_text() for pr in soup.find_all("p", {})]
    Text = ''
    for i in range(0,len(paragraphe)):
      Text = str(Text + paragraphe[i]) + '\n '
  except:
    pass
  data = {'Title' : titre , 'Text' : Text}
  df = pd.DataFrame(data,columns=['Title', 'Text'], index=[0])  
  return df  
