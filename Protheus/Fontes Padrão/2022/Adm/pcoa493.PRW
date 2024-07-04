// Copyright (C) 2007, Microsiga

#include "protheus.ch"
#include "pcoa493.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA493   บAutor  ณAcacio Egas         บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Planejamento de Receitas	                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static oMenuALV,oMenuSB1X,oMenuSB1

Function PCOA493( cAlias , nReg , nOpcx , aCpos , cVerPlan )

Local nWidth  := GetScreenRes()[1] - 40
Local nHeight := GetScreenRes()[2] - 200
Local aCposUsr
Local _nContItem
Local aColsALX, aHeaderALX

If ALV->ALV_STATUS == "2" .and. cVerPlan==nil  // ORCAMENTO EM REVISAO 
	HELP("  ",1,"PCOA100REV")
	Return
EndIf

Private lAlterPNJ	:= ( nOpcx==4 )
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

//Cria  Layouts para a Tela   
oPlanej:AddLayout("Planej")
oPlanej:AddLayout("Distri")

oPlanej:addSide(28, STR0002 ) //"Estrutura"

oPlanej:AddWindow(96,"WIN1", STR0002 ,2,.F.,.F.,oPlanej:oArea:oSideBar) //"Estrutura"

oPlanej:AddTre("001","WIN1",nil)


// Monta Estrutura do Tree
oPlanej:No_Tree( STR0003 ,"ALV"	,"ALLTRIM(ALV_CODIGO)+'-'+ALV_DESCRI"	,"RPMCPO"	,{|| oPlanej:ShowLayout("Planej")					}	,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)}	,) // "Planejamento"
oPlanej:No_Tree( STR0004 ,"SB1"	,"ALLTRIM(B1_COD)+'-'+B1_DESC"			,"SIMULACA"	,{|| oPlanej:ShowLayout("Distri"),Find_Agreg()		}	,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)}	,{|| /*RunEntid()*/},{|x,y| PcoIncAM2(x,"001",,PcoGetAm2(y),.F.) }) // "Produto"
oPlanej:No_Tree( STR0005 ,"SB1X","ALLTRIM(B1_COD)+'-'+B1_DESC"			,"SduCount"	,{|| oPlanej:ShowLayout("Distri"),Find_Agreg()	}		,{|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)}	,{|| /*RunEntid()*/},{|| }) //"Relacionado"

//Cria  Layouts para a Tela
oPlanej:AddLayout("Planej")
oPlanej:AddLayout("Distri")

aButs := {}

If lAlterPNJ
	
	aAdd( aButs , { 1, "GPRIMG32"	, 	{|| PcoRatALX(oPlanej:Getobj('WIN2')) }			, STR0006	, .F. } )
	aAdd( aButs , { 1, "EXCLUIR"	, 	{|| PcoExclRatALX(oPlanej:Getobj('WIN2')) }		, STR0008	, .F. } )//"Incluir Rateio"###"Visualizar Rateio"###"Excluir Rateio"

EndIf
aAdd( aButs , { 1, "RELATORIO"	, 	{|| PcoVisuRateioALX(oPlanej:Getobj('WIN2')) }	, STR0007	, .F. } )

// Adiciona Janela 2 com Bot๕es - servira para conter o cadastro centro de custo /ou Funcao /ou GetDados
oPlanej:AddWindow( 48 , "WIN2" , STR0009 , 3 , lAlterPNJ , , , aButs ) //"Distribui็ใo de Entidades"

// Monta aHeaderALX da GetDados

// Inclui campos no GetDados de Receitas Diretas
aCpos := {"ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4931")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4931"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aColsALX 	:= nil
// Cria GetDados da Tela

oPlanej:AddGtD("001", STR0010 , "WIN2" , "Distri" , aHeaderALX , aColsALX , {|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("001"))} , {|x| Find_Agreg()} , {|x| PcoPnjAtu(@oPlanej:GetGtd("001"),"001",.T.)} ) //"Receitas Diretas"

// Inclui campos no GetDados de Receitas relacionadas
aCpos := {"ALX_CODIGO","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4932")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4932"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),1] := "Prod. Relac."
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),9] := "SB1"
oPlanej:AddGtD("002", STR0011 , "WIN2" , "Distri" , aHeaderALX , aColsALX , {|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("002"))} , {|x| Find_Agreg()} , {|x| PcoPnjAtu(@oPlanej:GetGtd("002"),"002",.T.)} ) //"Receitas Relacionadas"

// Inclui campos no GetDados de Movimentos relacionadas
aCpos := {"ALX_CODIGO","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA",,"ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4933")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4933"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),1] := "Tp Movimento"
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),9] := "ALQ"
oPlanej:AddGtD("003", STR0012 , "WIN2" , "Distri" , aHeaderALX , aColsALX , {|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("003"))}	, {|x| Find_Agreg()} , {|x| PcoPnjAtu(@oPlanej:GetGtd("003"),"003",.T.)} ) //"Movimentos Relacionados"

// Inclui campos no GetDados de Custo relacionadas
aCpos := {"ALX_CODIGO","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA",,"ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4934")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4934"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),1] := "Produto"
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),9] := "SB1"
oPlanej:AddGtD("004", STR0013 , "WIN2" , "Distri" , aHeaderALX , aColsALX , {|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("004"))} , {|x| Find_Agreg()} , {|x| PcoPnjAtu(@oPlanej:GetGtd("004"),"004",.T.)} ) //"Custos Direto"

// Inclui campos no GetDados de Contra Partida
aCpos := {"ALX_CODIGO","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA",,"ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOA4935")
	If VALTYPE(aCposUsr := ExecBlock("PCOA4935"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeaderALX := GetAHeader("ALX",aCpos,)
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),1] := STR0014//"Tp Movimento"
aHeaderALX[aScan(aHeaderALX,{|x|x[2]=='ALX_CODIGO'}),9] := "ALQ"

// Cria variaveis de memoria para a MSMGet
RegToMemory("ALV", .F.,,, FunName())
//Cria MsmGet
oPlanej:AddMsm("001", STR0015 , "ALV" , ALV->(Recno()) , "WIN2" , "Planej" , {|x| } , {|x| } ) //"Planejamento"

// Adiciona Janela 2
oPlanej:AddWindow(48,"WIN3", STR0016 , 2 , lAlterPNJ , "Distri" ) //"Distribui็ใo de Valores"

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
oPlanej:AddMsm("003", STR0017 , "ALY" , ALY->(Recno()) , "WIN3" , "Distri" , {|| PcoLoadALY(aDataPlnj,,)} , {|x| PcoLoadALY(aDataPlnj,,,.T.,AtuPrc()) 	} , _aGetQuants ) //"Quantidades"
oPlanej:AddMsm("002", STR0018 , "ALY" , ALY->(Recno()) , "WIN3" , "Distri" , {|| PcoLoadALY(aDataPlnj,,)} , {|x| PcoLoadALY(aDataPlnj,,,.T.) 			} , _aGetValues ) //"Valores"

//Cria Browse de produtos
oPlanej:AddBrw("001", STR0019 , { STR0020 , STR0021 } , "WIN3" , "Planej" , {|| AtuBrow()} ) //"Produtos"###"Codigo"###"Descri็ใo"

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

	Processa( {|| PcoPnjSld() } , STR0022 ) //"Atualizando Saldos"

EndIf
*/

Return

Static Function AtuBrow()
Local nX
//Local nBrow := oPlanej:GetBrw("001")
	aCampos:= {}
	For Nx:=1 To Len(oPlanej:GetTre("001"):aCargo)
		cCargo := oPlanej:GetTre("001"):aCargo[Nx,1]		
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+SubStr(cCargo,4,Len(cCargo)-3))

		
		DbSelectArea("SB1")
		DbSetOrder(1)
		If SubStr(cCargo,1,3)="SB1" .and. SubStr(cCargo,4,1)<>"X"
			DbSeek(xFilial("SB1")+AM2->AM2_AGREG)
			aAdd(aCampos,{SB1->B1_COD,SB1->B1_DESC})
		EndIf
	Next
    If Len(aCampos)=0
    	aCampos:= {{'',''}}
    EndIf
    
	oPlanej:GetBrw("001"):SetArray(aCampos)
	oPlanej:GetBrw("001"):bLine := {|| aCampos[oPlanej:GetBrw("001"):nAt] }
	oPlanej:GetBrw("001"):Refresh()
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

Local oMenu

oMenu:= PopupMenu(@oTree)

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
Local cAlias := SubStr(cCargo,1,4)
Local cId

Do Case	
	
	Case SubStr(cAlias,1,3) == "ALV"

		If oMenuALV<>nil
		
			oMenuALV:Free()
			
		EndIf

		Menu oMenuALV Popup
		MenuItem STR0023 	Block {|| InsertTipo(@oTree)} //"Adicionar Produto "
		MenuItem "___________________" Disabled
		MenuItem STR0024	Block {|| PcoRunPlan(nil,"004",3,@oPlanej:GetGtd("004"),"ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' ") } //"Gerar Custos Diretos"
		MenuItem STR0025	Block {|| PcoRunPlan(nil,"004",5,@oPlanej:GetGtd("004"),"ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' ") } // "Excluir Custos Diretos"
		MenuItem "___________________" Disabled
		MenuItem STR0026	Block {|| PcoPnjAlt( , , ,  {'001','002' } ),AtuAgreg(.T.,.T.),P493DesBot()} //"Reajustar Rceita"
		MenuItem STR0027	Block {|| PcoPnjAlt( , , ,  {'004'} ),AtuAgreg(.T.,.T.),P493DesBot()} //"Reajustar Custo"
		EndMenu

		If !lAlterPNJ
		
			oMenuALV:AITEMS[01]:LACTIVE := .F.
			oMenuALV:AITEMS[03]:LACTIVE := .F.
			oMenuALV:AITEMS[04]:LACTIVE := .F.
			oMenuALV:AITEMS[06]:LACTIVE := .F.
			oMenuALV:AITEMS[07]:LACTIVE := .F.

			
		EndIf

		oMenu := oMenuALV

	Case SubStr(cAlias,1,4) == "SB1X"

		cId := SubStr(cCargo,5,Len(cCargo)-4)
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
		
		If oMenuSB1X<>nil
        
			oMenuSB1X:Free()
		
		EndIf
		
		Menu oMenuSB1X Popup
		MenuItem STR0028	Block {|| 	PcoDistShow("ALX_AM2ID='"+cId+"' ",,"002") } //"Visualizar Distribui็ใo "
		MenuItem "___________________" Disabled
		MenuItem STR0029 	Block {|| PcoRunPlan(cId,"003",3,@oPlanej:GetGtd("003"), "ALX_CODIGO='" + AM2->AM2_AGREG + "' AND ALX_AGREG='" + PcoGetAm2(AM2->AM2_IDPAI,.T.) + "' AND ALX_TIPOPL='002'" ,,{.F.}) } //"Gerar Movimentos Relacionados"
		MenuItem STR0030 	Block {|| PcoRunPlan(cId,"003",5,@oPlanej:GetGtd("003")) } //"Excluir Movimentos Relacionados"
		MenuItem "___________________" Disabled
		MenuItem STR0024	Block {|| PcoRunPlan(  cId,"004",3,@oPlanej:GetGtd("004")) } //"Gerar Custos Direto"
		MenuItem STR0025	Block {|| PcoRunPlan(  cId,"004",5,@oPlanej:GetGtd("004")) } //"Excluir Custos Diretos"
		MenuItem "___________________" Disabled
		MenuItem STR0026	Block {||   PcoPnjAlt(AM2->AM2_ID , nil , nil , {'001','002' } ),AtuAgreg(.T.,.T.),P493DesBot() } //"Reajustar Receita"
		MenuItem STR0027	Block {||   PcoPnjAlt(AM2->AM2_ID , nil , nil , {'004'} ),AtuAgreg(.T.,.T.),P493DesBot() } //"Reajustar Custo"
		EndMenu
	
		If !lAlterPNJ
		
			oMenuSB1X:AITEMS[03]:LACTIVE := .F.
			oMenuSB1X:AITEMS[04]:LACTIVE := .F.
			oMenuSB1X:AITEMS[06]:LACTIVE := .F.
			oMenuSB1X:AITEMS[07]:LACTIVE := .F.
			oMenuSB1X:AITEMS[09]:LACTIVE := .F.
			oMenuSB1X:AITEMS[10]:LACTIVE := .F.
			
		EndIf
	
		oMenu := oMenuSB1X		
			
	Case SubStr(cAlias,1,3) == "SB1"		

		cId := SubStr(cCargo,4,Len(cCargo)-3)			
	
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "001" + cId)
	    
		If oMenuSB1<>nil
		
			oMenuSB1:Free()
			
		EndIf
		
		Menu oMenuSB1 Popup
		MenuItem STR0028	Block {|| 	PcoDistShow("ALX_AM2ID='"+cId+"' ",,"001") } //"Visualizar Distribui็ใo "
		MenuItem STR0031	Block {|| 	PcoPnjReProc(cId,"001"),AtuAgreg(.T.,.T.) } //"Alterar Distribui็ใo "
		MenuItem "___________________" Disabled
		MenuItem STR0032	Block {|| DelTipo(@oTree) } //"Excluir  Produto "
		MenuItem "___________________" Disabled
		MenuItem STR0033	Block {|| PcoRunPlan(cId,"001",3,@oPlanej:GetGtd("001")) } //"Gerar Receitas "
		MenuItem STR0034	Block {|| PcoRunPlan(cId,"001",5,@oPlanej:GetGtd("001")) }
		MenuItem "___________________" Disabled
		MenuItem STR0035	Block {|| PcoRunPlan(cId,"002",3,@oPlanej:GetGtd("002")) } //"Gerar Receitas Relacionadas"
		MenuItem STR0036 	Block {|| PcoRunPlan(nil,"002",5,@oPlanej:GetGtd("002")," ALX_AGREG='"+ AM2->AM2_AGREG +"' ") } //"Excluir Receitas Relacionadas"
		MenuItem "___________________" Disabled
		MenuItem STR0029 	Block {|| PcoRunPlan(cId,"003",3,@oPlanej:GetGtd("003")	 ," ALX_AGREG='"+ AM2->AM2_AGREG +"' ") } //"Gerar Movimentos Relacionados"
		MenuItem STR0030 	Block {|| PcoRunPlan(cId,"003",5,@oPlanej:GetGtd("003")," ALX_AGREG='"+ AM2->AM2_AGREG +"' ") } //"Excluir Movimentos Relacionados"
		MenuItem "___________________" Disabled
		MenuItem STR0024	Block {|| PcoRunPlan(  cId,"004",3,@oPlanej:GetGtd("004")," ALX_AGREG='"+ AM2->AM2_AGREG +"' ") } //"Gerar Custos Diretos"
		MenuItem STR0025 	Block {|| PcoRunPlan(  cId,"004",5,@oPlanej:GetGtd("004")," ALX_AGREG='"+ AM2->AM2_AGREG +"' AND ALX_TIPOPL='004'") } //"Excluir Custos Diretos"
		MenuItem "___________________" Disabled
		MenuItem STR0026	Block {|| PcoPnjAlt( AM2->AM2_ID , "ALX_AGREG='" + AM2->AM2_AGREG + "' " , nil , {'001','002' } ),AtuAgreg(.T.,.T.),P493DesBot()} //"Reajustar Receita"
		MenuItem STR0027	Block {|| PcoPnjAlt( AM2->AM2_ID , "ALX_AGREG='" + AM2->AM2_AGREG + "' " , nil , {'004'} ),AtuAgreg(.T.,.T.),P493DesBot()} //"Reajustar Custo"
		EndMenu
    
		If !lAlterPNJ
		
			oMenuSB1:AITEMS[02]:LACTIVE := .F.
			oMenuSB1:AITEMS[04]:LACTIVE := .F.
			oMenuSB1:AITEMS[06]:LACTIVE := .F.
			oMenuSB1:AITEMS[07]:LACTIVE := .F.
			oMenuSB1:AITEMS[09]:LACTIVE := .F.
			oMenuSB1:AITEMS[10]:LACTIVE := .F.
			oMenuSB1:AITEMS[12]:LACTIVE := .F.
			oMenuSB1:AITEMS[13]:LACTIVE := .F.
			oMenuSB1:AITEMS[15]:LACTIVE := .F.
			oMenuSB1:AITEMS[16]:LACTIVE := .F.
			oMenuSB1:AITEMS[18]:LACTIVE := .F.
			oMenuSB1:AITEMS[19]:LACTIVE := .F.
			
		EndIf
        
		oMenu := oMenuSB1

	Otherwise
		// sem menu

EndCase

Return oMenu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsertTipo       บAutor  ณAcacio Egas   บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Distribui Produtos no xTree.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function InsertTipo(oTree)

Local aConfig
If ParamBox({ 	{1, STR0037 ,SPACE(Len(SB1->B1_COD))		,"@S15"	,"Vazio() .or. ExistCpo('SB1',,,,,.F.)","SB1",".T.",75,.F.	},; 
	  			{1, STR0038 ,SPACE(Len(SB1->B1_COD))		,"@S15"	,"Vazio() .or. ExistCpo('SB1',,,,,.F.)","SB1",".T.",75,.F.	},;
	  			{1,	STR0039 ,SPACE(Len(SBM->BM_GRUPO))		,"@S4"	,""		,"SBM",".T."		,4,.F.	},;
	  			{1, STR0040	,SPACE(Len(SBM->BM_GRUPO))		,"@S4"	,""		,"SBM",".T."	,4,.F.	}}, STR0041 ,@aConfig,,,,,,,"PCOA493_01",,.T.) //"Produto de "###"Produto ate"###"Grupo de"###"Grupo ate"###"Distribui็ใo do Planejamento"

	
	oPlanej:LoadTree( @oTree , "SB1" , aConfig[1] , aConfig[2] ,,,,, "AM2->AM2_ID" )
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

DbSelectarea("AM2")
DbSetOrder(3)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)

DbSelectArea("ALX")
DbSetOrder(1)

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"001"+AM2->AM2_AGREG)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"002"+AM2->AM2_AGREG)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"003"+AM2->AM2_AGREG)

	lContinua := .F.

EndIf

If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+_cVerPlan+"004"+AM2->AM2_AGREG)

	lContinua := .F.

EndIf
	
If lContinua

	DbSelectArea("AM2")
//	DbSetOrder(2)
//	If DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+AM2->AM2_AGREG)

		RecLock("AM2",.F.)                   
			DbDelete()
		MsUnlock()
		oTree:DelItem()
		AtuAgreg()
//	EndIf
Else
	Aviso( STR0042 , STR0043 ,{ STR0044 }) //"Aten็ใo"###"Existem lan็amentos para este agregador. Favor excluir os lan็amentos."###"OK"
EndIf

 Return


// Atualiza aCols
Static Function Find_Agreg()
                                
Local cCargo		:= oPlanej:GetTre("001"):GetCargo()
Local cId

If SubStr(cCargo,1,4)="SB1X"
    
	cId 	:= SubStr(cCargo,5,Len(cCargo)-4)

	DbSelectArea("AM2")
	DbSetOrder(3)
	DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
	
	PcoFindALX(cId	,"002",@oPlanej:GetGtd("001")) // Mostra a receita relacionada no Receita direta
	PcoFindALX('XX'	,"002",@oPlanej:GetGtd("002"))
	PcoFindALX(cId	,"003",@oPlanej:GetGtd("003"))
	PcoFindALX(cId	,"004",@oPlanej:GetGtd("004"))

Else

	cId 	:= SubStr(cCargo,4,Len(cCargo)-3)
	
	DbSelectArea("AM2")
	DbSetOrder(3)
	DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)

	PcoFindALX(cId	,"001",@oPlanej:GetGtd("001"))
	PcoFindALX(nil	,"002",@oPlanej:GetGtd("002"),"AND ALX_AGREG ='"+AM2->AM2_AGREG+"' ")
	PcoFindALX(cId	,"003",@oPlanej:GetGtd("003"))
	PcoFindALX(cId	,"004",@oPlanej:GetGtd("004"))

EndIf

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
DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"001")
Do While !AM2->(Eof()) .and. ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"001"==AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL
	If Empty(AM2->AM2_IDPAI)
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+AM2->AM2_AGREG)
		If aScan(oPlanej:GetTre("001"):aCargo,{|x|x[1]=="SB1"+&(IndexKey())})==0
			aAdd(aLoad,{"SB1",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'",AM2->AM2_ID})
	//		oPlanej:LoadTree(@oPlanej:aObjetos[oPlanej:GetTre("001"),2],"SB1",AM2->AM2_AGREG,,3,.F.)
		EndIf
	Else
		If (nI := aScan(aLoad,{|x|x[5]==ALLTRIM(AM2->AM2_IDPAI)}) )>0
			aAdd(aLoad[nI,3],{"SB1X",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'"})
		EndIf
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
    cId := SubStr(cCargo,4,Len(cCargo)-3)
    
	If SubStr(cCargo,1,3)="SB1" .and. SubStr(cCargo,4,1)<>"X"

		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
		
		DbSelectArea("SB1")
		DbSetOrder(1)

		DbSeek(xFilial("SB1")+AM2->AM2_AGREG)
		aAdd(aCampos,{SB1->B1_COD,SB1->B1_DESC})

	EndIf

Next

If Len(aCampos)==0

	aCampos := {{'',''}}

EndIf

oPlanej:GetBrw("001"):SetArray(aCampos)
oPlanej:GetBrw("001"):bLine := {|| aCampos[oPlanej:GetBrw("001"):nAt] }
oPlanej:GetBrw("001"):Refresh()

Return

// Rotina com query para buscar entidades abaixo

// Localiza o agregador no ID
Function PcoGetAm2(cId,lRestArea)

Local cAgreg 	:= ''
Local aArea 	:= AM2->(GetArea())

Default lRestArea := .F.

DbSelectArea("AM2")
DbSetOrder(3)
If DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
	cAgreg := AM2->AM2_AGREG
EndIf

If lRestArea

	RestArea(aArea)

EndIf
	

Return cAgreg

Static Function AtuPrc()

Local aListPara := {}
Local aConfig 	:= {}
Local nVlUnit 	:= 0
Local cCargo 	:= oPlanej:GetTre("001"):GetCargo()
Local cId

If SubStr(cCargo,1,4)=='SB1X'
	cId := SubStr(cCargo,5,Len(cCargo)-4)
Else
	cId := SubStr(cCargo,4,Len(cCargo)-3)
EndIf

DbSelectArea("AM2")
DbSetOrder(3)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)

aAdd(aListPara,{3, STR0045 ,1		,{ STR0046 , STR0047 },50,"",.F.}) //"Tipo de Valor (Receita)"###"Custo Standard"###"Pre็o Venda"
aAdd(aListPara,{1, STR0048 ,SPACE(3),"@S3","Vazio() .or. ExistCpo('DA0')","DA0",".T.",6,.F.}) //"Tabela de Pre็o"

If ParamBox(aListPara, STR0049 ,@aConfig,,,,,,,"PCOA493_02",,.T.) //"Atualiza็ใo de Pre็o"
	nVlUnit := PcoPrcPlan(AM2->AM2_AGREG,'001',Alltrim(Str(aConfig[1])),aConfig[2])
EndIf

Return (nVlUnit)
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA493   บAutor  ณMicrosiga           บ Data ณ  07/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Desabilita os bot๕es do WIN2 quando selecionado o primeiro บฑฑ
ฑฑบ          ณ registro da Tree                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function P493DesBot()
Local nX		:= 0
Local nLinTree	:= 0
Local lExibBut	:= .F.
Local nPosBot	:= aScan(oPlanej:aObjetos, { |x| Alltrim(x[1]) == 'BUT' })
Local nPosTree	:= aScan(oPlanej:aObjetos, { |x| Alltrim(x[1]) == 'TRE001' })
Local nPosLayout:= aScan(oPlanej:aObjetos, {|aX| aX[5] == .T.})
Local cLayoutAt	:= oPlanej:aObjetos[nPosLayout,4]  

nLinTree := Val(oPlanej:aObjetos[nPosTree][2]:CURRENTNODEID)

lExibBut := nLinTree != 1 .and. cLayoutAt != "Planej"

For nX := 1 To Len(oPlanej:aObjetos[nPosBot][2])
	oPlanej:Aobjetos[nPosBot][2][nX]:LACTIVE := lExibBut
Next nX

Return Nil