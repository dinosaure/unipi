open Mirage

let hook =
  let doc = Key.Arg.info ~doc:"Webhook (no / allowed)." ["hook"] in
  Key.(create "hook" Arg.(opt string "hook" doc))

let remote =
  let doc = Key.Arg.info
      ~doc:"Remote repository url, use suffix #foo to specify a branch 'foo': \
            https://github.com/hannesm/unipi.git#gh-pages"
      ["remote"]
  in
  Key.(create "remote" Arg.(required string doc))

let port =
  let doc = Key.Arg.info ~doc:"HTTP listen port." ["port"] in
  Key.(create "port" Arg.(opt int 80 doc))

let tls =
  let doc = Key.Arg.info ~doc:"Enable TLS." ["tls"] in
  Key.(create "tls" Arg.(opt bool false doc))

let ssh_seed =
  let doc = Key.Arg.info ~doc:"Seed for ssh private key." ["ssh-seed"] in
  Key.(create "ssh_seed" Arg.(opt (some string) None doc))

let ssh_authenticator =
  let doc = Key.Arg.info ~doc:"SSH host key authenticator." ["ssh-authenticator"] in
  Key.(create "ssh_authenticator" Arg.(opt (some string) None doc))

let hostname =
  let doc = Key.Arg.info ~doc:"Host name." ["hostname"] in
  Key.(create "hostname" Arg.(opt (some string) None doc))

let production =
  let doc = Key.Arg.info ~doc:"Let's encrypt production environment." ["production"] in
  Key.(create "production" Arg.(opt bool false doc))

let cert_seed =
  let doc = Key.Arg.info ~doc:"Let's encrypt certificate seed." ["cert-seed"] in
  Key.(create "cert_seed" Arg.(opt (some string) None doc))

let account_seed =
  let doc = Key.Arg.info ~doc:"Let's encrypt account seed." ["account-seed"] in
  Key.(create "account_seed" Arg.(opt (some string) None doc))

let email =
  let doc = Key.Arg.info ~doc:"Let's encrypt E-Mail." ["email"] in
  Key.(create "email" Arg.(opt (some string) None doc))

let packages = [
  package ~min:"2.0.0" "irmin";
  package ~min:"2.0.0" "irmin-mirage";
  package ~min:"2.0.0" "irmin-mirage-git";
  package "cohttp-mirage";
  package "tls-mirage";
  package "magic-mime";
  package "logs";
  package "awa-conduit";
  package "conduit-tls";
  package ~sublibs:["tcp";"dns"] "conduit-mirage";
  package "git";
  package "git-mirage";
  package "letsencrypt";
]

let stack = generic_stackv4v6 default_network

let () =
  let keys = Key.([
      abstract hook; abstract remote;
      abstract port; abstract tls;
      abstract ssh_seed; abstract ssh_authenticator;
      abstract hostname; abstract production; abstract cert_seed;
      abstract account_seed; abstract email;
    ])
  in
  register "unipi" [
    foreign
      ~keys
      ~packages
      "Unikernel.Main"
      (stackv4v6 @-> pclock @-> mclock @-> time @-> random @-> job)
    $ stack
    $ default_posix_clock
    $ default_monotonic_clock
    $ default_time
    $ default_random
  ]
