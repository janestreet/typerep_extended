#use "topfind";;
#require "js-build-tools.oasis2opam_install";;

open Oasis2opam_install;;

generate ~package:"typerep_extended"
  [ oasis_lib "typerep_extended"
  ; file "META" ~section:"lib"
  ]
