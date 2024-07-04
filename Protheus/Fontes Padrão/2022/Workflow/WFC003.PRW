#INCLUDE "WFC003.ch" 
#include "SIGAWF.CH"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} WFC003

CADASTRO DE E-MAILS DO WORKFLOW - Funcao principal do cadastro de e-mail do workflow

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------

Function WFC003()

	Private oMark 
		
	oMark := FWMarkBrowse():New() 
	 
	//Definição da tabela a ser utilizada 
	oMark:SetAlias('WF7') 
	
	//Habilita o semáforo
	oMark:SetSemaphore(.T.)
	 
	// Define a legenda  
	oMark:AddLegend("WF7_ATIVO", "GREEN" ) 
	oMark:AddLegend("!WF7_ATIVO", "RED") 
	  
	// Ativação da classe 
	oMark:Activate() 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função de criação do menu de opções da rotina

@author Henrique Makauskas
@since 07/07/2014
@version P12
@param aRot Array com as definições das opções do menu da rotina
@return aRot Retornar o array preenchido com as suas definições

/*/
//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRot := {}
	
	ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_PESQUISAR 	ACCESS 0 //"Pesquisar"
	ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_VISUALIZAR 	ACCESS 0 //"Visualizar"
	ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_INCLUIR 	ACCESS 0 //"Incluir"
	ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_ALTERAR 	ACCESS 0 //"Alterar"
	ADD OPTION aRot TITLE STR0006 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_EXCLUIR 	ACCESS 0 //"Excluir"
	ADD OPTION aRot TITLE STR0007 ACTION 'WF3SndMsg' 		OPERATION 6 				ACCESS 0 //"Enviar"
	ADD OPTION aRot TITLE STR0008 ACTION 'WF3SndAllMsg' 		OPERATION 7 				ACCESS 0 //"Enviar Todos"
	ADD OPTION aRot TITLE STR0009 ACTION 'WF3RcvMsg' 		OPERATION 8 				ACCESS 0 //"Receber"
	ADD OPTION aRot TITLE STR0010 ACTION 'WF3RcvAllMsg' 		OPERATION 9 				ACCESS 0 //"Receber Todos"

Return aRot

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função de criação da interface

@author Henrique Makauskas
@since 07/07/2014
@version P12
@return oView Objeto da interface da aplicação

/*/
//-------------------------------------------------------------------

Static Function ViewDef

	// Criação do objeto do modelo de dados da Interface
	Local oModel := FWLoadModel("WFC003")
	
	// Criação da estrutura de dados utilizada na interface
	Local oStWF7 := FWFormStruct( 2 , "WF7")	
	Local oView := Nil
	
	// Protocolo configurado no .INI (POP3 ou IMAP)
	Local cProtocol := WFGetProtocol()[2]
	
	// Array de opções para campo WF7_SMTPSE
	Local aSmtpse := {STR0066,STR0067,STR0068}
	
	// Cria o objeto da View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_WF7', oStWF7, 'FORMWF7')
	oView:CreateHorizontalBox('TELA', 100)
	oView:SetOwnerView('VIEW_WF7','TELA')
	
	// Cria os grupos para agrupamentos de campos
	oStWF7:AddGroup( 'CaixaCorreio', STR0030, 'TELA', 2 )
	oStWF7:AddGroup( 'Remetente', STR0034, 'TELA', 1 )
	oStWF7:AddGroup( 'ReceberMensagens', STR0016 + " (" + cProtocol + ")", 'TELA', 2 )
	oStWF7:AddGroup( 'Login', STR0040, 'TELA', 1 )
	oStWF7:AddGroup( 'EnviarMensagens', STR0013, 'TELA', 2 )
	oStWF7:AddGroup( 'Autenticacao', STR0046, 'TELA', 1 ) 
	oStWF7:AddGroup( 'Seguranca', STR0065, 'TELA', 1 )
	
	// Agrupamento  - Caixa de Correio 
	oStWF7:SetProperty( 'WF7_PASTA', MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' ) 
	oStWF7:SetProperty( 'WF7_TEMPO' , MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' ) 
	oStWF7:SetProperty( 'WF7_REMETE', MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' ) 
	oStWF7:SetProperty( 'WF7_ENDERE' , MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' )
	// Sub Grupo - Remetente
	oStWF7:SetProperty( 'WF7_REMETE', MVC_VIEW_GROUP_NUMBER, 'Remetente' ) 
	oStWF7:SetProperty( 'WF7_ENDERE' , MVC_VIEW_GROUP_NUMBER, 'Remetente' ) 
	 
	// Agrupamento  - Receber Mensagens 
	If (cProtocol == "IMAP")		
		oStWF7:SetProperty( 'WF7_IMAPPR', MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' ) 
		oStWF7:SetProperty( 'WF7_IMAPSR' , MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' )
		oStWF7:RemoveField('WF7_POP3SR')
		oStWF7:RemoveField('WF7_POP3PR')			
	Else // Padrão - POP3		
		oStWF7:SetProperty( 'WF7_POP3SR', MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' ) 
		oStWF7:SetProperty( 'WF7_POP3PR' , MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' )		
		oStWF7:RemoveField('WF7_IMAPPR')
		oStWF7:RemoveField('WF7_IMAPSR')	
	End
	oStWF7:SetProperty( 'WF7_CONTA', MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' ) 
	oStWF7:SetProperty( 'WF7_SENHA' , MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' )
	//Sub Grupo - Login
	oStWF7:SetProperty( 'WF7_CONTA', MVC_VIEW_GROUP_NUMBER, 'Login' ) 
	oStWF7:SetProperty( 'WF7_SENHA' , MVC_VIEW_GROUP_NUMBER, 'Login' )
	
	// Agrupamento  - Enviar mensagens
	oStWF7:SetProperty( 'WF7_SMTPSR', MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' ) 
	oStWF7:SetProperty( 'WF7_SMTPPR' , MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' ) 
	oStWF7:SetProperty( 'WF7_AUTUSU', MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' ) 
	oStWF7:SetProperty( 'WF7_AUTSEN' , MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' )
	// Sub Grupo - Autenticação
	oStWF7:SetProperty( 'WF7_AUTUSU', MVC_VIEW_GROUP_NUMBER, 'Autenticacao' ) 
	oStWF7:SetProperty( 'WF7_AUTSEN' , MVC_VIEW_GROUP_NUMBER, 'Autenticacao' )
	// Sub Grupo - Protocolo de Segurança	
	oStWF7:SetProperty( 'WF7_SMTPSE' , MVC_VIEW_GROUP_NUMBER, 'Seguranca' )
	
	// Transformação dos campos de senha e ComboBox	
	oStWF7:SetProperty( 'WF7_SMTPSE' , MVC_VIEW_COMBOBOX, aSmtpse )
	oStWF7:SetProperty( 'WF7_SENHA' , MVC_VIEW_PICT, '@*' )
	oStWF7:SetProperty( 'WF7_AUTSEN' , MVC_VIEW_PICT, '@*' )
		
	//Campos não utilizados
	oStWF7:RemoveField('WF7_DTELEF')
	oStWF7:RemoveField('WF7_MAPISR')
	oStWF7:RemoveField('WF7_MAPIPR')	
	oStWF7:RemoveField('WF7_TCONEX')
	oStWF7:RemoveField('WF7_DNOME')
	oStWF7:RemoveField('WF7_DCONTA')
	oStWF7:RemoveField('WF7_DSENHA')
	oStWF7:RemoveField('WF7_SSL')

Return oView

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função de criação do modelo de dados

@author Henrique Makauskas
@since 07/07/2014
@version P12
@param aRot Array com as definições das opções do menu da rotina
@return oModel Objeto da interface da aplicação

/*/
//-------------------------------------------------------------------

Static Function ModelDef

	// Criação do objeto do modelo de dados
	Local oStWF7 := FWFormStruct( 1 , 'WF7')
	Local oModel := Nil
	
	oModel:=MPFormModel():New('WFC003', /*Bloco Pre*/, /*Bloco Pos*/, /*Bloco Commit*/)
	oModel:AddFields('FORMWF7',/*cOwner*/, oStWF7 )
	oModel:SetDescription(STR0001)
	oModel:GetModel('FORMWF7'):SetDescription(STR0001)

Return oModel

/******************************************************************************
	
******************************************************************************/

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3SndMsg

Envia todas as mensagens criadas e que estao na caixa de saida (OUTBOX)
referida conta em que o curso do browser esta posicionado atualmente.

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3SndMsg()

	Local cMsg := STR0012 //'Deseja enviar mensagens da caixa de correio "%c"?'
	
	If MsgYesNo( FormatStr( cMsg, Upper( AllTrim( WF7->WF7_PASTA ) ) ), STR0013 ) //"Enviar mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFSndMsg", { cEmpAnt, cFilAnt, AllTrim( WF7->WF7_PASTA ), .T. } } )
	End
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3SndAllMsg

Envia todas as mensagens criadas e que estao na caixa de saida (OUTBOX)
referida conta em que o curso do browser esta posicionado atualmente.

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3SndAllMsg()
	
	Local cMsg := STR0014 //"Deseja enviar mensagens para todas as caixas de correio?"
	
	If MsgYesNo( cMsg, STR0013 ) //"Enviar mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFSndMsgAll", { cEmpAnt, cFilAnt } } )
	End
		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3RcvMsg

Envia todas as mensagens criadas e que estao na caixa de saida (OUTBOX)
referida conta em que o curso do browser esta posicionado atualmente.

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3RcvMsg()

	Local cMsg := STR0015 //'Deseja receber mensagens da caixa de correio "%c"?'
	
	If MsgYesNo( FormatStr( cMsg, Upper( AllTrim( WF7->WF7_PASTA ) ) ), STR0016 ) //"Receber mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFRcvMsg", { cEmpAnt, cFilAnt, AllTrim( WF7->WF7_PASTA ), .T. } } )
	End
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3RcvAllMsg

Recebe as mensagens de todas as conta cadastradas

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3RcvAllMsg()
	
	local cMsg := STR0017 //"Deseja receber mensagens para todas as caixas de correio?"
	
	If MsgYesNo( cMsg, STR0016 ) //"Receber mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFRcvMsgAll", { cEmpAnt, cFilAnt } } )
	End
	
Return