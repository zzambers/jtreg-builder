# Copyright (c) 2018 Zdenek Zambersky
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

TOP_DIR=$(shell pwd)

SRC_DIR=$(TOP_DIR)/src
CODE_TOOLS_URL=http://hg.openjdk.java.net/code-tools
PATCHES_DIR=$(TOP_DIR)/patches

JTREG_TAG=tip
JTREG_REPO_URL=$(CODE_TOOLS_URL)/jtreg
#JTREG_DL_URL=$(JTREG_REPO_URL)/archive/${JTREG_TAG}.zip
JTREG_SRC_DIR=$(SRC_DIR)/jtreg
JTREG_DIST_DIR=$(JTREG_SRC_DIR)/build

ANT_VERSION=1.9.11
ANT_DL_URL=https://archive.apache.org/dist/ant/source/apache-ant-$(ANT_VERSION)-src.tar.gz
ANT_SRC_DIR=$(SRC_DIR)/apache-ant-$(ANT_VERSION)
ANT_DIST_DIR=$(ANT_SRC_DIR)/dist
ANT_JAR=$(ANT_DIST_DIR)/lib/ant.jar
ANT=$(ANT_DIST_DIR)/bin/ant

JUNIT_VERSION=4.10
JUNIT_TAG=r$(JUNIT_VERSION)
JUNIT_DL_URL=https://github.com/junit-team/junit4/archive/$(JUNIT_TAG).tar.gz
JUNIT_SRC_DIR=$(SRC_DIR)/junit4-$(JUNIT_TAG)
JUNIT_DIST_DIR=$(JUNIT_SRC_DIR)/junit$(JUNIT_VERSION)

TESTNG_VERSION=6.9.10
TESTNG_DL_URL=https://github.com/cbeust/testng/archive/$(TESTNG_VERSION).tar.gz
TESTNG_SRC_DIR=$(SRC_DIR)/testng-$(TESTNG_VERSION)
TESTNG_DIST_DIR=$(TESTNG_SRC_DIR)/build

JTHARNESS_VERSION=5.0-b01
JTHARNESS_TAG=jt$(JTHARNESS_VERSION)
JTHARNESS_DL_URL=$(CODE_TOOLS_URL)/jtharness/archive/${JTHARNESS_TAG}.zip
JTHARNESS_SRC_DIR=$(SRC_DIR)/jtharness-$(JTHARNESS_TAG)
JTHARNESS_DIST_DIR=$(SRC_DIR)/JTHarness-build

ASMTOOLS_VERSION=6.0
ASMTOOLS_DL_URL=$(CODE_TOOLS_URL)/asmtools/archive/${ASMTOOLS_VERSION}.zip
ASMTOOLS_SRC_DIR=$(SRC_DIR)/asmtools-$(ASMTOOLS_VERSION)
ASMTOOLS_DIST_DIR=$(SRC_DIR)/asmtools-$(ASMTOOLS_VERSION)-build
ASMTOOLS_PATCH=$(PATCHES_DIR)/asmtools-$(ASMTOOLS_VERSION)-jdk7.patch

ASM_VERSION=6.0
ASM_DL_URL=http://download.forge.ow2.org/asm/asm-$(ASM_VERSION).tar.gz
ASM_CONF_DL_URL=https://gitlab.ow2.org/asm/asm/raw/ASM_6_0
ASM_SRC_DIR=$(SRC_DIR)/asm-$(ASM_VERSION)
ASM_DIST_DIR=$(ASM_SRC_DIR)/output/dist

JCOV_VERSION=3.0-b04
JCOV_TAG=jcov$(JCOV_VERSION)
JCOV_DL_URL=$(CODE_TOOLS_URL)/jcov/archive/${JCOV_TAG}.zip
JCOV_SRC_DIR=$(SRC_DIR)/jcov-${JCOV_TAG}
JCOV_DIST_DIR=$(JCOV_SRC_DIR)/JCOV_BUILD/jcov_$(shell printf '%s' "$(JCOV_VERSION)" | sed 's/-.*//g' )

JCOMMANDER_VERSION=1.48
JCOMMANDER_TAG=jcommander-$(JCOMMANDER_VERSION)
JCOMMANDER_DL_URL=https://github.com/cbeust/jcommander/archive/$(JCOMMANDER_TAG).tar.gz
JCOMMANDER_SRC_DIR=$(SRC_DIR)/jcommander-$(JCOMMANDER_TAG)
JCOMMANDER_DIST_DIR=$(JCOMMANDER_SRC_DIR)/target

.PHONY: ant junit testng jtharness asmtools jcov jcommander jtreg

jtreg: $(JTREG_DIST_DIR)

jcommander: $(JCOMMANDER_DIST_DIR)

jcov: $(JCOV_DIST_DIR)

asm: $(ASM_DIST_DIR)

asmtools: $(ASMTOOLS_DIST_DIR)

jtharness: $(JTHARNESS_DIST_DIR)

testng: $(TESTNG_DIST_DIR)

junit: $(JUNIT_DIST_DIR)

ant: $(ANT_DIST_DIR)

clean:
	rm -rf "$(SRC_DIR)"


$(SRC_DIR):
	mkdir "$(SRC_DIR)"


$(ANT_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(ANT_DL_URL)" > "$(SRC_DIR)/apache-ant-$(ANT_VERSION).tar.gz" && \
	tar -xf "apache-ant-$(ANT_VERSION).tar.gz"

$(ANT_DIST_DIR): | $(ANT_SRC_DIR)
	unset ANT_HOME && \
	cd "$(ANT_SRC_DIR)" && \
	./build.sh


$(JUNIT_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(JUNIT_DL_URL)" > "$(SRC_DIR)/junit4-$(JUNIT_TAG).tar.gz" && \
	tar -xf "junit4-$(JUNIT_TAG).tar.gz"

$(JUNIT_DIST_DIR): | $(JUNIT_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(JUNIT_SRC_DIR)" && \
	$(ANT) populate-dist


$(TESTNG_SRC_DIR): | $(SRC_DIR) $(ANT_DIST_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(TESTNG_DL_URL)" > "$(SRC_DIR)/testng-$(TESTNG_VERSION).tar.gz" && \
	tar -xf "testng-$(TESTNG_VERSION).tar.gz"

$(TESTNG_DIST_DIR): | $(TESTNG_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(TESTNG_SRC_DIR)" && \
	./build-with-gradle


$(JTHARNESS_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(JTHARNESS_DL_URL)" > "$(SRC_DIR)/jtharness-$(JTHARNESS_TAG).zip" && \
	unzip "jtharness-$(JTHARNESS_TAG).zip"

$(JTHARNESS_DIST_DIR): | $(JTHARNESS_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(JTHARNESS_SRC_DIR)/build" && \
	$(ANT)


$(ASMTOOLS_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(ASMTOOLS_DL_URL)" > "$(SRC_DIR)/asmtools-$(ASMTOOLS_VERSION).zip" && \
	unzip "asmtools-$(ASMTOOLS_VERSION).zip"
	cd "$(ASMTOOLS_SRC_DIR)" && \
	patch -p1 < "$(ASMTOOLS_PATCH)"

$(ASMTOOLS_DIST_DIR): | $(ASMTOOLS_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(ASMTOOLS_SRC_DIR)/build" && \
	$(ANT)


$(ASM_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(ASM_DL_URL)" > "$(SRC_DIR)/asm-$(ASM_VERSION).tar.gz" && \
	tar -xf "asm-$(ASM_VERSION).tar.gz"
	curl -L -f "$(ASM_CONF_DL_URL)/build.config" > "$(ASM_SRC_DIR)/build.config"
	mkdir "$(ASM_SRC_DIR)/config"
	curl -L -f "$(ASM_CONF_DL_URL)/config/biz.aQute.bnd-3.2.0.jar" \
	> "$(ASM_SRC_DIR)/config/biz.aQute.bnd-3.2.0.jar"

$(ASM_DIST_DIR): | $(ASM_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(ASM_SRC_DIR)" && \
	$(ANT) jar


$(JCOV_SRC_DIR): | $(SRC_DIR) $(JTHARNESS_DIST_DIR) $(ASM_DIST_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(JCOV_DL_URL)" > "$(SRC_DIR)/jcov-$(JCOV_TAG).zip" && \
	unzip "jcov-$(JCOV_TAG).zip"
	cd "$(JCOV_SRC_DIR)/build" && \
	cp "$(JTHARNESS_DIST_DIR)/binaries/lib/javatest.jar" . && \
	cp "$(ASM_DIST_DIR)/lib/asm-6.0.jar" . && \
	cp "$(ASM_DIST_DIR)/lib/asm-tree-6.0.jar" . && \
	cp "$(ASM_DIST_DIR)/lib/asm-util-6.0.jar" . && \
	sed -i "s/^asm.checksum =.*/asm.checksum = $$( sha1sum asm-6.0.jar )/g" build.properties && \
	sed -i "s/^asm.tree.checksum =.*/asm.tree.checksum = $$( sha1sum asm-tree-6.0.jar )/g" build.properties && \
	sed -i "s/^asm.util.checksum =.*/asm.util.checksum = $$( sha1sum asm-util-6.0.jar )/g" build.properties

$(JCOV_DIST_DIR): | $(JCOV_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(JCOV_SRC_DIR)/build" && \
	$(ANT)


$(JCOMMANDER_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	curl -L -f "$(JCOMMANDER_DL_URL)" > "$(SRC_DIR)/jcommander-$(JCOMMANDER_TAG).tar.gz" && \
	tar -xf "jcommander-$(JCOMMANDER_TAG).tar.gz"

$(JCOMMANDER_DIST_DIR): | $(JCOMMANDER_SRC_DIR) $(ANT_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(JCOMMANDER_SRC_DIR)" && \
	./build-with-maven


$(JTREG_SRC_DIR): | $(SRC_DIR)
	cd "$(SRC_DIR)" && \
	hg clone -r "$(JTREG_TAG)" "$(JTREG_REPO_URL)"
#	cd "$(SRC_DIR)" && \
#	curl -L -f "$(JTREG_DL_URL)" > "$(SRC_DIR)/jtreg.zip" && \
#	unzip jtreg.zip && \
#	rm jtreg.zip && \
#	mv jtreg* jtreg

$(JTREG_DIST_DIR): | $(JTREG_SRC_DIR) $(JUNIT_DIST_DIR) $(TESTNG_DIST_DIR) \
    $(JCOMMANDER_DIST_DIR) $(ANT_DIST_DIR) $(JCOV_DIST_DIR) \
    $(JTHARNESS_DIST_DIR) $(ASMTOOLS_DIST_DIR)
	export ANT_HOME=$(ANT_DIST_DIR) && \
	cd "$(JTREG_SRC_DIR)/make" && \
	make JUNIT_JAR=$(JUNIT_DIST_DIR)/junit-$(JUNIT_VERSION).jar \
		 JUNIT_LICENSE=$(JUNIT_SRC_DIR)/LICENSE \
		 TESTNG_JAR=$(TESTNG_DIST_DIR)/libs/testng-$(TESTNG_VERSION)-SNAPSHOT.jar \
		 TESTNG_LICENSE=$(TESTNG_SRC_DIR)/LICENSE.txt \
		 JCOMMANDER_JAR=$(JCOMMANDER_DIST_DIR)/jcommander-$(JCOMMANDER_VERSION).jar \
		 ANT=$(ANT) \
		 ANT_JAR=$(ANT_JAR) \
		 JCOV_JAR=$(JCOV_DIST_DIR)/jcov.jar \
		 JCOV_LICENSE=$(JCOV_SRC_DIR)/LICENSE \
		 JCOV_NETWORK_SAVER_JAR=$(JCOV_DIST_DIR)/jcov_network_saver.jar \
		 JAVATEST_JAR=$(JTHARNESS_DIST_DIR)/binaries/lib/javatest.jar \
		 JTHARNESS_LICENSE=$(JTHARNESS_SRC_DIR)/legal/license.txt \
		 JTHARNESS_COPYRIGHT=$(JTHARNESS_SRC_DIR)/legal/copyright.txt \
		 ASMTOOLS_JAR=$(ASMTOOLS_DIST_DIR)/binaries/lib/asmtools.jar \
		 ASMTOOLS_LICENSE=$(ASMTOOLS_SRC_DIR)/LICENSE \
		 JDKHOME="$${JAVA_HOME}" \
		 #${MAKE_ARGS:-}
		 # BUILD_VERSION=tip \
		 # BUILD_MILESTONE="${BUILD_MILESTONE:=dev}" \
		 # BUILD_NUMBER=""	\
