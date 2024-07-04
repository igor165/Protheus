#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE "CRM980EventDEF.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDef
Classe responsável pelo evento das regras de negócio da 
localização Padrão.

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
	// Bloco com regras de negócio antes da transação do modelo de dados.
	//--------------------------------------------------------------------
	Method BeforeTTS()
	
	//---------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//---------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de negócio depois transação do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
		
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEF
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
genéricas do cadastro antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

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
		// Se não for processamento pelo EAI (Mensagem Unica) não permite alterar os dados do cliente.
		//------------------------------------------------------------------------------------------------
		If !IsInCallStack("FWUMESSAGE") .And. oMdlSA1:GetValue("A1_ORIGEM") == "S1" .And. lVldInt
			Help(" ",1,"INTEGDEF",,STR0001+ oMdlSA1:GetValue("A1_ORIGEM"),3,0) //"Alteração não permitida, registro proveniente da integracao do "
			lValid := .F.
		EndIf
	EndIf

	If ( lValid .And. nOperation == MODEL_OPERATION_DELETE )
		
		//------------------------------------------------------------------------------------------------
		// Se não for processamento pelo EAI (Mensagem Unica) não permite alterar os dados do cliente.
		//------------------------------------------------------------------------------------------------
		If !IsInCallStack("FWUMESSAGE") .And. oMdlSA1:GetValue("A1_ORIGEM") == "S1" .And. lVldInt
			Help(" ",1,"INTEGDEF",,STR0002+ oMdlSA1:GetValue("A1_ORIGEM"),3,0) //"Exclusão não permitida, registro proveniente da integracao do "
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
						Help("",1,"SAVALCLI",, STR0003 + SA1->A1_COD + STR0004 + SA1->A1_LOJA, 4, 11 ) //"Código: " / " - Loja: "
						lValid := .F.	
					EndIf	
				
				EndIf
				
			EndIf
			
		EndIf 
					
	EndIf
	//---------------------------------------------------------------
	// Valida se o código de Cliente e Loja existe
	//---------------------------------------------------------------
	If ( lValid .And. nOperation == MODEL_OPERATION_INSERT .And.;
		!Empty(oMdlSA1:GetValue("A1_COD")) .And. !Empty(oMdlSA1:GetValue("A1_LOJA")) .And.;
		!ExistChav("SA1",oMdlSA1:GetValue("A1_COD")+oMdlSA1:GetValue("A1_LOJA"),,"EXISTCLI") )
		lValid := .F.
	EndIf 

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
Método responsável por executar regras de negócio genéricas do 
cadastro antes da transação do modelo de dados.

@type 		Método

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
			// Se deixa pra fazer depois de gravar, não tem como pegar os valores que estavam
			// nos campos antes da alteração
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
Método responsável por executar regras de negócio genéricas do
cadastro dentro da transação do modelo de dados.

@type 		Método

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
		// Exclui a amarração com os contatos.
		//--------------------------------------------------------------
		FtContato("SA1",SA1->( Recno() ),2,,3) 
		
		//--------------------------------------------------------------
		// Exclui a amarração com os conhecimentos.
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
Método responsável por executar regras de negócio genéricas do
cadastro depois da transação do modelo de dados.

@type 		Método

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
		cMessagem := STR0005 + SA1->A1_COD + "/" + SA1->A1_LOJA + Chr(13) + Chr(10) + STR0006 + SA1->A1_NOME + Chr(13) + Chr(10) + STR0007 + UsrFullName() + "." //"Inclusão do cliente de Código / Loja: "/"Razão Social: "/"Incluído no sistema pelo usuário:" / "Inclusão de cliente"
		FATPDLogUser('AFTERTTS')	// Log de Acesso LGPD
		EventInsert(FW_EV_CHANEL_ENVIRONMENT,FW_EV_CATEGORY_MODULES,cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0008,cMessagem,.T./*lPublic*/)	
	EndIf
Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

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
    Função que verifica se a melhoria de Dados Protegidos existe.

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
