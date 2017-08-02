<?xml version="1.0" encoding="utf-8"?>
<!--
   ====================================================================================

   Atlassian JIRA Standalone Edition Tomcat Configuration.


   See the following for more information

   http://confluence.atlassian.com/display/JIRA/Configuring+JIRA+Standalone

   ====================================================================================
 -->
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<Server port="8005" shutdown="SHUTDOWN">
    <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
    <!-- Security listener. Documentation at /docs/config/listeners.html
    <Listener className="org.apache.catalina.security.SecurityListener" />
    -->
    <!--APR library loader. Documentation at /docs/apr.html -->
    <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
    <!-- Prevent memory leaks due to use of particular java/javax APIs-->
    <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
    <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
    <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

    <!-- Global JNDI resources
         Documentation at /docs/jndi-resources-howto.html
    -->

    <!-- A "Service" is a collection of one or more "Connectors" that share
        a single "Container" Note:  A "Service" is not itself a "Container",
        so you may not define subcomponents such as "Valves" at this level.
        Documentation at /docs/config/service.html
    -->
    <Service name="Catalina">

        <Connector port="8080"

                   maxThreads="150"
                   minSpareThreads="25"
                   connectionTimeout="20000"

                   enableLookups="false"
                   maxHttpHeaderSize="8192"
                   protocol="HTTP/1.1"
                   useBodyEncodingForURI="true"
                   redirectPort="8443"
                   acceptCount="100"
                   disableUploadTimeout="true"
                   bindOnInit="false"
                   {{ if getenv "JIRA_HTTPS" }}
                   proxyPort="443"
                   secure="true"
                   scheme="https"
                   {{ end }}
        />
        <!--
        ====================================================================================

        For full steps on running JIRA over SSL or HTTPS for production and testing, see:
            http://confluence.atlassian.com/display/JIRA/Running+JIRA+over+SSL+or+HTTPS
        and
            http://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html

        A quicker method can be found below, which we recommend only for evaluation and demonstration:

            * Uncomment the Connector below
            * Execute:
                %JAVA_HOME%\bin\keytool -genkey -alias tomcat -keyalg RSA (Windows) 
                $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA (Unix) 
                with a password value of "changeit" for both the certificate and the keystore itself.
            * If you are on JDK1.3 or earlier, download and install JSSE 1.0.2 or later, and put the JAR files into "$JAVA_HOME/jre/lib/ext"
            * Restart and visit https://localhost:8443/

        ====================================================================================
        -->
        <!--
            <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
              maxHttpHeaderSize="8192" SSLEnabled="true"
              maxThreads="150" minSpareThreads="25"
              enableLookups="false" disableUploadTimeout="true"
              acceptCount="100" scheme="https" secure="true"
              clientAuth="false" sslProtocol="TLS" useBodyEncodingForURI="true"
              keystoreFile="/opt/bamboo-agent/.keystore"/>
        -->


        <!--
         ====================================================================================

         If you have Apache AJP Connector (mod_ajp) as a proxy in front of JIRA you should uncomment the following connector configuration line

         See the following for more information :

            http://confluence.atlassian.com/display/JIRA/Configuring+Apache+Reverse+Proxy+Using+the+AJP+Protocol

         ====================================================================================
        -->

        <!--
              <Connector port="8009" redirectPort="8443" enableLookups="false" protocol="AJP/1.3" URIEncoding="UTF-8"/>
        -->

        <Engine name="Catalina" defaultHost="localhost">
            <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">

                <Context path="" docBase="${catalina.home}/atlassian-jira" reloadable="false" useHttpOnly="true">


                    <!--
                     ====================================================================================

                     Note, you no longer configure your database driver or connection parameters here.
                     These are configured through the UI during application setup.

                     ====================================================================================
                    -->

                    <Resource name="UserTransaction" auth="Container" type="javax.transaction.UserTransaction"
                              factory="org.objectweb.jotm.UserTransactionFactory" jotm.timeout="60"/>
                    <Manager pathname=""/>
                    <JarScanner scanManifest="false"/>
                </Context>

            </Host>

            <!--
                ====================================================================================

                 Access Logging.

                 This should produce access_log.<date> files in the 'logs' directory.

                 The output access log lies has the following fields :

                 IP Request_Id User Timestamp  "HTTP_Method URL Protocol_Version" HTTP_Status_Code ResponseSize_in_Bytes RequestTime_In_Millis Referer User_Agent ASESSIONID

                 eg :

                 192.168.3.238 1243466536012x12x1 admin [28/May/2009:09:22:17 +1000] "GET /jira/secure/admin/jira/IndexProgress.jspa?taskId=1 HTTP/1.1" 200 24267 1070 "http://carltondraught.sydney.atlassian.com:8090/jira/secure/admin/jira/IndexAdmin.jspa" "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.10) Gecko/2009042523 Ubuntu/9.04 (jaunty) Firefox/3.0.10" "C2C99B632EE0F41E90F8EF7A201F6A78"

                 NOTES:

                 The RequestId is a millis_since_epoch plus request number plus number of concurrent users

                 The Request time is in milliseconds

                 The ASESSIONID is an hash of the JSESSIONID and hence is safe to publish within logs.  A session cannot be reconstructed from it.

                 See http://tomcat.apache.org/tomcat-6.0-doc/config/valve.html for more information on Tomcat Access Log Valves

                ====================================================================================

            -->
            <Valve className="org.apache.catalina.valves.AccessLogValve"
                   pattern="%a %{jira.request.id}r %{jira.request.username}r %t &quot;%m %U%q %H&quot; %s %b %D &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot; &quot;%{jira.request.assession.id}r&quot;"/>

        </Engine>
    </Service>
</Server>