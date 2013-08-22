#include <QApplication>
#include <QWidget>
#include "Debug.h"
#include <iostream>

#include <QTabWidget>
#include "MyGraphicsView.h"
#include "ALU.h"
#include "6502.h"
#include "main.h"

MyDebugWindow::MyDebugWindow (QWidget *parent)
{
    resize (900, 600);
    setWindowTitle("Breaks Debug");
    show ();
}

void MyDebugWindow::resizeEvent(QResizeEvent *event)
{
    std::cout << "ResizeEvent" << std::endl;

}

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    pads_6502._NMI = pads_6502._IRQ = pads_6502._RES = 1;
    pads_6502.RDY = 1;
    pads_6502.PHI1 = 1;

    /*
     * Debugger
    */

    MyDebugWindow * debugger = new MyDebugWindow ();

    MyGraphicsView view6502 (debugger, &debug_6502);
    //MyGraphicsView viewALU (debugger, &ALU_debug);

    QTabWidget *tabWidget = new QTabWidget (debugger);
    tabWidget->addTab (&view6502, debug_6502.tabname);
    //tabWidget->addTab (&viewALU, ALU_debug.tabname);
    tabWidget->show ();
    tabWidget->setSizePolicy(QSizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred));
    tabWidget->resize(debugger->width(), debugger->height());

    /*
     * TV.
    */

    //QWidget tv;
    //tv.resize(800, 400);
    //tv.setWindowTitle ("Breaks TV");
    //tv.show();

    return a.exec ();
}
