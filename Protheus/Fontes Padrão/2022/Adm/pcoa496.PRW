#INCLUDE "pcoa496.ch"
// Copyright (C) 2007, Microsiga

#include "protheus.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"

#define PLANILHCTT "009"
#define PLANILHSRJ "009"

#define SALARIOPLJ "009"
#define OUTRASVPLJ "010"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA496   บAutor  ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Planejamento de Folha de Pagamento               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Utiliza a classe PCOArea():New() - Fonte Pcoa491.prw       บฑฑ
ฑฑบ          ณ Desenvolvida por Acacio Egas                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static oMenuALV,oMenuCTT,oMenuSRJ

Function PCOA496( cAlias , nReg , nOpcx , aCpos , cVerPlan )

Local nWidth  		:= GetScreenRes()[1] - 40
Local nHeight 		:= GetScreenRes()[2] - 200
Local _nContItem, nX

//variaveis para montagem dos layouts
Local aLayout 			:= { "Planej", "Centro_Custo", "CC_Funcao", "Verbas_Relac" }

//variaveis para montagem do tree
Local aNode_Tree 	:= { STR0001, STR0002, STR0003} //"Planejamento"###"Centro de Custo"###"Funcao"
Local aAliasTree    := { "ALV", "CTT", "SRJ" }
Local aExpTitleTree := { 	"ALLTRIM(ALV_CODIGO)+'-'+ALV_DESCRI", ;
							"ALLTRIM(CTT_CUSTO)+'-'+CTT_DESC01", ;
							"ALLTRIM(RJ_FUNCAO)+'-'+RJ_DESC" }
							
Local aResourceTree := { "RPMCPO", "SIMULACA", "SIMULACA" }

Local bShow_01 		:= {|| oPlanej:ShowLayout(aLayout[1], AtuBrow() )				}	
Local bShow_02 		:= {|| Pco_AM2Posic( oPlanej:GetTre("001"):GetCargo(), PLANILHCTT ), oPlanej:ShowLayout("Centro_Custo"), AtuBrwSRJ() }
Local bShow_03 		:= {|| Pco_AM2Posic( oPlanej:GetTre("001"):GetCargo(), PLANILHSRJ ), oPlanej:ShowLayout("CC_Funcao"), Find_Agreg(), oPlanej:GetGtd("002"):oBrowse:SetFocus() }

Local bExecMenu 	:= 	{|x,y,z| RightTree( oPlanej:GetTre("001"),, x, y, z)}

Local bRunEntid 	:= {|| /*RunEntid()*/}

Local bInclCTTEntid := {|x|  }
Local bInclSRJEntid := {|x|  }
Local bEnchQtd 		:= {|| oPlanej:GetMsm("003"):EnchRefreshAll(), oPlanej:GetMsm("004"):EnchRefreshAll() }
Local aButs

If ALV->ALV_STATUS == "2" .and. cVerPlan==nil  // ORCAMENTO EM REVISAO 
	HELP("  ",1,"PCOA100REV")
	Return
EndIf

Private lAlterPNJ	:= ( nOpcx==4 )
Private _cVerPlan 	:= If(cVerPlan<>nil,cVerPlan, ALV->ALV_VERSAO) // Criado para Ferramenta de Revis๕a
Private aDataPlnj := {}
Private _aListData := PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.,aDataPlnj) 		
Private cParAprvAtu := GetNewPar("MV_PCOPLFP","1") //1=valor atual 2=valor aprovado 3=valor previsto
DbSelectArea("ALV")
Private oPlanej := PCOArea():New(0,0, nWidth, nHeight,STR0004) //"Planejamento Or็amentแrio - Folha de Pagamento"
Private aCampos := {{'',''}}
Private aCposBrw := {{'',''}}

dbSelectArea("AM1")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Maximiza a oDlg principal, deixando o tamanho correto da window  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPlanej:ODLG:LMAXIMIZED := .T.

//Cria  Layouts para a Tela
oPlanej:AddLayout( aLayout[1] )
oPlanej:AddLayout( aLayout[2] )
oPlanej:AddLayout( aLayout[3] )

//adiciona SideBar no objeto oPlanej (FWAREA)
oPlanej:addSide( 28, "Estrutura")

// Adiciona Janela 1 - contera a sidebar e o tree pแra navegacao
oPlanej:AddWindow( 96, "WIN1", STR0005, 2, .F., .F., oPlanej:oArea:oSideBar) //"Estrutura por Centro de Custo"

aButs := {}

If lAlterPNJ
	
	aAdd( aButs , { 1, "GPRIMG32"	, 	{|| PcoRatALX(oPlanej:Getobj('WIN2')) }			, "Incluir Rateio"	, .F. } )
	aAdd( aButs , { 1, "EXCLUIR"	, 	{|| PcoExclRatALX(oPlanej:Getobj('WIN2')) }		, "Excluir Rateio"	, .F. } )

EndIf
aAdd( aButs , { 1, "RELATORIO"	, 	{|| PcoVisuRateioALX(oPlanej:Getobj('WIN2')) }	, "Visualizar Rateio"	, .F. } )

// Adiciona Janela 2 com Bot๕es - servira para conter o cadastro centro de custo /ou Funcao /ou GetDados
oPlanej:AddWindow( 48, "WIN2", STR0006, 3, lAlterPNJ , aLayout[3],, aButs ) //"Entidade"

// Adiciona Janela 3 com Bot๕es
oPlanej:AddWindow( 48, "WIN3", STR0007, 2, lAlterPNJ , aLayout[3] ) //"Conte๚do"

oPlanej:AddTre("001","WIN1",nil)

// Monta Estrutura do Tree
oPlanej:No_Tree( aNode_Tree[1], aAliasTree[1], aExpTitleTree[1], aResourceTree[1], bShow_01, bExecMenu )
oPlanej:No_Tree( aNode_Tree[2], aAliasTree[2], aExpTitleTree[2], aResourceTree[2], bShow_02, bExecMenu, bRunEntid, bInclCTTEntid )
oPlanej:No_Tree( aNode_Tree[3], aAliasTree[3], aExpTitleTree[3], aResourceTree[3], bShow_03, bExecMenu, bRunEntid, bInclSRJEntid )
//-----------------------------------------------------------------------------------------------
// TELAS 
//-----------------------------------------------------------------------------------------------
// Cria variaveis de memoria para a MSMGet da Planilha de Planejamento
RegToMemory("ALV", .F.,,, FunName())  // usa no metodo msm
//Cria MsmGet e adiciona ao layou Planej
oPlanej:AddMsm("001", STR0001 ,"ALV",ALV->(Recno()),"WIN2",aLayout[1],{|x| },{|x| }) //"Planejamento"
//Cria listbox contendo centros de custos e adiciona ao layout Planej
oPlanej:AddBrw("001", STR0001 ,{STR0008,STR0009},"WIN3",aLayout[1],{|| AtuBrow()}) //"Codigo"###"Descri็ใo"###"Centro de Custo"

//-----------------------------------------------------------------------------------------------
// Cria variaveis de memoria para a MSMGet dos Centros de Custo e as funcoes abaixo dele
RegToMemory("CTT", .F.,,, FunName())  // usa no metodo msm
//Cria MsmGet e adiciona ao layou Planej
oPlanej:AddMsm("002", STR0002 ,"CTT",CTT->(Recno()),"WIN2",aLayout[2],{|x| },{|x| }) //"Centro de Custo"
//Cria listbox contendo centros de custos e adiciona ao layout Planej
oPlanej:AddBrw("002", STR0003 ,{STR0008,STR0009},"WIN3",aLayout[2],{|| AtuBrwSRJ()}) //"Codigo"###"Descri็ใo"###"Funcใo"

//-----------------------------------------------------------------------------------------------
// Monta aHeader e aCols a ser utilizado na GetDados referente a Grupo de Verbas Saldarios
aCpos := {"ALX_CO","ALX_CLASSE","ALX_OPER","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT", "ALX_CC"}
If ExistBlock("PCOA4961")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4961"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aColsALX 	:= nil
// Cria GetDados da Tela
oPlanej:AddGtD("001",STR0010, "WIN2", aLayout[3], aHeaderALX, aColsALX, {|| PcoLoadALY(aDataPlnj, oPlanej:GetGtd("001")), Eval(bEnchQtd)}, {|x| Find_Agreg()}, {|x| PcoPnjAtu(@oPlanej:GetGtd("001"),SALARIOPLJ, .T. )  } ) //"Planejamento - Salarios"

aCpos := {"ALX_CODIGO","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT", "ALX_CC"}
If ExistBlock("PCOA4962")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4962"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),1] := STR0011 //"Grupo Verba Relac."
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),9] := "AM3"

oPlanej:AddGtD("002", STR0044 , "WIN2", aLayout[3], aHeaderALX, aColsALX, {|| PcoLoadALY(aDataPlnj, oPlanej:GetGtd("002")), Eval(bEnchQtd)}, {|x| Find_Agreg()}, {|x| PcoPnjAtu(@oPlanej:GetGtd("002"),OUTRASVPLJ)} ) //"Composi็ใo de Verbas"

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
oPlanej:AddMsm("003", STR0045 ,"ALY",ALY->(Recno()),"WIN3", aLayout[3], {|| PcoLoadALY(aDataPlnj,,)}, {|x| PcoLoadALY( aDataPlnj , , , .T. , AtuPrc() )}, _aGetQuants) //"Quantidades"
oPlanej:AddMsm("004", STR0046 ,"ALY",ALY->(Recno()),"WIN3", aLayout[3], {|| PcoLoadALY(aDataPlnj,,)}, {|x| PcoLoadALY( aDataPlnj,,,.T.)}, _aGetValues) //"Valores"

oPlanej:ShowLayout(aLayout[1])

// Inicializa o Tree
AtuAgreg(.T.)
AtuBrow()

oPlanej:Activate()

/*
If lAlterPNJ

	Processa( {|| PcoPnjSld() } , STR0047 ) //"Atualizando Saldos"

EndIf	
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuBrow 	บAutor  ณAcacio Egas         บ Data ณ  10/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o ListBox.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuBrow()
Local nX
Local cCargo
Local oTree 	:= oPlanej:GetTre("001")
Local oLstBox 	:= oPlanej:GetBrw("001")

//aCampos eh variavel private
aCampos:= {}
DbSelectArea("CTT")
DbSetOrder(1)

DbSelectArea("AM2")
DbSetOrder(3)

For nX:=1 To Len(oTree:aCargo)

	cCargo := oTree:aCargo[nX,1]

	If Substr(cCargo,1,3)  == "CTT"

		dbSelectArea("AM2")
		If dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHCTT+Substr(cCargo, 4, Len(AM2->AM2_ID)))
			dbSelectArea("CTT")
			If dbSeek(xFilial("CTT")+Alltrim(AM2->AM2_AGREG) )  //AM2 ja esta posicionado
				aAdd(aCampos, { CTT->CTT_CUSTO, CTT->CTT_DESC01 } )
			EndIf	
		EndIf		

	EndIf


Next

If Len(aCampos)=0
	aCampos:= {{'',''}}
EndIf
    
oLstBox:SetArray(aCampos)
oLstBox:bLine := {|| aCampos[oLstBox:nAt] }
oLstBox:Refresh()

ReTurn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuBrwSRJ บAutor  ณAcacio Egas         บ Data ณ  10/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o ListBox.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuBrwSRJ()
Local nX
Local cCargo
Local oTree 	:= oPlanej:GetTre("001")
Local oLstBox 	:= oPlanej:GetBrw("002")
Local aArea     := GetArea()
Local aAreaAM2  := AM2->(GetArea())
Local cIdPai
Local aHeaCTT	:= GetaHeader("CTT")
//aCposBrw eh variavel private
aCposBrw:= {}
DbSelectArea("SRJ")
DbSetOrder(1)

DbSelectArea("AM2")
DbSetOrder(3)

cCargo := oTree:GetCargo()

If cCargo != NIL .And. Substr(cCargo,1,3)  == "CTT"

	cIdPai := AM2->AM2_ID

	dbSelectArea("CTT")
	DbSeek( xFilial("CTT")	+ AM2->AM2_AGREG )
	
    AEval( aHeaCTT , {|x| If(TYPE( "M->" + x[2] )<>"U" .and. x[10]<>"V" , &("M->" + x[2]) := &("CTT->" + x[2]) , .F.) })
    
    oPlanej:GetMsm("002"):EnchRefreshAll()
	
	
	For nX:=1 To Len(oTree:aCargo)
	
		cCargo := oTree:aCargo[nX,1]
	
		If Substr(cCargo,1,3)  == "SRJ"
		
			dbSelectArea("AM2")
			If dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHSRJ+Substr(cCargo, 4, Len(AM2->AM2_ID))) .And. ;
				AM2->AM2_IDPAI = cIdPai
			
				dbSelectArea("SRJ")
				If dbSeek(xFilial("SRJ")+Alltrim(AM2->AM2_AGREG) ) //AM2 ja esta posicionado
					aAdd(aCposBrw, { SRJ->RJ_FUNCAO, SRJ->RJ_DESC } )
				EndIf

			EndIf
	
		EndIf
	
	Next
	
EndIf

If Len(aCposBrw)=0
	aCposBrw:= {{'',''}}
EndIf
    
oLstBox:SetArray(aCposBrw)
oLstBox:bLine := {|| aCposBrw[oLstBox:nAt] }
oLstBox:Refresh()

ReTurn
                 
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

Local oMenu 	:= PopupMenu(oTree)
Local oSideBar 	:= oPlanej:GetSidebar()

If oMenu <> Nil

	oMenu:Activate( x-24, y-100, oSideBar )

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
Local cAlias := SubStr(cCargo,1,3)
Local cCC, cFunc
Local cId
Local bConfExcl := { |x|   	! PcoTemRatALX(oPlanej:Getobj('WIN2')) .And. ;
							Aviso(STR0012,STR0013+x+" ? ", { STR0014, STR0015 }) == 1 } //"Atencao"###"Confirma Exclusao "###"Sim"###"Nao"

Local bDelAlx := {| cId/*cAgregador*/,cTipoPlan,oGetDados,cSeq | PcoDelPnj(cId/*cAgregador*/,cTipoPlan,oGetDados,cSeq) }

Local bRefreshTela := {|x| 	Find_Agreg(), ;
							PcoAtuGtd(x) }

Do Case	
	Case cAlias == "ALV"
		
		If oMenuALV<>nil
		
			oMenuALV:Free()
			
		EndIf
		
		Menu oMenuALV Popup
		MenuItem STR0016	 	Block {|| InsertCTT(oTree)} //"Adicionar Centro de Custo "
//		MenuItem "___________________" Disabled
//		MenuItem STR0017 				Block {|| Pnj100alt() } //"Reajustar Valores"
		EndMenu     

		If !lAlterPNJ
		
			oMenuALV:AITEMS[01]:LACTIVE := .F.
			oMenuALV:AITEMS[03]:LACTIVE := .F.
			
		EndIf
		
		oMenu := oMenuALV
		
	Case cAlias == "CTT"                     
	
		If oMenuCTT<>nil
		
			oMenuCTT:Free()
			
		EndIf
	
		cId := SubStr(cCargo,4,Len(cCargo)-3)
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "009" + cId)
	
		Menu oMenuCTT Popup
		MenuItem STR0018					Block {|| InsertSRJ(oTree) } //"Incluir  Funcao "
		MenuItem STR0019					Block {|| Pco_AM2Posic( oPlanej:GetTre("001"):GetCargo(), PLANILHCTT ), ;
											DelTipo(oTree) } //"Excluir  Centro de Custo "
		MenuItem STR0042					Block {|| PcoExclFunc(oPlanej:GetTre("001"):GetCargo(),PLANILHCTT,oPlanej:GetGtd("001")), ;
												AtuAgreg(.T.,.T.)} //"Excluir Fun็๕es "																		
		MenuItem "___________________" Disabled
		MenuItem STR0021 				Block {|| 	PcoCarCCFunc(oTree:GetCargo(),@cCC,@cFunc), ;
												Gera_Salario(cCC, cFunc, Substr(aDataPlnj[1,1],1,6), Substr(aDataPlnj[Len(aDataPlnj),2],1,6), oPlanej:GetGtd("001") ), ;
												Eval(bRefreshTela,"001") } //"Gerar Grupo Verba Salarios"
		MenuItem STR0023 				Block {|| PcoRunPlan( nil , "009" , 5 , @oPlanej:GetGtd("001") , " ALX_CC='"+ AM2->AM2_AGREG +"' " ) }

		MenuItem "___________________" Disabled
		MenuItem STR0022 				Block {|| 	PcoCarCCFunc(oTree:GetCargo(),@cCC,@cFunc), ;
										Gera_Outras(cCC, nil , Substr(aDataPlnj[1,1],1,6), Substr(aDataPlnj[Len(aDataPlnj),2],1,6), oPlanej:GetGtd("002") ), ;
										Eval(bRefreshTela,"002") } //"Gerar Verbas Relacionadas"
		MenuItem STR0024 				Block {|| PcoRunPlan( nil , "010" , 5 , @oPlanej:GetGtd("002") , " ALX_CC='"+ AM2->AM2_AGREG +"' " ) }

		MenuItem "___________________" Disabled
		MenuItem STR0017 				Block {|| PcoCarCCFunc(oTree:GetCargo(),@cCC,@cFunc),;
										PcoPnjAlt( cId , "ALX_CC='" + cCC + "'" , , { '009' } ),AtuAgreg(.T.,.T.)} //"Reajustar Valores"

		EndMenu      
		
		If !lAlterPNJ
		
			oMenuCTT:AITEMS[01]:LACTIVE := .F.
			oMenuCTT:AITEMS[02]:LACTIVE := .F.
			oMenuCTT:AITEMS[03]:LACTIVE := .F.
			oMenuCTT:AITEMS[05]:LACTIVE := .F.
			oMenuCTT:AITEMS[06]:LACTIVE := .F.
			oMenuCTT:AITEMS[08]:LACTIVE := .F.
			oMenuCTT:AITEMS[09]:LACTIVE := .F.
	
		EndIf
		
		oMenu := oMenuCTT

	Case cAlias == "SRJ"

		cId := SubStr(cCargo,4,Len(cCargo)-3)

		If oMenuSRJ<>nil
		
			oMenuSRJ:Free()
			
		EndIf

		Menu oMenuSRJ Popup
		MenuItem STR0048 Block {|| 	PcoDistShow("ALX_AM2ID='"+cId+"' ",,"009") } //"Visualizar Distribui็ใo "
		MenuItem STR0049 Block {|| 	PcoPnjReProc(cId,"009"),AtuAgreg(.T.,.T.) } //"Alterar Distribui็ใo "
		MenuItem "___________________" Disabled
		
		MenuItem STR0020					Block {|| Pco_AM2Posic( oPlanej:GetTre("001"):GetCargo(), PLANILHCTT ), ;
														DelTipo(oTree) } //"Excluir  Funcao "
														
		MenuItem "___________________" Disabled
		MenuItem STR0021 		Block {|| 	PcoCarCCFunc(oTree:GetCargo(),@cCC,@cFunc), ;
											Gera_Salario(cCC, cFunc, Substr(aDataPlnj[1,1],1,6), Substr(aDataPlnj[Len(aDataPlnj),2],1,6), oPlanej:GetGtd("001") ), ;
											Eval(bRefreshTela,"001") } //"Gerar Grupo Verba Salarios"
											
		MenuItem STR0023 	Block {|| If( Eval(bConfExcl, "SALARIOS"), ; //"Excluir Grupo Verbas Salarios"
																	Eval(bDelAlx, AM2->AM2_ID, SALARIOPLJ, oPlanej:GetGtd("001"), ), ;
																 NIL ) }
		MenuItem "___________________" Disabled
		
		MenuItem STR0022 		Block {|| 	PcoCarCCFunc(oTree:GetCargo(),@cCC,@cFunc), ;
											Gera_Outras(cCC, cFunc, Substr(aDataPlnj[1,1],1,6), Substr(aDataPlnj[Len(aDataPlnj),2],1,6), oPlanej:GetGtd("002") ), ;
											Eval(bRefreshTela,"002") } //"Gerar Verbas Relacionadas"
											
		MenuItem STR0024	 	Block {|| If( Eval(bConfExcl, "VERBAS RELAC."), ; //"Excluir Verbas Relacionadas"
																	Eval(bDelAlx, AM2->AM2_ID, OUTRASVPLJ, oPlanej:GetGtd("002"), ), ;
																 NIL ) }

		MenuItem "___________________" Disabled
		MenuItem STR0017 				Block {|| PcoCarCCFunc(oTree:GetCargo(),@cCC,@cFunc),;
										PcoPnjAlt( cId ,  , , { '009' }),AtuAgreg(.T.,.T.)} //"Reajustar Valores"
		EndMenu		 
		
		If !lAlterPNJ
		
			oMenuCTT:AITEMS[02]:LACTIVE := .F.
			oMenuCTT:AITEMS[04]:LACTIVE := .F.
			oMenuCTT:AITEMS[06]:LACTIVE := .F.
			oMenuCTT:AITEMS[07]:LACTIVE := .F.
			oMenuCTT:AITEMS[09]:LACTIVE := .F.
			oMenuCTT:AITEMS[10]:LACTIVE := .F.
			oMenuCTT:AITEMS[12]:LACTIVE := .F.
	
		EndIf		
		
		oMenu := oMenuSRJ
		
	Otherwise		
		// sem menu
		
EndCase

Return oMenu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInsertCTT บAutor  ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Incluir Centro de Custo e Funcoes no xTree.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InsertCTT(oTree)

Local nX, nZ
Local aConfig 	:= {}
Local cWhere 	:= ""
Local aCCFunc 	:= {}
Local lIncluiFilho	
Local cChavAux

If ParamBox({ 	{ 1, STR0025	,SPACE(Len(CTT->CTT_CUSTO)), "@!", "Vazio() .or. ExistCpo('CTT')"	 ,"CTT"	, ".T."	, 75, .F.	},;  //"Centro de Custo  de "
	  			{ 1, STR0026	,SPACE(Len(CTT->CTT_CUSTO)), "@!", "Vazio() .or. ExistCpo('CTT')"	, "CTT"	, ".T."	, 75, .F.	},; //"Centro de Custo At้"
	  			{ 1, STR0027			,SPACE(Len(SRJ->RJ_FUNCAO)), "@!", "Vazio() .or. ExistCpo('SRJ')"	, "SRJ"	, ".T."	, 65, .F.	},; //"Fun็ใo de"
	  			{ 1, STR0028			,SPACE(Len(SRJ->RJ_FUNCAO)), "@!", "Vazio() .or. ExistCpo('SRJ')"	, "SRJ"	, ".T."	, 65, .F.	}},; //"Fun็ใo At้"
	  			STR0029,aConfig,,,,,,,"PCOA496_01",,.T.) //"Incluir Centro de Custo a Planilha de Planejamento"

	cWhere += " AND RBD_CC >= '"+aConfig[1]+"' AND RBD_CC <= '"+aConfig[2]+"' "
	cWhere += " AND RBD_FUNCAO >= '"+aConfig[3]+"' AND RBD_FUNCAO <= '"+aConfig[4]+"' "
	If cParAprvAtu=="1"
		cWhere += " AND RBD_QTATUA > 0 "
	ElseIf cParAprvAtu=="2"
		cWhere += " AND RBD_QTAPRO > 0 "
	ElseIf cParAprvAtu=="3"
		cWhere += " AND RBD_QTPREV > 0 "
	EndIf

	PcoCarFuncao(cWhere, aCCFunc)

	dbSelectArea("AM2")
	dbSetorder(2)

	For nX := 1 TO Len(aCCFunc)

		dbSelectArea("AM2")

		If dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHCTT+aCCFunc[nX,1])
			Aviso( STR0012 , STR0002 +aCCFunc[nX,1]+ STR0050 , { STR0051 }) //"Atencao"###"Ok"
			cIdPai := AM2->AM2_ID
			nRecAM2 := AM2->(Recno())
		Else
			//inclui centro de custo na tabela AM2
			PcoInsertAM2( aCCFunc[nX,1], PLANILHCTT, "")
		
			cIdPai := AM2->AM2_ID
			nRecAM2 := AM2->(Recno())
		
		EndIf	

		//funcao por centro custo
		For nZ := 1 TO Len(aCCFunc[nX,2])

			lIncluiFilho := .T.
			cChavAux := ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHSRJ+Padr(aCCFunc[ nX, 2, nZ],len(AM2_AGREG))

			dbSelectArea("AM2")

			If dbSeek(cChavAux)
			
				While AM2->(! Eof() .And. AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL+AM2_AGREG == cChavAux)
				
					If AM2->AM2_IDPAI == cIdPai
//						Aviso("Atencao", "No Centro de Custo "+aCCFunc[nX,1]+" ja existe a funcao "+aCCFunc[ nX, 2, nZ]+".", {"Ok"})
						lIncluiFilho := .F.
					EndIf
				
					dbSelectArea("AM2")
					dbSkip()
					
				EndDo

			EndIf

			//inclui funcao na tabela AM2 para o centro de custo correspondente
			If lIncluiFilho
			
				PcoInsertAM2( aCCFunc[ nX, 2, nZ], PLANILHSRJ, cIdPai )
			
				Gera_Salario( aCCFunc[nX,1]/*cCentroCusto*/, aCCFunc[ nX, 2, nZ] /*cFuncao*/, Substr(aDataPlnj[1,1],1,6), Substr(aDataPlnj[Len(aDataPlnj),2],1,6), oPlanej:GetGtd("001") , , .T. )
						
			EndIf

		Next
		
		//posiciona no pai novamente para montar a arvore
		AM2->(dbGoto(nRecAM2))
		
	Next
	
	AtuAgreg(.T., .T.)
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInsertSRJ บAutor  ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Incluir Funcoes no xTree abaixo do Centro de Custo.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InsertSRJ(oTree)

Local nX, nZ
Local aConfig := {}
Local cWhere 	:= ""
Local aCCFunc 	:= {}
Local cCargo 	:= oTree:GetCargo()
Local cIdPai 		:= Substr( cCargo , 4 , Len(cCargo) - 3 )

If ParamBox({ 	{ 1, STR0027	, SPACE(Len(SRJ->RJ_FUNCAO)), "@!", "Vazio() .or. ExistCpo('SRJ')", "SRJ", ".T.", 60, .F.	},; //"Fun็ใo de"
	  			{ 1, STR0028	, SPACE(Len(SRJ->RJ_FUNCAO)), "@!", "Vazio() .or. ExistCpo('SRJ')", "SRJ", ".T.", 60, .F.	}}, ; //"Fun็ใo At้"
	  			STR0030,aConfig,,,,,,,"PCOA496_02",,.T.) //"Incluir Fun็ใ ao Centro de Custo da Planilha de Planejamento"

	//aqui devo considerar o centro de custo que estiver posicionado (esta no cargo)
	cWhere += " AND RBD_CC = '"+AM2->AM2_AGREG+"' "  //AM2 esta posicionado
	cWhere += " AND RBD_FUNCAO >= '"+aConfig[1]+"' AND RBD_FUNCAO <= '"+aConfig[2]+"' "

	PcoCarFuncao(cWhere, aCCFunc)

	dbSelectArea("AM2")
	dbSetOrder(2)
	
	For nX := 1 TO Len(aCCFunc)  //DEVERA CARREGAR SOMENTE UM CENTRO DE CUSTO

		//funcao por centro custo
		For nZ := 1 TO Len(aCCFunc[nX,2])

			lIncluiFuncao := .T.
			cChavAux := ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHSRJ+aCCFunc[ nX, 2, nZ]

			dbSelectArea("AM2")

			If dbSeek(cChavAux)
			
				While AM2->(! Eof() .And. AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL+AM2_AGREG == cChavAux)
				
					If AM2->AM2_ID == cIdPai
						Aviso( STR0031 , STR0052 +aCCFunc[nX,1] + aCCFunc[ nX, 2, nZ]+".", {"Ok"}) //"Atencao"###"No Centro de Custo "###" ja existe a funcao "
						lIncluiFuncao := .F.
					EndIf
				
					dbSelectArea("AM2")
					dbSkip()
					
				EndDo

			EndIf

			//inclui funcao na tabela AM2 para o centro de custo correspondente
			If lIncluiFuncao
				PcoInsertAM2( aCCFunc[ nX, 2, nZ], PLANILHSRJ, cIdPai )
				oPlanej:LoadTree( oTree, "SRJ", aCCFunc[ nX, 2, nZ],,2,.F.,,,"'"+AM2->AM2_ID+"'" )				
			EndIf	
		
		Next
		
	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelTipo	บAutor  ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Excluir Centro de Custo ou Funcaono xTree .                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DelTipo(oTree)

Local cCargo 	:= oTree:GetCargo()
Local cAgreg	:= AM2->AM2_AGREG    //AM2 estara posicionado
Local lContinua := .T.
Local cAlias 	:= Left(cCargo, 3)
Local nRecAM2

DbSelectArea("ALX")
DbSetOrder(1)

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"001"+cAgreg)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"002"+cAgreg)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"003"+cAgreg)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"004"+cAgreg)

	lContinua := .F.

EndIf
	
If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+SALARIOPLJ+cAgreg)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+OUTRASVPLJ+cAgreg)

	lContinua := .F.

EndIf

If lContinua


	If cAlias == "CTT"

		nRecAM2 := AM2->(Recno())

		//primeiro passo - Verificar se existe funcao (SRJ) amarradas ao centro de custo
		lContinua := PcoVer_FunCC(AM2->AM2_ID)

        //deleta AM2 corresponde ao centro de custo
         dbSelectArea("AM2")
         dbGoto(nRecAM2)
         If lContinua
			RecLock("AM2",.F.)
			DbDelete()
			MsUnlock()

			//retira no do Tree		
			oTree:DelItem()

		Else
			
				Aviso(STR0031,STR0032,{ STR0051 }) //"Aten็ใo"###"Existem fun็๕es para este centro de custo. Favor excluir as fun็๕es."###"OK"
				
		EndIf	
	
	ElseIf cAlias == "SRJ"

        //deleta AM2
		RecLock("AM2",.F.)
		DbDelete()
		MsUnlock()

		//retira no do Tree		
		oTree:DelItem()

	EndIf
	
Else
	
	Aviso(STR0031,STR0033,{ STR0051 }) //"Aten็ใo"###"Existem lan็amentos para este agregador. Favor excluir os lan็amentos."###"OK"
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFind_Agreg บAutor ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza aCols.                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Find_Agreg()

Local cSeek
                                 
Local cCargo	:= oPlanej:GetTre("001"):GetCargo()
Local oGetDd_01 := oPlanej:GetGtd("001")
Local oGetDd_02 := oPlanej:GetGtd("002")
Local aAreaAM2  := AM2->(GetArea())
Local cCentroCusto 
cSeek	:= ''

If SubStr(cCargo,1,3)=="SRJ"

	If ! Empty(AM2->AM2_IDPAI)  //AM2 esta posicionado
		dbSelectArea("AM2")
		dbSetorder(3)
		If dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHCTT+AM2->AM2_IDPAI)
			cCentroCusto := AM2->AM2_AGREG
			cSeek 	+= " AND ALX_CC = '"+cCentroCusto+"' "
		EndIf
	EndIf
    RestArea(aAreaAM2)  //para voltar ordem e registro que estava posicionado
    
	PcoFindALX( AM2->AM2_ID, SALARIOPLJ, oGetDd_01, cSeek )
	PcoFindALX( AM2->AM2_ID, OUTRASVPLJ, oGetDd_02, cSeek )
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuAgreg  บAutor  ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tree e listbox com todos os Centros de Custo.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuAgreg(lIni, lRefresh)

Local nX
Local cTipoPlanilha 
Local nPosCTT

Local aAreaALV 	:= ALV->( GetArea() )
Local aArea 	:= GetArea()
Local aLoad 	:= {}
Local oTree 	:= oPlanej:GetTre("001")
Local oLstBox 	:= oPlanej:GetBrw("001")
Local cIdPai
Default lIni 		:= .F.
Default lRefresh 	:= .F.

cTipoPlanilha := PLANILHCTT

If lIni
	oTree:Reset()
EndIf

DbSelectArea("AM2")
DbSetorder(2)

DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+cTipoPlanilha)

Do While AM2->(! Eof() .And. ;
				AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL == ALV->(xFilial("AM2")+ALV_CODIGO+ALV_VERSAO+cTipoPlanilha) )

		If !Empty(AM2->AM2_IDPAI) //se estiver preenchido eh filho
			dbSelectArea("AM2")
			dbSkip()
			Loop
		EndIf
		
		DbSelectArea("CTT")
		DbSetOrder(1)
		DbSeek(xFilial("CTT")+AM2->AM2_AGREG)
		
		If  ( nPosCtt := aScan( aLoad,{ |x| x[1] + Alltrim(x[2]) == "CTT" + xFilial("CTT")+ Alltrim(AM2->AM2_AGREG) } ) ) ==0 
			aAdd(aLoad,{"CTT",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'"})
			nPosCtt := Len(aLoad)
		EndIf
		
        cAgreg  := AM2->AM2_AGREG
        nRecAM2 := AM2->(Recno())
        cIdPai  := AM2->AM2_ID
            
		DbSelectArea("AM2")
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+PLANILHSRJ)

		Do While AM2->(! Eof() .And. ;
						AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL == ALV->(xFilial("ALV")+ALV->ALV_CODIGO+_cVerPlan+PLANILHSRJ) )

			If !Empty(AM2->AM2_IDPAI) .And. ;//somente se o ID PAI estiver preenchido eh q eh filho 
				AM2->AM2_IDPAI  == cIdPai     // Se for filho deste pai entao adiciona ao noh 
			
				DbSelectArea("SRJ")
				DbSetOrder(1)
				DbSeek(xFilial("SRJ")+AM2->AM2_AGREG)

				If aScan(aLoad[nPosCTT,3],{|x|x[1]+x[2]=="SRJ"+AM2->AM2_AGREG })==0
					aAdd(aLoad[nPosCTT,3],{"SRJ",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'"})
				EndIf

			EndIf
	
			dbSelectArea("AM2")
			dbSkip()
			
		EndDo
		
	dbSelectArea("AM2")
	dbGoto(nRecAM2)

	AM2->(DbSkip())

EndDo               

// Monta Tree             
If lIni
	oPlanej:LoadTree(oTree,"ALV",ALV->ALV_CODIGO,,1,.F.,aLoad)
	If lRefresh
		oTree:Display()
		oTree:TreeSeek(oTree:aCargo[1,1])
		oPlanej:ShowLayout("Planej")
	EndIf	
EndIf

//monta list box 
aCampos:= {}
For nX := 1 To Len(oTree:aCargo)
	
	DbSelectArea("CTT")
	DbSetOrder(1)
	cCargo := oTree:aCargo[nX,1]
	
	If SubStr(cCargo,1,3) == "CTT"

		Pco_AM2Posic( cCargo, PLANILHCTT )
	
		DbSeek(xFilial("CTT")+AM2->AM2_AGREG)
		
		aAdd( aCampos, { CTT->CTT_CUSTO, CTT->CTT_DESC01 } )
		
	EndIf
	
Next

If Len(aCampos)==0
	aCampos := { { '', '' } }
EndIf

oLstBox:SetArray(aCampos)
oLstBox:bLine := {|| aCampos[oLstBox:nAt] }
oLstBox:Refresh()

RestArea(aAreaALV)
RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoCarFuncao    บAutor  ณPaulo Carnelossi    บ Data ณ  03/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega no array passado (2o.parametro) para a funcao todos os   บฑฑ
ฑฑบ          ณ registros da tabela RBD que satisfaca a condicao especificada na บฑฑ
ฑฑบ          ณ clausula Where (1o. parametro)                                   บฑฑ
ฑฑบ          ณ Group by por Centro de custo e funcao                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoCarFuncao(cWhere, aCCusFunc)
Local cCCAux
Local cQuery 		:= ""

cQuery += " SELECT RBD_CC, RBD_FUNCAO FROM  " + RetSqlName("RBD")
cQuery += " WHERE "
cQuery += " RBD_FILIAL = '"+xFilial("RBD")+"' "
cQuery += cWhere
cQuery += " AND D_E_L_E_T_ =  ' '"
cQuery += " GROUP BY RBD_CC, RBD_FUNCAO "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

dbSelectArea("TMPAUX")
dbGoTop()

While ! Eof()

	aAdd(aCCusFunc, { RBD_CC, {} } )
	cCCAux := TMPAUX->RBD_CC
	
	While TMPAUX->( ! Eof() .And. RBD_CC == cCCAux )
	
		aAdd( aCCusFunc[ Len(aCCusFunc), 2 ], TMPAUX->RBD_FUNCAO ) 
		
		dbSelectArea("TMPAUX")
		dbSkip()
		
	EndDo
	
EndDo


dbSelectArea("TMPAUX")
dbCloseArea()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoRetGrVerbaบAutor ณPaulo Carnelossi   บ Data ณ  08/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna array aGrpVerba para o codigo do grupo de verba    บฑฑ
ฑฑบ          ณ informado conforme layout abaixo:                          บฑฑ
ฑฑบ          ณ //1a.Posicao Conta Orcamentaria                            บฑฑ
ฑฑบ          ณ //2a.Posicao Classe Orcamentaria                           บฑฑ
ฑฑบ          ณ //3a.Posicao Operacao Orcamentaria                         บฑฑ
ฑฑบ          ณ //4a.Posicao Item Contabil (CTB)                           บฑฑ
ฑฑบ          ณ //5a.Posicao Classe de Valor (CTB)                         บฑฑ
ฑฑบ          ณ //6a.Posicao Indica se eh por 1-qtde | 2-Valor  (default)  บฑฑ
ฑฑบ          ณ //7a.Posicao Caso por Qtde Informa Valor a ser computado   บฑฑ
ฑฑบ          ณ para cada ocorrencia (ie, p/ cada unidade de ALY_QUANT)    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoRetGrVerba(cGrpVerba)
Local aGrpVerba := {}
Local aArea := GetArea()

dbSelectArea("AM3")
dbSetOrder(1)

If dbSeek(xFilial("AM3")+cGrpVerba)
	aAdd(aGrpVerba, AM3->AM3_CO) 		//1a.Posicao Conta Orcamentaria
	aAdd(aGrpVerba, AM3->AM3_CLASSE) 	//2a.Posicao Classe Orcamentaria
	aAdd(aGrpVerba, AM3->AM3_OPER) 		//3a.Posicao Operacao Orcamentaria
	aAdd(aGrpVerba, AM3->AM3_ITCTB) 	//4a.Posicao Item Contabil (CTB)
	aAdd(aGrpVerba, AM3->AM3_CLVLR) 	//5a.Posicao Classe de Valor (CTB)
	aAdd(aGrpVerba, AM3->AM3_TPVLR) 	//6a.Posicao Indica se eh por Valor (default) ou por quantidade
	aAdd(aGrpVerba, AM3->AM3_QUANT) 	//7a.Posicao Valor a ser multiplicada por cada unid/qtde 
EndIf

RestArea(aArea)

Return( { aClone(aGrpVerba) })
		
Static Function PcoVer_FunCC(cIdentPai)
Local aArea := GetArea()
Local cQuery := ""
Local lContinua

cQuery += " SELECT AM2_AGREG FROM  " + RetSqlName("AM2")
cQuery += " WHERE "
cQuery += " AM2_FILIAL = '"+xFilial("AM2")+"' "
cQuery += " AND AM2_TIPOPL = '"+PLANILHSRJ+"' "
cQuery += " AND AM2_IDPAI = '"+cIdentPai+"' "
cQuery += " AND D_E_L_E_T_ =  ' '"


cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

dbSelectArea("TMPAUX")
dbGoTop()

lContinua := Eof()  //se nao encontrar nenhum registro no result da query entao nao tem filhos

dbSelectArea("TMPAUX")
dbCloseArea()

RestArea(aArea)

Return(lContinua)

Static Function PcoAtuGtd(x)
Local nIpFolder

If ( nIpFolder := aScan(oPlanej:aObjetos,{|x|Alltrim(x[1])=="FLDCC_FuncaoWIN3"}) ) != 0
	//TENTATIVA DE FOCAR NO OBJETO QUE ACABOU DE SER GERADO -- GERA SALARIO OU GERA VERBAS RELAC
	oPlanej:aObjetos[1,2,1]:SetFocus()
	oPlanej:aObjetos[nIpFolder,2]:SetOption(Val(x))
	oPlanej:aObjetos[nIpFolder,2]:aDialogs[Val(x)]:Refresh()
	oPlanej:GetGtd(x):oBrowse:SetFocus()
	
EndIf	

Return


Static Function Pco_AM2Posic( cCargo, cTipoPlan )

dbSelectArea("AM2")
dbSetorder(3)

If ! dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cTipoPlan+SubStr(cCargo,4,Len(AM2->AM2_ID)))
	alert("Erro ao posicionar na tabela AM2") //"Erro ao posicionar na tabela AM2"
EndIf

Return


Function PcoCarCCFunc(cCargo, cCentroCusto, cFuncao )
Local cAliasAux := Left(cCargo, 3)
Local aAreaAM2

aAreaAM2 := AM2->(GetArea())
	
dbSelectArea("AM2")
dbSetorder(3)
dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHCTT+SubStr(cCargo,4,Len(AM2->AM2_ID)) )

If cAliasAux $ "CTT|SRJ"

	If cAliasAux == "CTT"
		cCentroCusto := AM2->AM2_AGREG
		
	ElseIf cAliasAux == "SRJ"

		cFuncao := AM2->AM2_AGREG

		If ! Empty(AM2->AM2_IDPAI)
			dbSelectArea("AM2")
			dbSetorder(3)
			If dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+PLANILHCTT+AM2->AM2_IDPAI)
					cCentroCusto := AM2->AM2_AGREG
			EndIf
		
		EndIf
		
	EndIf

EndIf

RestArea(aAreaAM2)

Return

Static Function AtuPrc()

Local aListPara := {}
Local aConfig 	:= {}
Local nVlUnit 	:= nil
Local cCargo 	:= oPlanej:GetTre("001"):GetCargo()
Local cId

cId := SubStr(cCargo,4,Len(cCargo)-3)

DbSelectArea("AM2")
DbSetOrder(3)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"009"+cId)

DbSelectArea("SRJ")
DbSetOrder(1)
If DbSeek( xFilial("SRJ") + AM2->AM2_AGREG )

	aAdd(aListPara,{1, STR0056 ,SRJ->RJ_SALARIO,"@E 999,999.99",,,".T.",60,.F.}) //"Salario"
	
	If ParamBox( aListPara , STR0057 , @aConfig ) //"Atualiza็ใo de Salario"

		nVlUnit := aConfig[1]

	EndIf

EndIf

Return (nVlUnit)