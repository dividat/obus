(*
 * uPower_wakeups.ml
 * -----------------
 * Copyright : (c) 2010, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implementation of D-Bus.
 *)

open Lwt
open OBus_pervasives

type string_option = string option
let obus_string_option = OBus_type.map obus_string
  (function
     | "" -> None
     | str -> Some str)
  (function
     | Some str -> str
     | None -> "")

type data = {
  data_is_userspace : bool;
  data_id : uint;
  data_value : float;
  data_cmdline : string_option;
  data_details : string;
} with obus

module Proxy = OBus_proxy.Make(struct
                                 type proxy = UPower.t
                                 let cast peer = OBus_proxy.make (UPower.to_peer peer) ["org"; "freedesktop"; "UPower"; "Wakeups"]
                                 let make proxy = UPower.of_peer (OBus_proxy.peer proxy)
                               end)

let op_interface = Proxy.make_interface "org.freedesktop.UPower.Wakeups"

OP_method GetData : data structure list
OP_method GetTotal : uint

OP_signal DataChanged : unit
OP_signal TotalChanged : uint

OP_property_r HasCapability : bool