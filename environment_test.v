// environment_test.v

module hamnn

// test_get_vmod
fn test_get_vmod() {
	// println('HamNN version: $get_package_version()')
}

// test_get_environment
fn test_get_environment() {
	mut env := Environment{}
	env = get_environment()
	// println(env)
	assert env.v_full_version[0..1] == 'V'
}
