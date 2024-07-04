#include "PROTHEUS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FINA790	
Cadastro de Codigo de Retenção x Vencimento

@author Marjorie
@since 01/02/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function FINA790()
Private cCadastro	:= "Codigo de Recolhimento x Vencimento"
Private aRotina := MenuDef()

mBrowse( 6, 1,22,75,"FJQ",,,,,,)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF	
Menudef

@author Marjorie
@since 01/02/2016
@version 12.1.7 
/*/
//-------------------------------------------------------------------
Static Function Menudef()
PRIVATE aRotina := {}
  
aRotina	:= { 	{"Pesquisar"	,"AxPesqui"  	, 0 , 1 , ,.F.},;  // "Pesquisar"
				{"Visualizar"	,"AxVisual"  	, 0 , 2 , ,},;  // "Visualizar"
				{"Incluir"		,"F790INC"		, 0 , 3 , ,},;  // "Incluir"
				{"Alterar"		,"F790ALT"		, 0 , 4 , ,},;  // "Alterar"
				{"Excluir"		,"A090Deleta"	, 0 , 5 , ,}}  // "Excluir"
					
Return(aRotina)
				
						
//-------------------------------------------------------------------
/*/{Protheus.doc} F790INC	
Inclusão do Cadastro de Codigo de Retenção x Vencimento

@author Marjorie
@since 01/02/2016
@version 12.1.7 
/*/
//-------------------------------------------------------------------
Function F790INC(cAlias, nReg, nOpc)

LOCAL aCpos  := {"FJQ_CODRET","FJQ_PERIOD"}


AxInclui (cAlias,nReg,nOpc,,,aCpos,'F790OK()')


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F790ALT	
Alteração do Cadastro de Codigo de Retenção x Vencimento

@author Marjorie
@since 01/02/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function F790ALT()

LOCAL nReg    := FJQ->( Recno() )
LOCAL aCpos  := {"FJQ_PERIOD"}
 
AxAltera("FJQ",nReg,4,,aCpos,,,'F790OK()')
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F790OK	
Tudo Ok

@author Marjorie
@since 01/02/2016
@version 12.1.7 
/*/
//-------------------------------------------------------------------
Function F790OK()
local aAreaFJQ	:= GetArea()
Local lRet		:= .T.

If Empty(M->FJQ_CODRET) .or. Empty(M->FJQ_PERIOD) 
	Help(" ",1,"F790OBR")//Os campos obrigatórios não foram preenchidos
	lRet	:= .F.
EndIf	

If FJQ->(dbSeek(xFilial("FJQ")+M->FJQ_CODRET))
	If M->FJQ_CODRET == FJQ->FJQ_CODRET .and. M->FJQ_PERIOD <> FJQ->FJQ_PERIOD .and. ALTERA
		lRet	:= .T.
	Else
		Help(" ",1,"F790CAD") //Cadastro já existente
		lRet	:= .F.
	EndIf
EndIf

RestArea(aAreaFJQ)
Return lRet	