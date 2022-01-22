#include "pch.h"

#ifdef _WINDOWS

void SpinLock::Lock()
{
    while (_InterlockedCompareExchange(&_lock,
        1, // exchange
        0)  // comparand
        == 1)
    {
        // spin!
        _mm_pause();
    }
}

void SpinLock::Unlock()
{
    _InterlockedExchange(&_lock, 0);
}

#endif
