# org.ddialliance:cvpublishing


* Declare and initialize the GESIS repository visibility property in your `pom.xml`:
    ```xml
    <properties>
      <gesis.repository.visibility>private</gesis.repository.visibility>
    </properties>
    ```

* Add GESIS Maven Repositories to your `pom.xml`:
    ```xml
    <repositories>
      <repository>
        <id>gesis-${gesis.repository.visibility}</id>
          <url>https://maven.gesis.org/repositories/gesis-${gesis.repository.visibility}</url>
      </repository>
    </repositories>
    ```

* Add the dependency to your `pom.xml`:
    ```xml
    <dependency>
      <groupId>org.ddialliance</groupId>
      <artifactId>cvpublishing</artifactId>
      <version>0.0.1-SNAPSHOT</version>
    </dependency>
    ```
