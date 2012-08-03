// Windows video subsystem

namespace VID
{
    bool    Init (HWND hwnd);
    void    Shutdown (void);
    void    Redraw ( u8 * LogicScreen );
    void    WMPaint (void);
}