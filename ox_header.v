// ox_header.v

module hamnn

fn header_test() {
	start := 'i#id,c#status,i#group'
	p := []string{len: 917, init: 'p$it'}
	h := []string{len: 917, init: 'h$it'}
	b := []string{len: 917, init: 'b$it'}
	r1 := []string{len: 917, init: '1r$it'}
	r2 := []string{len: 917, init: '2r$it'}
	println(start + ',' + p.join(',') + ',' + h.join(',') + ',' + b.join(',') + ',' + r1.join(',') + ',' + r2.join(','))
}