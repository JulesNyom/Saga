from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional, Set
from pydantic import BaseModel
from bs4 import BeautifulSoup
import requests
import re
from datetime import datetime
import html
import unicodedata

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
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept-Charset': 'utf-8',
        }
        self.processed_ids: Set[str] = set()

    def clean_url(self, url: str) -> str:
        if not url:
            return ''
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def clean_text(self, text: str) -> str:
        """Clean and normalize text to handle special characters"""
        if not text:
            return ""
        # Decode HTML entities
        text = html.unescape(text)
        # Normalize Unicode characters
        text = unicodedata.normalize('NFKC', text)
        # Remove extra whitespace
        text = ' '.join(text.split())
        return text

    def extract_views(self, views_element) -> str:
        if not views_element:
            return "0"
        views_text = views_element.text.strip()
        # Extract only numbers
        numbers = re.sub(r'\D', '', views_text)
        return numbers if numbers else "0"

    def extract_book_data(self, article) -> Optional[AudioBook]:
        try:
            # Extract post ID first
            post_id = article.get('data-id', '').replace('post-', '')
            
            # Skip if we've already processed this ID
            if post_id in self.processed_ids:
                return None
            
            self.processed_ids.add(post_id)

            # Extract title and URL
            title_elem = article.select_one('h3.entry-title a')
            title = self.clean_text(title_elem.text.strip() if title_elem else "Unknown Title")
            url = title_elem['href'] if title_elem else ""

            # Extract image URL
            img_elem = article.select_one('img.wp-post-image')
            image_url = self.clean_url(img_elem['src']) if img_elem else ""

            # Extract duration
            duration_elem = article.select_one('div.duration')
            duration = self.clean_text(duration_elem.text.strip() if duration_elem else "Unknown")

            # Extract views
            views_elem = article.select_one('div.views')
            views = self.extract_views(views_elem)

            # Extract author
            author_elem = article.select_one('span.entry-auteur a')
            author = self.clean_text(author_elem.text.strip() if author_elem else "Unknown Author")

            # Extract narrator
            narrator_elem = article.select_one('span.entry-voix a')
            narrator = self.clean_text(narrator_elem.text.strip() if narrator_elem else "")

            # Extract date
            date_elem = article.select_one('span.posted-on a')
            date = self.clean_text(date_elem.text.strip() if date_elem else "")

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

    async def scrape_books(self, limit: int = 20) -> BooksResponse:
        try:
            # Reset processed IDs for new scrape
            self.processed_ids.clear()
            
            response = requests.get(
                self.base_url, 
                headers=self.headers,
                timeout=10
            )
            response.encoding = 'utf-8'  # Ensure proper encoding
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'lxml')
            articles = soup.find_all('article', class_='block-loop-item')
            
            all_books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    all_books.append(book)
                
                # Stop if we've reached the limit
                if len(all_books) >= limit:
                    break
            
            # Sort books by views and split into featured and recent
            sorted_books = sorted(
                all_books, 
                key=lambda x: int(x.views) if x.views.isdigit() else 0, 
                reverse=True
            )
            
            # Get top 3 for featured, rest for recent
            featured_books = sorted_books[:3]
            recent_books = sorted_books[3:] if len(sorted_books) > 3 else []

            return BooksResponse(
                featured_books=featured_books,
                recent_books=recent_books
            )
            
        except requests.RequestException as e:
            raise HTTPException(
                status_code=503, 
                detail=f"Error fetching data: {str(e)}"
            )
        except Exception as e:
            raise HTTPException(
                status_code=500, 
                detail=f"Server error: {str(e)}"
            )

# Initialize scraper
scraper = LitteratureAudioScraper()

@app.get("/", response_model=BooksResponse)
async def get_books(limit: int = 20):
    """
    Get unique audio books from Littérature Audio.
    Returns featured and recent books with proper text encoding.
    """
    return await scraper.scrape_books(limit)

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "encoding": "UTF-8"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)