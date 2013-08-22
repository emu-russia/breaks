#-------------------------------------------------
#
# Project created by QtCreator 2013-08-16T14:21:57
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Breaks
TEMPLATE = app


SOURCES += main.cpp\
        MyGraphicsView.cpp \
    6502.cpp \
    ALU.cpp

HEADERS  += MyGraphicsView.h \
    Debug.h \
    6502.h \
    ALU.h \
    main.h
