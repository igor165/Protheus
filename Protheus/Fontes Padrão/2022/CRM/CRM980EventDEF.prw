#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE "CRM980EventDEF.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDef
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Padr�o.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEF From FwModelEvent 

	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model. 
	//---------------------
	Method ModelPosVld()
	
	//--------------------------------------------------------------------
	// Bloco com regras de neg�cio antes da transa��o do modelo de dados.
	//--------------------------------------------------------------------
	Method BeforeTTS()
	
	//---------------------------------------------------------------------
	// Bloco com regras de neg�cio dentro da transa��o do modelo de dados.
	//---------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de neg�cio depois transa��o do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
		
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEF
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar as valida��es das regras de neg�cio
gen�ricas do cadastro antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEF
	Local lValid 		:= .T.
	Local lMT030Int  	:= ExistBlock("MT030INT")
	Local lVldInt		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local cAliasTrf		:= ""
	Local cFilTrf		:= ""
	
	If lMT030Int
		lVldInt := Execblock("MT030INT",.F.,.T.)
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE  
		//------------------------------------------------------------------------------------------------
		// Se n�o for processamento pelo EAI (Mensagem Unica) n�o permite alterar os dados do cliente.
		//------------------------------------------------------------------------------------------------
		If !IsInCallStack("FWUMESSAGE") .And. oMdlSA1:GetValue("A1_ORIGEM") == "S1" .And. lVldInt
			Help(" ",1,"INTEGDEF",,STR0001+ oMdlSA1:GetValue("A1_ORIGEM"),3,0) //"Altera��o n�o permitida, registro proveniente da integracao do "
			lValid := .F.
		EndIf
	EndIf

	If ( lValid .And. nOperation == MODEL_OPERATION_DELETE )
		
		//------------------------------------------------------------------------------------------------
		// Se n�o for processamento pelo EAI (Mensagem Unica) n�o permite alterar os dados do cliente.
		//------------------------------------------------------------------------------------------------
		If !IsInCallStack("FWUMESSAGE") .And. oMdlSA1:GetValue("A1_ORIGEM") == "S1" .And. lVldInt
			Help(" ",1,"INTEGDEF",,STR0002+ oMdlSA1:GetValue("A1_ORIGEM"),3,0) //"Exclus�o n�o permitida, registro proveniente da integracao do "
			lValid := .F.
		EndIf
		
	EndIf 
	
	If ( lValid .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
		
		//---------------------------------------------------------------
		// Validacao do campo A1_FILTRF.(UPDEST39) 
		// Verificar se a filial informada neste campo existe realmente.
		//---------------------------------------------------------------
		If lValid .And. UsaFilTrf()
			
			cFilTrf := oMdlSA1:GetValue("A1_FILTRF")
		
			If !Empty(cFilTrf)
				
				//---------------------------------------------------------------
				// Valida se a filial informada existe realmente   
				//---------------------------------------------------------------
				lValid := MtValidFil(cEmpAnt+cFilTrf)
				
				//---------------------------------------------------------------------
				// Verificar se nao existe outro cliente com a mesma filial associada.   
				//---------------------------------------------------------------------
				If lValid	
					
					cAliasTrf := GetNextAlias()
					
					BeginSql Alias cAliasTrf
						
						SELECT A1_FILTRF
							FROM %Table:SA1% SA1
								WHERE
									SA1.A1_FILIAL = %xFilial:SA1% AND 
									SA1.A1_FILTRF = %Exp:cFilTrf% AND
									SA1.%NotDel%
										
					EndSql
					
					If ( (cAliasTrf)->(!Eof()) .And. ( SA1->A1_COD <> M->A1_COD ) )
						Help("",1,"SAVALCLI",, STR0003 + SA1->A1_COD + STR0004 + SA1->A1_LOJA, 4, 11 ) //"C�digo: " / " - Loja: "
						lValid := .F.	
					EndIf	
				
				EndIf
				
			EndIf
			
		EndIf 
					
	EndIf
	//---------------------------------------------------------------
	// Valida se o c�digo de Cliente e Loja existe
	//---------------------------------------------------------------
	If ( lValid .And. nOperation == MODEL_OPERATION_INSERT .And.;
		!Empty(oMdlSA1:GetValue("A1_COD")) .And. !Empty(oMdlSA1:GetValue("A1_LOJA")) .And.;
		!ExistChav("SA1",oMdlSA1:GetValue("A1_COD")+oMdlSA1:GetValue("A1_LOJA"),,"EXISTCLI") )
		lValid := .F.
	EndIf 

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
M�todo respons�vel por executar regras de neg�cio gen�ricas do 
cadastro antes da transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		25/05/2017 
/*/
//-------------------------------------------------------------------
Method BeforeTTS(oModel,cID) Class CRM980EventDEF
	Local lHistTab  	:= SuperGetMv("MV_HISTTAB",,.F.)
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local oStructSA1	:= oMdlSA1:GetStruct()
	Local dDataAlt 	:= Date()
	Local cHoraAlt 	:= Time()
	Local cFilialAIF	:= xFilial("AIF")
	Local cFilialSA1	:= xFilial("SA1")
	Local cCodigo		:= oMdlSA1:GetValue("A1_COD")
	Local cLoja		:= oMdlSA1:GetValue("A1_LOJA")
	Local aFields 	:= oStructSA1:GetFields()
	Local nOperation	:= oModel:GetOperation()
	Local nX			:= 0			
	
	If nOperation == MODEL_OPERATION_UPDATE	
		
		
		If lHistTab
			//--------------------------------------------------------------------------------
			// Cria o historico das alteracoes antes de gravar os novos dados do cliente.
			// Se deixa pra fazer depois de gravar, n�o tem como pegar os valores que estavam
			// nos campos antes da altera��o
			//--------------------------------------------------------------------------------	
			For nX := 1 To Len( aFields )
				If oMdlSA1:IsFieldUpdated( aFields[nX][MODEL_FIELD_IDFIELD] )
					MSGrvHist(cFilialAIF										,;			// Filial de AIF
					          cFilialSA1										,;			// Filial da tabela SA1
					          "SA1"											,;			// Tabela SA1
					          cCodigo											,;			// Codigo do cliente
					          cLoja											,;			// Loja do cliente
					          aFields[nX][MODEL_FIELD_IDFIELD]			,;			// Campo alterado
					          SA1->&(aFields[nX][MODEL_FIELD_IDFIELD])	,;			// Conteudo antes da alteracao
					          dDataAlt										,;			// Data da alteracao
					          cHoraAlt)													// Hora da alteracao	
				EndIf
			Next nX
		EndIf
		
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo respons�vel por executar regras de neg�cio gen�ricas do
cadastro dentro da transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEF
	
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_DELETE 
	
		//--------------------------------------------------------------
		// Exclui a amarra��o com os contatos.
		//--------------------------------------------------------------
		FtContato("SA1",SA1->( Recno() ),2,,3) 
		
		//--------------------------------------------------------------
		// Exclui a amarra��o com os conhecimentos.
		//--------------------------------------------------------------
		MsDocument("SA1",SA1->( RecNo() ),2,,3) 
		
		//--------------------------------------------------------------
		// Exclui a regra da Margem Minima.
		//--------------------------------------------------------------
		FT101Exc(SA1->A1_COD,SA1->A1_LOJA)
	EndIf 
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
M�todo respons�vel por executar regras de neg�cio gen�ricas do
cadastro depois da transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel,cID) Class CRM980EventDEF
	Local cEventID	:= ""
	Local cMessagem	:= ""
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		//--------------------------------------------------------------
		// Event Viewer - Envia e-mail ou RSS na inclusao de clientes.
		//--------------------------------------------------------------
		cEventID  := "032" //Inclusao de cliente
		cMessagem := STR0005 + SA1->A1_COD + "/" + SA1->A1_LOJA + Chr(13) + Chr(10) + STR0006 + SA1->A1_NOME + Chr(13) + Chr(10) + STR0007 + UsrFullName() + "." //"Inclus�o do cliente de C�digo / Loja: "/"Raz�o Social: "/"Inclu�do no sistema pelo usu�rio:" / "Inclus�o de cliente"
		FATPDLogUser('AFTERTTS')	// Log de Acesso LGPD
		EventInsert(FW_EV_CHANEL_ENVIRONMENT,FW_EV_CATEGORY_MODULES,cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0008,cMessagem,.T./*lPublic*/)	
	EndIf
Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa��es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op��o atribu�da a fun��o em execu��o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
