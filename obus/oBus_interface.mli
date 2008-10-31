(*
 * oBus_interface.mli
 * ------------------
 * Copyright : (c) 2008, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implemtation of dbus.
 *)

(** Proxy interface definition *)

(** This is the ocaml version of a DBus interface for proxy code.

    Note that interface contained in XML introspection files can be
    automatically converted with [obus-binder] *)
module type S = sig
  type t = OBus_proxy.t
  val tt : t OBus_type.ty_basic

  val interface : OBus_name.interface
    (** Name of the interface *)

  val call : OBus_name.member -> ('a, 'b Lwt.t, 'b) OBus_type.ty_function -> t -> 'a
    (** [call member typ obj ...] define a method call.

        A method call definition looks like:

        {[
          let caml_name = call "DBusName" method_call_type
        ]}

        Or even simpler, with the syntax extension:

        {[
          OBUS_method DBusName : method_call_type
        ]}
    *)

  val signal : ?broadcast:bool -> OBus_name.member -> [< 'a OBus_type.cl_sequence ] -> 'a OBus_signal.t
    (** [signal ?broadcast member typ] define a signal.

        A signal defintion looks like:

        {[
          let caml_name1 = signal "DBusName1" signal_type
          let caml_name2 = signal ~broadcast:false "DBusName2" signal_type
        ]}

        Or, with the syntax extension:

        {[
          OBUS_signal DBusName1 : signal_type
          OBUS_signal! DBusName2 : signal_type
        ]}
    *)

  val property : OBus_name.member -> ([< OBus_property.access ] as 'b) -> [< 'a OBus_type.cl_single ] -> ('a, 'b) OBus_property.t
    (** [property member access typ] define a property.

        A property definition looks like:

        {[
          let caml_name = property "DBusName" OBus_property.rd_only property_type
          let caml_name = property "DBusName" OBus_property.wr_only property_type
          let caml_name = property "DBusName" OBus_property.rdwr property_type
        ]}

        Or, with the syntax extension:

        {[
          OBUS_property_r DBusName : property_type
          OBUS_property_w DBusName : property_type
          OBUS_property_rw DBusName : property_type
        ]}
    *)

  val register_exn : OBus_error.name -> (OBus_error.message -> exn) -> (exn -> OBus_error.message option) -> unit
    (** Same as [OBus_error.register] but the error name will be
        prefixed by the interface name.

        An exception definition looks like:

        {[
          exception Caml_name of string
          let _ = register_exn "Error.DBusName" (fun msg -> Caml_name msg) (function
                                                                              | Caml_name msg -> Some msg
                                                                              | _ -> None)
        ]}

        Or, with the syntax extension:

        {[
          OBUS_exception Error.DBusName
        ]}
    *)
end

module Make(Name : sig val name : OBus_name.interface end) : S
