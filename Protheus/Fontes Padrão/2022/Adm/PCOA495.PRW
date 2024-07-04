// Copyright (C) 2007, Microsiga

#include "protheus.ch"
#include "dbtree.ch"
#include "tbiconn.ch"
#include "msmgadd.CH"
#include "PCOA495.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA495   บAutor  ณAcacio Egas/ Joใo   บ Data ณ  03/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Planejamento Evolu็ใo Patrimonial                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static oMenuALV,oMenuAM2

Function PCOA495()

Local nWidth  	:= GetScreenRes()[1] - 40
Local nHeight 	:= GetScreenRes()[2] - 200
Local bRight	:= {|x,y,z| RightTree(@oPlanej:GetTre("001"),, x, y, z)}
Local nContItem
Local aColsALX,aHeaderALX

If ALV->ALV_STATUS == "2"  // ORCAMENTO EM REVISAO 
	HELP("  ",1,"PCOA100REV")
	Return
EndIf

Private aDataPlnj := {}
Private _aListData := PcoRetPer(ALV->ALV_INIPER,ALV->ALV_FIMPER,ALV->ALV_TPPERI,.F.,aDataPlnj)

DbSelectArea("ALV")
Private oPlanej := PCOArea():New(0,0, nWidth, nHeight,"Planejamento Or็amentแrio ")
Private aCampos := {{'',''}}

dDataInic := CTOD(Substr(aListDtEv[1],1,8))
dSaldInic := dDataInic - 1
cSaldInic := DTOC(dSaldInic) + " - " + DTOC(dSaldInic)

aAdd(_aListData,cSaldInic)
For nContItem := 1 to Len(aListDtEv)
	aAdd(_aListData,aListDtEv[nContItem])
Next	

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Layouts para Telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/
oPlanej:AddLayout("Planej")
oPlanej:AddLayout("Conta")
oPlanej:AddLayout("Saldos")
oPlanej:AddLayout("Movime")


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Janela Lateral e Objeto Treeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/
oPlanej:addSide(28,"Cubos")
oPlanej:AddWindow(96,"WIN1","Estrutura",2,.F.,.F.,oPlanej:oArea:oSideBar)
oPlanej:AddTre("001","WIN1",nil)


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Estrutura do Treeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

oPlanej:No_Tree("Planejamento"			,"ALV","ALLTRIM(ALV_CODIGO)+'-'+ALV_DESCRI"	,"RPMCPO"	,{|| oPlanej:ShowLayout("Planej")}					, bRight ,,									)
oPlanej:No_Tree("Conta Or็amentแria"	,"AK5","ALLTRIM(AK5_CODIGO)+'-'+AK5_DESCRI"	,"SIMULACA"	,{|| oPlanej:ShowLayout("Conta" )}					, bRight ,,{|x| PcoIncAM2(x,"007",,,.F.) }	)
oPlanej:No_Tree(""						,"XXX","Saldos"								,""			,{|| oPlanej:ShowLayout("Saldo" ),Find_Agreg()	}	, bRight ,,									)



aButs := { 	{ 1, "GPRIMG32", 	{|| PcoRatALX(oPlanej:Getobj('WIN2')) }, 		"Incluir Rateio"	, .F. }, ;
			{ 1, "RELATORIO", 	{|| PcoVisuRateioALX(oPlanej:Getobj('WIN2')) }, 	"Visualizar Rateio"	, .F. }, ;
			{ 1, "EXCLUIR", 	{|| PcoExclRatALX(oPlanej:Getobj('WIN2')) }, 	"Excluir Rateio"	, .F. }   }


// Adiciona Janela 2 com Bot๕es - servira para conter o cadastro centro de custo /ou Funcao /ou GetDados


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona Janelas 2 e 3 com Bot๕es.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

oPlanej:AddWindow(48,"WIN2","Distribui็ใo de Entidades",3,.T.,,,aButs)

oPlanej:AddWindow(48,"WIN3","Distribui็ใo de Valores"	,2,.T.,"Saldos")


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Objetos do Layout de Planejamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

// Cria variaveis de memoria para a MSMGet
RegToMemory("ALV", .F.,,, FunName())
oPlanej:AddMsm("001","Planejamento","ALV",ALV->(Recno()),"WIN2","Planej",/*{|x| Cancelamento }*/,/*{|x| Edicao }*/)

oPlanej:AddBrw("001","Conta Or็amentแria",{"Codigo","Descri็ใo"},"WIN3","Planej",{|| AtuBrow()})

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Objetos do Layout de Conta   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Objetos do Layout de Saldos   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGetDados de Saldos Iniciais   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	aCpos := {"ALX_TIPO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
	If ExistBlock("PCOA4951")
		If VALTYPE(aCposUsr := ExecBlock("PCOA4951"))="A"
			aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
		EndIf
	EndIf
	aHeaderALX := GetAHeader("ALX",aCpos,)
	aColsALX 	:= nil
	oPlanej:AddGtD("001","Saldos Iniciais"		,"WIN2","Saldos",aHeaderALX,aColsALX,{|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("001"))}	,{|x| Find_Agreg()},{|x| PcoPnjAtu(@oPlanej:GetGtd("001"),"007",.T.) })
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGetDados de Fluxo de Caixa   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	aCpos := {"ALX_TIPO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
	If ExistBlock("PCOA4952")
		If VALTYPE(aCposUsr := ExecBlock("PCOA4952"))="A"
			aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
		EndIf
	EndIf
	aHeaderALX := GetAHeader("ALX",aCpos,)
	oPlanej:AddGtD("002","Fluxo de Caixa"		,"WIN2","Saldos",aHeaderALX,aColsALX,{|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("002"))}	,{|x| Find_Agreg()},{|x| PcoPnjAtu(@oPlanej:GetGtd("002"),"008",.T.) })
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMsmGet dos valores e quantidades  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	_aGetValues := {}
	_aGetQuants := {}
	For nContItem := 1 to Len(_aListData)	
	
		_SetOwnerPrvt("VLR" + StrZero(nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		_SetOwnerPrvt("QTD" + StrZero(nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		SX3->(DbSetOrder(2))
		SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
		ADD FIELD _aGetValues TITULO _aListData[nContItem] CAMPO "VLR" + StrZero(nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
		ADD FIELD _aGetQuants TITULO _aListData[nContItem] CAMPO "QTD" + StrZero(nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
	
	Next	
	oPlanej:AddMsm("003","Quantidades"	     	,"ALY",ALY->(Recno())	,"WIN3"	,"Saldos"		,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.) },_aGetQuants)
	oPlanej:AddMsm("002","Valores"           	,"ALY",ALY->(Recno())	,"WIN3"	,"Saldos"		,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.) },_aGetValues)
	

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Objetos do Layout de Movimentos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGetDados de Contra Partida ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	aCpos := {"ALX_TIPO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
	If ExistBlock("PCOA4951")
		If VALTYPE(aCposUsr := ExecBlock("PCOA4951"))="A"
			aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
		EndIf
	EndIf
	aHeaderALX := GetAHeader("ALX",aCpos,)
	aColsALX 	:= nil
	oPlanej:AddGtD("003","Contra Partida"		,"WIN2","Movime",aHeaderALX,aColsALX,{|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("001"))}	,{|x| Find_Agreg()},{|x| PcoPnjAtu(@oPlanej:GetGtd("001"),"007",.T.) })
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGetDados de Fluxo de Caixa   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	aCpos := {"ALX_TIPO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
	If ExistBlock("PCOA4952")
		If VALTYPE(aCposUsr := ExecBlock("PCOA4952"))="A"
			aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
		EndIf
	EndIf
	aHeaderALX := GetAHeader("ALX",aCpos,)
	oPlanej:AddGtD("004","Fluxo de Caixa"		,"WIN2","Movime",aHeaderALX,aColsALX,{|| PcoLoadALY(aDataPlnj,@oPlanej:GetGtd("002"))}	,{|x| Find_Agreg()},{|x| PcoPnjAtu(@oPlanej:GetGtd("002"),"008",.T.) })
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMsmGet dos valores e quantidades  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	_aGetValues := {}
	_aGetQuants := {}
	For nContItem := 1 to Len(_aListData)	
	
		_SetOwnerPrvt("VLR" + StrZero(nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		_SetOwnerPrvt("QTD" + StrZero(nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))		
		SX3->(DbSetOrder(2))
		SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
		ADD FIELD _aGetValues TITULO _aListData[nContItem] CAMPO "VLR" + StrZero(nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
		ADD FIELD _aGetQuants TITULO _aListData[nContItem] CAMPO "QTD" + StrZero(nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
	
	Next	
	oPlanej:AddMsm("004","Quantidades"	     	,"ALY",ALY->(Recno())	,"WIN3"	,"Movime"		,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.) },_aGetQuants)
	oPlanej:AddMsm("005","Valores"           	,"ALY",ALY->(Recno())	,"WIN3"	,"Movime"		,{|| PcoLoadALY(aDataPlnj,,)},{|x| PcoLoadALY(aDataPlnj,,,.T.) },_aGetValues)


oPlanej:ShowLayout("Planej")
// Inicializa o Tree
AtuAgreg(.t.)
oPlanej:Activate()

Processa( {|| PcoPnjSld() } , "Atualizando Saldos" )

Return




Static Function AtuBrow()

Local nX
Local cId,cCargo

	aCampos:= {}
	For Nx:=1 To Len(oPlanej:GetTre("001"):aCargo)

		DbSelectArea("AK5")
		DbSetOrder(1)
		cCargo := oPlanej:GetTre("001"):aCargo[Nx,1]
		If SubStr(cCargo,1,3)="AK5"
			
			cId := SubStr(cCargo,4,Len(cCargo)-3)
			DbSelectArea("AM2")
			DbSetOrder(3)
			DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + ALV->ALV_VERSAO + "006" + cId)			
			
			DbSeek(xFilial("AK5")+AM2->AM2_AGREG)
			aAdd(aCampos,{AK5->AK5_CODIGO,AK5->AK5_DESCRI})

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
Local cAlias := SubStr(cCargo,1,3)
Local cId

Do Case	
	Case cAlias == "ALV"
		
		If oMenuALV<>nil
		
			oMenuALV:Free()
		
		EndIf
		
		Menu oMenuALV Popup
		MenuItem "Adicionar Conta Or็amentแria " Block {|| InsertTipo(@oTree)}
		MenuItem "___________________" Disabled
		MenuItem "Excluir Saldos Iniciais" Block {|| PcoRunPlan(nil,5,"007") }		
		MenuItem "___________________" Disabled		
		EndMenu      
		
		oMenu := oMenuALV
		
	Case cAlias == "AK5"
	
		cId := SubStr(cCargo,4,Len(cCargo)-3)
	
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + ALV->ALV_VERSAO + "006" + cId)
        
		If oMenuAM2<>nil
		
			oMenuAM2:Free()
			
		EndIf
		
		Menu oMenuAM2 Popup
		MenuItem "Excluir Conta Or็amentแria "	Block {|| DelTipo(@oTree) }
		MenuItem "___________________" Disabled
		MenuItem "Gerar Saldos Iniciais" 	Block {|| PcoRunPlan(cId,"007"	,3,@oPlanej:GetGtd("001")) }
		MenuItem "Excluir Saldos Iniciais"	Block {|| PcoRunPlan(cId, "007" ,5,@oPlanej:GetGtd("001")) }
		MenuItem "___________________" Disabled
		MenuItem "Gerar Varia็ใo" 	        Block {|| PcoRunPlan(cId,"008",3,@oPlanej:GetGtd("002")) }
		MenuItem "_____________ ______" Disabled
		//MenuItem "Gerar Contra Partidas" 	Block {|| PcoRunPlan(cId,"507",3,@oPlanej:GetGtd("003"))}
		//MenuItem "Excluir Contra Partidas" 	Block {|| PcoRunPlan(cId,"507",5,@oPlanej:GetGtd("003"))}
		EndMenu
		
		oMenu := oMenuAM2
		
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
ฑฑบDesc.     ณ Distribui Conta Or็amentแria no xTree.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function InsertTipo(oTree)
Local aConfig
Local aLoad		:= {}
If ParamBox({ 	{1,"Conta de ",SPACE(Len(AK5->AK5_CODIGO)),PesqPict("AK5","AK5_CODIGO"),"ExistCpo('AK5')","AK5",".T.",60,.F.},; // "Tipos de Despesa"
	  			{1,"Conta ate",SPACE(Len(AK5->AK5_CODIGO)),PesqPict("AK5","AK5_CODIGO"),"ExistCpo('AK5')","AK5",".T.",60,.F.}},"Distribui็ใo do Planejamento",@aConfig,,,,,,,"PCOA495_01",,.T.)

			aAdd(aLoad,{"AK5X",' Saldos '		,{},"''"})
			aAdd(aLoad,{"AK5X",' Planejamento '	,{},"''"})

	oPlanej:LoadTree(@oTree,"AK5",aConfig[1],aConfig[2],,,aLoad,/*'AK5_TIPO =="2"'*/, "AM2->AM2_ID" )
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

DbSelectArea("ALX")
DbSetOrder(3)

If DbSeek(xFilial("ALX")+ cId + "007")

	lContinua := .F.

EndIf
	
If lContinua

	DbSelectArea("AM2")
	DbSetOrder(3)
	If DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + ALV->ALV_VERSAO + "007" + cId)

		RecLock("AM2",.F.)
		DbDelete()
		MsUnlock()
		oTree:DelItem()
		AtuAgreg()
	EndIf
	
Else

	Aviso("Aten็ใo","Existem lan็amentos para este agregador. Favor excluir os lan็amentos.",{"OK"})
	
EndIf

Return


// Atualiza aCols
Static Function Find_Agreg()
                                
Local cCargo	:= oPlanej:GetTre("001"):GetCargo()
Local cId 		:= SubStr(cCargo,4,Len(cCargo)-3)

DbSelectArea("AM2")
DbSetOrder(3)
DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+ALV->ALV_VERSAO+"006"+cId)

PcoFindALX(cId,"007",@oPlanej:GetGtd("001"))
PcoFindALX(cId,"008",@oPlanej:GetGtd("002"))
//PcoFindALX(cId,"507",@oPlanej:GetGtd("003"))

Return

Static Function AtuAgreg(lIni)
// Monta Tree
Local nX
Local aLoad := {}

Default lIni := .F.
//Local nBrow := oPlanej:GetBrw("001")
DbSelectArea("AM2")
DbSetorder(3)
DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+ALV->ALV_VERSAO+"007")
Do While !AM2->(Eof()) .and. ALV->ALV_FILIAL+ALV->ALV_CODIGO+ALV->ALV_VERSAO+"007"==AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL
	DbSelectArea("AK5")
	DbSetOrder(1)
	DbSeek(xFilial("AK5")+AM2->AM2_AGREG)
	aAdd(aLoad,{"AK5",AM2->AM2_AGREG,{},"'"+AM2->AM2_ID+"'",AM2->AM2_ID})
	AM2->(DbSkip())
EndDo

If lIni

	oPlanej:LoadTree(@oPlanej:GetTre("001"),"ALV",ALV->ALV_CODIGO,,1,.F.,aLoad)

EndIf

aCampos:= {}
For Nx:=1 To Len(oPlanej:GetTre("001"):aCargo)

	cCargo := oPlanej:GetTre("001"):aCargo[Nx,1]

	If SubStr(cCargo,1,3)="AK5"

	    cId := SubStr(cCargo,4,Len(cCargo)-3)
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+ALV->ALV_VERSAO+"007"+cId)

		DbSelectArea("AK5")
		DbSetOrder(1)
		DbSeek(xFilial("AK5")+ AM2->AM2_AGREG )
		aAdd(aCampos,{AK5->AK5_CODIGO,AK5->AK5_DESCRI})

	EndIf

Next
If Len(aCampos)==0

	aCampos := {{'',''}}

EndIf
oPlanej:GetBrw("001"):SetArray(aCampos)
oPlanej:GetBrw("001"):bLine := {|| aCampos[oPlanej:GetBrw("001"):nAt] }
oPlanej:GetBrw("001"):Refresh()
Return


Function PcoPnjSld()



If Aviso( STR0003 , STR0007 ,{ STR0008 , STR0009 } ) == 1 //"Aten็ใo"###"Deseja atualizar o Saldo de Todos os planejamentos ?"###"Sim"###"Nใo"
	
	PCOINIProc( "000358" )
	
	DbSelectArea("ALY")
	ProcRegua( RecCount() )
	DbGoTop()
	
	Do While !ALY->(Eof())
	
		DbSelectArea("ALX")
		DbSetOrder(2)
		If DbSeek(xFilial("ALX")+ALY->ALY_PLANEJ+ALY->ALY_VERSAO+ALY->ALY_SEQ) // Posiciona Tabela ALX    
	
			PCODETProc( "000358" , "01" , "PCOXPNJ" )
	
		EndIf
	    IncProc()
		ALY->(DbSkip())
	EndDo
	
	PcoFinProc( "000358" , /*lForceVis*/ , /*lProc*/ , ALV->ALV_INIPER , ALV->ALV_FIMPER )

EndIf

Return


Function PcoFinProc( cProcesso , lForceVis , lProc , dDataIni , dDateFim )

Local aCposVisual	:= {} 
Local aArea			:= GetArea()
Local nX,  aLoteProc:= {}
Local lRet			:= .T.
Local nPosLote             
Local lNotBlind		:= !IsBlind()
Local nUltProc 		:= Len(aPcoProc)

//******************************************************************************
//   Para a Utiliza็ใo desta rotina ้ necessario a cria็ใo de um parametro     *
// com MV_PCO + os 3 ultimos digitos do codigo do processo. Este parametro     *
// deve conter o Tipo de Saldo especifico para o Processo. o Tipo de Saldo     *
// informado nใo pode ser utilizado em outro lan็amento.                       *
//******************************************************************************

Local cSldProc		:= ALLTRIM(SuperGetMV("MV_PCO" + SubStr( cProcesso , 4 , 3 ) ,.F.,""))

DEFAULT lForceVis	:= .F.                    
DEFAULT lProc       := .F.

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	If !Empty(cSldProc)

		If nUltProc > 0
		
			AK8->(dbSetOrder(1))
			AK8->(MsSeek(xFilial()+cProcesso))
			FreeUsedCodes(.T.)
			If !Empty(aPcoProc[nUltProc, PCO_REGLANC])
		
				cUpd := "UPDATE " + RetSqlName("AKD") + " SET AKD_STATUS='1' WHERE AKD_PROCES='" + cProcesso + "' AND D_E_L_E_T_=' ' AND AKD_STATUS='2'"
				TcSqlExec( cUpd )
				TcRefresh(RetSqlName("AKD"))
		
				For nX := 1 TO Len(aPcoProc[nUltProc, PCO_REGLANC]) 
					AKD->(dbGoto(aPcoProc[nUltProc, PCO_REGLANC, nX]))
					If AKD->AKD_STATUS != "3"
						If (nPosLote	:=	ASCAN(aLoteProc, {|x| x[1] == AKD->AKD_LOTE}))==0
							aAdd(aLoteProc, {AKD->AKD_LOTE,{aPcoProc[nUltProc, PCO_REGLANC, nX]}})
						Else
							AAdd(aLoteProc[nPosLote][2],aPcoProc[nUltProc, PCO_REGLANC, nX])
						EndIf		
					EndIf
				Next
				DbSelectArea('AKD')
				While ( GetSX8Len() > aPcoProc[nUltProc, PCO_SAVESX8] )
					ConFirmSX8()
				EndDo
			
				aRecLanc := aPcoProc[nUltProc, PCO_REGLANC 	]
				aRecBlq  := aPcoProc[nUltProc, PCO_REGBLOQ 	]
				nSaveSX8 := aPcoProc[nUltProc, PCO_SAVESX8  ]
				PcoFreeBlq( cProcesso )
				aSize(aPcoProc, nUltProc-1)
			
				For nX := 1 To Len(aLoteProc)
				
					dbSelectArea("SX3")
					dbSetOrder(1)
					dbSeek("AKD")
					While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
				
						If X3USO(x3_usado) .AND. cNivel >= x3_nivel
				
							nPos := AT(Alltrim(SX3->X3_CAMPO)+";",AK8->AK8_PROPLC)
							If nPos > 0
				
								If Substr(AK8->AK8_PROPLC,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
				
									aAdd(aCposVisual,Alltrim(SX3->X3_CAMPO))
				
								EndIf
				
							EndIf
				
						EndIf
						dbSkip()
				
					End		        
					
					If lForceVis .Or. AK8->AK8_VISUAL == "1"

						lRet := PCOA050(4,,aCposVisual,aLoteProc[nX][2])

					Else
					
						//lRet := PCOA050(4,.T.,aCposVisual,aLoteProc[nX][2]) // A Rotina PCOA050 nใo valida automatica.
						lRet := .T.
					
					EndIf			
			
					If !lRet
						
						cUpd := "UPDATE " + RetSqlName("AKD") + " SET AKD_STATUS='2' WHERE AKD_PROCES='" + cProcesso + "' AND D_E_L_E_T_=' ' AND AKD_STATUS='1' AND AKD_LOTE='" + aLoteProc[nX][1] + "'"
						TcSqlExec( cUpd )
						TcRefresh(RetSqlName("AKD"))
					
					EndIf
					
				Next
						
				aParam := {" AND AKD_PROCES='" + cProcesso + "' ", " AND AKS_TPSALD='" + cSldProc + "' ", " AND AKT_TPSALD='" + cSldProc + "' " }
				
				aAuto := { "  " , "ZZ" , dDataIni , dDateFim }
				
				Pcoa300( aParam , aAuto )	
						
			EndIf
		
		EndIf

	Else
	
		PcoFinLan( cProcesso , lForceVis , lProc )
	
	EndIf    

EndIf

RestArea(aArea)

Return


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoSldInic       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de Saldos Iniciais de C.O. do Planejamento.       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PnjSldInic(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0006 //"Distribui็ใo do Planejamento"
Local aValores
Local cRegrDist
Local cTabePrec,cTipoValo
Local nPrecAgre,nSaldoIni
Local cTmpArq

Default cSeek := ''

If aAuto == NIL
	
	aAdd(aParam,{ 1, STR0001 , SPACE(6)	,"@S6"				,"ExistCpo('ALS')"	, "ALS"	, ".T."	,6	,.F.}) //"Regra Evolu็ใo Patrim."
	aAdd(aParam,{ 1, STR0002 ,0			,"@E 999,999,999.99",""					,""		,".T."	,50	,.F.}) //"Saldo inicial"
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_007",,.T.)
	
ElseIf Len(aAuto)==2
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrDist 	:= aConfig[1]
	nSaldoIni	:= aConfig[2]
	
	//************************************************************
	//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
	//*  para grava็ใo nใo atualiza os dados.                    *
	//************************************************************
	DbSelectArea("AM2")
	DbSetOrder(3)
	DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"007"+cId)
	
	//*****************************************************************
	//    Rotina para defini็ใo do tipo de valor e tabela de pre็o    *
	//*****************************************************************
	cTipoValo := '2'
	
EndIf

If lContinua
	
	//******************************************************
	//      Valida็ใo da rotina de saldo inicial           *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(3)
	If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + cId + "007" + cRegrDist ))
		
		Aviso( STR0003 , STR0004 ,{ STR0005 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf
/*
If lContinua
	
	lContinua := !Empty(cTipoCtbl := PCOBuscTp("007",AM2->AM2_AGREG))
	
Endif
*/
If lContinua
	
	//******************************************
	//* Ajusta aValores com Data de e Data ate *
	//******************************************
	aValores 	:= {}
	aEval(_aListData,{|x,y| aAdd(aValores,{nSaldoIni , aDataPlnj[y,1] , aDataPlnj[y,2] }) })
	
	//*********************************************************************
	//    Gera combina็ใo das entidades conforme regra de distribui็ใo    *
	//*********************************************************************
	PNJGerComb(cRegrDist,/*cEntiExcl*/,aValores,nPrecAgre,.F./*lQtd*/,/*cCodigo*/,"1"/*cTipoCtbl*/,/*cRegrFilt*/,@cTmpArq)	
		
	//****************************
	//   Rotina para Salvar ALX  *
	//****************************
	PcoGrvPLan(cId,oGtDados,"TMPDIS","007",cTipoValo=='1')

	If cTmpArq != NIL
		MsErase(cTmpArq)
	EndIf
	
EndIf

Return


Static Function PcoVarPatr(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0006 //"Distribui็ใo do Planejamento"
Local aMov,aEntid
Local cSeek2
Local _nX

Default cSeek 	:= ''

If aAuto == NIL
	
	For _nX := 2 to Len(_aListData)  // Desconsidera o saldo inicial
		
		aAdd(aParam,{1,Substr(_aListData[_nX],1,10),0,"@E 999.99 %","","",".T.",50,.F.})
		
	Next
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_008",,.T.)
	
ElseIf Len(aAuto)==Len(_aListData)-1
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	For _nX := 1 To Len(aConfig)
		
		If aConfig[_nX]<>0
			
			cSeek2 := cSeek + If( ALLTRIM(cSeek)<>'' , " AND " , "" ) + "ALY_DTINI ='" + aDataPlnj[_nX+1,1] + "' AND ALY_DTFIM='" + aDataPlnj[_nX+1,2] + "'"
			
			//***********************************************************
			//    Gera Relacionamento para Varia็ใo patrimonial.        *
			//***********************************************************
			
			aEntid 	:= {'','','','','',''}
			aMov	:= { '' , 0 , cId }
			lContinua := PNJGerRelac( cId , aEntid , aMov ,, aConfig[_nX] , '' ,,, cSeek2,{'007'})
			
			If lContinua
				
				//****************************
				//   Rotina para Salvar ALX  *
				//****************************
				PcoGrvPLan( cId , oGtDados , "TMPRGR" , "008" , .F. ,, (_nX==1) )
				
			EndIf
			
		EndIf
		
	Next
	
EndIf

Return


Function PnjVarPatr(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0006 //"Distribui็ใo do Planejamento"
Local aMov,aEntid
Local cSeek2
Local _nX

Default cSeek 	:= ''

If aAuto == NIL
	
	For _nX := 2 to Len(_aListData)  // Desconsidera o saldo inicial
		
		aAdd(aParam,{1,Substr(_aListData[_nX],1,10),0,"@E 999.99 %","","",".T.",50,.F.})
		
	Next
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_008",,.T.)
	
ElseIf Len(aAuto)==Len(_aListData)-1
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	For _nX := 1 To Len(aConfig)
		
		If aConfig[_nX]<>0
			
			cSeek2 := cSeek + If( ALLTRIM(cSeek)<>'' , " AND " , "" ) + "ALY_DTINI ='" + aDataPlnj[_nX+1,1] + "' AND ALY_DTFIM='" + aDataPlnj[_nX+1,2] + "'"
			
			//***********************************************************
			//    Gera Relacionamento para Varia็ใo patrimonial.        *
			//***********************************************************
			
			aEntid 	:= {'','','','','',''}
			aMov	:= { '' , 0 , cId }
			lContinua := PNJGerRelac( cId , aEntid , aMov ,, aConfig[_nX] , '' ,,, cSeek2,{'007'})
			
			If lContinua
				
				//****************************
				//   Rotina para Salvar ALX  *
				//****************************
				PcoGrvPLan( cId , oGtDados , "TMPRGR" , "008" , .F. ,, (_nX==1) )
				
			EndIf
			
		EndIf
		
	Next
	
EndIf

Return

