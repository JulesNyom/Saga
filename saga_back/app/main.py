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
    featured_books: List[AudioBook]
    recent_books: List[AudioBook]

class LitteratureAudioScraper:
    def __init__(self):
        self.base_url = 'https://www.litteratureaudio.com'
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        self.processed_ids: Set[str] = set()

    def decode_text(self, text: str) -> str:
        """Decode HTML entities and clean text"""
        if not text:
            return ""
        
        # First step: basic HTML entity decoding
        text = html.unescape(text)
        
        # Second step: handle specific French characters
        text = text.replace('&#233;', 'é')
        text = text.replace('&#232;', 'è')
        text = text.replace('&#224;', 'à')
        text = text.replace('&#231;', 'ç')
        text = text.replace('&#226;', 'â')
        text = text.replace('&#238;', 'î')
        text = text.replace('&#244;', 'ô')
        text = text.replace('&#251;', 'û')
        text = text.replace('&#39;', "'")
        
        # Remove extra whitespace
        text = ' '.join(text.split())
        
        return text

    def clean_url(self, url: str) -> str:
        if not url:
            return ''
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def extract_views(self, views_element) -> str:
        if not views_element:
            return "0"
        return ''.join(filter(str.isdigit, views_element.text.strip()))

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

    async def scrape_books(self, limit: int = 20) -> dict:
        try:
            self.processed_ids.clear()
            
            response = requests.get(self.base_url, headers=self.headers, timeout=10)
            response.encoding = 'utf-8'
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'lxml', from_encoding='utf-8')
            articles = soup.find_all('article', class_='block-loop-item')
            
            all_books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    all_books.append(book)
                if len(all_books) >= limit:
                    break
            
            sorted_books = sorted(
                all_books,
                key=lambda x: int(x.views) if x.views.isdigit() else 0,
                reverse=True
            )
            
            featured_books = sorted_books[:3]
            recent_books = sorted_books[3:] if len(sorted_books) > 3 else []

            # Convert to dict and ensure proper encoding
            response_dict = {
                "featured_books": [json.loads(book.json()) for book in featured_books],
                "recent_books": [json.loads(book.json()) for book in recent_books]
            }
            
            return response_dict
            
        except requests.RequestException as e:
            raise HTTPException(status_code=503, detail=str(e))
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

scraper = LitteratureAudioScraper()

@app.get("/")
async def get_books(limit: int = 20):
    """Get audio books from Littérature Audio"""
    books_data = await scraper.scrape_books(limit)
    
    # Return with explicit content type and encoding
    return JSONResponse(
        content=books_data,
        headers={
            "Content-Type": "application/json; charset=utf-8"
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="debug",
        reload=True
    )