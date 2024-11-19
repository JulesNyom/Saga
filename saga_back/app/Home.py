import requests
from bs4 import BeautifulSoup
import json
from typing import Dict, List
import re
from dataclasses import dataclass, asdict

@dataclass
class AudioBook:
    id: str
    title: str
    author: str
    imageUrl: str
    duration: str
    views: str
    url: str
    narrator: str = ""
    date: str = ""

class LitteratureAudioScraper:
    def __init__(self):
        self.base_url = 'https://www.litteratureaudio.com'
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

    def clean_url(self, url: str) -> str:
        """Remove size constraints from image URLs"""
        if not url:
            return ''
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def extract_views(self, views_element) -> str:
        """Extract view count from the views element"""
        if not views_element:
            return "0"
        # Remove all non-digit characters
        return re.sub(r'\D', '', views_element.text.strip())

    def extract_book_data(self, article) -> AudioBook:
        """Extract all relevant data from a book article element"""
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

    def scrape_books(self, limit: int = 10) -> Dict[str, List[Dict]]:
        """Scrape books and return them separated into featured and recent"""
        try:
            response = requests.get(self.base_url, headers=self.headers)
            soup = BeautifulSoup(response.text, 'lxml')
            
            # Find all book elements
            articles = soup.find_all('article', class_='block-loop-item')
            
            # Process all books
            all_books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    all_books.append(book)
            
            # Separate into featured and recent based on views
            sorted_books = sorted(all_books, key=lambda x: int(x.views) if x.views.isdigit() else 0, reverse=True)
            featured_books = sorted_books[:3]
            recent_books = sorted_books[3:]

            return {
                'featured_books': [asdict(book) for book in featured_books],
                'recent_books': [asdict(book) for book in recent_books]
            }
            
        except Exception as e:
            print(f"An error occurred while scraping: {e}")
            return {'featured_books': [], 'recent_books': []}

    def save_to_json(self, data: Dict[str, List[Dict]], filename: str = 'books.json'):
        """Save the scraped data to a JSON file"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

def main():
    scraper = LitteratureAudioScraper()
    books_data = scraper.scrape_books(limit=20)  # Scrape 20 books total
    scraper.save_to_json(books_data)
    print(f"Scraped {len(books_data['featured_books'])} featured books and {len(books_data['recent_books'])} recent books")
    
    # Print first book as example
    if books_data['featured_books']:
        print("\nExample of first featured book:")
        print(json.dumps(books_data['featured_books'][0], indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()