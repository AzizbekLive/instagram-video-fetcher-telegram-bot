import http.client

conn = http.client.HTTPSConnection("instagram-video-or-images-downloader.p.rapidapi.com")

payload = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"url\"\r\n\r\nhttps://www.instagram.com/reel/C8uSS6dtnYZ/\r\n-----011000010111000001101001--\r\n\r\n"

headers = {
    'x-rapidapi-key': "41cffcf8d1msh5bcead6ef52fdd5p16466ajsn2a3f7322fcb8",
    'x-rapidapi-host': "instagram-video-or-images-downloader.p.rapidapi.com",
    'Content-Type': "multipart/form-data; boundary=---011000010111000001101001"
}

conn.request("POST", "/", payload, headers)

res = conn.getresponse()
data = res.read()

print(data.decode("utf-8"))