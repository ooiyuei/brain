#!/usr/bin/env python3
"""
Morioka book OCR batch processor.
500 PNG images → text files using easyocr (Japanese support).

Output:
  C:\\Users\\Owner\\business\\brain\\.local\\morioka-ocr\\page-NNNN.txt
  C:\\Users\\Owner\\business\\brain\\.local\\morioka-ocr\\_all.txt (concatenated)
"""

import os
import sys
import time
from pathlib import Path

IMG_DIR = Path(r"C:\Users\Owner\Pictures\auto-screenshots-20260526-075018")
OUT_DIR = Path(r"C:\Users\Owner\business\brain\.local\morioka-ocr")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Progress log
LOG = OUT_DIR / "_progress.log"

def log(msg):
    timestamp = time.strftime("%H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line, flush=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

def main():
    log("=== OCR batch start ===")
    log(f"img dir: {IMG_DIR}")
    log(f"out dir: {OUT_DIR}")

    images = sorted(IMG_DIR.glob("*.png"))
    log(f"found {len(images)} PNG files")

    log("loading easyocr (Japanese+English)... (first run downloads models ~100MB)")
    import easyocr
    reader = easyocr.Reader(['ja', 'en'], gpu=False)  # CPU first for stability
    log("easyocr ready")

    all_text = []
    start = time.time()

    for idx, img_path in enumerate(images, 1):
        page_num = img_path.stem  # e.g. "0001"
        out_path = OUT_DIR / f"page-{page_num}.txt"

        if out_path.exists():
            # skip already-done
            text = out_path.read_text(encoding="utf-8")
            all_text.append(f"\n\n===== PAGE {page_num} =====\n{text}")
            continue

        try:
            results = reader.readtext(str(img_path), detail=0, paragraph=True)
            text = "\n".join(results)
        except Exception as e:
            text = f"[OCR_ERROR: {e}]"
            log(f"page {page_num} ERROR: {e}")

        out_path.write_text(text, encoding="utf-8")
        all_text.append(f"\n\n===== PAGE {page_num} =====\n{text}")

        if idx % 10 == 0:
            elapsed = time.time() - start
            eta = (elapsed / idx) * (len(images) - idx)
            log(f"progress: {idx}/{len(images)} ({100*idx//len(images)}%) elapsed={int(elapsed)}s ETA={int(eta)}s")

    # Concatenate all
    all_path = OUT_DIR / "_all.txt"
    all_path.write_text("".join(all_text), encoding="utf-8")
    log(f"saved {all_path} ({all_path.stat().st_size//1024}KB)")

    elapsed = time.time() - start
    log(f"=== OCR batch done in {int(elapsed)}s ({len(images)} pages) ===")

if __name__ == "__main__":
    main()
