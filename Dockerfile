# 
# Stand-alone tesseract-ocr web service in python.
# 
# Version: 0.0.5
# Developed by Mark Peng (markpeng.ntu at gmail), Jordan Dukadinov (jdukadinov at gmail)
# 

FROM ubuntu:16.04

MAINTAINER guitarmind, dan40

RUN apt-get update && apt-get install -y \
  autoconf \
  autoconf-archive \
  automake \
  autotools-dev \
  build-essential \
  checkinstall \
  git-core \
  libicu-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libtool \
  pkg-config \
  python \
  python-imaging \
  python-tornado \
  wget \
  zlib1g-dev

RUN mkdir ~/temp \
  && cd ~/temp/ \
  && wget http://www.leptonica.org/source/leptonica-1.74.1.tar.gz \
  && tar -zxvf leptonica-1.74.1.tar.gz \
  && cd leptonica-1.74.1 \
  && ./configure \
  && make \
  && checkinstall \
  && ldconfig

RUN cd ~/temp/ \
  && git clone https://github.com/tesseract-ocr/tesseract.git \
  && cd tesseract \
  && ./autogen.sh \
  && mkdir ~/local \
  && autoreconf -ivf \
  && ./configure --prefix=$HOME/local/ \
  && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make \
  && make install \
  && cd ~/temp/ \
  && git clone https://github.com/tesseract-ocr/tessdata.git \
  && cd tessdata \
  && git checkout tags/4.00 \
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

