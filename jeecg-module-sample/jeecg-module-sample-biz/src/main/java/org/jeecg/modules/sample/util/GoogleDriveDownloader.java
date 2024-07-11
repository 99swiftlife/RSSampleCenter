package org.jeecg.modules.sample.util;

/**
 * @program: RSSampleCenter
 * @description: 谷歌网盘下载器
 * @author: swiftlife
 * @create: 2024-06-22 11:49
 **/
public class GoogleDriveDownloader extends Downloader{
    @Override
    public String downloadFile(String url, String filePath) {
//        File file = new File(destinationPath);
//        long existingFileSize = file.exists() ? file.length() : 0;
//
//        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
//            HttpGet httpGet = new HttpGet(fileURL);
//            if (existingFileSize > 0) {
//                httpGet.setHeader("Range", "bytes=" + existingFileSize + "-");
//            }
//            HttpResponse response = httpClient.execute(httpGet);
//            int responseCode = response.getStatusLine().getStatusCode();
//
//            if (responseCode == 200 || responseCode == 206) {
//                HttpEntity entity = response.getEntity();
//                if (entity != null) {
//                    try (InputStream inputStream = entity.getContent();
//                         RandomAccessFile raf = new RandomAccessFile(file, "rw")) {
//                        raf.seek(existingFileSize);
//                        byte[] buffer = new byte[8192];
//                        int bytesRead;
//                        while ((bytesRead = inputStream.read(buffer)) != -1) {
//                            raf.write(buffer, 0, bytesRead);
//                        }
//                    }
//                }
//            } else {
//                System.out.println("No file to download. Server replied HTTP code: " + responseCode);
//            }
//        }
        return null;
    }
}
