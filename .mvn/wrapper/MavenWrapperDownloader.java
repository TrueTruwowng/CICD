/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
import java.net.*;
import java.io.*;
import java.nio.channels.*;
import java.util.Properties;

public class MavenWrapperDownloader {
    private static final String WRAPPER_VERSION = "3.3.2";
    private static final String DEFAULT_DOWNLOAD_URL = "https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/" + WRAPPER_VERSION + "/maven-wrapper-" + WRAPPER_VERSION + ".jar";
    private static final String MAVEN_WRAPPER_PROPERTIES_PATH = ".mvn/wrapper/maven-wrapper.properties";
    private static final String MAVEN_WRAPPER_JAR_PATH = ".mvn/wrapper/maven-wrapper.jar";

    public static void main(String args[]) {
        System.out.println("- Downloading Maven wrapper jar");
        try {
            File baseDirectory = new File(System.getProperty("user.dir"));
            File wrapperJar = new File(baseDirectory, MAVEN_WRAPPER_JAR_PATH);
            if(!wrapperJar.exists()) {
                File mavenWrapperPropertiesFile = new File(baseDirectory, MAVEN_WRAPPER_PROPERTIES_PATH);
                Properties mavenWrapperProperties = new Properties();
                if(mavenWrapperPropertiesFile.exists()) {
                    try (FileInputStream mavenWrapperPropertiesFileInputStream = new FileInputStream(mavenWrapperPropertiesFile)) {
                        mavenWrapperProperties.load(mavenWrapperPropertiesFileInputStream);
                    }
                }
                String url = mavenWrapperProperties.getProperty("wrapperUrl", DEFAULT_DOWNLOAD_URL);
                System.out.println("- Downloading from: " + url);
                downloadFileFromURL(url, wrapperJar);
                System.out.println("Done");
            }
        } catch (Throwable e) {
            System.out.println("- Error downloading: " + e.getMessage());
        }
    }

    private static void downloadFileFromURL(String urlString, File destination) throws Exception {
        if(System.getenv("MVNW_USERNAME") != null && System.getenv("MVNW_PASSWORD") != null) {
            String username = System.getenv("MVNW_USERNAME");
            char[] password = System.getenv("MVNW_PASSWORD").toCharArray();
            Authenticator.setDefault(new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });
        }
        URL website = new URL(urlString);
        ReadableByteChannel rbc;
        try (InputStream in = website.openStream(); FileOutputStream fos = new FileOutputStream(destination)) {
            rbc = Channels.newChannel(in);
            fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
        }
    }
}

