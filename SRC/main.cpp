#include <QApplication>
#include <QWidget>
#include "Debug.h"

#include <QTabWidget>
#include "MyGraphicsView.h"
#include "ALU.h"
#include "6502.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    pads_6502._NMI = pads_6502._IRQ = pads_6502._RES = 1;
    pads_6502.RDY = 1;
    pads_6502.PHI1 = 1;

    /*
     * Debugger
    */

    QWidget debugger;
    //debugger.resize(800, 400);
    debugger.setWindowTitle("Breaks Debug");
    debugger.show();

    MyGraphicsView view6502 (&debugger, &debug_6502);
    //MyGraphicsView viewALU (&debugger, &ALU_debug);

    QTabWidget *tabWidget = new QTabWidget (&debugger);
    tabWidget->addTab (&view6502, debug_6502.tabname);
    //tabWidget->addTab (&viewALU, ALU_debug.tabname);
    tabWidget->show ();

    /*
     * TV.
    */

    //QWidget tv;
    //tv.resize(800, 400);
    //tv.setWindowTitle ("Breaks TV");
    //tv.show();

    return a.exec ();
}
