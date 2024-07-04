#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1176.CH"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} LOJA1176()

rotina de exclusao de cargas

@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------   
Function LOJA1176()

Local oSelector		:= Nil
Local oTempRequest	:= Nil
Local oLoadGroups		:= Nil

LjGrvLog( "Carga","ID_INICIO")

//verifica se eh a retaguarda (servidor que cria cargas)
If LJ1176IsServer()
	
	oLoadGroups := LJILLoadResult()
	oTempRequest := LJCInitialLoadRequest():New() 
	oSelector := LJCInitialLoadSelector():New(oLoadGroups, oTempRequest, .F., .T.) //instacia o seletor em modo de exclusao de carga
	oSelector:Show()
	
Else
	//avisa que o ambiente nao eh compativel ou nao existem cargas a serem excluidas
	Aviso( STR0001, STR0002, {"OK"} ) //atusx "Atenção" "Este ambiente não possui cargas geradas a serem excluídas" "OK"
EndIf

LjGrvLog( "Carga","ID_FIM")

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} LOJA1176()

Verifica se eh o servidor gerador de cargas

@return lRet True se for servidor de carga (retaguarda)
@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------  
Function LJ1176IsServer() 
Local lRet := .F.

If AliasInDic("MBU")
	DbSelectArea("MBU")
	lRet := ( MBU->(LASTREC()) > 0 )
EndIf


Return lRet
