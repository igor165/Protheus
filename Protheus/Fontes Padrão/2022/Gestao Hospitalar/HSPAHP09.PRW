#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HSPAHp09 ณ Autor ณ Rogerio Machado Tabosaณ data ณ 08/06/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Parametriza็๕es Laboratorio                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHP09()         

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons := {}

Private nGDOpc		:= GD_UPDATE + GD_DELETE + GD_INSERT
Private nOpcAut   
Private nReg 		:= 0
Private nUGPH,nUGPG	:= 0
  
Private	nMMMCodPar 	:= 0
Private	nMMMCodSeq	:= 0
Private	nMMMCodMET 	:= 0
Private	nMMMCodMAT 	:= 0 
Private	nMMMCodMCO 	:= 0 
Private	nMMMIdPadr 	:= 0 
Private	nASSCodAss 	:= 0 
Private	nASSFatAss 	:= 0 

Private Inclui 		:= .F. 
Private lAtuDado	:= .F.

Private oGetProc  	:= nil
Private oGetMMM  	:= nil
Private oGetASS  	:= nil

Private oGP9	 	:= nil
Private oGP8	 	:= nil
Private aHeadProc 	:= {}, aColsProc := {}
Private aHeadMMM 	:= {}, aColsMMM := {}
Private aHeadASS 	:= {}, aColsASS := {}

Private aCpoGA7  	:= {"GA7_MNEMON","GA7_CODPRO","GA7_DESC","GAQ_CODLOC","GCS_NOMLOC"}  
Private aJoinGA7 	:= {}    

Private aCpoMMM  := {"GPG_CODMCO","GPG_DESMCO","GPG_CODMET","GPG_DESMET","GPG_CODMAT","GPG_DESMAT","GPG_CODSEQ"}
Private aCpoGPH  := {"GPH_FATASS","GPH_CODASS","GPG_DESASS"}
Private cMarDef  := ""
Private cCpomark  := ""

Private cCadastro  	:= OemToAnsi("Parametriza็ใo ") //"Solicitacao de Autorizacao"  
Private nGA7CodProc := 0
Private nGA7DesProc := 0

Private cGcsTipLoc 	:= "G" // Variavel utilizada pelo fonte HSPFFSXB para listar os setores do tipo
Private cCodLoc	    := ""
Private cGcsCodLoc	:= "" //Variavel de fitro da consulta padrใo de procedimentos 
Private cDesLoc	    := ""
Private cCodPar	    := ""

cMarDef  := "IIf(GPG->GPG_IDPADR =='1','LBTIK','LBNO')"
cCpomark := "GPG_IDPADR"
cCpoNao  := "GPG_IDPADR"
 
If !Pergunte("HSPP09",.T.)
	return
endif

If Empty(mv_par01) 			
	HS_MSGINF("Nenhum setor foi selecionado!","Aten็ใo","Valida็ใo Param. Lab.")//"Nenhum setor foi selecionado!" # "Aten็ใo" # "Validacao Controle de Solicita็๕es"			
	Return
Endif

cCodLoc		:= mv_par01 
cGcsCodLoc	:= mv_par01 
cDesLoc 	:= Alltrim(Posicione('GCS', 1, xFilial('GCS') + cCodLoc, 'GCS_NOMLOC'))

aJoinGA7 := {{" JOIN " + RetSqlName("GM2") + " GM2", "", "GM2.GM2_FILIAL = '" + xFilial("GM2") + "' AND GM2.D_E_L_E_T_ <> '*' AND GM2.GM2_CODPRO = GA7.GA7_CODPRO AND GM2.GM2_CODLOC = '" + cCodLoc + "'", ""},;
			 {" JOIN " + RetSqlName("GAQ") + " GAQ", "GAQ.GAQ_CODLOC", "GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' AND GAQ.GAQ_GRUPRO = GA7.GA7_CODGPP", "GAQ_CODLOC"},;			 
			 {" JOIN " + RetSqlName("GCS") + " GCS1", "GCS1.GCS_NOMLOC", "GCS1.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS1.D_E_L_E_T_ <> '*' AND GCS1.GCS_CODLOC = GAQ.GAQ_CODLOC", "GCS_NOMLOC"}}

 aSize := MsAdvSize()                                          
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
 
	oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4]) //Itens da parametriza็ใo
	oPanel1:Align := CONTROL_ALIGN_BOTTOM 
	
	oPanel2 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oDlgAut,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtros e Procedimentos
	oPanel2:Align := CONTROL_ALIGN_LEFT
	
	oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtro
	oPanel6:Align := CONTROL_ALIGN_TOP
	
	oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // Procedimentos
	oPanel7:Align := CONTROL_ALIGN_ALLCLIENT
	
    oPanel3 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4])// P09
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	                                           
	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS "Meios de Coleta / M้todo / Material Biol๓gico","Associados"
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT 
	
	HS_BDados("GA7", @aHeadProc, @aColsProc,, 1,, "",,,"/",,,,,,.T.,,,,,, aCpoGA7, aJoinGA7)
	nGA7CodProc := aScan(aHeadProc, {|aVet| aVet[2] == "GA7_CODPRO"})
	nGA7DesProc := aScan(aHeadProc, {|aVet| aVet[2] == "GA7_DESC  "})	
	nGAQCodLoc  := aScan(aHeadProc, {|aVet| aVet[2] == "GAQ_CODLOC"})

	aHeadProc[nGAQCodLoc,1] := "Setor Execut"			
		
	oGetProc:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadProc, aColsProc)
	oGetProc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   
	oGetProc:bChange       := {|| FS_AtTela()} 

	//Fitros dos Dados                           
	HS_GDPesqu( , , oGetProc, oPanel6, 001,.T.)

	DbSelectArea("GP9") 
	DbSetOrder(2)                        
	If DbSeek(xFilial("GP9") + oGetProc:aCols[oGetProc:nAt,nGA7CodProc] + cCodLoc) 
		nReg 	:= GP9->(Recno())                                          
		cCodPar := GP9->GP9_CODPAR 
		Inclui 	:= .F.
	Else
		cCodPar := ""
		nReg	:= 0 
		Inclui 	:= .T.
	EndIf

	RegToMemory("GP9",(nReg == 0)) //Gera variavies de memoria para o GPE
	
	oGP9:= MsMGet():New("GP9", nReg, 3,,,,, {aPEnc[2, 1], aPEnc[2, 2], aPEnc[2, 3], aPEnc[2, 4]},,,,,, oPanel3)
	oGP9:oBox:align:= CONTROL_ALIGN_ALLCLIENT	
                
	HS_BDados("GPG", @aHeadMMM, @aColsMMM,@nUGPG, 1,, " GPG.GPG_CODPAR = '" + cCodPar + "' AND GPG.D_E_L_E_T_ <> '*' AND GPG.GPG_FILIAL = '" + xFilial("GPG") + "'",,,,,,,cCpoMark,cMarDef,,,,,,, aCpoMMM,)

	oGetMMM := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,"HS_DuplAC(oGetMMM:oBrowse:nAt, oGetMMM:aCols, {nMMMCodMCO,nMMMCodMAT,nMMMCodMET})",,,,,,,,, oFolder:aDialogs[1], aHeadMMM, aColsMMM)
	oGetMMM:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
	oGetMMM:cFieldOk		:= "FS_LNOKGD(1)"
 	oGetMMM:oBrowse:BlDblClick := {|| FS_DblClk(oGetMMM:oBrowse:nAt)} 
	oGetMMM:oBrowse:BADD       := {|| FS_NovLin()}
                         
	nMMMCodSeq := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODSEQ"}) 
	nMMMCodPar := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODPAR"})  
	nMMMCodMCO := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMCO"})  
	nMMMCodMET := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMET"})  
	nMMMCodMAT := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMAT"})
	nMMMIdPadr := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_IDPADR"})    			

	HS_BDados("GPH", @aHeadASS, @aColsASS,@nUGPH, 1,, " GPH.GPH_CODPAR = '" + cCodPar + "' AND GPH.D_E_L_E_T_ <> '*' AND GPH.GPH_FILIAL = '" + xFilial("GPH") + "'",,,,,,,,,,,,,,, aCpoGPH,)

	oGetASS := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,"HS_DuplAC(oGetASS:oBrowse:nAt, oGetASS:aCols, {nASSCodAss})",,,,,,,,, oFolder:aDialogs[2], aHeadASS, aColsASS)
	oGetASS:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
	oGetASS:cFieldOk		:= "FS_LNOKGD(2)"
 	                         
	nASSCodAss := aScan(aHeadASS, {|aVet| aVet[2] == "GPH_CODASS"}) 
	nASSFatAss := aScan(aHeadASS, {|aVet| aVet[2] == "GPH_FATASS"})  	 

		
	aAdd(aButtons,	{"S4WB001N", {|| FS_GRVLAB()}, "Confirma Altera็๕es","Confirma"})  //
	aAdd(aButtons,	{"EXCLUIR", {|| FS_EXCLAB()}, "Exclui Param.","Exclui"})  //
	Aadd(aButtons	,{'NOTE', {||HS_MntPerg(M->GP9_QSTATE, Nil,, , .T., "PER", "oGP8",, Nil, CONTROL_ALIGN_ALLCLIENT, .T., "G",,.T.),Inclui 	:= .T.}, "Testa Grp Perg.","Grp Perg"}) // "Incluir item da prescri็ใo"##"Inc. Item"  	

	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcAut := 0},,aButtons) 
                                                        
If nOpcAut == 1
	FS_GRVLAB(.T.)
EndIf
                                                     
Return(.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LNOKGD บAutor  ณRogerio Tabosa      บ Data ณ 09/06/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para verificar que foi realizada altera็ใo nos dados บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function FS_LNOKGD(nValid)
Default nValid	:= 1

lAtuDado := .T.

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtTela บ Autor ณ ROGERIO TABOSA     บ Data ณ 16/09/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da GMJ ou GCY        บฑฑ
ฑฑบ          ณ          de acordo com a data escolhida                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParame    ณ	cChave:  chave para pesquisa							  บฑฑ
ฑฑบ			 ณ	nOrd:		 	ordem para pesquisa						  บฑฑ
ฑฑบ			 ณ	cFiltro: Filtro						   					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Controle de Autorizacoes               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Static Function FS_AtTela()


DbSelectArea("GP9") 
DbSetOrder(2)                        
If DbSeek(xFilial("GP9") + oGetProc:aCols[oGetProc:nAt,nGA7CodProc] + cCodLoc)  
	nReg := GP9->(Recno())
	cCodPar := GP9->GP9_CODPAR
	M->GP9_CODPAR := GP9->GP9_CODPAR
	FS_PREVAR()
	Inclui 	:= .F.
Else	
	nReg 	:= 0
	cCodPar	:= ""
	M->GP9_CODPAR := ""
	FS_LMPVAR()   
	Inclui 	:= .T.
EndIf
RegToMemory("GP9",(nReg == 0)) //Gera variavies de memoria para o GPE

oDlgAut:cTitle := cCadastro + Alltrim(cDesLoc) + " - " + oGetProc:aCols[oGetProc:nAt,nGA7CodProc] + "  " + oGetProc:aCols[oGetProc:nAt,nGA7DesProc] 
oGP9:Refresh()
                                               	
aHeadMMM := {}
aColsMMM := {} 
aColsASS := {} 

HS_BDados("GPG", @aHeadMMM, @aColsMMM,@nUGPG, 1,, " GPG.GPG_CODPAR = '" + cCodPar + "' AND GPG.D_E_L_E_T_ <> '*' AND GPG.GPG_FILIAL = '" + xFilial("GPG") + "'",,,,,,,cCpoMark,cMarDef,,,,,,, aCpoMMM,)
nMMMCodSeq := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODSEQ"}) 
nMMMCodMCO := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMCO"})  
nMMMCodMET := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMET"})  
nMMMCodMAT := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMAT"})  
nMMMIdPadr := aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_IDPADR"})

HS_BDados("GPH", @aHeadASS, @aColsASS,@nUGPH, 1,, " GPH.GPH_CODPAR = '" + cCodPar + "' AND GPH.D_E_L_E_T_ <> '*' AND GPH.GPH_FILIAL = '" + xFilial("GPH") + "'",,,,,,,,,,,,,,, aCpoGPH,)
nASSCodAss := aScan(aHeadASS, {|aVet| aVet[2] == "GPH_CODASS"})    
nASSFatAss := aScan(aHeadASS, {|aVet| aVet[2] == "GPH_FATASS"})    
 
oGetMMM:SetArray(aColsMMM)
oGetMMM:oBrowse:Refresh()

oGetASS:SetArray(aColsASS)
oGetASS:oBrowse:Refresh()  

	Inclui 	:= .T.

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVLAB บAutor  ณRogerio Tabosa      บ Data ณ 09/06/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravar os dados das parametriza็๕es             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                       

Static Function FS_GRVLAB(lOk)
Local lAchou 	:= .F.
Local nGD		:= 0

Default lOk 	:= .F.

If Empty(oGetProc:aCols[oGetProc:nAt,nGA7CodProc])
	HS_MSGINF("Selecione o procedimento!","Aten็ใo","Valida็ใo Parametros do Laborat๓rio")
	Return(Nil)
EndIf

Begin Transaction 	 
	DbSelectArea("GP9") 
	DbSetOrder(2)                        
	lAchou := DbSeek(xFilial("GP9") + oGetProc:aCols[oGetProc:nAt,nGA7CodProc] + cCodLoc) 
	
	RecLock("GP9", !lAchou)
		GP9->GP9_FILIAL  := xFilial("GP9")
		HS_GrvCpo("GP9")    		
		GP9->GP9_CODPRO  := oGetProc:aCols[oGetProc:nAt,nGA7CodProc]
		GP9->GP9_CODLOC  := cCodLoc                                   
		If !lAChou .OR. Empty(cCodPar)
			GP9->GP9_CODPAR  := cCodPar := GetSxeNum("GP9", "GP9_CODPAR",, 1)
			 While __lSx8
  				ConfirmSx8()
 			EndDo 		
		EndIf
	MsUnLock()

	For nGD := 1 to Len(oGetMMM:aCols) // CONFIGURACAO PADRAO		 
		If !Empty(oGetMMM:aCols[nGD,nMMMCodMCO]) .AND. !Empty(oGetMMM:aCols[nGD,nMMMCodMET]) .AND. !Empty(oGetMMM:aCols[nGD,nMMMCodMAT]) .AND. !oGetMMM:aCols[nGD,Len(oGetMMM:aHeader)+1]
			If Len(oGetMMM:aCols) == 1
				oGetMMM:aCols[nGD,nMMMIdPadr] := "LBTIK"
			ElseIf aScan(oGetMMM:aCols, {|aVet| aVet[nMMMIdPadr] == "LBTIK"}) == 0
				oGetMMM:aCols[nGD,nMMMIdPadr] := "LBTIK"  
			EndIf
		EndIf
	Next nGD
	//MEIOS DE COLETA / METODO / MATERIAL BIOLOGICO
	For nGD := 1 to Len(oGetMMM:aCols)
		If !Empty(oGetMMM:aCols[nGD,nMMMCodMCO]) .AND. !Empty(oGetMMM:aCols[nGD,nMMMCodMET]) .AND. !Empty(oGetMMM:aCols[nGD,nMMMCodMAT]) .AND. !oGetMMM:aCols[nGD,Len(oGetMMM:aHeader)+1]
			DbSelectArea("GPG") 
			If !Empty(oGetMMM:aCols[nGD,nMMMCodSeq])
				DbSetOrder(6) 
				lAchou := DbSeek(xFilial("GPG") + oGetMMM:aCols[nGD,nMMMCodSeq]) 
			Else
				DbSetOrder(4) 
				lAchou := DbSeek(xFilial("GPG") + cCodPar + oGetMMM:aCols[nGD,nMMMCodMCO] + oGetMMM:aCols[nGD,nMMMCodMET] + oGetMMM:aCols[nGD,nMMMCodMAT]) 			
			EndIf
			RecLock("GPG", !lAchou)
				GPG->GPG_FILIAL  := xFilial("GPG")                          
				GPG->GPG_IDPADR := IIf(oGetMMM:aCols[nGD,nMMMIdPadr] == "LBNO","0","1")				
				GPG->GPG_CODPAR  := cCodPar
				If !lAchou
					GPG->GPG_CODSEQ  := GetSxeNum("GPG", "GPG_CODSEQ",, 5)	
					oGetMMM:aCols[nGD,nMMMCodSeq] := GPG->GPG_CODSEQ			
				EndIf
				GPG->GPG_CODMCO  := oGetMMM:aCols[nGD,nMMMCodMCO]								
				GPG->GPG_CODMET  := oGetMMM:aCols[nGD,nMMMCodMET]
				GPG->GPG_CODMAT  := oGetMMM:aCols[nGD,nMMMCodMAT]
			MsUnLock()
			While __lSx8
  				ConfirmSx8()
 			EndDo 	 
		ElseIf oGetMMM:aCols[nGD,Len(oGetMMM:aHeader)+1]  //Deleta item
			DbSelectArea("GPG") 
			If !Empty(oGetMMM:aCols[nGD,nMMMCodSeq])
				DbSetOrder(6) 
				lAchou := DbSeek(xFilial("GPG") + oGetMMM:aCols[nGD,nMMMCodSeq]) 
			Else
				DbSetOrder(4) 
				lAchou := DbSeek(xFilial("GPG") + cCodPar + oGetMMM:aCols[nGD,nMMMCodMCO] + oGetMMM:aCols[nGD,nMMMCodMET] + oGetMMM:aCols[nGD,nMMMCodMAT]) 			
			EndIf			
			If lAchou
				RecLock("GPG", .F., .F.)
				DbDelete()
				MsUnlock()
				WriteSx2("GPG")
			EndIf
		EndIf
    Next nGD   
    // ASSOCIADOS
	For nGD := 1 to Len(oGetASS:aCols)
		If !Empty(oGetASS:aCols[nGD,nASSCodAss]) .AND. !oGetASS:aCols[nGD,Len(oGetASS:aHeader)+1]
			DbSelectArea("GPH") 
			DbSetOrder(1) 
			lAchou := DbSeek(xFilial("GPH") + cCodPar + oGetASS:aCols[nGD,nASSCodASS] ) 
			RecLock("GPH", !lAchou)
				GPH->GPH_FILIAL  := xFilial("GPH")                          			
				GPH->GPH_CODPAR  := cCodPar
				GPH->GPH_CODASS  := oGetASS:aCols[nGD,nASSCodASS]								
				GPH->GPH_FATASS  := oGetASS:aCols[nGD,nASSFatAss]				
			MsUnLock()	 
		ElseIf oGetASS:aCols[nGD,Len(oGetASS:aHeader)+1]  //Deleta item
			DbSelectArea("GPH") 
			DbSetOrder(1) 
			If DbSeek(xFilial("GPH") + cCodPar +oGetASS:aCols[nGD,nASSCodASS]) 
				RecLock("GPH", .F., .F.)
				DbDelete()
				MsUnlock()
				WriteSx2("GPH")
			EndIf
		EndIf
    Next nGD              
End Transaction

lAtuDado	:= .F.
If !lOk
	HS_MSGINF("Atualiza็ใo salva com sucesso!","Aten็ใo","Valida็ใo Parametros do Laborat๓rio")
	oGetMMM:Refresh()	
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DblClkบ Autor ณ Rogerio Tabosa     บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca configuracao padrao da coleta               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(nMar)
 Local nForACols := 0
                         
 If oGetMMM:aHeader[oGetMMM:oBrowse:nColPos, 2] == "GPG_IDPADR" .AND. !oGetMMM:aCols[nMar,nUGPG+1]
  If oGetMMM:aCols[nMar,nMMMIdPadr] == "LBNO"
   oGetMMM:aCols[nMar,nMMMIdPadr] := "LBTIK"
   For nForACols := 1 to len(oGetMMM:aCols)
    If oGetMMM:aCols[nForACols,nMMMIdPadr] == "LBTIK" .And. nForACols <> nMar
     oGetMMM:aCols[nForACols,nMMMIdPadr] := "LBNO"
     Exit
    Endif 
   Next
  Endif 
 Else
  oGetMMM:EDITCELL( oGetMMM:OBROWSE, oGetMMM:oBrowse:nAt, oGetMMM:oBrowse:nColPos )
 EndIf
 oGetMMM:oBrowse:Refresh()   
 
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_NovLinบ Autor ณ Rogerio Tabosa     บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera nova linha no browse                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_NovLin()
 oGetMMM:lChgField := .F.
 oGetMMM:AddLine()
 oGetMMM:aCols[len(oGetMMM:aCols), nMMMIdPadr] := IIF(len(oGetMMM:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_PREVARบ Autor ณ Rogerio Tabosa     บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Preenche variaveis da memoria no momento da troca de registบฑฑ
ฑฑบ          ณ no grid de procedimentos                                   บฑฑ
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
	M->GP9_KIT 		:= GP9->GP9_KIT
	M->GP9_URGENC	:= GP9->GP9_URGENC
	M->GP9_TMPNOR	:= GP9->GP9_TMPNOR	 
	M->GP9_TMPURG	:= GP9->GP9_TMPURG	 	
	M->GP9_TMPEMG	:= GP9->GP9_TMPEMG	 		
	M->GP9_ANTIBI	:= GP9->GP9_ANTIBI
	M->GP9_NUMAMO	:= GP9->GP9_NUMAMO
	M->GP9_VOLCOL	:= GP9->GP9_VOLCOL
	M->GP9_IMPMBM 	:= GP9->GP9_IMPMBM
	M->GP9_IMCIDM 	:= GP9->GP9_IMCIDM
	M->GP9_QSTATE	:= GP9->GP9_QSTATE 
	M->GP9_MAPA  	:= GP9->GP9_MAPA  
	M->GP9_LAUDO 	:= GP9->GP9_LAUDO
   	M->GP9_FATPRI 	:= GP9->GP9_FATPRI
	M->GP9_LDOUNI 	:= GP9->GP9_LDOUNI       
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_LMPVARบ Autor ณ Rogerio Tabosa     บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Limpa variaveis da memoria no momento da troca de registro บฑฑ
ฑฑบ          ณ no grid de procedimentos                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_LMPVAR()
	M->GP9_KIT 		:= "   "
	M->GP9_URGENC	:= ""
	M->GP9_TMPNOR	:= 0	 
	M->GP9_TMPURG	:= 0	 	
	M->GP9_TMPEMG	:= 0	 		
	M->GP9_ANTIBI	:= ""
	M->GP9_NUMAMO	:= 0
	M->GP9_VOLCOL	:= 0
	M->GP9_IMPMBM 	:= ""
	M->GP9_IMCIDM 	:= ""
	M->GP9_MAPA 	:= "      "
	M->GP9_LAUDO 	:= "      "
   	M->GP9_FATPRI 	:= ""
	M->GP9_LDOUNI 	:= ""	 			
Return   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_EXCLABบ Autor ณ Rogerio Tabosa     บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exclui Parametrizacao do Laboratorio                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_EXCLAB()
Local nGD	:= 0

If !Empty(cCodPar)
	If !MsgYesNo("Deseja realmente excluir a parametriza็ใo?" )//"Jแ existe Cadastro com o mesmo RG e Data de Nascimento com o prontuแrio: "###"  Deseja Continuar?"
    	Return(Nil)
	EndIf
Else 
	HS_MSGINF("Nใo hแ parametriza็ใo para ser excluida!","Aten็ใo","Valida็ใo Parametros do Laborat๓rio")
	Return(Nil)
EndIf	
Begin Transaction
	DbSelectArea("GP9") 
	DbSetOrder(1) 
	If DbSeek(xFilial("GP9") + cCodPar) 
		RecLock("GP9", .F., .F.)
		DbDelete()
		MsUnlock()
		WriteSx2("GP9")
	EndIf
	For nGD := 1 to Len(oGetMMM:aCols)
		DbSelectArea("GPG") 
		DbSetOrder(1) 
		If DbSeek(xFilial("GPG") + cCodPar + oGetMMM:aCols[nGD,nMMMCodMCO] + oGetMMM:aCols[nGD,nMMMCodMET] + oGetMMM:aCols[nGD,nMMMCodMAT]) 
			RecLock("GPG", .F., .F.)
			DbDelete()
			MsUnlock()
			WriteSx2("GPG")
		EndIf
	Next nGD
End Transaction

FS_AtTela()
		
Return

Function HS_RDESGPG(cCodSeq)
Local cDescricao := "" 
If !Empty(cCodSeq)
	cDescricao := Posicione('GPC',1,xFilial('GPC')+Posicione('GPG',6,xFilial('GPG')+cCodSeq,'GPG_CODMAT'),'GPC_DESCRI')
Endif
Return(cDescricao)

Function HS_VLDP09(nVld)
Local aArea := GetArea()
Local lRet := .T.

If nVld == 1
	lRet := HS_VldCSet(&(ReadVar()), "", cGcsTipLoc, "Parametriza็ใo Laborat๓rio") //"Prontuแrio Eletr๔nico"
ElseIf nVld == 2
	DbSelectArea("GM2")
	DbSetOrder(1)
	lRet := DbSeek(xFilial("GM2") + cCodLoc + &(ReadVar()))
ElseIf nVld == 3
	If HS_CountTB("GFS", "GFS_CDQUES = '" + &(ReadVar()) + "' AND GFS_TPQUES IN('1','4','5')")  > 0
		lRet := .T.
	Else
		lRet := .F.
	EndIf
EndIf  

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GTXTLABบ Autor ณ Rogerio Tabosa     บ Data ณ  27/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera TXT com a observa็ใo impressa no relatorio do LAB     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_GTXTLAB() 
Local cEnvServ := GetEnvServer()  
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
Local cNomArq	:= ""
Local cArqNf        := ""   

Private cTxtLab := ""     

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "OBSPROTOCOLOLAB.txt"
Else
	cNomArq := cDirRaiz + "\OBSPROTOCOLOLAB.txt"
EndIf 

cTxtLab := MemoRead(cNomArq)   

FErase(cNomArq)

cArqNf:=fCreate(cNomArq)

//FWrite(cArqNf,cTxtLab)

FS_EMemo("Observa็ใo",.T.,@cTxtLab) 

FWrite(cArqNf,cTxtLab)

FClose(cArqNf)

Return(Nil)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_EMemo บ Autor ณ Rogerio Tabosa     บ Data ณ  10/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre campo memo                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_EMemo( cLabel, lEdit, cTexto)

Local oDlgM, oTexto
Local nPos := 0, nPosCtrl := 0

Default cTexto := ""

lEdit  := IIf(lEdit  == Nil,           .T., lEdit)        
cLabel := IIf(cLabel == Nil,            "", cLabel)

DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE "Observa็ใo Protocolo" PIXEL //"Complemento do Cancelamento"

  @ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
  @ 025, 010 GET oTexto VAR cTexto MEMO When lEdit SIZE 178.64, 051 OF oDlgM PIXEL   

DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (oDlgM:End()) ENABLE OF oDlgM
//DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (lOkCpc := FS_GMemo(cTexto),IIf(lOkCpc,oDlgM:End(),)) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cTexto)),.F.,.T.)                                     


Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณHS_PERMLABณ Autor ณ Rogerio Tabosa        ณ Data ณ04/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Interface Cadastro de Permissao e Assinatura do Laboratorioณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_PERMLAB()

Local oSim, oNao,oDlgPer 
Local nI := 0
Local oAllAcesso
Local cCpoNao		:= "GM1_AUTORI"
Local nCpoS := "XX"
Local aCpoGM1 	:= {"GM1_CODUSU","GM1_CODLOC","GCS_NOMLOC"}
Local aJoinGM1 	:= {}
Local aButtons 	:= {}
Local aCposGbj 	:= {"GBJ_BITMAP"}
Local nOpcPer  	:= 0
Local oBmp

Private oGetGM1, oEncGbj, oFolder
Private aAcesso		:= {}
Private aLocais		:= {}
Private aDadosAux	:= {} //Pos 1 - Local 2- usuario 3 - permissoes 4 - Houve alteracao 5 - CRM
Private oAcesso,oCpoP		:= Nil
Private aHeadGM1 	:= {}, aColsGM1 := {},nUGM1 
Private nGM1NomLoc	:= 0 
Private nGM1CodUsu	:= 0 
Private nGM1CodLoc	:= 0 
Private Inclui 		:= .F.
Private nRegGbj		:= 0   
Private cCrmSel		:= ""

oSim   := LoadBitmap(GetResources(), "BR_VERDE")
oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")

aJoinGM1 := {	{" JOIN " + RetSqlName("GCS") + " GCS", "GCS_NOMLOC"  , " GCS.D_E_L_E_T_ <> '*' AND GCS_TIPLOC IN ('G','H') AND GM1.GM1_CODLOC=GCS.GCS_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' ", "GCS_NOMLOC"}}

PswOrder(1) // indice por ID
PswSeek(__CUSERID, .T.)  // Pesquisa o ID no cadastro de usuario


AADD(aAcesso,{"S","Fase Coleta"})
AADD(aAcesso,{"N","Fase Distribuicao"})
AADD(aAcesso,{"S","Fase Resultado"})
AADD(aAcesso,{"N","Fase Liberacao"})
AADD(aAcesso,{"S","Fase Entrega"})
	
DEFINE MSDIALOG oDlgPer TITLE OemToAnsi("Permiss๕es") FROM 120,000 TO 560,400 OF oMainWnd PIXEL //"Extrato"
                                                          
HS_BDados("GM1", @aHeadGM1, @aColsGM1,@nUGM1, 1,, ""/*" EXISTS (SELECT 1 FROM " + RetSqlName("GCS") +  " GCS WHERE GCS_CODLOC = GM1_CODLOC AND GCS_TIPLOC IN('G','H') AND GCS.D_E_L_E_T_ <> '*' AND GCS_FILIAL = '" + xFilial("GCS") + "') "*/,,,,,cCpoNao,,,,,,,,,,aCpoGM1 ,aJoinGM1,,,)
nGM1NomLoc := aScan(aHeadGM1, {|aVet| aVet[2] == "GCS_NOMLOC"})
nGM1CodLoc := aScan(aHeadGM1, {|aVet| aVet[2] == "GM1_CODLOC"})
nGM1CodUsu := aScan(aHeadGM1, {|aVet| aVet[2] == "GM1_CODUSU"})


If Len(aColsGM1) == 0 
	HS_MSGINF("Nใo existem usuarios atribuidos para setores do Laboratorio!","Aten็ใo","Valida็ใo Permissใo")
	Return(Nil)
Endif

For nI := 1 to Len(aColsGM1)
	DbSelectArea("GM1")
	DbSetorder(1)
	If DbSeek(xFilial("GM1") + aColsGM1[nI,nGM1CodLoc] + aColsGM1[nI,nGM1CodUsu])		
		If Empty(GM1->GM1_PRMLAB)
			AADD(aDadosAux,{aColsGM1[nI,nGM1CodLoc], aColsGM1[nI,nGM1CodUsu], "NNNNN",.F.,""}) // 1-Local,2-Usuario,3-String Acesso,4-Houve Alteracao(.T. ou .F.),5-CRM (Caso for medico)
		Else
			AADD(aDadosAux,{aColsGM1[nI,nGM1CodLoc], aColsGM1[nI,nGM1CodUsu], Alltrim(GM1->GM1_PRMLAB),.F.,""})		
		EndIf
	EndIf
	If Len(aLocais) == 0 
		AADD(aLocais,"Todos")
	Else	
		If (nPos := aScan(aLocais, {|aVet| aVet == aColsGM1[nI,nGM1NomLoc]})) == 0
			AADD(aLocais,aColsGM1[nI,nGM1NomLoc])
		EndIf	
	EndIf
Next nI
FS_VERPROF(@aDadosAux)

 @ 014, 005 MsComboBox oCpoP Var nCpoS Color CLR_BLACK Size 190, 010 Items aLocais On Change(FS_AtuGM1()) Of oDlgPer Pixel
 //oCpoP:nAt := nIndIni

oGetGM1 := MsNewGetDados():New(28, 05, 83, 194, 00,,,,,,,,,,, aHeadGM1, aColsGM1)
oGetGM1:bChange := {|| FS_VERACESS() }
oGetGM1:oBrowse:bGotFocus := {|| FS_VERACESS() }

@ 83, 05 FOLDER oFolder SIZE 190, 130  OF oDlgPer PIXEL PROMPTS "Permiss๕es","Assinatura" //"Coleta" "Intercorrencias"

DbSelectArea("GBJ")
DbGoTo(1)
RegToMemory("GBJ", .F.)
oEncGbj := MsMGet():New("GBJ", nRegGbj, 1,,,, {"GBJ_BITMAP"}, {03, 03, 115, 187},,,,,,oFolder:aDialogs[2] ,,,,,)
//oEnchoi := MsMGet():New("GCD",nReg    ,  ,,,,aVisual,aPObjs[1],,3,,,,oDlgCadastro,,.T.) 
//oEncGbj:AENTRYCTRLS[aScan(oEncGbj:aGets, {| aVet | "GBJ_BITMAP" $ aVet})]:BGOTFOCUS := {||M->GBJ_BITMAP := GBJ->GBJ_BITMAP,oEncGbj:Refresh()}  

//SelectBmp("GBJ_BITMAP",3,"GBJ",cNomeCmp)

@05,10 LISTBOX oAcesso FIELDS HEADER "", "Processos" FIELDSIZES 14,170,15 SIZE 170,085 PIXEL OF oFolder:aDialogs[1] // Processos 
oAcesso:SetArray(aAcesso)
oAcesso:bLine := {|| {If(aAcesso[oAcesso:nAt,1]=="S",oSim,oNao),;
aAcesso[oAcesso:nAt,2]}}
oAcesso:bLDblClick := {|| aAcesso[oAcesso:nAt,1]:=If(aAcesso[oAcesso:nAt,1]=="S","N","S"),;
oAcesso:DrawSelect(),FS_GRVACES()}

@ 95, 035 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of oFolder:aDialogs[1] PIXEL
@ 95, 045 Say "Acesso Negado" Of oFolder:aDialogs[1] PIXEL //"Internacao"

@ 95, 105 BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of oFolder:aDialogs[1] PIXEL
@ 95, 115 Say "Acesso Liberado" Of oFolder:aDialogs[1] PIXEL //"Ambultaorial"

aAdd(aButtons,	{"S4WB001N", {|| FS_GRVACES(.T.)}, "Salva","Salva"})

ACTIVATE MSDIALOG oDlgPer CENTERED ON INIT EnchoiceBar(oDlgPer, {|| nOpcPer := 1, oDlgPer:End() }, {|| oDlgPer:End(),nOpcPer := 0},,aButtons)

If nOpcPer == 1
	FS_GRVACES(.T.)
EndIf


Return()

Static Function FS_VERACESS()
Local cPermissao    := ""
Local nPos			:= 0         

aAcesso := {}

AADD(aAcesso,{"N","Fase Coleta"})
AADD(aAcesso,{"N","Fase Distribuicao"})
AADD(aAcesso,{"N","Fase Resultado"})
AADD(aAcesso,{"N","Fase Liberacao"})
AADD(aAcesso,{"N","Fase Entrega"})

/*If oFolder:nOption == 2 .AND. !lFoco
	If !Empty(M->GBJ_BITMAP)
		DbSelectArea("GBJ")
		DbSetOrder(1)
		If DbSeek(xFilial("GBJ") + aDadosAux[oGetGM1:nAt,5])
			RecLock("GBJ", .F.)
				GBJ->GBJ_BITMAP := M->GBJ_BITMAP
			MsUnLock()
		EndIf
	EndIf
EndIf */

If (nPos := aScan(aDadosAux, {|aVet| aVet[1] == oGetGM1:aCols[oGetGM1:nAt,nGM1CodLoc] .AND. aVet[2] == oGetGM1:aCols[oGetGM1:nAt,nGM1CodUsu]})) > 0
	cPermissao := aDadosAux[nPos,3]
	aAcesso[1,1] := IIf(Empty(Substr(cPermissao, 1 , 1 )),"N",Substr(cPermissao, 1 , 1 ))
	aAcesso[2,1] := IIf(Empty(Substr(cPermissao, 2 , 1 )),"N",Substr(cPermissao, 2 , 1 ))	
	aAcesso[3,1] := IIf(Empty(Substr(cPermissao, 3 , 1 )),"N",Substr(cPermissao, 3 , 1 ))		
	aAcesso[4,1] := IIf(Empty(Substr(cPermissao, 4 , 1 )),"N",Substr(cPermissao, 4 , 1 ))	
	aAcesso[5,1] := IIf(Empty(Substr(cPermissao, 5 , 1 )),"N",Substr(cPermissao, 5 , 1 ))
    
	// Assinatura 
	If !Empty(aDadosAux[nPos,5])
		DbSelectArea("GBJ") 
		DbSetOrder(1)//Filial + CRM
		If DbSeek(xFilial("GBJ") + aDadosAux[nPos,5])  
			oFolder:aDialogs[2]:lActive := .T.			
			nRegGbj := GBJ->(Recno())
			RegToMemory("GBJ",.F.)
			M->GBJ_BITMAP	:= GBJ->GBJ_BITMAP			                                                           
		    oEncGbj:aEntryCtrls[ aScan(oEncGbj:aGets, {| aVet | "GBJ_BITMAP" $ aVet}) ]:LoadBmp(M->GBJ_BITMAP)
			oEncGbj:aEntryCtrls[ aScan(oEncGbj:aGets, {| aVet | "GBJ_BITMAP" $ aVet}) ]:Refresh()
		Else
			oFolder:aDialogs[2]:lActive := .F.
		EndIf
	Else
		oFolder:aDialogs[2]:lActive := .F.	
	EndIf	
	
EndIf

//oAcesso:SetArray(aAcesso)
oAcesso:Refresh()   

Return()


Static Function FS_AtuGM1()
Local aColsAux 	:= {}
Local cLocSel	:= ""
Local nI 		:= 0

If oCpoP:nAt <> 1
	cLocSel := oCpoP:aItems[oCpoP:nAt]
	For nI := 1 To Len(aColsGM1)
		If aColsGM1[nI,nGM1NomLoc] == cLocSel
			AADD(aColsAux,aColsGM1[nI])      
		EndIf
	Next nI
	oGetGM1:SetArray(aColsAux)
	oGetGM1:oBrowse:Refresh() 
Else
	oGetGM1:SetArray(aColsGM1)
	oGetGM1:oBrowse:Refresh() 
EndIf 	

Return()  

Static Function FS_GRVACES(lGrav)
Local nPos 	:= 0 
Local nI 	:= 0

Default lGrav := .F.

If !lGrav
	If (nPos := aScan(aDadosAux, {|aVet| aVet[1] == oGetGM1:aCols[oGetGM1:nAt,nGM1CodLoc] .AND. aVet[2] == oGetGM1:aCols[oGetGM1:nAt,nGM1CodUsu]})) > 0
		aDadosAux[nPos,3] := aAcesso[1,1] + aAcesso[2,1] + aAcesso[3,1] + aAcesso[4,1] + aAcesso[5,1] //Monta String do campo GM1_PRMLAB
		aDadosAux[nPos,4] := .T. // indica que houve atualiza็ใo para esse registro
	EndIf
Else 
	For nI := 1 To Len(aDadosAux)
		DbSelectArea("GM1")
		DbSetOrder(1)
		If aDadosAux[nI,4] .AND. DbSeek(xFilial("GM1") + aDadosAux[nI,1] + aDadosAux[nI,2])
			RecLock("GM1",.F.)
				GM1->GM1_PRMLAB := aDadosAux[nI,3]
			MsUnLock() 
		EndIf			
	Next nI
	/*If !Empty(aDadosAux[oGetGM1:nAt,5])
		DbSelectArea("GBJ")
		DbSetOrder(1)
		If DbSeek(xFilial("GBJ") + aDadosAux[oGetGM1:nAt,5]) .AND. !Empty(M->GBJ_BITMAP)
			RecLock("GBJ", .F.)
				GBJ->GBJ_BITMAP := M->GBJ_BITMAP
			MsUnLock()
		EndIf
	EndIf */
EndIf

Return()
 

Static Function FS_VERPROF(aUser)
Local cRet := ""
Local nI	:= 0

For nI := 1 to Len(aUser)
	PswOrder(2) // indice por Nome
	PswSeek(aUser[nI,2], .T.)  // Pesquisa o ID no cadastro de usuario	
	cRet := HS_IniPadr("SRA", 1, substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1]) , "RA_CODIGO",, .F.)
	If !Empty(cRet)
		DbSelectArea("GBJ")
		DbSetOrder(1)
		If DbSeek(xFilial("GBJ") + cRet)
			If GBJ->GBJ_TIPPRO $ "0/1/2" //0-Medico Interno,1-Medico Cooperado,2-Medico Externo
				aUser[nI,5] := cRet
			EndIf
		EndIf
	EndIf 		
Next nI

Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณHS_LABACESณ Autor ณ Rogerio Tabosa        ณ Data ณ20/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica se o usuario possui acesso a determinado processo ณฑฑ
ฑฑณ          ณ do laboratorio                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
 
Function HS_LABACES(cUsuario, cLocal, cPosPer)
Local lRet 	:= .F.
Local nFase := 0
Local cPerm	:= ""

nFase := Val(cPosPer) + 1

DbSelectArea("GM1")
DbSetorder(1)
If DbSeek(xFilial("GM1") + cLocal + cUsuario)		
	cPerm := IIf(Empty(GM1->GM1_PRMLAB),"NNNNN", GM1->GM1_PRMLAB)
	lRet := (Substr(cPerm, nFase , 1) == "S")
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณHS_ENTRLABณ Autor ณ Rogerio Tabosa        ณ Data ณ18/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Configuracao da Data de Entrega de Resultados de Exames Labณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_ENTRLAB()

Local oSim, oNao,oDlgEnt 
Local nI := 0
Local aButtons 	:= {}
Local nOpcPer  	:= 0
Local cDiasEntr		:= ""

Private oEncGpu
Private aDias		:= {}
Private oDias		:= Nil

Private Inclui 		:= .F.
Private nRegGpu		:= 1

oSim   := LoadBitmap(GetResources(), "BR_VERDE")
oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")

FS_POPGPU()

AADD(aDias,{"N","Domingo"})
AADD(aDias,{"S","Segunda"})
AADD(aDias,{"S","Ter็a"})
AADD(aDias,{"S","Quarta"})
AADD(aDias,{"S","Quinta"})
AADD(aDias,{"S","Sexta"})
AADD(aDias,{"N","Sabado"})

	
DEFINE MSDIALOG oDlgEnt TITLE OemToAnsi("Entrega do Exame") FROM 120,000 TO 430,350 OF oMainWnd PIXEL //"Entrega do Exame"


//@ 83, 05 FOLDER oFolder SIZE 190, 130  OF oDlgEnt PIXEL PROMPTS "Permiss๕es","Assinatura" //"Coleta" "Intercorrencias"

@ 018, 008 TO 50, 170 Label "Data de Libera็ใo de resultados pelo setor" OF oDlgEnt PIXEL

DbSelectArea("GPU")
DbGoTo(1)
RegToMemory("GPU", .F.)
//oGP9	  := MsMGet():New("GP9", nReg   , 3,,,,,               {aPEnc[2, 1], aPEnc[2, 2], aPEnc[2, 3], aPEnc[2, 4]},,,,,, oPanel3)
oEncGpu := MsMGet():New("GPU", nRegGpu, 3,,,,{"GPU_DIALIB"}, {027, 12, 47, 165},,,,,, oDlgEnt ,,,,,)

cDiasEntr := GPU->GPU_DIAUTI


If !Empty(cDiasEntr)
	aDias[1,1] := IIf(Empty(Substr(cDiasEntr, 1 , 1 )),"N",Substr(cDiasEntr, 1 , 1 ))
	aDias[2,1] := IIf(Empty(Substr(cDiasEntr, 2 , 1 )),"S",Substr(cDiasEntr, 2 , 1 ))	
	aDias[3,1] := IIf(Empty(Substr(cDiasEntr, 3 , 1 )),"S",Substr(cDiasEntr, 3 , 1 ))		
	aDias[4,1] := IIf(Empty(Substr(cDiasEntr, 4 , 1 )),"S",Substr(cDiasEntr, 4 , 1 ))	
	aDias[5,1] := IIf(Empty(Substr(cDiasEntr, 5 , 1 )),"S",Substr(cDiasEntr, 5 , 1 ))
	aDias[6,1] := IIf(Empty(Substr(cDiasEntr, 6 , 1 )),"S",Substr(cDiasEntr, 6 , 1 ))
	aDias[7,1] := IIf(Empty(Substr(cDiasEntr, 7 , 1 )),"N",Substr(cDiasEntr, 7 , 1 ))		
EndIf

@ 050, 008 TO 150, 170 Label "Dias Uteis" OF oDlgEnt PIXEL

@059,012 LISTBOX oDias FIELDS HEADER "", "" FIELDSIZES 14,170,15 SIZE 155,080 PIXEL OF oDlgEnt // "Dias" 
oDias:SetArray(aDias)
oDias:bLine := {|| {If(aDias[oDias:nAt,1]=="S",oSim,oNao),aDias[oDias:nAt,2]}}
oDias:bLDblClick := {|| aDias[oDias:nAt,1]:=If(aDias[oDias:nAt,1]=="S","N","S"),;
oDias:DrawSelect()}  

@ 140, 035 BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of oDlgEnt PIXEL
@ 140, 045 Say "Sim" Of oDlgEnt PIXEL //

@ 140, 105 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of oDlgEnt PIXEL
@ 140, 115 Say "Nใo" Of oDlgEnt PIXEL //    

ACTIVATE MSDIALOG oDlgEnt CENTERED ON INIT EnchoiceBar(oDlgEnt, {|| nOpcPer := 1, oDlgEnt:End() }, {|| oDlgEnt:End(),nOpcPer := 0},,)


If nOpcPer == 1
	FS_GRVENTR()
EndIf


Return()
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_GRVENTRณ Autor ณ Rogerio Tabosa        ณ Data ณ21/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava dados da configuracao de entrega do exame            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_GRVENTR()
Local cString := ""

cString := aDias[1,1] + aDias[2,1] + aDias[3,1] + aDias[4,1] +  aDias[5,1] + aDias[6,1] + aDias[7,1]

DbSelectArea("GPU")
DbSetOrder(1)
DbGoTop()
If !Eof()
	RecLock("GPU", .F.)
		GPU->GPU_DIAUTI := cString
		GPU->GPU_DIALIB := M->GPU_DIALIB
	MsUnLock()
EndIf

Return()
   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_POPGPU ณ Autor ณ Rogerio Tabosa        ณ Data ณ21/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Popula a tabela GPU caso a mesma nao tenha nenhum registro ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_POPGPU()

DbSelectArea("GPU")
DbSetOrder(1)
DbGoTop()
If Eof()
	RecLock("GPU", .T.)
		GPU->GPU_DIAUTI := "NSSSSSN"
		GPU->GPU_DIALIB := 0
	MsUnLock()
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณHS_CALENT ณ Autor ณ Rogerio Tabosa        ณ Data ณ21/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula a data de entrega do exame                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_CALENT(cCodPed)
Local aArea := GetArea()
Local dDatEnt 	:= CTOD("")
Local cSql 		:= ""
Local aDatas	:= {}
Local cDiaNao	:= ""


DbSelectArea("GPU")
DbSetOrder(1)
DbGoTop()
If Eof()
	Return(CTOD(""))
Else
	If Substr(GPU->GPU_DIAUTI, 1 , 1 ) == "N"
		cDiaNao += "1"
	EndIf
	If Substr(GPU->GPU_DIAUTI, 2 , 1 ) == "N"
		cDiaNao += "2"
	EndIf 
	If Substr(GPU->GPU_DIAUTI, 3 , 1 ) == "N"
		cDiaNao += "3"
	EndIf
	If Substr(GPU->GPU_DIAUTI, 4 , 1 ) == "N"
		cDiaNao += "4"
	EndIf 
	If Substr(GPU->GPU_DIAUTI, 5 , 1 ) == "N"
		cDiaNao += "5"
	EndIf			 
	If Substr(GPU->GPU_DIAUTI, 6 , 1 ) == "N"
		cDiaNao += "6"
	EndIf	         
	If Substr(GPU->GPU_DIAUTI, 7 , 1 ) == "N"
		cDiaNao += "7"
	EndIf 
EndIf	

cSql := " SELECT GBY_SOLICI, GBY_DATSOL, GBY_PROSOL, GBY_CODLOC, GP9_TMPNOR, GP9_TMPURG, GBY_URGDES "
cSql += " FROM " + RetSqlName("GBY") + " GBY "
cSql += " JOIN " + RetSqlName("GP9") + " GP9 ON GP9.GP9_CODLOC = GBY.GBY_CODLOC AND GP9.GP9_CODPRO=GBY.GBY_PROSOL "
cSql += " AND GP9.D_E_L_E_T_ <> '*' AND GP9.GP9_FILIAL = '" + xFilial("GP9") + "' "
cSql += " WHERE GBY.D_E_L_E_T_ <> '*' AND GBY.GBY_FILIAL = '" + xFilial("GBY") + "' AND GBY.GBY_CODPED = '" + cCodPed + "'"

TCQUERY ChangeQuery(cSql) NEW ALIAS "TMPENT"
   
DbSelectArea("TMPENT")
While !Eof()
	If TMPENT->GBY_URGDES == "0"
		If !Empty(TMPENT->GP9_TMPNOR)
			AADD(aDatas,FS_DATENT(STOD(TMPENT->GBY_DATSOL),TMPENT->GP9_TMPNOR,cDiaNao))
		EndIf
	ElseIf TMPENT->GBY_URGDES == "1"
		If !Empty(TMPENT->GP9_TMPURG)
			AADD(aDatas,FS_DATENT(STOD(TMPENT->GBY_DATSOL),TMPENT->GP9_TMPURG,cDiaNao))
		ElseIf !Empty(TMPENT->GP9_TMPNOR)
			AADD(aDatas,FS_DATENT(STOD(TMPENT->GBY_DATSOL),TMPENT->GP9_TMPNOR,cDiaNao))			
		EndIf	
	EndIf
	DbSkip()
End

If Len(aDatas) > 0
	aSort(aDatas ,,,{|x,y| x > y})
	dDatEnt := aDatas[1]
EndIf 

DbSelectArea("TMPENT")
DbCloseArea()

RestArea(aArea)
Return(dDatEnt) 


Static Function FS_DATENT(dDatSol,nQtdH,cDiasNao)
Local dDatEnt 	:= CTOD("")
Local nDias		:= IIf(nQtdH > 24, IIf(Round(nQtdH/24,0) < nQtdH/24, Round(nQtdH/24,0) + 1 , Round(nQtdH/24,0)),1)
Local nCount	:= 0
                      
dDatEnt	:= dDatSol //+ 1

While nCount < nDias
	If !(Alltrim(Str(Dow(dDatEnt))) $ cDiasNao) .AND. !HS_IsFreeDay(dDatEnt)
		nCount ++
	EndIf
	dDatEnt := dDatEnt + 1
End

Return(dDatEnt)

