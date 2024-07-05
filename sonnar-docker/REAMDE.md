# SonarQube


---

SonarQube é uma ferramenta de análise que sistematicamente ajuda você a entregar código com qualidade. Como um elemento 
central da nossa solução de Sonar , SonarQube integra em seu fluxo de trabalho existente e detectar problemas em seu 
código para ajudá-lo a realizar contínuas código de inspeções de seus projetos. O produto análises 30+ de diferentes 
linguagens de programação e integra em sua Integração Contínua (CI) pipeline de DevOps 
plataformas para garantir que seu código atende a padrões de alta qualidade.

Veja mais em https://docs.sonarsource.com/sonarqube/latest/

## Spring - SonarScanner com Maven Jacoco

Comando maven pra rodar scaner sonar em projetos Java Spring que utiliza testes unitários com Jacoco

```shell
mvn clean install sonar:sonar
-Dsonar.projectName=<name projetct>
-Dsonar.projectKey=<id project>
-Dsonar.login=<token user sonar>
-Dsonar.host.url=http://localhost:9000
-Dsonar.test=src/test
-Dsonar.java.coveragePlugin=jacoco
-Dsonar.jacoco.reporPath=target/jacoco.exec
```

---

# Referencias

* Tutorial Sonar: https://www.sonarsource.com/
* [Docker Compose Sonar](https://docs.sonarsource.com/sonarqube/latest/setup-and-upgrade/install-the-server/installing-sonarqube-from-docker/) 
* [Generating and using tokens](https://docs.sonarsource.com/sonarqube/latest/user-guide/user-account/generating-and-using-tokens/)
* [SonarScaner for Maven](https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner-for-maven/)
