#include "Protheus.ch"
#include "GPEA934.CH"
#Include 'FWMVCDEF.CH' 
#INCLUDE "FWMBROWSE.CH"

//Recuperar versão de envio
Static cVersEnvio := ""
Static cVersGPE   := ""
Static lIntTAF    := ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )
Static lMiddleware:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEA934
Cadastro de Lotações para o eSocial
Esta rotina é o browse da tabela RJ3 - Lotações eSocial, os campos deste cadastro,
tem o objetivo de substituir os campos da tabela CTT no envio do evento S-1020 - Tabela de Lotações Tributárias.

@Author   Claudinei Soares
@Since    13/03/2019 
@Version  1.0 
@Type     Function

@History 13/03/2019 | Claudinei Soares     | DRHESOCP-11374 | Inclusão do fonte.
/*/
Function GPEA934()
	Local cFiltraRh
	Local oBrwRJ3
	Local cMsgDesatu	:= ""
	Local aDados		:= {}

	If !ChkFile("RJ3")
		cMsgDesatu := CRLF + OemToAnsi(STR0008) + CRLF
	EndIf																														

	If !Findfunction("RJPct") .Or. !Findfunction("fVldIniRJ")
		cMsgDesatu += CRLF + OemToAnsi(STR0009)
	EndIf													

	If !Empty(cMsgDesatu)
		//ATENCAO"###"Tabela RJ3 não encontrada na base de dados. Execute o UPDDISTR."
		//ATENCAO"###"Não foram encontradas atualizações necessárias para utilização desta rotina, favor atualizar o repositório."
		Help( " ", 1, OemToAnsi(STR0007),, cMsgDesatu, 1, 0 )
		Return 																	
	EndIf
		
	//Primeiro parâmetro da VldRotTab, quais eventos validar {S-1005, S-1010, S-1020}
	If !VldRotTab({.F.,.F.,.T.},@aDados)
		Help( " ", 1, OemToAnsi(STR0007),, CRLF + aDados[1] + CRLF + CRLF + OemToAnsi(STR0012) + CRLF + OemToAnsi(STR0013), 1, 0) //Atenção # O compartilhamento da tabela (RJ3) e (C99) estão divergentes, altere o modo de acesso através do Configurador. Arquivos (RJ3) e (C99)
		//O modo de acesso deve ser o mesmo para todas as tabelas envolvidas no processo, são elas: RJ3, RJ4, RJ5, RJ6, C99 e C92."
		Return 		
	EndIf
	
	If lMiddleware .And. !ChkFile("RJE")
		Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0014), 1, 0 )//"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Return
	EndIf	

  	oBrwRJ3 := FWmBrowse():New()
	oBrwRJ3:SetAlias( 'RJ3' )
	oBrwRJ3:SetDescription(OemToAnsi(STR0001))	//"Lotações eSocial"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"RJ3","1")
	
	//Filtro padrao do Browse conforme tabela RJ3 (Lotações eSocial)
	oBrwRJ3:SetFilterDefault(cFiltraRh)
	oBrwRJ3:SetLocate()

	oBrwRJ3:ExecuteFilter(.T.)

	oBrwRJ3:Activate()
	
Return

/*/{Protheus.doc}
Menu Funcional
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		oMdlRJ3
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local aArea :={}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA934'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA934' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA934'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA934'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

/*/{Protheus.doc}
Modelo de dados e Regras de Preenchimento para o Cadastro de Lotações eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		oMdlRJ3
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRJ3 := FWFormStruct( 1, 'RJ3', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlRJ3
	
	// Blocos de codigo do modelo
    Local bPosValid 	:= { |oMdlRJ3| Gp934PosVal( oMdlRJ3 )}
    Local bCommit		:= { |oMdlRJ3| Gp934Grav( oMdlRJ3 )}
    
	// Bloco de codigo Fields
	Local bTOkVld		:= { |oGrid| Gp934TOk( oGrid, oMdlRJ3)}
	
	// Cria o objeto do Modelo de Dados
	oMdlRJ3 := MPFormModel():New('GPEA934', /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlRJ3:AddFields( 'MDLGPEA934', /*cOwner*/, oStruRJ3, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRJ3:SetDescription(OemToAnsi(STR0001))//"Lotações eSocial"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRJ3:GetModel( 'MDLGPEA934' ):SetDescription(OemToAnsi(STR0001)) //"Lotações eSocial"

Return oMdlRJ3
	

/*/{Protheus.doc}
Visualizador de dados do Cadastro de Lotações eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		oView
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRJ3   := FWLoadModel( 'GPEA934' )
	// Cria a estrutura a ser usada na View
	Local oStruRJ3 := FWFormStruct( 2, 'RJ3' )
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRJ3 )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA934', oStruRJ3, 'MDLGPEA934' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA934', 'FORMFIELD' )

Return oView


/*/{Protheus.doc}
Pos-validacao do Cadastro de Lotações eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		oMdlRJ3, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp934PosVal( oMdlRJ3 )
	Local cChave	:= ""
	Local nOpcRJ3	:= oMdlRJ3:GetOperation()
	Local lRet		:= .T.

If nOpcRJ3 == MODEL_OPERATION_INSERT .Or. ( nOpcRJ3 == MODEL_OPERATION_UPDATE .And. (oMdlRJ3:GetValue('MDLGPEA934','RJ3_INI') + oMdlRJ3:GetValue('MDLGPEA934','RJ3_COD') <> M->(RJ3_INI + RJ3_COD) ))
    cChave := oMdlRJ3:GetValue('MDLGPEA934','RJ3_INI') + oMdlRJ3:GetValue('MDLGPEA934','RJ3_COD')
    
    dbSelectArea( "RJ3" )
    If dbSeek(xFilial("RJ3") + cChave )         
        //Atenção # Já existe um registro com a chave informada: RJ3_INI + RJ3_COD # Informe uma chave não existente na base de dados.
		Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0010) + "RJ3_INI + RJ3_COD", 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
		lRet := .F.     
	EndIf
EndIf

If (lIntTAF .Or. lMiddleware) .And. lRet .And. FindFunction("fVldRJ3")
	lRet:= fVldRJ3(nOpcRJ3)
EndIf

Return lRet

/*/{Protheus.doc}
Commit do Cadastro de Lotações eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		oMdlRJ3, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp934Grav( oMdlRJ3 )

Local lRetorno       := .T.	
    
FWFormCommit( oMdlRJ3 )    	

	
Return lRetorno                                             
 

/*/{Protheus.doc}
Tudo Ok do Cadastro de Lotações eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		oGrid, 		object, 	Objeto da Grid a ser validada
@param		oMdlRJ3,	object, 	Objeto do Modelo a ser validado
@return		lRet,		logic
/*/

Static Function Gp934TOk( oGrid, oMdlRJ3 )
Local lRet		:= .T.

// futura implementação para integração do evento com o TAF

Return lRet