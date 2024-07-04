#INCLUDE "PROTHEUS.CH"

//Compatibilização de fontes 30/05/2018

#define XALIAS_ 1
#define XORDER_ 2
#define XKEY_ 3
#define XRECNO_ 4

// --------------------------------------------------------------------------------
// Declaracao da Classe CTB_List_Records
// --------------------------------------------------------------------------------

CLASS CTB_List_Records
// Declaracao das propriedades da Classe
DATA aRecords
DATA cAlias
DATA nOrder
DATA nNumRecords
DATA bSeek
DATA bWhile
DATA cQuery
DATA nLinePosition

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD GetAlias()
METHOD SetAlias(cAlias)
METHOD GetOrder()
METHOD SetOrder(nOrder)
METHOD SetSeek_CodeBlock( bSeek )
METHOD SetWhile_CodeBlock( bWhile )
METHOD GetQuery()
METHOD SetQuery_Expression( cQuery )
METHOD CountRecords()
METHOD GetPosition()
METHOD SetPosition(nLinePosition)
METHOD GetKeyPosition()
METHOD GetRecordPosition()
METHOD SetRecord()
METHOD Fill_Records()
METHOD AddRecord(cKey, nRecord)
METHOD CloneRecPosition()

ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS CTB_List_Records
Self:aRecords := {}
Self:cAlias := ""
Self:nOrder := 0
Self:nNumRecords := 0
Self:nLinePosition := 0
Self:bSeek
Self:bWhile
Self:cQuery

Return Self

METHOD GetAlias() CLASS CTB_List_Records
Return Self:cAlias

METHOD SetAlias(cAlias) CLASS CTB_List_Records
Self:cAlias := Alltrim(cAlias)
Return 

METHOD GetOrder() CLASS CTB_List_Records
Return Self:nOrder

METHOD SetOrder(nOrder) CLASS CTB_List_Records
Self:nOrder := nOrder
Return 

METHOD SetSeek_CodeBlock( bSeek ) CLASS CTB_List_Records
Self:bSeek := bSeek
Return

METHOD SetWhile_CodeBlock( bWhile ) CLASS CTB_List_Records
Self:bWhile := bWhile
Return

METHOD GetQuery() CLASS CTB_List_Records
Return Self:cQuery


/*
A QUERY A SER ATRIBUIDA AO OBJETO DEVE SEGUIR O EXEMPLO ABAIXO
SELECT R_E_C_N_O_ NUM_RECNO FROM CT1990
WHERE
CT1_FILIAL = '  '  //OBRIGATORIO INDICE
AND CT1_CONTA >= '1'  //DEMAIS CONDICOES
AND CT1_CONTA < '2'
AND D_E_L_E_T_ = ' ' //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS
ORDER BY CT1_CONTA //OPCIONAL
GROUP BY CT1_CONTA //OPCIONAL
*/

METHOD SetQuery_Expression( cQuery ) CLASS CTB_List_Records
cQuery := Upper(cQuery)
If Empty(cQuery) .OR. ;
	AT("FROM ", cQuery) == 0 .OR. ;
	StrTran( Alltrim(Subs(cQuery, 1, AT("FROM ", cQuery))), Space(1), "") != "SELECTR_E_C_N_O_NUM_RECNO"
	MsgAlert("Erro na construcao da Query para o Objeto CTB_List_Records. Verifique!")
Else
	Self:cQuery := AllTrim(cQuery)
EndIf
	
Return

METHOD CountRecords() CLASS CTB_List_Records
Return Self:nNumRecords

METHOD GetPosition() CLASS CTB_List_Records
Return Self:nLinePosition

METHOD SetPosition(nLinePosition) CLASS CTB_List_Records
Self:nLinePosition := nLinePosition
Return 

METHOD GetKeyPosition() CLASS CTB_List_Records
Return Self:aRecords[Self:nLinePosition, XKEY_ ]

METHOD GetRecordPosition() CLASS CTB_List_Records
Return Self:aRecords[Self:nLinePosition, XRECNO_ ]

METHOD SetRecord() CLASS CTB_List_Records
dbSelectArea(Self:cAlias)
dbGoto(Self:aRecords[Self:nLinePosition, XRECNO_ ])
Return

METHOD Fill_Records() CLASS CTB_List_Records
Local aArea := GetArea()
Local aAreaEntd := (Self:cAlias)->(GetArea()) 
Local cKey
Local bWhile
Local nX
Local a_Records := {}
Local __nPosFil := ""

dbSelectArea(Self:cAlias)
dbSetOrder(Self:nOrder)

If ! Empty(Self:cQuery)

	Self:cQuery := ChangeQuery( Self:cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,Self:cQuery), "_TMP_QRY", .T., .T. )
	
	dbSelectArea("_TMP_QRY")

	bWhile := {||  ! Eof() }
	
	While bWhile
		aAdd(a_Records, _TMP_QRY->NUM_RECNO )
		_TMP_QRY->(dbSkip())
	EndDo
	
	dbSelectArea("_TMP_QRY")
	dbCloseArea()	
	
	dbSelectArea(Self:cAlias)
	dbSetOrder(Self:nOrder)
	
	For nX := 1 TO Len(a_Records)

		dbGoto(a_Records[nX])
		Self:AddRecord(&(IndexKey()), Recno())

	Next //nX
	
Else

	If Self:bSeek != NIL
		cKey := Eval(Self:bSeek)
	Else	
		cKey := Eval( {|| xFilial(Self:cAlias) } )
	EndIf
	
	dbSelectArea(Self:cAlias)
	dbSetOrder(Self:nOrder)

	dbSeek(cKey) 
	
	If Self:bWhile == NIL
		//retirado fieldpos do laco e colocado antes da atribuicao do bWhile
		//nao colocado em variavel static -- por variar instancia do objeto  
		If Left(Self:cAlias,1) == "S"
			__nPosFil := FieldPos(Right(Self:cAlias,2)+"_FILIAL")
		Else
			__nPosFil := FieldPos(Self:cAlias+"_FILIAL")
		EndIf
		
		Self:bWhile := {||  FieldGet( __nPosFil ) == xFilial(Self:cAlias) }
			
	EndIf
	
	bWhile := {||  ! Eof() .And. Eval(Self:bWhile) }
	
	While Eval(bWhile)

		Self:AddRecord(&(IndexKey()), Recno())
	    dbSkip()
    
	EndDo

EndIf


RestArea(aAreaEntd)
RestArea(aArea)

Return

METHOD AddRecord(cKey, nRecord) CLASS CTB_List_Records
    
    aAdd(Self:aRecords, ARRAY(4) )
    Self:nNumRecords++
	Self:aRecords[Self:nNumRecords, XALIAS_ ] 	:= Self:cAlias
	Self:aRecords[Self:nNumRecords, XORDER_ ] 	:= Self:nOrder
	Self:aRecords[Self:nNumRecords, XKEY_ ] 	:= cKey
	Self:aRecords[Self:nNumRecords, XRECNO_ ] 	:= nRecord

Return

METHOD CloneRecPosition() CLASS CTB_List_Records
Local oObjLstRec

oObjLstRec := CTB_List_Records():New() 
oObjLstRec:SetAlias(Self:GetAlias())
oObjLstRec:SetOrder(Self:GetOrder())
oObjLstRec:AddRecord(Self:GetKeyPosition(), Self:GetRecordPosition())
    
Return(oObjLstRec)	

/* ----------------------------------------------------------------------------

_CTB_LIST_RECORD()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _CTB_LIST_RECORD()
Return Nil	
