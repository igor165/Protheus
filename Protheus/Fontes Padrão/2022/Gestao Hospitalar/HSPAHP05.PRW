#INCLUDE "hspahp05.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HSPAHP05 ณ Autor ณ                 		ณ data ณ 18/10/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Parametriza็๕es Leitos			                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHP05()

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {}
Local aButtons := {}
Local nHRes	:=	oMainWnd:nClientWidth
Local aComboBx1	 := {STR0001,STR0002,STR0003} //"1-Setor"###"2-Quarto"###"3-Leito"

Private cComboRes :=""
Private aTela := {}, aGets := {} 
Private oTraQuar, lTraQuar := .F.
Private oTraLei, lTraLei := .F.
Private nGDOpc		:= GD_UPDATE + GD_DELETE + GD_INSERT
Private nOpcAut
Private nReg 		:= 0
Private	nGAVCodQua 	:= 0
Private	nGAVCodLoc	:= 0
Private	nGAVCodLei 	:= 0
Private	nGAVIdOK 	:= 0

Private Inclui 		:= .F.
Private lAtuDado	:= .F.
Private oComboBox   := nil
Private oGetSeto  	:= nil
Private oGetGAV  	:= nil

Private oGT5	 	:= nil
Private aHeadSeto 	:= {}, aColsSeto := {}
Private aHeadGAV 	:= {}, aColsGAV := {}

Private aCpoGCS  	:= {"GCS_CODLOC","GCS_NOMLOC","GCS_TIPLOC"}

Private aJoinGCS 	:= {}

Private 	aCor := {{"GAV_PARAME == '0' .Or. GAV_PARAME == ' ' " , "BR_CINZA"   },;
{"GAV_PARAME == '1'"                          , "BR_VERDE"  }}


Private cMarDef  := ""
Private cCpomark  := ""
Private cCadastro  	:= OemToAnsi(STR0004) // //"Parametriza็ใo Reserva "
Private nGCSCodLoc := 0
Private cCodLoc	    := ""
Private cDesLoc	    := ""
Private aCposIni    := {"GAV_CODLOC","GAV_QUARTO","GAV_LEITO"}
 
Private cOrderGav :='GAV_CODLOC,GAV_QUARTO,GAV_LEITO'


aSize := MsAdvSize(.T.)
aObjs := {{100, 050, .T., .T.,.T.}, ;
		{100, 050, .T., .T., .T.}}
		
aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObj := MsObjSize(aInfo, aObjs, .T.) 

aObjs := {{100, 050, .T., .T.},;
		{100, 050, .T., .T.}}

aInfo := {aPObj[1, 2], aPObj[1, 1], aPObj[1, 4], aPObj[1, 3], 0, 0}
aPEnc := MsObjSize(aInfo, aObjs, .T.)

aObjs := {{100, 50, .T., .T.}, ;
		{100, 50, .T., .T.}}

aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
aPAux := MsObjSize(aInfo, aObjs, .T.,.T.)

aObjs := {{13, 100, .T., .T.}, ;
			{87, 100, .T., .T.}}

aInfo := {aPEnc[1, 2], aPEnc[1, 1], aPEnc[1, 4], aPEnc[1, 3], 0, 0}
aPPac := MsObjSize(aInfo, aObjs, .T.,.T.)


DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cCadastro + cDesLoc) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL

oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4]) //Itens Quarto/Setor
oPanel1:Align := CONTROL_ALIGN_BOTTOM

oPanel2 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oDlgAut,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtros
oPanel2:Align := CONTROL_ALIGN_LEFT

oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtro Setor
oPanel6:Align := CONTROL_ALIGN_TOP

oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // Setor
oPanel7:Align := CONTROL_ALIGN_ALLCLIENT

oPanel3 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4])// Parametrizacao
oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS STR0005 //"Parametriza็ใo"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

/*Setor*/
HS_BDados("GCS", @aHeadSeto, @aColsSeto,, 1,, " GCS.GCS_TIPLOC  IN ('3','4','8','B') AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "'",,,"/",,,,,,.T.,,,,,, aCpoGCS, aJoinGCS)
nGCSCodLoc := aScan(aHeadSeto, {|aVet| aVet[2] == "GCS_CODLOC"})
nGCSDesLoc := aScan(aHeadSeto, {|aVet| aVet[2] == "GCS_NOMLOC"})
oGetSeto:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadSeto, aColsSeto)
oGetSeto:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetSeto:bChange       := {|| FS_TlaSet()} 

//Fitros dos Dados
HS_GDPesqu( , , oGetSeto, oPanel6, 001,.T.)

DbSelectArea("GT5")
RegToMemory("GT5",.F.)


/*Parametrizacao*/

oGT5:= MsMGet():New("GT5", nReg, 4,,,,, {aPEnc[2, 1], aPEnc[2, 2], aPEnc[2, 3], Iif (nHRes <= 969,aPEnc[2, 4]-80,aPEnc[2, 4]-300)},,,,,, oPanel3)
oGT5:oBox:align:= CONTROL_ALIGN_ALLCLIENT


  HS_BDados("GAV"   , @aHeadGAV, @aColsGAV ,        ,  2  ,       , "GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_CODLOC = '"+oGetSeto:aCols[oGetSeto:nAt,nGCSCodLoc]+"'",        ,"GAV_PARAME"      , "/"    ,         , /*cCpoNao*/,        ,"GAV_OK    ",/*cMarDef*/,.T.     ,aCor ,        ,  .T.    ,           ,         ,aCposIni ,      ,          ,cOrderGav ,       ,         ,           )
oGetGAV := MsNewGetDados():New(aPObj[2, 1]+  iif(!OAPP:LMDI,260,270) , aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oFolder:aDialogs[1], aHeadGAV, aColsGAV)
oGetGAV:oBrowse:Align 	:= CONTROL_ALIGN_BOTTOM
oGetGAV:oBrowse:BlDblClick := {|| FS_DblClk(oGetGAV:oBrowse:nAt),FS_AtTela(oGetGAV)}
nGAVCodLoc := aScan(aHeadGAV, {|aVet| aVet[2] == "GAV_CODLOC"})
nGAVCodQua := aScan(aHeadGAV, {|aVet| aVet[2] == "GAV_QUARTO"}) //quarto
nGAVCodLei := aScan(aHeadGAV, {|aVet| aVet[2] == "GAV_LEITO "})//Leito
nGAVIdOK := aScan(aHeadGAV, {|aVet| aVet[2] == "GAV_OK    "})

@ aPObj[2,1]+ iif(!OAPP:LMDI,18,28) , 005 Say STR0006 Font TFont():New("Courier New",15,0) SIZE 50,10 Pixel Of oPanel1  COLOR CLR_BLUE //"Tipo de Parametriza็ใo"
@ aPObj[2,1]+ iif(!OAPP:LMDI,36,46) ,260 ComboBox oComboBox VAR  cComboRes Items aComboBx1 Size 50,10 PIXEL OF oDlgAut

aAdd(aButtons,	{"S4WB001N", {|| IIF(Obrigatorio(aGets, aTela),FS_GRVRES(.F.,Val(cComboRes)),oGetSeto:oBrowse:SetFocus())}, STR0007,STR0008})  // //"Confirma Altera็๕es"###"Confirma"
aAdd(aButtons,	{STR0009, {|| FS_EXCRES(.F.,Val(cComboRes))}, STR0010,STR0011})  // //"EXCLUIR"###"Exclui Param."###"Exclui"


ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,IIF(Obrigatorio(aGets, aTela),oDlgAut:End(),nOpcAut := 0)}, ;
{|| oDlgAut:End(), nOpcAut := 0},,aButtons)

If nOpcAut == 1
	FS_GRVRES(.T.,Val(cComboRes))
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVRES บAutor  ณ			     บ Data ณ 18/10/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravar os dados das parametriza็๕es De Reserva  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GRVRES(lOk,nTpParam)
Local lAchou 	:= .F.
Local nGD		:= 0
Local lRet		:=.T. 
Local cQuat:=""
Local cSeto:=""
Local cleit:=""                                         
Default lOk 	:= .F. 

If Empty(oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]) .or. oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBNO"
	//HS_MSGINF("Selecione o Setor!","Aten็ใo","Valida็ใo Parametros do Reserva ")
	Return(Nil)
EndIf


cSeto  := oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]
cQuat  := oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]
cleit   :=oGetGAV:aCols[oGetGAV:nAt,nGAVCodLei]

If	nTpParam==2
	cleit :=space(TamSx3("GAV_LEITO")[1])
Elseif nTpParam==1
	cQuat  := space(TamSx3("GAV_QUARTO")[1])
	cleit :=space(TamSx3("GAV_LEITO")[1])
	
Endif

If  oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBTIK"
	DbSelectArea("GT5")
	DbSetOrder(1)
	lAchou := GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]+cQuat+cleit))
	RecLock("GT5", !lAchou)
	GT5->GT5_FILIAL  := xFilial("GT5")
	HS_GrvCpo("GT5")
	GT5->GT5_CODLOC  := cSeto
   	GT5->GT5_QUARTO  := cQuat
   	GT5->GT5_LEITO   := cleit
	If Empty(GT5->GT5_PSETOR)
		GT5->GT5_PSETOR := "9" // Nใo tem prioridade
	Endif
	
	If Empty(GT5->GT5_PIDADE)
		GT5->GT5_PIDADE := "9" // Nใo tem prioridade
	EndIf
	
	
	If Empty(GT5->GT5_PREINT)
		GT5->GT5_PREINT:= "9"
	Endif
	
	If Empty(GT5->GT5_PDATA)
		GT5->GT5_PDATA:= "9"
	Endif
	
	If Empty(GT5->GT5_PLEIES)
		GT5->GT5_PLEIES:= "9"
	Endif
	
	If Empty(GT5->GT5_PTIPO)
		GT5->GT5_PTIPO:= "9"
	Endif
	
	MsUnLock()

If nTpParam==3
	DbSelectArea("GAV")
	DbSetOrder(1)
	lAchou := GAV->(DbSeek(xFilial("GAV") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]+oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]+oGetGAV:aCols[oGetGAV:nAt,nGAVCodLei]))
	RecLock("GAV", !lAchou)
	GAV->GAV_PARAME:="1"
	MsUnLock()

ElseIf nTpParam==2
	
	For nGD := 1 to Len(oGetGAV:aCols)
		If  oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]==oGetGAV:aCols[nGD,nGAVCodQua]
		DbSelectArea("GAV")
		DbSetOrder(1)
		lAchou := GAV->(DbSeek(xFilial("GAV") + oGetGAV:aCols[nGD,nGAVCodLoc]+oGetGAV:aCols[nGD,nGAVCodQua]+oGetGAV:aCols[nGD,nGAVCodLei]))
		RecLock("GAV", !lAchou)
		GAV->GAV_PARAME:="1"
		MsUnLock()	
		Endif
	Next nGD
	
ElseIf nTpParam==1
	
	For nGD := 1 to Len(oGetGAV:aCols)
		DbSelectArea("GAV")
		DbSetOrder(1)
		lAchou := GAV->(DbSeek(xFilial("GAV") + oGetGAV:aCols[nGD,nGAVCodLoc]+oGetGAV:aCols[nGD,nGAVCodQua]+oGetGAV:aCols[nGD,nGAVCodLei]))
		RecLock("GAV", !lAchou)
		GAV->GAV_PARAME:="1"		
			MsUnLock()
		Next nGD
		
	Endif
	
ElseIf	HS_MSGINF(STR0012,STR0013,STR0014) //"Selecione um modo (por Setor,leito,Quarto) para Atualiza็ใo"###"Aten็ใo"###"Valida็ใo Parametros da Reserva"
		
		lRet 	:= .F.
		Return()
Endif 

If !lOk .and. lRet
	HS_MSGINF(STR0015,STR0013,STR0014) //"Atualiza็ใo salva com sucesso!"###"Aten็ใo"###"Valida็ใo Parametros da Reserva"
	oGetSeto:oBrowse:SetFocus()	
EndIf

If nOpcAut <> 1
	FS_TlaSet()
	oGetSeto:oBrowse:SetFocus()
Endif

Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_TlaSet บ Autor ณ                    บ Data ณ 18/10/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da GT5 ou GAV        บฑฑ
ฑฑบ          ณ          de acordo com O Dado Escolhido                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParame    ณ															  บฑฑ
ฑฑบ			 ณ															  บฑฑ
ฑฑบ			 ณ										   					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  							              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_TlaSet()

FS_LMPVAR()

oDlgAut:cTitle := cCadastro + Alltrim(oGetSeto:aCols[oGetSeto:nAt,nGCSDesLoc]) + " - " + oGetSeto:aCols[oGetSeto:nAt,nGCSCodLoc]
oGT5:Refresh()

aHeadGAV := {}
aColsGAV := {}
  
HS_BDados("GAV"   , @aHeadGAV, @aColsGAV ,        ,  2  ,        , "GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_CODLOC = '"+oGetSeto:aCols[oGetSeto:nAt,nGCSCodLoc]+"'",        ,"GAV_PARAME"      , "/"    ,         , /*cCpoNao*/,        ,"GAV_OK    ",/*cMarDef*/,.T.     ,aCor ,        ,         ,           ,         ,aCposIni ,         ,          ,         ,       ,         ,           )
oGetGAV:SetArray(aColsGAV)
oGetGAV:oBrowse:Refresh()

Inclui 	:= .T.

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_PREVARบ Autor ณ                    บ Data ณ  18/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Preenche variaveis da memoria no momento da troca de registบฑฑ
ฑฑบ          ณ no grid de de Leitos                                   บฑฑ
ฑฑบ          ณ Obs. Na troca de registro no grid sem a limpeza e o        บฑฑ
ฑฑบ          ณ preenchimento das variaveis manualmente o sistema          บฑฑ
ฑฑบ          ณ atribua os valores referente ao registro anterior          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_PREVAR()
M->GT5_TPRESE 	:= GT5->GT5_TPRESE
M->GT5_PSETOR	:= Iif(GT5->GT5_PSETOR=="9",space(TamSx3("GT5_PSETOR")[1]),GT5->GT5_PSETOR)
M->GT5_PIDADE	:= Iif(GT5->GT5_PIDADE=="9",space(TamSx3("GT5_PIDADE")[1]),GT5->GT5_PIDADE)
M->GT5_PREINT	:= Iif(GT5->GT5_PREINT=="9",space(TamSx3("GT5_PREINT")[1]),GT5->GT5_PREINT)
M->GT5_PDATA 	:= Iif(GT5->GT5_PDATA=="9",space(TamSx3("GT5_PDATA")[1]),GT5->GT5_PDATA)
M->GT5_PLEIES	:= Iif(GT5->GT5_PLEIES=="9",space(TamSx3("GT5_PLEIES")[1]),GT5->GT5_PLEIES)
M->GT5_PTIPO 	:= Iif(GT5->GT5_PTIPO=="9",space(TamSx3("GT5_PTIPO")[1]),GT5->GT5_PTIPO)
M->GT5_CID   	:= GT5->GT5_CID

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_LMPVARบ Autor ณ                    บ Data ณ  18/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Limpa variaveis da memoria no momento da troca de registro บฑฑ
ฑฑบ          ณ no grid de Leitos                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_LMPVAR(lRet)

Default lret:=.F.

If !lret
	M->GT5_TPRESE 	:= ""
Endif

M->GT5_PSETOR	:= SPACE(TAMSX3("GT5_PSETOR")[1])
M->GT5_PIDADE	:= SPACE(TAMSX3("GT5_PIDADE")[1])
M->GT5_PREINT	:= SPACE(TAMSX3("GT5_PREINT")[1])
M->GT5_PDATA 	:= SPACE(TAMSX3("GT5_PDATA")[1])
M->GT5_PLEIES	:= SPACE(TAMSX3("GT5_PLEIES")[1])
M->GT5_PTIPO 	:= SPACE(TAMSX3("GT5_PTIPO")[1])
M->GT5_CID   	:= SPACE(TAMSX3("GT5_CID")[1])
Return






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DblClkบ Autor ณ                    บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(nMar)
Local nForACols := 0

If oGetGAV:aHeader[oGetGAV:oBrowse:nColPos, 2] == "GAV_OK    " //.AND. !oGetGAV:aCols[nMar,nUGPG+1]
	If oGetGAV:aCols[nMar,nGAVIdOK] == "LBNO"
		oGetGAV:aCols[nMar,nGAVIdOK] := "LBTIK"
		For nForACols := 1 to len(oGetGAV:aCols)
			If oGetGAV:aCols[nForACols,nGAVIdOK] == "LBTIK" .And. nForACols <> nMar
				oGetGAV:aCols[nForACols,nGAVIdOK] := "LBNO"
				Exit
			Endif
		Next
	Endif
EndIf
oGetGAV:oBrowse:Refresh()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHP05  บAutor  ณMicrosiga           บ Data ณ  01/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os Dados cadastrados na parametriza็ใo leitos      บฑฑ
ฑฑบ          ณ Tabela GT5                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_AtTela()
Local   LAcha:=.F.

DbSelectArea("GT5")
GT5->(DbSetOrder(1))

If 	GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]+ oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]+oGetGAV:aCols[oGetGAV:nAt,nGAVCodLei]))
	LAcha:=.T.
	Val(cComboRes):=3
	oComboBox:nat:=3

ElseIF GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]+ oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]))
	If GT5->GT5_LEITO==oGetGAV:aCols[oGetGAV:nAt,nGAVCodLei] .or. Empty(GT5->GT5_LEITO)
		LAcha:=.T.
		Val(cComboRes):=2
		oComboBox:nat:=2
		
	ElseIf GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]))
		If (GT5->GT5_QUARTO == oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua] .and. empty(GT5->GT5_QUARTO)) .or. empty(GT5->GT5_QUARTO)
			LAcha:=.T.
			Val(cComboRes):=1
			oComboBox:nat:=1

		Endif
	Endif
ElseIf GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]))
	If (GT5->GT5_QUARTO == oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua] .and. empty(GT5->GT5_QUARTO)) .or. empty(GT5->GT5_QUARTO)
		LAcha:=.T.
		Val(cComboRes):=1
		oComboBox:nat:=1
    
	Endif
	
Endif


If LAcha
	nReg := GT5->(Recno())
	FS_PREVAR()
	Inclui 	:= .F.
Else
	nReg 	:= 0
	FS_LMPVAR()
	Inclui 	:= .T.
EndIf

oComboBox:Refresh()
DbSelectArea("GT5")
RegToMemory("GT5",Inclui) //Gera variavies de memoria para o GAV

oDlgAut:cTitle := cCadastro + Alltrim(oGetSeto:aCols[oGetSeto:nAt,nGCSDesLoc]) + " - " + oGetSeto:aCols[oGetSeto:nAt,nGCSCodLoc]
oGT5:Refresh()
FS_VLP05()
aHeadGAV := {}
aColsGAV := {}

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_EXCRES บAutor  ณMicrosiga           บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Exclusใo do Item de Parametrizacao                       บฑฑ
ฑฑบ          ณ   na reserva Leitos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_EXCRES(lOk,nTpParam)
Local lAchou 	:= .F.
Local nGD		:= 0 
Local lRet 	    := .T.

Default lOk 	:= .F.

If Empty(oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]) .or. oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBNO"
	HS_MSGINF(STR0016,STR0013,STR0017) //"Selecione o Setor!"###"Aten็ใo"###"Valida็ใo Parametros do Reserva "
	Return(Nil)
EndIf

	cSeto  := oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]
   	cQuat  := oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]
   	cleit   :=oGetGAV:aCols[oGetGAV:nAt,nGAVCodLei]
   	
   If	nTpParam==2
	cleit :=space(TamSx3("GAV_LEITO")[1])
   Elseif nTpParam==1
	cQuat  := space(TamSx3("GAV_QUARTO")[1])
   	cleit :=space(TamSx3("GAV_LEITO")[1])
   Endif

If HS_CountTB("GT6", "GT6_CODLOC  = '" + cSeto + "'")  > 0
	HS_MsgInf(STR0018, STR0013, STR0019) //"Este registro estแ sendo utilizado na Lista de Espera. Exclusใo nใo permitida!"##"Aten็ใo"##"Valida็ใo de Exclusใo" //"Existe Lista de Espera para Este Setor . Exclusใo nใo permitida!"###"Aten็ใo"###"Valida็ใo de Exclusใo"
	Return()
Endif


If  oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBTIK"  .and. nTpParam==3
	DbSelectArea("GT5")
	DbSetOrder(1)
	lAchou := GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]+cQuat+cleit))
	If lAchou
		RecLock("GT5", .F., .F.)
		DbDelete()
		MsUnlock()
		WriteSx2("GT5")
		
		DbSelectArea("GAV")
		DbSetOrder(1)
		lAchou := GAV->(DbSeek(xFilial("GAV") + oGetGAV:aCols[oGetGAV:nAt,nGAVCodLoc]+oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]+oGetGAV:aCols[oGetGAV:nAt,nGAVCodLei]))
		RecLock("GAV", !lAchou)
		GAV->GAV_PARAME:=space(TamSx3("GAV_PARAME")[1])
		MsUnLock()
	EndIf
	
ElseIf  oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBTIK"  .and. nTpParam==2
	DbSelectArea("GT5")
	DbSetOrder(1)
	For nGD := 1 to Len(oGetGAV:aCols)
		lAchou := GT5->(DbSeek(xFilial("GT5") + oGetGAV:aCols[nGD,nGAVCodLoc]+cQuat))
		If lAchou
			RecLock("GT5", .F., .F.)
	   		DbDelete()
			MsUnlock()
	   		WriteSx2("GT5")
   		EndIf
 
		If  oGetGAV:aCols[oGetGAV:nAt,nGAVCodQua]==oGetGAV:aCols[nGD,nGAVCodQua] .and. oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBTIK" /*.and. lAchou*/
			DbSelectArea("GAV")
			DbSetOrder(1)
			lAchou := GAV->(DbSeek(xFilial("GAV") + oGetGAV:aCols[nGD,nGAVCodLoc]+oGetGAV:aCols[nGD,nGAVCodQua]+oGetGAV:aCols[nGD,nGAVCodLei]))
			RecLock("GAV", !lAchou)
			GAV->GAV_PARAME:=space(TamSx3("GAV_PARAME")[1])
			MsUnLock()
		Endif
		
	Next nGD

		
ElseIf  oGetGAV:aCols[oGetGAV:nAt,nGAVIdOK] == "LBTIK"  .and. nTpParam==1
	DbSelectArea("GT5")
	DbSetOrder(1)
	For nGD := 1 to Len(oGetGAV:aCols)
		lAchou := GT5->(DbSeek(xFilial("GT5") +  oGetGAV:aCols[nGD,nGAVCodLoc]))
		If lAchou
			RecLock("GT5", .F., .F.)
	   		DbDelete()
			MsUnlock()
	   		WriteSx2("GT5")
   		EndIf
   			
		DbSelectArea("GAV")
		DbSetOrder(1)
		lAchou := GAV->(DbSeek(xFilial("GAV") + oGetGAV:aCols[nGD,nGAVCodLoc]+oGetGAV:aCols[nGD,nGAVCodQua]+oGetGAV:aCols[nGD,nGAVCodLei]))
		RecLock("GAV", !lAchou)
		GAV->GAV_PARAME:=space(TamSx3("GAV_PARAME")[1])		
		MsUnLock()
	Next nGD
	
ElseIf	HS_MSGINF(STR0012,STR0013,STR0014) //"Selecione um modo (por Setor,leito,Quarto) para Atualiza็ใo"###"Aten็ใo"###"Valida็ใo Parametros da Reserva"
		
		lRet 	:= .F.
		Return()
Endif 

If !lOk .and.lAchou .and. lRet 
	HS_MSGINF(STR0015,STR0013,STR0014) //"Atualiza็ใo salva com sucesso!"###"Aten็ใo"###"Valida็ใo Parametros da Reserva"
	
EndIf

FS_TlaSet()

Return()  




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLP05  บAutor  ณMicrosiga           บ Data ณ  01/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do Campos na parametriza็ใo                      บฑฑ
ฑฑบ          ณ  Desabilita campos da Gt5                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



Function FS_VLP05()
Local  nI :=1
Local  cCampo
Local lRet:=.F.


If (ReadVar() == "M->GT5_TPRESE" .AND. M->GT5_TPRESE ='0')  .OR.  M->GT5_TPRESE ='0'	
		For nI := 1 To Len(oGT5:AENTRYCTRLS)
			cCampo := AllTrim(oGT5:aEntryctrls[nI]:CREADVAR)
			cCampo := StrTran(cCampo,"M->","")
			If ( cCampo # "GT5_TPRESE" )
				oGT5:AENTRYCTRLS[nI]:LREADONLY := .T.
				OGT5:AENTRYCTRLS[nI]:LACTIVE := .F.
				OGT5:AENTRYCTRLS[nI]:BWHEN:= {||.F. }
			Endif
		Next
		lRet:=.T.
		FS_LMPVAR(lRet)
	Else
		For nI := 1 To Len(oGT5:AENTRYCTRLS)
			oGT5:AENTRYCTRLS[nI]:LREADONLY := .F.
			OGT5:AENTRYCTRLS[nI]:LACTIVE := .T.
			OGT5:AENTRYCTRLS[nI]:BWHEN:= {||.T. }
		Next
		
	Endif
	oGT5:Refresh()

Return()







