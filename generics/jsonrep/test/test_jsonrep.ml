open Core.Std
open Typerep_experimental.Std
open Json_typerep.Jsonrep

module Jt = Json.Json_type

let%test_module _ = (module struct

  type x =
    | Foo
    | Bar of int
    | Baz of float * float
    [@@deriving typerep]

  type mrec = {
    foo: int;
    bar: float
  } [@@deriving typerep]

  type tree = Leaf | Node of tree * tree [@@deriving typerep]

  let test_json x typerep_of_x =
    let test t_of_json json_of_t =
      let `generic x_of_json = t_of_json typerep_of_x in
      let `generic json_of_x = json_of_t typerep_of_x in
      Polymorphic_compare.equal x (x_of_json (json_of_x x))
    in
       test V1.t_of_json V1.json_of_t
    && test V2.t_of_json V2.json_of_t
    && test V2.t_of_json V1.json_of_t
  ;;

  let%test_unit _ = assert(test_json 5 typerep_of_int)
  let%test_unit _ = assert(test_json 'm' typerep_of_char)
  let%test_unit _ = assert(test_json 5.0 typerep_of_float)
  let%test_unit _ = assert(test_json "hello, world" typerep_of_string)
  let%test_unit _ = assert(test_json true typerep_of_bool)
  let%test_unit _ = assert(test_json false typerep_of_bool)
  let%test_unit _ = assert(test_json () typerep_of_unit)
  let%test_unit _ = assert(test_json None (typerep_of_option typerep_of_int))
  let%test_unit _ = assert(test_json (Some 42) (typerep_of_option typerep_of_int))
  let%test_unit _ = assert(test_json [1;2;3;4;5] (typerep_of_list typerep_of_int))
  let%test_unit _ = assert(test_json [|6;7;8;9;19|] (typerep_of_array typerep_of_int))
  let%test_unit _ =
    assert(test_json (52,78)
      (typerep_of_tuple2 typerep_of_int typerep_of_int))
  let%test_unit _ =
    assert(test_json (52,78,89)
      (typerep_of_tuple3 typerep_of_int typerep_of_int typerep_of_int))
  let%test_unit _ =
    assert(test_json (52,78,89, "hi")
      (typerep_of_tuple4
        typerep_of_int typerep_of_int
        typerep_of_int typerep_of_string))
  let%test_unit _ =
    assert(test_json (52,78,89, "hi",false)
      (typerep_of_tuple5
        typerep_of_int typerep_of_int
        typerep_of_int typerep_of_string typerep_of_bool))
  let%test_unit _ = assert(test_json Foo typerep_of_x)
  let%test_unit _ = assert(test_json (Bar 9) typerep_of_x)
  let%test_unit _ = assert(test_json (Baz (6.2, 7.566)) typerep_of_x)
  let%test_unit _ = assert(test_json {foo=5;bar=76.2} typerep_of_mrec)
  let%test_unit _ =
    assert(test_json
      (Node ((Node ((Node (Leaf, Leaf)), Leaf)), Leaf)) typerep_of_tree)
end)

let%test_module _ = (module struct
  module Jt = Json.Json_type

  type t = {
    a : int option;
  } [@@deriving typerep]

  let `generic t_of_json_v1    = V1.t_of_json typerep_of_t
  let `generic json_of_t_v1    = V1.json_of_t typerep_of_t

  let `generic t_of_json_v2    = V2.t_of_json typerep_of_t
  let `generic json_of_t_v2    = V2.json_of_t typerep_of_t

  module Ocaml = struct
    let some = { a = Some 42 }
    let none = { a = None }
  end

  module Json = struct
    let some      = Jt.Object [ "a",  Jt.Int 42 ]
    let none_with = Jt.Object [ "a",  Jt.Null ]
    let none_sans = Jt.Object []
  end

  let%test _ = json_of_t_v1   Ocaml.none      = Json.none_with
  let%test _ = json_of_t_v2   Ocaml.none      = Json.none_sans

  let%test _ = json_of_t_v1   Ocaml.some      = Json.some
  let%test _ = json_of_t_v2   Ocaml.some      = Json.some

  let%test _ = t_of_json_v2   Json.none_sans  = Ocaml.none

  let%test _ = t_of_json_v1   Json.none_with  = Ocaml.none
  let%test _ = t_of_json_v2   Json.none_with  = Ocaml.none

  let%test _ = t_of_json_v1   Json.some       = Ocaml.some
  let%test _ = t_of_json_v2   Json.some       = Ocaml.some

end)
