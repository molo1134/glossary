# !glossary irc command -- 2-clause BSD license.
#
# Copyright (c) 2018 /u/molo1134. All rights reserved.

bind pub - !term glossary_pub
bind msg - !term glossary_msg
bind pub - !dict glossary_pub
bind msg - !dict glossary_msg
bind pub - !glossary glossary_pub
bind msg - !glossary glossary_msg
bind pub - !define glossary_pub
bind msg - !define glossary_msg

set glossarycsv "glossary.csv"

proc glossary_msg {nick uhand handle input} {
  if { $input == {} } {
    putmsg $nick "usage: !dict <terms>"
    return
  }
  set term [sanitize_string [string trim ${input}]]
  set term [encoding convertfrom utf-8 ${term}]
  putlog "glossary msg: $nick $uhand $handle $term"
  set output [getglossary $term]
  set output [split $output "\n"]

  foreach line $output {
    putmsg $nick [encoding convertto utf-8 "$line"]
  }
}

proc glossary_pub { nick host hand chan text } {
  if { $text == {} } {
    putchan $chan "usage: !dict <terms>"
    return
  }
  set term [sanitize_string [string trim ${text}]]
  set term [encoding convertfrom utf-8 ${term}]
  putlog "glossary pub: $nick $host $hand $chan $term"
  set output [getglossary $term]
  set output [split $output "\n"]

  foreach line $output {
    putchan $chan [encoding convertto utf-8 "$line"]
  }
}

proc getglossary {lookup} {
  global glossarycsv

  if { ![file exists $glossarycsv] } {
    return ""
  }

  set csvfile [open $glossarycsv r]
  while {![eof $csvfile]} {

    set line [gets $csvfile]
    set line [encoding convertfrom utf-8 $line]

    if {[regexp -- {^#} $line]} {
      continue;
    }

    if {[regexp -- {^\s*$} $line]} {
      continue;
    }

    set fields [split $line ","]

    set rxp [lindex $fields 0]
    set term [lindex $fields 1]
    set def [lindex $fields 2]

    set re {^[^,]*,[^,]*,\"([^\"]*)\"$}
    regexp $re $line -> def

#    # substring match on the term -- causes false positives like "YL" matching "XYL"
#    if {[string match -nocase "*${lookup}*" $term]} {
#      close $csvfile
#      return "$term: $def"
#    }

    if {[regexp -nocase -- $rxp $lookup]} {
      close $csvfile
      return "$term: $def"
    }
  }
  close $csvfile
  return "not found; pull requests accepted: http://github.com/molo1134/glossary/"
}
