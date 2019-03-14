This is builder for jtreg that can build latest jtreg for JDK7.

Usage:
1. install JDK7 and maven
2. set alternatives (if necessary) and JAVA_HOME to JDK7
3. run make
4. get jtreg from src/jtreg/build/images

To get tar.gz (required by our infrastructure), go to src/jtreg/build/images directory and run:
tar -czf jtreg-4.2.0-tip.tar.gz jtreg
