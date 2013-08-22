#pragma once

#include <QWidget>

class MyDebugWindow : public QWidget
{
    Q_OBJECT

public:
    MyDebugWindow (QWidget *parent = 0);

protected:
    void resizeEvent (QResizeEvent *event);
};
