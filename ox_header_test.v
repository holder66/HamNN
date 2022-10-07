// ox_header.v

module hamnn

fn test_header_test() {
	start := 'i#id\tc#status\ti#group'
	p := []string{len: 917, init: 'p${(it + 1)}'}
	// h := []string{len: 917, init: 'h$it'}
	// b := []string{len: 917, init: 'b$it'}
	// r1 := []string{len: 917, init: '1r$it'}
	// r2 := []string{len: 917, init: '2r$it'}
	println(start + '\t' + p.join('\t'))
}