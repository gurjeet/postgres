/* -------------------------------------------------------------------------
 *
 * transaction_limiter.c
 *
 * Copyright (C) 2010-2011, PostgreSQL Global Development Group
 *
 * IDENTIFICATION
 *		contrib/transaction_limiter/transaction_limiter.c
 *
 * -------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/xact.h"
#include "storage/pg_sema.h"
#include "storage/shmem.h"
#include "utils/guc.h"

PG_MODULE_MAGIC;

void	_PG_init(void);
void	_PG_fini(void);

static Size xlim_shmem_size(void);
static int xlim_num_sema(void);

static shmem_startup_hook_type prev_shmem_startup_hook = NULL;

/* GUC Variables */
static int xlim_limit;

/* Shared data */
typedef xlimSharedState
{
	int				current_limit;
	int				num_running;
	s_lock			sl_current_limit;
	s_lock			sl_num_running;
	PGSemaphoreData	limiter_sema;

} xlimSharedState;

static xlimSharedState *xlim;

static Size
xlim_shmem_size()
{
	return sizeof(xlim_shared);
}

static int
xlim_num_sema()
{
	/* We need one semaphore for our purpose */
	return 1;
}

/*
 * Module Load Callback
 */
void
_PG_init(void)
{
	/* Define custom GUC variables */
	DefineCustomIntVariable("transaction_limiter.limit",
			 "Limit the number of active transactions to this.",
							NULL,
							&xlim_limit,
							0,
							0, INT_MAX,
							PGC_SIGHUP,
							0,
							NULL,
							NULL,
							NULL);

	/* Register callback */
	RegisterXactCallback(xlimCallback, NULL);

	/* Request shared memory for our use */
	RequestAddinShmemSpace(xlim_shmem_size());

	/* Request semaphores for our use */
	RequestAddinSemaphores(xlim_num_sema());

	prev_shmem_startup_hook = shmem_startup_hook;
	shmem_startup_hook = xlim_init;
}

/*
 * Module unload callback
 */
void
_PG_fini(void)
{
	shmem_startup_hook = prev_shmem_startup_hook;
}

void
xlim_init(void)
{
	bool found;

	LWLockAcquire(AddinShmemInitLock, LW_EXCLUSIVE);

	xlim = ShmemInitStruct("transaction_limiter",
						   sizeof(xlimSharedState),
						   &found);

	if (!found)
	{
		/* First time through ... */
		pgss->lock = LWLockAssign();
		pgss->query_size = pgstat_track_activity_query_size;
		pgss->cur_median_usage = ASSUMED_MEDIAN_INIT;
	}

	/* Be sure everyone agrees on the hash table entry size */
	query_size = pgss->query_size;

	memset(&info, 0, sizeof(info));
	info.keysize = sizeof(pgssHashKey);
	info.entrysize = offsetof(pgssEntry, query) +query_size;
	info.hash = pgss_hash_fn;
	info.match = pgss_match_fn;
	pgss_hash = ShmemInitHash("pg_stat_statements hash",
							  pgss_max, pgss_max,
							  &info,
							  HASH_ELEM | HASH_FUNCTION | HASH_COMPARE);

	LWLockRelease(AddinShmemInitLock);


	

}

static void
xlimCallback(XactEvent event, void *arg)
{
	/* We do nothing in bootstrap or standalone mode of operation */
	if (!IsUnderPostmaster)
		return;

	switch (event)
	{
		case XACT_EVENT_COMMIT:
		case XACT_EVENT_ABORT:
		case XACT_EVENT_PREPARE:
		case XACT_EVENT_PRE_START:
		default:
			Assert(false);
			break;
	}
}



