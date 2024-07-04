#Include 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "STBOrcCancel.CH" 

Static aRegs := {}

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STBOrcCancel
Valida os parametros 3 e 4 do pergunte STBORCCANC.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	15/04/2013
@return  	
@obs     	
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STBOrcCancel()
Local cFiltro	:= ""
Local oMark	:= Nil

Private aRotina := MenuDef()
Private cCadastro := "Exclus„o N.f./orcam."

cFiltro := STBSetMkBrowseFilter()

aRegs := {}

oMark:= FWMarkBrowse():New()
oMark:SetAlias('SL1')
oMark:SetDescription(cCadastro)
oMark:SetFieldMark( 'L1_UNDOBTC' )
oMark:SetAfterMark({|| STBGetMarkedRegistries(oMark)})
oMark:SetAllMark({|| STBMarkAllRegistries(oMark)})
If !Empty(cFiltro)
	oMark:SetFilterDefault(cFiltro)
EndIf
oMark:Activate()

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STVldOrcPerg
Valida os parametros 3 e 4 do pergunte STBORCCANC.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	15/04/2013
@return  	
@obs     	
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STVldOrcPerg()
Local lRet := .T.	

If SubStr(DTOS(MV_PAR03),1,8) > SubStr(DTOS(MV_PAR04),1,8) .Or. SubStr(DTOS(MV_PAR04),1,8) < SubStr(DTOS(MV_PAR03),1,8)
	MsgAlert(STR0001)//"O intervalo entre as datas informado est· incorreto, favor ajustar o intervalo de datas e tente novamente."
	lRet := .F.
EndIf

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/* {Protheus.doc} STBGetMarkedRegistries
Funcao que, ao selecionar um orcamento, o adiciona em aRegs para ser estornado posteriormente.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	09/04/2013
@return  	
@obs     	
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STBSetMkBrowseFilter()
Local cFiltro 	:= ""
Local lPergunta := .T.		//Varialvel de controle para  While

While lPergunta 
	lPergunta := Pergunte("STBORCCANC",.T.)
	If lPergunta
 		lPergunta := !STVldOrcPerg()
	Else 
		Exit
	Endif 
End
	
If !Empty(MV_PAR01)
	cFiltro += "SL1->L1_NUM >= '" + MV_PAR01 + "' .AND. "
EndIf

If !Empty(MV_PAR02)
	cFiltro += "SL1->L1_NUM <= '" + MV_PAR02 + "'.AND. "
EndIf

cFiltro += "SL1->L1_SITUA <> 'RX' .AND. "

cFiltro += "DToS(SL1->L1_EMISSAO) >= '" + DToS(MV_PAR03) + "' .AND. "
cFiltro += "DToS(SL1->L1_EMISSAO) <= '" + DToS(MV_PAR04) + "' .AND. "

cFiltro += "Empty( SL1->L1_FILRES ) .AND. Empty( SL1->L1_ORCRES )"


Return cFiltro

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/* {Protheus.doc} STBGetMarkedRegistries
Funcao que, ao selecionar um orcamento, o adiciona em aRegs para ser estornado posteriormente.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	09/04/2013
@return  	
@obs     	
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STBGetMarkedRegistries(oMark)
Local cMarca := oMark:Mark()
Local nPos   := 0

If oMark:IsMark(cMarca)
	Aadd(aRegs,SL1->L1_FILIAL+SL1->L1_NUM)
Else
	If Len(aRegs) > 0 
		nPos := aScan(aRegs,SL1->L1_FILIAL+SL1->L1_NUM)
		If nPos > 0
			aDel(aRegs,nPos)
			aSize(aRegs,Len(aRegs)-1)
		EndIf
	EndIf
EndIf

Return Nil

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/* {Protheus.doc} STBMarkAllRegistries
Funcao que, ao selecionar um orcamento, o adiciona em aRegs para ser estornado posteriormente.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	09/04/2013
@return  	
@obs     	
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Static Function STBMarkAllRegistries(oMark)
Local cMarca 	:= oMark:Mark()
Local aArea	:= GetArea()

oMark:AllMark()

DbSelectArea("SL1")
SL1->(DbSetOrder(4))
SL1->(DbGoTop())

While SL1->(!EOF())
	If oMark:IsMark(cMarca)
		Aadd(aRegs,SL1->L1_FILIAL+SL1->L1_NUM)
	EndIf
	SL1->(DbSkip())
End

RestArea(aArea)

Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/* {Protheus.doc} STBGrvCancel
Funcao que permite o cancelamento das operacoes realizadas pelo GrvBatch.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	09/04/2013
@return  	
@obs     	
@sample
*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

Function STBGrvCancel()

STDGrvCancel( aRegs )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author leandro.dourado
@since 09/04/2013
@version 12
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw"      	OPERATION 0       ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE "Excluir" ACTION "LjMsgRun('Processando...','Estornando Orcamentos',{||STBGrvCancel( )})" 	OPERATION MODEL_OPERATION_DELETE     ACCESS 0 //"Excluir"

Return aRotina
