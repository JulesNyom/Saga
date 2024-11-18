import requests
from bs4 import BeautifulSoup
import json
from typing import Dict, List
import re
from dataclasses import dataclass, asdict
from datetime import datetime

@dataclass
class AudioBook:
    id: str
    title: str
    author: str
    imageUrl: str
    duration: str
    views: str
    url: str
    narrator: str
    date: str
    description: str = ""

class LitteratureAudioScraper:
    def __init__(self):
        self.base_url = 'https://www.litteratureaudio.com'
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

    def clean_url(self, url: str) -> str:
        """Remove size constraints from image URLs"""
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def extract_book_data(self, article) -> AudioBook:
        """Extract all relevant data from a book article element"""
        # Extract basic information
        title = article.select_one('h3.entry-title a').text.strip()
        img_elem = article.select_one('img.wp-post-image')
        image_url = self.clean_url(img_elem['src']) if img_elem else ''
        duration = article.select_one('div.duration').text.strip()
        views = article.select_one('div.views').text.strip()
        author = article.select_one('span.entry-auteur a').text.strip()
        narrator = article.select_one('span.entry-voix a').text.strip()
        date = article.select_one('span.posted-on a').text.strip()
        url = article.select_one('h3.entry-title a')['href']
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

    def scrape_books(self, limit: int = 10) -> Dict[str, List[Dict]]:
        """Scrape books and return them separated into featured and recent"""
        try:
            response = requests.get(self.base_url, headers=self.headers)
            soup = BeautifulSoup(response.text, 'lxml')
            
            # Find all book elements
            articles = soup.find_all('article', class_='block-loop-item', limit=limit)
            
            # Process all books
            all_books = [self.extract_book_data(article) for article in articles]
            
            # Separate into featured and recent based on views
            sorted_books = sorted(all_books, key=lambda x: int(re.sub(r'[^\d]', '', x.views)), reverse=True)
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

if __name__ == "__main__":
    main()