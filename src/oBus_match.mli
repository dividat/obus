(*
 * oBus_match.mli
 * --------------
 * Copyright : (c) 2009, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implementation of D-Bus.
 *)

(** Matching rules *)

(** Type of a rule used to match a message *)
type rule = private {
  typ : [ `Signal | `Error | `Method_call | `Method_return ] option;
  sender : OBus_name.bus option;
  interface : OBus_name.interface option;
  member : OBus_name.member option;
  path : OBus_path.t option;
  destination : OBus_name.bus option;
  arguments : (int * string) list;
  (** Matching the argument [n] with string value [v] will match a
      message if its [n]th argument is a string and is equal to
      [v]. [n] must in the range 0..63.

      Note that [arguments] is always a sorted list. *)
} with projection, obus(basic)

val rule :
  ?typ : [ `Signal | `Error | `Method_call | `Method_return ] ->
  ?sender : OBus_name.bus ->
  ?interface : OBus_name.interface ->
  ?member : OBus_name.member ->
  ?path : OBus_path.t ->
  ?destination : OBus_name.bus ->
  ?arguments : (int * string) list ->
  unit -> rule
  (** Create a matching rule *)

val match_message : rule -> OBus_message.t -> bool
  (** [match_message rule message] returns wether [message] is matched
      by [rule] *)

exception Parse_failure of string * int * string
  (** [Parse_failure(string, position, reason)] is raised when parsing
      a rule failed *)

val string_of_rule : rule -> string
  (** Return a string representation of a matching rule. *)

val rule_of_string : string -> rule
  (** Parse a string representation of a matching rule.

      @raise [Failure] if the given string does not contain a valid
      matching rule. *)
