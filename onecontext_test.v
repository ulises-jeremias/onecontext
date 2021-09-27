module onecontext

import context
import time

fn eventually(ch chan int) bool {
	timeout, cancel := context.with_timeout(context.background(), 30 * time.millisecond)
	defer {
		cancel()
	}

	tdone := timeout.done()
	select {
		_ := <-ch {
			return true
		}
		_ := <-tdone {
			return false
		}
	}

	return false
}

struct Value {
	val string
}

fn test_merge_nomilan() {
	foo := &Value{
		val: 'foo'
	}
	ctx1, cancel := context.with_cancel(context.with_value(context.background(), 'foo',
		foo))
	defer {
		cancel()
	}

	bar := &Value{
		val: 'bar'
	}
	ctx2, _ := context.with_cancel(context.with_value(context.background(), 'bar', bar))

	ctx, cancel2 := merge(ctx1, ctx2)

	if deadline := ctx.deadline() {
		panic('this should never happen')
	}

	val1 := ctx.value('foo') or { panic('wrong value access for key `foo`') }
	match val1 {
		Value {
			assert foo == val1
		}
		else {
			assert false
		}
	}

	val2 := ctx.value('bar') or { panic('wrong value access for key `bar`') }
	match val2 {
		Value {
			assert bar == val2
		}
		else {
			assert false
		}
	}

	if _ := ctx.value('baz') {
		panic('this should never happen')
	}

	assert !eventually(ctx.done())
	assert ctx.err() is none

	cancel2()
	assert eventually(ctx.done())
	assert ctx.err() is Error
}

fn test_merge_deadline_context_1() {
	ctx1, cancel := context.with_timeout(context.background(), time.second)
	defer {
		cancel()
	}
	ctx2 := context.background()
	ctx, _ := merge(ctx1, ctx2)

	if deadline := ctx.deadline() {
		assert deadline.unix_time() != 0
	} else {
		panic('this should never happen')
	}
}

fn test_merge_deadline_context_2() {
	ctx1 := context.background()
	ctx2, cancel := context.with_timeout(context.background(), time.second)
	defer {
		cancel()
	}
	ctx, _ := merge(ctx1, ctx2)

	if deadline := ctx.deadline() {
		assert deadline.unix_time() != 0
	} else {
		panic('this should never happen')
	}
}

fn test_merge_deadline_context_n() {
	ctx1 := context.background()

	mut ctxs := []context.Context{cap: 21}
	for i in 0 .. 10 {
		ctxs << context.background()
	}
	ctx_n, _ := context.with_timeout(context.background(), time.second)
	ctxs << ctx_n

	for i in 0 .. 10 {
		ctxs << context.background()
	}

	ctx, cancel := merge(ctx1, ...ctxs)

	assert !eventually(ctx.done())
	assert ctx.err() is none
	cancel()
	assert eventually(ctx.done())
	assert ctx.err() is Error
}

fn test_merge_deadline_none() {
	ctx1 := context.background()
	ctx2 := context.background()

	ctx, _ := merge(ctx1, ctx2)

	if _ := ctx.deadline() {
		panic('this should never happen')
	}
}

fn test_merge_cancel_two() {
	ctx1 := context.background()
	ctx2 := context.background()

	ctx, cancel := merge(ctx1, ctx2)
	cancel()

	assert eventually(ctx.done())
	assert ctx.err() is Error
	assert ctx.err().str() == 'canceled context'
}

fn test_merge_cancel_multiple() {
	ctx1 := context.background()
	ctx2 := context.background()
	ctx3 := context.background()

	ctx, cancel := merge(ctx1, ctx2, ctx3)
	cancel()

	assert eventually(ctx.done())
	assert ctx.err() is Error
	assert ctx.err().str() == 'canceled context'
}
