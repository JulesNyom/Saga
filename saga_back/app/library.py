from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from typing import List, Optional, Set
from pydantic import BaseModel
from bs4 import BeautifulSoup
import requests
import re
from datetime import datetime
import html
import json

app = FastAPI(title="Littérature Audio API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class AudioBook(BaseModel):
    id: str
    title: str
    author: str
    imageUrl: str
    duration: str
    views: str
    url: str
    narrator: Optional[str] = ""
    date: Optional[str] = ""

class BooksResponse(BaseModel):
    page: int
    total_pages: int
    books: List[AudioBook]

class LitteratureAudioScraper:
    def __init__(self):
        self.base_url = 'https://www.litteratureaudio.com'
        self.popular_url = f"{self.base_url}/classement-de-nos-livres-audio-gratuits-les-plus-apprecies"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        self.processed_ids: Set[str] = set()

    def decode_text(self, text: str) -> str:
        if not text:
            return ""
        
        text = html.unescape(text)
        
        text = text.replace('&#233;', 'é')
        text = text.replace('&#232;', 'è')
        text = text.replace('&#224;', 'à')
        text = text.replace('&#231;', 'ç')
        text = text.replace('&#226;', 'â')
        text = text.replace('&#238;', 'î')
        text = text.replace('&#244;', 'ô')
        text = text.replace('&#251;', 'û')
        text = text.replace('&#39;', "'")
        
        return ' '.join(text.split())

    def clean_url(self, url: str) -> str:
        if not url:
            return ''
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def extract_views(self, views_element) -> str:
        if not views_element:
            return "0"
        views_text = views_element.text.strip() if views_element else "0"
        views_number = ''.join(filter(str.isdigit, views_text))
        return views_number if views_number else "0"

    def extract_book_data(self, article) -> Optional[AudioBook]:
        try:
            post_id = article.get('data-id', '').replace('post-', '')
            
            if post_id in self.processed_ids:
                return None
            
            self.processed_ids.add(post_id)
            
            # Title and URL
            title_elem = article.select_one('h3.entry-title a')
            raw_title = title_elem.text.strip() if title_elem else "Unknown Title"
            title = self.decode_text(raw_title)
            url = title_elem['href'] if title_elem else ""

            # Image
            img_elem = article.select_one('img.wp-post-image')
            image_url = self.clean_url(img_elem['src']) if img_elem else ""

            # Duration
            duration_elem = article.select_one('div.duration')
            duration = duration_elem.text.strip() if duration_elem else "Unknown"

            # Views
            views_elem = article.select_one('div.views')
            views = self.extract_views(views_elem)

            # Author
            author_elem = article.select_one('span.entry-auteur a')
            raw_author = author_elem.text.strip() if author_elem else "Unknown Author"
            author = self.decode_text(raw_author)

            # Narrator
            narrator_elem = article.select_one('span.entry-voix a')
            raw_narrator = narrator_elem.text.strip() if narrator_elem else ""
            narrator = self.decode_text(raw_narrator)

            # Date
            date_elem = article.select_one('span.posted-on a')
            raw_date = date_elem.text.strip() if date_elem else ""
            date = self.decode_text(raw_date)

            return AudioBook(
                id=post_id,
                title=title,
                author=author,
                imageUrl=image_url,
                duration=duration,
                views=views,
                url=url,
                narrator=narrator,
                date=date
            )
        except Exception as e:
            print(f"Error extracting data from article: {e}")
            return None

    async def scrape_popular_books(self, page: int = 1) -> dict:
        try:
            self.processed_ids.clear()
            
            # Construct URL with page parameter
            url = f"{self.popular_url}/page/{page}" if page > 1 else self.popular_url
            print(f"Scraping URL: {url}")  # Debug log
            
            response = requests.get(url, headers=self.headers, timeout=10)
            response.encoding = 'utf-8'
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'lxml', from_encoding='utf-8')
            
            # Extract total pages
            pagination = soup.select_one('nav.pagination')
            total_pages = 1
            if pagination:
                pages = pagination.select('a.page-numbers')
                if pages:
                    # Get the last numbered page
                    for page_link in reversed(pages):
                        if page_link.text.isdigit():
                            total_pages = int(page_link.text)
                            break
            
            # Extract books
            articles = soup.find_all('article', class_='block-loop-item')
            print(f"Found {len(articles)} articles")  # Debug log
            
            books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    books.append(book)
            
            response_dict = {
                "page": page,
                "total_pages": total_pages,
                "books": [json.loads(book.json()) for book in books]
            }
            
            print(f"Returning {len(books)} books")  # Debug log
            return response_dict
            
        except requests.RequestException as e:
            print(f"Request error: {e}")  # Debug log
            raise HTTPException(status_code=503, detail=str(e))
        except Exception as e:
            print(f"General error: {e}")  # Debug log
            raise HTTPException(status_code=500, detail=str(e))

scraper = LitteratureAudioScraper()

@app.get("/")
async def read_root():
    return {"message": "Welcome to Littérature Audio API"}

@app.get("/popular", response_model=BooksResponse)
async def get_popular_books(page: int = 1):
    """Get most popular audio books with pagination"""
    if page < 1:
        raise HTTPException(status_code=400, detail="Page number must be greater than 0")
        
    try:
        books_data = await scraper.scrape_popular_books(page)
        return JSONResponse(
            content=books_data,
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)