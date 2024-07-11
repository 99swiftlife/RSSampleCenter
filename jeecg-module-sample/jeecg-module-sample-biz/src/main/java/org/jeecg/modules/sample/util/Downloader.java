package org.jeecg.modules.sample.util;

import org.apache.commons.compress.archivers.zip.ZipArchiveInputStream;
import org.apache.xmlbeans.impl.xb.xsdschema.All;

import java.io.IOException;
import java.util.concurrent.CompletableFuture;

/**
 * @program: RSSampleCenter
 * @description: 数据下载类基类
 * @author: swiftlife
 * @create: 2024-06-22 11:31
 **/
public abstract class Downloader {
    public abstract String downloadFile(String url,String filePath);
    private void unzip(String zipFilePath, String destDir) throws IOException {

    }
    private void run(){
//        CompletableFuture<Void> downloadTask = CompletableFuture.runAsync(() -> {
//            try {
//                downloadFile(DOWNLOAD_URL, downloadedFilePath);
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        });
//
//        downloadTask.thenRunAsync(() -> {
//            try {
//                unzip(downloadedFilePath, DOWNLOAD_DIR);
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        });
//
//        downloadTask.join(); // 等待所有任务完成
    }
    
}
