# Description

Wordle-helper is a lua script that helps you get the next word based on previous entries.

It is not a wordle solver. It takes the information after each guess and show a list of remaining possibilities

It has a dictionary of all wordle words and a dictionary of used words that should be updated daily.

After each play, information for that play is given via parameters on the command line.

Command line arguments are given after each guess. There are three types of command line arguments:

1. x=   (for exact matches)
2. b=   (for blocked letters)
3. k=   (for known letters that will not occur in the positions in which they have been entered.

## Exact matches (Green letters)

Exact matches are entered in the form: x=-----

- a dash represents an unknown placement.
- if an e is at the end:   x=----e
- if an f is subsequently found in the first position: x=f---e


## Blocked Letters (Grey letters)

Blocked letters are letters that will not appear in the word. They are entered as: 'b=???' where '?' represents the letter to be blocked.

Example: If the letters r, p, s are not to appear in the word, then the parameter is entered as b=rps.

## Known Letters (Yellow letters

Known letters are entered in the form: 

    k=<letter><digit-series><letter><digit-series>
    <digit-series> ::= nothing or <digit> or <digit> .. <digit>

## Example 

If k is entered in position 2 and 4, but is a valid letter but not in those positions, then the entry would be:

    $ lua play_wordle.lua k=k24

In our example so far we have the command line:

    $ lua play_wordle.lua b=rps  e=f---e  k=k24


## Example for Wordle puzzle on 2023-07-13

guess line 1 : abide

    'a' is is known letter but not in the correct position placed in position 1
    'b' is is known letter but not in the correct position placed in position 2
    'i' and 'd' are not known and therefore blocked out and eliminated
    'e' is correctly placed

    $ lua play_wordle.lua e=----e  k=a1b2   b=id

guess line 2 : brake

    'b' is correctly placed in position 1
    'r' is known but not correctly placed in position 2
    'a' is known but again not correctly placed in position 3
    'k' is to be blocked
    'e' is again correctly placed

    $ lua play_wordle.lua e=b---e  k=a13b2   b=idk

After guess 2, there is only one possible answer: 'barge'

