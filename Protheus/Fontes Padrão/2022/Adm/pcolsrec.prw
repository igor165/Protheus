#INCLUDE "PROTHEUS.CH"

#define XALIAS_ 1
#define XINDEX_ 2
#define XKEY_ 3
#define XRECNO_ 4

// --------------------------------------------------------------------------------
// Declaracao da Classe List_Records
// --------------------------------------------------------------------------------

CLASS List_Records
// Declaracao das propriedades da Classe
DATA aRecords
DATA cAlias
DATA nIndex
DATA nNumRecords
DATA bSeek
DATA bWhile
DATA nLinePosition

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD GetAlias()
METHOD SetAlias(cAlias)
METHOD GetIndex()
METHOD SetIndex(nIndex)
METHOD SetSeek_CodeBlock( bSeek )
METHOD SetWhile_CodeBlock( bWhile )
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
METHOD New() CLASS List_Records
Self:aRecords := {}
Self:cAlias := ""
Self:nIndex := 0
Self:nNumRecords := 0
Self:nLinePosition := 0
Self:bSeek
Self:bWhile
Return Self

METHOD GetAlias() CLASS List_Records
Return Self:cAlias

METHOD SetAlias(cAlias) CLASS List_Records
Self:cAlias := Alltrim(cAlias)
Return 

METHOD GetIndex() CLASS List_Records
Return Self:nIndex

METHOD SetIndex(nIndex) CLASS List_Records
Self:nIndex := nIndex
Return 

METHOD SetSeek_CodeBlock( bSeek ) CLASS List_Records
Self:bSeek := bSeek
Return

METHOD SetWhile_CodeBlock( bWhile ) CLASS List_Records
Self:bWhile := bWhile
Return

METHOD CountRecords() CLASS List_Records
Return Self:nNumRecords

METHOD GetPosition() CLASS List_Records
Return Self:nLinePosition

METHOD SetPosition(nLinePosition) CLASS List_Records
Self:nLinePosition := nLinePosition
Return 

METHOD GetKeyPosition() CLASS List_Records
Return Self:aRecords[Self:nLinePosition, XKEY_ ]

METHOD GetRecordPosition() CLASS List_Records
Return Self:aRecords[Self:nLinePosition, XRECNO_ ]

METHOD SetRecord() CLASS List_Records
dbSelectArea(Self:cAlias)
dbGoto(Self:aRecords[Self:nLinePosition, XRECNO_ ])
Return

METHOD Fill_Records() CLASS List_Records
Local aArea := GetArea()
Local aAreaEntd := (Self:cAlias)->(GetArea()) 
Local cKey

dbSelectArea(Self:cAlias)
dbSetOrder(Self:nIndex)
If Self:bSeek != NIL
	cKey := Eval(Self:bSeek)
Else	
	cKey := Eval( {|| xFilial(Self:cAlias) } )
EndIf	
dbSeek(cKey)

If Self:bWhile == NIL
	If Left(Self:cAlias,1) == "S"
		Self:bWhile := {||  FieldGet(FieldPos(Right(Self:cAlias,2)+"_FILIAL")) == xFilial(Self:cAlias) }
	Else
		Self:bWhile := {||  FieldGet(FieldPos(Self:cAlias+"_FILIAL")) == xFilial(Self:cAlias) }
	EndIf	
EndIf

While ! Eof() .And. Eval(Self:bWhile)

	Self:AddRecord(&(IndexKey()), Recno())
    dbSkip()
    
EndDo

RestArea(aAreaEntd)
RestArea(aArea)

Return

METHOD AddRecord(cKey, nRecord) CLASS List_Records
    
    aAdd(Self:aRecords, ARRAY(4) )
    Self:nNumRecords++
	Self:aRecords[Self:nNumRecords, XALIAS_ ] 	:= Self:cAlias
	Self:aRecords[Self:nNumRecords, XINDEX_ ] 	:= Self:nIndex
	Self:aRecords[Self:nNumRecords, XKEY_ ] 	:= cKey
	Self:aRecords[Self:nNumRecords, XRECNO_ ] 	:= nRecord

Return

METHOD CloneRecPosition() CLASS List_Records
Local oObjLstRec

oObjLstRec := List_Records():New() 
oObjLstRec:SetAlias(Self:GetAlias())
oObjLstRec:SetIndex(Self:GetIndex())
oObjLstRec:AddRecord(Self:GetKeyPosition(), Self:GetRecordPosition())
    
Return(oObjLstRec)	

/* ----------------------------------------------------------------------------

_PCO_LIST_RECORD()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _PCO_LIST_RECORD()
Return Nil	