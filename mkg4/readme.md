# G4 Maker from ISOGQL pdf

## Steps

1. make gql.txt from pdf，
2. cut the header of gql.txt. let it start with

    ```
    97



    IWD 39075:202y(E)

    6

    <GQL-program>

    Format

    « WG3:UTC-045R1 »

    <GQL-program> ::=

    <program activity> [ <session close command> ]

    | <session close command>
   ```
3. extract literal section from gql.txt into gql_literals.txt, which starts with

    ```
    409




    IWD 39075:202y(E)

    21 Lexical elements

    « In consequence of WG3:UTC-069 Deleted 1 (one) editor's note »

    21.1 <literal>

    Function

    Specify a value.

    Format

    <literal> ::=

    <signed numeric literal>

    | <general literal>
    ```

4. run `python preprocess.py`
5. run `dotnet fsi format_bnf.fsx`