#include "Protheus.ch"
#include "GPEA934C.CH"
#Include 'FWMVCDEF.CH' 
#INCLUDE "FWMBROWSE.CH"

//Recuperar versão de envio
Static cVersEnvio  := ""
Static cVersGPE    := ""
Static lIntTAF     := ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )
Static lMiddleware := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVerTaf     := StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)

/*/{Protheus.doc} GPEA934C
Cadastro de Entidades Educativas para o eSocial
Esta rotina é o browse da tabela RJ6 - Entidades Educativas, os campos deste cadastro,
tem o objetivo de substituir os campos da tabela auxiliar S120 CTT no envio do evento S-1020 - Tabela de Lotações Tributárias.

@Author   Claudinei Soares
@Since    18/03/2019 
@Version  1.0 
@Type     Function

@History 18/03/2019 | Claudinei Soares     | DRHESOCP-11404 | Inclusão do fonte.
/*/
Function GPEA934C()
	Local cFiltraRh
	Local oBrwRJ6
	Local cMsgDesatu	:= ""
	Local aDados		:= {}	
	Local lNewVerEsoc   := .F.
	Local lContinua     := .F.

	If !ChkFile("RJ6")
		cMsgDesatu := CRLF + OemToAnsi(STR0008) + CRLF
	EndIf																														

	If !Findfunction("fVldIniRJ")
		cMsgDesatu += CRLF + OemToAnsi(STR0009)
	EndIf													

	If !Empty(cMsgDesatu)
		//ATENCAO"###"Tabela RJ6 não encontrada na base de dados. Execute o UPDDISTR."
		//ATENCAO"###"Não foram encontradas atualizações necessárias para utilização desta rotina, favor atualizar o repositório."
		Help( " ", 1, OemToAnsi(STR0007),, cMsgDesatu, 1, 0 )
		Return 																	
	EndIf

	// RECEBE A VERSÃO DO TAF.
	cVerTaf:= StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")

	If lIntTaf .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
		fVersEsoc("S1030", .F.,,, @cVersEnvio, @cVersGPE)			
		If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
			//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento xxx não será integrado com o TAF, e consequentemente, não será enviado ao RET.
			//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"				
			If !ESocMsgVer(.F.,/*cEvento*/, cVersGPE, cVersEnvio)
				Return ()
			Else
				lIntTaf := .F.
			Endif
		EndIf
	EndIf

	//Primeiro parâmetro da VldRotTab, quais eventos validar {S-1005, S-1010, S-1020}
	If !VldRotTab({.T.,.F.,.F.},@aDados)
		Help( " ", 1, OemToAnsi(STR0007),, CRLF + aDados[1] + CRLF + CRLF + OemToAnsi(STR0012) + CRLF + OemToAnsi(STR0013), 1, 0) //Atenção # O compartilhamento da tabela (RJ6) e (C92) estão divergentes, altere o modo de acesso através do Configurador. Arquivos (RJ6) e (C92)
		//O modo de acesso deve ser o mesmo para todas as tabelas envolvidas no processo, são elas: RJ3, RJ4, RJ5, RJ6, C99 e C92."
		Return 		
	EndIf


  	oBrwRJ6 := FWmBrowse():New()
	oBrwRJ6:SetAlias( 'RJ6' )
	oBrwRJ6:SetDescription(OemToAnsi(STR0001))	//"Entidades Educativas"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"RJ6","1")
	
	//Filtro padrao do Browse conforme tabela RJ6 (Entidades Educativas)
	oBrwRJ6:SetFilterDefault(cFiltraRh)
	oBrwRJ6:SetLocate()

	oBrwRJ6:ExecuteFilter(.T.)

	oBrwRJ6:Activate()
	
Return

/*/{Protheus.doc}
Menu Funcional
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		oMdlRJ6
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local aArea :={}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA934C'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA934C'  OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA934C'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA934C'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina

/*/{Protheus.doc}
Modelo de dados e Regras de Preenchimento para o Cadastro de Entidades Educativas eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		oMdlRJ6
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRJ6	:= FWFormStruct( 1, 'RJ6', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlRJ6
	
	// Blocos de codigo do modelo
    Local bPosValid 	:= { |oMdlRJ6| Gp934CPosVal( oMdlRJ6 )}
    Local bCommit		:= { |oMdlRJ6| Gp934CGrav( oMdlRJ6 )}
    
	// Bloco de codigo Fields
	Local bTOkVld		:= { |oGrid| Gp934CTOk( oGrid, oMdlRJ6)}
	
	// Cria o objeto do Modelo de Dados
	oMdlRJ6 := MPFormModel():New('GPEA934C', /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlRJ6:AddFields( 'MDLGPEA934C', /*cOwner*/, oStruRJ6, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRJ6:SetDescription(OemToAnsi(STR0001))//"Endidades Educativas"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRJ6:GetModel( 'MDLGPEA934C' ):SetDescription(OemToAnsi(STR0001)) //"Entidades Educativas"

Return oMdlRJ6
	

/*/{Protheus.doc}
Visualizador de dados do Cadastro de Entidades Educativas eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@return		oView
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRJ6   := FWLoadModel( 'GPEA934C' )
	// Cria a estrutura a ser usada na View
	Local oStruRJ6 := FWFormStruct( 2, 'RJ6' )
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRJ6 )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA934C', oStruRJ6, 'MDLGPEA934C' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA934C', 'FORMFIELD' )

Return oView


/*/{Protheus.doc}
Pos-validacao do Cadastro de Entidades Educativas eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		oMdlRJ6, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp934CPosVal( oMdlRJ6 )
	Local lRetorno      := .T.
	Local nOperation
	Local cChave		:= ""

	// Seta qual é a operacao corrente
	nOperation := oMdlRJ6:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .or. ( nOperation == MODEL_OPERATION_UPDATE .and. (oMdlRJ6:GetValue('MDLGPEA934C','RJ6_INI') + oMdlRJ6:GetValue('MDLGPEA934C','RJ6_TPINSC') + oMdlRJ6:GetValue('MDLGPEA934C','RJ6_NINSCR') + oMdlRJ6:GetValue('MDLGPEA934C','RJ6_ENTEDU') <> RJ6->(RJ6_INI + RJ6_TPINSC + RJ6_NINSCR + RJ6_ENTEDU) ))

    cChave := oMdlRJ6:GetValue('MDLGPEA934C','RJ6_INI') + oMdlRJ6:GetValue('MDLGPEA934C','RJ6_TPINSC') + oMdlRJ6:GetValue('MDLGPEA934C','RJ6_NINSCR') + oMdlRJ6:GetValue('MDLGPEA934C','RJ6_ENTEDU')
    
    dbSelectArea( "RJ6" )
    If dbSeek(xFilial("RJ6") + cChave )         
        //Atenção # Já existe um registro com a chave informada: RJ6_INI + RJ6_TPINSC + RJ6_NINSCR + RJ6_ENTEDU # Informe uma chave não existente na base de dados.
		Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0010) + "RJ6_INI + RJ6_TPINSC + RJ6_NINSCR + RJ6_ENTEDU", 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
		lRetorno := .F.     
	EndIf
EndIf

Return lRetorno


/*/{Protheus.doc}
Commit do Cadastro de Entidades Educativas eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		oMdlRJ6, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp934CGrav( oMdlRJ6 )

Local lRetorno       := .T.	
    
FWFormCommit( oMdlRJ6 )    	

	
Return lRetorno                                             
 

/*/{Protheus.doc}
Tudo Ok do Cadastro de Enditades Educativas eSocial
@type      	Static Function
@author   	Claudinei Soares
@since		13/03/2019
@version	1.0
@param		oGrid, 		object, 	Objeto da Grid a ser validada
@param		oMdlRJ6,	object, 	Objeto do Modelo a ser validado
@return		lRet,		logic
/*/

Static Function Gp934CTOk( oGrid, oMdlRJ6 )
Local lRet		:= .T.

// futura implementação para integração do evento com o TAF

Return lRet
