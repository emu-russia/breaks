#ifndef MYGRAPHICSVIEW_H
#define MYGRAPHICSVIEW_H

#include <QGraphicsView>
#include <QGraphicsRectItem>
#include <QtWidgets>
#include <QCheckBox>
#include <QMessageBox>
#include "Debug.h"

class MyCheckBox;

class MyGraphicsView : public QGraphicsView
{
    Q_OBJECT

public:
    MyGraphicsView(QWidget* parent = NULL, DebugContext *debug=NULL);
    MyCheckBox * triggers[1000];
    int num_triggers;
    DebugContext * debugContext;

private slots:
    void NextStepPressed ();
    void LocatorPressed ();

protected:

    //Take over the interaction
    virtual void wheelEvent(QWheelEvent* event);
};

//Derived Class from QCheckBox
class MyCheckBox: public QCheckBox
{
  Q_OBJECT
  public:
    MyGraphicsView * view;
    MyCheckBox(const QString & text, QWidget* parent, int * linkage = NULL, MyGraphicsView *pv = NULL )
    {
      view = pv;
      trigger_link = linkage;
      this->setText( text );
      this->setParent(parent);
      connect(this , SIGNAL(stateChanged(int)),this,SLOT(checkBoxStateChanged(int)));
    };
    ~ MyCheckBox(){};

    int * trigger_link;

  public slots:
    //Slot that is called when CheckBox is checked or unchecked
    void checkBoxStateChanged(int state)
    {
        QMessageBox* msg = new QMessageBox(this->parentWidget());
        msg->setWindowTitle("Hello !");

        if(state)
        {
          msg->setText("Trigger Set !");
          *trigger_link = 1;
        }
        else
        {
          msg->setText("Trigger Clear !");
          *trigger_link = 0;
        }
        //msg->show();

        // Find all triggers with same link.
        for (int i=0; i<view->num_triggers; i++)
        {
            if ( view->triggers[i]->trigger_link == trigger_link ) {
                if ( * trigger_link == 0 ) view->triggers[i]->setChecked( false );
                else view->triggers[i]->setChecked( true );
            }
        }

    };

};

#endif // MYGRAPHICSVIEW_H
