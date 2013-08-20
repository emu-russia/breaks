#ifndef MYGRAPHICSVIEW_H
#define MYGRAPHICSVIEW_H

#include <QGraphicsView>
#include <QGraphicsRectItem>
#include <QtWidgets>
#include <QCheckBox>
#include <QMessageBox>
#include "Debug.h"

class MyCheckBox;
class TextEdit;

class MyGraphicsView : public QGraphicsView
{
    Q_OBJECT

public:
    MyGraphicsView(QWidget* parent = NULL, DebugContext *debug=NULL);
    MyCheckBox * triggers[1000];
    TextEdit * collectors[1000];
    DebugContext * debugContext;
    bool initialized;

    void updateTriggers ();
    void updateCollectors ();

private slots:
    void NextStepPressed ();
    void LocatorPressed ();

protected:

    //Take over the interaction
    virtual void wheelEvent(QWheelEvent* event);
};

class TextEdit : public QTextEdit
{
public:
        MyGraphicsView * view;
        TextEdit(MyGraphicsView *pv = NULL)
        {
                view = pv;
                setTabChangesFocus(false);
                setWordWrapMode(QTextOption::NoWrap);
                setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
                setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
                setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
                setFixedHeight(sizeHint().height());
        }
        void keyPressEvent(QKeyEvent *event)
        {
                if (event->key() == Qt::Key_Return || event->key() == Qt::Key_Enter)
                {
                    event->ignore();
                    int index = property ("index").toInt();
                    unsigned value = toPlainText ().toUInt(0, 16);
                    if ( view->debugContext->collectors[index].setter)
                        view->debugContext->collectors[index].setter ( value );

                    // update all triggers
                    view->updateTriggers ();
                }
                else
                        QTextEdit::keyPressEvent(event);
        }
        QSize sizeHint() const
        {
                QFontMetrics fm(font());
                int h = qMax(fm.height(), 14) + 4;
                int w = fm.width(QLatin1Char('x')) * 17 + 4;
                QStyleOptionFrameV2 opt;
                opt.initFrom(this);
                return (style()->sizeFromContents(QStyle::CT_LineEdit, &opt, QSize(w, h).
                        expandedTo(QApplication::globalStrut()), this));
        }
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

        if (!view->initialized) return;

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
        for (int i=0; i<view->debugContext->num_triggers; i++)
        {
            if ( view->triggers[i]->trigger_link == trigger_link ) {
                if ( * trigger_link == 0 ) view->triggers[i]->setChecked( false );
                else view->triggers[i]->setChecked( true );
            }
        }

        // Update collectors
        view->updateCollectors ();
    };

};

#endif // MYGRAPHICSVIEW_H
