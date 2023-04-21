# FROM ubuntu:latest
FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-runtime
# 1. COPY all the source code.
RUN mkdir rfcnlp
COPY . rfcnlp/
# We will need this later ...
RUN apt-get install -y gzip
# 2. Install other dependencies
# 2.1. Stuff in requirements.txt
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y apt-utils python3-pip
WORKDIR rfcnlp
RUN python3 -m pip install --upgrade pip
RUN pip3 install numpy==1.21
RUN pip3 install --upgrade transitions
RUN pip3 install --upgrade networkx
RUN pip3 install --upgrade matplotlib
RUN pip3 install --upgrade cython
RUN pip3 install --upgrade deepwalk
RUN pip3 install --upgrade python-Levenshtein
RUN pip3 install --upgrade lxml
RUN pip3 install --upgrade graphviz
RUN pip3 install --upgrade tabulate
RUN pip3 install spacy==2.2.4
RUN pip3 install spacy-legacy==3.0.8
RUN pip3 install tqdm==4.62.3
RUN pip3 install scikit-learn==1.0
RUN apt-get install -y build-essential   \
                       python-dev        \
                       python-setuptools \
                       git
RUN pip3 install scipy==1.3.3
RUN pip3 install torchvision==0.8.2
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN git clone https://github.com/pystruct/pystruct.git
WORKDIR pystruct
RUN rm src/utils.c
RUN cython src/utils.pyx
RUN python3 setup.py install
WORKDIR ..
RUN pip3 install allennlp==2.0.0
RUN pip3 install --upgrade nltk 
# # 2.2. Install Apache OpenNLP - https://hub.docker.com/r/casetext/opennlp/dockerfile
RUN apt-get install -y openjdk-8-jdk curl maven
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME
RUN mkdir /models
RUN apt-get install -y wget
RUN curl -o /models/en-ud-ewt-sentence.bin https://www.apache.org/dyn/closer.cgi/opennlp/models/ud-models-1.0/opennlp-en-ud-ewt-sentence-1.0-1.9.3.bin
RUN curl -o /models/en-ud-ewt-pos.bin https://www.apache.org/dyn/closer.cgi/opennlp/models/ud-models-1.0/opennlp-en-ud-ewt-pos-1.0-1.9.3.bin
RUN curl -o /models/en-ud-ewt-tokens.bin https://www.apache.org/dyn/closer.cgi/opennlp/models/ud-models-1.0/opennlp-en-ud-ewt-tokens-1.0-1.9.3.bin
RUN wget https://archive.apache.org/dist/opennlp/opennlp-1.9.3/apache-opennlp-1.9.3-bin.tar.gz
RUN tar -xvzf apache-opennlp-1.9.3-bin.tar.gz
RUN mv apache-opennlp-* /usr/bin/.
# 2.3. Install our updated version of KORG
RUN git clone https://github.com/RFCNLP/RFCNLP-korg.git korg-update
WORKDIR korg-update
RUN pip3 install .
# 3. Install spin.
WORKDIR ..
RUN git clone https://github.com/nimble-code/Spin.git
WORKDIR Spin
RUN apt-get install -y bison flex
# RUN make install
WORKDIR Bin
RUN gunzip spin651_linux64.gz
RUN chmod +x spin651_linux64
RUN cp spin651_linux64 /usr/local/bin/spin
RUN apt-get install -y graphviz
WORKDIR ..
# 4. Install some stuff for the NLP pipeline
RUN pip3 install allennlp==2.0.0
RUN pip3 install allennlp-models==2.0.0
RUN pip3 install nltk==3.6.5
RUN python3 -m spacy download en_core_web_sm
RUN echo "import nltk; nltk.download('averaged_perceptron_tagger')" | python3
RUN pip3 install transformers==4.2.2
WORKDIR ..
entrypoint [""]
