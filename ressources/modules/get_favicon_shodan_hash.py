import sys, re, base64
import urllib.request
import urllib.parse

def mmh3Hash(key, seed=0):
    key = bytearray(key)
    length = len(key)
    nblocks = length // 4

    h1 = seed
    c1 = 0xcc9e2d51
    c2 = 0x1b873593

    for block_start in range(0, nblocks * 4, 4):
        k1 = (key[block_start] | (key[block_start + 1] << 8) |
              (key[block_start + 2] << 16) | (key[block_start + 3] << 24))

        k1 = (k1 * c1) & 0xFFFFFFFF
        k1 = (k1 << 15 | k1 >> 17) & 0xFFFFFFFF
        k1 = (k1 * c2) & 0xFFFFFFFF

        h1 ^= k1
        h1 = (h1 << 13 | h1 >> 19) & 0xFFFFFFFF
        h1 = (h1 * 5 + 0xe6546b64) & 0xFFFFFFFF

    tail_index = nblocks * 4
    tail_size = length & 3
    k1 = 0

    if tail_size >= 3:
        k1 ^= key[tail_index + 2] << 16
    if tail_size >= 2:
        k1 ^= key[tail_index + 1] << 8
    if tail_size >= 1:
        k1 ^= key[tail_index]

    if tail_size > 0:
        k1 = (k1 * c1) & 0xFFFFFFFF
        k1 = (k1 << 15 | k1 >> 17) & 0xFFFFFFFF
        k1 = (k1 * c2) & 0xFFFFFFFF
        h1 ^= k1

    h1 ^= length
    h1 ^= h1 >> 16
    h1 = (h1 * 0x85ebca6b) & 0xFFFFFFFF
    h1 ^= h1 >> 13
    h1 = (h1 * 0xc2b2ae35) & 0xFFFFFFFF
    h1 ^= h1 >> 16

    if h1 & 0x80000000:
        h1 = -((h1 ^ 0xFFFFFFFF) + 1)
    return h1


def fetch(url, timeout=10):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read(), resp.geturl()


def findFaviconUrl(domain):
    base = f"https://{domain}"
    try:
        html, final_url = fetch(base)
        html_text = html.decode("utf-8", errors="ignore")
        match = re.search(
            r'<link[^>]+rel=["\'](?:shortcut icon|icon)["\'][^>]*href=["\']([^"\']+)["\']',
            html_text, re.IGNORECASE)
        if match:
            return urllib.parse.urljoin(final_url, match.group(1))
    except Exception:
        pass
    return urllib.parse.urljoin(base + "/", "favicon.ico")


domain = sys.argv[1]
favicon_url = findFaviconUrl(domain)
try:
    data, _ = fetch(favicon_url)
except Exception as exc:
    print(f"error fetching favicon from {favicon_url}: {exc}", file=sys.stderr)
    sys.exit(1)

b64 = base64.encodebytes(data)
print(mmh3Hash(b64))

