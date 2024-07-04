#INCLUDE "PROTHEUS.CH"

#define XALIAS_ 1
#define XORDER_ 2
#define XKEY_ 3
#define XRECNO_ 4

//AMARRACAO
// --------------------------------------------------------------------------------
// Declaracao da Classe Adm_List_Records
// --------------------------------------------------------------------------------

CLASS Adm_List_Records
// Declaracao das propriedades da Classe
DATA aRecords
DATA cAlias
DATA nOrder
DATA nNumRecords
DATA bSeek
DATA bWhile
DATA cQuery
DATA nLinePosition
DATA lTcGenQry2 
DATA aParQry2 

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
METHOD SetCurrentRecord()
METHOD SetParQry2(a_Par_Qry2)
METHOD SetTcGenQry2(lQry2)
ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS Adm_List_Records
Self:aRecords := {}
Self:cAlias := ""
Self:nOrder := 0
Self:nNumRecords := 0
Self:nLinePosition := 0
Self:bSeek
Self:bWhile
Self:cQuery

Self:lTcGenQry2 := .F.
Self:aParQry2 := {}

Return Self

METHOD GetAlias() CLASS Adm_List_Records
Return Self:cAlias

METHOD SetAlias(cAlias) CLASS Adm_List_Records
Self:cAlias := Alltrim(cAlias)
Return 

METHOD GetOrder() CLASS Adm_List_Records
Return Self:nOrder

METHOD SetOrder(nOrder) CLASS Adm_List_Records
Self:nOrder := nOrder
Return 

METHOD SetSeek_CodeBlock( bSeek ) CLASS Adm_List_Records
Self:bSeek := bSeek
Return

METHOD SetWhile_CodeBlock( bWhile ) CLASS Adm_List_Records
Self:bWhile := bWhile
Return

METHOD GetQuery() CLASS Adm_List_Records
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

METHOD SetQuery_Expression( cQuery ) CLASS Adm_List_Records
cQuery := Upper(cQuery)
If Empty(cQuery) .OR. ;
	AT("FROM ", cQuery) == 0 .OR. ;
	StrTran( Alltrim(Subs(cQuery, 1, AT("FROM ", cQuery)-1)), Space(1), "") != "SELECTR_E_C_N_O_NUM_RECNO"
	MsgAlert("Erro na construcao da Query para o Objeto Adm_List_Records. Verifique!")
Else
	Self:cQuery := AllTrim(cQuery)
EndIf
	
Return

METHOD CountRecords() CLASS Adm_List_Records
Return Self:nNumRecords

METHOD GetPosition() CLASS Adm_List_Records
Return Self:nLinePosition

METHOD SetPosition(nLinePosition) CLASS Adm_List_Records
Self:nLinePosition := nLinePosition
Return 

METHOD GetKeyPosition() CLASS Adm_List_Records
Return Self:aRecords[Self:nLinePosition, XKEY_ ]

METHOD GetRecordPosition() CLASS Adm_List_Records
Return Self:aRecords[Self:nLinePosition, XRECNO_ ]

METHOD SetRecord() CLASS Adm_List_Records
dbSelectArea(Self:cAlias)
dbGoto(Self:aRecords[Self:nLinePosition, XRECNO_ ])
Return

METHOD Fill_Records() CLASS Adm_List_Records
Local aArea := GetArea()
Local aAreaEntd := (Self:cAlias)->(GetArea()) 
Local cKey
Local bWhile
Local nX
Local a_Records := {}

dbSelectArea(Self:cAlias)
dbSetOrder(Self:nOrder)

If ! Empty(Self:cQuery)

	If ! Self:lTcGenQry2
		Self:cQuery := ChangeQuery( Self:cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,Self:cQuery), "_TMP_QRY", .T., .T. )
	Else
		dbUseArea( .T., "TOPCONN", TcGenQry2(,,Self:cQuery,Self:aParQry2), "_TMP_QRY", .T., .T. )
	EndIf
	
	dbSelectArea("_TMP_QRY")

	bWhile := {||  ! Eof() }
	
	While Eval(bWhile)
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
		If Left(Self:cAlias,1) == "S"
			Self:bWhile := {||  FieldGet(FieldPos(Right(Self:cAlias,2)+"_FILIAL")) == xFilial(Self:cAlias) }
		Else
			Self:bWhile := {||  FieldGet(FieldPos(Self:cAlias+"_FILIAL")) == xFilial(Self:cAlias) }
		EndIf	
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

METHOD AddRecord(cKey, nRecord) CLASS Adm_List_Records
    
    aAdd(Self:aRecords, ARRAY(4) )
    Self:nNumRecords++
	Self:aRecords[Self:nNumRecords, XALIAS_ ] 	:= Self:cAlias
	Self:aRecords[Self:nNumRecords, XORDER_ ] 	:= Self:nOrder
	Self:aRecords[Self:nNumRecords, XKEY_ ] 	:= cKey
	Self:aRecords[Self:nNumRecords, XRECNO_ ] 	:= nRecord

Return

METHOD CloneRecPosition() CLASS Adm_List_Records
Local oObjLstRec

oObjLstRec := Adm_List_Records():New() 
oObjLstRec:SetAlias(Self:GetAlias())
oObjLstRec:SetOrder(Self:GetOrder())
oObjLstRec:AddRecord(Self:GetKeyPosition(), Self:GetRecordPosition())
    
Return(oObjLstRec)	


METHOD SetCurrentRecord() CLASS Adm_List_Records
Self:SetAlias(Alias())
Self:SetOrder(IndexOrd())
Self:AddRecord(&(IndexKey()), Recno() )
    
Return

METHOD SetParQry2(a_Par_Qry2) CLASS Adm_List_Records

Self:aParQry2 := a_Par_Qry2

Return

METHOD SetTcGenQry2(lQry2) CLASS Adm_List_Records

Self:lTcGenQry2 := lQry2

Return
/* ----------------------------------------------------------------------------

_Adm_LIST_RECORD()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _Adm_LIST_RECORD()
Return Nil	