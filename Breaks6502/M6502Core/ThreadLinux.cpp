#include "pch.h"

// Thanks for the example implementation.
// https://stackoverflow.com/questions/9397068/how-to-pause-a-pthread-any-time-i-want

// Whoever removed suspend / resume from pthread is not a good person.

void* Thread::RingleaderThreadProc(void* args)
{
	Thread* thread = (Thread*)args;

	while (!thread->terminated)
	{
		pthread_mutex_lock(&thread->mutex);

		switch (thread->command)
		{
			// command to pause thread..
			case 0:
				pthread_cond_wait(&thread->cond_var, &thread->mutex);
				break;

			// command to run..
			case 1:
				if (thread->ctx.proc)
				{
					thread->ctx.proc(thread->ctx.context);
				}
				break;
		}

		pthread_mutex_unlock(&thread->mutex);

		// it's important to give main thread few time after unlock 'this'
		pthread_yield();
	}

	thread->terminated = false;

	pthread_exit(nullptr);
}

Thread::Thread(ThreadProc threadProc, bool suspended, void* context, const char* name)
{
	running = !suspended;
	threadName = name;

	ctx.context = context;
	ctx.proc = threadProc;

	pthread_mutex_init(&mutex, nullptr);
	pthread_cond_init(&cond_var, nullptr);

	// create thread in suspended state..
	command = running ? 1 : 0;

	int status = pthread_create(&threadId, nullptr, Thread::RingleaderThreadProc, this);
	assert(status == 0);
}

Thread::~Thread()
{
	terminated = true;

	// Run if suspended
	if (!running)
	{
		Resume();
	}

	// Wait terminated
	while (terminated)
	{
		Thread::Sleep(1);
	}

	pthread_join(threadId, nullptr);

	pthread_cond_destroy(&cond_var);
	pthread_mutex_destroy(&mutex);
}

void Thread::Resume()
{
	resumeLock.Lock();
	if (!running)
	{
		pthread_mutex_lock(&mutex);
		command = 1;
		pthread_cond_signal(&cond_var);
		pthread_mutex_unlock(&mutex);

		running = true;
		resumeCounter++;
	}
	resumeLock.Unlock();
}

void Thread::Suspend()
{
	if (running)
	{
		running = false;
		suspendCounter++;

		pthread_mutex_lock(&mutex);
		command = 0;
		// in pause command we dont need to signal cond_var because we not in wait state now..
		pthread_mutex_unlock(&mutex);
	}
}

void Thread::Sleep(size_t milliseconds)
{
	usleep(milliseconds * 1000);
}
