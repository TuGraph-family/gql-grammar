parser grammar GQLParser;

options{ tokenVocab = GQLLexer; }

//入口
gqlRequest
    : gqlProgram COLON? EOF
    ;

gqlProgram : programActivity sessionCloseCommand?|sessionCloseCommand ;
programActivity : sessionActivity|transactionActivity ;
sessionActivity : sessionActivityCommand+ ;
sessionActivityCommand : sessionSetCommand|sessionResetCommand ;
transactionActivity : startTransactionCommand ( procedureSpecification endTransactionCommand? )?|procedureSpecification endTransactionCommand?|endTransactionCommand ;
endTransactionCommand : rollbackCommand|commitCommand ;
sessionSetCommand : SESSION SET ( sessionSetSchemaClause|sessionSetGraphClause|sessionSetTimeZoneClause|sessionSetParameterClause ) ;
sessionSetSchemaClause : SCHEMA schemaReference ;
sessionSetGraphClause : PROPERTY? GRAPH graphExpression ;
sessionSetTimeZoneClause : TIME ZONE setTimeZoneValue ;
setTimeZoneValue : stringValueExpression ;
sessionSetParameterClause : sessionSetGraphParameterClause|sessionSetBindingTableParameterClause|sessionSetValueParameterClause ;
sessionSetGraphParameterClause : PROPERTY? GRAPH sessionSetParameterName optTypedGraphInitializer ;
sessionSetBindingTableParameterClause : BINDING? TABLE sessionSetParameterName optTypedBindingTableInitializer ;
sessionSetValueParameterClause : VALUE sessionSetParameterName optTypedValueInitializer ;
sessionSetParameterName : parameterName ( IF NOT EXISTS )? ;
sessionResetCommand : SESSION? RESET sessionResetArguments? ;
sessionResetArguments : ALL? ( PARAMETERS|CHARACTERISTICS )|SCHEMA|PROPERTY? GRAPH|TIME ZONE|PARAMETER? parameterName ;
sessionCloseCommand : SESSION? CLOSE ;
startTransactionCommand : START TRANSACTION transactionCharacteristics? ;
transactionCharacteristics : transactionMode ( COMMA transactionMode )* ;
transactionMode : transactionAccessMode|implementationDefinedAccessMode ;
transactionAccessMode : READ ONLY|READ WRITE ;
implementationDefinedAccessMode : I_DONT_KNOW_1 ; //TODO: 需要参考其他标准定义，暂时空置
rollbackCommand : ROLLBACK ;
commitCommand : COMMIT ;

nestedProcedureSpecification : LEFT_BRACE procedureSpecification RIGHT_BRACE ;
procedureSpecification : catalogModifyingProcedureSpecification|dataModifyingProcedureSpecification|querySpecification ;
catalogModifyingProcedureSpecification : procedureBody ;
nestedDataModifyingProcedureSpecification : LEFT_BRACE dataModifyingProcedureSpecification RIGHT_BRACE ;
dataModifyingProcedureSpecification : procedureBody ;
nestedQuerySpecification : LEFT_BRACE procedureSpecification RIGHT_BRACE ;
querySpecification : procedureBody ;

unsignedNumericLiteral : exactNumericLiteral|approximateNumericLiteral ;

exactNumericLiteral :
    UNSIGNED_DECIMAL_INTEGER
    |unsignedDecimalInCommonNotation EXACT_NUMBER_SUFFIX?
    |UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION EXACT_NUMBER_SUFFIX
    |UNSIGNED_DECIMAL_INTEGER EXACT_NUMBER_SUFFIX? ;

approximateNumericLiteral :
    unsignedDecimalInCommonNotation APPROXIMATE_NUMBER_SUFFIX
    |UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION APPROXIMATE_NUMBER_SUFFIX?
    |UNSIGNED_DECIMAL_INTEGER APPROXIMATE_NUMBER_SUFFIX ;

unsignedDecimalInCommonNotation : UNSIGNED_DECIMAL_INTEGER ( PERIOD UNSIGNED_DECIMAL_INTEGER? )?|PERIOD UNSIGNED_DECIMAL_INTEGER ;

unbrokenSingleQuotedCharacterSequence: SINGLE_QUOTED_STRING_LITERAL ;
unbrokenDoubleQuotedCharacterSequence: DOUBLE_QUOTED_STRING_LITERAL ;
unbrokenAccentQuotedCharacterSequence: ACCENT_QUOTED_STRING_LITERAL ;

singleQuotedCharacterSequence : noEscape? unbrokenSingleQuotedCharacterSequence ( VERTICAL_BAR unbrokenSingleQuotedCharacterSequence )* ;
doubleQuotedCharacterSequence : noEscape? unbrokenDoubleQuotedCharacterSequence ( VERTICAL_BAR unbrokenDoubleQuotedCharacterSequence )* ;
accentQuotedCharacterSequence : noEscape? unbrokenAccentQuotedCharacterSequence ( VERTICAL_BAR unbrokenAccentQuotedCharacterSequence )* ;
unbrokenCharacterStringLiteral : (unbrokenSingleQuotedCharacterSequence | unbrokenDoubleQuotedCharacterSequence) ;
noEscape : COMMERCIAL_AT ;
nullLiteral : NULL ;
temporalLiteral : dateLiteral|timeLiteral|datetimeLiteral|sqlDatetimeLiteral ;
sqlDatetimeLiteral :
    DATE QUOTE FOUR_DIGIT MINUS_SIGN DOUBLE_DIGIT MINUS_SIGN DOUBLE_DIGIT QUOTE
    | TIME QUOTE DOUBLE_DIGIT COLON DOUBLE_DIGIT COLON DOUBLE_DIGIT QUOTE
    | TIMESTAMP QUOTE FOUR_DIGIT MINUS_SIGN DOUBLE_DIGIT MINUS_SIGN DOUBLE_DIGIT
        DOUBLE_DIGIT COLON DOUBLE_DIGIT COLON DOUBLE_DIGIT QUOTE
    | DATETIME  QUOTE FOUR_DIGIT MINUS_SIGN DOUBLE_DIGIT MINUS_SIGN DOUBLE_DIGIT
        DOUBLE_DIGIT COLON DOUBLE_DIGIT COLON DOUBLE_DIGIT QUOTE ;
dateLiteral : DATE unbrokenCharacterStringLiteral ;
timeLiteral : TIME unbrokenCharacterStringLiteral ;
datetimeLiteral : ( DATETIME|TIMESTAMP ) unbrokenCharacterStringLiteral ;
durationLiteral : DURATION unbrokenCharacterStringLiteral|sqlIntervalLiteral ;
sqlIntervalLiteral : UNSIGNED_DECIMAL_INTEGER sqlIntervalType ;
sqlIntervalType : INTERVAL_DAY | INTERVAL_WEEK | INTERVAL_MONTH | INTERVAL_YEAR;
identifier : REGULAR_IDENTIFIER|delimitedIdentifier | EXACT_NUMBER_SUFFIX | APPROXIMATE_NUMBER_SUFFIX ;
delimitedIdentifier : doubleQuotedCharacterSequence|accentQuotedCharacterSequence ;
// CHANGELOG：separatedIdentifier EXTENDED_IDENTIFIER -> REGULAR_IDENTIFIER
separatedIdentifier : REGULAR_IDENTIFIER|delimitedIdentifier | EXACT_NUMBER_SUFFIX | APPROXIMATE_NUMBER_SUFFIX ;
// nonDelimitedIdentifier : REGULAR_IDENTIFIER|EXTENDED_IDENTIFIER ;
objectName : identifier ;
objectNameOrBindingVariable : REGULAR_IDENTIFIER | EXACT_NUMBER_SUFFIX | APPROXIMATE_NUMBER_SUFFIX;
directoryName : identifier ;
schemaName : identifier ;
graphName : REGULAR_IDENTIFIER|delimitedGraphName ;
delimitedGraphName : delimitedIdentifier ;
graphTypeName : identifier ;
elementTypeName : identifier ;
bindingTableName : REGULAR_IDENTIFIER|delimitedBindingTableName ;
delimitedBindingTableName : delimitedIdentifier ;
procedureName : identifier ;
labelName : identifier ;
functionName : identifier;
propertyName : identifier ;
fieldName : identifier ;
// change unsignedDecimalInteger to unsignedNumericLiteral
parameterName : '$' (unsignedNumericLiteral|separatedIdentifier) ;
variable : graphVariable|graphPatternVariable|bindingTableVariable|valueVariable|bindingVariable ;
graphVariable : bindingVariable ;
graphPatternVariable : elementVariable|pathOrSubpathVariable ;
pathOrSubpathVariable : pathVariable|subpathVariable ;
elementVariable : bindingVariable ;
pathVariable : bindingVariable ;
subpathVariable : REGULAR_IDENTIFIER | EXACT_NUMBER_SUFFIX | APPROXIMATE_NUMBER_SUFFIX ;
bindingTableVariable : bindingVariable ;
valueVariable : bindingVariable ;
bindingVariable : REGULAR_IDENTIFIER | EXACT_NUMBER_SUFFIX | APPROXIMATE_NUMBER_SUFFIX ;
predefinedTypeLiteral : booleanLiteral|characterStringLiteral|BYTE_STRING_LITERAL|temporalLiteral|durationLiteral|nullLiteral ;
booleanLiteral : TRUE|FALSE|UNKNOWN ;
characterStringLiteral : singleQuotedCharacterSequence|doubleQuotedCharacterSequence ;

//******************************************************************
// 9.2 procedure Body
procedureBody : atSchemaClause? bindingVariableDefinitionBlock? statementBlock ;
bindingVariableDefinitionBlock : bindingVariableDefinition+ ;
bindingVariableDefinition : graphVariableDefinition|bindingTableVariableDefinition|valueVariableDefinition ;
statementBlock : statement nextStatement* ;
statement : linearCatalogModifyingStatement|linearDataModifyingStatement|compositeQueryStatement ;
nextStatement : NEXT yieldClause? statement ; //Notice！！Then消失了，变成了Next
graphVariableDefinition : PROPERTY? GRAPH graphVariable optTypedGraphInitializer ;
optTypedGraphInitializer : ( typed? graphReferenceValueType )? graphInitializer ;
graphInitializer : EQUALS_OPERATOR graphExpression ;
bindingTableVariableDefinition : BINDING? TABLE bindingTableVariable optTypedBindingTableInitializer ;
optTypedBindingTableInitializer : ( typed? bindingTableReferenceValueType )? bindingTableInitializer ;
bindingTableInitializer : EQUALS_OPERATOR bindingTableExpression ;

valueVariableDefinition : VALUE valueVariable optTypedValueInitializer ;
optTypedValueInitializer : ( typed? valueType )? valueInitializer ;
valueInitializer : EQUALS_OPERATOR valueExpression ;

graphExpression : nestedGraphQuerySpecification|objectExpressionPrimary|graphReference|objectNameOrBindingVariable|currentGraph ;
currentGraph : CURRENT_PROPERTY_GRAPH|CURRENT_GRAPH ;
nestedGraphQuerySpecification : nestedQuerySpecification ;
bindingTableExpression : nestedBindingTableQuerySpecification|objectExpressionPrimary|bindingTableReference|objectNameOrBindingVariable ;
nestedBindingTableQuerySpecification : nestedQuerySpecification ;
objectExpressionPrimary : variable valueExpressionPrimary|parenthesizedValueExpression|nonParenthesizedValueExpressionPrimarySpecialCase ;

linearCatalogModifyingStatement : simpleCatalogModifyingStatement+ ;
simpleCatalogModifyingStatement : primitiveCatalogModifyingStatement|callCatalogModifyingProcedureStatement ;
primitiveCatalogModifyingStatement : createSchemaStatement|createGraphStatement|createGraphTypeStatement|dropSchemaStatement|dropGraphStatement|dropGraphTypeStatement ;
createSchemaStatement : CREATE SCHEMA ( IF NOT EXISTS )? catalogSchemaParentAndName ;
dropSchemaStatement : DROP SCHEMA ( IF EXISTS )? catalogSchemaParentAndName ;
createGraphStatement : CREATE ( PROPERTY? GRAPH ( IF NOT EXISTS )?|OR REPLACE PROPERTY? GRAPH ) catalogGraphParentAndName ( openGraphType|ofGraphType ) graphSource? ;
openGraphType : OPEN ( PROPERTY? GRAPH )? TYPE ;
ofGraphType : graphTypeLikeGraph|typed? graphTypeReference|typed? nestedGraphTypeSpecification ;
graphTypeLikeGraph : LIKE graphExpression ;
graphSource : AS COPY OF graphExpression ;
dropGraphStatement : DROP PROPERTY? GRAPH ( IF EXISTS )? catalogGraphParentAndName ;
createGraphTypeStatement : CREATE ( PROPERTY? GRAPH TYPE ( IF NOT EXISTS )?|OR REPLACE PROPERTY? GRAPH TYPE ) catalogGraphTypeParentAndName graphTypeSource ;
graphTypeSource : AS? copyOfGraphType|graphTypeLikeGraph|AS? nestedGraphTypeSpecification ;
copyOfGraphType : COPY OF ( graphTypeReference|externalObjectReference ) ;
dropGraphTypeStatement : DROP PROPERTY? GRAPH TYPE ( IF EXISTS )? catalogGraphTypeParentAndName ;
callCatalogModifyingProcedureStatement : callProcedureStatement ;
linearDataModifyingStatement : focusedLinearDataModifyingStatement|ambientLinearDataModifyingStatement ;
focusedLinearDataModifyingStatement : focusedLinearDataModifyingStatementBody|focusedNestedDataModifyingProcedureSpecification ;
focusedLinearDataModifyingStatementBody : useGraphClause simpleLinearDataAccessingStatement primitiveResultStatement? ;
focusedNestedDataModifyingProcedureSpecification : useGraphClause nestedDataModifyingProcedureSpecification ;
ambientLinearDataModifyingStatement : ambientLinearDataModifyingStatementBody|nestedDataModifyingProcedureSpecification ;
ambientLinearDataModifyingStatementBody : simpleLinearDataAccessingStatement primitiveResultStatement? ;
simpleLinearDataAccessingStatement : simpleDataAccessingStatement+ ;
simpleDataAccessingStatement : simpleQueryStatement|simpleDataModifyingStatement ;
simpleDataModifyingStatement : primitiveDataModifyingStatement|callDataModifyingProcedureStatement ;
primitiveDataModifyingStatement : insertStatement|setStatement|removeStatement|deleteStatement ;
insertStatement : INSERT insertGraphPattern ;
setStatement : SET setItemList ;
setItemList : setItem ( COMMA setItem )* ;
setItem : setPropertyItem|setAllPropertiesItem|setLabelItem ;
setPropertyItem : bindingVariableReference PERIOD propertyName EQUALS_OPERATOR valueExpression ;
setAllPropertiesItem : bindingVariableReference EQUALS_OPERATOR LEFT_BRACE propertyKeyValuePairList? RIGHT_BRACE ;
setLabelItem : bindingVariableReference isOrColon labelSetSpecification ;

labelSetSpecification : labelName ( AMPERSAND labelName )* ;

removeStatement : REMOVE removeItemList ;
removeItemList : removeItem ( COMMA removeItem )* ;
removeItem : removePropertyItem|removeLabelItem ;
removePropertyItem : bindingVariableReference PERIOD propertyName ;
removeLabelItem : bindingVariableReference isOrColon labelSetSpecification ;
deleteStatement : ( DETACH|NODETACH )? DELETE deleteItemList ;
deleteItemList : deleteItem ( COMMA deleteItem )* ;
deleteItem : valueExpression ;
callDataModifyingProcedureStatement : callProcedureStatement ;

//==================================================================
// 14 Query statements
//******************************************************************
// 14.1 composite query statement
compositeQueryStatement : compositeQueryExpression ;

//******************************************************************
// 14.2 composite query expression
//TODO[GLC]： 14.2和14.1可以简化合起来
compositeQueryExpression : compositeQueryExpression queryConjunction compositeQueryPrimary|compositeQueryPrimary ;
queryConjunction : setOperator|OTHERWISE ;
setOperator : UNION setQuantifier?|EXCEPT setQuantifier?|INTERSECT setQuantifier? ;
compositeQueryPrimary : linearQueryStatement ;

//******************************************************************
// 14.3 linear query statement
linearQueryStatement : focusedLinearQueryStatement|ambientLinearQueryStatement ;
focusedLinearQueryStatement :
    focusedLinearQueryStatementPart* focusedLinearQueryAndPrimitiveResultStatementPart
    | focusedPrimitiveResultStatement
    | focusedNestedQuerySpecification
    | selectStatement ;
focusedLinearQueryStatementPart : useGraphClause simpleLinearQueryStatement ;
focusedLinearQueryAndPrimitiveResultStatementPart : useGraphClause simpleLinearQueryStatement primitiveResultStatement ;
focusedPrimitiveResultStatement : useGraphClause primitiveResultStatement ;
focusedNestedQuerySpecification : useGraphClause nestedQuerySpecification ;
ambientLinearQueryStatement : simpleLinearQueryStatement? primitiveResultStatement|nestedQuerySpecification ;
simpleLinearQueryStatement : simpleQueryStatement+ ;
simpleQueryStatement : primitiveQueryStatement|callQueryStatement ;
primitiveQueryStatement : matchStatement|letStatement|forStatement|filterStatement|orderByAndPageStatement ;

//******************************************************************
// 14.3 Match Statement
matchStatement : simpleMatchStatement|optionalMatchStatement ;
simpleMatchStatement : MATCH graphPatternBindingTable ;
optionalMatchStatement : OPTIONAL optionalOperand ;
optionalOperand : simpleMatchStatement|LEFT_BRACE matchStatementBlock RIGHT_BRACE|LEFT_PAREN matchStatementBlock RIGHT_PAREN ;
matchStatementBlock : matchStatement+ ;

callQueryStatement : callProcedureStatement ;

filterStatement : FILTER ( whereClause|searchCondition ) ;

//******************************************************************
// 14.7 LET Statement
letStatement : LET letVariableDefinitionList ;
letVariableDefinitionList : letVariableDefinition ( COMMA letVariableDefinition )* ;
letVariableDefinition : valueVariableDefinition|valueVariable EQUALS_OPERATOR valueExpression ;

//******************************************************************
// 14.8 FOR Statement
forStatement : FOR forItem forOrdinalityOrOffset? ;
forItem : forItemAlias listValueExpression ;
forItemAlias : identifier IN ;
forOrdinalityOrOffset : WITH ( ORDINALITY|OFFSET ) identifier ;

orderByAndPageStatement : orderByClause offsetClause? limitClause? | offsetClause limitClause?|limitClause ;

primitiveResultStatement : returnStatement orderByAndPageStatement? | FINISH ;
returnStatement : RETURN returnStatementBody ;
returnStatementBody : setQuantifier? ( ASTERISK|returnItemList ) groupByClause?|NO BINDINGS ;
returnItemList : returnItem ( COMMA returnItem )* ;
returnItem : aggregatingValueExpression returnItemAlias? ;
returnItemAlias : AS identifier ;

selectStatement : SELECT setQuantifier? selectItemList ( selectStatementBody whereClause? groupByClause? havingClause? orderByClause? offsetClause? limitClause? )? ;
selectItemList : selectItem ( COMMA selectItem )* ;
selectItem : aggregatingValueExpression selectItemAlias? ;
selectItemAlias : AS identifier ;
havingClause : HAVING searchCondition ;
selectStatementBody : FROM selectGraphMatchList|selectQuerySpecification ;
selectGraphMatchList : selectGraphMatch ( COMMA selectGraphMatch )* ;
selectGraphMatch : graphExpression matchStatement ;
selectQuerySpecification : FROM nestedQuerySpecification|FROM graphExpression nestedQuerySpecification ;


callProcedureStatement : OPTIONAL? CALL procedureCall ;
procedureCall : inlineProcedureCall|namedProcedureCall ;
inlineProcedureCall : variableScopeClause? nestedProcedureSpecification ;
variableScopeClause : LEFT_PAREN bindingVariableReferenceList? RIGHT_PAREN ;
bindingVariableReferenceList : bindingVariableReference ( COMMA bindingVariableReference )* ;


namedProcedureCall : procedureReference LEFT_PAREN procedureArgumentList? RIGHT_PAREN yieldClause? ;
procedureArgumentList : procedureArgument ( COMMA procedureArgument )* ;
procedureArgument : valueExpression ;
useGraphClause : USE graphExpression ;
atSchemaClause : AT schemaReference ;
bindingVariableReference : bindingVariable ;
elementVariableReference : bindingVariableReference ;
pathVariableReference : bindingVariableReference ;
parameter : parameterName ;
graphPatternBindingTable : graphPattern graphPatternYieldClause? ;
graphPatternYieldClause : YIELD graphPatternYieldItemList ;
graphPatternYieldItemList : graphPatternYieldItem ( COMMA graphPatternYieldItem )* | NO BINDINGS ;
graphPatternYieldItem : elementVariableReference | pathVariableReference ;
graphPattern :  matchMode? pathPatternList keepClause? graphPatternWhereClause? ;
matchMode : repeatableElementsMatchMode|differentEdgesMatchMode ;
repeatableElementsMatchMode : REPEATABLE elementBindingsOrElements ;
differentEdgesMatchMode : DIFFERENT edgeBindingsOrEdges ;
elementBindingsOrElements : ELEMENT BINDINGS?|ELEMENTS ;
edgeBindingsOrEdges : EDGE_SYNONYM BINDINGS?|EDGES_SYNONYM ;
pathPatternList : pathPattern ( COMMA pathPattern )* ;
pathPattern : pathVariableDeclaration? pathPatternPrefix? pathPatternExpression ;
pathVariableDeclaration : pathVariable EQUALS_OPERATOR ;
keepClause : KEEP pathPatternPrefix ;
graphPatternWhereClause : WHERE searchCondition ;
pathPatternPrefix : pathModePrefix|pathSearchPrefix ;
pathModePrefix : pathMode pathOrPaths? ;
pathMode : WALK|TRAIL|SIMPLE|ACYCLIC ;
pathSearchPrefix : allPathSearch|anyPathSearch|shortestPathSearch ;
allPathSearch : ALL pathMode? pathOrPaths? ;
pathOrPaths : PATH|PATHS ;
anyPathSearch : ANY numberOfPaths? pathMode? pathOrPaths? ;
numberOfPaths : unsignedIntegerSpecification ;
shortestPathSearch : allShortestPathSearch|anyShortestPathSearch|countedShortestPathSearch|countedShortestGroupSearch ;
allShortestPathSearch : ALL SHORTEST pathMode? pathOrPaths? ;
anyShortestPathSearch : ANY SHORTEST pathMode? pathOrPaths? ;
countedShortestPathSearch : SHORTEST numberOfPaths pathMode? pathOrPaths? ;
countedShortestGroupSearch : SHORTEST numberOfGroups pathMode? pathOrPaths? ( GROUP|GROUPS ) ;
numberOfGroups : unsignedIntegerSpecification ;
pathPatternExpression : pathTerm|pathMultisetAlternation|pathPatternUnion ;
pathMultisetAlternation : pathTerm MULTISET_ALTERNATION_OPERATOR pathTerm ( MULTISET_ALTERNATION_OPERATOR pathTerm )* ;
pathPatternUnion : pathTerm VERTICAL_BAR pathTerm ( VERTICAL_BAR pathTerm )* ;
pathTerm : pathFactor+ ;
//pathTerm : pathFactor|pathConcatenation ;
//pathConcatenation : pathTerm pathFactor ;
pathFactor : pathPrimary|quantifiedPathPrimary|questionedPathPrimary ;
quantifiedPathPrimary : pathPrimary graphPatternQuantifier ;
questionedPathPrimary : pathPrimary QUESTION_MARK ;
pathPrimary : elementPattern|parenthesizedPathPatternExpression|simplifiedPathPatternExpression ;
elementPattern : nodePattern|edgePattern ;
nodePattern : LEFT_PAREN elementPatternFiller RIGHT_PAREN ;
elementPatternFiller : elementVariableDeclaration? isLabelExpression? elementPatternPredicate? ;
elementVariableDeclaration : TEMP? elementVariable ;
isLabelExpression : isOrColon labelExpression ;
isOrColon : IS|COLON ;

elementPatternPredicate : elementPatternWhereClause|elementPropertySpecification ;
elementPatternWhereClause : WHERE searchCondition ;
elementPropertySpecification : LEFT_BRACE propertyKeyValuePairList RIGHT_BRACE ;
propertyKeyValuePairList : propertyKeyValuePair ( COMMA propertyKeyValuePair )* ;
propertyKeyValuePair : propertyName COLON valueExpression ;
edgePattern : fullEdgePattern|abbreviatedEdgePattern ;
fullEdgePattern : fullEdgePointingLeft
                  | fullEdgeUndirected
                  | fullEdgePointingRight
                  | fullEdgeLeftOrUndirected
                  | fullEdgeUndirectedOrRight
                  | fullEdgeLeftOrRight
                  | fullEdgeAnyDirection ;
fullEdgePointingLeft : LEFT_ARROW_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS ; // <-[]-
fullEdgeUndirected : TILDE_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE ; // ~[]~
fullEdgePointingRight : MINUS_LEFT_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW ; // -[]->
fullEdgeLeftOrUndirected : LEFT_ARROW_TILDE_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE ; // <~[]~
fullEdgeUndirectedOrRight : TILDE_LEFT_BRACKET elementPatternFiller BRACKET_TILDE_RIGHT_ARROW ; // ~[]~>
fullEdgeLeftOrRight : LEFT_ARROW_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW ; // <-[]->
fullEdgeAnyDirection : MINUS_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS ; // -[]-
abbreviatedEdgePattern :
                        LEFT_ARROW               #AbbreviatedEdgePointingLeft
                        | TILDE                  #AbbreviatedEdgeUndirected
                        | RIGHT_ARROW            #AbbreviatedEdgePointingRight
                        | LEFT_ARROW_TILDE       #AbbreviatedEdgeLeftOrUndirected
                        | TILDE_RIGHT_ARROW      #AbbreviatedEdgeUndirectedOrRight
                        | LEFT_MINUS_RIGHT       #AbbreviatedEdgeLeftOrRight
                        | MINUS_SIGN             #AbbreviatedEdgeAnyDirection
                        ;
parenthesizedPathPatternExpression : LEFT_PAREN subpathVariableDeclaration? pathModePrefix? pathPatternExpression parenthesizedPathPatternWhereClause? RIGHT_PAREN ;
subpathVariableDeclaration : subpathVariable EQUALS_OPERATOR ; //TODO
parenthesizedPathPatternWhereClause : WHERE searchCondition ;
insertGraphPattern : insertPathPatternList ;
insertPathPatternList : insertPathPattern ( COMMA insertPathPattern+ )? ;
insertPathPattern : insertNodePattern ( insertEdgePattern insertNodePattern )* ;
insertNodePattern : LEFT_PAREN insertElementPatternFiller? RIGHT_PAREN ;
insertEdgePattern : insertEdgePointingLeft|insertEdgePointingRight|insertEdgeUndirected ;
insertEdgePointingLeft : LEFT_ARROW_BRACKET insertElementPatternFiller? RIGHT_BRACKET_MINUS ;
insertEdgePointingRight : MINUS_LEFT_BRACKET insertElementPatternFiller? BRACKET_RIGHT_ARROW ;
insertEdgeUndirected : TILDE_LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET_TILDE ;
//TODO: insert时候label前面不需要加：??? 奇怪 draft中没有，这里加了
insertElementPatternFiller : elementVariableDeclaration labelAndPropertySetSpecification?|elementVariableDeclaration? labelAndPropertySetSpecification ;
labelAndPropertySetSpecification :  isOrColon labelSetSpecification elementPropertySpecification?| (isOrColon labelSetSpecification)? elementPropertySpecification ;

// already find better style
/*
labelExpression : labelTerm|labelDisjunction ;
labelDisjunction : labelExpression VERTICAL_BAR labelTerm ;
labelTerm : labelFactor|labelConjunction ;
labelConjunction : labelTerm AMPERSAND labelFactor ;
labelFactor : labelPrimary|labelNegation ;
labelNegation : EXCLAMATION_MARK labelPrimary ;
labelPrimary : labelName|wildcardLabel|parenthesizedLabelExpression ;
wildcardLabel : PERCENT ;
parenthesizedLabelExpression : LEFT_PAREN labelExpression RIGHT_PAREN ;
*/

labelExpression : labelTerm (VERTICAL_BAR labelTerm)* ;
labelTerm : labelFactor (AMPERSAND labelFactor)* ;
labelFactor : (EXCLAMATION_MARK)? labelPrimary ;
labelPrimary : labelName|wildcardLabel|parenthesizedLabelExpression ;
wildcardLabel : PERCENT ;
parenthesizedLabelExpression : LEFT_PAREN labelExpression RIGHT_PAREN ;

graphPatternQuantifier : ASTERISK|PLUS_SIGN|fixedQuantifier|generalQuantifier ;
fixedQuantifier : LEFT_BRACE UNSIGNED_DECIMAL_INTEGER RIGHT_BRACE ;
generalQuantifier : LEFT_BRACE lowerBound? COMMA upperBound? RIGHT_BRACE ;
lowerBound : UNSIGNED_DECIMAL_INTEGER ;
upperBound : UNSIGNED_DECIMAL_INTEGER ;
simplifiedPathPatternExpression : simplifiedDefaultingLeft|simplifiedDefaultingUndirected|simplifiedDefaultingRight|simplifiedDefaultingLeftOrUndirected|simplifiedDefaultingUndirectedOrRight|simplifiedDefaultingLeftOrRight|simplifiedDefaultingAnyDirection ;
simplifiedDefaultingLeft : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS ;
simplifiedDefaultingUndirected : TILDE_SLASH simplifiedContents SLASH_TILDE ;
simplifiedDefaultingRight : MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT ;
simplifiedDefaultingLeftOrUndirected : LEFT_TILDE_SLASH simplifiedContents SLASH_TILDE ;
simplifiedDefaultingUndirectedOrRight : TILDE_SLASH simplifiedContents SLASH_TILDE_RIGHT ;
simplifiedDefaultingLeftOrRight : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT ;
simplifiedDefaultingAnyDirection : MINUS_SLASH simplifiedContents SLASH_MINUS ;
simplifiedContents : simplifiedTerm|simplifiedPathUnion|simplifiedMultisetAlternation ;
simplifiedPathUnion : simplifiedTerm VERTICAL_BAR simplifiedTerm ( VERTICAL_BAR simplifiedTerm )* ;
simplifiedMultisetAlternation : simplifiedTerm MULTISET_ALTERNATION_OPERATOR simplifiedTerm ( MULTISET_ALTERNATION_OPERATOR simplifiedTerm )* ;
simplifiedTerm : (simplifiedFactorLow)+ ;
simplifiedFactorLow : (simplifiedFactorHigh AMPERSAND)* simplifiedFactorHigh ;
// find better style
/*simplifiedTerm : simplifiedFactorLow|simplifiedConcatenation ;
simplifiedConcatenation : simplifiedTerm simplifiedFactorLow ;
simplifiedFactorLow : simplifiedFactorHigh|simplifiedConjunction ;
simplifiedConjunction : simplifiedFactorLow AMPERSAND simplifiedFactorHigh ;*/
simplifiedFactorHigh : simplifiedTertiary|simplifiedQuantified|simplifiedQuestioned ;
simplifiedQuantified : simplifiedTertiary graphPatternQuantifier ;
simplifiedQuestioned : simplifiedTertiary QUESTION_MARK ;
simplifiedTertiary : simplifiedDirectionOverride|simplifiedSecondary ;
simplifiedDirectionOverride : simplifiedOverrideLeft|simplifiedOverrideUndirected|simplifiedOverrideRight|simplifiedOverrideLeftOrUndirected|simplifiedOverrideUndirectedOrRight|simplifiedOverrideLeftOrRight|simplifiedOverrideAnyDirection ;
simplifiedOverrideLeft : LEFT_ANGLE_BRACKET simplifiedSecondary ;
simplifiedOverrideUndirected : TILDE simplifiedSecondary ;
simplifiedOverrideRight : simplifiedSecondary RIGHT_ANGLE_BRACKET ;
simplifiedOverrideLeftOrUndirected : LEFT_ARROW_TILDE simplifiedSecondary ;
simplifiedOverrideUndirectedOrRight : TILDE simplifiedSecondary RIGHT_ANGLE_BRACKET ;
simplifiedOverrideLeftOrRight : LEFT_ANGLE_BRACKET simplifiedSecondary RIGHT_ANGLE_BRACKET ;
simplifiedOverrideAnyDirection : MINUS_SIGN simplifiedSecondary ;
simplifiedSecondary : simplifiedPrimary|simplifiedNegation ;
simplifiedNegation : EXCLAMATION_MARK simplifiedPrimary ;
simplifiedPrimary : labelName|LEFT_PAREN simplifiedContents RIGHT_PAREN ;

whereClause : WHERE searchCondition ;
yieldClause : YIELD yieldItemList ;
yieldItemList : yieldItem ( COMMA yieldItem )* ;
yieldItem : yieldItemName yieldItemAlias? ;
yieldItemName : fieldName ;
yieldItemAlias : AS bindingVariable ;
groupByClause : GROUP BY groupingElementList ;
groupingElementList : groupingElement ( COMMA groupingElement )?|emptyGroupingSet ;
groupingElement : bindingVariableReference ;
emptyGroupingSet : LEFT_PAREN RIGHT_PAREN ;
orderByClause : ORDER BY sortSpecificationList ;
aggregateFunction : COUNT LEFT_PAREN ASTERISK RIGHT_PAREN|generalSetFunction|binarySetFunction ;
generalSetFunction : generalSetFunctionType LEFT_PAREN setQuantifier? valueExpression RIGHT_PAREN ;
binarySetFunction : binarySetFunctionType LEFT_PAREN dependentValueExpression COMMA independentValueExpression RIGHT_PAREN ;
generalSetFunctionType : AVG|COUNT|MAX|MIN|SUM|COLLECT|STDDEV_SAMP|STDDEV_POP ;
setQuantifier : DISTINCT|ALL ;
binarySetFunctionType : PERCENTILE_CONT|PERCENTILE_DISC ;
dependentValueExpression : setQuantifier? numericValueExpression ;
independentValueExpression : numericValueExpression ;
sortSpecificationList : sortSpecification ( COMMA sortSpecification )* ;
sortSpecification : sortKey orderingSpecification? nullOrdering? ;
sortKey : aggregatingValueExpression ;
orderingSpecification : ASC|ASCENDING|DESC|DESCENDING ;
nullOrdering : NULLS FIRST|NULLS LAST ;
limitClause : LIMIT unsignedIntegerSpecification ;
offsetClause : offsetSynonym unsignedIntegerSpecification ;
offsetSynonym : OFFSET | SKIP_ ;
graphTypeSpecification : PROPERTY? GRAPH TYPE nestedGraphTypeSpecification ;
nestedGraphTypeSpecification : LEFT_BRACE graphTypeSpecificationBody RIGHT_BRACE ;
graphTypeSpecificationBody : elementTypeDefinitionList ;
elementTypeDefinitionList : elementTypeDefinition ( COMMA elementTypeDefinition )* ;
elementTypeDefinition : nodeTypeDefinition|edgeTypeDefinition ;
nodeTypeDefinition : nodeTypePattern|NODE_SYNONYM nodeTypePhrase ;
nodeTypePattern : LEFT_PAREN nodeTypeName? nodeTypeFiller? RIGHT_PAREN ;
nodeTypePhrase : TYPE? nodeTypeName nodeTypeFiller?|nodeTypeFiller ;
nodeTypeName : elementTypeName ;
nodeTypeFiller : nodeTypeLabelSetDefinition|nodeTypePropertyTypeSetDefinition|nodeTypeLabelSetDefinition nodeTypePropertyTypeSetDefinition ;
nodeTypeLabelSetDefinition : labelSetDefinition ;
nodeTypePropertyTypeSetDefinition : propertyTypeSetDefinition ;
edgeTypeDefinition : edgeTypePattern|edgeKind? EDGE_SYNONYM edgeTypePhrase ;
edgeTypePattern : fullEdgeTypePattern|abbreviatedEdgeTypePattern ;
edgeTypePhrase : TYPE? edgeTypeName ( edgeTypeFiller endpointDefinition )?|edgeTypeFiller endpointDefinition ;
edgeTypeName : elementTypeName ;
edgeTypeFiller : edgeTypeLabelSetDefinition|edgeTypePropertyTypeSetDefinition|edgeTypeLabelSetDefinition edgeTypePropertyTypeSetDefinition ;
edgeTypeLabelSetDefinition : labelSetDefinition ;
edgeTypePropertyTypeSetDefinition : propertyTypeSetDefinition ;
fullEdgeTypePattern : fullEdgeTypePatternPointingRight|fullEdgeTypePatternPointingLeft|fullEdgeTypePatternUndirected ;
fullEdgeTypePatternPointingRight : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference ;
fullEdgeTypePatternPointingLeft : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference ;
fullEdgeTypePatternUndirected : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference ;
arcTypePointingRight : MINUS_LEFT_BRACKET arcTypeFiller BRACKET_RIGHT_ARROW ;
arcTypePointingLeft : LEFT_ARROW_BRACKET arcTypeFiller RIGHT_BRACKET_MINUS ;
arcTypeUndirected : TILDE_LEFT_BRACKET arcTypeFiller RIGHT_BRACKET_TILDE ;
arcTypeFiller : edgeTypeName? edgeTypeFiller? ;
abbreviatedEdgeTypePattern : abbreviatedEdgeTypePatternPointingRight|abbreviatedEdgeTypePatternPointingLeft|abbreviatedEdgeTypePatternUndirected ;
abbreviatedEdgeTypePatternPointingRight : sourceNodeTypeReference RIGHT_ARROW destinationNodeTypeReference ;
abbreviatedEdgeTypePatternPointingLeft : destinationNodeTypeReference LEFT_ARROW sourceNodeTypeReference ;
abbreviatedEdgeTypePatternUndirected : sourceNodeTypeReference TILDE destinationNodeTypeReference ;
nodeTypeReference : sourceNodeTypeReference|destinationNodeTypeReference ;
sourceNodeTypeReference : LEFT_PAREN sourceNodeTypeName RIGHT_PAREN|LEFT_PAREN nodeTypeFiller? RIGHT_PAREN ;
destinationNodeTypeReference : LEFT_PAREN destinationNodeTypeName RIGHT_PAREN|LEFT_PAREN nodeTypeFiller? RIGHT_PAREN ;
edgeKind : DIRECTED|UNDIRECTED ;
endpointDefinition : CONNECTING endpointPairDefinition ;
endpointPairDefinition : endpointPairDefinitionPointingRight|endpointPairDefinitionPointingLeft|endpointPairDefinitionUndirected|abbreviatedEdgeTypePattern ;
endpointPairDefinitionPointingRight : LEFT_PAREN sourceNodeTypeName connectorPointingRight destinationNodeTypeName RIGHT_PAREN ;
endpointPairDefinitionPointingLeft : LEFT_PAREN destinationNodeTypeName LEFT_ARROW sourceNodeTypeName RIGHT_PAREN ;
endpointPairDefinitionUndirected : LEFT_PAREN sourceNodeTypeName connectorUndirected destinationNodeTypeName RIGHT_PAREN ;
connectorPointingRight : TO|RIGHT_ARROW ;
connectorUndirected : TO|TILDE ;
sourceNodeTypeName : elementTypeName ;
destinationNodeTypeName : elementTypeName ;
labelSetDefinition : LABEL labelName|LABELS labelNameSet|isOrColon labelNameSet ;
labelNameSet : labelName ( COMMA labelName )?|LEFT_PAREN labelName ( COMMA labelName )? RIGHT_PAREN ;
propertyTypeSetDefinition : LEFT_BRACE propertyTypeDefinitionList? RIGHT_BRACE ;
propertyTypeDefinitionList : propertyTypeDefinition ( COMMA propertyTypeDefinition )* ;
propertyTypeDefinition : propertyName typed? propertyValueType ;
propertyValueType : valueType ;
bindingTableType : BINDING? TABLE fieldTypesSpecification ;
valueType :
    predefinedType                                                                                                                     #predefType
    | pathValueType                                                                                                                    #pathType
    | listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET ( LEFT_BRACKET maxLength RIGHT_BRACKET )? notNull?            #listType1
    | valueType listValueTypeName ( LEFT_BRACKET maxLength RIGHT_BRACKET )? notNull?                                                   #listType2
    | OPEN? RECORD notNull?                                                                                                            #recordType1
    | RECORD? fieldTypesSpecification notNull?                                                                                         #recordType2
    | ANY  (VALUE)? (notNull)?                                                                                                         #openDynamicUnionType
    | ANY? PROPERTY VALUE  (notNull)?                                                                                                  #dynamicPropertyValueType
    | ANY LEFT_ANGLE_BRACKET valueType ( VERTICAL_BAR valueType )* RIGHT_ANGLE_BRACKET                                                 #closedDynamicUnionType1
    | valueType ( VERTICAL_BAR valueType )+                                                                                            #closedDynamicUnionType2
    ;

typed : DOUBLE_COLON|TYPED ;
predefinedType : booleanType|characterStringType|byteStringType|numericType|temporalType|referenceValueType ;
booleanType : ( BOOL|BOOLEAN ) notNull? ;
characterStringType : ( STRING|VARCHAR ) ( LEFT_PAREN maxLength RIGHT_PAREN )? notNull? ;
byteStringType :
    BYTES ( LEFT_PAREN ( minLength COMMA )? maxLength RIGHT_PAREN )? notNull?
    |BINARY ( LEFT_PAREN fixedLength RIGHT_PAREN )? notNull?
    |VARBINARY ( LEFT_PAREN maxLength RIGHT_PAREN )? notNull? ;
minLength : UNSIGNED_DECIMAL_INTEGER ;
maxLength : UNSIGNED_DECIMAL_INTEGER ;
fixedLength : UNSIGNED_DECIMAL_INTEGER ;
numericType : exactNumericType|approximateNumericType ;
exactNumericType : binaryExactNumericType|decimalExactNumericType ;
binaryExactNumericType : signedBinaryExactNumericType|unsignedBinaryExactNumericType ;
signedBinaryExactNumericType : INT8 notNull?|INT16 notNull?|INT32 notNull?|INT64 notNull?|INT128 notNull?|INT256 notNull?|SMALLINT notNull?|INT ( LEFT_PAREN precision RIGHT_PAREN )? notNull?|BIGINT|SIGNED? verboseBinaryExactNumericType notNull? ;
unsignedBinaryExactNumericType : UINT8 notNull?|UINT16 notNull?|UINT32 notNull?|UINT64 notNull?|UINT128 notNull?|UINT256 notNull?|USMALLINT notNull?|UINT ( LEFT_PAREN precision RIGHT_PAREN )? notNull?|UBIGINT notNull?|UNSIGNED verboseBinaryExactNumericType notNull? ;
verboseBinaryExactNumericType : INTEGER8 notNull?|INTEGER16 notNull?|INTEGER32 notNull?|INTEGER64 notNull?|INTEGER128 notNull?|INTEGER256 notNull?|SMALL INTEGER notNull?|INTEGER ( LEFT_PAREN precision RIGHT_PAREN )? notNull?|BIG INTEGER notNull? ;
decimalExactNumericType : ( DECIMAL|DEC ) ( LEFT_PAREN precision ( COMMA scale )? RIGHT_PAREN notNull? )? ;
precision : UNSIGNED_DECIMAL_INTEGER ;
scale: UNSIGNED_DECIMAL_INTEGER;
approximateNumericType : FLOAT16 notNull?|FLOAT32 notNull?|FLOAT64 notNull?|FLOAT128 notNull?|FLOAT256 notNull?|FLOAT ( LEFT_PAREN precision ( COMMA scale )? RIGHT_PAREN )? notNull?|REAL notNull?|DOUBLE PRECISION? notNull? ;
temporalType : temporalInstantType|temporalDurationType ;
temporalInstantType : datetimeType|localdatetimeType|dateType|timeType|localtimeType ;
temporalDurationType : durationType ;
datetimeType : ZONED DATETIME notNull?|TIMESTAMP WITH TIMEZONE notNull? ;
localdatetimeType : LOCAL DATETIME notNull?|TIMESTAMP ( WITHOUT TIMEZONE )? notNull? ;
dateType : DATE notNull? ;
timeType : ZONED TIME notNull?|TIME WITH TIMEZONE notNull? ;
localtimeType : LOCAL TIME notNull?|TIME WITHOUT TIMEZONE notNull? ;
durationType : DURATION notNull? ;
referenceValueType : graphReferenceValueType|bindingTableReferenceValueType|nodeReferenceValueType|edgeReferenceValueType ;
graphReferenceValueType : openGraphReferenceValueType|closedGraphReferenceValueType ;
closedGraphReferenceValueType : graphTypeSpecification notNull? ;
openGraphReferenceValueType : OPEN PROPERTY? GRAPH notNull? ;
bindingTableReferenceValueType : bindingTableType notNull? ;
nodeReferenceValueType : openNodeReferenceValueType|closedNodeReferenceValueType ;
closedNodeReferenceValueType : nodeTypeDefinition notNull? ;
openNodeReferenceValueType : OPEN? NODE_SYNONYM notNull? ;
edgeReferenceValueType : openEdgeReferenceValueType|closedEdgeReferenceValueType ;
closedEdgeReferenceValueType : edgeTypeDefinition notNull? ;
openEdgeReferenceValueType : OPEN? EDGE_SYNONYM notNull? ;

// NOTICE: already contained in valueType
//constructedType : listValueType|recordType ;
// fix left recursive: valueType -> predefinedType
//listValueType : ( listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET|predefinedType listValueTypeName ) ( LEFT_BRACKET maxLength RIGHT_BRACKET )? notNull? ;
listValueTypeName : GROUP? listValueTypeNameSynonym ;
listValueTypeNameSynonym : LIST|ARRAY ;
// NOTICE: already contained in valueType
//recordType : OPEN? RECORD notNull?|RECORD? fieldTypesSpecification notNull? ;
fieldTypesSpecification : LEFT_BRACE fieldTypeList? RIGHT_BRACE ;
fieldTypeList : fieldType ( COMMA fieldType )* ;
// NOTICE: already contained in valueType
//dynamicUnionType : openDynamicUnionType|dynamicPropertyValueType|closedDynamicUnionType ;
//openDynamicUnionType : ANY ;
//dynamicPropertyValueType : ANY? PROPERTY VALUE ;
//closedDynamicUnionType : ANY LEFT_ANGLE_BRACKET componentTypeList RIGHT_ANGLE_BRACKET|componentTypeList ;
//componentTypeList : componentType ( VERTICAL_BAR componentType )* ;
//componentType : valueType ;


pathValueType : PATH notNull?;
notNull : NOT NULL ;
fieldType : fieldName typed? valueType ;

//==================================================================
// 18 Object references

//******************************************************************
// 18.1 Schema references
schemaReference : absoluteCatalogSchemaReference|relativeCatalogSchemaReference|referenceParameter ;
absoluteCatalogSchemaReference : SOLIDUS|absoluteDirectoryPath schemaName ;
catalogSchemaParentAndName : absoluteDirectoryPath schemaName ;
relativeCatalogSchemaReference : predefinedSchemaReference|relativeDirectoryPath schemaName ;
predefinedSchemaReference : HOME_SCHEMA|CURRENT_SCHEMA|PERIOD ;
absoluteDirectoryPath : SOLIDUS simpleDirectoryPath? ;
// TODO[glc]: ( SOLIDUS DOUBLE_PERIOD )* {}...到底几次
relativeDirectoryPath : DOUBLE_PERIOD ( ( SOLIDUS DOUBLE_PERIOD )* SOLIDUS simpleDirectoryPath? )? ;
simpleDirectoryPath : ( directoryName SOLIDUS )+ ;

//******************************************************************
// 18.2 graph references
graphReference : catalogObjectParentReference graphName|delimitedGraphName|homeGraph|referenceParameter ;
catalogGraphParentAndName : catalogObjectParentReference? graphName ;
homeGraph : HOME_PROPERTY_GRAPH|HOME_GRAPH ;

//******************************************************************
// 18.3 Graph type references
graphTypeReference : catalogGraphTypeParentAndName|referenceParameter ;
catalogGraphTypeParentAndName : catalogObjectParentReference? graphTypeName ;

//******************************************************************
// 18.4 Binding table references

bindingTableReference : catalogObjectParentReference bindingTableName|delimitedBindingTableName|referenceParameter ;
catalogBindingTableParentAndName : catalogObjectParentReference? bindingTableName ;

//******************************************************************
// 18.5 Procedure references
procedureReference : catalogProcedureParentAndName|referenceParameter ;
catalogProcedureParentAndName : catalogObjectParentReference? procedureName ;

//******************************************************************
// 18.6 Catalog object parent references
catalogObjectParentReference : schemaReference SOLIDUS? ( objectName PERIOD )* | ( objectName PERIOD )+ ;

//******************************************************************
// 18.7 references parameter
referenceParameter : parameter ;

//******************************************************************
// 18.8 external object reference
// TODO: 需要参考URI的标准，优先级低
externalObjectReference : I_DONT_KNOW_3 ;

// boolean value expression
searchCondition : booleanValueExpression ;
predicate :
    comparisonPredicate
    |existsPredicate
    |nullPredicate
    |normalizedPredicate
    |directedPredicate
    |labeledPredicate
    |sourceDestinationPredicate
    |allDifferentPredicate
    |samePredicate
    |propertyExistsPredicate;

comparisonPredicate : comparisonPredicand comparisonPredicatePart_2 ;
comparisonPredicatePart_2 : compOp comparisonPredicand ;
compOp : EQUALS_OPERATOR|NOT_EQUALS_OPERATOR|lessThanOperator|greaterThanOperator|LESS_THAN_OR_EQUALS_OPERATOR|GREATER_THAN_OR_EQUALS_OPERATOR ;
lessThanOperator: LEFT_ANGLE_BRACKET ;
greaterThanOperator: RIGHT_ANGLE_BRACKET ;
comparisonPredicand : commonValueExpression|booleanPredicand ;
existsPredicate : EXISTS (
    LEFT_BRACE graphPattern RIGHT_BRACE
    | LEFT_PAREN graphPattern RIGHT_PAREN
    | LEFT_BRACE matchStatementBlock RIGHT_BRACE
    | LEFT_PAREN matchStatementBlock RIGHT_PAREN
    | nestedQuerySpecification ) ;
nullPredicate : valueExpressionPrimary nullPredicatePart_2 ;
nullPredicatePart_2 : IS NOT? NULL ;
valueTypePredicate : valueExpressionPrimary valueTypePredicatePart_2 ;
valueTypePredicatePart_2 : IS NOT? typed valueType ;
normalizedPredicate : stringValueExpression normalizedPredicatePart_2 ;
normalizedPredicatePart_2 : IS NOT? normalForm? NORMALIZED ;
directedPredicate : elementVariableReference directedPredicatePart_2 ;
directedPredicatePart_2 : IS NOT? DIRECTED ;
labeledPredicate : elementVariableReference labeledPredicatePart_2 ;
labeledPredicatePart_2 : isLabeledOrColon labelExpression ;
isLabeledOrColon : IS NOT? LABELED|COLON ;
sourceDestinationPredicate : nodeReference sourcePredicatePart_2|nodeReference destinationPredicatePart_2 ;
nodeReference : elementVariableReference ;
sourcePredicatePart_2 : IS NOT? SOURCE OF edgeReference ;
destinationPredicatePart_2 : IS NOT? DESTINATION OF edgeReference ;
edgeReference : elementVariableReference ;
allDifferentPredicate : ALL_DIFFERENT LEFT_PAREN elementVariableReference COMMA elementVariableReference ( COMMA elementVariableReference )* RIGHT_PAREN ;
samePredicate : SAME LEFT_PAREN elementVariableReference COMMA elementVariableReference ( COMMA elementVariableReference )* RIGHT_PAREN ;
propertyExistsPredicate : PROPERTY_EXISTS LEFT_PAREN elementVariableReference COMMA propertyName RIGHT_PAREN ;
valueSpecification : literal|parameterValueSpecification ;
unsignedValueSpecification : unsignedLiteral|parameterValueSpecification ;
unsignedIntegerSpecification : UNSIGNED_DECIMAL_INTEGER|parameter ;
parameterValueSpecification : parameter|predefinedParameter ;
predefinedParameter : CURRENT_USER ;

valueExpression : commonValueExpression|booleanValueExpression ;
commonValueExpression :
    numericValueExpression
    |stringValueExpression
    |datetimeValueExpression
    |durationValueExpression
    |listValueExpression
    |recordValueExpression
    |pathValueExpression
    |referenceValueExpression ;

referenceValueExpression : graphReferenceValueExpression|bindingTableReferenceValueExpression|nodeReferenceValueExpression|edgeReferenceValueExpression ;
graphReferenceValueExpression : PROPERTY? GRAPH graphExpression|valueExpressionPrimary ;
bindingTableReferenceValueExpression : BINDING? TABLE bindingTableExpression|valueExpressionPrimary ;
nodeReferenceValueExpression : valueExpressionPrimary ;
edgeReferenceValueExpression : valueExpressionPrimary ;
recordValueExpression : valueExpressionPrimary ;
aggregatingValueExpression : valueExpression ;
booleanValueExpression : booleanTerm|booleanValueExpression OR booleanTerm|booleanValueExpression XOR booleanTerm ;
booleanTerm : booleanFactor|booleanTerm AND booleanFactor ;
booleanFactor : NOT? booleanTest ;
booleanTest : booleanPrimary ( IS NOT? truthValue )? ;
truthValue : TRUE|FALSE|UNKNOWN ;
booleanPrimary : predicate|booleanPredicand ;
booleanPredicand : parenthesizedBooleanValueExpression|nonParenthesizedValueExpressionPrimary ;
parenthesizedBooleanValueExpression : LEFT_PAREN booleanValueExpression RIGHT_PAREN ;
numericValueExpression : term|numericValueExpression PLUS_SIGN term|numericValueExpression MINUS_SIGN term ;
term : factor|term ASTERISK factor|term SOLIDUS factor ;
factor : ( PLUS_SIGN|MINUS_SIGN )? numericPrimary ;
numericPrimary : valueExpressionPrimary|numericValueFunction ;
valueExpressionPrimary : parenthesizedValueExpression|nonParenthesizedValueExpressionPrimary ;
parenthesizedValueExpression : LEFT_PAREN valueExpression RIGHT_PAREN ;
nonParenthesizedValueExpressionPrimary : nonParenthesizedValueExpressionPrimarySpecialCase (selector)* ;// |bindingVariableReference ;
selector : (PERIOD propertyName) | (LEFT_BRACKET valueExpression RIGHT_BRACKET);
nonParenthesizedValueExpressionPrimarySpecialCase :
   unsignedValueSpecification
   | aggregateFunction
   | collectionValueConstructor
   | valueQueryExpression
   | caseExpression
   | letValueExpression
   | castSpecification
   | elementIdFunction
   | generalFunction
   | bindingVariableReference
   ;
collectionValueConstructor : listValueConstructor|recordValueConstructor|pathValueConstructor ;
numericValueFunction : lengthExpression|absoluteValueExpression|modulusExpression|trigonometricFunction|generalLogarithmFunction|commonLogarithm|naturalLogarithm|exponentialFunction|powerFunction|squareRoot|floorFunction|ceilingFunction ;
lengthExpression : charLengthExpression|byteLengthExpression|pathLengthExpression ;
charLengthExpression : ( CHAR_LENGTH|CHARACTER_LENGTH ) LEFT_PAREN characterStringValueExpression RIGHT_PAREN ;
byteLengthExpression : ( BYTE_LENGTH|OCTET_LENGTH ) LEFT_PAREN byteStringValueExpression RIGHT_PAREN ;
pathLengthExpression : PATH_LENGTH LEFT_PAREN pathValueExpression RIGHT_PAREN ;
absoluteValueExpression : ABS LEFT_PAREN numericValueExpression RIGHT_PAREN ;
modulusExpression : MOD LEFT_PAREN numericValueExpressionDividend COMMA numericValueExpressionDivisor RIGHT_PAREN ;
numericValueExpressionDividend : numericValueExpression ;
numericValueExpressionDivisor : numericValueExpression ;
trigonometricFunction : trigonometricFunctionName LEFT_PAREN numericValueExpression RIGHT_PAREN ;
trigonometricFunctionName : SIN|COS|TAN|COT|SINH|COSH|TANH|ASIN|ACOS|ATAN|DEGREES|RADIANS ;
generalLogarithmFunction : LOG LEFT_PAREN generalLogarithmBase COMMA generalLogarithmArgument RIGHT_PAREN ;
generalLogarithmBase : numericValueExpression ;
generalLogarithmArgument : numericValueExpression ;
commonLogarithm : LOG10 LEFT_PAREN numericValueExpression RIGHT_PAREN ;
naturalLogarithm : LN LEFT_PAREN numericValueExpression RIGHT_PAREN ;
exponentialFunction : EXP LEFT_PAREN numericValueExpression RIGHT_PAREN ;
powerFunction : POWER LEFT_PAREN numericValueExpressionBase COMMA numericValueExpressionExponent RIGHT_PAREN ;
numericValueExpressionBase : numericValueExpression ;
numericValueExpressionExponent : numericValueExpression ;
squareRoot : SQRT LEFT_PAREN numericValueExpression RIGHT_PAREN ;
floorFunction : FLOOR LEFT_PAREN numericValueExpression RIGHT_PAREN ;
ceilingFunction : ( CEIL|CEILING ) LEFT_PAREN numericValueExpression RIGHT_PAREN ;
stringValueExpression : characterStringValueExpression|byteStringValueExpression ;
characterStringValueExpression: characterStringFactor|characterStringValueExpression CONCATENATION_OPERATOR characterStringFactor ;
//characterStringValueExpression : characterStringConcatenation|characterStringFactor ;
//characterStringConcatenation : characterStringValueExpression CONCATENATION_OPERATOR characterStringFactor ;
characterStringFactor : characterStringPrimary ;
characterStringPrimary : valueExpressionPrimary|stringValueFunction ;
byteStringValueExpression : (byteStringFactor CONCATENATION_OPERATOR)* byteStringFactor;
//byteStringValueExpression : byteStringConcatenation|byteStringFactor ;
byteStringFactor : byteStringPrimary ;
byteStringPrimary : valueExpressionPrimary|stringValueFunction ;
//byteStringConcatenation : byteStringValueExpression CONCATENATION_OPERATOR byteStringFactor ;
stringValueFunction : characterStringFunction|byteStringFunction ;
characterStringFunction : substringFunction|fold|trimFunction|normalizeFunction ;
substringFunction:(LEFT | RIGHT ) LEFT_PAREN characterStringValueExpression COMMA stringLength RIGHT_PAREN;
fold : ( UPPER|LOWER ) LEFT_PAREN characterStringValueExpression RIGHT_PAREN ;
trimFunction : singleCharacterTrimFunction|multiCharacterTrimFunction ;
singleCharacterTrimFunction : TRIM LEFT_PAREN trimOperands RIGHT_PAREN ;
multiCharacterTrimFunction : ( BTRIM|LTRIM|RTRIM ) LEFT_PAREN trimSource ( COMMA trimCharacterString )? RIGHT_PAREN ;
trimOperands : ( trimSpecification? trimCharacterString? FROM )? trimSource ;
trimSource : characterStringValueExpression ;
trimSpecification : LEADING|TRAILING|BOTH ;
trimCharacterString : characterStringValueExpression ;
normalizeFunction : NORMALIZE LEFT_PAREN characterStringValueExpression ( COMMA normalForm )? RIGHT_PAREN ;
normalForm : NFC|NFD|NFKC|NFKD ;
byteStringFunction :  byteStringSubstringFunction | byteStringTrimFunction;
byteStringSubstringFunction : ( LEFT | RIGHT ) LEFT_PAREN byteStringValueExpression COMMA stringLength RIGHT_PAREN ;
byteStringTrimFunction : TRIM LEFT_PAREN byteStringTrimOperands RIGHT_PAREN ;
byteStringTrimOperands : ( trimSpecification? trimByteString? FROM )? byteStringTrimSource ;
byteStringTrimSource : byteStringValueExpression ;
trimByteString : byteStringValueExpression ;
stringLength : numericValueExpression ;
datetimeValueExpression : datetimeTerm|durationValueExpression PLUS_SIGN datetimeTerm|datetimeValueExpression PLUS_SIGN durationTerm|datetimeValueExpression MINUS_SIGN durationTerm ;
datetimeTerm : datetimeFactor ;
datetimeFactor : datetimePrimary ;
datetimePrimary : valueExpressionPrimary|datetimeValueFunction ;
datetimeValueFunction : dateFunction|timeFunction|datetimeFunction|localTimeFunction|localDatetimeFunction ;
dateFunction : CURRENT_DATE|DATE LEFT_PAREN dateFunctionParameters? RIGHT_PAREN ;
timeFunction : CURRENT_TIME|ZONED_TIME LEFT_PAREN timeFunctionParameters? RIGHT_PAREN ;
localTimeFunction : LOCAL_TIME ( LEFT_PAREN timeFunctionParameters? RIGHT_PAREN )? ;
datetimeFunction : CURRENT_TIMESTAMP|ZONED_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN ;
localDatetimeFunction : LOCAL_TIMESTAMP|LOCAL_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN ;
dateFunctionParameters : dateString|recordValueConstructor ;
timeFunctionParameters : timeString|recordValueConstructor ;
datetimeFunctionParameters : datetimeString|recordValueConstructor ;
dateString: unbrokenCharacterStringLiteral;
timeString: unbrokenCharacterStringLiteral;
datetimeString: unbrokenCharacterStringLiteral;
//durationValueExpression : durationTerm|durationValueExpression_1 PLUS_SIGN durationTerm_1|durationValueExpression_1 MINUS_SIGN durationTerm_1|datetimeSubtraction ;
durationValueExpression : durationTerm|durationValueExpression PLUS_SIGN durationTerm|durationValueExpression MINUS_SIGN durationTerm|datetimeSubtraction ;
datetimeSubtraction : DURATION_BETWEEN LEFT_PAREN datetimeSubtractionParameters RIGHT_PAREN ;
datetimeSubtractionParameters : datetimeValueExpression_1 COMMA datetimeValueExpression_2 ;
durationTerm : durationFactor|durationTerm ASTERISK factor|durationTerm SOLIDUS factor|term ASTERISK durationFactor ;
//durationTerm : durationFactor|durationTerm_2 ASTERISK factor|durationTerm_2 SOLIDUS factor|term ASTERISK durationFactor ;
durationFactor : ( PLUS_SIGN|MINUS_SIGN )? durationPrimary ;
durationPrimary : valueExpressionPrimary|durationValueFunction ;
//durationValueExpression_1 : durationValueExpression ;
//durationTerm_1 : durationTerm ;
//durationTerm_2 : durationTerm ;
datetimeValueExpression_1 : datetimeValueExpression ;
datetimeValueExpression_2 : datetimeValueExpression ;
durationValueFunction : durationFunction|durationAbsoluteValueFunction ;
durationFunction : DURATION LEFT_PAREN durationFunctionParameters RIGHT_PAREN ;
durationFunctionParameters : durationString|recordValueConstructor ;
durationString : unbrokenCharacterStringLiteral;
durationAbsoluteValueFunction : ABS LEFT_PAREN durationValueExpression RIGHT_PAREN ;
listValueExpression : (listPrimary CONCATENATION_OPERATOR)* listPrimary;
//listValueExpression : listConcatenation|listPrimary ;
//listConcatenation : listValueExpression_1 CONCATENATION_OPERATOR listPrimary ;
//listValueExpression_1 : listValueExpression ;
listPrimary : listValueFunction|valueExpressionPrimary ;
listValueFunction : trimListFunction | elementsFunction ;
trimListFunction : TRIM LEFT_PAREN listValueExpression COMMA numericValueExpression RIGHT_PAREN ;
elementsFunction : ELEMENTS LEFT_PAREN pathValueExpression RIGHT_PAREN ;
listValueConstructor : listValueConstructorByEnumeration ;
listValueConstructorByEnumeration : listValueTypeName? LEFT_BRACKET listElementList? RIGHT_BRACKET ;
listElementList : listElement ( COMMA listElement )* ;
listElement : valueExpression ;
recordValueConstructor : RECORD? fieldsSpecification ;
fieldsSpecification : LEFT_BRACE fieldList? RIGHT_BRACE ;
fieldList : field ( COMMA field )* ;
field : fieldName COLON valueExpression ;
pathValueExpression : (pathValuePrimary CONCATENATION_OPERATOR)* pathValuePrimary;
//pathValueExpression : pathValueConcatenation|pathValuePrimary ;
//pathValueConcatenation : pathValueExpression_1 CONCATENATION_OPERATOR pathValuePrimary ;
//pathValueExpression_1 : pathValueExpression ;
pathValuePrimary : valueExpressionPrimary ;
pathValueConstructor : pathValueConstructorByEnumeration ;
pathValueConstructorByEnumeration : PATH LEFT_BRACKET pathElementList RIGHT_BRACKET ;
pathElementList : pathElementListStart pathElementListStep* ;
pathElementListStart : nodeReferenceValueExpression ;
pathElementListStep : COMMA edgeReferenceValueExpression COMMA nodeReferenceValueExpression ;
propertyReference : propertySource PERIOD propertyName ;
propertySource : nodeReferenceValueExpression|edgeReferenceValueExpression|recordValueExpression ;
valueQueryExpression : VALUE nestedQuerySpecification ;
caseExpression : caseAbbreviation|caseSpecification ;
caseAbbreviation : NULLIF LEFT_PAREN valueExpression COMMA valueExpression RIGHT_PAREN|COALESCE LEFT_PAREN valueExpression ( COMMA valueExpression )+ RIGHT_PAREN ;
caseSpecification : simpleCase|searchedCase ;
simpleCase : CASE caseOperand simpleWhenClause+ elseClause? END ;
searchedCase : CASE searchedWhenClause+ elseClause? END ;
simpleWhenClause : WHEN whenOperandList THEN result ;
searchedWhenClause : WHEN searchCondition THEN result ;
elseClause : ELSE result ;
caseOperand : nonParenthesizedValueExpressionPrimary|elementVariableReference ;
whenOperandList : whenOperand ( COMMA whenOperand )* ;
whenOperand :
    nonParenthesizedValueExpressionPrimary
    | comparisonPredicatePart_2
    | nullPredicatePart_2
    | valueTypePredicatePart_2
    | directedPredicatePart_2
    | labeledPredicatePart_2
    | sourcePredicatePart_2
    | destinationPredicatePart_2
    ;
result : resultExpression|NULL ;
resultExpression : valueExpression ;
castSpecification : CAST LEFT_PAREN castOperand AS castTarget RIGHT_PAREN ;
castOperand : valueExpression ;
castTarget : valueType ;
elementIdFunction : ELEMENT_ID LEFT_PAREN elementVariableReference RIGHT_PAREN ;
generalFunction : functionName LEFT_PAREN procedureArgumentList? RIGHT_PAREN ;
letValueExpression : LET letVariableDefinitionList IN  valueExpression END;

unsignedLiteral : unsignedNumericLiteral|generalLiteral ;
literal : signedNumericLiteral|generalLiteral ;
signedNumericLiteral : ( PLUS_SIGN|MINUS_SIGN )? unsignedNumericLiteral ;
generalLiteral : predefinedTypeLiteral|listLiteral|recordLiteral ;
listLiteral : listValueConstructorByEnumeration ;
recordLiteral : recordValueConstructor ;