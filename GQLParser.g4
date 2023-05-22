parser grammar GQLParser;

options { tokenVocab = GQLLexer; }

//入口
gqlRequest
   : gqlProgram SEMICOLON? EOF
   ;

gqlProgram
   : programActivity sessionCloseCommand?
   | sessionCloseCommand
   ;

programActivity
   : sessionActivity
   | transactionActivity
   ;

sessionActivity
   : sessionActivityCommand+
   ;

sessionActivityCommand
   : sessionSetCommand
   | sessionResetCommand
   ;

transactionActivity
   : startTransactionCommand (procedureSpecification endTransactionCommand?)?
   | procedureSpecification endTransactionCommand?
   | endTransactionCommand
   ;

endTransactionCommand
   : rollbackCommand
   | commitCommand
   ;

sessionSetCommand
   : SESSION SET (sessionSetSchemaClause | sessionSetGraphClause | sessionSetTimeZoneClause | sessionSetParameterClause)
   ;

sessionSetSchemaClause
   : SCHEMA schemaReference
   ;

sessionSetGraphClause
   : PROPERTY? GRAPH graphExpression
   ;

sessionSetTimeZoneClause
   : TIME ZONE setTimeZoneValue
   ;

setTimeZoneValue
   : expression
   ;

sessionSetParameterClause
   : sessionSetGraphParameterClause
   | sessionSetBindingTableParameterClause
   | sessionSetValueParameterClause
   ;

sessionSetGraphParameterClause
   : PROPERTY? GRAPH sessionSetParameterName optTypedGraphInitializer
   ;

sessionSetBindingTableParameterClause
   : BINDING? TABLE sessionSetParameterName optTypedBindingTableInitializer
   ;

sessionSetValueParameterClause
   : VALUE sessionSetParameterName optTypedValueInitializer
   ;

sessionSetParameterName
   : parameterName (IF NOT EXISTS)?
   ;

sessionResetCommand
   : SESSION? RESET sessionResetArguments?
   ;

sessionResetArguments
   : ALL? (PARAMETERS | CHARACTERISTICS)
   | SCHEMA
   | PROPERTY? GRAPH
   | TIME ZONE
   | PARAMETER? parameterName
   ;

sessionCloseCommand
   : SESSION? CLOSE
   ;

startTransactionCommand
   : START TRANSACTION transactionCharacteristics?
   ;

transactionCharacteristics
   : transactionMode (COMMA transactionMode)*
   ;

transactionMode
   : transactionAccessMode
   | implementationDefinedAccessMode
   ;

transactionAccessMode
   : READ ONLY
   | READ WRITE
   ;

implementationDefinedAccessMode
   : I_DONT_KNOW_1
   ; //TODO: 需要参考其他标准定义，暂时空置

rollbackCommand
   : ROLLBACK
   ;

commitCommand
   : COMMIT
   ;

nestedProcedureSpecification
   : LEFT_BRACE procedureSpecification RIGHT_BRACE
   ;

procedureSpecification
   : procedureBody
   ;

catalogModifyingProcedureSpecification
   : procedureBody
   ;

nestedDataModifyingProcedureSpecification
   : LEFT_BRACE dataModifyingProcedureSpecification RIGHT_BRACE
   ;

dataModifyingProcedureSpecification
   : procedureBody
   ;

nestedQuerySpecification
   : LEFT_BRACE procedureSpecification RIGHT_BRACE
   ;

querySpecification
   : procedureBody
   ;

unsignedNumericLiteral
   : integerLiteral
   | floatLiteral
   ;

integerLiteral
   : UNSIGNED_DECIMAL_INTEGER
   | UNSIGNED_OCTAL_INTEGER
   | UNSIGNED_HEXADECIMAL_INTEGER
   | UNSIGNED_BINARY_INTEGER
   ;

floatLiteral
   : UNSIGNED_DECIMAL_IN_COMMON_NOTATION
   | UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION
   ;

unbrokenSingleQuotedCharacterSequence
   : SINGLE_QUOTED_STRING_LITERAL
   ;

unbrokenDoubleQuotedCharacterSequence
   : DOUBLE_QUOTED_STRING_LITERAL
   ;

unbrokenAccentQuotedCharacterSequence
   : ACCENT_QUOTED_STRING_LITERAL
   ;

singleQuotedCharacterSequence
   : unbrokenSingleQuotedCharacterSequence (VERTICAL_BAR unbrokenSingleQuotedCharacterSequence)*
   ;

doubleQuotedCharacterSequence
   : unbrokenDoubleQuotedCharacterSequence (VERTICAL_BAR unbrokenDoubleQuotedCharacterSequence)*
   ;

accentQuotedCharacterSequence
   : unbrokenAccentQuotedCharacterSequence (VERTICAL_BAR unbrokenAccentQuotedCharacterSequence)*
   ;

unbrokenCharacterStringLiteral
   : (unbrokenSingleQuotedCharacterSequence | unbrokenDoubleQuotedCharacterSequence)
   ;

nullLiteral
   : NULL
   ;

temporalLiteral
   : dateLiteral
   | timeLiteral
   | datetimeLiteral
   | sqlDatetimeLiteral
   ;

sqlDatetimeLiteral
   : DATE QUOTE FOUR_DIGIT MINUS_SIGN DOUBLE_DIGIT MINUS_SIGN DOUBLE_DIGIT QUOTE
   | TIME QUOTE DOUBLE_DIGIT COLON DOUBLE_DIGIT COLON DOUBLE_DIGIT QUOTE
   | TIMESTAMP QUOTE FOUR_DIGIT MINUS_SIGN DOUBLE_DIGIT MINUS_SIGN DOUBLE_DIGIT DOUBLE_DIGIT COLON DOUBLE_DIGIT COLON DOUBLE_DIGIT QUOTE
   | DATETIME QUOTE FOUR_DIGIT MINUS_SIGN DOUBLE_DIGIT MINUS_SIGN DOUBLE_DIGIT DOUBLE_DIGIT COLON DOUBLE_DIGIT COLON DOUBLE_DIGIT QUOTE
   ;

dateLiteral
   : DATE unbrokenCharacterStringLiteral
   ;

timeLiteral
   : TIME unbrokenCharacterStringLiteral
   ;

datetimeLiteral
   : (DATETIME | TIMESTAMP) unbrokenCharacterStringLiteral
   ;

durationLiteral
   : DURATION unbrokenCharacterStringLiteral
   | sqlIntervalLiteral
   ;

sqlIntervalLiteral
   : UNSIGNED_DECIMAL_INTEGER sqlIntervalType
   ;

sqlIntervalType
   : INTERVAL_DAY
   | INTERVAL_WEEK
   | INTERVAL_MONTH
   | INTERVAL_YEAR
   ;

identifier
   : REGULAR_IDENTIFIER
   | delimitedIdentifier
   | nonReservedWord
   ; //[Extend]：加入nonReservedWord，支持ID等一些token作为标识符

nonReservedWord
   : ID
   | PATH
   | TIME
   | TYPE
   ;

//delimitedIdentifier
//   : doubleQuotedCharacterSequence
//   | accentQuotedCharacterSequence
//   ;

//[Extend]
delimitedIdentifier
   : accentQuotedCharacterSequence
   ;

objectName
   : identifier
   ;

objectNameOrBindingVariable
   : REGULAR_IDENTIFIER
   ;

directoryName
   : identifier
   ;

schemaName
   : identifier
   ;

graphName
   : REGULAR_IDENTIFIER
   | delimitedGraphName
   ;

delimitedGraphName
   : delimitedIdentifier
   ;

graphTypeName
   : identifier
   ;

elementTypeName
   : identifier
   ;

bindingTableName
   : REGULAR_IDENTIFIER
   | delimitedBindingTableName
   ;

delimitedBindingTableName
   : delimitedIdentifier
   ;

procedureName
   : identifier
   ;

labelName
   : identifier
   ;

functionName
   : identifier
   ;

propertyName
   : identifier
   ;

fieldName
   : identifier
   ;

// change unsignedDecimalInteger to unsignedNumericLiteral
parameterName
   : '$' (unsignedNumericLiteral | identifier)
   | PERCENT (unsignedNumericLiteral | identifier) PERCENT
   ; //[Extend:GeaPhi]：支持%xxx%的写法

//variable : graphVariable|graphPatternVariable|bindingTableVariable|valueVariable|bindingVariable ;
variable
   : bindingVariable
   ;

graphVariable
   : bindingVariable
   ;

graphPatternVariable
   : elementVariable
   | pathOrSubpathVariable
   ;

pathOrSubpathVariable
   : pathVariable
   | subpathVariable
   ;

elementVariable
   : bindingVariable
   ;

pathVariable
   : bindingVariable
   ;

subpathVariable
   : identifier
   ;

bindingTableVariable
   : bindingVariable
   ;

valueVariable
   : bindingVariable
   ;

bindingVariable
   : identifier
   ;

predefinedTypeLiteral
   : booleanLiteral
   | characterStringLiteral
   | BYTE_STRING_LITERAL
   | temporalLiteral
   | durationLiteral
   | nullLiteral
   ;

booleanLiteral
   : TRUE
   | FALSE
   | UNKNOWN
   ;

characterStringLiteral
   : singleQuotedCharacterSequence
   | doubleQuotedCharacterSequence
   ;

procedureBody
   : atSchemaClause? bindingVariableDefinitionBlock? statementBlock
   ;

bindingVariableDefinitionBlock
   : bindingVariableDefinition+
   ;

bindingVariableDefinition
   : graphVariableDefinition
   | bindingTableVariableDefinition
   | valueVariableDefinition
   ;

statementBlock
   : statement nextStatement*
   ;

statement
   : linearCatalogModifyingStatement
   | linearDataModifyingStatement
   | compositeQueryStatement
   ;

nextStatement
   : NEXT
   | THEN yieldClause? statement // [EXTEND:geabase]还需要保留then
   ;

graphVariableDefinition
   : PROPERTY? GRAPH graphVariable optTypedGraphInitializer
   ;

optTypedGraphInitializer
   : (typed? graphReferenceValueType)? graphInitializer
   ;

graphInitializer
   : EQUALS_OPERATOR graphExpression
   ;

bindingTableVariableDefinition
   : BINDING? TABLE bindingTableVariable optTypedBindingTableInitializer
   ;

optTypedBindingTableInitializer
   : (typed? bindingTableReferenceValueType)? bindingTableInitializer
   ;

bindingTableInitializer
   : EQUALS_OPERATOR bindingTableExpression
   ;

valueVariableDefinition
   : VALUE valueVariable optTypedValueInitializer
   ;

optTypedValueInitializer
   : (typed? valueType)? EQUALS_OPERATOR expression
   ;

graphExpression
   : nestedGraphQuerySpecification
   | objectExpressionPrimary
   | graphReference
   | objectNameOrBindingVariable
   | currentGraph
   ;

currentGraph
   : CURRENT_PROPERTY_GRAPH
   | CURRENT_GRAPH
   ;

nestedGraphQuerySpecification
   : nestedQuerySpecification
   ;

bindingTableExpression
   : nestedBindingTableQuerySpecification
   | objectExpressionPrimary
   | bindingTableReference
   | objectNameOrBindingVariable
   ;

nestedBindingTableQuerySpecification
   : nestedQuerySpecification
   ;

objectExpressionPrimary
   : variable expressionAtom
   | LEFT_PAREN expression RIGHT_PAREN
   | expression
   ;

linearCatalogModifyingStatement
   : simpleCatalogModifyingStatement+
   ;

simpleCatalogModifyingStatement
   : primitiveCatalogModifyingStatement
   | callCatalogModifyingProcedureStatement
   ;

primitiveCatalogModifyingStatement
   : createSchemaStatement
   | createGraphStatement
   | createGraphTypeStatement
   | dropSchemaStatement
   | dropGraphStatement
   | dropGraphTypeStatement
   ;

createSchemaStatement
   : CREATE SCHEMA (IF NOT EXISTS)? catalogSchemaParentAndName
   ;

dropSchemaStatement
   : DROP SCHEMA (IF EXISTS)? catalogSchemaParentAndName
   ;

createGraphStatement
   : CREATE (PROPERTY? GRAPH (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH) catalogGraphParentAndName (openGraphType | ofGraphType) graphSource?
   ;

openGraphType
   : OPEN (PROPERTY? GRAPH)? TYPE
   ;

ofGraphType
   : graphTypeLikeGraph
   | typed? graphTypeReference
   | typed? nestedGraphTypeSpecification
   ;

graphTypeLikeGraph
   : LIKE graphExpression
   ;

graphSource
   : AS COPY OF graphExpression
   ;

dropGraphStatement
   : DROP PROPERTY? GRAPH (IF EXISTS)? catalogGraphParentAndName
   ;

createGraphTypeStatement
   : CREATE (PROPERTY? GRAPH TYPE (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH TYPE) catalogGraphTypeParentAndName graphTypeSource
   ;

graphTypeSource
   : AS? copyOfGraphType
   | graphTypeLikeGraph
   | AS? nestedGraphTypeSpecification
   ;

copyOfGraphType
   : COPY OF (graphTypeReference | externalObjectReference)
   ;

dropGraphTypeStatement
   : DROP PROPERTY? GRAPH TYPE (IF EXISTS)? catalogGraphTypeParentAndName
   ;

callCatalogModifyingProcedureStatement
   : callProcedureStatement
   ;

linearDataModifyingStatement
   : focusedLinearDataModifyingStatement
   | ambientLinearDataModifyingStatement
   ;

focusedLinearDataModifyingStatement
   : focusedLinearDataModifyingStatementBody
   | focusedNestedDataModifyingProcedureSpecification
   ;

focusedLinearDataModifyingStatementBody
   : useGraphClause simpleLinearDataAccessingStatement primitiveResultStatement?
   ;

focusedNestedDataModifyingProcedureSpecification
   : useGraphClause nestedDataModifyingProcedureSpecification
   ;

ambientLinearDataModifyingStatement
   : ambientLinearDataModifyingStatementBody
   | nestedDataModifyingProcedureSpecification
   ;

// 之前统一AST的时候说要改成这样子 TODO  check
ambientLinearDataModifyingStatementBody
   : simpleLinearQueryStatement? simpleDataModifyingStatement+ primitiveResultStatement?
   ;

simpleLinearDataAccessingStatement
   : simpleDataAccessingStatement+
   ;

simpleDataAccessingStatement
   : simpleQueryStatement
   | simpleDataModifyingStatement
   ;

simpleDataModifyingStatement
   : primitiveDataModifyingStatement
   | callDataModifyingProcedureStatement
   ;

// geabase 扩展replaceStatement
primitiveDataModifyingStatement
   : insertStatement
   | setStatement
   | removeStatement
   | deleteStatement
   | replaceStatement
   ;

insertStatement
   : INSERT insertGraphPattern
   ;

setStatement
   : SET setItemList
   ;

setItemList
   : setItem (COMMA setItem)*
   ;

setItem
   : setPropertyItem
   | setAllPropertiesItem
   | setLabelItem
   ;

setPropertyItem
   : bindingVariableReference PERIOD propertyName EQUALS_OPERATOR expression
   ;

setAllPropertiesItem
   : bindingVariableReference EQUALS_OPERATOR LEFT_BRACE propertyKeyValuePairList? RIGHT_BRACE
   ;

setLabelItem
   : bindingVariableReference isOrColon labelSetSpecification
   ;

labelSetSpecification
   : labelName (AMPERSAND labelName)*
   ;

removeStatement
   : REMOVE removeItemList
   ;

removeItemList
   : removeItem (COMMA removeItem)*
   ;

removeItem
   : removePropertyItem
   | removeLabelItem
   ;

removePropertyItem
   : bindingVariableReference PERIOD propertyName
   ;

removeLabelItem
   : bindingVariableReference isOrColon labelSetSpecification
   ;

deleteStatement
   : (DETACH | NODETACH)? DELETE deleteItemList
   ;

deleteItemList
   : deleteItem (COMMA deleteItem)*
   ;

deleteItem
   : expression
   ;

// geabase 扩展replaceStatement
replaceStatement
   : REPLACE insertGraphPattern
   ;

callDataModifyingProcedureStatement
   : callProcedureStatement
   ;

compositeQueryStatement
   : compositeQueryExpression
   ;

compositeQueryExpression
   : compositeQueryExpression queryConjunction compositeQueryPrimary
   | compositeQueryPrimary
   ;

queryConjunction
   : setOperator
   | OTHERWISE
   ;

setOperator
   : UNION setQuantifier?
   | EXCEPT setQuantifier?
   | INTERSECT setQuantifier?
   ;

compositeQueryPrimary
   : linearQueryStatement joinQueryPart? //[EXTEND:Geaphi]: Join support
   ;

joinQueryPart
   : joinQueryBody+ returnStatement
   ;

joinQueryBody
   : joinType? JOIN linearQueryStatement (ON expression)?
   ;

joinType
   : INNER
   | CROSS
   | LEFT
   | RIGHT
   ;

linearQueryStatement
   : focusedLinearQueryStatement
   | ambientLinearQueryStatement
   ;

focusedLinearQueryStatement
   : focusedLinearQueryStatementPart* focusedLinearQueryAndPrimitiveResultStatementPart
   | focusedPrimitiveResultStatement
   | focusedNestedQuerySpecification
   | selectStatement
   ;

focusedLinearQueryStatementPart
   : useGraphClause simpleLinearQueryStatement
   ;

focusedLinearQueryAndPrimitiveResultStatementPart
   : useGraphClause simpleLinearQueryStatement primitiveResultStatement
   ;

focusedPrimitiveResultStatement
   : useGraphClause primitiveResultStatement
   ;

focusedNestedQuerySpecification
   : useGraphClause nestedQuerySpecification
   ;

ambientLinearQueryStatement
   : simpleLinearQueryStatement? primitiveResultStatement
   | nestedQuerySpecification
   ;

simpleLinearQueryStatement
   : simpleQueryStatement+
   ;

simpleQueryStatement
   : primitiveQueryStatement
   | callQueryStatement
   ;

primitiveQueryStatement
   : matchStatement
   | letStatement
   | forStatement
   | filterStatement
   | orderByAndPageStatement
   ;

matchStatement
   : simpleMatchStatement
   | optionalMatchStatement
   ;

simpleMatchStatement
   : MATCH graphPatternBindingTable
   ;

optionalMatchStatement
   : OPTIONAL optionalOperand
   ;

optionalOperand
   : simpleMatchStatement
   | LEFT_BRACE matchStatementBlock RIGHT_BRACE
   | LEFT_PAREN matchStatementBlock RIGHT_PAREN
   ;

matchStatementBlock
   : matchStatement+
   ;

callQueryStatement
   : callProcedureStatement
   ;

filterStatement
   : FILTER (whereClause | expression)
   ;

letStatement
   : LET letVariableDefinitionList
   ;

letVariableDefinitionList
   : letVariableDefinition (COMMA letVariableDefinition)*
   ;

letVariableDefinition
   : valueVariableDefinition
   | valueVariable EQUALS_OPERATOR expression
   ;

forStatement
   : FOR forItem forOrdinalityOrOffset?
   ;

forItem
   : forItemAlias expressionAtom
   ;

forItemAlias
   : identifier IN
   ;

forOrdinalityOrOffset
   : WITH (ORDINALITY | OFFSET) identifier
   ;

orderByAndPageStatement
   : orderByClause offsetClause? limitClause?
   | offsetClause limitClause?
   | limitClause
   ;

primitiveResultStatement
   : returnStatement orderByAndPageStatement?
   | constructGraphStatement //[EXTEND:geaphi]: contruct 语法支持
   | FINISH
   ;

returnStatement
   : RETURN returnStatementBody
   ;

// geabase扩展hint
returnStatementBody
   : hintItemlist? setQuantifier? (ASTERISK | returnItemList) groupByClause?
   | NO BINDINGS
   ;

returnItemList
   : returnItem (COMMA returnItem)*
   ;

returnItem
   : expression returnItemAlias?
   ;

returnItemAlias
   : AS identifier
   ;

// geabase扩展hint
hintItemlist
   : HINT_BEGIN hintItem (COMMA hintItem)* BRACKETED_COMMENT_TERMINATOR
   ;

hintItem
   : READ_CONSISTENCY LEFT_PAREN identifier RIGHT_PAREN
   ;

//[EXTEND:geaphi]: contruct 语法支持
constructGraphStatement
   : CONSTRUCT constructElementList
   ;

constructElementList
   : constructElement (COMMA constructElement)*
   ;

constructElement
   : currentElement
   | newElement
   ;

currentElement
   : bindingVariable propertyList?
   ;

propertyList
   : PROPERTIES LEFT_PAREN propertyName (COMMA propertyName)* RIGHT_PAREN
   ;

newElement
   : new_node
   | new_edge
   ;

new_node
   : LEFT_PAREN construct_element_pattern_filler RIGHT_PAREN
   ;

new_edge
   : LEFT_PAREN start_var RIGHT_PAREN construct_edge_pattern LEFT_PAREN end_var RIGHT_PAREN
   ;

construct_element_pattern_filler
   : (elementVariableDeclaration)? isLabelExpression (primary_key)? construct_element_property_specification
   ;

construct_edge_pattern
   : (construct_edge_pointing_right | construct_edge_pointing_left | construct_edge_any_direction)
   ;

construct_edge_pointing_right
   : MINUS_SIGN LEFT_BRACKET construct_element_pattern_filler RIGHT_BRACKET RIGHT_ARROW
   ;

construct_edge_pointing_left
   : LEFT_ANGLE_BRACKET MINUS_SIGN LEFT_BRACKET construct_element_pattern_filler RIGHT_BRACKET MINUS_SIGN
   ;

construct_edge_any_direction
   : MINUS_SIGN LEFT_BRACKET construct_element_pattern_filler RIGHT_BRACKET MINUS_SIGN
   ;

primary_key
   : PRIMARY KEY LEFT_PAREN (identifier)+ RIGHT_PAREN
   ;

construct_element_property_specification
   : LEFT_BRACE propertyKeyValuePairList (COMMA extend_element)? RIGHT_BRACE
   ;

extend_element
   : DOUBLE_PERIOD identifier
   ;

start_var
   : identifier
   ;

end_var
   : identifier
   ;

selectStatement
   : SELECT setQuantifier? selectItemList (selectStatementBody whereClause? groupByClause? havingClause? orderByClause? offsetClause? limitClause?)?
   ;

selectItemList
   : selectItem (COMMA selectItem)*
   ;

selectItem
   : expression selectItemAlias?
   ;

selectItemAlias
   : AS identifier
   ;

havingClause
   : HAVING expression
   ;

selectStatementBody
   : FROM selectGraphMatchList
   | selectQuerySpecification
   ;

selectGraphMatchList
   : selectGraphMatch (COMMA selectGraphMatch)*
   ;

selectGraphMatch
   : graphExpression matchStatement
   ;

selectQuerySpecification
   : FROM nestedQuerySpecification
   | FROM graphExpression nestedQuerySpecification
   ;

callProcedureStatement
   : OPTIONAL? CALL procedureCall
   ;

procedureCall
   : inlineProcedureCall
   | namedProcedureCall
   ;

inlineProcedureCall
   : variableScopeClause? nestedProcedureSpecification
   ;

variableScopeClause
   : LEFT_PAREN bindingVariableReferenceList? RIGHT_PAREN
   ;

bindingVariableReferenceList
   : bindingVariableReference (COMMA bindingVariableReference)*
   ;

namedProcedureCall
   : procedureReference LEFT_PAREN procedureArgumentList? RIGHT_PAREN yieldClause?
   ;

procedureArgumentList
   : procedureArgument (COMMA procedureArgument)*
   ;

procedureArgument
   : expression
   ;

useGraphClause
   : (USE | FROM) graphExpression  //[Extended:Geaphi] ADD from in use graph clause
   ;

atSchemaClause
   : AT schemaReference
   ;

bindingVariableReference
   : bindingVariable
   ;

elementVariableReference
   : bindingVariableReference
   ;

pathVariableReference
   : bindingVariableReference
   ;

parameter
   : parameterName
   ;

graphPatternBindingTable
   : graphPattern graphPatternYieldClause?
   ;

graphPatternYieldClause
   : YIELD graphPatternYieldItemList
   ;

graphPatternYieldItemList
   : graphPatternYieldItem (COMMA graphPatternYieldItem)*
   | NO BINDINGS
   ;

graphPatternYieldItem
   : elementVariableReference
   | pathVariableReference
   ;

graphPattern
   : matchMode? pathPatternList keepClause? graphPatternWhereClause?
   ;

matchMode
   : repeatableElementsMatchMode
   | differentEdgesMatchMode
   ;

repeatableElementsMatchMode
   : REPEATABLE elementBindingsOrElements
   ;

differentEdgesMatchMode
   : DIFFERENT edgeBindingsOrEdges
   ;

elementBindingsOrElements
   : ELEMENT BINDINGS?
   | ELEMENTS
   ;

edgeBindingsOrEdges
   : EDGE_SYNONYM BINDINGS?
   | EDGES_SYNONYM
   ;

pathPatternList
   : pathPattern (COMMA pathPattern)*
   ;

pathPattern
   : pathVariableDeclaration? pathPatternPrefix? pathPatternExpression
   ;

pathVariableDeclaration
   : pathVariable EQUALS_OPERATOR
   ;

keepClause
   : KEEP pathPatternPrefix
   ;

graphPatternWhereClause
   : WHERE expression
   ;

pathPatternPrefix
   : pathModePrefix
   | pathSearchPrefix
   ;

pathModePrefix
   : pathMode pathOrPaths?
   ;

pathMode
   : WALK
   | TRAIL
   | SIMPLE
   | ACYCLIC
   ;

pathSearchPrefix
   : allPathSearch
   | anyPathSearch
   | shortestPathSearch
   ;

allPathSearch
   : ALL pathMode? pathOrPaths?
   ;

pathOrPaths
   : PATH
   | PATHS
   ;

anyPathSearch
   : ANY numberOfPaths? pathMode? pathOrPaths?
   ;

numberOfPaths
   : unsignedIntegerSpecification
   ;

shortestPathSearch
   : allShortestPathSearch
   | anyShortestPathSearch
   | countedShortestPathSearch
   | countedShortestGroupSearch
   ;

allShortestPathSearch
   : ALL SHORTEST pathMode? pathOrPaths?
   ;

anyShortestPathSearch
   : ANY SHORTEST pathMode? pathOrPaths?
   ;

countedShortestPathSearch
   : SHORTEST numberOfPaths pathMode? pathOrPaths?
   ;

countedShortestGroupSearch
   : SHORTEST numberOfGroups pathMode? pathOrPaths? (GROUP | GROUPS)
   ;

numberOfGroups
   : unsignedIntegerSpecification
   ;

pathPatternExpression
   : pathTerm
   | pathMultisetAlternation
   | pathPatternUnion
   ;

pathMultisetAlternation
   : pathTerm MULTISET_ALTERNATION_OPERATOR pathTerm (MULTISET_ALTERNATION_OPERATOR pathTerm)*
   ;

pathPatternUnion
   : pathTerm VERTICAL_BAR pathTerm (VERTICAL_BAR pathTerm)*
   ;

pathTerm
   : pathFactor+
   ;

pathFactor
   : pathPrimary
   | quantifiedPathPrimary
   | questionedPathPrimary
   ;

quantifiedPathPrimary
   : pathPrimary graphPatternQuantifier
   ;

questionedPathPrimary
   : pathPrimary QUESTION_MARK
   ;

pathPrimary
   : elementPattern
   | parenthesizedPathPatternExpression
   | simplifiedPathPatternExpression
   ;

elementPattern
   : nodePattern
   | edgePattern
   ;

nodePattern
   : LEFT_PAREN elementPatternFiller RIGHT_PAREN
   ;

elementPatternFiller
   : elementVariableDeclaration? isLabelExpression? elementPatternPredicate?
   ;

elementVariableDeclaration
   : TEMP? elementVariable
   ;

isLabelExpression
   : isOrColon labelExpression
   ;

isOrColon
   : IS
   | COLON
   ;

// [Extend: ALL] PERNODELIMIT
elementPatternPredicate
   : elementPatternWhereClause
   | elementPropertySpecification
   | perNodeLimitClause
   | perNodeLimitWherePredicate
   | perNodeLimitPropertyPredicate
   ;

elementPatternWhereClause
   : WHERE expression
   ;

elementPropertySpecification
   : LEFT_BRACE propertyKeyValuePairList RIGHT_BRACE
   ;

propertyKeyValuePairList
   : propertyKeyValuePair (COMMA propertyKeyValuePair)*
   ;

propertyKeyValuePair
   : propertyName COLON expression
   ;

// geabase扩展
perNodeLimitClause
   : PER_NODE_LIMIT unsignedIntegerSpecification
   | PER_NODE_LIMIT LEFT_PAREN unsignedIntegerSpecification RIGHT_PAREN
   ;

perNodeLimitWherePredicate
   : perNodeLimitLeftWherePredicate
   | perNodeLimitRightWherePredicate
   | perNodeLimitBothWherePredicate
   ;

perNodeLimitLeftWherePredicate
   : lhs = perNodeLimitClause elementPatternWhereClause
   ;

perNodeLimitRightWherePredicate
   : elementPatternWhereClause rhs = perNodeLimitClause
   ;

perNodeLimitBothWherePredicate
   : lhs = perNodeLimitClause elementPatternWhereClause rhs = perNodeLimitClause
   ;

perNodeLimitPropertyPredicate
   : lhs = perNodeLimitClause? elementPropertySpecification rhs = perNodeLimitClause?
   ;

edgePattern
   : fullEdgePattern
   | abbreviatedEdgePattern
   ;

fullEdgePattern
   : fullEdgePointingLeft
   | fullEdgeUndirected
   | fullEdgePointingRight
   | fullEdgeLeftOrUndirected
   | fullEdgeUndirectedOrRight
   | fullEdgeLeftOrRight
   | fullEdgeAnyDirection
   ;

fullEdgePointingLeft
   : LEFT_ANGLE_BRACKET MINUS_SIGN LEFT_BRACKET elementPatternFiller RIGHT_BRACKET MINUS_SIGN
   ; // <-[]-

fullEdgeUndirected
   : TILDE LEFT_BRACKET elementPatternFiller RIGHT_BRACKET TILDE
   ; // ~[]~

fullEdgePointingRight
   : MINUS_SIGN LEFT_BRACKET elementPatternFiller RIGHT_BRACKET RIGHT_ARROW
   ; // -[]->

fullEdgeLeftOrUndirected
   : LEFT_ANGLE_BRACKET TILDE LEFT_BRACKET elementPatternFiller RIGHT_BRACKET TILDE
   ; // <~[]~

fullEdgeUndirectedOrRight
   : TILDE LEFT_BRACKET elementPatternFiller RIGHT_BRACKET TILDE_RIGHT_ARROW
   ; // ~[]~>

fullEdgeLeftOrRight
   : LEFT_ANGLE_BRACKET MINUS_SIGN LEFT_BRACKET elementPatternFiller RIGHT_BRACKET RIGHT_ARROW
   ; // <-[]->

fullEdgeAnyDirection
   : MINUS_SIGN LEFT_BRACKET elementPatternFiller RIGHT_BRACKET MINUS_SIGN
   ; // -[]-

abbreviatedEdgePattern
   : LEFT_ANGLE_BRACKET MINUS_SIGN  #abbreviatedEdgePointingLeft
   | TILDE                          #abbreviatedEdgeUndirected
   | RIGHT_ARROW                    #abbreviatedEdgePointingRight
   | LEFT_ANGLE_BRACKET TILDE       #abbreviatedEdgeLeftOrUndirected
   | TILDE_RIGHT_ARROW              #abbreviatedEdgeUndirectedOrRight
   | LEFT_MINUS_RIGHT               #abbreviatedEdgeLeftOrRight
   | MINUS_SIGN                     #abbreviatedEdgeAnyDirection
   ;

parenthesizedPathPatternExpression
   : LEFT_PAREN parenthesizedPathPatternExpressionBody RIGHT_PAREN
   | LEFT_BRACKET parenthesizedPathPatternExpressionBody RIGHT_BRACKET
   ;

//[EXTEND:geaphi] sliding window start
parenthesizedPathPatternExpressionBody
   : subpathVariableDeclaration? pathModePrefix? pathPatternExpression slidingPart? parenthesizedPathPatternWhereClause? untilPart?
   ;

untilPart
   : UNTIL expression
   ;

slidingPart
   : SLIDING lengthPart (stepPart)? AS identifier (graphPatternWhereClause)?
   ;

lengthPart
   : LENGTH integerLiteral
   ;

stepPart
   : STEP integerLiteral
   ;
//[EXTEND:geaphi] sliding window end

subpathVariableDeclaration
   : subpathVariable EQUALS_OPERATOR
   ;

parenthesizedPathPatternWhereClause
   : WHERE expression
   ;

insertGraphPattern
   : insertPathPatternList
   ;

insertPathPatternList
   : insertPathPattern (COMMA insertPathPattern)*
   ;

insertPathPattern
   : insertNodePattern (insertEdgePattern insertNodePattern)*
   ;

insertNodePattern
   : LEFT_PAREN insertElementPatternFiller? RIGHT_PAREN
   ;

insertEdgePattern
   : insertEdgePointingLeft
   | insertEdgePointingRight
   | insertEdgeUndirected
   ;

insertEdgePointingLeft
   : LEFT_ANGLE_BRACKET MINUS_SIGN LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET MINUS_SIGN
   ;

insertEdgePointingRight
   : MINUS_SIGN LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET RIGHT_ARROW
   ;

insertEdgeUndirected
   : TILDE LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET TILDE
   ;

insertElementPatternFiller
   : elementVariableDeclaration labelAndPropertySetSpecification?
   | elementVariableDeclaration? labelAndPropertySetSpecification
   ;

labelAndPropertySetSpecification
   : isOrColon labelSetSpecification elementPropertySpecification?
   | (isOrColon labelSetSpecification)? elementPropertySpecification
   ;

labelExpression
   : labelTerm (VERTICAL_BAR labelTerm)*
   ;

labelTerm
   : labelFactor (AMPERSAND labelFactor)*
   ;

labelFactor
   : (EXCLAMATION_MARK)? labelPrimary
   ;

labelPrimary
   : labelName
   | wildcardLabel
   | parenthesizedLabelExpression
   ;

wildcardLabel
   : PERCENT
   ;

parenthesizedLabelExpression
   : LEFT_PAREN labelExpression RIGHT_PAREN
   ;

graphPatternQuantifier
   : ASTERISK
   | PLUS_SIGN
   | fixedQuantifier
   | generalQuantifier
   ;

fixedQuantifier
   : LEFT_BRACE UNSIGNED_DECIMAL_INTEGER RIGHT_BRACE
   ;

generalQuantifier
   : LEFT_BRACE lowerBound? COMMA upperBound? RIGHT_BRACE
   ;

lowerBound
   : UNSIGNED_DECIMAL_INTEGER
   ;

upperBound
   : UNSIGNED_DECIMAL_INTEGER
   ;

simplifiedPathPatternExpression
   : simplifiedDefaultingLeft
   | simplifiedDefaultingUndirected
   | simplifiedDefaultingRight
   | simplifiedDefaultingLeftOrUndirected
   | simplifiedDefaultingUndirectedOrRight
   | simplifiedDefaultingLeftOrRight
   | simplifiedDefaultingAnyDirection
   ;

simplifiedDefaultingLeft
   : LEFT_MINUS_SLASH simplifiedContents SOLIDUS MINUS_SIGN
   ;

simplifiedDefaultingUndirected
   : TILDE_SLASH simplifiedContents SOLIDUS TILDE
   ;

simplifiedDefaultingRight
   : MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT
   ;

simplifiedDefaultingLeftOrUndirected
   : LEFT_TILDE_SLASH simplifiedContents SOLIDUS TILDE
   ;

simplifiedDefaultingUndirectedOrRight
   : TILDE_SLASH simplifiedContents SLASH_TILDE_RIGHT
   ;

simplifiedDefaultingLeftOrRight
   : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT
   ;

simplifiedDefaultingAnyDirection
   : MINUS_SLASH simplifiedContents SOLIDUS MINUS_SIGN
   ;

simplifiedContents
   : simplifiedTerm
   | simplifiedPathUnion
   | simplifiedMultisetAlternation
   ;

simplifiedPathUnion
   : simplifiedTerm VERTICAL_BAR simplifiedTerm (VERTICAL_BAR simplifiedTerm)*
   ;

simplifiedMultisetAlternation
   : simplifiedTerm MULTISET_ALTERNATION_OPERATOR simplifiedTerm (MULTISET_ALTERNATION_OPERATOR simplifiedTerm)*
   ;

simplifiedTerm
   : (simplifiedFactorLow)+
   ;

simplifiedFactorLow
   : (simplifiedFactorHigh AMPERSAND)* simplifiedFactorHigh
   ;

simplifiedFactorHigh
   : simplifiedTertiary
   | simplifiedQuantified
   | simplifiedQuestioned
   ;

simplifiedQuantified
   : simplifiedTertiary graphPatternQuantifier
   ;

simplifiedQuestioned
   : simplifiedTertiary QUESTION_MARK
   ;

simplifiedTertiary
   : simplifiedDirectionOverride
   | simplifiedSecondary
   ;

simplifiedDirectionOverride
   : simplifiedOverrideLeft
   | simplifiedOverrideUndirected
   | simplifiedOverrideRight
   | simplifiedOverrideLeftOrUndirected
   | simplifiedOverrideUndirectedOrRight
   | simplifiedOverrideLeftOrRight
   | simplifiedOverrideAnyDirection
   ;

simplifiedOverrideLeft
   : LEFT_ANGLE_BRACKET simplifiedSecondary
   ;

simplifiedOverrideUndirected
   : TILDE simplifiedSecondary
   ;

simplifiedOverrideRight
   : simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideLeftOrUndirected
   : LEFT_ANGLE_BRACKET TILDE simplifiedSecondary
   ;

simplifiedOverrideUndirectedOrRight
   : TILDE simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideLeftOrRight
   : LEFT_ANGLE_BRACKET simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideAnyDirection
   : MINUS_SIGN simplifiedSecondary
   ;

simplifiedSecondary
   : simplifiedPrimary
   | simplifiedNegation
   ;

simplifiedNegation
   : EXCLAMATION_MARK simplifiedPrimary
   ;

simplifiedPrimary
   : labelName
   | LEFT_PAREN simplifiedContents RIGHT_PAREN
   ;

whereClause
   : WHERE expression
   ;

yieldClause
   : YIELD yieldItemList
   ;

yieldItemList
   : yieldItem (COMMA yieldItem)*
   ;

yieldItem
   : yieldItemName yieldItemAlias?
   ;

yieldItemName
   : fieldName
   ;

yieldItemAlias
   : AS bindingVariable
   ;

groupByClause
   : GROUP BY groupingElementList
   ;

groupingElementList
   : groupingElement (COMMA groupingElement)?
   | emptyGroupingSet
   ;

groupingElement
   : expression
   ; //gebabase : bindingVariableReference ->expression

emptyGroupingSet
   : LEFT_PAREN RIGHT_PAREN
   ;

orderByClause
   : ORDER BY sortSpecificationList
   ;

// geabase扩展count DISTINCT
aggregateFunction
   : COUNT LEFT_PAREN ASTERISK RIGHT_PAREN                                                                  #gqlCountAllFunction
   | COUNT LEFT_PAREN DISTINCT expression (COMMA expression)+ RIGHT_PAREN                                   #gqlCountDistinctFunction
   | generalSetFunctionType LEFT_PAREN setQuantifier? expression RIGHT_PAREN windowClause?                  #gqlGeneralSetFunction
   | binarySetFunctionType LEFT_PAREN setQuantifier? lhs = expression COMMA rhs = expression RIGHT_PAREN    #gqlBinarySetFunction
   | windowFunctionType LEFT_PAREN RIGHT_PAREN windowClause                                                 #gqlWindowFunction
   ;

// geabase扩展GROUP_CONCAT函数
generalSetFunctionType
   : AVG
   | COUNT
   | MAX
   | MIN
   | SUM
   | COLLECT
   | STDDEV_SAMP
   | STDDEV_POP
   | GROUP_CONCAT
   ;

setQuantifier
   : DISTINCT
   | ALL
   ;

binarySetFunctionType
   : PERCENTILE_CONT
   | PERCENTILE_DISC
   ;

//[Extend: Geaphi]: window function extend
windowFunctionType
   : ROW_NUMBER
   | RANK
   | DENSE_RANK
   | CUME_DIST
   | PERCENT_RANK
   ;

windowClause
   : OVER LEFT_PAREN PARTITION BY expressionAtom (COMMA expressionAtom)* (orderByClause)? RIGHT_PAREN
   ;

sortSpecificationList
   : sortSpecification (COMMA sortSpecification)*
   ;

sortSpecification
   : sortKey orderingSpecification? nullOrdering?
   ;

sortKey
   : expression
   ;

orderingSpecification
   : ASC
   | ASCENDING
   | DESC
   | DESCENDING
   ;

nullOrdering
   : NULLS FIRST
   | NULLS LAST
   ;

limitClause
   : LIMIT unsignedIntegerSpecification
   ;

offsetClause
   : offsetSynonym unsignedIntegerSpecification
   ;

offsetSynonym
   : OFFSET
   | SKIP_
   ;

graphTypeSpecification
   : PROPERTY? GRAPH TYPE nestedGraphTypeSpecification
   ;

nestedGraphTypeSpecification
   : LEFT_BRACE graphTypeSpecificationBody RIGHT_BRACE
   ;

graphTypeSpecificationBody
   : elementTypeDefinitionList
   ;

elementTypeDefinitionList
   : elementTypeDefinition (COMMA elementTypeDefinition)*
   ;

elementTypeDefinition
   : nodeTypeDefinition
   | edgeTypeDefinition
   ;

nodeTypeDefinition
   : nodeTypePattern
   | NODE_SYNONYM nodeTypePhrase
   ;

nodeTypePattern
   : LEFT_PAREN nodeTypeName? nodeTypeFiller? RIGHT_PAREN
   ;

nodeTypePhrase
   : TYPE? nodeTypeName nodeTypeFiller?
   | nodeTypeFiller
   ;

nodeTypeName
   : elementTypeName
   ;

nodeTypeFiller
   : nodeTypeLabelSetDefinition
   | nodeTypePropertyTypeSetDefinition
   | nodeTypeLabelSetDefinition nodeTypePropertyTypeSetDefinition
   ;

nodeTypeLabelSetDefinition
   : labelSetDefinition
   ;

nodeTypePropertyTypeSetDefinition
   : propertyTypeSetDefinition
   ;

edgeTypeDefinition
   : edgeTypePattern
   | edgeKind? EDGE_SYNONYM edgeTypePhrase
   ;

edgeTypePattern
   : fullEdgeTypePattern
   | abbreviatedEdgeTypePattern
   ;

edgeTypePhrase
   : TYPE? edgeTypeName (edgeTypeFiller endpointDefinition)?
   | edgeTypeFiller endpointDefinition
   ;

edgeTypeName
   : elementTypeName
   ;

edgeTypeFiller
   : edgeTypeLabelSetDefinition
   | edgeTypePropertyTypeSetDefinition
   | edgeTypeLabelSetDefinition edgeTypePropertyTypeSetDefinition
   ;

edgeTypeLabelSetDefinition
   : labelSetDefinition
   ;

edgeTypePropertyTypeSetDefinition
   : propertyTypeSetDefinition
   ;

fullEdgeTypePattern
   : fullEdgeTypePatternPointingRight
   | fullEdgeTypePatternPointingLeft
   | fullEdgeTypePatternUndirected
   ;

fullEdgeTypePatternPointingRight
   : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference
   ;

fullEdgeTypePatternPointingLeft
   : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference
   ;

fullEdgeTypePatternUndirected
   : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference
   ;

arcTypePointingRight
   : MINUS_SIGN LEFT_BRACKET arcTypeFiller RIGHT_BRACKET RIGHT_ARROW
   ;

arcTypePointingLeft
   : LEFT_ANGLE_BRACKET MINUS_SIGN LEFT_BRACKET arcTypeFiller RIGHT_BRACKET MINUS_SIGN
   ;

arcTypeUndirected
   : TILDE LEFT_BRACKET arcTypeFiller RIGHT_BRACKET TILDE
   ;

arcTypeFiller
   : edgeTypeName? edgeTypeFiller?
   ;

abbreviatedEdgeTypePattern
   : abbreviatedEdgeTypePatternPointingRight
   | abbreviatedEdgeTypePatternPointingLeft
   | abbreviatedEdgeTypePatternUndirected
   ;

abbreviatedEdgeTypePatternPointingRight
   : sourceNodeTypeReference RIGHT_ARROW destinationNodeTypeReference
   ;

abbreviatedEdgeTypePatternPointingLeft
   : destinationNodeTypeReference LEFT_ANGLE_BRACKET MINUS_SIGN sourceNodeTypeReference
   ;

abbreviatedEdgeTypePatternUndirected
   : sourceNodeTypeReference TILDE destinationNodeTypeReference
   ;

nodeTypeReference
   : sourceNodeTypeReference
   | destinationNodeTypeReference
   ;

sourceNodeTypeReference
   : LEFT_PAREN sourceNodeTypeName RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

destinationNodeTypeReference
   : LEFT_PAREN destinationNodeTypeName RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

edgeKind
   : DIRECTED
   | UNDIRECTED
   ;

endpointDefinition
   : CONNECTING endpointPairDefinition
   ;

endpointPairDefinition
   : endpointPairDefinitionPointingRight
   | endpointPairDefinitionPointingLeft
   | endpointPairDefinitionUndirected
   | abbreviatedEdgeTypePattern
   ;

endpointPairDefinitionPointingRight
   : LEFT_PAREN sourceNodeTypeName connectorPointingRight destinationNodeTypeName RIGHT_PAREN
   ;

endpointPairDefinitionPointingLeft
   : LEFT_PAREN destinationNodeTypeName LEFT_ANGLE_BRACKET MINUS_SIGN sourceNodeTypeName RIGHT_PAREN
   ;

endpointPairDefinitionUndirected
   : LEFT_PAREN sourceNodeTypeName connectorUndirected destinationNodeTypeName RIGHT_PAREN
   ;

connectorPointingRight
   : TO
   | RIGHT_ARROW
   ;

connectorUndirected
   : TO
   | TILDE
   ;

sourceNodeTypeName
   : elementTypeName
   ;

destinationNodeTypeName
   : elementTypeName
   ;

labelSetDefinition
   : LABEL labelName
   | LABELS labelNameSet
   | isOrColon labelNameSet
   ;

labelNameSet
   : labelName (COMMA labelName)?
   | LEFT_PAREN labelName (COMMA labelName)? RIGHT_PAREN
   ;

propertyTypeSetDefinition
   : LEFT_BRACE propertyTypeDefinitionList? RIGHT_BRACE
   ;

propertyTypeDefinitionList
   : propertyTypeDefinition (COMMA propertyTypeDefinition)*
   ;

propertyTypeDefinition
   : propertyName typed? propertyValueType
   ;

propertyValueType
   : valueType
   ;

bindingTableType
   : BINDING? TABLE fieldTypesSpecification
   ;

valueType
   : predefinedType                                                                                                      #predefType
   | pathValueType                                                                                                       #pathType
   | listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull? #listType1
   | valueType listValueTypeName (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?                                        #listType2
   | OPEN? RECORD notNull?                                                                                               #recordType1
   | RECORD? fieldTypesSpecification notNull?                                                                            #recordType2
   | ANY (VALUE)? (notNull)?                                                                                             #openDynamicUnionType
   | ANY? PROPERTY VALUE (notNull)?                                                                                      #dynamicPropertyValueType
   | ANY LEFT_ANGLE_BRACKET valueType (VERTICAL_BAR valueType)* RIGHT_ANGLE_BRACKET                                      #closedDynamicUnionType1
   | valueType (VERTICAL_BAR valueType)+                                                                                 #closedDynamicUnionType2
   ;

typed
   : DOUBLE_COLON
   | TYPED
   ;

predefinedType
   : booleanType
   | characterStringType
   | byteStringType
   | numericType
   | temporalType
   | referenceValueType
   ;

booleanType
   : (BOOL | BOOLEAN) notNull?
   ;

characterStringType
   : (STRING | VARCHAR) (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
   ;

byteStringType
   : BYTES (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
   | BINARY (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
   | VARBINARY (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
   ;

minLength
   : UNSIGNED_DECIMAL_INTEGER
   ;

maxLength
   : UNSIGNED_DECIMAL_INTEGER
   ;

fixedLength
   : UNSIGNED_DECIMAL_INTEGER
   ;

numericType
   : exactNumericType
   | approximateNumericType
   ;

exactNumericType
   : binaryExactNumericType
   | decimalExactNumericType
   ;

binaryExactNumericType
   : signedBinaryExactNumericType
   | unsignedBinaryExactNumericType
   ;

signedBinaryExactNumericType
   : INT8 notNull?
   | INT16 notNull?
   | INT32 notNull?
   | INT64 notNull?
   | INT128 notNull?
   | INT256 notNull?
   | SMALLINT notNull?
   | INT (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | BIGINT
   | SIGNED? verboseBinaryExactNumericType notNull?
   | LONG notNull? // geabase扩展，为了与现在保持一致加了notNull?

   ;

unsignedBinaryExactNumericType
   : UINT8 notNull?
   | UINT16 notNull?
   | UINT32 notNull?
   | UINT64 notNull?
   | UINT128 notNull?
   | UINT256 notNull?
   | USMALLINT notNull?
   | UINT (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | UBIGINT notNull?
   | UNSIGNED verboseBinaryExactNumericType notNull?
   ;

verboseBinaryExactNumericType
   : INTEGER8 notNull?
   | INTEGER16 notNull?
   | INTEGER32 notNull?
   | INTEGER64 notNull?
   | INTEGER128 notNull?
   | INTEGER256 notNull?
   | SMALL INTEGER notNull?
   | INTEGER (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | BIG INTEGER notNull?
   ;

decimalExactNumericType
   : (DECIMAL | DEC) (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN notNull?)?
   ;

precision
   : UNSIGNED_DECIMAL_INTEGER
   ;

scale
   : UNSIGNED_DECIMAL_INTEGER
   ;

approximateNumericType
   : FLOAT16 notNull?
   | FLOAT32 notNull?
   | FLOAT64 notNull?
   | FLOAT128 notNull?
   | FLOAT256 notNull?
   | FLOAT (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN)? notNull?
   | REAL notNull?
   | DOUBLE PRECISION? notNull?
   ;

temporalType
   : temporalInstantType
   | temporalDurationType
   ;

temporalInstantType
   : datetimeType
   | localdatetimeType
   | dateType
   | timeType
   | localtimeType
   ;

temporalDurationType
   : durationType
   ;

datetimeType
   : ZONED DATETIME notNull?
   | TIMESTAMP WITH TIMEZONE notNull?
   | DATETIME notNull? // geabase cast (x AS Datetime)
   ;

localdatetimeType
   : LOCAL DATETIME notNull?
   | TIMESTAMP (WITHOUT TIMEZONE)? notNull?
   ;

dateType
   : DATE notNull?
   ;

timeType
   : ZONED TIME notNull?
   | TIME WITH TIMEZONE notNull?
   ;

localtimeType
   : LOCAL TIME notNull?
   | TIME WITHOUT TIMEZONE notNull?
   ;

durationType
   : DURATION notNull?
   ;

referenceValueType
   : graphReferenceValueType
   | bindingTableReferenceValueType
   | nodeReferenceValueType
   | edgeReferenceValueType
   ;

graphReferenceValueType
   : openGraphReferenceValueType
   | closedGraphReferenceValueType
   ;

closedGraphReferenceValueType
   : graphTypeSpecification notNull?
   ;

openGraphReferenceValueType
   : OPEN PROPERTY? GRAPH notNull?
   ;

bindingTableReferenceValueType
   : bindingTableType notNull?
   ;

nodeReferenceValueType
   : openNodeReferenceValueType
   | closedNodeReferenceValueType
   ;

closedNodeReferenceValueType
   : nodeTypeDefinition notNull?
   ;

openNodeReferenceValueType
   : OPEN? NODE_SYNONYM notNull?
   ;

edgeReferenceValueType
   : openEdgeReferenceValueType
   | closedEdgeReferenceValueType
   ;

closedEdgeReferenceValueType
   : edgeTypeDefinition notNull?
   ;

openEdgeReferenceValueType
   : OPEN? EDGE_SYNONYM notNull?
   ;

listValueTypeName
   : GROUP? listValueTypeNameSynonym
   ;

listValueTypeNameSynonym
   : LIST
   | ARRAY
   ;

fieldTypesSpecification
   : LEFT_BRACE fieldTypeList? RIGHT_BRACE
   ;

fieldTypeList
   : fieldType (COMMA fieldType)*
   ;

pathValueType
   : PATH notNull?
   ;

notNull
   : NOT NULL
   ;

fieldType
   : fieldName typed? valueType
   ;

schemaReference
   : absoluteCatalogSchemaReference
   | relativeCatalogSchemaReference
   | referenceParameter
   ;

absoluteCatalogSchemaReference
   : SOLIDUS
   | absoluteDirectoryPath schemaName
   ;

catalogSchemaParentAndName
   : absoluteDirectoryPath schemaName
   ;

relativeCatalogSchemaReference
   : predefinedSchemaReference
   | relativeDirectoryPath schemaName
   ;

predefinedSchemaReference
   : HOME_SCHEMA
   | CURRENT_SCHEMA
   | PERIOD
   ;

absoluteDirectoryPath
   : SOLIDUS simpleDirectoryPath?
   ;

relativeDirectoryPath
   : DOUBLE_PERIOD ((SOLIDUS DOUBLE_PERIOD)* SOLIDUS simpleDirectoryPath?)?
   ;

simpleDirectoryPath
   : (directoryName SOLIDUS)+
   ;

graphReference
   : catalogObjectParentReference graphName
   | delimitedGraphName
   | homeGraph
   | referenceParameter
   ;

catalogGraphParentAndName
   : catalogObjectParentReference? graphName
   ;

homeGraph
   : HOME_PROPERTY_GRAPH
   | HOME_GRAPH
   ;

graphTypeReference
   : catalogGraphTypeParentAndName
   | referenceParameter
   ;

catalogGraphTypeParentAndName
   : catalogObjectParentReference? graphTypeName
   ;

bindingTableReference
   : catalogObjectParentReference bindingTableName
   | delimitedBindingTableName
   | referenceParameter
   ;

catalogBindingTableParentAndName
   : catalogObjectParentReference? bindingTableName
   ;

procedureReference
   : catalogProcedureParentAndName
   | referenceParameter
   ;

catalogProcedureParentAndName
   : catalogObjectParentReference? procedureName
   ;

catalogObjectParentReference
   : schemaReference SOLIDUS? (objectName PERIOD)*
   | (objectName PERIOD)+
   ;

referenceParameter
   : parameter
   ;

// TODO: 需要参考URI的标准，优先级低
externalObjectReference
   : I_DONT_KNOW_3
   ;

comparisonPredicateCond
   : compOp expression
   ;

compOp
   : EQUALS_OPERATOR
   | NOT_EQUALS_OPERATOR
   | LEFT_ANGLE_BRACKET
   | RIGHT_ANGLE_BRACKET
   | LESS_THAN_OR_EQUALS_OPERATOR
   | GREATER_THAN_OR_EQUALS_OPERATOR
   | SAFE_EXQUAL_OPERATOR
   ;

nullPredicateCond
   : IS NOT? NULL
   ;

normalizedPredicateCond
   : IS NOT? normalForm? NORMALIZED
   ;

directedPredicateCond
   : IS NOT? DIRECTED
   ;

labeledPredicateCond
   : (IS NOT? LABELED | COLON) labelExpression
   ;

sourceDestinationPredicateCond
   : IS NOT? (SOURCE | DESTINATION) OF elementVariableReference
   ;
   //表达式重构

expression
   : NOT expression                                                         #gqlNotExpression
   | lhs = expression AND rhs = expression                                  #gqlLogicalAndExpression
   | lhs = expression XOR rhs = expression                                  #gqlLogicalXorExpression
   | lhs = expression (OR | CONCATENATION_OPERATOR) rhs = expression        #gqlLogicalOrExpression  //geabase 拓展了or，可以用||代替
   | expressionPredicate                                                    #gqlPredicateExpression
   ;

expressionPredicate
   : expressionPredicate NOT? IN listValueTypeName? listValue                                           #gqlInExpression
   | expressionPredicate (IS NOT? | EQUALS_OPERATOR | NOT_EQUALS_OPERATOR) truthValue                   #gqlBooleanTestExpression
   | self = expressionPredicate NOT? LIKE regex = expressionPredicate                                   #gqlLikeExpression
   | lhs = expressionPredicate compOp rhs = expressionPredicate                                         #gqlComparisonExpression
   | val = expressionPredicate NOT? BETWEEN low = expressionPredicate AND high = expressionPredicate    #gqlBetweenExpression
   | EXISTS ( LEFT_BRACE graphPattern RIGHT_BRACE
            | LEFT_PAREN graphPattern RIGHT_PAREN
            | LEFT_BRACE matchStatementBlock RIGHT_BRACE
            | LEFT_PAREN matchStatementBlock RIGHT_PAREN
            | nestedQuerySpecification)                                                                 #gqlExistsExpression
   | expressionPredicate nullPredicateCond                                                              #gqlNullExpression
   | expressionAtom normalizedPredicateCond                                                             #gqlNormalizedExpression
   | elementVariableReference directedPredicateCond                                                     #gqlDirectedExpression
   | elementVariableReference labeledPredicateCond                                                      #gqlLabeledExpression
   | elementVariableReference sourceDestinationPredicateCond                                            #gqlSourceDestinationExpression
   | ALL_DIFFERENT LEFT_PAREN elementVariableReference (COMMA elementVariableReference)+ RIGHT_PAREN    #gqlAllDifferentExpression
   | SAME LEFT_PAREN elementVariableReference (COMMA elementVariableReference)+ RIGHT_PAREN             #gqlSameExpression
   | PROPERTY_EXISTS LEFT_PAREN elementVariableReference COMMA propertyName RIGHT_PAREN                 #gqlPropertyExistExpression
   | PROPERTY? GRAPH graphExpression                                                                    #gqlGraphRefValueExpression
   | BINDING? TABLE bindingTableExpression                                                              #gqlBindingTableValueExpression
   | LET letVariableDefinitionList IN expression END                                                    #gqlLetExpression
   | expressionAtom                                                                                     #gqlAtomExpression
   ;
   //类似expression primary

expressionAtom
   : LEFT_PAREN expression RIGHT_PAREN                                                      #gqlParenthesizedExpression
   | expressionAtom LEFT_BRACKET unsignedNumericLiteral RIGHT_BRACKET                       #gqlSubscriptExpression //[EXTEND: GeaPhi]: 下标支持 TODO:结合顺序问题？qiyi
   | expressionAtom PERIOD propertyName                                                     #gqlPropertyReference
//   | expressionAtom CONCATENATION_OPERATOR expressionAtom                                   #gqlConcatenationExpression // geabase用||作为OR，这里作为concat的暂时注释掉
   | variable                                                                               #gqlVariableExpression
   | unsignedLiteral                                                                        #gqlLiteralExpression
   | unaryOperator expressionAtom                                                           #gqlUnaryExpression
   | functionCall                                                                           #gqlFunctionExpression
   | collectionValueConstructor                                                             #gqlCollectionExpression
   | VALUE nestedQuerySpecification                                                         #gqlValueQueryExpression
   | lhs = expressionAtom CIRCUMFLEX rhs = expressionAtom                                   #gqlBitXorExpression // geabase扩展
   | lhs = expressionAtom op = (ASTERISK | SOLIDUS | PERCENT | MOD) rhs = expressionAtom    #gqlHighArithmeticExpression //  PERCENT MOD 为geabase扩展
   | lhs = expressionAtom op = (PLUS_SIGN | MINUS_SIGN) rhs = expressionAtom                #gqlLowArithmeticExpression
   | lhs = expressionAtom (LEFT_SHIFT | RIGHT_SHIFT) rhs = expressionAtom                   #gqlBitShiftExpression // geabase扩展
   | lhs = expressionAtom AMPERSAND rhs = expressionAtom                                    #gqlBitAndExpression // geabase扩展
   | lhs = expressionAtom VERTICAL_BAR rhs = expressionAtom                                 #gqlBitOrExpression // geabase扩展
   | parameterValueSpecification                                                            #gqlParameterExpression
   ;

truthValue
   : TRUE
   | FALSE
   | UNKNOWN
   ;

unaryOperator
   : EXCLAMATION_MARK
   | PLUS_SIGN
   | MINUS_SIGN
   | TILDE // TILDE为geabase扩展
   ;

// functions yielding a value of expression,including numeric value function ,string value function and so on.
functionCall
   : numericFunction
   | aggregateFunction
   | caseFunction
   | castFunction
   | elementFunction
   | datetimeValueFunction
   | durationFunction
   | listFunction
   | stringFunction
   | generalFunction
   ;

numericFunction
   : oneArgNumericFunctionName LEFT_PAREN functionParameter RIGHT_PAREN                             #gqlOneArgScalarFunction
   | twoArgNumericFunctionName LEFT_PAREN functionParameter COMMA functionParameter RIGHT_PAREN     #gqlTwoArgScalarFunction
   | IF LEFT_PAREN functionParameter COMMA functionParameter COMMA functionParameter RIGHT_PAREN    #gqlIfFunction
   ;

//可能存在ambiguities
functionParameter
   : unsignedLiteral
   | variable
   | propertyReference
   | functionCall
   | expression
   ;

propertyReference
   : variable PERIOD propertyName
   ;

oneArgNumericFunctionName
   : CHAR_LENGTH
   | CHARACTER_LENGTH
   | BYTE_LENGTH
   | OCTET_LENGTH
   | PATH_LENGTH
   | ABS
   | SIN
   | COS
   | TAN
   | COT
   | SINH
   | COSH
   | TANH
   | ASIN
   | ACOS
   | ATAN
   | DEGREES
   | RADIANS
   | LOG10
   | LN
   | EXP
   | SQRT
   | FLOOR
   | CEIL
   | CEILING
   | LOG // geabase log函数只需一个参数，增加支持
   | LAST // geabase last(list)函数，因为last是保留字所以先留在这里？实际上..
   | LABELS // geabase扩展labels 和 label函数
   | LABEL // geabase扩展labels 和 label函数
   | LENGTH // geabase length("")函数，理由同LAST

   ;

twoArgNumericFunctionName
   : MOD
   | LOG
   | POWER
   ;

stringFunction
   : SUBSTR LEFT_PAREN str = expressionAtom COMMA startPos = expressionAtom (COMMA len = expressionAtom)? RIGHT_PAREN   #gqlSubstringFunction
   | LEFT LEFT_PAREN expressionAtom COMMA expressionAtom RIGHT_PAREN                                                    #gqlLeftStringFunction
   | RIGHT LEFT_PAREN expressionAtom COMMA expressionAtom RIGHT_PAREN                                                   #gqlRightStringFunction
   | dir = (UPPER | LOWER) LEFT_PAREN expressionAtom RIGHT_PAREN                                                        #gqlFoldStringFunction
   | TRIM LEFT_PAREN (trimSpecification? expressionAtom? FROM)? trimSrc = expressionAtom RIGHT_PAREN                    #gqlSingleTrimStringFunction
   | dir = (BTRIM | LTRIM | RTRIM) LEFT_PAREN trimSrc = expressionAtom (COMMA delChar = expressionAtom)? RIGHT_PAREN    #gqlMultiTrimStringFunction
   | NORMALIZE LEFT_PAREN expressionAtom (COMMA normalForm)? RIGHT_PAREN                                                #gqlNormStringFunction
   ;

listFunction
   : TRIM LEFT_PAREN list = expressionAtom COMMA trim = expressionAtom RIGHT_PAREN      #gqlListTrimFunction
   | ELEMENTS LEFT_PAREN expressionAtom RIGHT_PAREN                                     #gqlElementsOfPathFunction
   ;

// geabase 扩展coalesce函数 最少需要一个参数（与draft不同，draft需要至少两个
caseFunction
   : NULLIF LEFT_PAREN lhs = expression COMMA rhs = expression RIGHT_PAREN  #gqlNullIfCaseFunction
   | COALESCE LEFT_PAREN expression (COMMA expression)* RIGHT_PAREN         #gqlCoalesceCaseFunction
   | CASE expressionAtom simpleWhenClause+ elseClause? END                  #gqlSimpleCaseFunction
   | CASE searchedWhenClause+ elseClause? END                               #gqlSearchedCaseFunction
   ;

simpleWhenClause
   : WHEN whenOperand (COMMA whenOperand)* THEN expression
   ;

searchedWhenClause
   : WHEN expression THEN expression
   ;

elseClause
   : ELSE expression
   ;

whenOperand
   : expressionAtom
   | comparisonPredicateCond
   | nullPredicateCond
   | directedPredicateCond
   | labeledPredicateCond
   | sourceDestinationPredicateCond
   ;

// cast specification
castFunction
   : CAST LEFT_PAREN expression AS valueType RIGHT_PAREN //geabase用的predefinedType，这里value type可以包括
   ;

elementFunction
   : elementFunctionName LEFT_PAREN variable RIGHT_PAREN
   ;

// TODO[lili]:geabase扩展 ID + TIMESTAMP + LENGTH , IN/OUT_DEGREE没用到暂时先注释掉。 像这种保留字的函数到底应该放到哪里？
// 放到这里的原因是length(path) timestamp(r) r都是指定的变量；id(n) 应该也是变量，但id如果作为保留字会与n.id冲突
elementFunctionName
   : LENGTH //check 冲突？
   //    | IN_DEGREE
   //    | OUT_DEGREE
   | ELEMENT_ID
   //    | ID
   | TIMESTAMP
   ;

datetimeValueFunction
   : dateFunction
   | timeFunction
   | datetimeFunction
   | localTimeFunction
   | localDatetimeFunction
   ;

dateFunction
   : CURRENT_DATE
   | DATE LEFT_PAREN dateFunctionParameters? RIGHT_PAREN
   ;

timeFunction
   : CURRENT_TIME
   | ZONED_TIME LEFT_PAREN timeFunctionParameters? RIGHT_PAREN
   ;

localTimeFunction
   : LOCAL_TIME (LEFT_PAREN timeFunctionParameters? RIGHT_PAREN)?
   ;

datetimeFunction
   : CURRENT_TIMESTAMP
   | ZONED_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

localDatetimeFunction
   : LOCAL_TIMESTAMP
   | LOCAL_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

durationFunction
   : DURATION_BETWEEN LEFT_PAREN expressionAtom COMMA expressionAtom RIGHT_PAREN    #gqlDatetimeSubtractionFunction
   | DURATION LEFT_PAREN durationFunctionParameters RIGHT_PAREN                     #gqlDurationFunction
   ;

dateFunctionParameters
   : dateString
   | recordValueConstructor
   ;

timeFunctionParameters
   : timeString
   | recordValueConstructor
   ;

datetimeFunctionParameters
   : datetimeString
   | recordValueConstructor
   ;

dateString
   : unbrokenCharacterStringLiteral
   ;

timeString
   : unbrokenCharacterStringLiteral
   ;

datetimeString
   : unbrokenCharacterStringLiteral
   ;

durationFunctionParameters
   : durationString
   | recordValueConstructor
   ;

durationString
   : unbrokenCharacterStringLiteral
   ;

generalFunction
   : functionName LEFT_PAREN procedureArgumentList? RIGHT_PAREN
   ;

collectionValueConstructor
   : listValueConstructor
   | recordValueConstructor
   | pathValueConstructor
   | mapValueConstructor // geabase 拓展
   ;

trimSpecification
   : LEADING
   | TRAILING
   | BOTH
   ;

normalForm
   : NFC
   | NFD
   | NFKC
   | NFKD
   ;

listValueConstructor
   : listValueTypeName? LEFT_BRACKET (expression (COMMA expression)*)? RIGHT_BRACKET
   ;

listValue
   : LEFT_BRACKET expression (COMMA expression)* RIGHT_BRACKET
   | LEFT_PAREN expression (COMMA expression)* RIGHT_PAREN
   ;

recordValueConstructor
   : RECORD? LEFT_BRACE (field (COMMA field)*)? RIGHT_BRACE
   ;

field
   : key = fieldName COLON value = expression
   ;

pathValueConstructor
   : PATH LEFT_BRACKET expressionAtom (COMMA expressionAtom COMMA expressionAtom)* RIGHT_BRACKET
   ;

// map constructor  geabase拓展 这本来是draft上一个版本存在的 最新的已经删掉了，但是宁波poc上有需求要有MAP
mapValueConstructor
   : MAP LEFT_BRACE mapElement (COMMA mapElement)* RIGHT_BRACE
   ;

mapElement
   : key = expression COLON value = expression
   ;

unsignedValueSpecification
   : unsignedLiteral
   | parameterValueSpecification
   ;

unsignedIntegerSpecification
   : integerLiteral
   | parameter
   ;

parameterValueSpecification
   : parameter
   | predefinedParameter
   ;

predefinedParameter
   : CURRENT_USER
   ;

unsignedLiteral
   : unsignedNumericLiteral
   | generalLiteral
   ;

generalLiteral
   : predefinedTypeLiteral
   | listLiteral
   | mapLiteral
   | recordLiteral
   ;

listLiteral
   : listValueTypeName? LEFT_BRACKET (generalLiteral (COMMA generalLiteral)*)? RIGHT_BRACKET
   ;

mapLiteral
   : MAP LEFT_BRACE mapElementLiteral (COMMA mapElementLiteral)* RIGHT_BRACE
   ;

mapElementLiteral
   : key = generalLiteral COLON value = generalLiteral
   ;

recordLiteral
   : RECORD? LEFT_BRACE (recordFieldLiteral (COMMA recordFieldLiteral)*)? RIGHT_BRACE
   ;

recordFieldLiteral
   : key = variable COLON value = generalLiteral
   ;
