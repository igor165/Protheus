#INCLUDE "HSPAHM50.ch"
#include "protheus.CH"
#Include "topconn.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM50  º Autor ³Alessandro Freire   º Data ³  24/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz a atribuicão das guias com seus respectivos lotes      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHM50()
 Local bKeyF12 := SetKey(VK_F12, {|| IIf(Type("__cFilM50")=="U", FS_FilM50(.T.), .T.)})
 Local aCposMB := {}

 Private cCadastro	 := STR0001 //"Atribuição de Lotes"
 Private cFilM50    := ""
 Private aGets[0], aTela[0][0]
 Private lMarkALL	:= .T. 
 Private cMarca := GetMark()
 
 Private aCores		:= {{"GCZ->GCZ_STATUS == '2'"	, 'BR_VERDE'	  }, ;
                     {"GCZ->GCZ_STATUS == '3'"	, 'BR_VERMELHO'}}

 Private __aMarkBrow := {}
 Private nTpAtend    := 0
 Private cCodConv    := Space(Len(GA9->GA9_CODCON))
 Private cGATCodCon  := ""  //Utilizada na funcao de filtro da GAT (HS_FilLote)
 Private cGATNrFatu  := Space(Len(GAT->GAT_NRFATU))  //Utilizada na funcao de filtro da GAT (HS_FilLote)
 Private cGcmCodCon := "" // Utilizada na funcao de filtro da GCM (HS_FilPla)
 Private cFilGuia    := "" // Recebe o valor do parametro Filial Faturamento
	
								
 Private aRotina	:= MenuDef()
            									
 
 aAdd(aCposMB, { "GCZ_IDMARC",, "", "" })
 aAdd(aCposMB, { "GCZ_DATATE",, HS_CfgSx3("GCZ_DATATE")[SX3->(FieldPos("X3_TITULO"))], '@D' })
 aAdd(aCposMB, { "GCZ_NOME  ",, HS_CfgSx3("GCZ_NOME  ")[SX3->(FieldPos("X3_TITULO"))], '@!' })

 DbSelectArea("SX3")
 DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
 DbSeek("GCZ")
 While !Eof() .And. SX3->X3_ARQUIVO == "GCZ"
  If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. SX3->X3_CONTEXT <> "V" .And. ;
     aScan(aCposMB, {| aVet | SX3->X3_CAMPO == aVet[1]}) == 0
   aAdd(aCposMB, { SX3->X3_CAMPO,, SX3->X3_TITULO, SX3->X3_PICTURE })
  EndIf
 
  DbSkip()
 End

 dbSelectArea("GCZ")
 dbSetOrder(1) // GCZ_FILIAL + GCZ_NRSEQG + GCZ_STATUS

 If Type("__cFilM50") <> "U" .Or. FS_FilM50(.F.)
  If Type("__cFilM50") <> "U"
	  cCodConv 			:= __cCodConv
   cFilM50 := __cFilM50
  Endif 
  MarkBrowse("GCZ", "GCZ_IDMARC",, aCposMB, .F., cMarca, "HS_MMarkB(@__aMarkBrow, cFilM50, .T.)",,,,, {|| oMB := GetMarkBrow(), oMB:bMark := {|| HS_BMark(@__aMarkBrow)} }, cFilM50, .T., aCores)
 EndIf
 
 SetKey(VK_F12, bKeyF12)
Return(nil)

Static Function FS_FilM50(lSetFilter)
 Local lRet := .F., oObjMBrw := GetMarkBrow()

lRet := !Pergunte("HSM50A", .T.)
While !lRet 
 If (!lRet)
  cFilGuia := MV_PAR01
  // Validacao do Plano
  lRet := HS_VSUSCP(MV_PAR02, MV_PAR03)
  If lRet
	  cCodConv 			:= MV_PAR02
	  nTpAtend 			:= MV_PAR09
		 FS_M50Cond()
		 If lSetFilter
		 	SetMBTopFilter("GCZ", cFilM50)
		 	DbSeek(xFilial("GCZ"))
            oObjMBrw:oBrowse:GoTop()
			oObjMBrw:oBrowse:Refresh()
		 EndIf
		 lRet := .T.
  EndIf
 Else
	 cGATCodCon := cCodConv
 	Return(.F.)
 EndIf
EndDo

 cGATCodCon := cCodConv
Return(lRet)

****************************************************************************************************
Function HS_m50atri()

Local nI			:= 1
Local oDlg			:= nil
Local cNovLot		:= SPACE(LEN(GAT->GAT_NUMLOT))
Local nOpca			:= 0
Local aProcessa		:= {}
Local cMsgErro		:= ""
Local aArea 		:= GetArea()
Local nGuiaAtu		:= 0
Local cMV_ATESUS	:= GetMv("MV_ATESUS",,"N")
Local aVParam		:= {}
 
Local cCodCon		:= ""
Local cCodBPA		:= ""
Local cCodPAC		:= ""
Local cCodAIH		:= ""
Local nMedida		:= 0
Local nForFil		:= 0  
Local nForGrp		:= 0
Local cFilGCZ		:= ""
Local lValid		:= .T. 
Local cTgTISS		:= ""
Local aCtlDesp		:= {}
Local _daduser		:= {}
Local _GRUPO 		:= {} 
Local nVldApac   	:= GetMv("MV_VLDGUIA",,90)              
Local cMV_CCVSUS	:= GetMv("MV_CCVSUS",,"")            
Local lRet			:=.T.
Local nGLote		:= 0
Local nQTGTISL 		:= GetMv("MV_QTGTISL",, 0)
Local nQTGTIEX 		:= 0 
Local aSize  		:= {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
Local lHsp50Vlot	:= ExistBlock("HSP50VLOT") 
Local lHspm50Ilo 	:= ExistBlock("HSPM50ILO")

Private cGATFilial  := "" //Utilizada na funcao de filtro da GAT (HS_FilLote)	
Private cFilLote 	:= cFilGuia // Recebe a filial do lote
Private cGk7Solici 	:= ""
Private dIniVldApc 	:= CtoD("")
Private dFimVldApc 	:= CtoD("") 
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

nMedida		:= IIF(!Empty(cFilGuia), aSize[ 6 ]*0.35, aSize[ 6 ]*0.25)

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.) 
	RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)    
EndIf

If Type("__cCodAIH") == "U"
	Private __cCodAIH	:= ""
	Private __cCodBPA	:= ""
	Private __cCodPAC	:= ""

	If cMV_AteSus == "S"
		aVParam := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
		If !HS_VMVSUS(@aVParam)
			UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)  
			HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
			Return(Nil)
		Else
			__cCodBPA  := aVparam[2][2]
			__cCodPAC  := aVparam[3][2]
			__cCodAIH  := aVparam[4][2]
		EndIf
	EndIf 
EndIf

PswOrder(1)
PswSeek(__CUSERID, .T.)  
_daduser := PswRet(1)
_grupo := Array(len(_daduser[1,10]))

For nForGrp := 1 to len(_daduser[1,10])

	If FindFunction("FWGrpEmp")
		_grupo[nForGrp] := FWGrpEmp(_daduser[1,10,nForGrp])
	Else
		Exit
	EndIf
	
	For nForFil := 1 To Len(_grupo[nForGrp])
		If ! _grupo[nForGrp][nForFil] $ cGATFilial
			cGATFilial += IIF(!Empty(cGATFilial), "/", "") + IIf(FWSizeFilial() > 2,SubStr(_grupo[nForGrp][nForFil],3,FWSizeFilial()),_grupo[nForGrp][nForFil])
		EndIf
	Next nForFil
	
Next nForGrp

AAdd(_grupo,PSWRET(2)[1][6])

PswOrder(1)
PswSeek(__CUSERID, .T.) 
For nForFil := 1 To Len(_grupo[Len(_grupo)])     
	If ! _grupo[Len(_grupo)][nForFil] $ cGATFilial
		cGATFilial += IIF(!Empty(cGATFilial), "/", "") + IIf(FWSizeFilial() > 2,SubStr(_grupo[Len(_grupo)][nForFil], 3, FWSizeFilial()),_grupo[Len(_grupo)][nForFil])
	EndIf
Next nForFil

//Caso tenha acesso a apenas uma filial, adiciona uma barra no fila para evitar que a funcao HS_InSql fatie o conteudo
If Len(cGATFilial) == Len(Alltrim(xFilial("GAT")))
	cGATFilial += "/"
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi("") From aSize[ 7 ], 000 to nMedida, aSize[ 5 ]/3  Pixel	Of oMainWnd 
  
	If lValid := !Empty(cFilGuia) .Or. (Empty(cFilGuia) .And. Len(PSWRET(2)[1][6]) == 1 .And. PSWRET(2)[1][6][1] == cFilAnt)
		@ aPObjs[1,1]+10, 008 Say STR0004 Size 60,0 PIXEL COLOR CLR_BLUE OF oDlg //"Selecione o Lote"
		@ aPObjs[1,1]+10, 065 MSGet o09 var cNovLot Picture "@!" F3 "GAT002" Size  45,9 PIXEL COLOR CLR_BLACK OF oDlg
	Else
		@ aPObjs[1,1]+10, 008 Say STR0063 Size 60,0 PIXEL COLOR CLR_BLUE OF oDlg  //"Selecione a Filial"
		@ aPObjs[1,1]+10, 065 MSGet o09 var cFilLote Picture "@!" F3 "GAT001" VALID FS_AtuVar() Size 45,9 PIXEL COLOR CLR_BLACK OF oDlg     
                                                                                         
		@ aPObjs[1,1]+25, 008 Say STR0004 Size 60,0 PIXEL COLOR CLR_BLUE OF oDlg //"Selecione o Lote"
		@ aPObjs[1,1]+25, 065 MSGet o09 var cNovLot Picture "@!" F3 "GAT002"  Size  45,9 PIXEL COLOR CLR_BLACK OF oDlg
	EndIf
   
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg, {|| nOpcA := 1, IIF(HFM050VLOT(cNovLot, cFilLote) .And. IIF(!lValid, HS_VldFilF(), .T.), oDlg:End(), nOpcA := 0)}, ;
 																																																										{|| nOpca := 0, oDlg:End()})

If nOpca == 0
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)    
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(nil)
EndIf  
     
DbSelectArea("GAT")
DbSetOrder(2) // GAT_FILIAL + GAT_CODCON + GAT_NUMLOT
DbSeek(cFilLote + cCodConv + cNovLot)
 
If Alias() <> "GCZ"
	DBSelectArea("GCZ")
EndIf

nQTGTIEX := FS_VQTGTIS(cNovLot,GCZ->GCZ_CODCON,GCZ->GCZ_NRSEQG,.T.)

If lHsp50Vlot
	If !(ExecBlock("HSP50VLOT",.F.,.F.,{cNovLot, GCZ->GCZ_NRSEQG}))		//Numero do lote - Sequencia da guia
		RestArea(aArea)
		UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.) 
		HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
		Return(Nil)
	EndIf
EndIf

ProcRegua(Len(__aMarkBrow))

nGLote := HS_CountTB("GCZ","GCZ_NRLOTE = '" + cNovLot + "'") + 1

If Len(__aMarkBrow) ==0
    HS_MsgInf(STR0080, STR0010,STR0001)
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.) 
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(nil)
Endif	
For nGuiaAtu := 1 To Len(__aMarkBrow)

	/*If nGLote > 100
		Exit
	EndIf*/

	If Alias() <> "GCZ"
		DBSelectArea("GCZ")
	EndIf
  
	If IndexOrd() <> 1
		DbSetOrder(1)
	EndIf
  
	cFilGCZ := IIF(Empty(xFilial("GCZ")), "  ", __aMarkBrow[nGuiaAtu][4])
  
	DBSeek(cFilGCZ + __aMarkBrow[nGuiaAtu][1])
  
	IncProc(STR0031 + GCZ->GCZ_NRSEQG + STR0032 + cNovLot + STR0033)//"Aguarde, atribuindo a guia ["###"] ao lote ["###"]"
 
	If GAT->GAT_MATMED == "0"
		GD5->(DbSetOrder(2)) //GD5_FILIAL + GD5_NRSEQG + GD5_DATDES
		If GD5->(DbSeek(cFilGCZ + GCZ->GCZ_NRSEQG))
			HS_MsgInf(STR0026, STR0010, STR0048) //"Este Lote nao aceita despesas de Medicamentos e Materiais."###"Atencao"###"Validação do Lote"   
			Loop
		EndIf
	EndIf 
 	
	If GAT->GAT_TAXDIA == "0"
		GD6->(DbSetOrder(2)) // GD6_FILIAL + GD6_NRSEQG + GD6_DATDES
		If GD6->(DbSeek(cFilGCZ + GCZ->GCZ_NRSEQG))
			HS_MsgInf(STR0027, STR0010, STR0048) //"Este Lote nao aceita despesas de Taxas e Diarias."###"Atencao"###"Validação do Lote"
			Loop
		EndIf
	EndIf   
  
	If GCZ->GCZ_STATUS <> "2"
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG  //"NRSEQG"
		cMsgErro += STR0034 + Chr(10)//" Somente as guias com status 2(Faturamento) podem ser atribuidas a um lote "  
		Loop
	EndIf
  
	If !Empty(xFilial("GA9")) .And. !Empty(xFilial("GCM")) .And. GCZ->GCZ_FILFAT <> cFilAnt  //Se as tabelas GA9 e GCM nao forem compartilhadas, despreza as guias com filial fat <> da filial posicionada 
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
		cMsgErro += STR0066 + Chr(10)    //"As tabela de Convênio e Plano não são compartilhadas. "
		Loop
	EndIf
		
	If GCZ->GCZ_FILFAT <> GAT->GAT_FILIAL  //Verifica se o campo GCZ_FILFAT e diferente da filial do lote
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
		cMsgErro += STR0067 + Chr(10)    //"Esta guia possui filial de faturamento diferente da filial do lote."
		Loop
	EndIf

	// Se ja tem um lote atribuido, não pode alterar
	If ! Empty(GCZ->GCZ_NRLOTE)                                                                                   
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
		cMsgErro += STR0035 + Chr(10)//"Esta guia já possui lote atribuido "   
		Loop
	EndIf
	If !Empty(GAT->GAT_CODPLA)
		If !(GCZ->GCZ_CODPLA $ GAT->GAT_CODPLA)
			cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
			cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
			cMsgErro += STR0042 + GAT->GAT_CODPLA + STR0037 + Chr(10)//"Esta guia nao pertence ao plano ["###"] do lote"
			Loop
		EndIf
	Else
		If GCZ->GCZ_CODCON != GAT->GAT_CODCON
			cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
			cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
			cMsgErro += STR0036 + GAT->GAT_CODCON + STR0037 + Chr(10)//"Esta guia nao pertence ao convenio ["###"] do lote"	 
			Loop
		EndIf
	EndIf
	 
	cTgTISS := HS_IniPadr("GCU", 1, GCZ->GCZ_CODTPG, "GCU_TGTISS",, .F.)      
	If GCZ->GCZ_ATENDI == "0" .And. cTgTISS == "04" .And. Empty(GCZ->GCZ_CODDES)  // Validacao TISS - somente para atendimentos "0" e tipo de guia TISS igual a "04"   	 
		aCtlDesp := HS_CtlDesp(GCZ->GCZ_NRSEQG) 
		If aCtlDesp[2]  		
			cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
			cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
			cMsgErro += STR0071 + Chr(10) //"Não possuí código do serviço principal"
		EndIf
	EndIf	                          

	If (Empty(cMV_CCVSUS) .Or. GAT->GAT_CODCON != cMV_CCVSUS) .And. HS_ExisDic({{"C", "GAT_TGTISS"}}, .F.) .And. cTgTISS != space(len(GCU->GCU_TGTISS))
		If !(cTgTISS $ GAT->GAT_TGTISS)
			cMsgErro += STR0077 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"O tipo de guia TISS não é permitido neste lote"
			Loop
		EndIf  	
	EndIf
	 	
	If (!Empty(cMV_CCVSUS) .Or. GAT->GAT_CODCON == cMV_CCVSUS) .And. Alltrim(GAT->GAT_CODPLA) == Alltrim(__cCodAIH)
		If GAT->(FieldPos("GAT_DTAPRE"))>0 .And. Empty(GAT->GAT_DTAPRE)
			cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
			cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
			cMsgErro += "Para o Plano " + Alltrim(GAT->GAT_CODPLA) + " e necessario preencher o campo Data Apres" + Chr(10)
			Loop
		EndIf    
	EndIf
	If GCU->GCU_TPGUIA != GAT->GAT_TIPATE
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
		cMsgErro += STR0075 + Chr(10) //"O tipo da guia difere da regra configurada no lote"
		Loop
	EndIf
	 
	If	(GAT->GAT_TIPATE == "0" .And. !(GCZ->GCZ_CODPLA $ GAT->GAT_CODPLA)) .Or.;
		(GAT->GAT_TIPATE != "0" .And. !Empty(GAT->GAT_CODPLA) .And. !(GCZ->GCZ_CODPLA $ GAT->GAT_CODPLA))
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10) //"NRSEQG"
		cMsgErro += STR0076 + Chr(10) //"Plano não permitido neste lote"
		Loop
	EndIf
	 
	aProcessa := HS_P12SEL("F")//Verifica se existe alguma despesa de Mat/Med - Tax/Dia - Procedto zerada referente a esta Guia.
	 
	If (!aProcessa[1] .Or. !aProcessa[2] .Or. !aProcessa[3] .Or. aProcessa[4] == 0 .Or. !aProcessa[5][1] .Or. !aProcessa[5][2] .Or. !aProcessa[5][3]) .And.;
		!(GCZ->GCZ_CODPLA $ __cCodBPA + "/" + __cCodPAC + "/" + __cCodAIH) //Não valida para o SUS
		cMsgErro += STR0065 + " - " + ' ' + GCZ->GCZ_NRSEQG + Chr(10)
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		If !aProcessa[1]
			cMsgErro += STR0038 + Chr(10)//"Guia Não Faturada, existem despesas de Mat/Med Com o Valor Zerado"
		EndIf	          
		If !aProcessa[2]
			cMsgErro += STR0039 + Chr(10)//"Guia Não Faturada, existe despesa de Tax/Dia Com o Valor Zerado"
		EndIf	          
		If !aProcessa[3]
			cMsgErro += STR0040 + Chr(10)//"Guia Não Faturada, existe despesa de Procedto Com o Valor Zerado"
		EndIf 	 	       
		If aProcessa[4] == 0
			cMsgErro += STR0041 + Chr(10)//"Não foi encontrada nenhuma despesa lançada na guia"
		EndIf
		If !aProcessa[5][1]
			cMsgErro += STR0072 + chr(10)
		EndIf 	 	
		If !aProcessa[5][2]
			cMsgErro += STR0073 + chr(10)
		EndIf 	 	
		If !aProcessa[5][3]
			cMsgErro += STR0074 + chr(10)
		EndIf 	 	
		Loop
	EndIf
	 
	// Se foi selecionado um lote ambulatorial e foi parametrizado que a guia eh de internacao
	// nao atribui lote
	If GAT->GAT_TIPATE $ "123" .and. nTpAtend == 1
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
		cMsgErro += STR0044 + Chr(10)//"Lotes dos tipos (1, 2, ou 3) não podem ser usados para guias de internação"	 
		Loop
	Endif
	
	// Se foi selecionado um lote de internacao e foi parametrizado que a guia eh ambulatorial
	// nao atribui lote
	If GAT->GAT_TIPATE == "0" .and. nTpAtend == 2                                                                 
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
		cMsgErro += STR0045 + Chr(10)//"Lotes de internação nao podem ser usados para guias ambulatoriais"   
		Loop
	Endif
	 
	// Se a guia tiver pendencia (GEZ)
	DbSelectArea("GEZ")
	DbSetOrder(3) //GEZ_FILIAL + GEZ_NRSEQG + GEZ_ATIVO
	If DbSeek(IIF(Empty(xFilial("GEZ")), "  ", cFilGCZ) + GCZ->GCZ_NRSEQG + "1")
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
		cMsgErro += STR0046 + Chr(10)//"Guia apresenta pendencias"
		Loop
	EndIf
	 
	// Verifica se a quantidade de itens ultrapassa o limite maximo informado no cadastro de lote
	If GAT->GAT_LIMITE > 0 .and. GAT->GAT_ITENS >= GAT->GAT_LIMITE
		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
		cMsgErro += STR0023 + GAT->GAT_NUMLOT + STR0024 + AllTrim(Str(GAT->GAT_LIMITE)) + STR0025 + Chr(10) //"O Lote "###" ultrapassou o limite de "###" guias."
		Loop
	EndIf
	 
	//Valida guia sus apac
	If (GCZ->GCZ_CODPLA $ __cCodPAC) 
		If !Empty(cGk7Solici := Hs_SolApac(GCZ->GCZ_REGATE,"GK7_SOLICI",{{'dIniVldApc', 'GK7_DTINVL'}, {'dFimVldApc','GK7_DTFIVL'}}))    
			If Substr(StrTran(HS_DToC(dIniVldApc),"/",""),3) > StrTran(GAT->GAT_MESREF,"/","") ;
				.Or. Substr(StrTran(HS_DToC(dFimVldApc),"/",""),3) < StrTran(GAT->GAT_MESREF,"/","")
				cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
				cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
				cMsgErro += "Validade da 'Solicitação de Apac' "
				If Substr(StrTran(HS_DToC(dIniVldApc),"/",""),3) < GAT->GAT_MESREF
					cMsgErro += "anterior a competência do lote."
				Else
					cMsgErro += "posterior a competência do lote."     
				Endif
				Loop
			EndIf  
		Else
			cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
			cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
			cMsgErro += "Solicitação de APAC não encontrada."
			Loop   
		EndIf
	EndIf  
	 	 
	//Valida guia sus Aih
	If (GCZ->GCZ_CODPLA == __cCodAIH)  .And. !Empty(GAT->GAT_DTAPRE) 
		cData := CTod("01" + Substr(dtoc(CtoD('01/'+ GAT->GAT_DTAPRE)- 90),3,8))   //verifico a data dos ultimos 3 meses
		If (CTod("01" + Substr(dtoc(GCZ->GCZ_DATATE),3,8)) >= CtoD('01/'+ GAT->GAT_DTAPRE) .Or. ; 
			cData > CTod("01" + Substr(dtoc(GCZ->GCZ_DATATE),3,8))) .And. GCZ->GCZ_TIPAIH <> '5'
			//Substr(StrTran(HS_DToC(GCZ->GCZ_DATATE),"/",""),3) >= StrTran(GAT->GAT_DTAPRE,"/","")
			//(Substr(StrTran(HS_DToC(cData),"/",""),3) > Substr(StrTran(HS_DToC(GCZ->GCZ_DATATE),"/",""),3))
			
			cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
			cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
			cMsgErro += "Validade do Num da AIH "
			If CTod("01" + Substr(dtoc(GCZ->GCZ_DATATE),3,8)) < cData// Substr(StrTran(HS_DToC(GCZ->GCZ_DATATE),"/",""),3) < Substr(StrTran(HS_DToC(cData),"/",""),3) 
				cMsgErro += "menor do que a data de apresentacao do lote."
			Else
				cMsgErro += "maior ou igual a data de apresentacao do lote."    
			Endif
			Loop
		EndIf  
	EndIf
	/*Valida os Procedimento lancados com o Grupo de Procedimentos Informado no Lote*/

	If !Empty(GAT->GAT_CODGPP).and. !(lRet := HS_GrupLot(GAT->GAT_CODGPP,GCZ->GCZ_NRSEQG))
		cMsgErro += STR0078 + Chr(10) 		
		Loop
	Endif
	
	If nQTGTISL > 0  // Quantidade atribuida pelo maximo estipulado no parametro "MV_QTGTISL" correspondente ao schema do XML TISS
    	If nQTGTIEX >= nQTGTISL
	  		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
	  		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
	  		cMsgErro += STR0023 + GAT->GAT_NUMLOT + STR0024 + AllTrim(Str(nQTGTISL)) + STR0025 + Chr(10) //"O Lote "###" ultrapassou o limite de "###" guias."    		    	
	  		Exit
    	ElseIf (nQTGTIEX += FS_VQTGTIS(cNovLot,GCZ->GCZ_CODCON,GCZ->GCZ_NRSEQG,.F.)) > nQTGTISL
	  		cMsgErro += STR0064 + " - " + GCZ->GCZ_FILIAL + Chr(10) //"Filial"
	  		cMsgErro += STR0065 + " - " + GCZ->GCZ_NRSEQG + Chr(10)
	  		cMsgErro += STR0023 + GAT->GAT_NUMLOT + STR0024 + AllTrim(Str(nQTGTISL)) + STR0025 + Chr(10) //"O Lote "###" ultrapassou o limite de "###" guias."    		
	  		Exit
	  	EndIf
	EndIf
	
	If lHspm50Ilo
		lRet := ExecBlock("HSPM50ILO",.F.,.F.,{GCZ->GCZ_REGATE, cNovLot, GCZ->GCZ_NRSEQG})		//Registro de Atendimento - Numero do lote - Sequencia da guia
		If !lRet
			Loop
		EndIf
	EndIf
	 
	DbSelectArea("GAT")
	RecLock("GAT",.F.)
		GAT->GAT_ITENS		:= GAT->GAT_ITENS + 1
	MsUnlock()
  
	DbSelectArea("GCZ")
	RecLock("GCZ",.F.)
		GCZ->GCZ_NRLOTE	:= cNovLot
		GCZ->GCZ_STATUS	:= "3" // Com Lote
	MsUnlock()

	nGLote++
	 	 
Next nGuiaAtu
 
/*If nGLote > 100
	HS_MsgInf(STR0079, STR0010, STR0048) //"Este Lote atingiu o limite máximo de guias (100), conforme regulamentação da ANS (TISS)."###"Atencao"###"Validação do Lote"
EndIf*/

If !Empty(cMsgErro)
	HS_MsgInf(cMsgErro, STR0010, STR0001)//"Atenção"###"Atribuição de lotes"
Else
	If FunName() <> "HSPAHP12"
		HS_MMarkB(@__aMarkBrow, cFilM50, .T.)
	EndIf
EndIf
 
UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aArea)
Return(Nil)

****************************************************************************************************
FUNCTION HS_m50reti(aItensMar, oMbGCZ)
Local aArea			:= GetArea()
Local nGuiaAtu		:= 0
Local lRet			:= .T.
Local lHspm50Ret	:= ExistBlock("HSPM50RET")

If !LockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCZ->GCZ_REGATE,.T.)
	RestArea(aArea)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCZ->GCZ_REGATE)  
EndIf

If ! MsgYesNo(STR0009, STR0010) //"Confirma a retirada do lote dos itens marcados?"###"Atenção"
	UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)
	Return(nil)
Endif
For nGuiaAtu := 1 To Len(__aMarkBrow)
	
	If Alias() <> "GCZ"
		DBSelectArea("GCZ")
	EndIf
	
	If IndexOrd() <> 1
		DBSetOrder(1)
	EndIf
	
	cFilGCZ :=IIF(Empty(xFilial("GCZ")), " ", __aMarkBrow[nGuiaAtu][4])
	
	DBSeek(cFilGCZ + __aMarkBrow[nGuiaAtu][1])
	
	If GCZ->GCZ_STATUS <> "3"
		DbSkip()
		Loop
	EndIf
	
	If lHspm50Ret
		lRet := ExecBlock("HSPM50RET", .F., .F., {GCZ->GCZ_REGATE, GCZ->GCZ_NRLOTE})
		If !lRet
			DbSkip()
			Loop
		EndIf
	EndIf
	
	DBSelectArea("GAT")
	DBSetOrder(2) //GAT_FILIAL + GAT_CODCON + GAT_NUMLOT
	DBSeek(GCZ->GCZ_FILFAT + GCZ->GCZ_CODCON + GCZ->GCZ_NRLOTE)
	
	IF GAT->GAT_ITENS > 0
		RecLock("GAT",.F.)
		GAT->GAT_ITENS		:= GAT->GAT_ITENS - 1
		MsUnlock()
	EndIf
	
	RecLock("GCZ",.F.)
	GCZ->GCZ_NRLOTE	:= Space(Len(GCZ->GCZ_NRLOTE))
	GCZ->GCZ_STATUS	:= "2"
	MsUnlock()
	
Next

If FunName() <> "HSPAHP12"
	HS_MMarkB(@__aMarkBrow, cFilM50, .T.)
EndIf

UnLockByName("ExecM24" + GCZ->GCZ_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCZ->GCZ_REGATE)

RestArea(aArea)
Return(nil)

****************************************************************************************************
* Faz a atribuicao das despesas
****************************************************************************************************
FUNCTION HS_m50desp()

 Local aArea	:= GetArea()
 Local nOpc  := IIF(FunName() == "HSPAHP01", 2, 7)

 DbSelectArea("GCY")
 DbSetOrder(1) //GCY_FILIAL + GCY_REGATE 
 If !dbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
	 HS_MsgInf(STR0020, STR0021, STR0047) //"Não há registro de atendimento para esta guia. Chame o suporte."###"Inconsistência"###"Atribuição da(s) Despesa(s)"
 Else
 	HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "F", nOpc, GCY->GCY_CODLOC, GCZ->GCZ_NRSEQG})
 EndIf

 RestArea(aArea)
Return(nil)

****************************************************************************************************
* Esta rotina valida o lote digitado verificando se o convenio esta correto, se o lote nao foi faturado
* e se deve atribuir lote mesmo que as datas estajam fora do informado nos parametros
****************************************************************************************************
STATIC FUNCTION HFM050VLOT(cNovLot, cFilLote)

 Local aArea		:= GetArea()
 Local lRet		:= .t.

 dbSelectArea("GAT")
 dbSetOrder(2) // GAT_FILIAL + GAT_CODCON + GAT_NUMLOT
 If ! dbSeek(cFilLote + cCodConv + cNovLot)
	 HS_MsgInf( STR0011 + cNovLot + STR0068 + cFilLote + STR0012 + cCodConv, STR0010, STR0048) //"Não Existe o lote "###" para o convênio "###"Atencao"###"Validação do Lote" //" na filial "
	 lRet	:= .f.
 EndIf

 If lRet .And. ( !Empty(GAT->GAT_DTFTLT) .Or. !Empty(GAT->GAT_NRFATU) )
 	HS_MsgInf(STR0013, STR0010, STR0048) //"Este lote já foi faturado e não aceita novas atualizações"###"Atencao"###"Validação do Lote"
 	lRet := .f.
 EndIf

 RestArea(aArea)
Return(lRet)

****************************************************************************************************
STATIC FUNCTION FS_M50Cond()
 cFilM50		:= "GCZ_STATUS IN ('2', '3') AND GCZ_CANCEL <> '1' "

 If !Empty(cFilGuia)
	 cFilM50		+= " AND GCZ_FILFAT = '" + cFilGuia + "'" 
 EndIf

 IF ! Empty(cCodConv)
	 cFilM50		+= " AND GCZ_CODCON = '" + cCodConv + "'"
 EndIf

 If ! Empty(mv_par03)
	 cFilM50	+= " AND GCZ_CODPLA = '" + MV_PAR03 + "'"
 EndIf 
 
 If !Empty(MV_PAR04)
  cFilM50	+= " AND GCZ_NRGUIA >= '"  + MV_PAR04 + "'"
 EndIf
 
 If !Empty(MV_PAR05)
  cFilM50	+= " AND GCZ_NRGUIA <= '"  + MV_PAR05 + "'"
 EndIf
                            
 If !Empty(MV_PAR06)
	 cFilM50 += " AND GCZ_LOCATE = '" + MV_PAR06 + "'"
 EndIf
 
 If !Empty(MV_PAR07)
  cFilM50	+= " AND GCZ_DATATE >= '" + DToS(MV_PAR07) + "'"
 EndIf
 
 If !Empty(MV_PAR08)
  cFilM50	+= " AND GCZ_DATATE <= '" + DToS(MV_PAR08) + "'"
 EndIf

 If     nTpAtend == 1 // Internacao
	 cFilM50 += " AND GCZ_ATENDI = '0'"
 ElseIf nTpAtend == 2 // ambulatorio
	 cFilM50 += " AND GCZ_ATENDI IN ('1', '2')"
 EndIf
 
 If !Empty(MV_PAR10)
	 cFilM50 += " And GCZ_CODTPG = '" + MV_PAR10 + "'"
 EndIf         
Return(Nil)

****************************************************************************************************
*********************************************************************************************
Function HS_M50Leg()
 BrwLegenda(cCadastro, STR0006, {{'BR_VERDE'		 , STR0014}, ; //"Legenda"###"Guias sem lote"
                                 {'BR_VERMELHO', STR0015}})  //"Guias com lote"
Return(.T.)

****************************************************************************************************
FUNCTION HS_M50VG()
 AxVisual("GCZ",GCZ->(Recno()),2)
Return(nil)

****************************************************************************************************
FUNCTION HS_M50VL()

 If Empty(GCZ->GCZ_NRLOTE)
	 HS_MsgInf(STR0003, STR0010, STR0048) //"Esta guia não está associada a nenhum lote."###"Inconsistência"###"Validação do Lote"
	 Return(nil)
 EndIf

 GAT->(dbSetOrder(2))  //GAT_FILIAL + GAT_CODCON + GAT_NUMLOT
 GAT->(dbSeek(xFilial("GAT") + GCZ->GCZ_CODCON + GCZ->GCZ_NRLOTE) )

 AxVisual("GAT",GAT->(Recno()), 2)

Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_M50EXT ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 17.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Extrato do paciente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M50EXT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M50EXT(cAlias, nReg, nOpc)

 HS_EXTM24C(GCZ->GCZ_REGGER, "P", nOpc)

Return(Nil)              

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilM50 ³ Autor ³ Eduardo Alves         ³ Data ³ 10/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche a variavel do filtro HS_FilPla da consulta padrao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_FilM50                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP - SX1 - HSM50A                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FilM50()
	cGcmCodCon	:= MV_PAR02
Return(.T.)  
  




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRot1		:= {{STR0016, "HS_M50VG", 0, 2}, ; //"Guia"
                    {STR0017, "HS_M50VL", 0, 2}}   //"Lote"
								
Local aRot2		:= {{STR0007,"HS_M50Atri()"  , 0, 4}, ; //"Atribuir Lote"
                    {STR0018,"HS_M50Reti()", 0, 4}}   //"Retirar Lote"
                      
Local aRot3  := {{STR0029,"HS_DocsFat(1)", 0, 2},; //"Capa Fatura"
                    {STR0030,"HS_DocsFat(2)", 0, 2},; //"Descritivo"
                    {STR0005,"HS_DocsFat(3)", 0, 2}}  //"Ambos"
 
Local aRotina	:= {{STR0002,"AxPesqui"     , 0, 1, 0, Nil},; //"Pesquisar"
                      {STR0019,aRot1         , 0, 2, 0, Nil},; //"Visualizar"
                      {STR0017,aRot2         , 0, 4, 0, Nil},; //"Lote"
                      {STR0008,"HS_m50Desp()", 0, 4, 0, Nil},;  //"Despesas"
                      {STR0022,"HS_M50Ext"   , 0, 2, 0, Nil},; //"Extrato"
                      {STR0028,aRot3         , 0, 4, 0, Nil},;    //"Doctos"                         
                      {STR0006,"HS_m50Leg()" , 0, 3, 0, Nil} } //"Legenda"
Return(aRotina)

Static Function FS_AtuVar()
 cNovLot := cFilLote    
Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM50  ºAutor  ³Microsiga           º Data ³  06/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se Os procedimentos lançados na                    º±±
±±º          ³Guia não pertence ao Grupo de Procedimentos                 º±±
±±º 		  Informado no lote para serem atribuida        			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function  HS_GrupLot(CODGPP,NRSEQG)
Local lRet := .T.
Local cSQL := ""
Local aArea := GetArea()


 cSQL := "SELECT 'GD' TIPO, COUNT(*) CNTDESP"
 cSQL += " FROM " + RetSQLName("GD7") + " GD7 "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "	
 cSQL += " WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCZ.GCZ_NRSEQG = '" + NRSEQG + "' "
 cSQL += " AND GA7.GA7_CODGPP <>  '" + CODGPP + "' "

 cSQL += "UNION ALL "

 cSQL += " SELECT 'GE' TIPO, COUNT(*) CNTDESP"
 cSQL += " FROM " + RetSQLName("GE7") + " GE7 "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "	
 cSQL += " WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCZ.GCZ_NRSEQG = '" + NRSEQG + "' "
 cSQL += " AND GA7.GA7_CODGPP <>  '" + CODGPP + "' "
	
 cSQL := ChangeQuery(cSQL)
	
 DBUseArea(.T., "TOPCONN", TcGenQry(,, cSQL), "QRYDESP", .F., .T.)
	
 DbSelectArea("QRYDESP")
 DbGoTop()
	
 While !EOF()
 	If QRYDESP->CNTDESP > 0
		lRet := .F.
	End
 DBSkip()
 EndDo
	
 DbCloseArea()	


RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VQTGTISºAutor  ³Microsiga           º Data ³  14/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a quantidade de Guias existentes no lote           º±±
±±º          ³e se ultrapassara a quantidade informada no parametro       º±±
±±º 		 |MV_QTGTISL, quantidade parametrizada de acordo com o schema º±±
±±º 		 |do XML de TISS da ANS                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VQTGTIS(cLote,cCodCon,cNrSeqG, lVerTD)
Local cSql 		:= "" 
Local nQtdreg	:= 0

If lVerTD
	cSql := " SELECT DISTINCT  GCZ_NRSEQG, GE7_CODCRM "
	cSql += " FROM  " + RetSqlName("GCZ") + "  GCZ "
	cSql += " JOIN  " + RetSqlName("GE7") + "  GE7 ON  GE7.D_E_L_E_T_ <> '*' AND GE7_PGTMED = '0' "
	cSql += " AND GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' "
	cSql += " WHERE GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND "
	cSql += " GCZ_CODCON = '" + cCodCon + "' AND GCZ_NRLOTE = '"  + cLote + "' "
	cSql += " UNION "
	cSql += " SELECT DISTINCT GCZ_NRSEQG, GCZ_CODCRM "
	cSql += " FROM  " + RetSqlName("GCZ") + "  GCZ "
	cSql += " WHERE GCZ.D_E_L_E_T_ <> '*' AND "
	cSql += " GCZ_CODCON = '" + cCodCon + "' AND GCZ_NRLOTE = '"   + cLote +  "' "
	cSql += " AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ_NRSEQG NOT IN(SELECT GCZ_NRSEQG "
	cSql += " FROM  " + RetSqlName("GCZ") + "  GCZ1 "
	cSql += " JOIN  " + RetSqlName("GE7") + "  GE71 ON  GE71.D_E_L_E_T_ <> '*' AND GE71.GE7_PGTMED = '0' "
	cSql += " AND GE71.GE7_NRSEQG = GCZ1.GCZ_NRSEQG  AND GE71.GE7_FILIAL = '" + xFilial("GE7") + "' "
	cSql += " WHERE GCZ1.D_E_L_E_T_ <> '*' AND GCZ1.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND "
	cSql += " GCZ1.GCZ_CODCON = '" + cCodCon + "' AND GCZ1.GCZ_NRLOTE = '" + cLote + "') "
	
	cSql := ChangeQuery(cSql)
	   	
	TCQUERY cSql NEW ALIAS "QRYQTD"     
	
	While !QRYQTD->(Eof())
		nQtdreg += 1
		QRYQTD->(DbSkip())
	End
	
	QRYQTD->(DbCloseArea()) 
EndIf

If !lVerTd
	cSql := " SELECT DISTINCT  GCZ_NRSEQG, GE7_CODCRM "
	cSql += " FROM  " + RetSqlName("GCZ") + "  GCZ "
	cSql += " JOIN  " + RetSqlName("GE7") + "  GE7 ON  GE7.D_E_L_E_T_ <> '*' AND GE7_PGTMED = '0' "
	cSql += " AND GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' "
	cSql += " WHERE GCZ.GCZ_NRSEQG = '" + cNrSeqG + "' AND GCZ.D_E_L_E_T_ <> '*' 
	cSql += " AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND "
	cSql += " GCZ_CODCON = '" + cCodCon + "' "
	cSql += " UNION "
	cSql += " SELECT DISTINCT GCZ_NRSEQG, GCZ_CODCRM "
	cSql += " FROM  " + RetSqlName("GCZ") + "  GCZ "
	cSql += " WHERE GCZ.GCZ_NRSEQG = '" + cNrSeqG + "' AND GCZ.D_E_L_E_T_ <> '*' AND "
	cSql += " GCZ_CODCON = '" + cCodCon + "'  "
	cSql += " AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ_NRSEQG NOT IN(SELECT GCZ_NRSEQG "
	cSql += " FROM  " + RetSqlName("GCZ") + "  GCZ1 "
	cSql += " JOIN  " + RetSqlName("GE7") + "  GE71 ON GE71.D_E_L_E_T_ <> '*' AND GE71.GE7_PGTMED = '0' "
	cSql += " AND GE71.GE7_NRSEQG = GCZ1.GCZ_NRSEQG  AND GE71.GE7_FILIAL = '" + xFilial("GE7") + "' "
	cSql += " WHERE GCZ1.GCZ_NRSEQG = '" + cNrSeqG + "' AND " 
	cSql += " GCZ1.D_E_L_E_T_ <> '*' AND GCZ1.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND "
	cSql += " GCZ1.GCZ_CODCON = '" + cCodCon + "' ) "
	
	cSql := ChangeQuery(cSql)
	   	
	TCQUERY cSql NEW ALIAS "QRYQTD"     

	While !QRYQTD->(Eof())
		nQtdreg += 1
		QRYQTD->(DbSkip())
	End
	
	QRYQTD->(DbCloseArea())  
EndIf

Return(nQtdreg)
