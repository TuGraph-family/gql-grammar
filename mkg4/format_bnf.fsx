#r "nuget: FParsec"

open FParsec
open System.IO
open System

module Format =
    type Expr =
        | Symbol of string // ABC
        | Var of string // <aa bb>
        | RepAtLeatOne of Expr // E ...
        | Rep of Expr // E ...
        | Opt of Expr // [  E  ]
        | Concat of Expr list
        | Alternative of Expr list

    type Stmt = Stmt of string * Expr
    type Program = Stmt list

    let stmtDef = function Stmt(def, exp) -> def
    let stmtExpr = function Stmt(def, exp) -> exp

module Antlr =
    open Format
    let rec mm (t: Expr): Expr =
        match t with
        | Alternative [ e ] -> mm e
        | Concat [ e ] -> mm e
        | RepAtLeatOne e -> RepAtLeatOne(mm (e))
        | Rep e -> Rep(mm e)
        | Opt e -> Opt(mm e)
        | Concat e -> Concat(List.map mm e)
        | Alternative e -> Alternative(List.map mm e)
        | Symbol s -> Symbol s
        | Var s -> Var s
        |> function
        | Opt (RepAtLeatOne (e)) -> Rep(e)
        | e -> e

    let rec exprToString (t: Expr): string =
        match t with
        | Symbol s -> sprintf "\'%s\'" (s.Replace("\\", "\\\\").Replace("'", "\\'"))
        | Var s -> s
        | RepAtLeatOne s -> sprintf "( %s )+" (exprToString s)
        | Rep s -> sprintf "( %s )*" (exprToString s)
        | Opt s -> sprintf "( %s )?" (exprToString s)
        | Concat ts ->
            let fterm (e: Expr) =
                let f =
                    match e with
                    | Alternative x -> sprintf "( %s )"
                    | _ -> id

                f (exprToString e)

            ts |> Seq.map fterm |> String.concat " "
        | Alternative terms -> terms |> Seq.map exprToString |> String.concat "|"

    let stmtToString (Stmt (v, e): Stmt): string =
        sprintf "%s : %s ;" v (exprToString (mm e))

    let toString (f: Program): string =
        f |> Seq.map stmtToString |> String.concat "\n"

module BNF =
    open Format

    let pWord =
        many1Chars
            (anyOf [ ':'; '-'; '_'; '/' ]
             <|> satisfy Char.IsLetterOrDigit)

    let pTok =
        parse {
            let! h = letter
            let! tails = manyChars (letter <|> digit <|> (anyOf ['-'; ' ';'/'; '_'] |>>fun _ -> '_'))
            return sprintf "%c%s" h tails
        }
    let pS = manyChars (pchar ' ')

    run (pS .>>. anyString 2) "  aaa"

    let padding = pS
    // let padding = pS .>>. (opt (pchar '\n' .>>. pS))

    run (padding .>>. anyString 2) "  \n  abc"

    let pSymbol = pWord .>> padding |>> Symbol

    let pVar =
        parse {
            let! _ = pchar '<'
            let! words = sepBy1 (pTok) (many1Chars (pchar ' '))
            let! _ = pchar '>'
            let! _ = padding
            return String.Join("_", words)
        }

    let pOr = pstring "|" .>> padding

    let rec pOpt =
        parse {
            let! r = between (pchar '[' .>> padding) (pchar ']' .>> padding) pExpr
            return Opt r
        }

    and pGroup =
        between (pchar '{' .>> padding) (pchar '}' .>> padding) pExpr

    and pRepAtLeatOne =
        parse {
            let! r = opt (pstring "..." .>> padding)

            match r with
            | Some _ -> return RepAtLeatOne
            | None -> return id
        }

    and pTerm =
        parse {
            let! e = pOpt <|> pGroup <|> (pVar |>> Var) <|> pSymbol
            let! r = pRepAtLeatOne
            return r e
        }

    and pTerms = many1 pTerm |>> Concat

    and pExpr = sepBy1 pTerms pOr |>> Alternative

    let pStmt: Parser<Stmt, unit> =
        pVar
        .>> pstring "::="
        .>> spaces
        .>>. pExpr
        .>> skipRestOfLine true
        |>> Stmt

    // let pMain: Parser<Program, unit> = sepBy pStmt (many1Chars (pchar '\n'))
    let pMain: Parser<Program, unit> = many1 pStmt .>> eof

    let pSymbols: Parser<Program, unit> =
        let p: Parser<Format.Stmt, unit> =
            parse {
                let! var = pVar
                let! _ = pstring "::="
                let! _ = spaces
                let! symbol = restOfLine true
                return Stmt(var, Symbol symbol)
            }

        many (attempt pStmt <|> p) .>> eof

    let parseFile fname parser =
        runParserOnFile parser () fname Text.Encoding.UTF8
        |> function
        | Success (r, s, p) -> r
        | err -> failwithf "parse %A error, msg : %A" fname err

let writeFile fname s =
    File.WriteAllText(fname, s, Text.Encoding.UTF8)

let appendFile fname s =
    File.AppendAllText(fname, s, Text.Encoding.UTF8)

let rules = BNF.parseFile "gql.bnf" BNF.pMain

for s in rules do
    printfn "%A" s

let symbols = BNF.parseFile "gql_symbols.bnf" BNF.pSymbols

for s in symbols do
    printfn "%A" s

let firstToLower (s:string) = String.map Char.ToLower s
let firstToUpper (s:string) = String.map Char.ToUpper s

let rulesDef = rules |> Seq.map Format.stmtDef |> Seq.map (function d -> (d, firstToLower d))
let symbolsDef = symbols |> Seq.map Format.stmtDef |> Seq.map (function d -> (d, firstToUpper d))
let mapping = Map.ofSeq(Seq.append rulesDef symbolsDef)

let renameProgram (p: Format.Program)(m: Map<string, string>)=
    p
    |> Seq.map (function Format.Stmt(def, exp)->
                          let find v = Map.tryFind v m |> function Some a -> a | None -> failwithf "not found %A at stmt %s" v def
                          let rec renameExp : Format.Expr -> Format.Expr  =
                            function
                            | Format.Symbol s -> Format.Symbol s
                            | Format.Var s -> Format.Var (find s)
                            | Format.RepAtLeatOne e -> Format.RepAtLeatOne (renameExp e)
                            | Format.Rep e -> Format.Rep (renameExp e)
                            | Format.Opt o -> Format.Opt (renameExp o)
                            | Format.Concat es -> Format.Concat (List.map renameExp es)
                            | Format.Alternative es -> Format.Alternative(List.map renameExp es)

                          let def = find def
                          let exp = renameExp exp
                          Format.Stmt(def, exp)
                )

let rulesNew = renameProgram rules mapping |> List.ofSeq
let symbolsNew = renameProgram symbols mapping |> List.ofSeq
"grammar GQLParser;\n" + "options { tokenVocab=GqlLexer; }\n" + (Antlr.toString rulesNew) + "\n"
|> writeFile "GQLParser.g4"

sprintf "lexer grammar GQLLexer; \n\n%s" (Antlr.toString symbolsNew)
|> writeFile "GQLLexer.g4"
