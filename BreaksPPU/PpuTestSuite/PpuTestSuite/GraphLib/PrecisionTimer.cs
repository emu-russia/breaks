using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;

#region License

/*  
 * Based on the work of  Leslie Sanford  
 */

#endregion


namespace PrecisionTimer
{    
    public enum Mode
    {        
        OneShot,        
        Periodic
    };
    
    [StructLayout(LayoutKind.Sequential)]
    public struct TimerCaps
    {       
        public int periodMin;       
        public int periodMax;
    }

    
    public sealed class Timer : IComponent
    {       
        private delegate void TimeProc(int id, int msg, int user, int param1, int param2);

        private delegate void EventRaiser(EventArgs e);
            
        [DllImport("winmm.dll")]
        private static extern int timeGetDevCaps(ref TimerCaps caps,
                                                 int sizeOfTimerCaps);

        [DllImport("winmm.dll")]
        private static extern int timeSetEvent(int delay, 
                                               int resolution,
                                               TimeProc proc, 
                                               int user, 
                                               int mode);

        [DllImport("winmm.dll")]
        private static extern int timeKillEvent(int id);

        private const int TIMERR_NOERROR = 0;
        
        private int timerID;

        private volatile Mode mode;
        
        private volatile int period;

        private volatile int resolution;        
        
        private TimeProc timeProcPeriodic;

        private TimeProc timeProcOneShot;

        private EventRaiser tickRaiser;

        private bool running = false;

        private volatile bool disposed = false;

        private ISynchronizeInvoke synchronizingObject = null;

        private ISite site = null;

        private static TimerCaps caps;      
         
        public event EventHandler Started;
         
        public event EventHandler Stopped;
         
        public event EventHandler Tick;
         
        static Timer()
        {
            // Get multimedia timer capabilities.
            timeGetDevCaps(ref caps, Marshal.SizeOf(caps));
        }

        
        public Timer(IContainer container)
        {
            
            container.Add(this);

            Initialize();
        }

         
        public Timer()
        {
            Initialize();
        }

        ~Timer()
        {
            if(IsRunning)
            {
                // Stop and destroy timer.
                timeKillEvent(timerID);
            }
        }

        private void Initialize()
        {
            this.mode = Mode.Periodic;
            this.period = Capabilities.periodMin;
            this.resolution = 1;

            running = false;

            timeProcPeriodic = new TimeProc(TimerPeriodicEventCallback);
            timeProcOneShot = new TimeProc(TimerOneShotEventCallback);
            tickRaiser = new EventRaiser(OnTick);
        }

        
        public void Start()
        {
            
            if(disposed)
            {
                throw new ObjectDisposedException("Timer");
            }
 
            if(IsRunning)
            {
                return;
            }
           
            if(Mode == Mode.Periodic)
            {
                 timerID = timeSetEvent(Period, Resolution, timeProcPeriodic, 0, (int)Mode);
            }
            else
            {
                  timerID = timeSetEvent(Period, Resolution, timeProcOneShot, 0, (int)Mode);
            }

            if(timerID != 0)
            {
                running = true;

                if(SynchronizingObject != null && SynchronizingObject.InvokeRequired)
                {
                    SynchronizingObject.BeginInvoke(
                        new EventRaiser(OnStarted), 
                        new object[] { EventArgs.Empty });
                }
                else
                {
                    OnStarted(EventArgs.Empty);
                }                
            }
            else
            {
                throw new TimerException("Unable to start timer.");
            }
        }

        
        public void Stop()
        {
            
            if(disposed)
            {
                throw new ObjectDisposedException("Timer");
            }
                        
            if(!running)
            {
                return;
            }

                       
            int result = timeKillEvent(timerID);

            Debug.Assert(result == TIMERR_NOERROR);

            running = false;

            if(SynchronizingObject != null && SynchronizingObject.InvokeRequired)
            {
                SynchronizingObject.BeginInvoke(
                    new EventRaiser(OnStopped), 
                    new object[] { EventArgs.Empty });
            }
            else
            {
                OnStopped(EventArgs.Empty);
            }
        }        

         
        private void TimerPeriodicEventCallback(int id, int msg, int user, int param1, int param2)
        {
            if(synchronizingObject != null)
            {
                synchronizingObject.BeginInvoke(tickRaiser, new object[] { EventArgs.Empty });
            }
            else
            {
                OnTick(EventArgs.Empty);
            }
        }
      
        private void TimerOneShotEventCallback(int id, int msg, int user, int param1, int param2)
        {
            if(synchronizingObject != null)
            {
                synchronizingObject.BeginInvoke(tickRaiser, new object[] { EventArgs.Empty });
                Stop();
            }
            else
            {
                OnTick(EventArgs.Empty);
                Stop();
            }
        }

        
       
        // Raises the Disposed event.
        private void OnDisposed(EventArgs e)
        {
            EventHandler handler = Disposed;

            if(handler != null)
            {
                handler(this, e);
            }
        }

        // Raises the Started event.
        private void OnStarted(EventArgs e)
        {
            EventHandler handler = Started;

            if(handler != null)
            {
                handler(this, e);
            }
        }

        // Raises the Stopped event.
        private void OnStopped(EventArgs e)
        {
            EventHandler handler = Stopped;

            if(handler != null)
            {
                handler(this, e);
            }
        }

        // Raises the Tick event.
        private void OnTick(EventArgs e)
        {
            EventHandler handler = Tick;

            if(handler != null)
            {
                handler(this, e);
            }
        }

      
       
       

        /// <summary>
        /// Gets or sets the object used to marshal event-handler calls.
        /// </summary>
        public ISynchronizeInvoke SynchronizingObject
        {
            get
            {
                #region Require

                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }

                #endregion

                return synchronizingObject;
            }
            set
            {
                #region Require

                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }

                #endregion

                synchronizingObject = value;
            }
        }

         
        public int Period
        {
            get
            {
                #region Require

                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }

                #endregion

                return period;
            }
            set
            {
                #region Require

                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }
                else if(value < Capabilities.periodMin || value > Capabilities.periodMax)
                {
                    throw new ArgumentOutOfRangeException("Period", value,
                        "Multimedia Timer period out of range.");
                }

                #endregion

                period = value;

                if(IsRunning)
                {
                    Stop();
                    Start();
                }
            }
        }

       
        public int Resolution
        {
            get
            {
                
                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }
                
                return resolution;
            }
            set
            {               
                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }
                else if(value < 0)
                {
                    throw new ArgumentOutOfRangeException("Resolution", value,
                        "timer resolution out of range.");
                }

                resolution = value;

                if(IsRunning)
                {
                    Stop();
                    Start();
                }
            }
        }
        
        public Mode Mode
        {
            get
            {
                
                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }

                
                return mode;
            }
            set
            {
               
                if(disposed)
                {
                    throw new ObjectDisposedException("Timer");
                }

                 
                mode = value;

                if(IsRunning)
                {
                    Stop();
                    Start();
                }
            }
        }

        /// <summary>
        /// Gets a value indicating whether the Timer is running.
        /// </summary>
        public bool IsRunning
        {
            get
            {
                return running;
            }
        }

        /// <summary>
        /// Gets the timer capabilities.
        /// </summary>
        public static TimerCaps Capabilities
        {
            get
            {
                return caps;
            }
        }

      
      
      
        public event System.EventHandler Disposed;

        public ISite Site
        {
            get
            {
                return site;
            }
            set
            {
                site = value;
            }
        }

       
        public void Dispose()
        {
            
            if(disposed)
            {
                return;
            }
            
            if(IsRunning)
            {
                Stop();
            }

            disposed = true;

            OnDisposed(EventArgs.Empty);
        }

        
    }

    
    public class TimerException : ApplicationException
    {       
        public TimerException(string message) : base(message)
        {
        }
    }
}
