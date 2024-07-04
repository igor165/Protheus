#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA009.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA009
Cadastro MVC Para cadastrar informações do BLOCO I x Contabilidade para o EDF SPED Contribuições.

@author Diego Dias Godas
@since 22.12.2016
@version P11

/*/
//-------------------------------------------------------------------
Function FISA009()

	Local   oBrowse := Nil		
	
	IF	AliasIndic("F3F")	 	
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("F3F")
		oBrowse:SetDescription(STR0010) // Cadastro Bloco I x Contabilidade do EFD Contribuições		
		oBrowse:SetFilterDefault( "F3F_TPREG=='1'" )  
		If F3F->(FieldPos("F3F_CTB")) > 0
			oBrowse:AddLegend( "F3F_CTB== '1'", "GREEN", STR0033 ) // "Realizou Integra??o com Cont?bil"
			oBrowse:AddLegend( "F3F_CTB<> '1' ", "RED",  STR0034 ) // "Integra??o com Cont?bil pendente""
		EndIF
		oBrowse:Activate()			
	Else
		Help("",1,"Help","Help",STR0001,1,0) // "Tabela F3F não cadastrada no sistema ou campos que precisam de atualizações, execute o compatibilizador U_UPDSIGAFIS !!"
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}		
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA009'	OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA009'	OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA009'	OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA009'	OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'FISA009Ctb()' 	  	OPERATION 3 ACCESS 0 //'Proc.Ctb'			
	ADD OPTION aRotina TITLE STR0009 ACTION 'FISA009Cpy()'   	OPERATION 4 ACCESS 0 //"Copiar" 

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel	:= Nil
	    
	//Criação da estrutura de dados utilizada na interface
	Local oStructPAI		:= FWFormStruct(1, "F3F" ,{|cCampo| COMP11STRU(cCampo,"PAI")})
	Local oStructNETO		:= FWFormStruct(1, "F3F" ,{|cCampo| COMP11STRU(cCampo,"NETO")})
		
	//Instanciando o modelo
	oModel	:=	MPFormModel():New('FISA009MOD',/*Pre-Validacao*/,{|oModel|FSA009VLDA(oModel) },{|oModel|FS009Grava(oModel)}/*Commit*/,/*Cancel*/)	
	
	//Tornando os campos obrigatorios	 
	oStructPAI:SetProperty('F3F_CST'  	, MODEL_FIELD_OBRIGAT, .T. )	
	oStructPAI:SetProperty('F3F_PER' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. IsInCallStack("FISA009Cpy") ) })			
	oStructPAI:SetProperty('F3F_CST' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. IsInCallStack("FISA009Cpy") ) })			
	oStructPAI:SetProperty('F3F_ALQPIS' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. IsInCallStack("FISA009Cpy") ) })			
	oStructPAI:SetProperty('F3F_ALQCOF' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. IsInCallStack("FISA009Cpy") ) })			
	oStructPAI:SetProperty('F3F_NATREC' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. IsInCallStack("FISA009Cpy") ) })				
	
	oStructNETO:SetProperty('F3F_DEBCRE' , MODEL_FIELD_OBRIGAT, .T. )
	oStructNETO:SetProperty('F3F_BLOCOI' , MODEL_FIELD_OBRIGAT, .T. )
	oStructNETO:SetProperty('F3F_CONTA'  , MODEL_FIELD_OBRIGAT, .T. )
	
	//Atribuindo formulários para o modelo
	oModel:AddFields( 'FISA009MOD' ,, oStructPAI )    	
	oModel:AddGrid( 'FISA009NETO', 'FISA009MOD', oStructNETO)//TALVEZ MUDAR AQUI		
	oModel:GetModel( 'FISA009NETO' ):SetUseOldGrid()
	//Fazendo o relacionamento entre o Pai e Neto
	oModel:SetRelation( "FISA009NETO" , { { "F3F_FILIAL" , 'xFilial("F3F")' } , { "F3F_IDPAI" , "F3F_ID" } }, F3F->( IndexKey( 1 ) ) )	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({})		
	oModel:GetModel( 'FISA009NETO' ):SetUniqueLine( { 'F3F_BLOCOI','F3F_CONTA' } )
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(STR0010) //Cadastro Bloco I x Contabilidade do EFD Contribuições
	
	//Setando a descrição do formulário
	oModel:GetModel('FISA009MOD'):SetDescription(STR0011) //Registro I100	
	oModel:GetModel( 'FISA009NETO' ):SetDescription(STR0013) //Registro I300	
	oModel:GetModel( 'FISA009NETO' ):SetMaxLine(9999)//Registro I300	 
		
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	//Criação do objeto do modelo de dados da Interface do Cadastro
	Local oModel     := FWLoadModel( "FISA009" )
	
	//Criação da estrutura de dados utilizada na interface do cadastro	
	Local oStructPAI		:= FWFormStruct(2, "F3F",{|cCampo| COMP11STRU(cCampo,"PAI")})	
	Local oStructNETO		:= FWFormStruct(2, "F3F",{|cCampo| COMP11STRU(cCampo,"NETO")})
	
	//Criando oView como nulo
	Local oView := Nil
	
	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	//Atribuindo formulários para interface	
	oView:AddField( 'VIEW_PAI', oStructPAI, 'FISA009MOD' )	
	oView:AddGrid( 'VIEW_NETO', oStructNETO, 'FISA009NETO' )
	
	//Remove os campos que não irão aparecer	
	oStructPAI:RemoveField( 'F3F_TPREG' )
	oStructPAI:RemoveField( 'F3F_ID' )
		
	//Remove os campos que não irão aparecer	
	oStructNETO:RemoveField( 'F3F_ID' ) 
		
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'SUPERIOR_PAI', 45 )
		
	oView:CreateHorizontalBox( 'INFERIOR_NETO', 55 )
	
	//Colocando título do formulário
    oView:EnableTitleView('VIEW_PAI', STR0014)
    oView:EnableTitleView('VIEW_NETO', STR0015 )
    
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView( 'VIEW_PAI', 'SUPERIOR_PAI' )	
	oView:SetOwnerView( 'VIEW_NETO', 'INFERIOR_NETO' )
	
	//Deixando não editavél PAI
	oStructPAI:SetProperty( 'F3F_BCPIS'  , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_VLRPIS' , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_BCCOF'  , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_VLRCOF' , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_VALOR'  , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_VDEGER' , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_VDEESP' , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_CNATRE' , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_GRPNAT' , MVC_VIEW_CANCHANGE  , .F. )
	oStructPAI:SetProperty( 'F3F_DTFIMN' , MVC_VIEW_CANCHANGE  , .F. )

	//Deixando não editavél NETO
	oStructNETO:SetProperty( 'F3F_VALOR'  , MVC_VIEW_CANCHANGE  , .F. )
	
	//Mudando titulo do campo
	oStructPAI:SetProperty( 'F3F_VALOR'  , MVC_VIEW_TITULO   , 'Valor Fat/Rec' )
		
	oStructNETO:SetProperty( 'F3F_BLOCOI' , MVC_VIEW_LOOKUP  , { || F009ChgF3("F3F_DEBCRE",'FISA009NETO') } )
	
Return oView

//-------------------------------------------------------------------

/*/{Protheus.doc} F009ChgF3
Efetua a troca da consulta padrão do campo F3F_BLOCOI.

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------
Static Function F009ChgF3 (cCmpF3,cModel)
Local	oModel	:= 	FWModelActive()
Local	cF3		:=	""
Local	cGet	:=	oModel:GetValue( cModel , cCmpF3 )

If cGet == "1"
	cF3	:=	"CGE"
Else
	cF3	:=	"CGG"
Endif 

Return cF3

//-------------------------------------------------------------------

/*/{Protheus.doc} COMP11STRU
Controle dos campos de cabeçalho.

@author Diego Dias Godas
@since 21.09.2016
@version P11

/*/
//-------------------------------------------------------------------
Static Function COMP11STRU(cCampo,cTipo)

	Local 	lRet 			:= .T.	
	Local	cItemNETO		:=	""

	cCabecPAI	:= "F3F_PER/F3F_FILIAL/F3F_ID/F3F_TPREG/F3F_CST/F3F_BCPIS/F3F_ALQPIS/F3F_VLRPIS/F3F_BCCOF/F3F_ALQCOF/F3F_VLRCOF/F3F_NATREC/F3F_CNATRE/F3F_GRPNAT/F3F_DTFIMN/F3F_VALOR/F3F_VDEGER/F3F_VDEESP/"
	
	cItemNETO	:=	"F3F_ID/F3F_DEBCRE/F3F_BLOCOI/F3F_CONTA/F3F_VALOR/F3F_INFO/"
	
	If cTipo = "PAI"
		If !AllTrim( cCampo ) + "/" $ cCabecPAI
			lRet := .F.
		EndIf	
	Else
		If !AllTrim( cCampo ) + "/" $ cItemNETO
			lRet := .F.
		EndIf	
	EndIf

Return(lRet)

//-------------------------------------------------------------------

/*/{Protheus.doc} FS009Grava
Grava as informações.

@author Erick G Dias
@since 26/01/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function FS009Grava(oModel)

	Local nX		   	:= 0
	Local nOperation 	:= oModel:GetOperation()	
	Local aHeaderNet 	:= oModel:GetModel('FISA009NETO'):GetOldData()[1]
	Local aColsNeto 	:= oModel:GetModel('FISA009NETO'):GetOldData()[2]
	Local cIDPai		:= ""
	Local cCst 			:= oModel:GetValue ('FISA009MOD',"F3F_CST")
	Local nAlqPis		:= oModel:GetValue ('FISA009MOD',"F3F_ALQPIS")
	Local nAlqCof		:= oModel:GetValue ('FISA009MOD',"F3F_ALQCOF")
	Local cNatRec		:= oModel:GetValue ('FISA009MOD',"F3F_NATREC")
	Local cCNatRe		:= oModel:GetValue ('FISA009MOD',"F3F_CNATRE")
	Local cGrpNat		:= oModel:GetValue ('FISA009MOD',"F3F_GRPNAT")
	Local dDtFimN		:= oModel:GetValue ('FISA009MOD',"F3F_DTFIMN")		
	Local cPer			:= oModel:GetValue ('FISA009MOD',"F3F_PER")			
	Local nID			:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_ID"})
	Local nDebCre		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_DEBCRE"})
	Local nBlocoI		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_BLOCOI"})
	Local nConta		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_CONTA"})	
	Local nInfo			:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_INFO"})		
	Local lRet			:= .T.

	If	nOperation == MODEL_OPERATION_INSERT 	// --- Valida a INCLUSAO ---				
		//---------- 
		//Grava I100
		//----------
		GravaF3F("1","1" ,,, cPer , cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN)										
	
		// Guarda o ID do PAI para gravar no FILHO						
		cIDPai		:= F3F_ID		
				
		//Atualiza posi??es com Header do I300
		nDebCre	:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_DEBCRE"})
		nBlocoI	:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_BLOCOI"})
		nConta	:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_CONTA"})
		nInfo	:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_INFO"})
		
		//--------------------------
		//Grava todos os filhos I300
		//--------------------------
		For nX := 1 to Len(aColsNeto)			
			If !aColsNeto[nX,Len(aColsNeto[Nx])] //Se a linha do grid n?o estiver deletada				
				GravaF3F("1","3" , cIDPai , , cPer , cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN, aColsNeto[nX,nDebCre], aColsNeto[nX,nBlocoI], aColsNeto[nX,nConta], aColsNeto[nX,nInfo])										
			EndIf
			
		Next(nX)  
		
	EndIf	
		
	If	nOperation == 4 // --- Valida a ALTERACAO ---	  	
	  	//----------------------------
		//Atualiza informa??es do I100
		//----------------------------
		GravaF3F("2",,,,cPer, cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN)		

		// Guarda o ID do PAI para gravar no FILHO						
		cIDPai		:= F3F_ID	

		F3F->(dbSetOrder( 4 ))			
			
		nID			:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_ID"})
		nDebCre		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_DEBCRE"})
		nBlocoI		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_BLOCOI"})
		nConta		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_CONTA"})
		nInfo		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_INFO"})
		
		// Gravação I300  
		For nX := 1 to Len(aColsNeto)			
			If !aColsNeto[nX,Len(aColsNeto[Nx])]
				If	F3F->( MsSeek(xFilial('F3F')+aColsNeto[nX,nID],.F.) )						
					//Atualiza I300
					GravaF3F("4",,,,cPer, cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN, aColsNeto[nX,nDebCre], aColsNeto[nX,nBlocoI], aColsNeto[nX,nConta],aColsNeto[nX,nInfo])								
				Else						
					//Inclui I300
					GravaF3F("1","3" , cIDPai ,  , cPer   , cCst   , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN, aColsNeto[nX,nDebCre], aColsNeto[nX,nBlocoI], aColsNeto[nX,nConta], aColsNeto[nX,nInfo])										
				EndIf	
			Else 
				// Exclui I300
				If	F3F->( MsSeek(xFilial('F3F')+aColsNeto[nX,nID],.F.) )
					DeletaF3F()
				EndIf					

			EndIf
			
		Next(nX)
		
	Endif
	F3F->(dbSetOrder( 1 ))			
	If	nOperation == 5 // --- Valida a EXCLUSAO --- 		
		//Exclui I100
		DeletaF3F()
			
		nID		:= Ascan(aHeaderNet,{|x|Alltrim(x[2])=="F3F_ID"})
		
		For nX := 1 to Len(aColsNeto)
			If	F3F->( MsSeek(xFilial('F3F')+cPer+aColsNeto[nX,nID],.F.) )	
				//Excluir I300
				DeletaF3F()
			EndIF	
		Next(nX)
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA009Ctb
Função para realizar a valorização contábil, passando a conta para o retorno
dos movimentos.

@author Diego Dias
@since 22/12/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function FISA009Ctb()
	
	Local cMsg	
	Local cPerg	:= 'FIS009'
	
	cMsg	:= STR0016+CHR(13) //"Consolida??o Cont?bil."
	cMsg	+= STR0017+CHR(13) //'Deseja recalcular o saldo das contas cont?beis para os'
	cMsg	+= STR0018+CHR(13) //'Registros I300 e consolidar os saldos para depois gerar'
	cMsg	+= STR0019 //"o EFD Contribui??es?"
	
	If Pergunte(cPerg)
		
		If Empty(MV_PAR01) .OR. Empty(MV_PAR02)
			Alert(STR0020) //"Dever? ser informada a data inicial e data final de processamento"
		ElseIF MV_PAR02 < MV_PAR01
			Alert(STR0021) //"Data final n?o dever? ser menor que data inicial"
		ElseIF Month(MV_PAR01) <> Month(MV_PAR02) .AND. Year(MV_PAR01) <> Year(MV_PAR02)
			Alert(STR0028) //'M?s inicial diferente do m?s final'
		ElseIF MsgYesNo(cMsg)			
			FwMsgRun(,{|oSay| FProcCtb(oSay) }, STR0022, "") //"Processando saldos cont?bies ..."			
		EndIF

	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FProcCtb
Função para realizar o processamento da valorização contábil

@author Diego Dias
@since 22/12/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function FProcCtb( oSay )
	
	Local nValor		:= 0
	Local cPer			:= strzero(Month(MV_PAR01),2) + strzero(Year(MV_PAR01),4)
	Local cFilF3F		:= xFilial("F3F")
	
	Begin Transaction	
	oSay:cCaption := (STR0030)//"Iniciando processamento..."
	ProcessMessages()
	//---------------------------------------------------------------------------------------------------
	//Chama fun??o para limpar todos os valores da F3F do per?odo antes de fazer integra??o com Cont?bil
	//---------------------------------------------------------------------------------------------------
	ClearF3F(cPer)
	
	dbSelectArea('F3F')
	dbSetOrder(2)
	
	oSay:cCaption := (STR0031)//"Buscando valores das contas cont?beis..."
	ProcessMessages()
	
	If F3F->( MsSeek( xFilial('F3F') + cPer + '3' ,.F.) )	
	
		While !F3F->(EOF()) .AND. F3F->F3F_FILIAL = cFilF3F .AND. F3F->F3F_PER == cPer .AND. F3F->F3F_TPREG == '3'

			nValor	:= ABS( MovConta( F3F->F3F_CONTA, MV_PAR01, MV_PAR02, "01", "1", 3 ) )
			// Efeito: Retorna o movimento do mês para a conta contábil "2101", partindo do primeiro dia do 
			// mês corrente, até o último dia do mês corrente, para a moeda "01", tipo de saldo "1",
			// em qual tipo de saldo: [1] Movimento Devedor / [2] Movimento Credor / 
			// [3] Movimento do Mes / [4] Saldo Final
		
			RecLock('F3F',.F.)
			F3F->F3F_VALOR	:= nValor		
			F3F->(msUnlock())
		
			F3F->(dbSkip())
		EndDo
		
		FISA009Con( .T., cPer, oSay )

	EndIf	
	End Transaction	
	MsgInfo(STR0023) //"Arquivo gerado com sucesso!"		

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA009Con
Função para realizar a consolidação dos registros I100 e I200

@author Diego Dias
@since 22/12/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function FISA009Con( lProc, cPer, oSay)
	
	Local cMsg	
	Default lProc	:= .F.
	
	cMsg	:= STR0024+CHR(13) //'Consolida??o de Saldos.'
	cMsg	+= STR0025+CHR(13) //'Deseja recalcular a valoriza??o dos campos para os Registros'
	cMsg	+= STR0026+CHR(13) //'do tipo I100 e I200 para depois gerar o EFD Contribui??es?'
	
	If lProc .or. MsgYesNo(cMsg) 
		FProcCon( lProc, cPer, oSay )
	EndIf
Return
	
//-------------------------------------------------------------------
/*/{Protheus.doc} FProcCon
Fun??o para realizar o processamento da consolidação dos registros I100 e I200

@author Erick G Dias
@since 26/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------	
Static Function FProcCon(lProc, cPer, oSay)

	Local nX		:= 0
	Local cAliasF3F	:= ''
	Local lF3FCTB	:= F3F->(FieldPos("F3F_CTB")) > 0
	
	Default lProc	:= .F.		
	
	dbSelectArea('F3F')
	F3F->(dbSetOrder( 1 ))	
	
	oSay:cCaption := (STR0029)//"Calculando valores de PIS e COFINS..."
	ProcessMessages()
	//-----------------------------------------------------------------------------------
	//Chama fun??o para fazer query na F3F buscando os itens I300 para totalizar no I100
	//-----------------------------------------------------------------------------------
	cAliasF3F	:= QryF3f(cPer, "1")
	
	While !(cAliasF3F)->(EOF())
		
		If F3F->( MsSeek(xFilial('F3F')+cPer+(cAliasF3F)->F3F_IDPAI,.F.) )
			RecLock('F3F',.F.)
						
			If SubStr( (cAliasF3F)->F3F_BLOCOI,1,1 ) == "D" //Dedu??es/Exclus?es
				
				If SubStr( (cAliasF3F)->F3F_BLOCOI,1,4 ) == "D000" //Exclus?es e Dedu??es de car?ter Geral
					F3F->F3F_VDEGER	+= (cAliasF3F)->F3F_VALOR					
				Else
					F3F->F3F_VDEESP	+=  (cAliasF3F)->F3F_VALOR						
				EndIF

			Else
				F3F->F3F_VALOR	+= (cAliasF3F)->F3F_VALOR //Receita									
			EndIF
			
			F3F->F3F_VLRPIS	:= 0
			F3F->F3F_VLRCOF	:= 0			
			F3F->F3F_BCPIS	:= F3F->( F3F_VALOR - ( F3F_VDEGER+F3F_VDEESP ) )
			F3F->F3F_BCCOF	:= F3F->F3F_BCPIS
			If F3F_BCPIS > 0	
				F3F->F3F_VLRCOF	:= (F3F->F3F_BCCOF *(F3F->F3F_ALQCOF/100))
				F3F->F3F_VLRPIS	:= (F3F->F3F_BCPIS *(F3F->F3F_ALQPIS/100))
			EndIF
			//Grava indicador que processou integra??o com CTB
			If lF3FCTB
				F3F->F3F_CTB:= '1'
			EndIF
			
			F3F->(msUnlock())
		EndIf	
		(cAliasF3F)->( dbSkip() )
	EndDo
	DbSelectArea (cAliasF3F)
	(cAliasF3F)->( DbCloseArea() )
	
	If !lProc
		MsgAlert(STR0023) //'Processamento Finalizado'
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCtbBlcI
Função para retornar a tabela com os dados para geração do BLOCO I
Quando o bloco I for gerado através das contas contabeis, sem integração com financeiro e PLS.

@author Diego Dias
@since 22/12/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function FisCtbBlcI(ddataini,ddatafim,cAlias)

	Local cQuery		:=" "
	Local cPer			:= strzero(Month(ddataini),2) + strzero(Year(ddataini),4)
	
	Default ddataini	:=	ddatabase
	Default ddatafim	:=	ddatabase
	Default cAlias 		:= "TRB"
	
	// Cálculo pelas contas contábeis
	cQuery:=" SELECT F3F_BLOCOI CLASSE, F3F_CONTA CONTA, F3F_INFO INFO, F3F_VALOR VALOR,"	
	cQuery+=" 'XXXXXXXXX' NOTA, 'XXX' SERIE, F3F_CST CSTPIS, 'XXXXXX' CLIENTE,"
	cQuery+=" 'XX' LOJA, F3F_NATREC NATREC, F3F_CNATRE CNATREC, F3F_GRPNAT GRUPONC, F3F_DTFIMN DTFIMNT, "
	cQuery+=" F3F_ALQPIS ALIQPIS, F3F_ALQCOF ALIQCOF  "
	cQuery+=" FROM "+RetSqlName("F3F") + " F3F "
	cQuery+=" WHERE F3F_FILIAL = '" + xFilial("F3F") +  "' AND F3F_PER = '" +  cPer +  "'    AND F3F_TPREG = '3'  AND  "
	cQuery+=" F3F.D_E_L_E_T_= ' '  "
		
	cQuery := ChangeQuery(cQuery)
	
	If Select(cAlias) > 0
		&(cAlias+"->")(dbCloseArea()) 
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF3F
Fun??o que ir? gravar as informa??es na tabela F3F

@author Erick Dias
@since 24/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaF3F(cOp, cTpReg, cIdPai, cIdFil, cPer, cCst, nAlqPis, ;
					   nAlqCof, cNatRec, cCnatRec, cGrpNat, dDtFim, ;
					   cDebCre, cBlocoI, cConta, cInfo)
	
	Local lF3FCTB	:= F3F->(FieldPos("F3F_CTB")) > 0
	Default cIdFil	:= ""
	Default cIdPai	:= ""
	Default cDebCre	:= ""
	Default cBlocoI	:= ""
	Default cConta	:= ""	
	Default cInfo	:= ""	

	If cOp $ '1'//Inclui

		RecLock("F3F",.T.)		
		F3F_FILIAL	:= xFilial("F3F")
		F3F_ID		:= FWUUID("F3F")
		F3F_TPREG   := cTpReg
		F3F_IDPAI 	:= cIdPai
		F3F_IDFIL   := cIdFil
		F3F_PER		:= cPer
		F3F_CST		:= cCst
		F3F_ALQPIS	:= nAlqPis
		F3F_ALQCOF	:= nAlqCof
		F3F_NATREC	:= cNatRec
		F3F_CNATRE	:= cCnatRec
		F3F_GRPNAT	:= cGrpNat
		F3F_DTFIMN	:= dDtFim											
		F3F_DEBCRE	:= cDebCre
		F3F_BLOCOI	:= cBlocoI
		F3F_CONTA	:= cConta											
		F3F_INFO	:= cInfo
		MsUnLock()
	Else 
		
		RecLock("F3F",.F.)			
		F3F_PER 	:=  cPer
		F3F_CST		:=	cCst 
		F3F_ALQPIS	:=	nAlqPis
		F3F_ALQCOF	:=	nAlqCof
		F3F_NATREC	:=	cNatRec
		F3F_CNATRE	:=	cCnatRec
		F3F_GRPNAT	:=	cGrpNat
		F3F_DTFIMN	:=	dDtFim		
		
		//Grava indicador que a integra??o com cont?bil est? pendente, j? que houve altera??o no registro e ? necess?rio integrar novamente
		//V?lido somente para I100
		If cOp == '2' .AND. lF3FCTB		
			F3F->F3F_CTB:= '2'
		EndIF

		If cOp $ '3/4' //Atualiza I200/I300
			F3F_DEBCRE	:= cDebCre
			F3F_BLOCOI	:= cBlocoI
			F3F_CONTA	:= cConta
			
			If cOp == '4' //Atualiza I300													
				F3F_INFO	:= cInfo
			EndIF			
		EndIF
		MsUnLock()
	EndIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeletaF3F
Fun??o que ir? deletar F3F

@author Erick Dias
@since 24/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function DeletaF3F()

	RecLock("F3F",.F.)
	F3F->(dbDelete())
	MsUnLock()

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} QryF3f
Fun??o que far? query na F3F buscando linhas do I300 para consolidar 
no I100

@param		cPer	- String -  Per?odo a ser processado no formato MM/AAAA
		    cOp     - String - Op??o de processamento 

@Return     cAliasF3F - String - Alias com retorno da query executada 			

@author Erick Dias
@since 26/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function QryF3f(cPer, cOp, cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN, cIdPai)

Local cAliasF3F	:= "F3F"
Local cSlctF3F	:= ''
Local cWhere	:= ''
Local cGroupBy	:= ''
Default cIdPai	:= ''

cAliasF3F	:=	GetNextAlias()

If cOp == '1'
	//Processa I300 somado 
	cSlctF3F 	+= '%F3F.F3F_IDPAI, Sum(F3F.F3F_VALOR) as F3F_VALOR , F3F.F3F_BLOCOI%'
	cWhere 		+= "%F3F.F3F_FILIAL = '"+ xFilial('F3F') + "' AND "
	cWhere 		+= "F3F.F3F_PER = '" + cPer + "' AND "	
	cWhere 		+= "F3F.F3F_TPREG = '3' AND%"	
	cGroupBy 	+= "%GROUP BY F3F.F3F_TPREG, F3F.F3F_IDPAI, F3F.F3F_BLOCOI%"		

ElseIf cOp == '2'
	//Traz todas as linhas da F3F do per?odo
	cSlctF3F 	+= '%F3F.F3F_ID%'
	cWhere 		+= "%F3F.F3F_FILIAL = '"+ xFilial('F3F') + "' AND "
	cWhere 		+= "F3F.F3F_PER = '" 	+ cPer + "' AND%"			
	cGroupBy 	+= "%%"		

ElseIf cOp == '3'	 	
	//Verifica se F3F j? existe, chamado da fun??o que valida inclus?o 
	cSlctF3F 	+= '%F3F.F3F_ID%'
	cWhere 		+= "%F3F.F3F_FILIAL = '"	+ xFilial('F3F') 		+ "' AND "
	cWhere 		+= "F3F.F3F_PER = '" 		+ cPer 					+ "' AND "			
	cWhere 		+= "F3F.F3F_CST = '" 		+ cCst 					+ "' AND "			
	cWhere 		+= "F3F.F3F_ALQPIS = "		+ Alltrim(STR(nAlqPis))	+ " AND "
	cWhere 		+= "F3F.F3F_ALQCOF = " 		+ Alltrim(STR(nAlqCof))	+ " AND "
	cWhere 		+= "F3F.F3F_NATREC = '" 	+ cNatRec 				+ "' AND "
	cWhere 		+= "F3F.F3F_CNATRE = '" 	+ cCNatRe 				+ "' AND "
	cWhere 		+= "F3F.F3F_GRPNAT = '" 	+ cGrpNat 				+ "' AND "
	cWhere 		+= "F3F.F3F_DTFIMN = '" 	+ dTos( dDtFimN ) 		+ "' AND%"
	cGroupBy 	+= "%%"		

ElseIf cOp == '4'	 
	//Traz todos filhos do I110 espec?fico
	cSlctF3F 	+= '%F3F.*%'
	cWhere 		+= "%F3F.F3F_FILIAL = '"+ xFilial('F3F') + "' AND "
	cWhere 		+= "F3F.F3F_PER = '" + cPer + "' AND "	
	cWhere 		+= "F3F.F3F_TPREG = '3' AND "	
	cWhere 		+= "F3F.F3F_IDPAI = '" + cIdPai  + "' AND%"	
	cGroupBy 	+= "%%"		
EndIF

BeginSql Alias cAliasF3F	
	SELECT			    
		%Exp:cSlctF3F%
	FROM 
		%Table:F3F% F3F
	WHERE
		%Exp:cWhere%
		F3F.%NotDel%
		%Exp:cGroupBy%
EndSql

Return cAliasF3F 

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearF3F
Fun??o que ir? limpar os valores da tabela F3F antes de fazer a integra??o
com o cont?bil, limpando todos os valores do per?odo, para que sempre seja
refeito.

@param		cPer	- String -  Per?odo a ser processado no formato MM/AAAA

@author Erick Dias
@since 26/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ClearF3F(cPer)

Local cAliasF3F	:= QryF3f(cPer, "2")

While !(cAliasF3F)->(EOF())
		
	If F3F->( MsSeek(xFilial('F3F')+cPer+(cAliasF3F)->F3F_ID,.F.) )
		RecLock('F3F',.F.)
		
		F3F->F3F_VALOR 	:= 0
		F3F->F3F_BCPIS 	:= 0
		F3F->F3F_BCCOF 	:= 0
		F3F->F3F_VLRPIS := 0
		F3F->F3F_VLRCOF := 0
		F3F->F3F_VDEESP := 0
		F3F->F3F_VDEGER := 0

		F3F->(msUnlock())
	EndIf	
	(cAliasF3F)->( dbSkip() )
EndDo	
	
(cAliasF3F)->( DbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkAddF3F
Fun??o que verifica se j? existe I100 gravado. Utilizada na valida??o 
de inclus?o.

@author Erick Dias
@since 26/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ChkAddF3F(cPer , cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN)

Local cAliasF3F	:= QryF3f(cPer, '3' , cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN)
Local lRet		:= .T.
While !(cAliasF3F)->(EOF())
	//Se existe informa??o j? gravada ir? exibir mensagem para usu?rio
	lRet:= .F.	
	Exit
EndDo	
	
(cAliasF3F)->( DbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA009VLDC
Fun??o de valida??o do c?digo de receita ou dedu??o

@author Erick Dias
@since 26/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FSA009VLDC()

Local cAlias:= ''
Local lRet	:= .F.

IF GDFieldGet("F3F_DEBCRE") == '1' //Receita
	cAlias	:= 'CGE'
ElseIF GDFieldGet("F3F_DEBCRE") == '2' //Dedu??o
	cAlias	:= 'CGG'
EndIF

//Verifica se c?digo existe
If ExistCpo(cAlias,M->F3F_BLOCOI,1) .AND. Len(Alltrim(M->F3F_BLOCOI)) == 8
	lRet	:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA009VLDA
Fun??o que realiza as valida??es de cadastros, das al?quotas, 
c?digoa da receita da natureza e duplicidade de I100

@author Erick Dias
@since 26/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FSA009VLDA(oModel) 

Local nOperation 	:= oModel:GetOperation()
Local cCst 			:= oModel:GetValue ('FISA009MOD',"F3F_CST")
Local nAlqPis		:= oModel:GetValue ('FISA009MOD',"F3F_ALQPIS")
Local nAlqCof		:= oModel:GetValue ('FISA009MOD',"F3F_ALQCOF")
Local cNatRec		:= oModel:GetValue ('FISA009MOD',"F3F_NATREC")
Local cCNatRe		:= oModel:GetValue ('FISA009MOD',"F3F_CNATRE")
Local cPer			:= oModel:GetValue ('FISA009MOD',"F3F_PER")			
Local cGrpNat		:= oModel:GetValue ('FISA009MOD',"F3F_GRPNAT")
Local dDtFimN		:= oModel:GetValue ('FISA009MOD',"F3F_DTFIMN")		
Local lRet			  := .T.

IF ( cCst $ "01/02/03" .OR. ( cCst == "05" .AND. Empty( cCNatRe ) .AND. Empty( cNatRec ) ) ) 
	//Opera??o tributada
	//Se utilizar CST tributado, ent?o al?quota ser? obrigat?ria.
	//O CST 05 permite opera??es tributadas quanto n?o tributadas al?quota zero.
	//Se utilizar CST 05 sem informa??es da natureza da receita justificando irei exigir al?quota.
	If  nAlqPis == 0 .OR. nAlqCof == 0
		lRet	:= .F.
		Help( ,, 'Help',, STR0035, 1, 0 ) //'Para o CST utilizado ? necess?rio informar as al?quotas de PIS e COFINS'
	EndIF

Else
	//Opera??o N?o tributada
	//Para opera??es n?o tributadas dever?o ser informadas a tabela e c?digo da receita da natureza
	If Empty( cCNatRe ) .AND. Empty( cNatRec )
		lRet	:= .F.
		Help( ,, 'Help',, STR0036, 1, 0 ) //'Para o CST utilizado ? necess?rio informar a Tabela e C?digo da Receita da Natureza'
	EndIF

EndIF

//Verifica na inclus?o se I100 j? foi gravado
If lRet .AND.  nOperation == MODEL_OPERATION_INSERT    .AND. !ChkAddF3F(cPer , cCst , nAlqPis, nAlqCof , cNatRec, cCNatRe, cGrpNat, dDtFimN)
	lRet	:= .F.
	Help( ,, 'Help',, STR0032, 1, 0 )//"Combina??o de Per?odo, CST, Al?quota de PIS e COFINS e Informa??es da Natureza da Receita j? cadastrados!"			
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA009Cpy
Fun??o que realiza a c?pia da estrutura do bloco I

@author Erick Dias
@since 29/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA009Cpy()

Local cAliasF3F		:= ''
Local cIdDestino	:= ''
Local cPer			:= F3F->F3F_PER
Local lProc			:= .F.
Local nRet 			:= 0

//Inicia Transa??o
Begin Transaction	

//----------------------------------------------------
//Traz todos os filhos do registro selecionado na tela
//----------------------------------------------------
cAliasF3F	:= QryF3f(F3F->F3F_PER, "4", F3F->F3F_CST , F3F->F3F_ALQPIS, F3F->F3F_ALQCOF , F3F->F3F_NATREC, F3F->F3F_CNATRE, F3F->F3F_GRPNAT, F3F->F3F_DTFIMN, F3F->F3F_ID)
TcSetField(cAliasF3F,"F3F_DTFIMN","D",8,0)

//----------------------------------------------------
//Adiciona c?pia do I100
//----------------------------------------------------
GravaF3F("1","1" ,,, cPer , F3F->F3F_CST , F3F->F3F_ALQPIS, F3F->F3F_ALQCOF , F3F->F3F_NATREC, F3F->F3F_CNATRE,  F3F->F3F_GRPNAT, F3F->F3F_DTFIMN)

//----------------------------------------------------
// Guarda o ID do PAI para gravar no FILHO						
//----------------------------------------------------
cIdDestino		:= F3F_ID			

While !(cAliasF3F)->(EOF())
	
	//----------------------------------------------------
	//Realiza c?pia de todos os filhos
	//----------------------------------------------------
	lProc	:= .T.
	GravaF3F("1","3" , cIdDestino , , cPer , (cAliasF3F)->F3F_CST , (cAliasF3F)->F3F_ALQPIS, (cAliasF3F)->F3F_ALQCOF , (cAliasF3F)->F3F_NATREC, (cAliasF3F)->F3F_CNATRE, ;
	(cAliasF3F)->F3F_GRPNAT, (cAliasF3F)->F3F_DTFIMN, (cAliasF3F)->F3F_DEBCRE, (cAliasF3F)->F3F_BLOCOI, (cAliasF3F)->F3F_CONTA, (cAliasF3F)->F3F_INFO)										
	
	(cAliasF3F)->( dbSkip() )
EndDo

(cAliasF3F)->( DbCloseArea() )	

//------------------------------------------------------------------
//Se processou a c?pia ent?o ser? exibida a tela para usu?rio editar
//------------------------------------------------------------------
If lProc	
	
	If F3F->( MsSeek(xFilial('F3F')+cPer+cIdDestino,.F.) )

		nRet	:= FWExecView('Filial: ' + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA009', MODEL_OPERATION_UPDATE ,, { || .T. } , ) 	
					//FWExecView('Filial: ' + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA002', MODEL_OPERATION_UPDATE,, { || .T. }, { || ASA001GDUP() }) 	

		IF nRet <> 0			
			//------------------------------------------------------------------
			//usuário n?o confirmou opera??o irei desfazer todas as c?pias
			//------------------------------------------------------------------
			DisarmTransaction()
		EndIF

	EndIF
EndIF

End Transaction	

Return
