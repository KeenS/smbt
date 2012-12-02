(* vim: set et ts=4: *)
(* Smbt, an SML build tool
 *  Copyright (c) 2012 Filip Sieczkowski & Gian Perrone
 * 
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appear in all copies and that
 * both the copyright notice and this permission notice and warranty
 * disclaimer appear in supporting documentation, and that the name of
 * the above copyright holders, or their entities, not be used in
 * advertising or publicity pertaining to distribution of the software
 * without specific, written prior permission.
 * 
 * The above copyright holders disclaim all warranties with regard to
 * this software, including all implied warranties of merchantability and
 * fitness. In no event shall the above copyright holders be liable for
 * any special, indirect or consequential damages or any damages
 * whatsoever resulting from loss of use, data or profits, whether in an
 * action of contract, negligence or other tortious action, arising out
 * of or in connection with the use or performance of this software.
 *
*)

signature WATCH =
sig
    val until : string list -> unit
end

(** Watch a list of files and do things when they are modified. **)
structure Watch :> WATCH =
struct
    (** Poll a list of (file * Time.time), returning on change. **)
    fun poll l =
        let
            val _ = OS.Process.sleep (Time.fromSeconds 1) (* 1 second sleep *)
            
            val modified =
                List.exists (fn (f,t) =>
                    Time.> (OS.FileSys.modTime f, t)) l
        in
            if modified then () else poll l
        end

    (** Block on modification of a list of files. **)
    fun until fl =
        let
            val fl' = map (fn f => (f, OS.FileSys.modTime f)) fl
        in
            poll fl'
        end handle e => (print "Continuous mode aborted.\n"; raise e)
end

