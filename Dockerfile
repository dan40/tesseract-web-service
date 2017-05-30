# 
# Stand-alone tesseract-ocr web service in python.
# 
# Version: 0.0.3 
# Developed by Mark Peng (markpeng.ntu at gmail)
# 

FROM ubuntu:12.04

MAINTAINER guitarmind

RUN apt-get update && apt-get install -y \
  autoconf \
  automake \
  autotools-dev \
  build-essential \
  checkinstall \
  git-core \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libtool \
  python \
  python-imaging \
  python-tornado \
  wget \
  zlib1g-dev

RUN mkdir ~/temp \
  && cd ~/temp/ \
  && leptonica-version=1.74.1 \
  && wget http://www.leptonica.org/source/leptonica-${leptonica-version}.tar.gz \
  && tar -zxvf leptonica-${leptonica-version}.tar.gz \
  && cd leptonica-${leptonica-version} \
  && ./configure \
  && make \
  && checkinstall \
  && ldconfig

RUN cd ~/temp/ \
  && git clone https://github.com/tesseract-ocr/tesseract.git \
  && cd tesseract \
  && git checkout tags/3.02.02 \
  && ./autogen.sh \
  && mkdir ~/local \
  && ./configure --prefix=$HOME/local/ \
  && make \
  && make install \
  && cd ~/temp/ \
  && git clone https://github.com/tesseract-ocr/tessdata.git \
  && cd tessdata \
  && git checkout tags/3.04.00 \
  && mkdir -p /root/local/share/tesseract-ocr/tessdata \
  && mv * /root/local/share/tesseract-ocr/tessdata

ENV TESSDATA_PREFIX /root/local/share/tesseract-ocr

RUN mkdir -p /opt/ocr/static

COPY tesseractcapi.py /opt/ocr/tesseractcapi.py
COPY tesseractserver.py /opt/ocr/tesseractserver.py

RUN chmod 755 /opt/ocr/*.py 

EXPOSE 1688

WORKDIR /opt/ocr

CMD ["python", "/opt/ocr/tesseractserver.py", "-p", "1688", "-b", "/root/local/lib", "-d", "/root/local/share/tesseract-ocr" ]

