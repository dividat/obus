open Migrate_parsetree
open Parsetree


let rewriter_name = "ppx_obus"


let raise_errorf ?sub ?if_highlight ?loc message =
  message |> Printf.kprintf (fun str ->
    let err = Location.error ?sub ?if_highlight ?loc str in
    raise (Location.Error err))


let register_obus_exception = function
  | { pstr_desc = Pstr_exception exn; pstr_loc } ->
    (match Ast_convenience.find_attr_expr "obus" exn.pext_attributes with
    | Some expr ->
      let registerer typ =
        let loc = pstr_loc in
        if Filename.basename pstr_loc.loc_start.pos_fname = "oBus_error.ml" then
          [%stri
            let () =
              let module M =
                Register(struct
                  let name = [%e expr]
                  exception E of [%t typ]
                end)
              in ()
          ]
        else
          [%stri
            let () =
              let module M =
                OBus_error.Register(struct
                  let name = [%e expr]
                  exception E of [%t typ]
                end)
              in ()
          ] in
      (match exn.pext_kind with
      | Pext_decl (Pcstr_tuple [typ], None) ->
          Some (registerer typ)
      | _ ->
        raise_errorf ~loc:pstr_loc
          "%s: OBus exceptions take a single string argument" rewriter_name)
    | _ ->
      None)
  | _ ->
    None


let obus_mapper =
  { Ast_mapper.default_mapper with
    structure = fun mapper items ->
      List.fold_right (fun item acc ->
        let item' = Ast_mapper.default_mapper.structure_item mapper item in
        match register_obus_exception item with
        | Some reg ->
          item' :: reg :: acc
        | None ->
          item' :: acc)
      items []
  }


let () =
  Driver.register ~name:rewriter_name Versions.ocaml_406
    (fun _ _ -> obus_mapper)
