
#pragma once

#if defined(_WINDOWS) || defined(_PLAYGROUND_WINDOWS)

class SpinLock
{
    volatile long _lock = 0;

public:
    void Lock();
    void Unlock();
};

#endif

#ifdef _LINUX

class SpinLock
{
    std::atomic_flag locked = ATOMIC_FLAG_INIT;
public:

    void Lock()
    {
        while (locked.test_and_set(std::memory_order_acquire)) { ; }
    }

    void Unlock()
    {
        locked.clear(std::memory_order_release);
    }
};

#endif
