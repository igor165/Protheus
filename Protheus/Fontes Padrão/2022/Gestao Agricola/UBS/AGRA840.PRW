#INCLUDE "PROTHEUS.CH"
#INCLUDE "AGRA840.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE _CRLF CHR(13)+CHR(10)

Static oArqTemp := Nil

/*
############################################################################
# Função   : AGRA840                                                       #
# Descrição: Cadastramento de lotes   ( Refeito )                          #
# Data     : 12/08/2014                                                    #  
############################################################################
*/
Function AGRA840(cLote,cTipoP)
	Local aArea 		:= GetArea()
	Local vVetTSB8		:=	{{"B8_PRODUTO"},{"B8_LOCAL"},{"B8_LOTECTL"},{"B8_EMPENHO"},{"B8_SALDO"},{"B8_QTDORI"},{"BF_LOCALIZ"},;
		{"BC_QUANT"},{"BC_TIPO"},{"BC_MOTIVO"}}
	//  transferir para o UPDNP9
	Local   cPerg250	:= AGRGRUPSX1("MTA250")

	Private cPergF11 	:= AGRGRUPSX1("AGRA840F11")
	Private nTamDSG1	:= AGRSEEKDIC("SX3","G1_DESC  ",2,"X3_TAMANHO")
	Private cComponP 	:= AGRINICIAVAR("G1_COMP",.T.)	//Inicializa uma variável de acordo com o dicionário de dados e/ou da base de dados
	Private cLocalA		:= Space(2)
	Private cLoteTSI	:= cLote
	Private cTipoPro	:= cTipoP
	Private cTm		  	:= GetMv("MV_AGRTMPS")
	Private cLocalPR	:= SubStr(GetMv("MV_LOCPROC"),1,Len(SB8->B8_LOCAL))
	Private cReutOp		:= GetMv("MV_AGRREOP")
	Private cNumOp3   	:= AGRINICIAVAR("D3_OP",.T.)		// Inicializa uma variável de acordo com o dicionário de dados e/ou da base de dados
	Private cNumOp2   	:= AGRINICIAVAR("C2_NUM",.T.)	// Inicializa uma variável de acordo com o dicionário de dados e/ou da base de dados
	Private cCustoS		:= AGRINICIAVAR("B1_CC",.T.)		// Inicializa uma variável de acordo com o dicionário de dados e/ou da base de dados
	Private cLocalO		:= AGRINICIAVAR("C2_LOCAL",.T.)	// Inicializa uma variável de acordo com o dicionário de dados e/ou da base de dados
	Private l185 		:= .f.,lF11 := .t.,lConsTerc := .f.,lParaSa := .t.,lEmpPrev	:= .F.	// Sempre considerar saldo fisico e não em empenho
	Private aEstrSG1	:= {},aMatNEdi := {},aItePe := {}
	Private lNovaOp,lFechOp,lGerouOp
	Private cMovent,cMovsai,cStaTSI,cChavSB8,cProdNP9,cLoteOri
	Private oStruSG1,oStruSB8,oStruNP9,oView,oModel,l241 :=.T.
	Private M->NP9_PROD := CriaVar("B1_COD")
	Private aRetIN := {}
	Private cIni := ""
	
	Store .t. To lNovaOp,lFechOp,lGerouOp

	If !AGRIFDICIONA("SX3","D3_CODSAF",2,.F.) 	//*Verifica se o registro existe no dicionário de dados
		AGRINCOMDIC("U_UPDSD3",,.T.)			//*Mensagem de incompatibilidade do dicionário de dados
		Return
	EndIf

	PERGUNTE(cPerg250,.f.)
	lConsTerc := If(MV_PAR07 = 1,.T.,.F.)
	cMoveAP	  := Alltrim(GetMv("MV_AGRTMPS"))
	cMovsAx   := Alltrim(GetMv("MV_AGRSD3S"))
	cMovsai	  := cMovsAx+Space(Len(SF5->F5_CODIGO)-Len(cMovsAx))

	If Empty(cMovsai) .Or. Empty(cMoveAP)
		Alert(STR0085+" MV_AGRSD3S,MV_AGRTMPS "+STR0086)
		Return
	EndIf

	AGRQUEBRAFIL("SF5")
	If !Dbseek(FwxFilial("SF5")+cMovsai) .Or. cMovsai < "500"
		lParaSa := .f.
	Else
		cValoriz := SF5->F5_VAL
	EndIf

	If !lParaSa
		Alert("TM "+STR0092+"  "+cMovsai)
		Return
	EndIf

	If !Empty(cValoriz) .And. cValoriz = "S"
		Alert("TM "+cMovsai+"  "+STR0088+" "+STR0105)
		Return
	EndIf

	SetKey(VK_F12,{|| MTA840PERG()}) // Ativa tecla 12 para acionar perguntas MATA240
	SetKey(VK_F11,{|| AGRA840F11()}) // Ativa tecla 11 para acionar perguntas LOTE

	vRet := AGRCRIATRB(,vVetTSB8,{"B8_PRODUTO","B8_PRODUTO+B8_LOTECTL","B8_PRODUTO+B8_LOCAL+BF_LOCALIZ",;
		"B8_PRODUTO+B8_LOCAL+BF_LOCALIZ+B8_LOTECTL"},"AGR840",.T.)
	cNoT := vRet[3]
	cAlT := vRet[4]

	If cLote = Nil
		oBrowse := FWMBrowse():New() // Instancia o objeto Browse
		oBrowse:SetAlias('NP9')
		oBrowse:SetDescription( STR0001 )

		// Legendas
		AGRLEGEBROW(@oBrowse,{{"NP9_STATUS = '1'",STR0008,"RED"},{"NP9_STATUS = '2'",STR0009,"GREEN"},;
			{"NP9_STATUS = '3'",STR0010,"BLACK"}})
		oBrowse:Activate() // Ativa o Browse
	Else
		FWExecView(If(Empty(cTipoP),STR0080,If(cTipoP = "PRO",STR0152,STR0153)),'VIEWDEF.AGRA840',MODEL_OPERATION_INSERT,,{|| .T. })
	EndIf
	If file(cAlt)
		AGRDELETRB(cAlT,cNoT)
	EndIf
	SetKey(VK_F12,Nil)
	SetKey(VK_F11,Nil)
	RestArea(aArea)
Return()

/*
############################################################################
# Função   : ModelDef                                                      #
# Descrição: Definição da ModelDef                                         #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 12/08/2014                                                    #  
############################################################################
*/
Static Function ModelDef()
	Local vVetCOBR   := AGRSX3OBR("SB8"),nx
	Local cCampNao   := "NP9_FILIAL|NP9_QTD2UM|NP9_DOCD3|NP9_FORMUL|NP9_OP|NP9_DOC|NP9_SERIE|NP9_FORNEC|NP9_LOJA"
	Local vVetNOBR 	 :=	{"B8_PRODUTO","B8_DATA","B8_LOTEFOR","B8_NUMLOTE","B8_DTVALID","B8_EMPENHO","B8_EMPENH2","B8_ORIGEM"}
	Local vVetNSG1	 :=	{"G1_COMP","G1_DESC","G1_QUANT","G1_PERDA","G1_FIXVAR"}
	Local vVetNSB8 	 :=	{"B8_LOCAL","B8_LOTECTL","B8_EMPENHO","B8_SALDO","B8_QTDORI"}
	Default cPergF11 := AGRGRUPSX1("AGRA840F11")
	Private vVetCamp := {} // Variavel utilizada nos pontos de entradas
	Private vVetEdit := {} // Variavel utilizada nos pontos de entradas

	IF TYPE("CTIPOPRO") <> "C" .AND. IsBlind() //verificação isblind devido aos debitos tecnicos
		Default CTIPOPRO := nil
	EndIf
	If TYPE("CLOTETSI") <> "C" .AND. IsBlind() //verificação isblind devido aos debitos tecnicos
		Default CLOTETSI := nil
	EndIf

	oStruNP9 := FwFormStruct(1,"NP9")//Lote
	oStruSG1 := FwFormStruct(1,"SG1")//Estrutura do produto
	oStruSB8 := FwFormStruct(1,"SB8")//Saldo em lote

	oModel := MpFormModel():New('AGRA840',,{ |oModel| AGR840POS(oModel)},{ |oModel| AGR840GRV(oModel)},{||AGR840CAN()}) // Cria o objeto do Modelo de Dados
	oModel:SetDescription(STR0001)

	// Altera a propriedade do X3_OBRIGAT
	If !Empty(vVetCOBR)
		AGROBRIGMVC(@oStruSB8,vVetNOBR)
	EndIf

	// Altera a propriedade do X3_VALID
	AGRVALIDMVC(@oStruSG1,vVetNSG1)
	AGRVALIDMVC(@oStruSB8,vVetNSB8)

	oStruSB8:SetProperty("B8_QTDORI",MODEL_FIELD_VALID,{|| AGRRETTRUE()})

	// Cabeçalho objeto do Modelo de Dados
	oModel:AddFields('CABEC',,oStruNP9)
	oModel:GetModel("CABEC"):SetDescription(STR0007)

	// Adiciona a estrutura da Grid
	oModel:AddGrid('ITEM','CABEC',oStruSG1,,{|| AGRRETTRUE()})
	oModel:GetModel("ITEM"):SetDescription(STR0040)

	AGRCAMPDEF(oStruSG1,{{STR0041					,STR0042,'B2_QATU','N',TAMSX3('B2_QATU')[1],TAMSX3('B2_QATU')[2]},;
		{AGRTITULO("D3_LOCALIZ")	,AGRTITULO("D3_LOCALIZ"),'D3_LOCALIZ','C',TAMSX3('D3_LOCALIZ')[1]},;
		{AGRTITULO("NP9_LOCAL") 	,AGRTITULO("NP9_LOCAL") ,'NP9_LOCAL' ,'C',TAMSX3('NP9_LOCAL')[1]},;
		{AGRTITULO("D3_PERDA")  	,AGRTITULO("BC_QUANT")  ,'D3_PERDA'  ,'N',TAMSX3('D3_PERDA')[1],TAMSX3('D3_PERDA')[2]},;
		{AGRTITULO("BC_TIPO")  		,AGRTITULO("BC_TIPO")   ,'BC_TIPO'   ,'C',TAMSX3('BC_TIPO')[1]},;
		{AGRTITULO("BC_MOTIVO") 	,AGRTITULO("BC_MOTIVO") ,'BC_MOTIVO' ,'C',TAMSX3('BC_MOTIVO')[1]}})

	AGRCAMPDEF(oStruSB8,{{AGRTITULO("BC_QUANT")  	,AGRTITULO("BC_QUANT")  ,'BC_QUANT'  ,'N',TAMSX3('BC_QUANT')[1],TAMSX3('BC_QUANT')[2]},;
		{AGRTITULO("BC_TIPO")  	,AGRTITULO("BC_TIPO")   ,'BC_TIPO'   ,'C',TAMSX3('BC_TIPO')[1]},;
		{AGRTITULO("BC_MOTIVO") 	,AGRTITULO("BC_MOTIVO") ,'BC_MOTIVO' ,'C',TAMSX3('BC_MOTIVO')[1]},;
		{AGRTITULO("BF_LOCALIZ")	,AGRTITULO("BF_LOCALIZ"),'BF_LOCALIZ','C',TAMSX3('BF_LOCALIZ')[1]}})

	oModel:AddGrid( 'ITEM2', 'ITEM', oStruSB8)
	oModel:GetModel( "ITEM2" ):SetDescription(STR0043)

	oStruSG1:SetProperty('G1_COMP'	,MODEL_FIELD_WHEN,{|| AGR840FAL()})
	oStruSG1:SetProperty('G1_QUANT'	,MODEL_FIELD_WHEN,{|| AGR840FAL()})

	AGRWHENMVC(oStruSG1,{{'NP9_LOCAL',"AGR840CLOC()"}     ,{'B2_QATU',"AGR840FAL()"}        ,{'D3_PERDA',"AGR840PD3()"},;
		{'BC_TIPO'  ,'AGR840PGTM("SG1")'},{'BC_MOTIVO','AGR840PGTM("SG1")'},{'D3_LOCALIZ',"AGR840LOCZ()"}})

	AGRWHENMVC(oStruSB8,{{'B8_QTDORI',"AGR840LQTD()"}     ,{'BC_QUANT',"AGR840PB8()"},{'BC_TIPO','AGR840PGTM("SB8")'},;
		{'BC_MOTIVO','AGR840PGTM("SB8")'},{'BF_LOCALIZ'	         ,"AGR840LOBF()"}})

	oStruNP9:SetProperty('NP9_RENASE',MODEL_FIELD_WHEN,{|| AGRRETFALSO()})
	oStruNP9:SetProperty('NP9_TIPLOT',MODEL_FIELD_VALID,{|| AGR840TIPL()})

	If cTipoPro == "PRO"
		oStruNP9:SetProperty("NP9_LOCAL",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"AGRCAG1B8(,FwFldGet('NP9_LOCAL'),cTipoPro)"))
	EndIf

	AGRVALDEMVC(oStruSG1,{{'NP9_LOCAL',"AGR840LOCG1(.t.)"},{'B2_QATU',"Positivo() .And. AGR840QAU()"},{'D3_PERDA',"AGR840VPD('SG1')"},;
		{'BC_TIPO'  ,"Pertence('RS')"}  ,{'BC_MOTIVO',"AGR840CYO()"}})

	AGRVALDEMVC(oStruSB8,{{'B8_QTDORI',"AGR840VQTD()"},{'BC_QUANT',"AGR840VPD('SB8') .And. AGR840VQTD()"},;
		{'BC_TIPO'  ,"Pertence('RS') .And. AGR840VQTD()"},;
		{'BC_MOTIVO',"AGR840CYO()"},{'B8_LOTECTL',"AGRRETTRUE()"}})

	AGROBRIGMVC(oStruSB8,{'B8_LOTECTL','B8_LOCAL'})

	//Sub-modelo 
	oModel:SetRelation("ITEM"     , { { "G1_FILIAL", "FwxFilial( 'SG1' )" }, {"G1_COD","NP9_PROD"  } }, SG1->( IndexKey( 1 ) ) )
	oModel:SetRelation("ITEM2"    , { { "SB8_FILIAL", "FwxFilial( 'SB8' )" }, {"B8_PRODUTO","G1_COMP"} }, SB8->( IndexKey( 1 ) ) )
    
	oModel:GetModel( 'ITEM' ):SetOptional(.T.)     // Permissão para grid vazia
	oModel:GetModel( 'ITEM' ):SetOnlyQuery(.T.)    // Não gravar
	oModel:GetModel( 'ITEM' ):SetNoInsertLine(.T.) // Não incluir
	oModel:GetModel( 'ITEM' ):SetNoUpdateLine(.F.) // Não Alterar
	oModel:GetModel( 'ITEM' ):SetNoDeleteLine(.T.) // Não deleta

	oModel:GetModel( 'ITEM2'):SetOptional(.T.)     // Permissão para grid vazia
	oModel:GetModel( 'ITEM2'):SetOnlyQuery (.T.)   // Não gravar
	oModel:GetModel( 'ITEM2'):SetNoInsertLine(.T.) // Não incluir
	oModel:GetModel( 'ITEM2'):SetNoDeleteLine(.T.) // Não deleta


	oModel:SetPrimaryKey({"NP9_FILIAL","NP9_CODIGO"}) // Seta chave primaria

	If cLoteTSI <> Nil
		cStaTSI  := NP9->NP9_STATUS
		cLoteOri := NP9->NP9_LOTE
		cProdNP9 := NP9->NP9_PROD
		vVetCamp := oStruNP9:GetFields() //assim não pega campos nao usados
		vVetEdit := {"NP9_LOCAL","NP9_QUANT","NP9_UMIDEN","NP9_UMIDAD","NP9_OBS","NP9_HRINI","NP9_HRFIM","NP9_PSMDEN",;
			"NP9_PSMDSC","NP9_CODTUR","NP9_CCUSTO","NP9_DANMEC","NP9_VISTRA","NP9_DATAFI"}
		If !Empty(cTipoPro)
			If cTipoPro <> "PRO"
				Aadd(vVetEdit,"NP9_PROD")
			EndIf
		Else
			Aadd(vVetEdit,"NP9_PROD")
			Aadd(vVetEdit,"NP9_EMB")
			Aadd(vVetEdit,"NP9_MARCA")
		EndIf

		If ExistBlock("AGR840P1")
			ExecBlock("AGR840P1",.F.,.F.) // Variaveis para testar cTipoPro,cLoteTSI para manipular vVetEdit
		EndIf

		aMatNEdi := {}

		For nx := 1 To Len(vVetCamp)
			If !Alltrim(vVetCamp[nx,3]) $ cCampNao .And. Ascan(vVetEdit,{|x| Alltrim(x) = Alltrim(vVetCamp[nx,3])}) = 0
				Aadd(aMatNEdi,{Alltrim(vVetCamp[nx,3])})
			EndIf
		Next nx

		AGRWHENMVC(oStruNP9,aMatNEdi)

		AGRINIPADMVC(oStruNP9,{{"NP9_CODSAF","NP9->NP9_CODSAF"},{"NP9_LOTE","NP9->NP9_LOTE"},{"NP9_CULTRA","NP9->NP9_CULTRA"},{"NP9_CTVAR","NP9->NP9_CTVAR"},;
			{"NP9_CATEG","NP9->NP9_CATEG"},{"NP9_PENE","NP9->NP9_PENE"},{"NP9_SECA","NP9->NP9_SECA"},{"NP9_CLASS","NP9->NP9_CLASS"},;
			{"NP9_DOCBLQ","NP9->NP9_DOCBLQ"},{"NP9_TIPLOT","'1'"},{"NP9_EGF","NP9->NP9_EGF"},{"NP9_IR","NP9->NP9_IR"},;
			{"NP9_CTRDES",'SubStr(Posicione("NP3",1,Xfilial("NP3")+NP9->NP9_CULTRA,"NP3_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTRDES",2,"X3_TAMANHO"))'},;
			{"NP9_CTVDES",'SubStr(Posicione("NP4",1,Xfilial("NP4")+NP9->NP9_CTVAR,"NP4_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTVDES",2,"X3_TAMANHO"))'},;
			{"NP9_PENDES",'SubStr(Posicione("NP7",1,Xfilial("NP7")+NP9->NP9_PENE ,"NP7_DESCRI"),1,AGRSEEKDIC("SX3","NP9_PENDES",2,"X3_TAMANHO"))'},;
			{"NP9_DTVAL" ,'Posicione("SB8",3,xFilial("SB8")+NP9->NP9_PROD+NP9->NP9_LOCAL+cLoteTSI,"B8_DTVALID")'},;
			{"NP9_INSCPO","NP9->NP9_INSCPO"},{"NP9_RETPEN","NP9->NP9_RETPEN"}})

		If ExistBlock("AGR840P8")
			aRetIN := 	ExecBlock("AGR840P8",.F.,.F.)
			For nx := 1 To Len(aRetIN)
				If ValType(aRetIN[nx,2]) == 'C'
					cIni := "'" + aRetIN[nx,2] + "'"
				Else
					cIni := cValToChar(aRetIN[nx,2])
				EndIf
				oStruNP9:SetProperty(aRetIN[nx,1],MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, cIni) )
			Next nx
		EndIf

		If !Empty(cTipoPro)
			If cTipoPro == "PRO"
				AGRINIPADMVC(oStruNP9,{{"NP9_PROD","NP9->NP9_PROD"},{"NP9_UM","NP9->NP9_UM"},{"NP9_2UM","NP9->NP9_2UM"},{"NP9_TRATO","NP9->NP9_TRATO"},;
					{"NP9_PRDDES",'SubStr(Posicione("SB1",1,Xfilial("SB1")+NP9->NP9_PROD,"B1_DESC"),1,AGRSEEKDIC("SX3","NP9_PRDDES",2,"X3_TAMANHO"))'}})
			Else
				oStruNP9:SetProperty("NP9_TRATO",MODEL_FIELD_INIT,{||"3"})
			EndIf
			AGRINIPADMVC(oStruNP9,{{"NP9_EMB","NP9->NP9_EMB"},{"NP9_MARCA","NP9->NP9_MARCA"}})
		Else
			oStruNP9:SetProperty("NP9_TRATO",MODEL_FIELD_INIT,{|| '1'})

			// pré-carregados no TSI
			If ExistBlock("AGR840P2")
				aRetIN := 	ExecBlock("AGR840P2",.F.,.F.)
				For nx := 1 To Len(aRetIN)
					oStruNP9:SetProperty(aRetIN[nx,1],MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,aRetIN[nx,2]))
				Next nx
			EndIf
			If !Empty(cLoteTSI)			
			   DbSelectArea("SB8")
				DbSetOrder(3)
				If SB8->(DbSeek(FwxFilial("SB8") + NP9->NP9_PROD + NP9->NP9_LOCAL + cLoteTSI))
				   oStruNP9:SetProperty("NP9_DTVAL",MODEL_FIELD_INIT,{||SB8->B8_DTVALID})
				Endif   
			EndIF   
		EndIf		
	Else // cLoteTSI = Nil
		AGRA840WI(cPergF11)
	EndIf

	oStruSG1:SetProperty('G1_PERDA',MODEL_FIELD_VALID, { | oField | AGRA840TRG( oField, "G1_PERDA" ) } )

Return oModel

/*
############################################################################
# Função   : ViewDef                                                       #
# Descrição: Definição da ViewDef                                          #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 12/08/2014                                                    #  
############################################################################
*/
Static Function ViewDef()
	Local cPesqRefug := ' '
	Local vVetCSB8 := {"B8_LOCAL","B8_LOTECTL","B8_EMPENHO","B8_SALDO"}
	Local aCampTit := {{"B8_QTDORI",STR0025}}
	Local aCampOrd := {{"B8_QTDORI"},{"BC_QUANT"},{"BC_TIPO"},{"BC_MOTIVO"},{"B8_LOTECTL"},{"B8_SALDO"},{"B8_EMPENHO"},{"B8_LOCAL"}} // Mostrar essa ordem
	Local aCamOSG1 := {{"G1_COMP"},{"G1_DESC"},{"G1_QUANT"},{"NP9_LOCAL"},{"B2_QATU"},{"D3_PERDA"},{"BC_TIPO"},{"BC_MOTIVO"},{"D3_LOCALIZ"}}
	Local vVetNSG1	:=	{"G1_COMP","G1_DESC","G1_QUANT","G1_PERDA","G1_FIXVAR"}
	Local vVetNSB8 	:=	{"B8_LOCAL","B8_LOTECTL","B8_EMPENHO","B8_SALDO","B8_QTDORI"}
	Default cPergF11 := AGRGRUPSX1("AGRA840F11")
	
	oModel	 := FwLoadModel( "AGRA840" )
	oStruNP9 := FwFormStruct(2,"NP9" , {|cCampo| !(AllTRim(cCampo) $ "NP9_DOCBLQ|NP9_STATUS" ) })//Lote de Sementes/
	oStruSG1 := FwFormStruct(2,"SG1")
	oStruSB8 := FwFormStruct(2,"SB8")

	oView := FWFormView():New() // Cria o objeto de View

	//Se o cliente tem os campos novos da CYO, então ele tem a melhoria em que foi retirada
	//o cadastro de refugo da SX5 e transferido para o SFCA003 (tabela CYO)
	if AGR840camp()
		cPesqRefug:= "CYO003"
	Else
		cPesqRefug:= "43"
	EndIf

	//Adiciona mais campos
	AGRCAMPVIEW(oStruSG1,{{'G1_DESC'   ,'2',AGRTITULO("G1_DESC")   ,AGRTITULO("G1_DESC")   ,,'C',"@!"},;
		{'B2_QATU'   ,'3',STR0042,STR0042,,'N'   ,AGRSEEKDIC("SX3","B8_QTDORI ",2,"X3_PICTURE")},;
		{'D3_LOCALIZ','7',AGRTITULO("D3_LOCALIZ"),AGRTITULO("D3_LOCALIZ"),,'C','@!',NIL,'SBE'},;
		{'NP9_LOCAL' ,'5',AGRTITULO("NP9_LOCAL") ,AGRTITULO("NP9_LOCAL") ,,'C','@!'},;
		{'D3_PERDA'  ,'4',AGRTITULO("BC_QUANT")  ,AGRTITULO("BC_QUANT")  ,,'N','@E 999,999,999.99'},;
		{'BC_TIPO'   ,'5',AGRTITULO("BC_TIPO")   ,AGRTITULO("BC_TIPO")   ,,'C','@!',NIL,,.T.,NIL,NIL,{'R=Refugo','S=Scrap'}},;
		{'BC_MOTIVO' ,'6',AGRTITULO("BC_MOTIVO") ,AGRTITULO("BC_MOTIVO") ,,'C','@!',NIL,cPesqRefug}})

	AGRCAMPVIEW(oStruSB8,{{'BC_QUANT'  ,'4',AGRTITULO("BC_QUANT")  ,AGRTITULO("BC_QUANT")	,,'N','@E 999,999,999.99'},;
		{'BC_TIPO'   ,'5',AGRTITULO("BC_TIPO")   ,AGRTITULO("BC_TIPO")	,,'C','@!',NIL,,.T.,NIL,NIL,{'R=Refugo','S=Scrap'}},;
		{'BC_MOTIVO' ,'6',AGRTITULO("BC_MOTIVO") ,AGRTITULO("BC_MOTIVO")	,,'C','@!',NIL,cPesqRefug},;
		{'BF_LOCALIZ','6',AGRTITULO("BF_LOCALIZ"),AGRTITULO("BF_LOCALIZ"),,'C','@!'}})

	oView:AddUserButton(STR0044,'CLIPS',{|oView|AGR840ALTE()}) // Adiciona um botão

	AGRGRIDMVC(@oStruSG1,"SG1",vVetNSG1,.F.)
	AGRGRIDMVC(@oStruSB8,"SB8",vVetNSB8,.F.)

	AGRCHANGEMVC(@oStruSB8,vVetCSB8)

	AGRTITULOMVC(@oStruSB8,aCampTit)

	AGRORDEMMVC(@oStruSB8,aCampOrd)
	AGRORDEMMVC(@oStruSG1,aCamOSG1)

	oView:SetModel( oModel )                    // Define qual Modelo de dados será utilizado
	oView:AddField('VIEW_NP9',oStruNP9,'CABEC') // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid('VIEW_SG1',oStruSG1,'ITEM')
	oView:AddGrid('VIEW_SB8',oStruSB8,'ITEM2')

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox('SUPERIOR',50)
	oView:CreateHorizontalBox('INFERIOR',50)

	oView:CreateVerticalBox('EMBAIXOSG1',50,'INFERIOR')
	oView:CreateVerticalBox('EMBAIXOSB8',50,'INFERIOR')

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView('VIEW_NP9','SUPERIOR')
	oView:SetOwnerView('VIEW_SG1','EMBAIXOSG1')
	oView:SetOwnerView('VIEW_SB8','EMBAIXOSB8')

	oView:EnableTitleView('ITEM' ,STR0040)
	oView:EnableTitleView('ITEM2',STR0043)

	oView:SetViewProperty('VIEW_SG1',"CHANGELINE",{{|| AGR840CHLINE(oView,cPergF11)}})
Return oView

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840CAN                                                                           |
| Descrição : Cancelamento da inclusão                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/11/2014                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840CAN()
	SetKey(VK_F4,Nil)
	SetKey(VK_F11,{|| AGRA840F11()})
	lF11   := .t.
	INCLUI := .F.
Return .t.

/*                                                                                                 
+=================================================================================================+
| Programa  : AGRDTVALID                                                                          |
| Descrição : Calcula da data de validade                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 12/051/2014                                                                         | 
+=================================================================================================+                                                                           |  
*/
Function AGRDTVALID(dData,lFwAt)
	If cLoteTSI = Nil
		AGRIFDBSEEK("SB1",M->NP9_PROD,1,.f.)
		dDTVAL := If(cLoteTSI = Nil,dData+SB1->B1_PRVALID,NP9->NP9_DTVAL)
		If lFwAt = Nil .AND. Empty(FwFldGet("NP9_DTVAL"))
			FwFldPut("NP9_DTVAL",dDTVAL)
		EndIf
	Else
		DbSelectArea("SB8")
		DbSetOrder(3)
		If SB8->(DbSeek(FwxFilial("SB8") + M->NP9_PROD + M->NP9_LOCAL + cLoteTSI))
			dDTVAL := SB8->B8_DTVALID
			FwFldPut("NP9_DTVAL",SB8->B8_DTVALID)
		Endif   			
	Endif
Return If(cLoteTSI <> Nil,.t., If(lFwAt = Nil,.t.,dDTVAL))

/*
############################################################################
# Função   : AGR840CLOC                                                    #
# Descrição: Verifica se habilita o campo local do item                    #
# Autor    : Vitor                                                         #
# Data     : 12/11/2014                                                    #  
############################################################################
*/
Function AGR840CLOC()
	Local oModel	 := FwModelActive()
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local cCompoL := oGrdSG1:GetValue("G1_COMP")
	cLocalA := oGrdSG1:GetValue("NP9_LOCAL")
Return If(FwFldGet("NP9_TIPLOT") = "2",.t.,If((oModel:GetOperation() = 3) .And. !Empty(cCompoL),.t.,.f.))

/*
############################################################################
# Função   : AGR840LOCZ                                                    #
# Descrição: Verifica se habilita campo de endereço do SG1                 #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 17/12/2014                                                    #  
############################################################################
*/
Function AGR840LOCZ()
	Local oModel	 := FwModelActive()
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local cCompon := oGrdSG1:GetValue("G1_COMP")
Return If(AGRIFDBSEEK("SB1",cCompon,1,.f.).And. RetFldProd(SB1->B1_COD,"B1_LOCALIZ") = "S" .And. !AGRIFSEETRB(cAlT,cCompon,1,.f.),.T.,.F.)

/*
############################################################################
# Função   : AGR840LOTL                                                    #
# Descrição: Verifica se habilita campo de lote do SG1                     #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 17/12/2014                                                    #  
############################################################################
*/
Function AGR840LOTL()
	Local oModel	 := FwModelActive()
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local cCompon := oGrdSG1:GetValue("G1_COMP")
Return If(AGRIFDBSEEK("SB1",cCompon,1,.f.) .And. SB1->B1_RASTRO = "L",.T.,.F.)

/*
############################################################################
# Função   : AGR840FAL                                                     #
# Descrição: Valida a leitura dos campos                                   #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 14/11/2014                                                    #  
############################################################################
*/
Function AGR840FAL(cVar)
Return If(ReadVar() = "M->G1_COMP" .Or. ReadVar() = "M->G1_QUANT",.F.,.T.)

/*
############################################################################
# Função   : AGR840LOCG1                                                   #
# Descrição: Refaz a grid dos componentes na troca de local                #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 14/11/2014                                                    #  
############################################################################
*/
Function AGR840LOCG1(lGrd)
	Local oModel	:= FwModelActive()
	Local oGrdSG1	:= oModel:GetModel("ITEM")
	Local oGrdSB8	:= oModel:GetModel("ITEM2")
	Local nLinxx	:= oGrdSG1:GetLine()
	Local lGrid		:= If(lGrd <> Nil,lGrd,.f.)

	oGrdSG1:GoLine(nLinxx)
	cComponP := oGrdSG1:GetValue("G1_COMP")
	cLocalB8 := If(!lGrid,FwFldGet("NP9_LOCAL"),oGrdSG1:GetValue("NP9_LOCAL"))
	cLocaliz := oGrdSG1:GetValue("D3_LOCALIZ")

	If !lGrid .And. cLocalB8 = cLocalPR
		Help(,1,"HELP",,STR0103+" (MV_LOCPROC)",1,0)
		Return .f.
	EndIf

	// Deleta os lote do componente do local anterior e carrega com o novo lote
	If !Empty(cLocalB8)
		// Verifica se o item tem lote
		If Empty(FwFldGet("NP9_OP"))
			If AGRIFSEETRB(cAlT,cComponP,1,.f.)
				While !Eof() .And. (cAlT)->B8_PRODUTO = cComponP
					AGRDELETAREG()
					AGRDBSELSKIP(cAlT)
				End
			End
			AGR840CSB8(cComponP,cLocalB8,cLocaliz)
			ARG840GRID2()
		EndIf
	Else
		oGrdSB8:aCols      := {}
		oGrdSB8:adatamodel := {}
		If ValType(oView) != "U"
			oView:Refresh('VIEW_SB8')
		EndIf
	EndIf

	oGrdSG1:GoLine(nLinxx)

Return .T.

/*
############################################################################
# Função   : MenuDef                                                       #
# Descrição: Definição do MenuDef                                          #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 12/08/2014                                                    #  
############################################################################
*/
Static Function MenuDef()
	Local nx
	Local nOper
	Private aRotina := {}

	/* Alterado para chamar a pré-função AGR840PRE, onde há um ponto de entrada disponibilizado os tratamentos
	de permissão de execução a rotinas conforme conceito aplicado pelo cliente.

	Ex: se é possível ou não Produzir + a partir de um lote já aprovado	*/

	// Lembrete: Sempre que incluir um item de menu novo, manutenir a função AGR840PRE
	ADD OPTION aRotina Title OemToAnsi(STR0004)	Action 'AGR840PRE(2)'			OPERATION 2  ACCESS 0	  //"Visualizar"
	ADD OPTION aRotina Title OemToAnsi(STR0005)	Action 'VIEWDEF.AGRA840'		OPERATION 3  ACCESS 0	  //"Incluir"
	ADD OPTION aRotina Title OemToAnsi(STR0006)	Action 'AGR840PRE(4)'	  		OPERATION 4  ACCESS 0	  //"Alterar"
	ADD OPTION aRotina Title OemToAnsi(STR0007)	Action 'AGR840PRE(5)'     		OPERATION 5  ACCESS 0	  //"Exluir"
	ADD OPTION aRotina Title OemToAnsi(STR0184)	Action 'AGR840PRE(7)'		   	OPERATION 7  ACCESS 0     //"Desmontagem" 
	ADD OPTION aRotina Title OemToAnsi(STR0012)	Action 'AGR840PRE(8)'		    OPERATION 8  ACCESS 0	  //"Descarte"
	ADD OPTION aRotina Title OemToAnsi(STR0079)	Action 'AGR840PRE(9)'        	OPERATION 9  ACCESS 0	  //"Conhecimento"
	ADD OPTION aRotina Title OemToAnsi(STR0080)	Action 'AGR840PRE(10)'			OPERATION 10 ACCESS 0	  //"TSI"
	ADD OPTION aRotina Title OemToAnsi(STR0152)	Action 'AGR840PRE(11)'			OPERATION 11 ACCESS 0	  //"Produzir +"
	ADD OPTION aRotina Title OemToAnsi(STR0136)	Action 'AGR840PRE(12)'		   	OPERATION 13 ACCESS 0	  //"Histórico"
	ADD OPTION aRotina Title OemToAnsi(STR0069)	Action 'AGR840PRE(13)'	   		OPERATION 14 ACCESS 0	  //"Aprovar"
	ADD OPTION aRotina Title OemToAnsi(STR0070)	Action 'AGR840PRE(14)'	   		OPERATION 15 ACCESS 0	  //"Rejeitar"

	For nX := 1 to Len(aRotina)
		nOper := aRotina[nX][4]	
	Next nX

    //Ponto de entrada para adicionar outras ações relacionadas 
	If ExistBlock('AGR840P3')
		aRetM := ExecBlock('AGR840P3',.F.,.F.)
		If Type("aRetM") == 'A'
			For nx := 1 To Len(aRetM)
				nOper ++
				ADD OPTION aRotina Title aRetM[nx,1]	Action aRetM[nx,2] OPERATION 7 ACCESS 0	
			Next nx
		EndIf
	EndIf

Return aRotina

/*
############################################################################
# Função   : AGR840CON                                                     #
# Descrição: Consistência para inclusão de conhecimento                    #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 04/09/2014                                                    #  
############################################################################
*/
Function AGR840CON()
	If NP9->NP9_TRATO <> '2'
		vVetLP := AGRDOCLOTPAI(NP9->NP9_CODSAF,NP9->NP9_PROD,NP9->NP9_LOTE,,.T.)
		Help(,1,"HELP",,STR0164+If(!Empty(vVetLP),STR0165+"  "+Alltrim(AGRTITULO("NP9_CODSAF"))+"..:"+" "+Alltrim(vVetLP[1])+;
			" "+Alltrim(AGRTITULO("NP9_PROD  "))+"..:"+" "+Alltrim(vVetLP[2])+" "+Alltrim(AGRTITULO("NP9_LOTE  "))+"..:"+" "+Alltrim(vVetLP[3])," "),1,0)
		Return
	EndIf
	AGRCONHECIM("NP9")
Return

/*
############################################################################
# Função   : AGRCAG1B8                                                     #
# Descrição: Carrega a estrutura do produto e lotes dos compomentes        #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 12/08/2014                                                    #  
############################################################################
*/
Function AGRCAG1B8(cF11,cLocalMP,lMP,lgrid)
	Local oModel  := FwModelActive()
	Local oCabec := oModel:GetModel("CABEC")
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local oGrdSB8 := oModel:GetModel("ITEM2")
	Local cTipLote	:= FwFldGet("NP9_TIPLOT")
	Local nLinha  := 1,nCount := 0,nx
	Store 0 To nLinha,nCount

	// Permite manipular o local de estoque gatilhado por padrao nos itens de MP a serem consumidos
	If ExistBlock("AGR840P7")
		cLocalMP := ExecBlock("AGR840P7",.F.,.F.,)
	EndIf

	If cTipoPro = "PRO" .And. !Empty(FwFldGet("NP9_LOCAL")) .And. FwFldGet("NP9_LOCAL") <> NP9->NP9_LOCAL
		Help(,1,"HELP",,STR0157+" "+NP9->NP9_LOCAL,1,0)
		Return .f.
	EndIf

	If cTipoPro = "TRC" .And. FwFldGet("NP9_PROD") = NP9->NP9_PROD
		Help(,1,"HELP",,STR0158+" "+NP9->NP9_PROD,1,0)
		Return .f.
	EndIf

	If !AGR840REOP()
		Return .f.
	EndIf

	If oModel:GetModel('CABEC'):GetValue('NP9_QUANT') > 0 .And. ;
			(ReadVar() = "M->NP9_PROD" .Or. ReadVar() = "M->NP9_LOCAL")
		oModel:GetModel('CABEC'):SetValue('NP9_QUANT',0)
	Endif

	SetKey(VK_F4,{|| AGR840F4()})
	SetKey(VK_F11,Nil)

	AGRIFDBSEEK("SB1",M->NP9_PROD,1,.f.)

	M->NP9_UM := SB1->B1_UM
	If cF11 = Nil .And. lMP = Nil .And. !lgrid
		M->NP9_LOCAL := SB1->B1_LOCPAD
	EndIf
	AGRSETAVAR({{"M->NP9_2UM",SB1->B1_SEGUM},{"M->NP9_PRDDES",SB1->B1_DESC},{"M->NP9_OP",Space(Len(NP9->NP9_OP))},;
		{"M->NP9_CCUSTO",SB1->B1_CC},{"M->NP9_DTVAL",If(cLoteTSI = Nil,IIF(Empty(M->NP9_DTVAL),M->NP9_DATA+SB1->B1_PRVALID,M->NP9_DTVAL),NP9->NP9_DTVAL)}})

	// Não deleta
	If cLoteTSI = Nil .And. !lgrid
		AGRIFDBSEEK("SB5",M->NP9_PROD,1,.f.)
		AGRSETAVAR({{"M->NP9_CULTRA",SB5->B5_CULTRA},{"	M->NP9_CATEG",SB5->B5_CATEG},{"M->NP9_PENE",SB5->B5_PENE},{"M->NP9_CTVAR",SB5->B5_CTVAR},;
			{"M->NP9_MARCA",SubStr(SB5->B5_MARCA,1,Len(NP9->NP9_MARCA))}})
	EndIf

	If lMP <> Nil .And. !lgrid
		AGRSETAVAR({{"M->NP9_CULTRA",NP9->NP9_CULTRA},{"M->NP9_CATEG",NP9->NP9_CATEG},{"M->NP9_PENE",NP9->NP9_PENE},;
			{"M->NP9_CTVAR",NP9->NP9_CTVAR},{"M->NP9_MARCA",NP9->NP9_MARCA}})
	EndIf

	If !lgrid
		AGRSETAVAR({{"M->NP9_CTRDES",SubStr(Posicione("NP3",1, Xfilial("NP3")+M->NP9_CULTRA,"NP3_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTRDES",2,"X3_TAMANHO"))},;
			{"M->NP9_CTVDES",SubStr(Posicione("NP4",1, Xfilial("NP4")+M->NP9_CTVAR,"NP4_DESCRI") ,1,AGRSEEKDIC("SX3","NP9_CTVDES",2,"X3_TAMANHO"))},;
			{"M->NP9_PENDES",SubStr(Posicione("NP7",1, Xfilial("NP7")+M->NP9_PENE,"NP7_DESCRI")  ,1,AGRSEEKDIC("SX3","NP9_PENDES",2,"X3_TAMANHO"))}})
	EndIf

	oGrdSG1:SetNoInsert( .f. )
	oGrdSG1:SetNoDelete( .f. )

	DbSelectArea(cAlT)
	Zap

	// Limpa os grids
	AGRLIMPAGRID(oGrdSG1,"VIEW_SG1")
	AGRLIMPAGRID(oGrdSB8,"VIEW_SB8")

	nEstru   := 0
	aEstrSG1 := ESTRUT(M->NP9_PROD,1,.T.,.f.)

	//Bruna
	If Empty(aEstrSG1) .And. cTipLote <> "2" //Comprado
		oModel:GetModel( 'ITEM2' ):SetNoInsertLine( .F. )
		AGRLIMPAGRID(oGrdSG1,"VIEW_SG1")
		oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
		Help(,1,STR0013,,STR0194,1,0)
		Return .f.
	EndIf

	nLinha := 1
	oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )

	For nx := 1 To Len(aEstrSG1)
		If AGRIFDBSEEK("SB1",aEstrSG1[nx,3],1,.f.) .And. SB1->B1_FANTASM <> "S" .And. AGRIFDBSEEK("SG1",aEstrSG1[nx,2]+aEstrSG1[nx,3],1,.f.)
			nCount++
			If (nCount > nLinha,oGrdSG1:AddLine(),oGrdSG1:GoLine(1))
				nQtdeF := If(SG1->G1_FIXVAR = "F",SG1->G1_QUANT+((SG1->G1_QUANT*SG1->G1_PERDA)/100),;
					SG1->G1_QUANT*M->NP9_QUANT+((SG1->G1_QUANT*M->NP9_QUANT)*SG1->G1_PERDA/100))
					cLocalG1 := If(cLocalMP = Nil,SB1->B1_LOCPAD,cLocalMP) 
					If (cLocalG1 == Nil)
						cLocalG1 :=oCabec:GetValue('NP9_LOCAL') 
					EndIf
				AGRLOADVALUE(oGrdSG1,{{'G1_COMP',SG1->G1_COMP},{'G1_DESC',SubStr(SB1->B1_DESC,1,nTamDSG1)},{'G1_QUANT',SG1->G1_QUANT},;
					{'G1_PERDA',SG1->G1_PERDA},{'G1_FIXVAR',SG1->G1_FIXVAR},{'B2_QATU',(nQtdeF / SB1->B1_QB)},{'NP9_LOCAL',cLocalG1},;
					{"D3_PERDA",0},{"BC_TIPO"," "},{"BC_MOTIVO","  "}})
				AGR840CSB8(SG1->G1_COMP,oGrdSG1:GetValue('NP9_LOCAL'),CriaVar("D3_LOCALIZ"), nQtdeF) // Carrega os lotes para o arquivo temporário
			EndIf
		Next nx

		If nCount = 0
			oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
			Return .t.
		EndIf

		oGrdSG1:GoLine(1)
		cComponP := oGrdSG1:GetValue("G1_COMP")
		oModel:GetModel( 'ITEM' ):SetNoInsertLine( .T. )
		oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
		If ValType(oView) != "U"
			oView:Refresh('VIEW_SG1')
		EndIf
		ARG840GRID2() // Carrega os lotes do primeiro componente da grid

		If FwFldGet("NP9_TIPLOT") = "2"
			// Limpa os grids
			AGRLIMPAGRID(oGrdSG1,"VIEW_SG1")
			AGRLIMPAGRID(oGrdSB8,"VIEW_SB8")
		EndIf
		Return .T.

/*
############################################################################
# Função   : AGR840CSB8                                                    #
# Descrição: Carrega os lotes do compomente do SB8                         #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 23/08/2014                                                    #  
############################################################################
*/
Function AGR840CSB8(cG1_COMP,cLocalB8,cLocaliz, nQuant)
	Local nSaldo   	:= 0
	Local nQuantP  	:= 0
	Local lGrava 	:= .F.
	Local lB1QB		:= .F. 
	Local oFWSX1	:= Nil //oFWSX1 objeto com o pergunte para validar se existe campo/variavel de pergunte para marcar lote add na p12.1.37 porem clientes podem add manual em versões anteriores
	Local lMarcLote := .T. //por padrão sempre marca automatico os lotes dos componentes

	Default nQuant := 0

	PERGUNTE(cPergF11,.f.)

	oFWSX1 := FWSX1Util():New()
	oFWSX1:AddGroup(cPergF11)
	oFWSX1:SearchGroup() 

	If Len(oFWSX1:aGrupo[1, 2]) > 4 .and. MV_PAR05 = 2
		lMarcLote := .F.
	EndIf
	
	AGRIFDBSEEK("SB1",cG1_COMP,1,.f.)
	If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") <> "S"
		cAlia8 := GetNextAlias()
		cQuer8 := " SELECT B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_LOTECTL,B8_NUMLOTE FROM "+RetSqlName("SB8")+" SB8 "
		cQuer8 += " WHERE SB8.B8_FILIAL = '"+Xfilial("SB8")+"' AND SB8.B8_PRODUTO = '"+cG1_COMP+"' AND SB8.B8_LOCAL = '"+cLocalB8+"'"
		cQuer8 += " AND SB8.D_E_L_E_T_ = '' "
		cQuer8 := ChangeQuery(cQuer8)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuer8),cAlia8,.F.,.T.)
		ARGSETIFARQUI(cAlia8)
		While !Eof()
			If AGRIFDBSEEK("SB8",(cAlia8)->B8_PRODUTO+(cAlia8)->B8_LOCAL+(cAlia8)->B8_DTVALID+(cAlia8)->B8_LOTECTL+(cAlia8)->B8_NUMLOTE,1,.F.)
				If Empty(cLocalB8)
					cLocalB8 := If(oModel:GetOperation() = 3,cLocalB8,NP9->NP9_LOCAL)
				EndIf
				lGrava := If(AGRIFDBSEEK("SB5",cG1_COMP,1,.f.) .And. SB5->B5_SEMENTE == "1" .And. SB8->B8_LOTECTL <> FwFldGet("NP9_LOTE"),.f.,.t.)
				If lGrava
					lGrava := Rastro(SB8->B8_PRODUTO)
				EndIf
				If lGrava .And. cLocalB8 = SB8->B8_LOCAL
					nSaldo := SB8Saldo(.F.,!Empty(SB8->B8_LOTECTL),NIL,NIL,NIL,lEmpPrev,NIL,FwFldGet("NP9_DATA"))
					If nSaldo > 0 
						nQuantP := 0 //ZERA VARIAVEL
						If nQuant > 0 .and. lMarcLote
							AGRIFDBSEEK("SB1", oModel:GetModel("CABEC"):GetValue("NP9_PROD"),1,.F.)	
							If !lB1QB // Condição para que não realize a divisão novamente 
								nQuant := nQuant / SB1->B1_QB // Cálculo Qtd a Consumir
								lB1QB := .T.
							EndIf						
							If nSaldo >= nQuant // Se o Lote possui saldo maior que o Qtd a Consumir
								nQuantP := nQuant
							ElseIf nSaldo < nQuant // Se o Lote possui saldo menor que o Qtd a Consumir
								nQuantP := nSaldo
							EndIf
							nQuant -= nQuantP // Subtração para obter quanto ainda falta da Qtd a Consumir 
						EndIf		
						If !AGRIFSEETRB(cAlT,SB8->B8_PRODUTO+SB8->B8_LOTECTL,2,.f.)
							AGRTRAVAREG(cAlT,.t.)
							AGRGRAVAREG(cAlT,{{"B8_PRODUTO",SB8->B8_PRODUTO},{"B8_LOCAL",SB8->B8_LOCAL},{"B8_LOTECTL",SB8->B8_LOTECTL},;
								{"B8_EMPENHO",SB8->B8_EMPENHO},{"B8_SALDO",nSaldo},{"BC_QUANT",0},{"B8_QTDORI",nQuantP}})
							(cAlT)->(MsUnLock())
						EndIf						
					EndIf
				EndIf
			EndIf
			AGRDBSELSKIP(cAlia8)
		EndDo
		ARGCLOSEAREA(cAlia8)
	Else
		cLocalB8 := If(oModel:GetOperation() = 3,cLocalB8,NP9->NP9_LOCAL)
		If AGRIFSEETRB(cAlT,cG1_COMP+cLocalB8,2,.f.)
			While !Eof() .And. (cAlT)->B8_PRODUTO = cG1_COMP .And. (cAlT)->B8_LOCAL = cLocalB8
				AGRDELEREG()
				DbSkip()
			End
		EndIf
		cAliasQry := GetNextAlias()
		cQuery := " SELECT BF_LOCAL,BF_LOCALIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE FROM "+RetSqlName("SBF")+" SBF "
		cQuery += " WHERE SBF.BF_FILIAL = '"+Xfilial("SBF")+"' AND SBF.BF_PRODUTO = '"+cG1_COMP+"' AND SBF.BF_LOCAL = '"+cLocalB8+"'"
		cQuery += " AND SBF.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		ARGSETIFARQUI(cAliasQry)
		While !Eof()
			If AGRIFDBSEEK("SBF",(cAliasQry)->(BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE),1,.f.)
				lGrava := If(AGRIFDBSEEK("SB5",cG1_COMP,1,.f.) .And. SB5->B5_SEMENTE = "1" .And. SBF->BF_LOTECTL <> FwFldGet("NP9_LOTE"),.f.,.t.)
				If lGrava .And. cLocalB8 = SBF->BF_LOCAL
					nSaldo := SaldoSBF(SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_PRODUTO,SBF->BF_NUMSERI,SBF->BF_LOTECTL)
					If nSaldo > 0
						cChaveTRB := (cAliasQry)->(BF_PRODUTO+BF_LOCAL+BF_LOCALIZ+If((cLoteTSI <> Nil .and. cTipoPro <> "PRO"),"",BF_LOTECTL))
						nIndicTRB := If((cLoteTSI <> Nil .and. cTipoPro <> "PRO"),3,4)
						If !AGRIFSEETRB(cAlT,cChaveTRB,nIndicTRB,.f.)
							AGRTRAVAREG(cAlT,.t.)
							AGRGRAVAREG(cAlT,{{"B8_PRODUTO",SBF->BF_PRODUTO},{"B8_LOCAL",SBF->BF_LOCAL},{"B8_LOTECTL",SBF->BF_LOTECTL},;
								{"B8_EMPENHO",SBF->BF_EMPENHO},{"B8_SALDO",nSaldo},{"BF_LOCALIZ",SBF->BF_LOCALIZ},{"BC_QUANT",0}})
							(cAlT)->(MsUnLock())
						EndIf
					EndIf
				EndIf
			EndIf
			AGRDBSELSKIP(cAliasQry)
		End
		ARGCLOSEAREA(cAliasQry)
	EndIf
Return

/*
############################################################################
# Função   : AGRCALOSB8                                                    #
# Descrição: Carrega os lotes do compomente                                #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 17/08/2014                                                    #  
############################################################################
*/
Function AGRCALOSB8()
	Local nx
	Local oModel  := FwModelActive()
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local oCabec := oModel:GetModel("CABEC")
	DbselectArea(cAlT)
	ZAP

	For nx := 1 To Len(aEstrSG1)
		AGR840CSB8(aEstrSG1[nx,3],oCabec:GetValue("NP9_LOCAL"))
	Next nx

	oModel:GetModel( 'ITEM' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
	For nx := 1 To oGrdSG1:Length()
		oGrdSG1:GoLine(nx)
		If Empty(FwFldGet("NP9_OP"))
			oGrdSG1:SetValue('NP9_LOCAL',oCabec:GetValue("NP9_LOCAL"))
		EndIf
	Next nx

	oGrdSG1:GoLine(1)
	cComponP := oGrdSG1:GetValue("G1_COMP")
	oModel:GetModel( 'ITEM' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
	If ValType(oView) != "U"
		oView:Refresh('VIEW_SG1')
	EndIf
	ARG840GRID2() // Carrega os lotes do primeiro componente da grid
Return .T.

/*
############################################################################
# Função   : ARG840GRID2                                                   #
# Descrição: Carrega os lotes do compomente                                #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 12/08/2014                                                    #  
############################################################################
*/
Function ARG840GRID2()
	Local oModel  := FwModelActive()
	Local oGrdSB8 := oModel:GetModel("ITEM2")
	Local nCount  := 0,nLinha := 1
	oModel:GetModel( 'ITEM2' ):SetNoInsertLine( .F. )
	AGRLIMPAGRID(oGrdSB8,"VIEW_SB8")
	nLinGrid := 0
	//Carrega os lotes do primeiro produto da grid
	If AGRIFSEETRB(cAlT,cComponP,1,.f.)
		While !Eof() .And. (cAlT)->B8_PRODUTO = cComponP
			nCount++
			If nCount > nLinha
				oGrdSB8:AddLine()
				oGrdSB8:GoLine( nCount )
			EndIf

			AGRLOADVALUE(oGrdSB8,{{'B8_LOCAL',(cAlT)->B8_LOCAL},{'B8_LOTECTL',(cAlT)->B8_LOTECTL},{'B8_EMPENHO',(cAlT)->B8_EMPENHO},;
				{'B8_SALDO',(cAlT)->B8_SALDO},{'B8_QTDORI',(cAlT)->B8_QTDORI},{'BF_LOCALIZ',(cAlT)->BF_LOCALIZ},;
				{"BC_QUANT",(cAlT)->BC_QUANT},{"BC_TIPO",(cAlT)->BC_TIPO},{"BC_MOTIVO",(cAlT)->BC_MOTIVO}})
			AGRDBSELSKIP(cAlT)
		End
	EndIf

	oGrdSB8:GoLine(1)
	If ValType(oView) != "U"
		oView:Refresh('VIEW_SB8')
	EndIf
	oModel:GetModel('ITEM2'):SetNoInsertLine( .T. )
Return .T.

/*
############################################################################
# Função   : AGR840ALTE                                                    #
# Descrição: Carrega os produtos alternativo e atualiza grid do compomente #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 14/08/2014                                                    #  
############################################################################
*/
Function AGR840ALTE()
	Local oModel	 := FwModelActive()
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local nQuanti := oGrdSG1:GetValue("G1_QUANT")
	Local aMatSGI := {}
	Local vVetCol := {AGRTITULO('GI_PRODALT'),AGRTITULO('B1_DESC'),AGRTITULO('GI_FATOR'),AGRTITULO('GI_TIPOCON')}
	Local nqtdBase := 0 //TWAV19
	Local nQtdePA

	AGRIFDBSEEK("SB1",FwFldGet("NP9_PROD"),1,.F.)
	nqtdBase := SB1->B1_QB


	cComponP      := oGrdSG1:GetValue("G1_COMP")
	If AGRIFDBSEEK("SGI",cComponP,1,.F.)
		While !Eof() .And. SGI->GI_FILIAL = Xfilial("SGI") .And. SGI->GI_PRODORI = cComponP
			Aadd(aMatSGI,{SGI->GI_PRODALT,SubStr(Posicione("SB1",1,Xfilial("SB1")+GI_PRODALT,"B1_DESC"),1,nTamDSG1),SGI->GI_FATOR,SGI->GI_TIPOCON})
			AGRDBSELSKIP("SGI")
		End
	EndIf
	If Empty(aMatSGI)
		Alert(STR0024+" "+Alltrim(cComponP)+" "+STR0045)
	Else
		vRetComp := AGRF3MATRIZ(aMatSGI,vVetCol,{1,3,4},STR0046+" "+Alltrim(cComponP))
		If ValType(vRetComp) = "A" .And. !Empty(vRetComp[1])

			//Atualiza a quantidade do produto, da estrutura. Produto alternativo
			/*
			If AGRIFDBSEEK("SG1", vRetComp[1] + FwFldGet("NP9_PROD"),2,.f.)
				If SG1->G1_FILIAL = Xfilial("SG1")
			nQuanti := SG1->G1_QUANT
				EndIf
			EndIf
			*/
			nQuanti := oGrdSG1:GetValue("G1_QUANT")

			oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
			AGRLOADVALUE(oGrdSG1,{{'G1_COMP'  ,vRetComp[1]},{'G1_DESC',SubStr(Posicione("SB1",1,Xfilial("SB1")+vRetComp[1],"B1_DESC"),1,nTamDSG1)},;
				{'G1_QUANT' ,If(vRetComp[3] = "M",nQuanti * vRetComp[2],nQuanti / vRetComp[2])},;
				{'B2_QATU'	,If(!Empty(oGrdSG1:GetValue("G1_QUANT")),oGrdSG1:GetValue("G1_QUANT")*M->NP9_QUANT,oGrdSG1:GetValue("G1_QUANT"))},;
				{'NP9_LOCAL',If(!Empty(cLocalO),cLocalO,FwFldGet("NP9_LOCAL"))},;
				{"D3_PERDA" ,0},{"BC_TIPO"," "},{"BC_MOTIVO","  "}})
			oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .f. )

			// Retira o produto original pelo alternativo
			If AGRIFSEETRB(cAlT,cComponP,1,.f.)
				AGRDELWHILE(cAlT,cComponP,,,,"(cAlT)->B8_PRODUTO = cComponP") // Deleta todos os lotes do componente
			EndIf
			// Carrega os lotes do produto alternativo na grid
			AGR840CSB8(vRetComp[1],oGrdSG1:GetValue('NP9_LOCAL'),oGrdSG1:GetValue('D3_LOCALIZ'))// Carrega os lotes do produto alternativo
			cCompAxu := cComponP
			cComponP := vRetComp[1]
			ARG840GRID2()

			//Inicio - Novo modo (dividir pela nQtdBase)
			nQtdePA := If(oGrdSG1:GetValue("G1_FIXVAR") = "F",oGrdSG1:GetValue("G1_QUANT")+((oGrdSG1:GetValue("G1_QUANT")*oGrdSG1:GetValue("G1_PERDA"))/100),;
				oGrdSG1:GetValue("G1_QUANT")*M->NP9_QUANT+((oGrdSG1:GetValue("G1_QUANT")*M->NP9_QUANT)*oGrdSG1:GetValue("G1_PERDA")/100))
			AGRLOADVALUE(oGrdSG1,{{'B2_QATU',nQtdePA / nqtdBase}})
			//Final - Novo modo
			If ValType(oView) != "U"
				oView:Refresh('VIEW_SG1')
			EndIf
			cComponP := cCompAxu
		EndIf
	EndIf
Return

/*
############################################################################
# Função   : AGR840RECE                                                    #
# Descrição: Recalcula a quantidade a ser consumida                        #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 14/08/2014                                                    #  
############################################################################
*/
Function AGR840RECE()
	Local aAreaAtu 	:= GetArea()
	Local oModel	 := FwModelActive(),nx
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local nLinxx  := oGrdSG1:GetLine()
	Local nqtdBase := 0
	AGRIFDBSEEK("SB1",FwFldGet("NP9_PROD"),1,.F.)
	nqtdBase := SB1->B1_QB
	M->NP9_OP := ' '

	AGRCAG1B8(,,,.t.)

	oModel:GetModel( 'ITEM' ):SetNoUpdateLine(.F.)
	For nx := 1 To oGrdSG1:Length()
		oGrdSG1:GoLine(nx)
		If oGrdSG1:GetValue("G1_FIXVAR") = "F"
			nQtdeF := oGrdSG1:GetValue("G1_QUANT")+((oGrdSG1:GetValue("G1_QUANT")*oGrdSG1:GetValue("G1_PERDA"))/100)
			nQtdeF := Ceiling( (nQtdeF * (M->NP9_QUANT / nqtdBase) ))
		else
			nQtdeF := oGrdSG1:GetValue("G1_QUANT")*M->NP9_QUANT+((oGrdSG1:GetValue("G1_QUANT")*M->NP9_QUANT)*oGrdSG1:GetValue("G1_PERDA")/100)
			nQtdeF :=  (nQtdeF / nqtdBase) 
		EndIf	
		oGrdSG1:SetValue('B2_QATU', nQtdeF ) // Ceiling - Calcula o arrendodamento (para cima) do valor do ponto flutuante.

	Next nx
	oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
	oGrdSG1:GoLine(nLinxx)

	If ValType(oView) != "U"
		oView:Refresh('VIEW_SG1')
	EndIf
	RestArea(aAreaAtu)
Return .T.

/*
############################################################################
# Função   : AGR840LQTD                                                    #
# Descrição: Verifica se habilita campo de quantidade do lote              #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 14/08/2014                                                    #  
############################################################################
*/
Function AGR840LQTD()
	Local oModel	 := FwModelActive()
	Local oGrdSB8	 := oModel:GetModel("ITEM2")
	nQTDSAL := oGrdSB8:GetValue("B8_SALDO")
Return If(nQTDSAL > 0,.t.,.f.)

/*
############################################################################
# Função   : AGR840LOBF                                                    #
# Descrição: Verifica se habilita campo de localização                     #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 15/08/2014                                                    #  
############################################################################
*/
Function AGR840LOBF()
Return If(ReadVar() = "M->BF_LOCALIZ",.F.,.T.)

/*
############################################################################
# Função   : AGR840VQTD                                                    #
# Descrição: Consistência da quantidade a baixar e gravação no temporário  #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 15/08/2014                                                    #  
############################################################################
*/
Function AGR840VQTD()
	Local oModel	 := FwModelActive()
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local oGrdSB8	 := oModel:GetModel("ITEM2")
	Local nQTDSol    := oGrdSG1:GetValue("B2_QATU")
	Local nSaldoD    := oGrdSB8:GetValue("B8_SALDO")
	Local nLinha     := oGrdSB8:GetLine()
	Local nLiSG1     := oGrdSG1:GetLine()
	Local cLoteGr    := oGrdSB8:GetValue("B8_LOTECTL")
	Local cLocalB    := oGrdSG1:GetValue("NP9_LOCAL")
	Local cLocaliz   := oGrdSB8:GetValue("BF_LOCALIZ")
	Local nQTDInf,lRet := .t.,cMensa := Space(1),nPosT,nPosM
	Store 0 To nQTDInf,nPosT,nPosM

	oGrdSG1:GoLine(nLiSG1)
	nQTDSol  := oGrdSG1:GetValue("B2_QATU")
	cComponP := oGrdSG1:GetValue("G1_COMP")

	If ReadVar() = "M->B8_QTDORI"
		If M->B8_QTDORI > nSaldoD
			cMensa := STR0048
		Else
			If !AGRA840S8F(cComponP,cLocalB,CriaVar("B8_NUMLOTE"),cLoteGr,M->B8_QTDORI)
				Return .f.
			EndIf
			If AGRIFDBSEEK("SB5",cComponP,1,.f.) .And. SB5->B5_SEMENTE = "1"
				/*If Alltrim(Str(M->B8_QTDORI,16)) <> Alltrim(Str(nQTDSol,16))
					cMensa := STR0024+" "+Alltrim(cComponP)+" "+STR0049
				EndIf*/
			Else
				If M->B8_QTDORI > nQTDSol
						cMensa := STR0047+" "+cComponP						
				EndIf
			EndIf
		EndIf
		If !Empty(cMensa)
				Help(,1,"HELP",,cMensa,1,0)
				lRet := .f.
		Else
				AGRAREAORDE(cAlT,4)
				AGRALTRBCAMP(cAlT,cComponP+cLocalB+clocaliz+cLoteGr,4,"B8_QTDORI",M->B8_QTDORI)
				AGRAREAORDE(cAlT,1)
		EndIf
	ElseIf ReadVar() $ "M->BC_QUANT|M->BC_TIPO|M->BC_MOTIVO"
		AGRAREAORDE(cAlT,2)
		If ReadVar() $ "M->BC_QUANT"
				AGRALTRBCAMP(cAlT,cComponP+cLoteGr,2,"BC_QUANT",M->BC_QUANT)
			If Empty(M->BC_QUANT)
					AGRALTRBCAMP(cAlT,cComponP+cLoteGr,2,"BC_TIPO"," ")
					AGRALTRBCAMP(cAlT,cComponP+cLoteGr,2,"BC_MOTIVO",Space(Len(SBC->BC_MOTIVO)))
					AGRLIMPCMVC(oGrdSB8,nLinha,{"BC_TIPO","BC_MOTIVO"})
			EndIf
		ElseIf ReadVar() $ "M->BC_TIPO"
				AGRALTRBCAMP(cAlT,cComponP+cLoteGr,2,"BC_TIPO",M->BC_TIPO)
		ElseIf ReadVar() $ "M->BC_MOTIVO"
				AGRALTRBCAMP(cAlT,cComponP+cLoteGr,2,"BC_MOTIVO",M->BC_MOTIVO)
		EndIf
			AGRAREAORDE(cAlT,1)
	EndIf
	oGrdSB8:GoLine(nLinha)

Return lRet

/*
############################################################################
# Função   : AGR840CHLINE                                                  #
# Descrição: Controle de navegação nos componentes da estrutura            #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 15/08/2014                                                    #  
############################################################################
*/
Function AGR840CHLINE(oModelx, cPergF11)
	Local oGrdSG1 := oModel:GetModel("ITEM")
	PERGUNTE(cPergF11,.f.)
	If lF11 .And. (!Empty(MV_PAR01) .Or. !Empty(MV_PAR02) .Or. !Empty(MV_PAR03) .Or. !Empty(MV_PAR04))
		AGRCAG1B8("F11",MV_PAR04)
		lF11 := .f.
	EndIf
	cComponP := oGrdSG1:GetValue("G1_COMP")
	ARG840GRID2()
Return .t.

//----------------------------------------------------------------
/*/{Protheus.doc} AGR840GRV
Efetua inclusão da ordem de produção. Aponta a produção automaticamente 
para produto com controle de lote.

@author Cleber Maldonado
@since 14/02/2013
/*/
//----------------------------------------------------------------
Static Function AGR840GRV( oModel )
	Local lRet		:= .T.
	Local cTipLote	:= FwFldGet("NP9_TIPLOT")
	Local aApont := {},aProduc := {}
	Local nQtdNec,nTotLot
	Local cNumBloq,cChavOp,cChavIt,cChavSeq,cStatus,cTipLot
	Local oModCabec  := oModel:GetModel("CABEC")

	Private lMSHelpAuto,lGEROUEMP
	Private lMSErroAuto	:= .F.
	Private vVetOP		:= {}
	Private cNumDoc	   	:= CriaVar("D3_DOC") //usado função CriaVar para permitir uso do inicializador do campo via dicionario, permitindo customizar   
	Private cNuDocPai   := cNumDoc
	Private cCCustoPai 	:= AGRINICIAVAR("B1_CC",.T.)
	Private cSeqSD3     := AGRINICIAVAR("D3_NUNSEQ",.T.)
	Private nOperac	   	:= oModel:GetOperation()

	Store .t. To lMSHelpAuto,lGEROUEMP
	Store ""  To cNumBloq,cChavOp,cChavIt,cChavSeq,cStatus
	Store 0   To nQtdNec,nTotLot

	If(!AGR840B2QT()) .And. cTipLote <> "2" /* Comprado */ //"Todos os campos de quantidade a consumir estão zerados"###"Informe a quantidade de um item."
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0195, STR0196, "", "")
		Return .F.
	EndIf

	l250 := .F. 	 // Variável usada no MATA250
	SaveInter()   // Salva as Variaveis publicas
	nModulo := 10 // Seta modulo para PCP e verifica número de documento

	Begin Transaction
		If (cTipLote = "1") // Caso o lote for do tipo comprado(2) não é nescessario fazer à baixa no estoque
			If nOperac == 3
				DbSelectArea("SC2")
				If Empty(cNumOp2)
					cNumOp2 := GetNumSc2()
					ConfirmSX8()
				EndIf
				If Empty(cNumDoc)
					cNumDoc   := NextNumDoc()
					cNuDocPai := cNumDoc
				EndIf
			Else
				Aadd(aApont,{"D3_OP",cNumOp3,Nil})
			EndIf

			Aadd(aApont, {"D3_DOC",cNumDoc,Nil})
			Aadd(aProduc,{"C2_NUM",cNumOp2,Nil})

			AGRIFDBSEEK("SB1",FwFldGet("NP9_PROD"),1,.F.)
			cCCustoPai := If(!Empty(FwFldGet("NP9_CCUSTO")),FwFldGet("NP9_CCUSTO"),If(Empty(cCustoS),SB1->B1_CC,cCustoS))

			//Adiciona os dados em arrays para rotinas automaticas
			If lNovaOp
				Aadd(aProduc,{"C2_ITEM"	  ,"01"		   			 ,Nil})
				Aadd(aProduc,{"C2_SEQUEN" ,"001"				 ,Nil})
				Aadd(aProduc,{"C2_PRODUTO",FwFldGet("NP9_PROD")	 ,Nil})
				Aadd(aProduc,{"C2_QUANT"  ,FwFldGet("NP9_QUANT") ,Nil})
				Aadd(aProduc,{"C2_LOCAL"  ,FwFldGet("NP9_LOCAL") ,Nil})
				Aadd(aProduc,{"C2_DATPRI" ,FwFldGet("NP9_DATA")	 ,Nil})
				Aadd(aProduc,{"C2_DATPRF" ,dDataBase          	 ,Nil})
				Aadd(aProduc,{"C2_EMISSAO",FwFldGet("NP9_DATA")	 ,Nil})
				Aadd(aProduc,{"C2_TPOP"   ,"F"           		 ,Nil})
				Aadd(aProduc,{"C2_QUJE"   ,0					 ,Nil})
				Aadd(aProduc,{"C2_CC"     ,cCCustoPai			 ,Nil})
				if NP9->(ColumnPos('NP9_TPPR' )) > 0
					Aadd(aProduc,{"C2_TPPR",FwFldGet("NP9_TPPR")	 ,Nil})
				EndIF
			EndIf

			Aadd(aApont,{"D3_TM"     ,cTM           		,Nil})
			Aadd(aApont,{"D3_COD"    ,FwFldGet("NP9_PROD")	,Nil})
			Aadd(aApont,{"D3_UM"     ,FwFldGet("NP9_UM")	,Nil})
			Aadd(aApont,{"D3_QUANT"  ,FwFldGet("NP9_QUANT")	,Nil})
			Aadd(aApont,{"D3_LOCAL"  ,FwFldGet("NP9_LOCAL")	,Nil})
			Aadd(aApont,{"D3_EMISSAO",FwFldGet("NP9_DATA")  ,Nil})
			Aadd(aApont,{"D3_LOTECTL",FwFldGet("NP9_LOTE")	,Nil})
			Aadd(aApont,{"D3_DTVALID",FwFldGet("NP9_DTVAL")	,Nil})
			Aadd(aApont,{"D3_CC"     ,cCCustoPai			,Nil})
			Aadd(aApont,{"D3_CODSAF" ,FwFldGet("NP9_CODSAF"),Nil})
			AGRQUEBRAFIL("SF5")

			If nOperac == 3
				If lNovaOp

					// Permite manipular os dados antes executar a rotina automatica para criar da ordem de produção (SC2)
					If ExistBlock("AGR840P5")
						aRet := ExecBlock("AGR840P5",.F.,.F.,{aProduc})
						If ValType(aRet) == "A"
							aProduc := aClone(aRet)
						EndIf
					EndIf

					MSExecAuto({|x,y| mata650(x,y)},aProduc,nOperac)

					If lMsErroAuto
						MostraErro()
						lGerouOp := .f.
					EndIf
					cSeqSD3 := SD3->D3_NUMSEQ
					cNumOp3 := Alltrim(cNumOp2+'01001')
					cNumOp3 := cNumOp3+Space(Len(SD3->D3_OP)-Len(cNumOp3))
				EndIf

				If lGerouOp
					Aadd(aApont, {"D3_OP", cNumOP3, Nil})

					// Permite manipular os dados antes executar a rotina automatica para criar os insumos da produção (SD3)
					If ExistBlock("AGRA840P")
						aRet := ExecBlock("AGRA840P",.F.,.F.,{aApont})
						If ValType(aRet) == "A"
							aApont := aClone(aRet)
						EndIf
					EndIf

					If !AGRIFDBSEEK("SB2",FwFldGet("NP9_PROD")+FwFldGet("NP9_LOCAL"),1,.f.)
						CriaSB2(FwFldGet("NP9_PROD"),FwFldGet("NP9_LOCAL"))
					EndIf

					//Movimentas os insumos
					Aadd(vVetOP,STR0083+"..: "+cNumOp3)
					Aadd(vVetOP," ")
					Aadd(vVetOP,STR0084)
					AGR840GEM(oModel)

					// PERDA
					If nOperac == 3 .And. !Empty(aItePe)
						AGR840PEDE()
					EndIf

					MsExecAuto({|x,y| MATA250(x,y)},aApont,nOperac) // Apontamento da Produção

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					Else
						If AGRIFDBSEEK("SD3",cNumDoc,2,.f.) //Grava o centro de custo para todos os itens gerado do documento.
							While !("SD3")->(Eof()) .And. xFilial("SD3") == SD3->D3_FILIAL .And. cNumDoc == SD3->D3_DOC .And. Alltrim(cNumOp3) == Alltrim(SD3->D3_OP)
								AGRTRAVAREG()
								SD3->D3_CC := cCCustoPai
								AGRDESTRAREG()
								cNuDocPai  := SD3->D3_DOC
								SD3->(DBskip())
							End
						Else
							//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
							lRet := .F.
							DisarmTransaction()
							Break
						EndIf
						cSeqSD3 := SD3->D3_NUMSEQ
					Endif
				EndIf

				If !lGEROUEMP

					MsExecAuto({|x,y| MATA250(x,y)},aApont,5)
				EndIf
				AGRQUEBRAFIL("SF5")
			EndIf
		Else
			FwFldPut("NP9_STATUS","2") // Deixa o lote com Disponivel
		Endif

	End Transaction

	//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
	If !lRet
		Alert(STR0137+chr(13)+STR0181+chr(13)+STR0182+" (SX3, SD3)"+chr(13)+STR0183)
		Return
	EndIf

	nModulo := 67

	If !lMsErroAuto
		If cLoteTSI = Nil
			FwFldPut("NP9_STATUS","1")
			FwFldPut("NP9_OP",cNumOp3)
			FWFormCommit(oModel)
			If nOperac == 3 .And. Empty(aEstrSG1)
				AGRALTCAMBA("NP9",FwFldGet("NP9_CODSAF")+FwFldGet("NP9_PROD")+FwFldGet("NP9_LOTE"),1,"NP9_TIPLOT","2")
			EndIf
			AGRALTCAMBA("NP9",FwFldGet("NP9_CODSAF")+FwFldGet("NP9_PROD")+FwFldGet("NP9_LOTE"),1,"NP9_RENASE",GetMv("MV_AGRRENA"))
		Else
			AGRIFDBSEEK("NP9",NP9->NP9_CODSAF+cProdNP9+NP9->NP9_LOTE,1,.f.)
			cDocNFE := NP9->NP9_DOC
			cSerNFE := NP9->NP9_SERIE
			cForNFE := NP9->NP9_FORNEC
			cLojNFE := NP9->NP9_LOJA
			cStatus := NP9->NP9_STATUS
			cRenase := NP9->NP9_RENASE
			cTipLot := NP9->NP9_TIPLOT
			If AGRIFDBSEEK("NP9",NP9->NP9_CODSAF+FwFldGet("NP9_PROD")+NP9->NP9_LOTE,1,.f.)
				AGRTRAVAREG("NP9",.F.)
				NP9->NP9_QUANT 	+= FwFldGet("NP9_QUANT")
				NP9->NP9_QTD2UM	+=	ConvUm(FwFldGet("NP9_PROD"),FwFldGet("NP9_QUANT"),0,2)
				NP9->NP9_STATUS	:= cStatus
				AGRDESTRAREG("NP9")
			Else
				FWFormCommit( oModel )
				AGRTRAVAREG("NP9",.F.)
				NP9->NP9_OP    	:= cNumOp3
				NP9->NP9_STATUS	:= cStatus
				NP9->NP9_RENASE	:= If(cTipLot = "2",cRenase,GetMv("MV_AGRRENA"))
				AGRDESTRAREG("NP9")
			EndIf
			DbSelectArea("NP9")
			AGRTRAVAREG(,.F.)
			NP9->NP9_DOC		:= cDocNFE
			NP9->NP9_SERIE	:= cSerNFE
			NP9->NP9_FORNEC	:= cForNFE
			NP9->NP9_LOJA		:= cLojNFE
			AGRDESTRAREG()
		EndIf

		AGRIFDBSEEK("NP9",FwFldGet("NP9_CODSAF")+FwFldGet("NP9_PROD")+FwFldGet("NP9_LOTE"),1,.f.)

		If NP9->NP9_TIPLOT <> "2" .And. cReutOp = '1'
			AGRALERTESP(STR0083,vVetOP)
		EndIf

		If localiza(NP9->NP9_PROD) .And. NP9->NP9_TIPLOT = "1"
			AGRA840EN()
		EndIf
		AG840LDGOP(oModCabec:GetValue("NP9_LOTE"))//Grava na NP9 o campo de Lote quando for gerado automáticamente.
	Else
		oModel:SetErrorMessage( , , , , , "Não foi possível gerar apontamento para o lote.")
		lRet := .F.
	Endif
	RestInter()

	AGR840CAN()
	lF11	:= .T.
	INCLUI	:= .F.
Return lRet

/*
############################################################################
# Função   : AGR840GEM                                                     #
# Descrição: Gera empenhos e movimentações                                 #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 19/08/2014                                                    # 
# Parâmet. : oModel - Objeto model                                         #  
############################################################################
*/   
Function AGR840GEM(oModel)
	Local cNumD3N
	Local oGrdSG1	 := oModel:GetModel("ITEM")
	Local nx

	Private aCab	:= {},aItens :={}
	Private lSeloFiscal,lAtuSD3,l241,l242

	Store .f.     To lSeloFiscal,lAtuSD3,l241,l242
	Store cNumDoc To cNumD3N

	aRotina := AGREMULAROT()
	nModulo := 4

	DbselectArea("SD3")
	// Carrega cabeçalho do movimento
	aCab := {{"D3_DOC"	  ,cNumDoc			   ,Nil},;
		{"D3_EMISSAO",FwFldGet("NP9_DATA"),Nil},;
		{"D3_TM"     ,cMovsai  		   ,Nil},;
		{"D3_ESTORNO","N"      		   ,Nil}}
	aItens := {}
	aItePe := {}

	For nx := 1 To oGrdSG1:Length()
		oGrdSG1:GoLine(nx)
		cProduto := oGrdSG1:GetValue("G1_COMP")
		nQtde    := oGrdSG1:GetValue("B2_QATU")
		cLocal   := oGrdSG1:GetValue("NP9_LOCAL")
		cLocaliz := CriaVar("D3_LOCALIZ")
		cLoted3  := CriaVar("D3_LOTECTL")
		nQtdPe   := oGrdSG1:GetValue("D3_PERDA")
		cTipo	 := oGrdSG1:GetValue("BC_TIPO")
		cMotivo	 := oGrdSG1:GetValue("BC_MOTIVO")
		If nQtde > 0 .and. .Not. oGrdSG1:IsDeleted()
			AGRIFDBSEEK("SB1",cProduto,1,.f.)
			// Verifica se o item tem lote
			If AGRIFSEETRB(cAlT,cProduto,1,.f.)
				While !Eof() .And. (cAlT)->B8_PRODUTO = oGrdSG1:GetValue("G1_COMP")
					If !Empty((cAlT)->B8_QTDORI)
						AGR840ID3((cAlT)->B8_LOTECTL,(cAlT)->B8_QTDORI,(cAlT)->BF_LOCALIZ,(cAlT)->BC_QUANT,(cAlT)->BC_TIPO,(cAlT)->BC_MOTIVO)
						cLoted3	 := (cAlT)->B8_LOTECTL
						nQtde		 := (cAlT)->B8_QTDORI
						cLocaliz := (cAlT)->BF_LOCALIZ
						nQtdPe   := (cAlT)->BC_QUANT
						cTipo		 := (cAlT)->BC_TIPO
						cMotivo	 := (cAlT)->BC_MOTIVO
					Endif
					AGRDBSELSKIP(cAlT)
				End
			Else
				cLoted3 := CriaVar("B8_LOTECTL")
				AGR840ID3(cLoted3,nQtde,cLocaliz,nQtdPe,cTipo,cMotivo)
			EndIf
		EndIf
	Next nx
	If !Empty(aItens)
		lMsErroAuto := .F.

		MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab,aItens,Nil)

		If lMsErroAuto
			lGEROUEMP := .F.
			Mostraerro()
		EndIf
	EndIf

	AGRQUEBRAFIL("SF5")
	nModulo := 67
Return

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840ID3                                                                           |
| Descrição : Carrega matriz e gera empenho                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 05/12/2014                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840ID3(clote,nQtde,cLocaliz,nQtdPe,cTipo,cMotivo)
	AGRIFDBSEEK("SB1",cProduto,1,.f.)

	Aadd(aItens,{})
	Aadd(aTail(aItens),{"D3_COD"    ,cProduto                                                     	,Nil})
	Aadd(aTail(aItens),{"D3_QUANT"  ,nQtde                                                        	,Nil})
	Aadd(aTail(aItens),{"D3_LOCAL"  ,cLocal															,Nil})
	Aadd(aTail(aItens),{"D3_OP"     ,cNumOp3														,Nil})
	Aadd(aTail(aItens),{"D3_UM"     ,SB1->B1_UM														,Nil})
	Aadd(aTail(aItens),{"D3_CC"     ,cCCustoPai														,Nil})
	Aadd(aTail(aItens),{"D3_LOTECTL",cLote															,Nil})
	Aadd(aTail(aItens),{"D3_CF"     ,"RE0"                                                        	,Nil})
	Aadd(aTail(aItens),{"D3_NUMLOTE",CriaVar('D3_NUMLOTE')                                        	,Nil})
	Aadd(aTail(aItens),{"D3_DTVALID",CriaVar('D3_DTVALID')                                        	,Nil})
	Aadd(aTail(aItens),{"D3_CHAVE"  ,SubStr(SD3->D3_CF,2,1)+If(SD3->D3_CF $ 'RE4|DE4','9','0')    	,Nil})
	Aadd(aTail(aItens),{"D3_USUARIO",If(Len(SD3->D3_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))	,Nil})
	Aadd(aTail(aItens),{"D3_NUMSEQ" ,ProxNum()                                                    	,Nil})
	Aadd(aTail(aItens),{"D3_CONTA"  ,SB1->B1_CONTA                                                	,Nil})
	Aadd(aTail(aItens),{"D3_ITEMCTA",SB1->B1_ITEMCC                                               	,Nil})
	Aadd(aTail(aItens),{"D3_SEGUM"  ,SB1->B1_SEGUM                                                	,Nil})
	Aadd(aTail(aItens),{"D3_QTSEGUM",ConvUm(cProduto,nQtde,0,2)										,Nil})
	Aadd(aTail(aItens),{"D3_GRUPO"  ,SB1->B1_GRUPO                                                	,Nil})
	Aadd(aTail(aItens),{"D3_TIPO"   ,SB1->B1_TIPO                                                 	,Nil})
	Aadd(aTail(aItens),{"D3_LOCALIZ",If(!Empty(cLocaliz),cLocaliz,CriaVar('D3_LOCALIZ'))    		,Nil})
	Aadd(aTail(aItens),{"D3_STSERV" ,"1"                 											,Nil})
	Aadd(aTail(aItens),{"D3_CODSAF" ,FwFldGet("NP9_CODSAF")											,Nil})
	Aadd(aTail(aItens),{"D3_DOC"    ,CriaVar('D3_DOC')												,Nil})

	Aadd(vVetOP,Alltrim(cProduto)+" - "+SubStr(SB1->B1_DESC,1,25)+"  "+Str(nQtde,15,2))
	// Permite manipular os dados antes executar a rotina automatica para criar a produção
	If ExistBlock("AGR840PI")
		aRet := ExecBlock("AGR840PI",.F.,.F.,{aCab,aItens[len(aItens)]})
		If ValType(aRet) == "A"
			aItens[len(aItens)] := aClone(aRet)
		EndIf
	Endif

	// PERDA
	If !Empty(nQtdPe)
		Aadd(aItePe,{cProduto,cLocal,nQtdPe,cTipo,cMotivo,cLocaliz,cLote})
	EndIf
Return .t.

//----------------------------------------------------------------
/*/{Protheus.doc} AGR840POS
Efetua validação dos dados para posterior envio a gravação.

@author Cleber Maldonado
@since 14/02/2013
/*/
//----------------------------------------------------------------
Static Function AGR840POS(oModel)
	Local lHelp   := .f.,lRet := .T.
	Local cProd	 := FwFldGet("NP9_PROD")
	Local nQtdNec := 0, nTotLot := 0
	Local cMensa  := " ",nx
	Local oGrdSG1	 := oModel:GetModel("ITEM")

	If oModel:GetOperation() = 4
		Return .t.
	EndIf

	If oModel:GetOperation() = 3 .And. cTipoPro = Nil .And.;
			AGRIFDBSEEK("NP9",FwFldGet("NP9_CODSAF")+FwFldGet("NP9_PROD")+FwFldGet("NP9_LOTE"),1,.f.)
		Help(" ",1,"REGNOS",,STR0159,3,0)
		Return .f.
	EndIf

	For nx := 1 To oGrdSG1:Length()
		oGrdSG1:GoLine(nx)
		cLocalC := oGrdSG1:GetValue("NP9_LOCAL")
		If Empty(cLocalC)
			oGrdSG1:SetValue('NP9_LOCAL',FwFldGet("NP9_LOCAL"))
		EndIf
	Next nx
	oGrdSG1:GoLine(1)
	If ValType(oView) != "U"
		oView:Refresh('VIEW_SG1')
	EndIf
	cComponP := oGrdSG1:GetValue("G1_COMP")
	ARG840GRID2()

	For nx := 1 To oGrdSG1:Length()
		oGrdSG1:GoLine(nx)
		nQtdNec := oGrdSG1:GetValue("B2_QATU")
		nQtdPer := oGrdSG1:GetValue("D3_PERDA")
		cProdut := oGrdSG1:GetValue("G1_COMP")
		cLocalC := oGrdSG1:GetValue("NP9_LOCAL")
		cLocali := oGrdSG1:GetValue("D3_LOCALIZ")
		cTipo		:= oGrdSG1:GetValue("BC_TIPO")
		cMotivo	:= oGrdSG1:GetValue("BC_MOTIVO")
		nTotLot := 0
		cMensa  := Space(1)
		If nQtdNec > 0 .and. .Not. oGrdSG1:IsDeleted()
			Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_DESC")
			If cLocalC = cLocalPR
				cMensa := STR0103+" (MV_LOCPROC) "+STR0110+" "+Alltrim(Str(nx,3))
				Exit
			EndIf
			If !AGRIFDBSEEK("SB2",cProdut+cLocalC,1,.f.)
				cMensa := Alltrim(AGRTITULO("B2_LOCAL"))+" "+cLocalC+"  "+STR0099+" "+Alltrim(cProdut)+" "+STR0100+" "+Str(nx,3)+" "+STR0102+" "+AGRSX2NOME("SB2")
				Exit
			EndIf

			// PERDA
			cMensa := AGR840GDVAL(nQtdPer,nQtdNec,cTipo,cMotivo,nx,STR0040,STR0042)
			If !Empty(cMensa)
				Help(" ",1,"AGR840PSAL",,cMensa,3,0)
				Return .f.
			EndIf

			If !IsProdMod(SB1->B1_COD,1,3)
				If Rastro(cProdut) .And. !AGRIFSEETRB(cAlT,cProdut,1,.f.)
					cMensa := STR0104+" "+STR0100+" "+Str(nx,3)+" "+AGRSX2NOME("SB8")
					Exit
				EnDif

				If AGRIFSEETRB(cAlT,cProdut,1,.f.)
					nSB8L := 0
					While !Eof() .And. (cAlT)->B8_PRODUTO = cProdut
						nTotLot += (cAlT)->B8_QTDORI
						nSB8L ++
						// PERDA
						cMensa := AGR840GDVAL((cAlT)->BC_QUANT,(cAlT)->B8_QTDORI,(cAlT)->BC_TIPO,(cAlT)->BC_MOTIVO,nSB8L,STR0043,STR0025)
						If !Empty(cMensa)
							Help(" ",1,"AGR840PSAL",,cMensa,3,0)
							Return .f.
						EndIf

						AGRDBSELSKIP(cAlT)
					End

					If !Empty(cMensa)
						Exit
					ElseIf nTotLot <> nQtdNec
						cMensa := STR0050+" "+cProdut
						Exit
					EndIf
				Else
					If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") = "S"
						If Empty(cLocali)
							cMensa := STR0094+"  "+Str(nx,2)
							Exit
						Else
							nSldSBF := SaldoSBF(cLocalC,cLocali,cProdut,CriaVar("D3_NUMSERI"),CriaVar("D3_LOTECTL"))
							If nQtdNec > nSldSBF
								cMensa := STR0035+" "+Alltrim(cProdut)+Chr(13)+Chr(13)+STR0037+" "+STR0095+"..: "+Str(nQtdNec,10,2)+Chr(13)+STR0057+"..: "+Str(nSldSBF,10,2)
								Exit
							EndIf
						EndIf
					Else
						Posicione("SB2",1,xFilial("SB2")+cProdut+cLocalC,"B2_CM1")
						nSaldoSB2 := SaldoSB2(.F.,.f.,FwFldGet("NP9_DATA")+365,lConsTerc)
						If nQtdNec > nSaldoSB2
							cMensa := STR0035+" "+Alltrim(cProdut)+Chr(13)+Chr(13)+STR0037+" "+STR0096+"..: "+Str(nQtdNec,10,2)+Chr(13)+STR0057+"..: "+Str(nSaldoSB2,10,2)
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nx

	If !Empty(cMensa)
		Help(" ",1,"AGR840PSAL",,cMensa,3,0)
		Return .f.
	EndIf

	AGRIFDBSEEK("SB1",cProd,1,.f.)
	If !lHelp .And. !Rastro(cProd)
		Help(" ",1,"NAORASTRO")
		lHelp := .T.
	EndIf

	If !lHelp .and. Empty(cTM)
		Help("  ",1,"AGR840PAR")
		lHelp := .T.
	EndIf

	If !lHelp
		AGRQUEBRAFIL("SF5")
		If !MsSeek(xFilial("SF5")+SubStr(cTM,1,Len(SF5->F5_CODIGO)))
			Help("  ",1,"AGR840MOV")
			lHelp := .T.
		Endif
	Endif

	If !lHelp
		If GetMv("MV_AGRGEOP") = '1' .And. Empty(FwFldGet("NP9_OP"))
			Help(,1,"HELP",,STR0169+" "+STR0170+" "+AGRTITULO("NP9_OP   "),1,0)
			lHelp := .T.
		EndIf
	EndIf

	If !lHelp
		If ExistBlock("AGR840P4")
			lHelP := ExecBlock("AGR840P4",.F.,.F.)
		EndIf
	EndIf

	If lHelp
		lRet := .F.
	Endif
Return lRet

	//----------------------------------------------
	/*/{Protheus.doc} NextNumDoc()
	Retorna o proximo numero de documento disponivel

	@param: Nil
	@author: Cleber Maldonado
	@since: 26/11/2012
	@Uso: AGRA840
	/*/
//----------------------------------------------
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumDoc 	:= "",cMay := ""

	// Inicializa o numero do Documento com o ultimo + 1³
	DbSelectArea("SD3")
	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	AGRQUEBRAFIL("SF5")
	cNumDoc := A261RetINV(cNumDoc)
	dbSelectArea("SD3")
	dbSetOrder(2)
	dbSeek(cFilAnt+cNumDoc)
	cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # "S"
			cNumDoc := Soma1(cNumDoc)
			cMay    := "SD3"+Alltrim(cFilAnt)+cNumDoc
		EndIf
		DbSkip()
	End

	RestArea(aAreaAtu)
Return cNumDoc

	//----------------------------------------------
	/*/{Protheus.doc} AGR840VCPO()
	Efetua a validação dos dados e bloqueio da alteração do mesmo caso estejam na tabela SB5 .

	@param: Nil
	@author: Maicol Lange
	@since: 11/12/2013
	@Uso: AGRA840
	/*/
//----------------------------------------------
Function AGR840VCPO()
	Local lRetorno 	:= .T.,cMensa := Space(1)
	If cLoteTSI = Nil
		AGRIFDBSEEK("SB5",M->NP9_PROD,1,.F.)
		//Check a cultura - NP3
		If AllTrim(ReadVar()) $ "M->NP9_CULTRA"
			If Empty(SB5->B5_CULTRA )
				lRetorno := ExistCpo("NP3")
				M->NP9_CTRDES := SubStr(Posicione("NP3",1,Xfilial("NP3")+M->NP9_CULTRA,"NP3_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTRDES",2,"X3_TAMANHO"))
			Else
				If SB5->B5_CULTRA <> M->NP9_CULTRA
					cMensa := STR0016
				EndIf
			EndIf

			//Check o cultivador - NP4
		ElseIf AllTrim(ReadVar()) $ "M->NP9_CTVAR"
			If Empty(SB5->B5_CTVAR)
				lRetorno := ExistCpo("NP4")
				M->NP9_CTVDES := SubStr(Posicione("NP4",1,Xfilial("NP4")+M->NP9_CTVAR,"NP4_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTVDES",2,"X3_TAMANHO"))
			Else
				If SB5->B5_CTVAR <> M->NP9_CTVAR
					cMensa := STR0017
				EndIf
			EndIf

			//Check o categoria - K1
		ElseIf AllTrim(ReadVar()) $ "M->NP9_CATEG"
			If Empty(SB5->B5_CATEG)
				lRetorno := ExistCpo('SX5','K1'+M->NP9_CATEG)
			Else
				If !Empty(SB5->B5_CATEG) .and. SB5->B5_CATEG <> M->NP9_CATEG
					cMensa := STR0018
				EndIf
			EndIf

			//Check a peneira - NP7
		ElseIf AllTrim(ReadVar()) $ "M->NP9_PENE"
			If Empty(SB5->B5_PENE)
				lRetorno := ExistCpo("NP7")
				M->NP9_PENDES := SubStr(Posicione("NP7",1,Xfilial("NP7")+M->NP9_PENE,"NP7_DESCRI"),1,AGRSEEKDIC("SX3","NP9_PENDES",2,"X3_TAMANHO"))
			Else
				If SB5->B5_PENE <> M->NP9_PENE
					cMensa := STR0019
				EndIf
			EndIf
		EndIf

		If !Empty(cMensa)
			Help(,1,"HELP",,cMensa,1,0)
			lRetorno := .f.
		EndIf
	EndIf
Return lRetorno

/*
############################################################################
# Função   : AGR840APR                                                     #
# Descrição: Aprovação dos Lotes                                           #
# Autor    : Ana Laura Olegini    Refeito Inácio Luiz Kolling 18/02/15     #
# Data     : 08/10/2014                                                    #  
############################################################################
*/
Function AGR840APR()
	If !AGRA840TLO(STR0069)
		Return
	EndIf
	If NP9->NP9_STATUS = "1" .Or. NP9->NP9_STATUS = "3" // AGUARDANDO RESULTADO LABORATORIAL OU REJEITADO CQ
		If AGRGRAVAHIS(STR0061,"NP9",xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"A") = 1
			AGRTRAVAREG("NP9",.F.)
			NP9->NP9_STATUS := "2"
			AGRDESTRAREG()
		EndIf
	Else
		MSGINFO(STR0063)	// "Lote já aprovado!"
		Return
	EndIf
Return


/*/{Protheus.doc} AGR840REJ
//Rejeição do lote  
@author bruna.rocio
@since 14/12/2016
@version undefined
@type function
/*/
Function AGR840REJ(cHistDP, cTipoMs )
	Local aArea := GetArea()
	Local lRet  := .T.

	If NP9->NP9_TRATO <> '1' //1-Sim 2-Não
		If !AGRA840TLO(STR0070)
			lRet := .F.
		Endif
	Endif

	If lRet
		If NP9->NP9_STATUS $ "3" //= 3 REJEITADO
			Alert(STR0066) //Lote já rejeitado
		Else
			If AGRGRAVAHIS((STR0132+" "+ STR0133),"NP9",;
					xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"R") = 1
				If !Empty(cHistDP)
					AGRTRAVAREG("NK9",.F.)
					NK9->NK9_MSGMEM := NK9->NK9_MSGMEM+" "+Chr(13)+cHistDP
					If cTipoMs <> Nil
						NK9->NK9_TIPOMS := cTipoMs
					EndIf
					AGRDESTRAREG()
				EndIf

				AGRTRAVAREG("NP9",.F.)
				NP9->NP9_STATUS := "3"
				AGRDESTRAREG()

			EndIf
		EndIf
	Endif

	RestArea(aArea)
Return lRet



/*/{Protheus.doc} AGR840DSCT
//Função para registro do histórico de descarte do lote
@author bruna.rocio
@since 14/12/2016
@version undefined
@param cHistDP, characters, descricao
@param cTipoMs, characters, descricao
@type function
/*/
Function AGR840DSCT(cHistDP,cTipoMs)
	Local aArea := GetArea()

	If AGRGRAVAHIS((STR0064+" "+STR0134),"NP9",;
			xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"D") = 1
		If !Empty(cHistDP)
			AGRTRAVAREG("NK9",.F.)
			NK9->NK9_MSGMEM := NK9->NK9_MSGMEM+" "+Chr(13)+cHistDP
			If cTipoMs <> Nil
				NK9->NK9_TIPOMS := cTipoMs
			EndIf
			AGRDESTRAREG()
		EndIf
	EndIf

	RestArea(aArea)
Return

/*
############################################################################
# Função   : AGR840HIS                                                     #
# Descrição: Mostra em tela o Historico de aprovações e rejeições          #
# Autor    : Ana Laura Olegini   Inácio Luiz Kolling 18/02/2015            #
# Data     : 08/10/2014                                                    #  
############################################################################
*/
Function AGR840HIS()
	Local cChaveI := "NP9->("+Alltrim(AGRSEEKDIC("SIX","NP91",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))
	AGRHISTTABE("NP9",cChaveA)
Return

/*
############################################################################
# Função   : AGRA840VE                                                     #
# Descrição: Cadastramento de lotes ( Visualização / Exclusão )            #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 29/10/2014                                                    #  
############################################################################
*/
Function AGRA840VE(nOpcao)
    Local aAreaAnt      := GetArea()
	Local nx,ny,nOpca	:= 2
	Local lTemTSI 		:= .f.
	Local i				:= 0
	Local vVetC			:= {"D3_COD","B1_DESC","B8_QTDORI","D3_LOTECTL","D3_LOCAL"}
	Local aApont		:= {},vCampEdi	:= {},cLoteL := NP9->NP9_LOTE
	Local cCampNed,cStatus,cSafra,cProdP9
	Local cItemOP, cSeqOP
	Local aVetor    := {}
	Local lExcluiOP := .F.
	Local lRet      := .T.
	Local lFECHTO   := .F.
	Local cMvPar    := "mv_par04" //parametro pergunte MTA240 chamada no mata241
	Local lRestMVPar := .F. //valor logico para definir se deve restaurar pergunte MTA240

	Private aSize			:= MsAdvSize(,.f.,430),aObjects := {},aArraySB8 := {}
	Private nItemB		:= 0,nQtdB := 0,lContinua := .t.
	Private l241			:= .F.,l250 := .F.,l242 := .F.,l261 := .F. // Variaveis usadas na integração
	Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado := 0
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	DbSelectArea("NP9")
	nRegNP9 := Recno()

	If nOpcao = 4
		If NP9->NP9_TRATO = '1'
			Alert(STR0106+" "+STR0080)//"Lote de semente não pode ser alterado por motivo do status e/ou por ter"###"Geração de TSI"
			Return
		ElseIf !NP9->NP9_STATUS $ "12"
			Help(,1,"HELP",,STR0021,1,0) //#Lote não disponível ou já foi realizado o tratamento.
			Return
		ElseIf TCCanOpen("NP9","7") 
			If AGRIFDBSEEK("NP9",NP9->NP9_CODSAF+NP9->NP9_LOTE+NP9->NP9_PROD + "1",7,.F.)
				Alert(STR0197) //#Lote de semente possui TSI. Alteração não permitida.
				AGRAREAORDE("NP9",1)
				Return
			Endif
		EndIf

		cCampNed := "NP9_TIPLOT|NP9_LOTE|NP9_CODSAF|NP9_PROD|NP9_LOCAL|NP9_UM|NP9_QUANT|NP9_2UM|NP9_QTD2UM|NP9_TRATO|NP9_CLASS|NP9_OP"
		cCampNed += "NP9_DOCD3|NP9_DOCBLQ|NP9_STATUS|NP9_IR|NP9_CCUSTO||NP9_DTVAL"
		vVetCSX3 := AGRFACAESSX3({"NP9"},{'CAMPO'},.F.)
		For nx := 1 To Len(vVetCSX3)
			If !vVetCSX3[nx,1] $ cCampNed
				Aadd(vCampEdi,vVetCSX3[nx,1])
			EndIf
		Next nx
	EndIf

	AGRAREAORDE("NP9",1)
	Dbgoto(nRegNP9)
	cStatus := NP9->NP9_STATUS
	cSafra  := NP9->NP9_CODSAF
	cLoteP9 := NP9->NP9_LOTE
	cProdP9 := NP9->NP9_PROD

	bCampo := {|nCPO| Field(nCPO)}
	For i := 1 To FCount()
		M->&(EVAL(bCampo,i)) := &(EVAL(bCampo,i))
	Next i

	If nOpcao = 1
		If TCCanOpen("NP9","7") .and. AGRIFDBSEEK("NP9",NP9->NP9_LOTE+NP9->NP9_CODSAF+NP9->NP9_PROD + "1",7,.F.)
			Alert(STR0089) //#Lote de semente possui TSI. Exclusão não permitida.
			AGRAREAORDE("NP9",1)
			Return
		EndIf
		If NP9->NP9_TIPLOT = "2" .And. !Empty(NP9->NP9_DOC)
			Alert(STR0033+" "+STR0151)
			Return
		EndIf
		cAliasNPX := GetNextAlias()
		cQueryNPX := " SELECT NPX.NPX_LOTE FROM "+RetSqlName("NPX")+" NPX "
		cQueryNPX += " WHERE NPX.NPX_FILIAL = '"+Xfilial("NPX")+"' AND NPX.NPX_LOTE = '"+NP9->NP9_LOTE+"'"
		cQueryNPX += " AND NPX.NPX_CODPRO = '"+NP9->NP9_PROD+"' AND NPX.NPX_CODSAF = '"+NP9->NP9_CODSAF+"' AND NPX.D_E_L_E_T_ = '' "
		cQueryNPX += " Order by NPX_LOTE "
		cQueryNPX := ChangeQuery(cQueryNPX)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryNPX),cAliasNPX,.F.,.T.)
		DbGoTop()
		While !Eof()
			If !Empty((cAliasNPX)->NPX_LOTE)
				If !AGRYESNOMVC(STR0033+" "+STR0160+" "+Alltrim(AGRSX2NOME("NPX"))+"  "+STR0161,STR0098)
					ARGCLOSEAREA(cAliasNPX)
					Return
				Else
					Exit
				EndIf
			EndIf
			AGRDBSELSKIP(cAliasNPX)
		End
		ARGCLOSEAREA(cAliasNPX)
		AGRAREAORDE("NP9",1)
		DbGoto(nRegNP9)
	Endif

	If NP9->NP9_TRATO <> "1" .And. nOpcao = 1
		cAliasQ := GetNextAlias()
		cQuery2 := " SELECT NP9.NP9_TRATO FROM "+RetSqlName("NP9")+" NP9 "
		cQuery2 += " WHERE NP9.NP9_FILIAL = '"+Xfilial("NP9")+"' AND NP9.NP9_LOTE = '"+cLoteL+"' AND NP9.D_E_L_E_T_ = '' "
		cQuery2 += " Order by NP9_LOTE "
		cQuery2 := ChangeQuery(cQuery2)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQ,.F.,.T.)

		DbGoTop()
		While !Eof()
			If (cAliasQ)->NP9_TRATO = '1'
				lTemTSI := .t.
				Exit
			EndIf
			AGRDBSELSKIP(cAliasQ)
		End
		ARGCLOSEAREA(cAliasQ)
	EndIf
	nModulo := 10

	aRotina := AGREMULAROT()
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{050,050,.t.,.t.})
	aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj  := MsObjSize(aInfo, aObjects,.t.)
	aCols    := {}
	aHeader  := AGRCRIAGRID(,vVetC,.t.,.t.)
	vVetColu := {}

	For nx := 1 To Len(vVetC)
		Aadd(vVetColu,aScan(aHeader,{|x| AllTrim(x[2]) == vVetC[nx]}))
	Next nx

	cAliasQ := GetNextAlias()
	cQuery2 := " SELECT SD3.D3_OP,SD3.D3_COD,SD3.D3_LOCAL,SD3.D3_NUMSEQ,SD3.D3_QUANT,SD3.D3_DOC FROM "+RetSqlName("SD3")+" SD3 "
	cQuery2 += " WHERE SD3.D3_FILIAL = '"+Xfilial("SD3")+"' AND SD3.D3_TM = '"+cTm +"' AND SD3.D3_CF = 'PR0' AND SD3.D3_ESTORNO <> 'S'"
	cQuery2 += " AND D3_CODSAF = '"+NP9->NP9_CODSAF+"' AND SD3.D3_LOTECTL = '"+NP9->NP9_LOTE+"' AND D3_COD = '"+NP9->NP9_PROD+"' AND SD3.D_E_L_E_T_ = '' "
	cQuery2 += " Order by D3_OP "
	cQuery2 := ChangeQuery(cQuery2)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQ,.F.,.T.)

	DbGoTop()
	aArOp := {}
	aArPC := {}
	While !Eof()
		cDesSB1 := Posicione("SB1",1,Xfilial("SB1")+(cAliasQ)->D3_COD,"B1_DESC")
		Aadd(aArOp,{(cAliasQ)->D3_OP,(cAliasQ)->D3_COD,cDesSB1,(cAliasQ)->D3_QUANT,(cAliasQ)->D3_DOC})
		Aadd(aArPC,{(cAliasQ)->D3_COD,(cAliasQ)->D3_LOCAL,(cAliasQ)->D3_NUMSEQ,(cAliasQ)->D3_DOC})
		AGRDBSELSKIP(cAliasQ)
	End
	ARGCLOSEAREA(cAliasQ)

	If !lContinua
		Return
	EndIf

	If Empty(aArOp)
		Aadd(aArop,{" "," "," ",0.000," "})
	Endif

	aCols := {}
	AGRZERAACOLS(aHeader,aCols,.t.)

	Define MsDialog oDlgTela Title STR0023 From aSize[1],aSize[2] To aSize[4],aSize[3] PIXEL
	oDlgTela:lMaximized := .t.

	nOpEnc	  := nOpcao // 2 = Visualizar / 4 = Alterar / 1 = Excluir

	oPanel := TPanel():New(0,0,'',oDlgTela,, .T., .T.,,,, ,.F.,.F. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelTop := TPanel():New(0,0,'',oPanel,, .T., .T.,,,, (oPanel:nClientHeight * 0.65),.F.,.F. )
	oPanelTop:Align := CONTROL_ALIGN_TOP

	oPanelBot := TPanel():New(0,0,'',oPanel,, .T., .T.,,,, (oPanel:nClientHeight * 0.265),.F.,.F. )
	oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelLeft := TPanel():New(0,0,'',oPanel,, .T., .T.,,,(oPanel:nClientWidth * 0.50),,.F.,.F. )
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	oPanelLTop := TPanel():New(1,1,'',oPanelLeft,, .T., .T.,,,,8,.F.,.F. )
	oPanelLTop:Align := CONTROL_ALIGN_TOP
	oPanelLBot := TPanel():New(1,1,'',oPanelLeft,, .T., .T.,,,,,.F.,.F. )
	oPanelLBot:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelRigh := TPanel():New(1,1,'',oPanel,, .T., .T.,,,(oPanel:nClientWidth * 0.50),,.F.,.F. )
	oPanelRigh:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelRigT := TPanel():New(1,1,'',oPanelRigh,, .T., .T.,,,,8,.F.,.F. )
	oPanelRigT:Align := CONTROL_ALIGN_TOP
	oPanelRigB := TPanel():New(1,1,'',oPanelRigh,, .T., .T.,,,,,.F.,.F. )
	oPanelRigB:Align := CONTROL_ALIGN_ALLCLIENT

	oEnchoice := Msmget():New("NP9", Recno(),nOpEnc,,,,,{aSize[1],aSize[2],aSize[4]-170,aSize[3]},If(nOpEnc = 4,vCampEdi,),1,,,,oPanelTop)
	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	oFont := TFont():New('Arial',,,.T.,,,,,.T.,.F.)
	oSay1:= TSay():New(01,01,{||STR0083},oPanelLTop,,oFont,,,,.T.,CLR_BLUE,,120,10)

	@8,1 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(AGRTITULO('D3_OP')),OemToAnsi(AGRTITULO('D3_COD')),;
		OemToAnsi(AGRTITULO('B1_DESC')),OemToAnsi(AGRTITULO('D3_QUANT')),OemToAnsi(AGRTITULO('D3_DOC')) SIZE ((oPanel:nClientHeight + 8) * 0.265),92 PIXEL OF oPanelLBot
	oQual:SetArray(aArOp)
	oQual:bLine	  := {||{aArOp[oQual:nAT,1],aArOp[oQual:nAT,2],aArOp[oQual:nAT,3],aArOp[oQual:nAT,4],aArOp[oQual:nAT,5]}}
	oQual:bChange := {|| ARG840LOV(2)}
	oQual:Align := CONTROL_ALIGN_TOP

	oSay2:= TSay():New(01,01,{||STR0084},oPanelRigT,,oFont,,,,.T.,CLR_BLUE,,150,10)
	oGet := MSGetDados():New(8,1,(oPanel:nClientHeight * 0.265 - oPanelLTop:nHeight),100,3,"AllwaysTrue()","AllwaysTrue()",,.f.,,3,,Len(acols),,,,,oPanelRigB)
	oGet:oBrowse:Align := CONTROL_ALIGN_TOP

	For nx := 1 To Len(aHeader)
		oGet:aInfo[nx,4] := ".F."
	Next

	Activate Msdialog oDlgTela On Init EnchoiceBar(oDlgTela,{|| nOpca := 1,If(AGR840TRUE(nOpEnc),oDlgTela:End(),nOPCA := 2)},{|| nOPCA := 2,oDlgTela:End()})

	If nOPCA = 1 .And. nOpcao = 1
		nModulo := 4
		If NP9->NP9_TIPLOT = '1'
			Begin Transaction
				cOpD3  := aArOp[nItemB,1]
				cD3DM  := aArOp[nItemB,5]
				cNumAx := SubStr(cOpD3,1,len(SC2->C2_NUM))

				// Reabre a OP
				lOpOk := .f.
				DbselectArea("SC2")
				DBClearFilter()
				If AGRIFDBSEEK("SC2",cNumAx+'01'+NP9->NP9_PROD,9,.f.)
					AGRTRAVAREG("SC2")
					dDataFe       := SC2->C2_DATRF
					SC2->C2_DATRF := AGRINICIAVAR("C2_DATRF")
					AGRDESTRAREG("SC2")

					lOpOk := .t.

				EndIf

				vVetRD3PR := {}
				vVetSD3PE := {}
				vVetRD3RE := {}
				DbSelectArea("SD3")
				DbSetOrder(1)
				DbSeek(Xfilial("SD3")+cOpD3,.T.)
				If SD3->D3_FILIAL <> Xfilial("SD3")
					DbSkip(-1)
				EndIf
				If SD3->D3_OP <> cOpD3
					DbSkip(-1)
				EndIf

				If !lRestMVPar 
					//configura o pergunte MTA240 MV_PAR04 usado no MATA241, ira passar somente uma vez aqui e o pergunte deverá ser restaurado ao final do processamento 
					&cMvPar := ""
					Pergunte("MTA240",.F.)
					//Validar se o Pergunte MTA240 MV_PAR04 está com o valor 1 
					//Se não estiver alterar para 1 e depois retornar para o valor original, o estorno será por DOCUMENTO
					If !(&cMvPar == 1)
						SetMVValue("MTA240",cMvPar,1) //altera para valor 1 --> (Quanto ao Estorno: 1=Por Documento; 2=Por Item)
						lRestMVPar := .T. //.T. = deve ser restaurado -- passa apenas uma vez aqui
					EndIf 
				EndIf

				lRet := .T.
				If !AGRDTFECHAEST(SD3->D3_EMISSAO, .T. )
					//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
					DisarmTransaction()
					lRet := .F.
					lFECHTO := .T.
					Break
				EndIf				

				If lRet
					// Pesquisa e armazena movimentação do produto pai e filhos do lote
					While !Eof() .And. SD3->(D3_FILIAL+D3_OP) == xFilial("SD3")+cOpD3
						If (Substr(SD3->D3_CF,1,2) == "PR" .Or. SubStr(SD3->D3_CF,1,2) = "RE") .And. SD3->D3_ESTORNO <> 'S' .And. SD3->D3_DOC = cD3DM
							If(Substr(SD3->D3_CF,1,2) == "PR",	Aadd(vVetRD3PR,Recno()),Aadd(vVetRD3RE,Recno()))
						EndIf
						DbSkip()
					EndDo

					// Estorna as requisições
					aSB8Reg := {}
					aItens	:= {}
					aCab		:= {{'D3_EMISSAO',SD3->D3_EMISSAO,Nil}}
					vItePe	:= {}
					vIteRe  := {}
					For nx := 1 To Len(vVetRD3RE)
						DbSelectArea("SD3")
						Dbgoto(vVetRD3RE[nx])
						lPerda := .f.
						// PERDA
						aConsSCB := AGRBUSREGIS("SBC",xFilial("SBC")+SD3->D3_OP,1,.t.,.f.,;
							"SBC->BC_FILIAL = XFILIAL('SBC') .And. SBC->BC_OP = '"+SD3->D3_OP+"'",;
							{{"BC_NUMSEQ"}},"SBC->BC_SEQSD3 = '"+SD3->D3_NUMSEQ+"'","M")
						For ny := 1 To Len(aConsSCB[2])
							If AGRIFDBSEEK("SBC",SD3->D3_OP+aConsSCB[2,ny,1],1,.f.)
								Aadd(vItePe,SBC->(Recno()))
								Aadd(vVetSD3PE,SD3->(Recno()))
								lPerda := .T.
							EndIf
						Next ny

						If !lPerda
							Aadd(aItens,{{'D3_COD'    ,SD3->D3_COD    ,Nil},;
								{'D3_UM'     ,SD3->D3_UM		,Nil},;
								{'D3_CC'     ,SD3->D3_CC		,Nil},;
								{'D3_DOC'    ,SD3->D3_DOC    	,Nil},;
								{'D3_QUANT'  ,SD3->D3_QUANT  	,Nil},;
								{'D3_LOCAL'  ,SD3->D3_LOCAL  	,Nil},;
								{'D3_OP'     ,SD3->D3_OP     	,Nil},;
								{'D3_LOCALIZ',SD3->D3_LOCALIZ	,Nil},;
								{'D3_NUMSEQ' ,SD3->D3_NUMSEQ 	,Nil},;
								{"D3_LOTECTL",SD3->D3_LOTECTL	,Nil},;
								{"D3_ESTORNO","S"            	,Nil},;
								{"D3_NUMLOTE",SD3->D3_NUMLOTE	,Nil}})
							Aadd(vIteRe,SD3->(Recno())	)

							If Rastro(SD3->D3_COD,'L') .And. AGRIFDBSEEK("SB8",SD3->D3_COD+SD3->D3_LOCAL+Dtos(SD3->D3_DTVALID)+SD3->D3_LOTECTL+SD3->D3_NUMLOTE,1,.F.)
								Aadd(aSB8Reg,{Recno(),SD3->D3_QUANT,SB8->B8_SALDO})
							EndIf
						EndIf
					Next nx

					If !Empty(vIteRe)
						DbSelectArea("SD3")
						Dbgoto(vIteRe[1])

						lMsErroAuto := .F.
						MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab,aItens,6)

						If lMSErroAuto
							//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
							DisarmTransaction()
							lRet := .F.
							Break
						EndIf
					EndIf
				EndIf

				// Pesquisa e armazena as movimentações de transferências do produto pai
				cAliasQD3 := GetNextAlias()
				cQuery2 := "SELECT SD3.*,R_E_C_N_O_ SD3RECNO "
				cQuery2 += "FROM "+RetSqlName("SD3")+" SD3 "
				cQuery2 += " WHERE SD3.D3_FILIAL = '"+Xfilial("SD3")+"' AND SD3.D3_TM = '499' AND SD3.D3_CF = 'DE4' AND SD3.D3_ESTORNO <> 'S'"
				cQuery2 += " AND SD3.D3_LOTECTL = '"+NP9->NP9_LOTE+"' AND D3_COD = '"+NP9->NP9_PROD+"' AND SD3.D_E_L_E_T_ = '' "
				cQuery2 += " Order by D3_OP "
				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQD3,.F.,.T.)
				
				aAreaAnt := (cAliasQD3)->(GETAREA())

				// Estorna as requisições
				aSB8Reg := {}
				aItens	:= {}
				aCab		:= {{'D3_EMISSAO',SD3->D3_EMISSAO,Nil}}
				vItePe	:= {}
				vIteRe  := {}
				For nx := 1 To Len(vVetRD3RE)
					DbSelectArea("SD3")
					Dbgoto(vVetRD3RE[nx])
					If SD3->D3_ESTORNO != 'S'  //Se não foi estornado por algum motivo
						lPerda := .f.
						// PERDA
						aConsSCB := AGRBUSREGIS("SBC",xFilial("SBC")+SD3->D3_OP,1,.t.,.f.,;
							"SBC->BC_FILIAL = XFILIAL('SBC') .And. SBC->BC_OP = '"+SD3->D3_OP+"'",;
							{{"BC_NUMSEQ"}},"SBC->BC_SEQSD3 = '"+SD3->D3_NUMSEQ+"'","M")
						For ny := 1 To Len(aConsSCB[2])
							If AGRIFDBSEEK("SBC",SD3->D3_OP+aConsSCB[2,ny,1],1,.f.)
								Aadd(vItePe,SBC->(Recno()))
								Aadd(vVetSD3PE,SD3->(Recno()))
								lPerda := .T.
							EndIf
						Next ny

						If !lPerda
							Aadd(aItens,{{'D3_COD'    ,SD3->D3_COD    ,Nil},;
								{'D3_UM'     ,SD3->D3_UM		,Nil},;
								{'D3_CC'     ,SD3->D3_CC		,Nil},;
								{'D3_DOC'    ,SD3->D3_DOC    ,Nil},;
								{'D3_QUANT'  ,SD3->D3_QUANT  ,Nil},;
								{'D3_LOCAL'  ,SD3->D3_LOCAL  ,Nil},;
								{'D3_OP'     ,SD3->D3_OP     ,Nil},;
								{'D3_LOCALIZ',SD3->D3_LOCALIZ,Nil},;
								{'D3_NUMSEQ' ,SD3->D3_NUMSEQ ,Nil},;
								{"D3_LOTECTL",SD3->D3_LOTECTL,Nil},;
								{"D3_ESTORNO","S"            ,Nil},;
								{"D3_NUMLOTE",SD3->D3_NUMLOTE,Nil}})
							Aadd(vIteRe,SD3->(Recno())	)

						EndIf
					EndIf
				Next nx

				If !Empty(vIteRe)
					DbSelectArea("SD3")
					Dbgoto(vIteRe[1])
				
					lMsErroAuto := .F.
					MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab,aItens,6)

					If lMSErroAuto
						//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
						DisarmTransaction()
						lRet := .F.
						Break
					EndIf
				EndIf

				AGRQUEBRAFIL("SF5")

				RESTAREA( aAreaAnt )

				DbSelectArea(cAliasQD3)
				DbGoTop()
				nQuantT := 0
				While !Eof()
					DbSelectArea("SD3")
					DbGoto((cAliasQD3)->SD3RECNO)
					cCF := SD3->D3_CF
					AGRTRAVAREG()
					SD3->D3_CF := "PR0"
					SD3->D3_OP := NP9->NP9_OP
					AGRDESTRAREG()

					Apont := {}
					lMsErroAuto := .F.
					Aadd(aApont,{"D3_DOC"	 ,SD3->D3_DOC			 ,Nil})
					Aadd(aApont,{"D3_OP"	 ,SD3->D3_OP			 ,Nil})
					Aadd(aApont,{"D3_COD"    ,SD3->D3_COD	 		 ,Nil})
					Aadd(aApont,{"D3_UM"     ,SD3->D3_UM			 ,Nil})
					Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT			 ,Nil})
					Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL			 ,Nil})
					Aadd(aApont,{"D3_CC"     ,SD3->D3_CC			 ,Nil})
					Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO      	 ,Nil})
					Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL		 ,Nil})
					Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID        ,Nil})
					Aadd(aApont,{"D3_NUMSEQ" ,ProxNum()    			 ,Nil})
					Aadd(aApont,{"D3_CHAVE"	 ,SD3->D3_CHAVE			 ,Nil})
					Aadd(aApont,{"D3_CF"	 ,"PR0"        			 ,Nil})
					nQuantT += SD3->D3_QUANT
					lMsErroAuto := .F.
					MsExecAuto({|x,y| MATA250(x,y)},aApont,5)

					DbSelectArea("SD3")
					DbGoto((cAliasQD3)->SD3RECNO)
					AGRTRAVAREG()
					SD3->D3_CF := cCF
					AGRDESTRAREG()
					AGRDBSELSKIP(cAliasQD3)
				EndDo
				ARGCLOSEAREA(cAliasQD3)

				nResto := NP9->NP9_QUANT - nQuantT
				If nResto <> 0
					// Estorna a produção
					For nx := 1 To Len(vVetRD3PR)
						DbSelectArea("SD3")
						Dbgoto(vVetRD3PR[nx])

						Apont := {}
						lMsErroAuto := .F.
						Aadd(aApont,{"D3_DOC"	 ,SD3->D3_DOC		,Nil})
						Aadd(aApont,{"D3_OP"	 ,SD3->D3_OP		,Nil})
						Aadd(aApont,{"D3_COD"    ,SD3->D3_COD		,Nil})
						Aadd(aApont,{"D3_UM"     ,SD3->D3_UM		,Nil})
						Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT		,Nil})
						Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL		,Nil})
						Aadd(aApont,{"D3_CC"     ,SD3->D3_CC		,Nil})
						Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO	,Nil})
						Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL	,Nil})
						Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID	,Nil})
						Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
						Aadd(aApont,{"D3_CHAVE"	 ,SD3->D3_CHAVE		,Nil})
						aAdd(aApont,{"INDEX"     , 4        , Nil})

						lMsErroAuto := .F.
						MsExecAuto({|x,y| MATA250(x,y)},aApont,5)

						If lMsErroAuto
							//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
							DisarmTransaction()
							lRet := .F.
							Break
						EndIf
						AGRQUEBRAFIL("SF5")
					Next nx
				EndIf

				// Perda
				lMSErroAuto := .F.
				If Len(vItePe) > 0
					lEstornoAut := .T.
					nModulo := 10
					//Aplica resposta padrao de pergunte da tela de perda
					Pergunte("MTA685",.F.)
					For nx := 1 To Len(vItePe)
						DbSelectArea("SD3")
						Dbgoto(vVetSD3PE[nx])
						DbSelectArea("SBC")
						Dbgoto(vItePe[nx])

						aCabBC:=	{{'DOCTO',SD3->D3_DOC,Nil},;
							{'BC_OP'		,SBC->BC_OP		,Nil},;
							{'BC_PRODUTO',SBC->BC_PRODUTO	,Nil},;
							{'BC_NUMSEQ' ,SBC->BC_NUMSEQ 	,Nil},;
							{'BC_SEQSD3' ,SBC->BC_SEQSD3 	,Nil},;
							{'BC_RECURSO',SBC->BC_RECURSO	,Nil},;
							{'BC_OPERAC' ,SBC->BC_OPERAC 	,Nil}}
						aIteBC := {}

						Aadd(aIteBC,{{'BC_PRODUTO',SBC->BC_PRODUTO,Nil},;
							{'BC_LOCORIG',SBC->BC_LOCORIG,Nil},;
							{'BC_TIPO'   ,SBC->BC_TIPO   ,Nil},;
							{'BC_MOTIVO' ,SBC->BC_MOTIVO ,Nil},;
							{'BC_QUANT'  ,SBC->BC_QUANT  ,Nil},;
							{'BC_DATA'   ,SBC->BC_DATA   ,Nil}})

						//Valida se é necessario infomar os campos de localização Ascan(aItePe,{|x| x[1] = 'BC_LOCALIZ'}) > 0  .and.
						if  (!Empty(AllTrim(SBC->BC_LOCALIZ) ))
							Aadd(aTail(aIteBC),{'BC_LOCALIZ',SBC->BC_LOCALIZ,Nil})
						endif
						//Valida se é necessario infomar os campos de lote Ascan(aItePe,{|x| x[1] = 'BC_LOTECTL'}) > 0  .and.
						if  (! Empty(AllTrim(SBC->BC_LOTECTL) ))
							Aadd(aTail(aIteBC),{'BC_LOTECTL',SBC->BC_LOTECTL,Nil})
							Aadd(aTail(aIteBC),{'BC_NUMSERI',SBC->BC_NUMSERI,Nil})
							Aadd(aTail(aIteBC),{'BC_NUMLOTE',SBC->BC_NUMLOTE,Nil})
						endif
						// ATENÇÃO: Parâmetro mv_par01 do	MTA685 tem influência direta na geração da movimentação da perda. 1 - gera
						lMSErroAuto := .F.
						MSExecAuto({|x,y,z| Mata685(x,y,z)},aCabBC,aIteBC,6)
					Next nx
					lEstornoAut := .F.
					nModulo := 67
					//Refaz Pergunte padrao da tela
					Pergunte("MTA240",.F.)
				EndIf

				// Refaz o tratamento da OP
				DbselectArea("SC2")
				DBClearFilter()
				If AGRIFDBSEEK("SC2",cNumAx+'01'+NP9->NP9_PROD,9,.f.)
					AGRTRAVAREG("SC2")
					SC2->C2_DATRF := If(SC2->C2_QUANT - SC2->C2_QUJE > 0,Ctod(''),dDataFe)
					SC2->C2_QUJE  := If(SC2->C2_QUJE < 0,0,SC2->C2_QUJE)
					cItemOP       := SC2->C2_ITEM
					cSeqOP        := SC2->C2_SEQUEN
					AGRDESTRAREG("SC2")

					lExcluiOP := .F.
					If A650DefLeg(2)
						lExcluiOP := .T.
					Endif
				EndIf

				If lExcluiOP
					AADD(aVetor,{'C2_NUM' 		, cNumAx , NIL}) //Numero da OP
					AADD(aVetor,{'C2_ITEM'		, cItemOP, NIL}) //Item da OP
					AADD(aVetor,{'C2_SEQUEN'	, cSeqOP , NIL}) //Sequencia da OP

					//-----------------------------
					// Executa rotina a automatica
					//-----------------------------
					MSExecAuto({|x,y| MATA650(x,y)},aVetor, 5)
				Endif

				AGRTRAVAREG("NP9")

				cChaveRp := NP9->NP9_CODSAF+NP9->NP9_LOTE
				cTipoTra := NP9->NP9_TRATO

				If cTipoTra <> "1"
					If NP9->NP9_QUANT - nQtdB = 0
						DbDelete()
					Else
						NP9->NP9_QUANT  -= nQtdB
						NP9->NP9_QTD2UM	-=	ConvUm(NP9->NP9_PROD,nQtdB,0,2)
					EndIf
				Else
					If NP9->NP9_QUANT - nQtdB <= 0
						DbDelete()
					Else
						NP9->NP9_QUANT  -= nQtdB
						NP9->NP9_QTD2UM	-=	ConvUm(NP9->NP9_PROD,nQtdB,0,2)
					EndIf
				EndIf
				AGRDESTRAREG("NP9")

				// Atualiza o status do lote pai
				If cTipoTra = "1"
					// Refaz o tratamento da OP
					AGRALTCAMBA("NP9",cChaveRp,3,"NP9_STATUS","2")
					AGRAREAORDE("NP9",1)
				EndIf
			End Transaction()

			If lRestMVPar //restaura pergunte MTA240
				SetMVValue("MTA240",cMvPar,1) //restaura o pergunte para valor 1 --> // (Quanto ao Estorno: 1=Por Documento; 2=Por Item)
			EndIF 

			//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
			If !lRet
				If lFECHTO
					Help('',1, 'FECHTO') //Problema: Não pode ser digitado movimento com data anterior a última data de fechamento (virada de saldos).
					Return   	         //Solução: Utilizar data posterior ao último fechamento de estoque (MV_ULMES) / posterior à data do bloqueio de movimentos (MV_DBLQMOV).
				EndIf
				MostraErro()
				Return
			EndIf

		Else
			DbSelectArea("NP9")
			AGRDELETAREG()
		EndIf

		// Atualiza o lote padrão
		If AGRIFDBSEEK("NP9",cSafra+cProdP9+cLoteP9,1,.f.)
			AGRTRAVAREG()
			NP9->NP9_STATUS := cStatus
			AGRDESTRAREG()
		EndIf
	ElseIf nOPCA = 1 .And. nOpcao = 4
		// Alteração
		cHistor := CriaVar("NP9_OBS")
		AGRTRAVAREG("NP9")
		For ny := 1 To Fcount()
			nx := "M->" + Fieldname(ny)
			If &nx <> &("NP9->"+Fieldname(ny))
				cContMe := &nx
				cContBa := &("NP9->"+Fieldname(ny))
				If ValType(cContMe) = "N"
					cContMe := Alltrim(Str(cContMe))
					cContBa := Alltrim(Str(cContBa))
				ElseIf ValType(cContMe) = "D"
					cContMe := Dtoc(cContMe)
					cContBa := Dtoc(cContBa)
				EndIf
				cHistor += Alltrim(AGRTITULO(Fieldname(ny)))+"   "+Alltrim(cContBa)+"   --> "+Alltrim(cContMe)+"  "+_CRLF
			EndIf
			FieldPut(ny,&nx.)
		Next ny
		AGRDESTRAREG()

		If !Empty(cHistor)
			AGRGRAVAHIS(,,,,{"NP9",NP9->NP9_FILIAL+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"4",Alltrim(cHistor)})
		EndIf
	EndIf
	nModulo := 67
Return

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840TRUE                                                                          |
| Descrição : Atualiza variáveis para a confirmação                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/12/2014                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840TRUE(nOpc)
	If nOpc = 1
		nItemB := oQual:nAT
		nQtdB  := aArOp[nItemB,4]
		If nOpc = 1 .And. !AGRDTFECHAEST(NP9->NP9_DATA,.t.)
			Return .f.
		EndIf

		If !Empty(aArPC) .And. Localiza(aArPC[nItemB,1]) .And.;
				AGRIFDBSEEK("SDA",aArPC[nItemB,1]+aArPC[nItemB,2]+aArPC[nItemB,3]+aArPC[nItemB,4],1,.f.) .And. SDA->DA_QTDORI # SDA->DA_SALDO
			Help(" ",1,"SDAJADISTR")
			Return .f.
		Endif


		// Consiste com ordem de carregamento  TWGAGJ
		If NP9->NP9_STATUS = '2'
			If AGRSALDOSB8(NP9->NP9_LOTE,NP9->NP9_PROD,,,.t.) < 0
				Alert(STR0180+" "+AGRSX2NOME("NPN"))
				Return .f.
			ElseIf AGRIFDBSEEK('NPN',NP9->NP9_LOTE+NP9->NP9_PROD,4,.f.)
				Alert(STR0180+" "+AGRSX2NOME("NPN"))
				Return .f.
			Endif
		EndIf

	Endif
Return .t.

/*
############################################################################
# Função   : ARG840LOV                                                     #
# Descrição: Monta os lote usados na baixa do estoque                      #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 29/10/2014                                                    #  
############################################################################
*/
Function ARG840LOV(nOp)
	Local nInc	:= If(nOp = 1,1,oQual:nAT),c999 := "999"
	Local cOpD3 := "aArOp["+Alltrim(Str(nInc))+",1]"
	Local cD3Do := "aArOp["+Alltrim(Str(nInc))+",5]"
	cVar2 		:= &cOpD3
	cDoD3 		:= &cD3Do
	aCols 		:= {}

	If !Empty(cVar2)
		cAliasQ := GetNextAlias()
		cQuery2 := " SELECT SD3.D3_COD,SD3.D3_QUANT,SD3.D3_LOTECTL,SD3.D3_LOCAL FROM "+RetSqlName("SD3")+" SD3 "
		cQuery2 += " WHERE SD3.D3_FILIAL = '"+Xfilial("SD3")+"' AND SD3.D3_OP = '"+cVar2+"' AND (SD3.D3_TM = '"+cMovsai+"' OR SD3.D3_TM = '"+c999+"')"
		cQuery2 += " AND SUBSTRING(SD3.D3_CF,1,2) = 'RE' AND SD3.D3_ESTORNO <> 'S' AND SD3.D3_DOC = '"+cDoD3+"' AND SD3.D_E_L_E_T_ = '' "
		cQuery2 += " Order by D3_COD "
		cQuery2 := ChangeQuery(cQuery2)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQ,.F.,.T.)

		DbGoTop()
		While !Eof()
			AGRZERAACOLS(aHeader,aCols,.t.)
			aCols[Len(aCols),1] := (cAliasQ)->D3_COD
			aCols[Len(aCols),2] := Posicione("SB1",1,Xfilial("SB1")+(cAliasQ)->D3_COD,"B1_DESC")
			aCols[Len(aCols),3] := (cAliasQ)->D3_QUANT
			aCols[Len(aCols),4] := (cAliasQ)->D3_LOTECTL
			aCols[Len(aCols),5] := (cAliasQ)->D3_LOCAL
			AGRDBSELSKIP(cAliasQ)
		End
		ARGCLOSEAREA(cAliasQ)
	Else
		AGRZERAACOLS(aHeader,aCols,.t.)
	EndIf
	oGet:oBrowse:REFRESH()
Return .t.

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840F4                                                                            |
| Descrição : Monta consulta padrão F4 saldo do produto em armazens                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 12/11/2014                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840F4()
	Local oModel  := FwModelActive()
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local nLinSG1 := oGrdSG1:GetLine()
	Local cProdF4 := AGRINICIAVAR("B1_COD",.T.)
	Local nObjeto := Getfocus()
	Local nMenorO := If(cLoteTSI = Nil,6090,6070)
	oGrdSG1:GoLine(nLinSG1)
	cProdF4 := If(nObjeto <= nMenorO,M->NP9_PROD,oGrdSG1:GetValue("G1_COMP"))
	If !Empty(cProdF4)
		MaViewSB2(cProdF4)
	EndIf
Return

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840TSI()                                                                         |
| Descrição : Gera TSI                                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/11/2014                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840TSI()
	If AGRSALDOSB8(NP9->NP9_LOTE,NP9->NP9_PROD) = 0
		Help(,1,"HELP",,STR0057,1,0)
		Return .f.
	EndIf

	If NP9->NP9_TRATO = '1' .Or. NP9->NP9_STATUS <> "2"
		Help(,1,"HELP",,STR0021,1,0)
		Return .f.
	Else
		If !Empty(NP9->NP9_LOTE)			
			DbSelectArea("SB8")
			DbSetOrder(3)
			If  SB8->(DbSeek(FwxFilial("SB8") + NP9->NP9_PROD + NP9->NP9_LOCAL + NP9->NP9_LOTE))
				If  RecLock( "NP9", .F. )
				    NP9->NP9_DTVAL := SB8->B8_DTVALID 
			        NP9->( msUnLock() )
			    EndIF
			Endif   
		EndIF   		
		AGRA840(NP9->NP9_LOTE,"")
	EndIf

Return

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840PRO()                                                                         |
| Descrição : Gera mais produção para um lote já produzido.                                                                            |
| Autor     : Vitor Alexandre de Barba                                                               |
| Data      : 23/07/2015                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840PRO()
	If NP9->NP9_TIPLOT = "2" .Or. NP9->NP9_STATUS = "3" .Or. NP9->NP9_TRATO = "1"
		Help(,1,"HELP",,STR0155,1,0)
	Else
		AGRA840(NP9->NP9_LOTE,"PRO")
	EndIf
Return

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840PRO()                                                                         |
| Descrição : trocar produto por outro, devido alguma alteração na embalagem.    |
| Autor     : Vitor Alexandre de Barba                                                            |
| Data      : 23/07/2015                                                                          | 
+=================================================================================================+                                                                      |  
*/
Function AGR840TRC()
	If NP9->NP9_STATUS = "3" .Or. AGRSALDOSB8(NP9->NP9_LOTE,NP9->NP9_PROD) = 0
		Help(,1,"HELP",,STR0033+" "+If(NP9->NP9_STATUS = "3",STR0010,STR0057),1,0)
	Else
		AGRA840(NP9->NP9_LOTE,"TRC")
	EndIf
Return

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840TIPL()                                                                        |
| Descrição : Verifica se é lote comprado e/ou produzido                                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/12/2014                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840TIPL()
	Local oModel  := FwModelActive()
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local oGrdSB8 := oModel:GetModel("ITEM2")
	If FwFldGet("NP9_TIPLOT") = "2"
		AGRLIMPAGRID(oGrdSG1,"VIEW_SG1")
		AGRLIMPAGRID(oGrdSB8,"VIEW_SB8")
		M->NP9_CCUSTO := AGRINICIAVAR("B1_CC",.T.)
		oModel:LoadValue('CABEC','NP9_CCUSTO',M->NP9_CCUSTO)
	Else
		AGRCAG1B8()
		oGrdSB8:GoLine(1)
		oGrdSG1:GoLine(1)
	EndIf
Return .t.

/*                                                                                                 
+=================================================================================================+
| Programa  : AGR840REOP()                                                                        |
| Descrição : Verifica se reaproveita OP                                                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 08/01/2015                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function AGR840REOP()
	Local lRet    := .t.
	Local cProdut := FwFldGet("NP9_PROD")
	Local nQtdeS0 := FwFldGet("NP9_QUANT")
	Local cOPLote := SubStr(FwFldGet("NP9_OP"),1,Len(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN));
		+FwFldGet("NP9_PROD")+CRIAVAR("C2_ITEMGRD")
	cNumOp3			 := AGRINICIAVAR("D3_OP",.T.)
	cNumOp2			 := AGRINICIAVAR("C2_NUM",.T.)
	cCustoS			 := AGRINICIAVAR("B1_CC",.T.)

	Store .t. To lNovaOp,lFechOp,lGerouOp

	If !Empty(FwFldGet("NP9_OP")) .And. cLoteTSI = NIL .And. !Empty(cProdut) .And. !Empty(nQtdeS0) .And. FwFldGet("NP9_TIPLOT") = "1"
		If AGRIFDBSEEK("SC2",cOPLote,6,.f.)
			If Empty(SC2->C2_DATRF) .And. SC2->C2_QUANT - SC2->C2_QUJE >= FwFldGet("NP9_QUANT")
			Else
				If cReutOp = '1'
					lRet := AGRYESNOMVC(STR0107+" "+Alltrim(cProdut)+". "+STR0108,STR0098)
					M->NP9_OP := If(lRet,Space(Len(NP9->NP9_OP)),FwFldGet("NP9_OP"))
					Return lRet
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

/*                                                                                                 
+=================================================================================================+
| Programa  : AGRA840HR()                                                                         |
| Descrição : Valida hora inicial e final                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 08/01/2015                                                                          | 
+=================================================================================================+                                                                           |  
*/

Function AGRA840HR(cHora)
	Local lRet     := .t.
	Local cHoras   := Substr(cHora,1,2)
	Local cMinutos := Substr(cHora,4,2)

	If cHoras >= "00" .And. cHoras < "24" .And. cMinutos >= "00" .And. cMinutos < "60"
		If Readvar() = 'M->NP9_HRFIM' .And. M->NP9_DATA = M->NP9_DATAFI
			If M->NP9_HRFIM <= M->NP9_HRINI
				lRet := .f.
			Endif
		EndIf
	Else
		lRet := .f.
	EndIf
	If !lRet
		Help(" ",1,"VLDHORA")
	EndIf
Return(lRet)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRAFSD4                                                                            |
| Descrição : Não gerar requisição de ajuste de saída para lote (mata250)                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 13/01/2015                                                                          | 
|                                                                                                 | 
| OBSERVAÇÃO: Somente mexer essa função se realmente for necessário                               | 
+=================================================================================================+                                                                           |  
*/
Function AGRAFSD4()
Return If(funname() = "AGRA840",.f.,.t.)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840TLO                                                                          |
| Descrição : Consistência em relação ao tipo de lote e opção selecionada                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
| Parâmetros: cOper - Descrição da opção selecionada                                   Obrigatório| 
+=================================================================================================+                                                                           |  
*/
Function AGRA840TLO(cOper)
	Local cMensa := Space(1),lRet := .t.
	DbSelectArea("NP9")
	nRegNP9 := Recno()
	If NP9->NP9_TRATO = '1'
		cMensa := "TSI"
	EndIf
	If Empty(cMensa) .And. AGRIFDBSEEK("NP9",NP9->NP9_LOTE+NP9->NP9_CODSAF+"1",4,.F.)
		cMensa := STR0109+" "+"TSI"
	EndIf
	If !Empty(cMensa)
		Alert(STR0110+" "+cOper+" "+STR0111+".  "+STR0033+" "+cMensa)
		lRet := .f.
	EndIf
	AGRAREAORDE("NP9",1)
	DbGoto(nRegNP9)
Return lRet

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DN                                                                           |
| Descrição : Descarte do lote de beneficiamento (Totalmente refeito em relação a função anterior)|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840DN( lDescarte )

	//TODO Essa função precisa ser refatorada, separando totalmente as lógicas de Desmontagem e Descarte
	Local nx,ny,nOpca	:= 2,lMsErroAuto := .f.,aMatcam := {},cNGetDad
	Local vVetC			:= {"B8_PRODUTO","B1_DESC","B8_LOCAL","B8_LOTECTL","D3_LOCALIZ","D3_QUANT"}
	Local vCampos		:= {"D3_COD","D3_LOCAL","D3_QUANT","D3_RATEIO","D3_QTSEGUM","D3_LOCALIZ","D3_NUMSERI","D3_NUMLOTE","D3_LOTECTL",;
		"D3_DTVALID","D3_POTENCI","D3_CONTA","D3_ITEMCTA","D3_CLVL","D3_CC","D3_SERVIC"}
	Local lDesm         := .T. //PE AGR840CDES = Controla desmontagem do lote
	Local lAGR840CDE    :=  ExistBlock("AGR840CDES")

	Private aHeader		:= {},cHistPD := "",lNivel := .f.,lPerdaDN := .f.
	Private aSize		:= MsAdvSize(,.f.,430), aObjects := {},aArraySB8 := {}
	Private nPoscprod	:= 1,lLocaliz,lRastroL,lRastroS
	Private nSomaRat    := 0


	//O processo de desmontagem/descarte é permitido para os status:
	// 1 - Aguardando Resultados Laboratorais
	// 2 - Disponível
	// 3 - Rejeitado

	AGRIFDBSEEK("SB1",NP9->NP9_PROD,1,.F.)
	lLocaliz := localiza(NP9->NP9_PROD)
	lRastroL := Rastro(NP9->NP9_PROD,'L')
	lRastroS := Rastro(NP9->NP9_PROD,'S')
	lTSI     := If(NP9->NP9_TRATO = '1',.t.,.f.)
	cTipoD   := If(NP9->NP9_STATUS = "2","P","T")

	If NP9->NP9_STATUS = '1' //Aguardando Resultado Laboratorial
		//Se o status for Aguardando Analise Laboratorial, não pode ser feito desmontagem, nem descarte

		Help(, , STR0013, , STR0188, 1, 0 ) //"Atenção"###"Processo não permitido para lotes com status igual a Aguardando Resultado Laboratorial."
		Return
	Endif

	If !lDescarte .And. NP9->NP9_STATUS = '3' //Rejeitado
		//Se o status for Rejeitado não é possível fazer desmontagem, apenas descartar

		Help(, , STR0013, , STR0187, 1, 0 ) //"Atenção"###"Processo não permitido para lotes com status igual a Rejeitado"
		Return
	Endif

	If (lDescarte .And. lTSI)
		//Se for opção de descarte e for TSI,  não é permitido

		Help(, , STR0013, , STR0185, 1, 0 ) //"Atenção"###"A opçao de descarte nao é autorizada para lotes TSI."
		Return
	Endif


	nModulo := 4
	Private l240 := .F., l250 := .F., l241 := .F., l242 := .T., l261 := .F., l185 := .F.
	Aadd(aMatcam,{'B2_QFIM'   ,IIF(lDescarte,STR0121,STR0191),'AGA8480DQ()'  }) //Qtde P/ Descarte
	Aadd(aMatcam,{'BF_QUANT'  ,STR0114,' '            }) //Saldo
	Aadd(aMatcam,{'BF_LOCALIZ',STR0113+" "+STR0112,' '}) //Localiz. Orig.
	Aadd(aMatcam,{'BF_LOCAL'  ,STR0120,' '            }) //Local STR0120
	Aadd(aMatcam,{'B8_LOTECTL',STR0138,' '            }) //Lote Origem
	Aadd(aMatcam,{'BF_NUMLOTE',STR0115,' '            }) //Sub-Lote

	For nx := 1 To Len(vCampos)
		If SD3->(FieldPos(vCampos[nx]))
			Aadd(aMatcam,{vCampos[nx],RetTitle(vCampos[nx]),X3Valid(vCampos[nx])+If(vCampos[nx] = "D3_COD"," .And. AGRA840SM(aCols[n,1])","")})
		EndIf
	Next nx

	cNGetDad := "BF_QUANT|BF_LOCALIZ|BF_NUMLOTE|BF_LOCAL|B8_LOTECTL"

	aRotina := AGREMULAROT()
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{050,050,.t.,.t.})
	aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj  := MsObjSize(aInfo, aObjects,.t.)
	aCols    := {}
	vVetc    := AGRMATVETOR(aMatcam,1)
	aHeader  := AGRCRIAGRID(,vVetc,.t.,.t.)

	nDesD := GDFIELDPOS("B1_DESC"   ,aHeader)
	nLocz := GDFIELDPOS("D3_LOCALIZ",aHeader)
	nLote := GDFIELDPOS("D3_LOTECTL",aHeader)
	nNumL := GDFIELDPOS("D3_NUMLOTE",aHeader)
	nLoca := GDFIELDPOS("D3_LOCAL"  ,aHeader)
	nQtde := GDFIELDPOS("D3_QUANT"  ,aHeader)
	nSald := GDFIELDPOS("BF_QUANT"  ,aHeader)

	nUniD 	  		:=	GDFIELDPOS("D3_UM"	   ,aHeader)
	nProd 	  		:=	GDFIELDPOS("D3_COD"    ,aHeader)
	nAlmF 	  		:=	GDFIELDPOS("BF_LOCAL"  ,aHeader)
	nLocf 	  		:=	GDFIELDPOS("BF_LOCALIZ",aHeader)
	nQtdeS 	  		:=	GDFIELDPOS("BF_QUANT"  ,aHeader)
	nQtde8 	  		:=	GDFIELDPOS("B2_QFIM"   ,aHeader)
	nNumL     		:=	GDFIELDPOS("BF_NUMLOTE",aHeader)
	nLCTL    	 	:=	GDFIELDPOS("B8_LOTECTL",aHeader)

	nPosQuant 	 	:=	GDFIELDPOS("D3_QUANT"  ,aHeader)
	nPosLocal   	:=	GDFIELDPOS("D3_LOCAL"  ,aHeader)
	nPosRateio 		:=	GDFIELDPOS("D3_RATEIO" ,aHeader)
	nPosQtSegum 	:=	GDFIELDPOS("D3_QTSEGUM",aHeader)
	nPoslocali		:=	GDFIELDPOS("D3_LOCALIZ",aHeader)
	nPosNumSer		:=	GDFIELDPOS("D3_NUMSERI",aHeader)
	nPoslote		:=	GDFIELDPOS("D3_NUMLOTE",aHeader)
	nPosLotCTL		:=	GDFIELDPOS("D3_LOTECTL",aHeader)
	nPosDValid  	:=	GDFIELDPOS("D3_DTVALID",aHeader)
	nPosPotenc  	:=	GDFIELDPOS("D3_POTENCI",aHeader)
	nPosCta     	:=	GDFIELDPOS("D3_CONTA"  ,aHeader)
	nPosItCta   	:=	GDFIELDPOS("D3_ITEMCTA",aHeader)
	nPosCLVL    	:=	GDFIELDPOS("D3_CLVL"   ,aHeader)
	nPosCC      	:=	GDFIELDPOS("D3_CC" 	   ,aHeader)
	nPosServic	 	:=	GDFIELDPOS("D3_SERVIC" ,aHeader)
	nPosCod			:= nProd

	// Seleciona estoque e saldo
	cAliasQry := GetNextAlias()
	If lLocaliz
		cQuery := " SELECT BF_LOCAL,BF_LOCALIZ,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE,BF_QUANT FROM "+RetSqlName("SBF")+" SBF "
		cQuery += " WHERE SBF.BF_FILIAL = '"+Xfilial("SBF")+"' AND SBF.BF_PRODUTO = '"+NP9->NP9_PROD+"' AND SBF.BF_LOTECTL = '"+NP9->NP9_LOTE+"'"
		cQuery += " AND SBF.D_E_L_E_T_ = '' "
	Else
		cQuery := " SELECT B8_LOCAL,B8_LOTECTL,B8_NUMLOTE,B8_SALDO FROM "+RetSqlName("SB8")+" SB8 "
		cQuery += " WHERE SB8.B8_FILIAL = '"+Xfilial("SB8")+"' AND SB8.B8_PRODUTO = '"+NP9->NP9_PROD+"'"
		cQuery += " AND SB8.B8_LOTECTL = '"+NP9->NP9_LOTE+"' AND SB8.D_E_L_E_T_ = '' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	ARGSETIFARQUI(cAliasQry)
	lNEnder := .t.
	While !Eof()
		lNEnder := .f.
		nSaldo  := 0
		If lLocaliz
			nSaldo := SaldoSBF((cAliasQry)->BF_LOCAL,(cAliasQry)->BF_LOCALIZ,NP9->NP9_PROD,(cAliasQry)->BF_NUMSERI,(cAliasQry)->BF_LOTECTL,(cAliasQry)->BF_NUMLOTE)
		ElseIf lRastroL .Or. lRastroS
			nIndice := If(lRastroL,3,2)
			cChaveA := If(lRastroL,NP9->NP9_PROD+(cAliasQry)->B8_LOCAL+(cAliasQry)->B8_LOTECTL,;
				(cAliasQry)->B8_NUMLOTE+(cAliasQry)->B8_LOTECTL+NP9->NP9_PROD+(cAliasQry)->B8_LOCAL)
			AGRIFDBSEEK("SB8",cChaveA,nIndice,.F.)
			nSaldo := If(lRastroL,SaldoLote(NP9->NP9_PROD,(cAliasQry)->B8_LOCAL,(cAliasQry)->B8_LOTECTL,NIL,lEmpPrev,.t.,NIL,ddatabase),;
				SB8Saldo(nil,.t.,nil,nil,nil,lEmpPrev,nil,ddatabase))
		EndIf
		If nSaldo > 0

			AGRZERAACOLS(aHeader,aCols,.t.)
			aCols[Len(aCols),nSald]  := nSaldo
			aCols[Len(aCols),nNumL]  := If(lLocaliz,(cAliasQry)->BF_NUMLOTE,(cAliasQry)->B8_NUMLOTE)
			aCols[Len(aCols),nAlmF] := If(lLocaliz,(cAliasQry)->BF_LOCAL  ,(cAliasQry)->B8_LOCAL)
			aCols[Len(aCols),nLCTL] := If(lLocaliz,(cAliasQry)->BF_LOTECTL,(cAliasQry)->B8_LOTECTL)

			If lLocaliz
				aCols[Len(aCols),nLocf] := (cAliasQry)->BF_LOCALIZ
			EndIf

			aCols[Len(aCols),nPosRateio] := 100
			aCols[Len(aCols),nPosQuant]  :=	NP9->NP9_QUANT
			aCols[Len(aCols),nPosLocal]  :=	NP9->NP9_LOCAL
			cLocPai						 := aCols[Len(aCols),nAlmF]
			cLotPai 					 := aCols[Len(aCols),nLCTL]
			cLozPai 					 := aCols[Len(aCols),nLocf]
		EndIf
		AGRDBSELSKIP(cAliasQry)
	End
	ARGCLOSEAREA(cAliasQry)

	If Empty(aCols)
		Alert(If(lNEnder,STR0033+" "+STR0054+" "+STR0131,IIF(lDescarte,STR0122,STR0192)))
		Return
	EndIf
	For nx := 1 To Len(aHeader)
		aHeader[nx,1] := aMatcam[nx,2]
	Next nx

	Define MsDialog oDlgTela Title IIf(lDescarte,STR0123,STR0189) From aSize[1],aSize[2] To aSize[4],aSize[3] PIXEL
	oDlgTela:lMaximized := .t.

	oPanel := TPanel():New(0,0,'',oDlgTela,, .T., .T.,,,, ,.F.,.F. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelTop := TPanel():New(0,0,'',oPanel,, .T., .T.,,,,(oPanel:nClientHeight * 0.65),.F.,.F. )
	oPanelTop:Align := CONTROL_ALIGN_TOP
	oPanelBot := TPanel():New(1,1,'',oPanel,, .T., .T.,,,,(oPanel:nClientHeight * 0.265),.F.,.F. )
	oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelBot1 := TPanel():New(1,1,'',oPanel,, .T., .T.,,,,(oPanel:nClientHeight * 0.020),.F.,.F. )
	oPanelBot1:Align := CONTROL_ALIGN_TOP
	oPanelBot2 := TPanel():New(1,1,'',oPanel,, .T., .T.,,,,(oPanel:nClientHeight * 0.245),.F.,.F. )
	oPanelBot2:Align := CONTROL_ALIGN_ALLCLIENT

	oEnchoice := Msmget():New("NP9",Recno(),1,,,,,{0,0,oPanelTop:nClientHeight,oPanelTop:nClientWidth},,1,,,,oPanelTop)
	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	@1,10 say STR0124 of oPanelBot1 pixel color CLR_BLUE
	@1,280 say IIf(lDescarte,STR0125,STR0190) of oPanelBot1 pixel color CLR_BLUE

	oGet := MSGetDados():New(8,1,(oPanel:nClientHeight * 0.10),oPanelTop:nClientWidth,3,"AllwaysTrue()","AllwaysTrue()",,.t.,,3,,1,"AGRA840GD()";
		,,,"AGR840DG()",oPanelBot2)
	//Alinha o grid para ocupar todo o formulário
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	//Atualiza as informações no grid
	oGet:ForceRefresh()
	nMODULO := 4
	For nx := 1 To Len(aHeader)
		If Alltrim(aHeader[nx,2]) $ cNGetDad
			oGet:aInfo[nx,4] := ".F."
		EndIf
		If Alltrim(aHeader[nx,2]) = "B2_QFIM" .Or. Alltrim(aHeader[nx,2]) = "D3_COD"
			aHeader[nx,6] := aMatcam[nx,3]
		EndIf
	Next

	Activate Msdialog oDlgTela On Init EnchoiceBar(oDlgTela,{|| nOpca := 1,If(AGR840DF(),oDlgTela:End(),nOPCA := 2)},{|| nOPCA := 2,oDlgTela:End()},,)

	If nOPCA = 1
		Begin Transaction
			lDesca := .t.
			inclui := .t.
			lMHist := .f.
			nSomaRat := 0

			nModulo      := 4
			cNumDoc      := NextNumDoc() //Busca o numero do documento de movimentação de estoque

			a242Itens 		:= {}
			a242CabIte 		:= {}

			lMSErroAuto	:= .F.
			lMSHelpAuto	:= .T.
			For nx := 1 to Len(aCols)
				a242Cab := {}
				Aadd(a242Cab,{'cProduto'   ,NP9->NP9_PROD			                  ,Nil})
				Aadd(a242Cab,{'cLocOrig'   ,aCols[nx,nAlmF]		                      ,Nil})
				Aadd(a242Cab,{'nQtdOrig'   ,aCols[nx,nQtde8]		                  ,Nil})
				Aadd(a242Cab,{'nQtdOrigSe' ,ConvUm(NP9->NP9_PROD,aCols[nx,nQtde8],0,2),Nil})
				Aadd(a242Cab,{'cDocumento' ,cNumDoc                                   ,Nil})
				Aadd(a242Cab,{'cNumLote'   ,aCols[nx,nNumL]		                      ,Nil})
				Aadd(a242Cab,{'cLoteDigi'  ,aCols[nx,nLCTL]		                      ,Nil})
				Aadd(a242Cab,{'dDtValid'   ,NP9->NP9_DTVAL                            ,Nil})
				Aadd(a242Cab,{'nPotencia'  ,CriaVar('D3_POTENCI')                     ,Nil})
				Aadd(a242Cab,{'cLocaliza'  ,aCols[nx,nLocf]		                      ,Nil})
				Aadd(a242Cab,{'cNumSerie'  ,CriaVar('D3_NUMSERI')                     ,Nil})

				Aadd(a242CabIte, a242Cab)

				If !(aCols[nx, (Len(aHeader) + 1)])

					a242Item := {}
					Aadd(a242Item,{'D3_COD'    ,aCols[nx,nProd]			                       ,Nil})
					Aadd(a242Item,{'D3_LOCAL'  ,aCols[nx,nPosLocal]	                           ,Nil})
					Aadd(a242Item,{'D3_QUANT'  ,aCols[nx,nPosQuant]	                           ,Nil})
					Aadd(a242Item,{'D3_QTSEGUM',ConvUm(aCols[nx,nProd],aCols[nx,nPosQuant],0,2),Nil})
					Aadd(a242Item,{'D3_RATEIO' ,aCols[nx,nPosRateio]	                       ,Nil})

					nSomaRat += aCols[nx,nPosRateio]

					If !Empty(aCols[nx,nPoslocali])
						Aadd(a242Item,{'D3_LOCALIZ',aCols[nx,nPoslocali] ,Nil})
					EndIf
					If !Empty(aCols[nx,nPosNumSer])
						Aadd(a242Item,{'D3_NUMSERI',aCols[nx,nPosNumSer] ,Nil})
					EndIf
					If !Empty(aCols[nx,nPoslote])
						Aadd(a242Item,{'D3_NUMLOTE',aCols[nx,nPoslote]	 ,Nil})
					EndIf
					If !Empty(aCols[nx,nPosLotCTL])
						Aadd(a242Item,{'D3_LOTECTL',aCols[nx,nPosLotCTL] ,Nil})
					EndIf

					//Solicitado pela Cereal Ouro
					If !Empty(aCols[nx,nPosDValid])
						Aadd(a242Item,{'D3_DTVALID',aCols[nx,nPosDValid] ,Nil})
					EndIf

					If !Empty(aCols[nx,nPosCC])
						Aadd(a242Item,{'D3_CC',aCols[nx,nPosCC] ,Nil})
					EndIf

				Endif
				Aadd(a242Itens,a242Item)
			Next nx

			// Permite adicionar itens a desmontagem antes de executar a rotina automatica
			If ExistBlock("AGR840DE")
				aRet := ExecBlock("AGR840DE",.F.,.F.)
				If ValType(aRet) == "A"
					For ny := 1 To Len( aRet )
						Aadd(a242Item,aRet[ny])
					Next ny
				EndIf
			EndIf


			If nSomaRat < 100
				//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
				lMSErroAuto	:= .T.
				lMSHelpAuto	:= .F.
				DisarmTransaction()
				Break
			Endif

			For nx := 1 to Len(a242Itens)
				If !Empty(aCols[nx,1]) .And. !aCols[nx,Len(aCols[1])]

					DbSelectArea("SD3")
					nQtdRegA := Reccount()

					// Permite cancelar o processo de desmontagem com base nas informações de destino
					If !lDescarte .And. lAGR840CDE
						lDesm := ExecBlock("AGR840CDES",.F.,.F.,{a242CabIte[1],a242Item,NP9->NP9_CODSAF/* Acordado com a Cereal Ouro */})
					EndIf

					If lDesm

						MsExecAuto({ |v,x,y,z| Mata242(v,x,y,z) },a242CabIte[nx],{a242Itens[nx]},3,.T.)

						DbSelectArea("SD3")
						nQtdRegD := Reccount()

						If lMSErroAuto
							//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
							DisarmTransaction()
							Break
						EndIf

						cHistPD += STR0024+" "+STR0011+ " " + cValToChar(nx) + " ..: "+NP9->NP9_PROD+Chr(13)+;
							STR0025+" "+STR0175+" ..: "+Alltrim(Transform(aCols[nx,nQtde8],PesqPictQt("B8_SALDO",14)))+"  "+Chr(13)+;
							STR0119+" "+STR0176+" ..: "+Posicione("SB1",1,Xfilial("SB1")+NP9->NP9_PROD,"B1_UM")+"  "+Chr(13)+;
							STR0024+" "+STR0117+" ..: "+aCols[nx,nProd]+"  "+Chr(13)+;
							STR0025+" "+STR0117+" ..: "+Alltrim(Transform(aCols[nx,nPosQuant],PesqPictQt("B8_SALDO",14)))+"  "+Chr(13)+;
							STR0119+" "+STR0176+" ..: "+Posicione("SB1",1,Xfilial("SB1")+aCols[nx,nProd],"B1_UM")+"  "+Chr(13)+;
							STR0177+" ..: "+aCols[1,nPosLocal]+"  "+Chr(13)

					EndIf
				EndIf

			Next nx

			If lDesca .And. aCols[1,nQtde8] <> aCols[1,nSald]
				lDesca := .f.
			EndIf

			If lDescarte
				AGR840DSCT(cHistPD,"D")
			Endif

		End Transaction()

		//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
		If !lMSHelpAuto
			Help(, , STR0098, , STR0193, 1, 0 ) //"Atenção"###"Rateio total de itens a desmontar não atingido (100%)."
			Return
		EndIf

		//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
		If lMSErroAuto
			Mostraerro()
			Return
		EndIf

		If ExistBlock("AGR840P9")
			ExecBlock("AGR840P9",.F.,.F.,{a242CabIte, a242Itens,lDescarte})
		EndIf

	EndIf
	nModulo := 67

Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840SM                                                                           |
| Descrição : Conversão de unidade para descarte  (usado nA validação do D3_COD)                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/08/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840SM(nQTD)
	AGRIFDBSEEK("SB1",M->D3_COD,1,.f.)
	aCols[n,nQtde] := AGRX001(NP9->NP9_UM,SB1->B1_UM,nQTD)
Return .T.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840GD                                                                           |
| Descrição : Consistência em relação a edição do componente no descarte do lote normal           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/04/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840GD()
	If ReadVar() = "M->D3_COD" .And. lNivel
		Alert(STR0148)
		Return .f.
	EndIf
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGR840DG                                                                            |
| Descrição : Consistência em relação a exclusão do item da grid                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/04/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGR840DG()
Return If(lNivel,.t.,.f.)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DP                                                                           |
| Descrição : Consistência e carregamento das informações do produto destino                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840DP()
	acols[n,nDesD] := AGRINICIAVAR("B1_DESC",.T.)
	acols[n,nUnid] := AGRINICIAVAR("B1_UM",.T.)
	acols[n,nLoca] := AGRINICIAVAR("D3_LOCAL",.T.)
	acols[n,nLote] := AGRINICIAVAR("D3_LOTECTL",.T.)
	If lLocaliz
		acols[n,nLocz] := AGRINICIAVAR("BF_LOCALIZ",.T.)
	EndIf
	If cTipoD = "P"
		acols[n,nQtde] := AGRINICIAVAR("D3_QUANT",.T.)
	EndIf
	If !Empty(M->D3_COD)
		If !ExistCpo("SB1")
			Return .f.
		EndIf

		If M->D3_COD = NP9->NP9_PROD
			Alert(STR0126)
			Return .f.
		EndIf

		AGRIFDBSEEK("SB1",M->D3_COD,1,.F.)
		acols[n,nDesD] := SB1->B1_DESC
		acols[n,nUnid] := SB1->B1_UM
	EndIf
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DL                                                                           |
| Descrição : Consistência em relação ao produto X estoque                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840DL()
	If !AGRIFDBSEEK("SB2",aCols[n,nProd]+M->D3_LOCAL,1,.F.)
		Help(' ',1,'A260Local')
		Return .f.
	EndIf
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DL                                                                           |
| Descrição : Consistência em relação a localização do produto destino                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840LD()
	Local lRet := .t.
	If Empty(aCols[n,nProd]) .Or. Empty(aCols[n,nLoca])
		Help(' ',1,'MA260OBR')
		lRet := .F.
	EndIf
	If lRet .And. !Localiza(aCols[n,nProd])
		&(ReadVar()) := Space(Len(&(ReadVar())))
	Else
		lRet := ExistCpo('SBE',aCols[n,nLoca]+M->D3_LOCALIZ)
		If lRet
			lRet := ProdLocali(aCols[n,nProd],aCols[n,nLoca],M->D3_LOCALIZ)
		EndIf
	EndIf
Return lRet

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DQ                                                                           |
| Descrição : Consistência em relação a quantidade a ser descartada                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGA8480DQ()
	Local nQuant 	:= IIF(ValType(M->B2_QFIM) = Nil, ,M->B2_QFIM)
	Local lLoteVenc	:= SuperGetMV("MV_LOTVENC") == "S"
	Local cDataValidade := Posicione("SB8",3,FWxFilial("SB8") + NP9->NP9_PROD + NP9->NP9_LOCAL + NP9->NP9_LOTE, "B8_DTVALID")
	If !NaoVazio(nQuant) .Or. !Positivo(nQuant)
		Return .f.
	EndIf
	If nQuant > aCols[n,nSald]
		Alert(STR0127)
		Return .f.
	elseIf !lLoteVenc
		If cDataValidade < ddatabase
			Help(" ",1,"A240NEGAT")
			Return .F.
		endIf
	EndIf
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DL                                                                           |
| Descrição : Consistência em relação a leitura da localização do produto destino                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840VL()
Return Localiza(aCols[n,nProd])

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840DF                                                                           |
| Descrição : Consistências ao clicar em confirma                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGR840DF()
	Local nx,cMensa := Space(1),lRastlL,lRastlS
	For nx := 1 To Len(aCols)
		lTesta := .t.

		If nx <> 1 .And. Empty(aCols[nx,nQtde8])
			Loop
		EndIf
		lRastlL := Rastro(aCols[nx,nProd],'L')
		lRastlS := Rastro(aCols[nx,nProd],'S')
		If cTipoD = "T"
			If Empty(aCols[nx,nProd])
				cMensa := STR0024+" "+STR0117
				lTesta := .f.
			EndIf
		EndIf

		If lTesta
			If Empty(aCols[nx,nQtde8])
				cMensa := STR0121 //Qtde P/ Descarte
			ElseIf Empty(aCols[nx,nPosLocal])
				cMensa := AGRTITULO("D3_LOCAL  ")  //Almox. Destino
			ElseIf Empty(aCols[nx,nPosQuant])
				cMensa := AGRTITULO("D3_QUANT  ")
			ElseIf Localiza(aCols[nx,nProd]) .And. Empty(aCols[nx,nPoslocali])
				cMensa := AGRTITULO("D3_LOCALIZ") //Localiz. Destino
			ElseIf lRastlS
				If Empty(aCols[nx,nPoslote])
					cMensa := AGRTITULO("D3_NUMLOTE") //Sub-Lote
				EndIf
			ElseIf lRastlL
				If Empty(aCols[nx,nPosLotCTL])
					cMensa := AGRTITULO("D3_LOTECTL") //Lote
				EndIf
			ElseIf Empty(aCols[nx,nProd]) 
				cMensa := AGRTITULO("D3_COD") 
			EndIf

			If !Empty(cMensa)
				Exit
			EndIf

			If !AGRIFDBSEEK("SB2",aCols[nx,nProd]+aCols[nx,nPosLocal],1,.t.)
				Return .F.
			EndIf
		EndIf

		// se produto tiver rastro = "S" numlote é obrigatorio e saldo
		If !lLocaliz
			nIndice := If(lRastroL,3,2)
			cChaveA := If(lRastroL,NP9->NP9_PROD+aCols[nx,nAlmF]+NP9->NP9_LOTE+aCols[nx,nNumL],;
				aCols[nx,nNumL]+NP9->NP9_LOTE+NP9->NP9_PROD+aCols[nx,nAlmF])
			If !AGRIFDBSEEK("SB8",cChaveA,nIndice,.F.)
				Help(' ',1,'A240LOTERR')
				Return .F.
			EndIf
		EndIf

	Next nx

	If !Empty(cMensa)
		Alert(STR0128+" "+cMensa+".   "+STR0100+" "+Str(nx,3))
	EndIf
Return If(!Empty(cMensa),.f.,.t.)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840OP                                                                           |
| Descrição : Atribui valor a variável                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840OP()
	cOp := M->BC_OP
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840OP                                                                           |
| Descrição : Atribui valor a variável                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Static Function MTA840PERG()
	PERGUNTE("MTA240",.T.)
Return NIL

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840F11                                                                           |
| Descrição : Atribui valor a variável                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/01/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Static Function AGRA840F11()
	PERGUNTE(cPergF11,.T.)
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840V02                                                                          |
| Descrição : Valida da pergunto MV_PARO2                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/05/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840V02()
	//Return If(Empty(MV_PAR02),.T.,ExistCPO("SB5",MV_PAR02) .And. SB5->B5_SEMENTE == "1")
	local lRet := .f.

	If Empty(MV_PAR02) .or. ( AGRIFDBSEEK("SB5",PADR(ALLTRIM(MV_PAR02), TamSX3( "B5_COD" )[1]) ,1,.f.) .and. Alltrim(SB5->B5_SEMENTE) == "1" )
		lRet := .t.
	EndIf

Return lRet

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840WI                                                                           |
| Descrição : Atribui valor as variáveis do F11                                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 27/04/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Static Function AGRA840WI(cPergF11)      
	PERGUNTE(cPergF11,.f.)
	If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02) .Or. !Empty(MV_PAR03) .Or. !Empty(MV_PAR03) .Or. !Empty(MV_PAR04)
		M->NP9_PROD := MV_PAR02
		AGRIFDBSEEK("SB1",MV_PAR02,1,.f.)
		AGRIFDBSEEK("SB5",MV_PAR02,1,.f.)
		AGRINIPADMVC(oStruNP9,{{"NP9_CODSAF","MV_PAR01"},{"NP9_PROD","MV_PAR02"},{"NP9_LOCAL","MV_PAR03"},{"NP9_PRDDES","SB1->B1_DESC"},;
			{"NP9_UM","SB1->B1_UM"},{"NP9_2UM","SB1->B1_SEGUM"},{"NP9_DTVAL","AGRDTVALID(dDataBase,.f.)"},;
			{"NP9_CULTRA","SB5->B5_CULTRA"},{"NP9_CATEG","SB5->B5_CATEG"},{"NP9_PENE","SB5->B5_PENE"},{"NP9_CTVAR","SB5->B5_CTVAR"},;
			{"NP9_CTRDES",'SubStr(Posicione("NP3",1,Xfilial("NP3")+SB5->B5_CULTRA,"NP3_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTRDES",2,"X3_TAMANHO"))'},;
			{"NP9_CTVDES",'SubStr(Posicione("NP4",1,Xfilial("NP4")+SB5->B5_CTVAR,"NP4_DESCRI"),1,AGRSEEKDIC("SX3","NP9_CTVDES",2,"X3_TAMANHO"))'},;
			{"NP9_PENDES",'SubStr(Posicione("NP7",1,Xfilial("NP7")+SB5->B5_PENE,"NP7_DESCRI"),1,AGRSEEKDIC("SX3","NP9_PENDES",2,"X3_TAMANHO"))'}})
		lF11 := .t.
	EndIf
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840LOP                                                                          |
| Descrição : Validação da OP para o lote                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/02/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840LOP()
	local aAreaatu := GetArea()
	Local oModel   := FwModelActive()
	Local oGrdSG1  := oModel:GetModel("ITEM")
	Local oGrdSB8  := oModel:GetModel("ITEM2")
	Local cOPLote  := SubStr(FwFldGet("NP9_OP"),1,Len(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))+FwFldGet("NP9_PROD")+CRIAVAR("C2_ITEMGRD")
	Local aEstrSG1 := {},nCount := 0,nLinha := 0,nx
	Local nqtdBase := 0
	AGRIFDBSEEK("SB1",FwFldGet("NP9_PROD"),1,.F.)
	nqtdBase := SB1->B1_QB
	Store .t. To lNovaOp,lFechOp,lGerouOp

	If !Empty(FwFldGet("NP9_OP"))
		If !AGRIFDBSEEK("SC2",cOPLote,6,.T.)
			Return .f.
		Else
			If !AGR840SALD()
				Return .f.
			EndIf
			If Empty(SC2->C2_DATRF) .And. SC2->C2_QUANT - SC2->C2_QUJE >= FwFldGet("NP9_QUANT")
				nQuanOp := SC2->C2_QUANT
				cNumGOp := FwFldGet("NP9_OP")
				cAlias4 := GetNextAlias()
				cQuery4 := " SELECT SD4.D4_COD,SD4.D4_QTDEORI,SD4.D4_QUANT,SD4.D4_LOCAL FROM "+RetSqlName("SD4")+" SD4 "
				cQuery4 += " WHERE SD4.D4_FILIAL = '"+Xfilial("SD4")+"' AND SD4.D4_OP = '"+cNumGOp+"' AND SD4.D_E_L_E_T_ = '' "
				cQuery4 += " Order by D4_COD "
				cQuery4 := ChangeQuery(cQuery4)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery4),cAlias4,.F.,.T.)
				lTemSD4 := .f.
				DbGoTop()
				While !Eof() .And. !Empty((cAlias4)->D4_COD)
					lTemSD4 := .t.
					Exit
					AGRDBSELSKIP(cAlias4)
				End

				If lTemSD4
					// Limpa os grids
					AGRLIMPAGRID(oGrdSG1,"VIEW_SG1")
					AGRLIMPAGRID(oGrdSB8,"VIEW_SB8")

					oGrdSG1:SetNoInsert(.f.)
					oGrdSG1:SetNoDelete(.f.)
					oModel:GetModel( 'ITEM' ):SetNoUpdateLine(.F.)

					DbSelectArea(cAlT)
					Zap

					nEstru   := 0
					aEstrSG1 := ESTRUT(M->NP9_PROD,1,.T.,.f.)

					vVetComp := AGRMATVETOR(aEstrSG1,3,"C") // Busca os componentes
					// Retirar os componentes do SG1 em relação ao SD4
					ARGSETIFARQUI(cAlias4)
					While !Eof()
						nPosi := Ascan(vVetComp,{|x| x = (cAlias4)->D4_COD})
						If nPosi > 0
							aDel(vVetComp,nPosi)
							aSize(vVetComp,Len(vVetComp)-1)
						EndIf
						AGRDBSELSKIP(cAlias4)
					End

					nLinha := 1
					ARGSETIFARQUI(cAlias4)
					While !Eof()
						If AGRIFDBSEEK("SB1",(cAlias4)->D4_COD,1,.f.) .And. SB1->B1_FANTASM <> "S"
							nPosSG1 := aScan(aEstrSG1,{|x| x[3] == (cAlias4)->D4_COD})
							nPropor := M->NP9_QUANT
							If nPosSG1 > 0
								DbSelectArea("SG1")
								DbGoto(aEstrSG1[nPosSG1,8])
								If SG1->G1_FILIAL = Xfilial("SG1")
									nQtdeF := If(SG1->G1_FIXVAR = "F",SG1->G1_QUANT+((SG1->G1_QUANT*SG1->G1_PERDA)/100),;
										SG1->G1_QUANT*M->NP9_QUANT+((SG1->G1_QUANT*M->NP9_QUANT)*SG1->G1_PERDA/100)) / nqtdBase
									nQuantD4 := SG1->G1_QUANT
									nPerdaD4 := SG1->G1_PERDA
									cFixvaD4 := SG1->G1_FIXVAR
								EndIf
							Else
								// Verifica se o produto é alternativo
								lTemSGI := .f.
								If !Empty(vVetComp)
									For nx := 1 To Len(vVetComp)
										cAliasI := GetNextAlias()
										cQueryI := " SELECT SGI.GI_PRODORI,SGI.GI_TIPOCON,SGI.GI_FATOR FROM "+RetSqlName("SGI")+" SGI "
										cQueryI += " WHERE SGI.GI_FILIAL = '"+Xfilial("SGI")+"' AND SGI.GI_PRODALT = '"+(cAlias4)->D4_COD+"' AND SGI.D_E_L_E_T_ = '' "
										cQueryI += " Order by GI_PRODORI "
										cQueryI := ChangeQuery(cQueryI)
										dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryI),cAliasI,.F.,.T.)
										lTemSGI := .f.
										DbGoTop()
										While !Eof() .And. !lTemSGI
											If (cAliasI)->GI_PRODORI = vVetComp[nx]
												lTemSGI := .t.
												nPropor := If((cAliasI)->GI_TIPOCON = "M",M->NP9_QUANT * (cAliasI)->GI_FATOR,M->NP9_QUANT / (cAliasI)->GI_FATOR)
												Exit
											EndIf
											AGRDBSELSKIP(cAliasI)
										End
										ARGCLOSEAREA(cAliasI)
										If lTemSGI
											aDel(vVetComp,nx)
											aSize(vVetComp,Len(vVetComp)-1)
											Exit
										EndIf
									Next nx
								EndIf
								If !lTemSGI
									nPropor := ((cAlias4)->D4_QTDEORI / nQuanOp) * M->NP9_QUANT
								EndIf
								nQtdeF   := nPropor
								nQuantD4 := nPropor
								nPerdaD4 := 0.00
								cFixvaD4 := "V"
							Endif

							nCount++
							If(nCount > nLinha,oGrdSG1:AddLine(),oGrdSG1:GoLine(1))

								AGRLOADVALUE(oGrdSG1,{{'G1_COMP',(cAlias4)->D4_COD},{'G1_DESC',SubStr(SB1->B1_DESC,1,nTamDSG1)},{'G1_QUANT',nQuantD4},;
									{'G1_PERDA',nPerdaD4},{'G1_FIXVAR',cFixvaD4},{'B2_QATU',nQtdeF},{'NP9_LOCAL',(cAlias4)->D4_LOCAL},;
									{"D3_PERDA",0},{"BC_TIPO"," "},{"BC_MOTIVO","  "}})

								AGR840CSB8((cAlias4)->D4_COD,(cAlias4)->D4_LOCAL,CriaVar("D3_LOCALIZ")) // Carrega os lotes para o arquivo temporário
							EndIf
							AGRDBSELSKIP(cAlias4)
						End

						ARGCLOSEAREA(cAlias4)
						If nCount = 0
							oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
							Return .t.
						EndIf

						oGrdSG1:GoLine(1)
						cComponP := oGrdSG1:GetValue("G1_COMP")
						oModel:GetModel( 'ITEM' ):SetNoInsertLine( .T. )
						oModel:GetModel( 'ITEM' ):SetNoUpdateLine( .F. )
						If ValType(oView) != "U"
							oView:Refresh('VIEW_SG1')
						EndIf
						ARG840GRID2() // Carrega os lotes do primeiro componente da grid
					EndIf
				Else
					If cReutOp = '1'
						lRet := AGRYESNOMVC(STR0107+" "+Alltrim(FwFldGet("NP9_PROD"))+". "+STR0108,STR0098)
						If lRet
							M->NP9_OP := Space(Len(NP9->NP9_OP))
							lRefresh := .T.
						EndIf
					Else
						M->NP9_OP := Space(Len(NP9->NP9_OP))
						lRefresh := .T.
						lRet := .t.
					EndIf
					Return lRet
				EndIf
			EndIf
			cNumOp3 := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
			cNumOp2 := SC2->C2_NUM
			cCustoS	:= SC2->C2_CC
			cLocalO := SC2->C2_LOCAL

			lNovaOp := .f.
			lFechOp := If(SC2->C2_QUANT - SC2->C2_QUJE > FwFldGet("NP9_QUANT"),.f.,.t.)
			M->NP9_CCUSTO := cCustoS

			oModel:LoadValue('CABEC','NP9_CCUSTO',M->NP9_CCUSTO)
			aAux := oGrdSG1:oformmodelstruct:afields
			nPos := aScan(aAux,{|x| AllTrim(x[3]) == "NP9_LOCAL"})

			oModel:GetModel( 'ITEM' ):SetNoInsertLine( .F. )
			For nx := 1 To oGrdSG1:Length()
				oGrdSG1:GoLine(nx)
				cComponP := oGrdSG1:GetValue("G1_COMP")
				If AGRIFSEETRB(cAlT,cComponP,1,.f.)
					While !Eof() .And. (cAlT)->B8_PRODUTO = cComponP
						AGRDELETAREG()
						AGRDBSELSKIP(cAlT)
					End
				EndIf
				cLocalB8 := cLocalO
				cLocaliz := oGrdSG1:GetValue("D3_LOCALIZ")
				AGR840CSB8(cComponP,oGrdSG1:GetValue('NP9_LOCAL'),cLocaliz)
			Next nx
			oGrdSG1:GoLine(1)
			oModel:GetModel( 'ITEM' ):SetNoInsertLine( .T. )
			If ValType(oView) != "U"
				oView:Refresh('VIEW_SG1')
			Endif
			cComponP := oGrdSG1:GetValue("G1_COMP")
			ARG840GRID2()
		Else
			AGRCAG1B8(,,'XX')
		EndIf
		If ValType(oView) != "U"
			oView:Refresh()
		EndIf
		RestArea(aAreaAtu)
		Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840HF                                                                           |
| Descrição : Validação das datas e horas e calculo do tempo do lote                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 10/02/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840HF()
	If M->NP9_DATA = M->NP9_DATAFI .And. M->NP9_HRFIM <= M->NP9_HRINI
		Alert(STR0135)
		Return .f.
	EndIf
	M->NP9_HRTOT := AGRTOHONOR(M->NP9_DATA,M->NP9_HRINI,M->NP9_DATAFI,M->NP9_HRFIM)
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840EN                                                                           |
| Descrição : Endereçamento do lote                                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/03/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840EN()
	Local aAreaLe := GetArea()
	Local aRotSal := If(Type("aRotina") = "A",Aclone(aRotina),{})
	Local cCadSal := If(Type("cCadastro") <> "U",cCadastro,' ')

	cCadastro := OemToAnsi(AGRSX2NOME("SDA"))
	aRotina   := {{STR0139,"AxPesqui"  ,0,1},; //"Pesquisar"
	{STR0140,"A265Visual",0,2},; //"Visualizar"
	{STR0141,"A265Inclui",0,3}}  //"EnDerecar"
	L265AUTO := .F.
	oBrow2   := FWMBrowse():New()
	oBrow2:SetAlias('SDA')
	oBrow2:SetDescription(cCadastro)
	oBrow2:SetFilterDefault("SDA->DA_FILIAL = '"+Xfilial('SDA')+"' .AND. SDA->DA_PRODUTO = '";
		+NP9->NP9_PROD+"' .AND. SDA->DA_LOTECTL = '"+NP9->NP9_LOTE+"'")
	AGRLEGEBROW(@oBrow2,{{"DA_SALDO = 0",STR0167,"RED"},{"DA_SALDO <> 0",STR0168,"GREEN"}})
	oBrow2:Activate()

	If !Empty(aRotSal)
		aRotina := Aclone(aRotSal)
	Endif
	If !Empty(cCadSal)
		cCadastro := cCadSal
	EndIf
	RestArea(aAreaLe)
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840S8F                                                                          |
| Descrição : Consistência em relação ao saldo do lote e o saldo da localização quando o produto  |
|             é controlado por rastro e localização                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/03/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840S8F(cProd,cLocal,cNumLote,cLoteCtl,nQtd)
	Local lRet  := .t.,nIndice,cChaveA,lRastroS := If(Rastro(cProd,"S"),.t.,.f.)
	Local cHelp := Alltrim(AGRTITULO("B8_PRODUTO"))+" "+AllTrim(cProd)+" "+Alltrim(AGRTITULO("B8_LOCAL  "))+" "+cLocal;
		+" "+Alltrim(AGRTITULO("B8_SALDO  "))+" "
	nIndice := If(lRastroS,2,3)
	cChaveA := If(lRastroS,cNumLote+cLoteCtl+cProd+cLocal,cProd+cLocal+cLoteCtl+cNumLote)
	AGRIFDBSEEK("SB1",cProd,1,.f.)
	AGRIFDBSEEK("SF5",cMovsai,1,.f.)

	If AGRIFDBSEEK("SB8",cChaveA,nIndice,.f.)
		If lRastroS
			If QtdComp(SB8Saldo(lBxEmpB8,nil,nil,nil,nil,lEmpPrev,nil,FwFldGet("NP9_DATA"))) < QtdComp(nQtd)
				cHelp += Alltrim(Transform(SB8Saldo(nil,nil,nil,nil,nil,lEmpPrev,nil,FwFldGet("NP9_DATA")),;
					PesqPictQt("B8_SALDO",14)))+" "+Alltrim(AGRTITULO("B8_LOTECTL"))+" "+cLoteCtl
				Help(" ",1,"A240LOTENE",,cHelp,4,1)
				lRet := .F.
			EndIf
		Else
			If (SF5->F5_APROPR != "S" .And. SB1->B1_APROPRI == "I")
				nSaldo := SaldoLote(cProd,cLocal,cLoteCtl,NIL,.F.,.T.,nil,FwFldGet("NP9_DATA"))
				If QtdComp(nSaldo) < QtdComp(nQtd)
					cHelp += Alltrim(Transform(nSaldo,PesqPictQt("B8_SALDO",14)))+" "+Alltrim(AGRTITULO("B8_LOTECTL"))+" "+cLoteCtl
					Help(" ",1,"A240LOTENE",,cHelp,4,1)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf (RetFldProd(cProd,"B1_LOCALIZ") = "S")
		lRet := .T.
	Else
		Help(" ",1,"A840LNCSB8",,STR0027+" "+AGRSX2NOME("SB8"),4,1)
		lRet := .F.
	EndIf
Return lRet

/*                                                                                                 
+=================================================================================================+
| Função    : AGRA840F3P                                                                          |
| Descrição : Consulta específica para F3 do produto                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 06/04/2015                                                                          | 
+=================================================================================================+                                                                                                 | 
*/
Function AGRA840F3P()
	Local aCamADA  := {{"B1_COD"},{"B1_DESC"},{"B5_CEME"}}
	Local vVetInd  := {"B1_COD","B1_DESC","B5_CEME"}
	Local aAreaL   := GetArea()
	Local lB5TRAT  := If(AGRIFDICIONA("SX3","B5_TRATAM ",2,.f.),.T.,.F.)
	Local cQuery 	:= ""
	Local aCampIni 	:= {}
	Local aCampIni2 := {}
	Local aIndices 	:= {}

	If lB5TRAT
		Aadd(aCamADA,{"B5_TRATAM"})
		Aadd(aCamADA,{"B5_DESTRAT"})
		Aadd(vVetInd,"B5_TRATAM")
		Aadd(vVetInd,"B5_DESTRAT")
	EndIf

	//Se já realizou a busca, apagar todos os elementos. Pode acontecer um cadastro no momento da consulta
	If oArqTemp <> Nil
		//AGRDLTPTB(oArqTemp, {}, .T.)
		oArqTemp := NIL

	EndIf

	aCmpsTab := TamSX3("B1_COD")
	AADD(aCampIni,{"B1_COD", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCampIni2,{"B1_COD", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Codigo", "@!"})

	aCmpsTab := TamSX3("B1_DESC")
	AADD(aCampIni,{"B1_DESC", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCampIni2,{"B1_DESC", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Descricao", "@!"})

	aCmpsTab := TamSX3("B5_CEME")
	AADD(aCampIni,{"B5_CEME", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCampIni2,{"B5_CEME", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Nome Cientif", "@!S45"})

	If lB5TRAT
		aCmpsTab := TamSX3("B5_TRATAM")
		AADD(aCampIni,{"B5_TRATAM", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
		AADD(aCampIni2,{"B5_TRATAM", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Tipo Tratam.", "@!"})

		aCmpsTab := TamSX3("B5_DESTRAT")
		AADD(aCampIni,{"B5_DESTRAT", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
		AADD(aCampIni2,{"B5_DESTRAT", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Descrição.", "@!"})
	EndIf

	cAliasTRB := GetNextAlias()
	//ALTERADO TAMANHO DOS ALIASES PARA NÃO GERAR ERRO NO BANCO DE DADOS ORACLE
	aAdd(aIndices, {"B1_DSC", "B1_DESC"} )
	aAdd(aIndices, {"B5_CM", "B5_CEME"} )
	aAdd(aIndices, {"B5_TRA", "B5_TRATAM"} )
	aAdd(aIndices, {"B5_DST", "B5_DESTRAT"} )
	aAdd(aIndices, {"B1_COD", "B1_COD"} )

	oArqTemp  := AGRCRTPTB(cAliasTRB, {aCampIni, aIndices })

	cSB5Alias := GetNextAlias()

	cQuery := " SELECT SB5.B5_COD, SB5.B5_CEME, SB1.B1_COD, SB1.B1_DESC, SB5.B5_SEMENTE "
	If lB5TRAT
		cQuery += ",SB5.B5_TRATAM, NKD.NKD_DESCRI "
	EndIf
	cQuery += " FROM " + RetSqlName("SB5") + " SB5  "
	cQuery += " INNER JOIN "  + RetSqlName("SB1") + " SB1 ON "
	cQuery += " (SB5.B5_COD = SB1.B1_COD AND SB5.B5_FILIAL = SB1.B1_FILIAL) "

	If lB5TRAT
		cQuery += " LEFT  JOIN "  + RetSqlName("NKD") + " NKD ON "
		cQuery += " (NKD.NKD_TRATAM = SB5.B5_TRATAM AND NKD_FILIAL = SB5.B5_FILIAL AND NKD.D_E_L_E_T_ = '') "
	EndIf

	cQuery += " WHERE SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
	cQuery += " AND SB5.B5_SEMENTE = '1' "
	cQuery += " AND SB5.D_E_L_E_T_ = '' "
	cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += " AND SB1.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cSB5Alias, .F., .T.)

	dbSelectArea(cSB5Alias)
	dbGoTop()

	CursorWait()

	While !(cSB5Alias)->(Eof())
		Reclock(cAliasTRB, .T.)
		Replace (cAliasTRB)->B1_COD With (cSB5Alias)->B1_COD
		Replace (cAliasTRB)->B1_DESC With (cSB5Alias)->B1_DESC
		Replace (cAliasTRB)->B5_CEME With (cSB5Alias)->B5_CEME

		AGRGRAVAREG(cAliasTRB,{{"B1_COD",(cSB5Alias)->B1_COD},{"B1_DESC",(cSB5Alias)->B1_DESC},{"B5_CEME",(cSB5Alias)->B5_CEME}})
		If lB5TRAT
			AGRGRAVAREG(cAliasTRB,{{"B5_TRATAM",(cSB5Alias)->B5_TRATAM},{"B5_DESTRAT",(cSB5Alias)->NKD_DESCRI}})
		EndIf
		AGRDESTRAREG(cAliasTRB)

		(cAliasTRB)->(MsUnlock())
		(cSB5Alias)->(dbSkip())
	End

	(cSB5Alias)->(dbCloseArea())

	CursorArrow()

	M->NP9_PROD := AGRAF3TEMP(STR0150,cAliasTRB,aCampIni2,vVetInd,{"B1_COD"})

	AGRDLTPTB(oArqTemp)

	RestArea(aAreaL)
Return .T.

/*
+=================================================================================================+
| Função    : AGR840PD3                                                                           |
| Descrição : Habilita o campo quantidade na perda de insumos na geração do lote                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
*/
Function AGR840PD3()
	Local oModel  := FwModelActive()
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local nLinxx  := oGrdSG1:GetLine()
	oGrdSG1:GoLine(nLinxx)
	AGRIFDBSEEK("SB1",oGrdSG1:GetValue("G1_COMP"),1,.f.)
Return !localiza(oGrdSG1:GetValue("G1_COMP")) .And. !IsProdMod(oGrdSG1:GetValue("G1_COMP"),1,3);
		.And. !Empty(oGrdSG1:GetValue("B2_QATU")) .And. SB1->B1_RASTRO = "N"

/*
+=================================================================================================+
| Função    : AGR840PGTM                                                                          |
| Descrição : Habilita nos demais campos na perda de insumos na geração do lote                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
|Parâmetros : cGrid - Alias da grid                                                    Obrigotório|
+=================================================================================================+
*/
Function AGR840PGTM(cGrid)
	Local oModel  := FwModelActive()
	Local oGrdGTM := oModel:GetModel(If(cGrid = "SG1","ITEM","ITEM2"))
	Local nLinxx  := oGrdGTM:GetLine()
	oGrdGTM:GoLine(nLinxx)
Return !Empty(oGrdGTM:GetValue(If(cGrid = "SG1","D3_PERDA","BC_QUANT")))

/*
+=================================================================================================+
| Função    : AGR840PB8                                                                           |
| Descrição : Habilita o campo quantidade na perda saldo lote                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
*/
Function AGR840PB8()
	Local oModel  := FwModelActive()
	Local oGrdSB8 := oModel:GetModel("ITEM2")
	Local nLinSB8 := oGrdSB8:GetLine()
	oGrdSB8:GoLine(nLinSB8)
Return If(!Empty(oGrdSB8:GetValue("B8_QTDORI")),.T.,.F.)

/*
+=================================================================================================+
| Função    : AGR840GDVAL                                                                         |
| Descrição : Validação final dos campos de perda                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
|Parâmetros : nPerda  - Quantidade da perda                                            Obrigotório|
|             nQtdcon - Quantidade a consumir                                          Obrigotório|
|             cTipo   - Tipo da perda                                                  Obrigotório|
|             cMotivo - Motivo da perda                                                Obrigotório|
|             nItem   - Item da grid                                                   Obrigotório|
|             cGrid   - Nome da  grid                                                  Obrigotório|
|             cPerda  - Nome do campo da grid                                          Obrigotório|
+=================================================================================================+
*/
Function AGR840GDVAL(nPerda,nQtdcon,ctipo,cmotivo,nItem,cGrid,cPerda)
	Local cMensaL := ""
	If !Empty(nPerda)
		If Empty(cTipo) .Or. Empty(cMotivo)
			cMensaL :=	STR0171+" "+If(Empty(cTipo),AGRTITULO("BC_TIPO"),AGRTITULO("BC_MOTIVO"))+" "+;
				STR0172+" "+cGrid+" "+STR0101+" "+STR0145+" "+Alltrim(Str(nItem,3))
		EndIf
	EndIf
Return cMensaL

/*
+=================================================================================================+
| Função    : AGR840VPD                                                                         |
| Descrição : Validação da quantidade da perda                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
|Parâmetros : cGrid - Alias da grid                                                    Obrigotório|
+=================================================================================================+
*/
Function AGR840VPD(cGrid)
	Local oModel  := FwModelActive(),cMensa := ""
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local oGrdSB8 := oModel:GetModel("ITEM2")
	Local nLinSG1 := oGrdSG1:GetLine()
	Local nLinSB8 := oGrdSB8:GetLine()
	oGrdSG1:GoLine(nLinSG1)
	oGrdSB8:GoLine(nLinSB8)
	If cGrid = "SG1"
		If Empty(M->D3_PERDA)
			AGRLIMPCMVC(oGrdSG1,nLinSG1,{"BC_TIPO","BC_MOTIVO"})
			Return .t.
		EndIf
	EndIf
	If !Empty(cMensa)
		Help(,1,"HELP",,cMensa,1,0)
	EndIf
Return If(Empty(cMensa),.t.,.f.)

/*
+=================================================================================================+
| Função    : AGR840QAU                                                                           |
| Descrição : Atualizador da grid                                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
*/
Function AGR840QAU()
	Local oModel  := FwModelActive()
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local nLinSG1 := oGrdSG1:GetLine()

	If ReadVar() = "M->B2_QATU" .And. Empty(M->B2_QATU)
		AGRLIMPCMVC(oGrdSG1,nLinSG1,{"D3_PERDA","BC_TIPO","BC_MOTIVO"})
	EndIf
Return .t.

/*
+=================================================================================================+
| Função    : AGR840PEDE                                                                          |
| Descrição : Perda de insumos na geração do lote                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+
*/
Function AGR840PEDE()
	Local nx,lMsErroAuto := .f.
	Local aMatcam		 := {}
	Private aHeader 	 := {}

	nModulo := 10
	Aadd(aMatcam,{'BC_OP'		,AGRTITULO("BC_OP     "),' '}) //Op
	Aadd(aMatcam,{'BC_LOCORIG'  ,AGRTITULO("BC_LOCORIG"),' '}) //Local
	Aadd(aMatcam,{'BC_TIPO'		,AGRTITULO("BC_TIPO   "),' '}) //Tipo
	Aadd(aMatcam,{'BC_MOTIVO'   ,AGRTITULO("BC_MOTIVO "),' '}) //Motivo
	Aadd(aMatcam,{'BC_DESCRI'   ,AGRTITULO("BC_DESCRI "),' '}) //Descrição
	Aadd(aMatcam,{'BC_LOCALIZ'	,AGRTITULO("BC_LOCALIZ"),' '}) //Localização
	Aadd(aMatcam,{'BC_NUMSERI'	,AGRTITULO("BC_NUMSERI"),' '}) //Serie
	Aadd(aMatcam,{'BC_LOTECTL'	,AGRTITULO("BC_LOTECTL"),' '}) //Lote
	Aadd(aMatcam,{'BC_NUMLOTE'	,AGRTITULO("BC_NUMLOTE"),' '}) //Sub-Lote
	Aadd(aMatcam,{'D3_QUANT'	,STR0121                ,' '}) // Qtde P/ Descarte
	Aadd(aMatcam,{'BF_QUANT'	,STR0114                ,' '}) // Saldo

	aCols   := {}
	vVetc   := AGRMATVETOR(aMatcam,1)
	aHeader := AGRCRIAGRID(,vVetc,.t.,.t.)

	// Variavéis usadas no MATA685
	//Aplica resposta padrao de pergunte da tela de perda
	Pergunte("MTA685",.F.)
	lParam    := .T.
	cOpx      := AGRINICIAVAR("BC_OP",.T.)
	cOp       := SubStr(cNumOp3,1,Len(cOpx))
	l685Auto  := .T.
	SC2->(DbSetOrder(1))

	For nx := 1 To Len(aItePe)
		aItens:= {}
		aCab:= {{'DOCTO'		,cNuDocPai					,Nil},;
			{'BC_OP'     	,cOp						,Nil},;
			{'BC_PRODUTO'	,aItePe[nx,1]				,Nil},;
			{'BC_RECURSO'	,CriaVar('BC_RECURSO')		,Nil},;
			{'BC_OPERAC' 	,CriaVar('BC_OPERAC')		,Nil}}

		Aadd(aItens,{{'BC_PRODUTO'	,aItePe[nx,1]			,Nil},;
			{'BC_LOCORIG'	,aItePe[nx,2]         	,Nil},;
			{'BC_LOCAL'  	,aItePe[nx,2]         	,Nil},;
			{'BC_TIPO'   	,aItePe[nx,4]         	,Nil},;
			{'BC_MOTIVO' 	,aItePe[nx,5]         	,Nil},;
			{'BC_QUANT'  	,aItePe[nx,3]         	,Nil},;
			{'BC_DATA'   	,FwFldGet("NP9_DATA") 	,Nil}})

		//Valida se é necessario infomar os campos de lote
		if(!Empty(AllTrim(aItePe[nx,7]) ))
			Aadd(aTail(aItens),{'BC_LOTECTL',aItePe[nx,7]         ,Nil})
			Aadd(aTail(aItens),{'BC_NUMSERI',CriaVar('BC_NUMSERI'),Nil})
			Aadd(aTail(aItens),{'BC_NUMLOTE',CriaVar('BC_NUMLOTE'),Nil})
		endif

		//Valida se é necessario infomar os campos de localização
		if(!Empty(AllTrim(aItePe[nx,6]) ))
			Aadd(aTail(aItens),{'BC_LOCALIZ',aItePe[nx,6]         ,Nil})
		endif

		// ATENÇÃO: Parâmetro mv_par01 do	MTA685 tem influência direta na geração da movimentação da perda. 1 - gera
		lMSErroAuto := .F.
		MSExecAuto({|x,y,z| Mata685(x,y,z)},aCab,aItens,3)
		If lMSErroAuto
			MostraErro()
			Return


		Else //Atualiza Cod Safra

			dbSelectArea("SD3")
			dbGoTop()

			If AGRIFDBSEEK("SD3",cNuDocPai+PADR("",TamSX3("D3_ITEM")[1]),9,.f.)
				While !("SD3")->(Eof()) .AND. SD3->D3_DOC == cNuDocPai
					AGRTRAVAREG()
					SD3->D3_CODSAF := FwFldGet("NP9_CODSAF")
					AGRDESTRAREG()
					dbSelectArea("SD3")
					SD3->(DBskip())
				EndDo
			EndIf
		Endif
	Next nx
	nModulo := 67
	//restaura resposta padrao de pergunte da tela
	Pergunte("MTA240",.F.)
Return

/*
+=================================================================================================+
| Função    : AGR840PRE                                                                           |
| Descrição : Função Pré-Menu                                                                     |
| Autor     : Bruna Rocio                                                                         |
| Data      : 25/01/2016                                                                          |
+=================================================================================================+
*/

Function AGR840PRE(nOp)
	Local lRet := .T.

	If ExistBlock("AGR840P6")
		lRet := ExecBlock("AGR840P6",.F.,.F.,{nOp})
		If !lRet
			Return
		Endif
	Endif

	Do Case
	Case nOp == 2 //"Visualizar"
		AGRA840VE(2)
	Case nOp == 4 //"Alterar"
		AGRA840VE(4)
	Case nOp == 5 //"Excluir"
		AGRA840VE(1)
	Case nOp == 7 //"Desmontagem"
		AGRA840DN(.F.)
	Case nOp == 8 //"Descarte"
		AGRA840DN(.T.)
	Case nOp == 9 //"Conhecimento"
		AGR840CON()
	Case nOp == 10 //"TSI"
		AGR840TSI()
	Case nOp == 11 //"Produzir +"
		AGR840PRO()
	Case nOp == 12 //"Histórico"
		AGR840HIS()
	Case nOp == 13 //Aprovar
		AGR840APR()
	Case nOp == 14 //Rejeitar
		AGR840REJ()
	EndCase

Return .t.

/*
+=================================================================================================+
| Função    : AGR840B2QT                                                                          |
| Descrição : Pesquisa por um componente que possua a quantidade a consumir diferente de 0, Caso  |
|			  encontre, retornará .T.															  |
| Autor     : Carlos Augusto                                                                      |
| Data      : 25/01/2016                                                                          |
+=================================================================================================+
*/
Static Function AGR840B2QT()
	Local oGrdSG1	:= oModel:GetModel("ITEM")
	Local nx
	Private lDifZero := .F.

	For nx := 1 To oGrdSG1:Length()
		oGrdSG1:GoLine(nx)
		If oGrdSG1:GetValue("B2_QATU") > 0 .and. .Not. oGrdSG1:IsDeleted() 
			lDifZero := .T.
			exit
		EndIf
	Next nx
Return lDifZero

/*/{Protheus.doc} AGR840SALD
//No filtro da consulta padrão SC2L (do campo "OP"). Cópia da função ASC2SLD do MATXFUNB
@author marcos.wagner
@since 28/12/2017
@version undefined

@type function
/*/
Static Function AGR840SALD()
	Local aArea := GetArea()
	Local nDecs := TamSX3("C2_QUANT")[2]
	Local nSalop := NoRound(0, nDecs) // Forçar valor zero com casa decimais do SX3
	Local lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)
	Local lRet := .t.

	dbSelectAreA("SC2")
	dbSetOrder(1)
	If MsSeek(FwxFilial("SC2")+FwFldGet("NP9_OP"))

		nSalop := Max(0,NoRound(SC2->C2_QUANT - SC2->C2_QUJE - IIF(lPerdInf,0,SC2->C2_PERDA), nDecs))

		If nSalop < FwFldGet("NP9_QUANT") .AND. !Empty(FwFldGet("NP9_QUANT"))
			Help(" ",1,"HELP",,"O Saldo disponível da OP não é suficiente para a quantidade informada!",3,0)
			lRet := .f.
		EndIf
	EndIf

	RestArea(aArea)

Return (lRet)

/*/{Protheus.doc} AGR840LDGOP
//Força a gravação da Ordem de Produção-OP no NP9_OP da rotina Lote de Sementes
@author Jonisson Henckel
@since 30/10/2018
@version undefined

@type function
/*/

Static Function AG840LDGOP(cLote)
	Local aArea 	:= GetArea()
	Local dData     := Date()
	Local cQuerySD3	:= ''
	Local cProduto  := ''
	Local cSafra    := ''
	Local cOp       := ''
	Local cLocal    := ''
	Local cFilNP9	:= FwxFilial("NP9")
	Local lRet      := .F.
	Local oModItem  := oModel:GetModel("CABEC")

	cQuerySD3 := GetNextAlias()

	BeginSql Alias cQuerySD3

		SELECT SD3.D3_OP,
		SD3.D3_CODSAF,
		SD3.D3_COD,
		SD3.D3_LOCAL
		FROM %table:SD3% SD3
		WHERE SD3.D3_EMISSAO = %Exp:dData% 
		AND SD3.D3_LOTECTL = %Exp:cLote%
		AND SD3.%notDel%

	EndSQL

	cSafra 		:= (cQuerySD3)->D3_CODSAF
	cProduto	:= (cQuerySD3)->D3_COD
	cOp 		:= (cQuerySD3)->D3_OP
	cLocal 		:= (cQuerySD3)->D3_LOCAL

	DbSelectArea("SD3")
	DbSetOrder(1)// FILIAL + OP + PRODUTO + LOCAL

	If DbSeek(cFilNP9 + cOp + cProduto + cLocal )
		If Empty(oModItem:GetValue("NP9_OP"))
			RecLock("NP9",.F.)
			NP9_OP 	:= cOp
			lRet 	:= .T.
			MsUnlock()
		EndIf
	EndIf

	(cQuerySD3)->(DbCloseArea())
	RestArea(aArea)

Return

/*
############################################################################
# Função   : AGR840CYO                                                     #
# Descrição: Verifica se o cliente possui os novos campos da tabela CYO    #
#			 Se possuir, o motivo de refugo deve  ser verificado pela CYO  #
# Autor    : Michelle Ramos                                                #
# Data     : 02/01/2019                                                    #  
############################################################################
*/

Function AGR840camp()
	Local aArea    := GetArea()
	Local lRet     := .T.

	DbSelectArea("CYO")
	If CYO->(FieldPos("CYO_LGRT")) > 0
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet

/*
############################################################################
# Função   : AGR840CYO                                                     #
# Descrição: Verifica se a validação deve utilizar a tabela SX5 ou CYO     #
# Autor    : Michelle Ramos                                                #
# Data     : 02/01/2019                                                    #  
############################################################################
*/
Function AGR840CYO()
	local lret:=.T.

	If AGR840camp()
		lret:=ExistCpo('CYO',M->BC_MOTIVO) .And. AGR840VQTD()
	Else
		lret:=ExistCpo('SX5','43'+M->BC_MOTIVO) .And. AGR840VQTD()
	EndIf

return lRet

/*{Protheus.doc} AGRA840TRG
Gatilho de atualização dos campos 
@author felipe.mendes
@since 30/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@param cFieldDt, characters, descricao
@type function
*/
function AGRA840TRG(oField, cFieldDt)
	Local oModel := oField:GetModel()
	Local oGrdSG1 := oModel:GetModel("ITEM")
	Local oFldNP9 := oModel:GetModel("CABEC")

	oGrdSG1:SetValue('B2_QATU',  (( ( oGrdSG1:GetValue("G1_PERDA") / 100 ) + 1 ) * oGrdSG1:GetValue("G1_QUANT") * oFldNP9:GetValue("NP9_QUANT")) )

return .T.
