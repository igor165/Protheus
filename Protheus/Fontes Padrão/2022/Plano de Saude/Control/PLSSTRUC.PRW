#INCLUDE "PLSSTRUC.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOBJECT.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Define
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
#DEFINE IDX_TAB_AL 1 
#DEFINE IDX_F_DATA 1 
#DEFINE IDX_F_VALU 2 
#DEFINE IDX_F__STA 3

#DEFINE IDX_FS_IND 3 
#DEFINE IDX_FS_TYP 4 
#DEFINE IDX_FS_SIZ 5 

/*/{Protheus.doc} PLSSTRUC
Class que retorna Struct de um alias para gravacao

Heranca
1 = PLSDAO
2 = PLSCONTR

@author Alexander Santos
@since 27/09/2010
@version P11
/*/
CLASS PLSSTRUC FROM PLSDAO
DATA oStruc		AS OBJECT
DATA aData	 	AS ARRAY
DATA aErros		AS ARRAY
DATA nOpc	 	AS NUMERIC
DATA nRecno		AS NUMERIC
DATA nIdx		AS NUMERIC 
DATA cKey	 	AS STRING
DATA lLog	 	AS LOGIC
DATA lAltera 	AS LOGIC

METHOD New(cAlias,nOpc,nIdx,nRecno,cKey) CONSTRUCTOR

METHOD Destroy()
METHOD CRUD()

METHOD SetValue()
METHOD GetValue()  

METHOD SetLogCMP()   
METHOD GetLog() 
                             
METHOD SetlAltera()   
METHOD GetlAltera() 

METHOD SetOperation()   
METHOD GetOperation() 

METHOD GetTable()
METHOD GetIndex()
METHOD GetAlias()

METHOD VldData()
METHOD GetData()

METHOD SetRecno()
METHOD GetRecno()

METHOD SetKey()
METHOD GetKey()

METHOD SetIdx()
METHOD GetIdx()

METHOD GetErrorMessage()

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Alexander Santos
@since 27/09/2010
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(cAlias,nOpc,nIdx,nRecno,cKey,cFields) Class PLSSTRUC
LOCAL nI 		 := 1      
LOCAL nHoraBase  := Seconds()
DEFAULT nOpc	 := MODEL_OPERATION_INSERT
DEFAULT nIdx   	 := 1     
DEFAULT nRecno	 := 0
DEFAULT cKey	 := ""
DEFAULT cFields	 := "" 

DEFAULT ::nOpc	 := nOpc
DEFAULT ::nIdx   := nIdx
DEFAULT ::nRecno := nRecno             
DEFAULT ::cKey	 := cKey
DEFAULT ::aData  := {}
DEFAULT ::aErros := {}
DEFAULT ::lLog   := .T.

// Cria a estrutura a ser usada com os campos recebidos via instanciamento da classe
if Empty(cFields)
	::oStruc := FWFormStruct( 1, cAlias )
else 
	::oStruc := FWFormStruct( 1, cAlias, {|x| AllTrim(x) $ cFields} )
endif

For nI:=1 To Len(::oStruc:aFields)
	AaDd(::aData,{::oStruc:aFields[nI,3],"",.F.})
Next             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Duração
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_Super:SetLog(nHoraBase)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(Self)
//-------------------------------------------------------------------
/*/{Protheus.doc} SetValue
Seta valor a um campo da estrutura

@author Alexander Santos
@since 27/09/2010
@version P11
/*/
//-------------------------------------------------------------------
METHOD SetValue(cField,cValue) Class PLSSTRUC
LOCAL nPos := 0

If ( nPos := Ascan(::aData,{ |x| x[IDX_F_DATA] == cField}) ) > 0
	::aData[nPos,IDX_F_VALU] 	:= cValue
	::aData[nPos,IDX_F__STA] 	:= .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetValue

Retorna o valor de um campo da estrutura

@author Alexander Santos
@since 27/09/2010
@version P11
/*/
//-------------------------------------------------------------------
METHOD GetValue(cField) Class PLSSTRUC
LOCAL nPos 		:= 0
LOCAL cConteudo := NIL

If ( nPos := Ascan(::aData,{ |x| x[IDX_F_DATA] == cField}) ) > 0
	cConteudo := ::aData[nPos,2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cConteudo)
//-------------------------------------------------------------------
/*/{Protheus.doc} SetOperation

Seta o tipo de Operacao Inclusao, Alteracao ou Exclusao

@author Alexander Santos
@since 27/09/2010
@version P11
/*/
//-------------------------------------------------------------------
METHOD SetOperation(nOpc) Class PLSSTRUC
::nOpc := nOpc
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetOperation
Retorna a operacao que esta sendo realizada

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetOperation() Class PLSSTRUC
Return ::nOpc
//-------------------------------------------------------------------
/*/ { Protheus.doc } VldData
Validacao dos dados contidos na matriz adata do obj

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VldData() Class PLSSTRUC     
LOCAL nHoraBase := Seconds()
LOCAL nI,nY 	:= 0
LOCAL nPos		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Campos e dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nI:=1 To Len(::aData)
	
	If ::aData[nI,IDX_F__STA]	
	
		If ( nPos := Ascan(::oStruc:aFields,{ |x| x[IDX_FS_IND] == ::aData[nI,IDX_F_DATA]}) ) > 0
		
			cType := ::oStruc:aFields[nPos,	IDX_FS_TYP]
			nSize := ::oStruc:aFields[nPos,	IDX_FS_SIZ]
			
			If ValType(::aData[nI,IDX_F_VALU]) == "C" .And. Len(::aData[nI,IDX_F_VALU]) > nSize
				AaDd(::aErros,"["+::aData[nI,IDX_F_DATA]+STR0001) //"] - Tamanho maior que o definido no dicionario"
			EndIf
			
			If ValType(::aData[nI,IDX_F_VALU]) <> cType .And. cType <> 'M'
				AaDd(::aErros,"["+::aData[nI,IDX_F_DATA]+STR0002) //"] - Tipo diferente do definido no dicionario"
			EndIf         
		Else
			AaDd(::aErros,"["+::aData[nI,IDX_F_DATA]+STR0003) //"] - Nao encontrado no dicionario"
		EndIf
		
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Duração
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_Super:SetLog(nHoraBase)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( Len(::aErros)==0 )
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetData
Retorna a matriz adata 

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetData() Class PLSSTRUC
Return ::aData
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetErrorMessage
Retorna os erros encontrados na validacao do obj

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetErrorMessage(lOp) Class PLSSTRUC
LOCAL nI	:= 1
LOCAL cErro := ""
DEFAULT lOp := .F.

If lOp
	For nI:=1 To Len(::aErros)
		cErro += ::aErros[nI]+CRLF
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( Iif(lOp, AllToChar(cErro), ::aErros) )
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetTable
Retorna informacoes sobre a tabela

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetTable() Class PLSSTRUC
Return(::oStruc:aTable)
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetAlias
Retorna o alias 

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetAlias() Class PLSSTRUC
Return(::oStruc:aTable[IDX_TAB_AL])
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetRecno
Seta o recno de registro no obj

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetRecno(nRecno) Class PLSSTRUC
::nRecno := nRecno
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetRecno
Retorna o recno do registro

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetRecno() Class PLSSTRUC
Return(::nRecno)
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetIndex
Retorna a matriz de indices do registro

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetIndex() Class PLSSTRUC
Return(::oStruc:aIndex)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetIdx
Seta o ind para checagem na inclusao

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetIdx(nIdx) Class PLSSTRUC
::nIdx := nIdx
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetIdx
Retorna o Idx usado para inclusao

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetIdx() Class PLSSTRUC
Return(::nIdx)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetLogCMP
Ativa o registro de log

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetLogCMP(lLog) Class PLSSTRUC
::lLog := lLog
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetLog
Retorna se o registro de log esta ativo ou nao

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetLog() Class PLSSTRUC
Return(::lLog)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetKey
Set na chave de pesquisa 

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetKey(cKey) Class PLSSTRUC
::cKey := cKey
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetKey
Retorna a chave de pesquisa 

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetKey() Class PLSSTRUC
Return(::cKey)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetlAltera
Ativa o controle se altera na inclusao quando o registro existe

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetlAltera(lAltera) Class PLSSTRUC
::lAltera := lAltera
Return
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetlAltera
Retorna o controle se altera na inclusao quando o registro existe

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetlAltera() Class PLSSTRUC
Return(::lAltera)
//-------------------------------------------------------------------
/*/{Protheus.doc} CRUD
Metodo de inclusao, alteracao e exclusao de registro

@author Alexander Santos
@since 14/01/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD CRUD() Class PLSSTRUC     
LOCAL lRet		:= .T.
LOCAL oObj 		:= Self
LOCAL nHoraBase := Seconds()

If oObj:VldData()
	_Super:New(oObj,::aErros)
Else 
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0004 + ' [' + oObj:GetErrorMessage(.T.) + ']'  , 0, 0, {}) //"Erros encontrados:"
	lRet := .F.
EndIf           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Duração
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_Super:SetLog(nHoraBase)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)                                                        
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSSTRUC
FreeObj(Self:self)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSSTRUC  ³ Autor ³ Totvs				    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSSTRUC
Return
