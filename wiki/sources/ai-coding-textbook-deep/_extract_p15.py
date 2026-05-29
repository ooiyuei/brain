import fitz
import sys

pdf_path = r"C:\Users\Owner\Downloads\非エンジニアのためのAIコーディングの教科書v1.0.1.pdf"
out_path = r"C:\Users\Owner\business\brain\wiki\sources\ai-coding-textbook-deep\_part15_pymupdf.txt"

doc = fitz.open(pdf_path)
print(f"Total pages: {len(doc)}", file=sys.stderr)

with open(out_path, "w", encoding="utf-8") as f:
    for page_num in range(280, 300):  # 0-indexed: pages 281-300
        page = doc.load_page(page_num)
        text = page.get_text("text")
        f.write(f"\n===== PAGE {page_num + 1} =====\n")
        f.write(text)
        f.write("\n")

doc.close()
print("DONE", file=sys.stderr)
