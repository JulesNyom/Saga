from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel
from bs4 import BeautifulSoup
import requests
import re
from datetime import datetime

app = FastAPI(title="Litterature Audio API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins in development
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

    def clean_url(self, url: str) -> str:
        if not url:
            return ''
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def extract_views(self, views_element) -> str:
        if not views_element:
            return "0"
        return re.sub(r'\D', '', views_element.text.strip())

    def extract_book_data(self, article) -> Optional[AudioBook]:
        try:
            # Extract title and URL
            title_elem = article.select_one('h3.entry-title a')
            title = title_elem.text.strip() if title_elem else "Unknown Title"
            url = title_elem['href'] if title_elem else ""

            # Extract image URL
            img_elem = article.select_one('img.wp-post-image')
            image_url = self.clean_url(img_elem['src']) if img_elem else ""

            # Extract duration
            duration_elem = article.select_one('div.duration')
            duration = duration_elem.text.strip() if duration_elem else "Unknown"

            # Extract views
            views_elem = article.select_one('div.views')
            views = self.extract_views(views_elem)

            # Extract author
            author_elem = article.select_one('span.entry-auteur a')
            author = author_elem.text.strip() if author_elem else "Unknown Author"

            # Extract narrator
            narrator_elem = article.select_one('span.entry-voix a')
            narrator = narrator_elem.text.strip() if narrator_elem else ""

            # Extract date
            date_elem = article.select_one('span.posted-on a')
            date = date_elem.text.strip() if date_elem else ""

            # Extract post ID
            post_id = article.get('data-id', '').replace('post-', '')

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

    async def scrape_books(self, limit: int = 10) -> BooksResponse:
        try:
            response = requests.get(self.base_url, headers=self.headers)
            response.raise_for_status()  # Raise an exception for bad status codes
            
            soup = BeautifulSoup(response.text, 'lxml')
            articles = soup.find_all('article', class_='block-loop-item')
            
            all_books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    all_books.append(book)
            
            # Sort books by views and split into featured and recent
            sorted_books = sorted(all_books, key=lambda x: int(x.views) if x.views.isdigit() else 0, reverse=True)
            featured_books = sorted_books[:3]
            recent_books = sorted_books[3:]

            return BooksResponse(
                featured_books=featured_books,
                recent_books=recent_books
            )
            
        except requests.RequestException as e:
            raise HTTPException(status_code=503, detail=f"Error fetching data: {str(e)}")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")

# Initialize scraper
scraper = LitteratureAudioScraper()

@app.get("/", response_model=BooksResponse)
async def get_books(limit: int = 10):
    """
    Get audio books from Litterature Audio.
    Returns featured and recent books.
    """
    return await scraper.scrape_books(limit)

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)