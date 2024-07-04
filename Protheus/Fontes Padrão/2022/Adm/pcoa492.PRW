// Copyright (C) 2008, Microsiga

#include "protheus.ch"
#include "pcoa492.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA492   บAutor  ณAcacio Egas         บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Planejamento de Despesas Indiretas               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static oMenuALV,oMenuALT

Function PCOA492( cAlias , nReg , nOpcx , aCpos , cVerPlan )

Local nWidth  := GetScreenRes()[1] - 40
Local nHeight := GetScreenRes()[2] - 200
Local _nContItem
Local aHeaderALX,aColsALX

If ALV->ALV_STATUS == "2" .and. cVerPlan==nil  // ORCAMENTO EM REVISAO 
	HELP("  ",1,"PCOA100REV")
	Return
EndIf
Private lAlterPNJ	:= (nOpcx==4)
Private _cVerPlan 	:= If(cVerPlan<>nil,cVerPlan, ALV->ALV_VERSAO) // Criado para Ferramenta de Revis๕a
Private aDataPlnj 	:= {}
Private _aListData 	:= PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.,aDataPlnj) 		

DbSelectArea("AK5")
DbSetOrder(1)
DbSelectArea("ALV")
Private oPlanej := PCOArea():New(0,0, nWidth, nHeight, STR0001 ) //"Planejamento Or็amentแrio"
Private aCampos := {{'',''}}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Maximiza a oDlg principal, deixando o tamanho correto da window  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPlanej:ODLG:LMAXIMIZED := .T.

//Cria   Layouts para a Tela
oPlanej:AddLayout("Planej")
oPlanej:AddLayout("Distri")

oPlanej:addSide(28,"Estrutura")

oPlanej:AddWindow(96,"WIN1", STR0002 ,2,.F.,.F.,oPlanej:oArea:oSideBar) //"Estrutura"

oPlanej:AddTre("001","WIN1",nil)

// Monta Estrutura do Tree
oPlanej:No_Tree("Planejamento"		,"ALV","ALLTRIM(ALV_CODIGO)+'-'+ALV_DESCRI","RPMCPO"	,{|| oPlanej:ShowLayout("Planej")}	,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)},,)
oPlanej:No_Tree("Tipo de Despesa"	,"ALT","ALLTRIM(ALT_CODIGO)+'-'+ALT_DESCR","SIMULACA"	,{|| oPlanej:ShowLayout("Distri"),Find_Agreg()	}	,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)},,{|x| PcoIncAM2(x,"005",,,.F.) })

aButs := {}

If lAlterPNJ
	
	aAdd( aButs , { 1, "GPRIMG32"	, 	{|| PcoRatALX(oPlanej:Getobj('WIN2')) }			, STR0003	, .F. } )
	aAdd( aButs , { 1, "EXCLUIR"	, 	{|| PcoExclRatALX(oPlanej:Getobj('WIN2')) }		, STR0005	, .F. } )//"Incluir Rateio"###"Visualizar Rateio"###"Excluir Rateio"

EndIf
aAdd( aButs , { 1, "RELATORIO"	, 	{|| PcoVisuRateioALX(oPlanej:Getobj('WIN2')) }	, STR0004	, .F. } )


// Adiciona Janela 2 com Bot๕es - servira para conter o cadastro centro de custo /ou Funcao /ou GetDados
oPlanej:AddWindow( 48 , "WIN2" , STR0006 , 3 , lAlterPNJ , , , aButs ) //"Distribui็ใo de Entidades"

// Monta aHeader da GetDados
aCpos := {"ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4921")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4921"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aColsALX 	:= nil
oPlanej:AddGtD("001", STR0007 ,"WIN2","Distri",aHeaderALX,aColsALX,{|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("001")),Find_Agreg(),oPlanej:GetGtd("001")}	,{|x| Find_Agreg()},{|x| PcoPnjAtu(@oPlanej:GetGtd("001"),"005",.T.)}) //"Despesas Indiretas"

// Cria variaveis de memoria para a MSMGet
RegToMemory("ALV", .F.,,, FunName())
//Cria MsmGet
oPlanej:AddMsm("001", STR0008 ,"ALV",ALV->(Recno()),"WIN2","Planej",/*Load*/{|x| PcoGetALV("2")},/*Confirm*/{|x| PcoGetALV("1")}) //"Planejamento"

// Adiciona Janela 2
oPlanej:AddWindow(48,"WIN3", STR0009 ,2, lAlterPNJ ,"Distri") //"Distribui็ใo de Valores"

//********************************************************
//  Gera Variaveis de Memoria para a MsmGetAutoContida   *
//********************************************************
	// Gera variแveis para utiliza็ใo na MsMGet
	_aGetValues := {}
	_aGetQuants := {}
	For _nContItem := 1 to Len(_aListData)	
		_SetOwnerPrvt("VLR" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		_SetOwnerPrvt("QTD" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		// Criando campos para a MsmGet
		SX3->(DbSetOrder(2))
		SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
		ADD FIELD _aGetValues TITULO _aListData[_nContItem] CAMPO "VLR" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
		ADD FIELD _aGetQuants TITULO _aListData[_nContItem] CAMPO "QTD" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
	Next	
// Fim                    

//Cria MsmGet
oPlanej:AddMsm("003", STR0010 ,"ALY",ALY->(Recno()),"WIN3","Distri"	,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.,AtuPrc()) },_aGetQuants) //"Quantidades"
oPlanej:AddMsm("002", STR0011 ,"ALY",ALY->(Recno()),"WIN3","Distri"			,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.) },_aGetValues) //"Valores"

oPlanej:AddBrw("001", STR0012 ,{ STR0028 , STR0029 },"WIN3","Planej",{|| /*AtuBrow()*/}) //"Produtos"###"Codigo"###"Descri็ใo"

oPlanej:ShowLayout("Planej")
// Inicializa o Tree
AtuAgreg(.t.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็ใo que desabilita os botoes da WIN2 quando posicionado o registro pai da treeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
P493DesBot()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInsere tratamento no BCHANGE do objeto da Tree para desabilitarณ
//ณ os botoes da WIN2 quando posicionado no registro pai da Tree  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPlanej:Aobjetos[1][2]:BCHANGE := {|OOBJ,NROW,NCOL| oObj:TREECHANGE(OOBJ,NROW,NCOL),P493DesBot()}

oPlanej:Activate()

/*
If lAlterPNJ

	Processa( {|| PcoPnjSld() } , STR0013 ) //"Atualizando Saldos"

EndIf
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPopupMenu บAutor  ณAcacio Egas         บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo executada ao clicar botใo direita no xTree.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RightTree(oTree,oObject1,oObject2, x, y, z)

Local oMenu := PopupMenu(@oTree)
If oMenu <> Nil
	oMenu:Activate(x - 24, y - 100, oPlanej:GetSidebar() )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPopupMenu บAutor  ณAcacio Egas         บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popup executado no xTree                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบSintaxe   ณ LoadTree(ExpC1)                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ ExpC1 - Objeto xTree para disparar popup.                  บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PopupMenu(oTree)
Local oMenu := Nil
Local cCargo := oTree:GetCargo()
Local cId
Local cAlias := SubStr(cCargo,1,3)

cId := SubStr(cCargo,4,Len(cCargo)-3)

DbSelectArea("AM2")
DbSetOrder(3)
DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"005"+cId )

DbSelectArea("ALT")
DbSetOrder(1)
DbSeek(xFilial("ALT")+AM2->AM2_AGREG)

Do Case	
	Case cAlias == "ALV"
		
		If oMenuALV<>nil
		
			oMenuALV:Free()
			
		EndIf
		
		Menu oMenuALV Popup
		MenuItem STR0014 Block {|| InsertTipo(@oTree)} //"Adicionar Tipo de Despesa "
		EndMenu

		If !lAlterPNJ
		
			oMenuALV:AITEMS[01]:LACTIVE := .F.
			
		EndIf
		
		oMenu := oMenuALV
		
	Case cAlias == "ALT" 
	
		If oMenuALT<>nil
		
			oMenuALT:Free()
		
		EndIf

		Menu oMenuALT Popup
		MenuItem STR0015 Block {|| 	PcoDistShow( "ALX_AM2ID='" + cId + "' " , (ALT->ALT_TPVLR=='1') , "005" ) } //"Visualizar Distribui็ใo "
		MenuItem "___________________" Disabled
		MenuItem STR0016 Block {|| DelTipo(@oTree) } //"Excluir Tipo de Despesa"
		MenuItem "___________________" Disabled
		MenuItem STR0017 Block {|| PcoRunPlan(cId,"005",3,@oPlanej:GetGtd("001")) } //"Gerar Despesas Indiretas"
		MenuItem STR0018 Block {|| PcoRunPlan(cId,"005",5,@oPlanej:GetGtd("001")) } //"Excluir Despesas Indiretas"
		MenuItem "___________________" Disabled
		MenuItem STR0019 Block {|| PcoPnjAlt(cId, , , {"005"} ) , AtuAgreg(.T.,.T.) } //"Reajustar Valores"
		EndMenu		 

		If !lAlterPNJ
		
			oMenuALT:AITEMS[03]:LACTIVE := .F.
			oMenuALT:AITEMS[05]:LACTIVE := .F.
			oMenuALT:AITEMS[06]:LACTIVE := .F.
			oMenuALT:AITEMS[08]:LACTIVE := .F.
			
		EndIf
		
		oMenu := oMenuALT
									
	Otherwise		
		// sem menu		
EndCase
Return oMenu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInsertTipo      บAutor  ณAcacio Egas   บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Distribui Despesas Indiretas no xTree.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function InsertTipo(oTree)
Local aConfig
If ParamBox({ 	{1, STR0020 ,SPACE(Len(ALT->ALT_CODIGO)),"@S6","ExistCpo('ALT')","ALT_01",".T.",40,.F.},; //"Despesa de "
	  			{1, STR0021 ,SPACE(Len(ALT->ALT_CODIGO)),"@S6","ExistCpo('ALT')","ALT_01",".T.",40,.F.}}, STR0022 ,@aConfig,,,,,,,"PCOA492_05",,.T.) //"Despesa ate"###"Distribui็ใo do Planejamento"

	oPlanej:LoadTree(@oTree,"ALT"	 ,aConfig[1],aConfig[2],,,,,"AM2->AM2_ID")
	AtuAgreg()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelTipo         บAutor  ณAcacio Egas   บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Deleta Despesas Indiretas no xTree.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DelTipo(oTree)

Local cCargo 	:= oTree:GetCargo()
Local cId		:= SubStr(cCargo,4,Len(cCargo)-3)
Local lContinua := .T.

dbSelectArea("AM2")
dbSetOrder(3)
dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"005"+cId)

DbSelectArea("ALX")
DbSetOrder(1)

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"005"+AM2->AM2_AGREG)

	lContinua := .F.

EndIf
	
If lContinua

	DbSelectArea("AM2")
	DbSetOrder(2)
	If DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"005"+AM2->AM2_AGREG)

		RecLock("AM2",.F.)
			DbDelete()
		MsUnlock()
		oTree:DelItem()
		AtuAgreg()

	EndIf
Else
	Aviso( STR0023 , STR0024 ,{ STR0025 }) //"Aten็ใo"###"Existem lan็amentos para este agregador. Favor excluir os lan็amentos."###"OK"
EndIf

Return

// Atualiza aCols
Static Function Find_Agreg()
                                
Local cCargo	:= oPlanej:GetTre("001"):GetCargo()
Local cId 		:= SubStr(cCargo,4,Len(cCargo)-3)

PcoFindALX(cId,"005",@oPlanej:GetGtd("001"))

Return

Static Function AtuAgreg(lIni,lRefresh)
// Monta Tree
Local nX
Local aLoad := {}

Default lIni 		:= .F.
Default lRefresh    := .F.

If lIni
	oPlanej:GetTre("001"):Reset()
EndIf


//Local nBrow := oPlanej:GetBrw("001")
DbSelectArea("AM2")
DbSetorder(3)
DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"005")
Do While !AM2->(Eof()) .and. ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"005"==AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL
	DbSelectArea("ALT")
	DbSetOrder(1)
	DbSeek(xFilial("ALT")+AM2->AM2_AGREG)
	If aScan(oPlanej:GetTre("001"):aCargo,{|x|x[1]=="ALT"+AM2->AM2_ID})==0
		aAdd(aLoad,{"ALT",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'"})
//		oPlanej:LoadTree(@oPlanej:oTree,"ALT",AM2->AM2_AGREG,,2,.F.)
	EndIf
	AM2->(DbSkip())
EndDo

If lIni

	oPlanej:LoadTree(@oPlanej:GetTre("001"),"ALV",ALV->ALV_CODIGO,,1,.F.,aLoad)

	If lRefresh
	
		oPlanej:GetTre("001"):Display()
		oPlanej:GetTre("001"):TreeSeek(oPlanej:GetTre("001"):aCargo[1,1])
		oPlanej:ShowLayout("Planej")
	
	EndIf

EndIf

aCampos:= {}
For Nx:=1 To Len(oPlanej:GetTre("001"):aCargo)
	cCargo := oPlanej:GetTre("001"):aCargo[Nx,1]
	DbSelectArea("AM2")
	DbSetOrder(3)
	DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"005"+SubStr(cCargo,4,Len(cCargo)-3))
	DbSelectArea("ALT")
	DbSetOrder(1)
	If SubStr(cCargo,1,3)="ALT"
		DbSeek( xFilial("ALT")+AM2->AM2_AGREG )
		aAdd(aCampos,{ALT->ALT_CODIGO,ALT_DESCR})
	EndIf
Next
If Len(aCampos)==0
	aCampos := {{'',''}}
EndIf
oPlanej:GetBrw("001"):SetArray(aCampos)
oPlanej:GetBrw("001"):bLine := {|| aCampos[oPlanej:GetBrw("001"):nAt] }
oPlanej:GetBrw("001"):Refresh()

Return

Static Function AtuPrc()

Local nVlUnit 	:= 0
Local cCargo 	:= oPlanej:GetTre("001"):GetCargo()
Local cId

cId := SubStr(cCargo,4,Len(cCargo)-3)


DbSelectArea("AM2")
DbSetOrder(3)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"005"+cId)

DbSelectArea("ALT")
DbSetOrder(1)
DbSeek(xFilial("ALT")+AM2->AM2_AGREG)

If ALLTRIM(ALT->ALT_TPVLR)=='1'

	nVlUnit := PcoPrcPlan(AM2->AM2_AGREG,'005')

Else

	Aviso( STR0023 , STR0026 ,{ STR0027 }) //"Aten็ใo"###"Tipo de despesa controlado por Valor"###"OK"

EndIf

Return (nVlUnit)