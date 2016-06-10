#use "topfind";;
#require "js-build-tools.oasis2opam_install";;

open Oasis2opam_install;;

generate ~package:"typerep_extended"
  [ oasis_lib "json_typerep"
  ; oasis_lib "typerep_bin_io"
  ; oasis_lib "typerep_experimental"
  ; oasis_lib "typerep_extended"
  ; oasis_lib "typerep_sexp"
  ; file "META" ~section:"lib"
  ]
