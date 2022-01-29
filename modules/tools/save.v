// save.v
module tools
// import json
// import os

// // save_classifier 
// fn save_classifier(cl) ? {
	
// }

// struct User {
//     name string
//     age  int
// mut:
//     is_registered bool
// }
// const (
//     tfolder = os.join_path(os.temp_dir(), 'os_file_test')
//     tfile   = os.join_path(tfolder, 'test_file')
// )

// fn main() {

//     s := '[{"name":"Frodo", "age":25}, {"name":"Bobby", "age":10}]'
//     mut users := json.decode([]User, s) or {
//         eprintln('Failed to parse json')
//         return
//     }
//     for user in users {
//         println('$user.name: $user.age')
//     }
//     println('')
//     for i, mut user in users {
//         println('$i) $user.name')
//         if !user.can_register() {
//             println('Cannot register $user.name, they are too young')
//             continue
//         }
//         // `user` is declared as `mut` in the for loop,
//         // modifying it will modify the array
//         user.register()
//     }
//     // Let's encode users again just for fun
//     println('')
//     println(json.encode(users))
//     println(tfolder)
//     println(tfile)
//     os.rmdir_all(tfolder) or {}
//     assert !os.is_dir(tfolder)
//     os.mkdir_all(tfolder) ?
//     os.chdir(tfolder) ?
//     assert os.is_dir(tfolder)
//     mut f := os.open_file(tfile, 'w') ?
//     f.write_string(json.encode(users)) ?
//     f.close()
// }

// fn (u User) can_register() bool {
//     return u.age >= 16
// }

// fn (mut u User) register() {
//     u.is_registered = true
// }