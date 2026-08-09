import urllib.request
import json
import ssl
import os

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

release_id = 781158
apk_path = r'C:\dev\oxford_word_game\build\app\outputs\flutter-apk\app-release.apk'
access_token = '6d2918948733a638447df5e98d3dceaa'

# 读取文件
with open(apk_path, 'rb') as f:
    file_data = f.read()

filename = os.path.basename(apk_path)

# 构建 multipart 请求
boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'
body_parts = []
body_parts.append('--' + boundary)
body_parts.append('Content-Disposition: form-data; name="file"; filename="' + filename + '"')
body_parts.append('Content-Type: application/vnd.android.package-archive')
body_parts.append('')
body = '\r\n'.join(body_parts).encode() + file_data + ('\r\n--' + boundary + '--\r\n').encode()

url = f'https://gitee.com/api/v5/repos/alanfoxe/oxford-word-game/releases/{release_id}/attachments?access_token={access_token}'

req = urllib.request.Request(url, data=body, method='POST')
req.add_header('Content-Type', 'multipart/form-data; boundary=' + boundary)

try:
    resp = urllib.request.urlopen(req, context=ctx)
    result = json.loads(resp.read())
    print('上传成功!')
    print('文件名:', result.get('name', ''))
    print('下载地址:', result.get('browser_download_url', ''))
except Exception as e:
    print('上传失败:', e)
    if hasattr(e, 'read'):
        print(e.read().decode())
