#INCLUDE "HSPAHP10.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HSPAHP10 ณ Autor ณ Rogerio Machado Tabosaณ data ณ 15/07/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Laboratorio - Analises Clinicas                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHP10(lNotPerg)
Local cSql			:= "" 

//Private oDlgAut		:= nil 

Private nUGBY    	:= 0
Private nUINT    	:= 0
  
Private Inclui 		:= .T. 

Private lMark1		:= .T.
Private lMark2		:= .T. 
Private nOpcAut		:= 0

Private cMarDef  	:= ""
Private cCpomark  	:= ""
Private aRNs		:= {} 

Private cCadastro  	:= OemToAnsi(STR0001) //"Laborat๓rio"

Private cGcsTipLoc 	:= "GH" // Variavel utilizada pelo fonte HSPFFSXB para listar os setores do tipo
Private cGesTipCan 	:= "1"
Private cCodLoc	    := ""
Private cLocSub	    := "" // Subsetores
Private cGcsCodLoc	:= "" //Variavel de fitro da consulta padrใo de procedimentos 
Private cDesLoc	    := ""
Private nTipAte		:= 0 
Private cTipAte		:= ""
Private cStatus		:= ""  
Private cDescStat	:= ""  

Private cCondUrg	:= ""
Private cCndDatCol	:= ""
Private cCndDatMap	:= "" 
Private cCndDatRes	:= "" 
Private cCndLocSol	:= ""                    

Private cLabDis		:= GetMv("MV_LABDIS",,"")
Private cCodPed	    := ""
Private __cNmMpaInd	:= ""  // Numero do Mapa Individual visualizado no relatorio de impressao do questionario
Private __cNumSolic	:= ""  // Numero da solicitacao (Mapa Individual) visualizado no relatorio de impressao do questionario

Default	lNotPerg	:= .F.

If !lNotPerg
	If !Pergunte("HSPP10",.T.)
		Return
	EndIf
EndIf

cCodLoc		:= mv_par01 
nTipAte		:= mv_par02
cTipAte		:= IIf(nTipAte == 1 ,"1",IIf(nTipAte == 2,"2",IIf(nTipAte == 3 ,"0","") ))//0-Interna็ใo  1-Ambulatorial  2-Pronto Atendimento 3-Atendimento Doacao 
cStatus		:= Alltrim(Str(mv_par03 - 1))
cDescStat	:= IIf(cStatus == "0", STR0002,IIf(cStatus == "1",STR0003,IIf(cStatus == "2",STR0004,Iif(cStatus == "3",STR0005,STR0006)))) //"Coleta" "Distribui็ใo" "Resultado" "Libera็ใo" "Entrega"
nUrgencia	:= mv_par04  

If !HS_LABACES(cUserName, cCodLoc, cStatus)
	HS_MSGINF("Usuแrio nใo tem acesso a fase de " + cDescStat + "",STR0016,STR0017) //"Aten็ใo","Valida็ใo Laborat๓rio"
	Return(Nil)
EndIf

cDesLoc 	:= Alltrim(Posicione('GCS', 1, xFilial('GCS') + cCodLoc, 'GCS_NOMLOC'))

cCondUrg 	:= IIf(nUrgencia == 1, " AND GBY_URGDES = '1' " , IIf(nUrgencia == 2 ," AND GBY_URGDES = '0' " , ""))

If Select("QRYSUB") > 0
	DbSelectArea("QRYSUB")
	DbCloseArea()
EndIf
            
cSql := " SELECT GCS_CODLOC FROM " + RetSqlName("GCS") + " GCS "
cSql += " WHERE GCS_ESTSUP = '" + cCodLoc + "' AND GCS_FILIAL = '" + xFilial("GCS") + "' AND D_E_L_E_T_ <> '*'"

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRYSUB"

If QRYSUB->(Eof())
	cLocSub := "'" + cCodLoc + "'"
Else                      
	cLocSub := cCodLoc + "/"
	While !QRYSUB->(Eof())
        cLocSub += QRYSUB->GCS_CODLOC + "/"
		QRYSUB->(DbSkip())                           
	EndDo
	cLocSub := HS_InSql(cLocSub, 2)
EndIf

If cStatus == "0" //Coleta
	HS_P10COL()
ElseIf cStatus == "1" //Distribuicao
	HS_P10DIS()
ElseIf cStatus == "2" //Resultado
	HS_P10RES()	
ElseIf cStatus == "3" //Libera็ใo
	HS_P10LIB()		
EndIf
                                                    
Return(Nil)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HS_P10COLณ Autor ณ Rogerio Machado Tabosaณ data ณ 21/09/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Laboratorio - Fase Coleta                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_P10COL()

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons 	:= {}
Local cPsqReq	:= Space(TamSx3("GBY_CODPED")[1])
Local oGetReq 
Local nGDOpc1	:= GD_UPDATE
Local nGDOpc2	:= GD_UPDATE 


Private oDlgAut		:= Nil
Private oGDPED  	:= nil
Private oGDEXA  	:= nil
Private oGDINT  	:= nil
Private oFolCol  	:= nil 
Private bKeyF12 := SetKey(VK_F12, {|| FS_REABRE()})

Private aHeadGNJ 	:= {}, aColsGNJ := {}
Private aHeadGBY 	:= {}, aColsGBY := {} 
Private aHeadINT 	:= {}, aColsINT := {}
Private aMemCplCan	:= {} 

Private aCpoGNJ  	:= {}
Private aCpoGBY  	:= {"GBY_PROSOL","GA7_MNEMON","GBY_DESPRO","GBY_DATCOL", "GBY_HORCOL","GBY_CFGMMM","GBY_DESMAT","GBY_SOLICI"}  
Private aCpoAltEx	:= {"GBY_DATCOL", "GBY_HORCOL","GBY_CFGMMM"}
Private aJoinGBY := {{" JOIN " + RetSqlName("GA7") + " GA7", "GA7_MNEMON", "GA7.GA7_CODPRO=GBY.GBY_PROSOL", "GA7_MNEMON"}}
Private aJoinGNJ := {}
Private aCpoINT 	:= {"GBY_PROSOL","GA7_MNEMON","GBY_DESPRO","GBY_MTVCAN","GBY_DESMTV","GBY_CPLCAN","GBY_CFGMMM","GBY_DESMAT","GBY_SOLICI"}  
Private aJoinINT := {{" JOIN " + RetSqlName("GA7") + " GA7", "GA7_MNEMON", "GA7.GA7_CODPRO=GBY.GBY_PROSOL", "GA7_MNEMON"}}

Private nEXAIdMarc  := 0
Private nEXAProSol  := 0
Private nEXASolici  := 0
Private nEXACfgMMM  := 0
Private nEXADESMMM  := 0
Private nEXADATCOL  := 0
Private nEXAHORCOL  := 0  
Private nPEDRegAte	:= 0 
Private nPEDCodSeq	:= 0 
Private nPEDQuarto 	:= 0
Private nPEDLeito 	:= 0
Private nOptFol		:= 1  


If cTipAte == "0" .OR. Empty(cTipAte)
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC","GAV_QUARTO","GAV_LEITO"}  
Else
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC"}  
EndIf

aJoinGNJ := {	{" JOIN " + RetSqlName("GCY") + " GCY", "GCY_NOME"  , " GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE=GNJ.GNJ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' " + IIf(!Empty(cTipAte), " AND GCY.GCY_ATENDI = '" + cTipAte + "'  ", ""), "GCY_NOME"},;
		 		{"" , "GCY.GCY_CODLOC",, "GCY_CODLOC"},;
				{" JOIN " + RetSqlName("GCS") + " GCS", "GCS_NOMLOC"  , " GCS.D_E_L_E_T_ <> '*' AND GCY.GCY_CODLOC=GCS.GCS_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' ", "GCS_NOMLOC"},;//				"GCY_CODLOC,GCY_NOME,GAV_LEITO "
			 	{" LEFT JOIN " + RetSqlName("GAV") + " GAV", "GAV_QUARTO"  , " GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_REGATE=GNJ.GNJ_REGATE AND GAV.GAV_LEITO <> '" + Space(TamSx3("GAV_LEITO")[1]) + "'", "GAV_QUARTO"},;
				{"" , "GAV.GAV_LEITO",, "GAV_LEITO"}}


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
 
 aObjs := {{50, 100, .T., .T.}, ;
           {50, 100, .T., .T.}}     	

 aInfo := {aPPac[1, 2], aPPac[1, 1], aPPac[1, 4], aPPac[1, 3], 0, 0}
 aPFil := MsObjSize(aInfo, aObjs, .T.,.T.)    
 
 
DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cCadastro + " - " + cDesLoc + " - " + cDescStat) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
 
	oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4]) //Itens da parametriza็ใo
	oPanel1:Align := CONTROL_ALIGN_BOTTOM 
	
	oPanel2 := tPanel():New(aPObj[1, 1], aPObj[1, 2],, oDlgAut,,,,,, aPObj[1, 3], aPObj[1, 4]) // Filtros e Procedimentos
	oPanel2:Align := CONTROL_ALIGN_LEFT
	
	oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // Filtro
	oPanel6:Align := CONTROL_ALIGN_TOP         

	oPanel8 := tPanel():New(aPFil[2, 3], aPFil[2, 4],, oPanel6,,,,,, aPFil[2, 3], aPFil[2, 4]) // Filtro
	oPanel8:Align := CONTROL_ALIGN_RIGHT        
	
	oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // Procedimentos
	oPanel7:Align := CONTROL_ALIGN_ALLCLIENT
	
    oPanel3 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4])// P09
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	                                           
	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolCol SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS STR0002,STR0007 //"Coleta" "Intercorrencias"
	oFolCol:Align := CONTROL_ALIGN_ALLCLIENT 
	oFolCol:bChange    := {|| nOptFol := oFolCol:nOption }

	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " GNJ_FILIAL = '" + xFilial("GNJ") + "' AND EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	nPEDCodSeq 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_CODSEQ"})
	nPEDRegAte 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_REGATE"})	
	nPEDDatPed 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_DATPED"}) 
	nPEDNome 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_NOME  "})	
	nPEDCodLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_CODLOC"})
	nPEDNomLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCS_NOMLOC"})	

	If cTipAte == "0" .OR. Empty(cTipAte)
		nPEDQuarto := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_QUARTO"})		
		nPEDLeito := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_LEITO "})		
		FS_TRATRN(@aColsGNJ)
	EndIf
		
	oGDPED:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadGNJ, aColsGNJ)
	oGDPED:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   
	oGDPED:bChange       := {|| FS_AtTela()}  
	oGDPED:oBrowse:bGotFocus  := {|| FS_AtTela()}   	

	//Fitros dos Dados                           
	HS_GDPesqu( , , oGDPED, oPanel6, 001,.T.) 
	
	@001, 105 MSGet oGetReq Var cPsqReq Picture "@!" Size 100, 010 Of oPanel8 Pixel Color CLR_BLACK  
  	oBtnReq := tButton():New(001, 205, STR0008, oPanel8, {|| FS_EFPESQ(cPsqReq)}, 050, 012,,,, .T.)    //"Codigo de Barras"	
	//Exames
	Inclui := .T.
	HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' " + cCondUrg + " AND GBY_STALAB = '" + cStatus + " '",,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
	oGDEXA := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc1,,,,aCpoAltEx,,,,,, oFolCol:aDialogs[1], aHeadGBY, aColsGBY)	
	oGDEXA:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
 	oGDEXA:oBrowse:BlDblClick := {|| FS_DblClk(oGDEXA,oFolCol:nOption)} 	
                         
	nEXAIdMarc := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_IDMARC"}) 
	nEXAProSol := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_PROSOL"}) 	
	nEXASolici := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_SOLICI"}) 	
	nEXACfgMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_CFGMMM"}) 	
	nEXADESMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DESMAT"}) 		
	nEXADATCOL := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DATCOL"}) 		
	nEXAHORCOL := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_HORCOL"}) 			
	
	FS_ATDTCOL()
                         
	//Intercorrencias
	HS_BDados("GBY", @aHeadINT, @aColsINT,@nUINT, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' " + cCondUrg + " AND GBY_STALAB = '" + cStatus + " '",,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoINT ,aJoinINT,,,{"GA7_MNEMON","GBY_CPLCAN"})

	oGDINT := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc2,,,,,,,,,, oFolCol:aDialogs[2], aHeadINT, aColsINT)
	oGDINT:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
 	oGDINT:oBrowse:BlDblClick := {|| FS_DblClk(oGDINT, oFolCol:nOption)}
	oGDINT:oBrowse:bCustomEditCol := {|| FS_DblClk(oGDINT, oFolCol:nOption)} 	 	
                         
	nINTIdMarc := aScan(aHeadINT, {|aVet| aVet[2] == "GBY_IDMARC"}) 
	nINTProSol := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_PROSOL"}) 		
	nINTSolici := aScan(aHeadINT, {|aVet| aVet[2] == "GBY_SOLICI"}) 		
	nINTCplCan := aScan(aHeadINT, {|aVet| aVet[2] == "GBY_CPLCAN"}) 			
	nINTMtvCan := aScan(aHeadINT, {|aVet| aVet[2] == "GBY_MTVCAN"}) 				
			
	aAdd(aButtons,  {"PMSRRFSH", {|| FS_Refresh()}, "Atualiza Tela(F5)","Atualiza"})    //
	aAdd(aButtons,  {"CHECKED", {|| FS_MarcT(IIf(oFolCol:nOption == 1,oGDEXA,oGDINT),nEXAIdMarc,oFolCol:nOption)},  STR0010,STR0009})    //"Todos", "Marcar Todos"
	aAdd(aButtons,	{"S4WB001N", {|| FS_GRVCOL(,oFolCol:nOption)}, STR0011,STR0011})  // "Confirma","Confirma Coleta"
//	aAdd(aButtons,	{"EXCLUIR", {|| FS_EXCCOL()}, "Exclui","Exclui Coleta"})  //"Exclui","Exclui Coleta"
	aAdd(aButtons,	{"S4WB007N", {|| FS_PEDEXA(oGDPED:nAt)}, STR0013,"Ped.Exam."})  //	"Ped. Exames","Pedido Exames"
	aAdd(aButtons,	{"BTPESQ_OCEAN", {|| FS_FILSOL()}, "Filtra Setor","Filtro Setor Solicitante"})  //	"Ped. Exames","Pedido Exames"		
	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcAut := 0},,aButtons) 
                                                        
If nOpcAut == 1
	FS_GRVCOL(.T.,nOptFol)
EndIf

Return(.T.)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ FS_GRVCOLณ Autor ณ Rogerio Machado Tabosaณ data ณ 15/09/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Rotina de Confirmacao e Gravacao da Coleta                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_GRVCOL(lOk, nOptFol)
Local lAchou 	:= .F.
Local nGD		:= 0 
Local lSel		:= .F.

Default lOk 	:= .F.
                             
If nOptFol == 1 // Coleta
	For nGD := 1 To Len(oGDEXA:aCols)
	                                                         
		If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK" 
			lSel := .T.
			Begin Transaction 	 
				DbSelectArea("GBY") 
				DbSetOrder(1)                        
				If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici]) 
				
					RecLock("GBY", .F.)     
					If cCodLoc $ cLabDis .AND. cStatus == "0"
						GBY->GBY_STALAB  := "1" //
					Else
						GBY->GBY_STALAB  := "2"// Envia diretamente para o resultado e pula a distribuicao
					EndIf
					GBY->GBY_CFGMMM := oGDEXA:aCols[nGD,nEXACFGMMM]
					GBY->GBY_DATCOL := oGDEXA:aCols[nGD,nEXADATCOL]					
					GBY->GBY_HORCOL := oGDEXA:aCols[nGD,nEXAHORCOL]
					GBY->GBY_USRCOL	:= cUserName
					MsUnLock() 
				EndIf
			End Transaction
		EndIf
	
	Next nGD
	
	If !lSel .AND. !lOk
		HS_MSGINF(STR0015,STR0016,STR0017) //"Selecione ao menos um item na Aba de Analises Clinicas","Aten็ใo","Valida็ใo Laborat๓rio"
	ElseIf lSel	.AND. !lOk
		HS_MSGINF(STR0018,STR0016,STR0017)//"Exames confirmados com sucesso!","Aten็ใo","Valida็ใo Laborat๓rio"
		aColsGNJ := {}
		HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " GNJ_FILIAL = '" + xFilial("GNJ") + "' AND EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)		
		If cTipAte == "0" .OR. Empty(cTipAte)
			FS_TRATRN(@aColsGNJ)
		EndIf		
		oGDPED:SetArray(aColsGNJ)
		oGDPED:oBrowse:Refresh()  	
		FS_AtTela()
	EndIf
Else  //Intercorrencias 

	For nGD := 1 To Len(oGDINT:aCols)
	
		If oGDINT:aCols[nGD, nINTIdMarc] == "LBTIK" 
			lSel := .T.
			Begin Transaction 	 
				DbSelectArea("GBY") 
				DbSetOrder(1)                        
				If DbSeek(xFilial("GBY") + oGDINT:aCols[nGD,nINTSolici]) 				
					RecLock("GBY", .F.)
						GBY->GBY_MTVCAN  := oGDINT:aCols[nGD,nINTMtvCan]
					MsUnLock()
					nPos := aScan(aMemCplCan, {|aVet | aVet[1] == oGDINT:aCols[nGD,nINTSolici]}) 
					If nPos > 0 				
						MSMM(, TamSx3("GBY_CPLCAN")[1],, aMemCplCan[nPos,2], 1,,, "GBY","GBY_CPLCAN" )
					EndIf 
				EndIf 

			End Transaction
		EndIf
	
	Next nGD
	
	If !lSel .AND. !lOk
		HS_MSGINF(STR0019,STR0016,STR0017) //"Selecione ao menos um item na Aba de Intercorrencias","Aten็ใo","Valida็ใo Laborat๓rio"
	ElseIf lSel	.AND. !lOk
		HS_MSGINF(STR0020,STR0016,STR0017) //"Intercorrencia gravada com sucesso!","Aten็ใo","Valida็ใo Laborat๓rio"
		aColsGNJ := {}
		HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " GNJ_FILIAL = '" + xFilial("GNJ") + "' AND EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)		
		If cTipAte == "0" .OR. Empty(cTipAte)
			FS_TRATRN(@aColsGNJ)
		EndIf		
		oGDPED:SetArray(aColsGNJ)
		oGDPED:oBrowse:Refresh()  	
		FS_AtTela()
	EndIf

EndIf

Return(Nil)  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtTela บ Autor ณ ROGERIO TABOSA     บ Data ณ 16/09/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da GBY               บฑฑ
ฑฑบ          ณ          de acordo com o Numero de pedido escolhido        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Static Function FS_AtTela(cFiltro)
Local nPos 		:= 0
Default cFiltro	:= ""

aColsGBY := {}
aColsINT := {} 

oDlgAut:cTitle := Alltrim(cDesLoc) + " - " + cDescStat +  IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq])," - Pedido: " + oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"")
Inclui := .F.
If (nPos := ASCAN(aRNs,{|aVet| aVet[1] == oGDPED:nAt})) > 0
	cFiltro += " AND GBY.GBY_RESERV = '" + aRNs[nPos,2] + "' "
EndIf

HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' AND GBY_MTVCAN = '" + Space(TamSx3("GBY_CPLCAN")[1]) + "' AND GBY_STALAB = '" + cStatus + "' " + cCondUrg + " " + cFiltro ,,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
HS_BDados("GBY", @aHeadINT, @aColsINT,@nUINT, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' AND GBY_STALAB = '" + cStatus + "' " + cCondUrg  + " " + cFiltro ,,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoINT ,aJoinINT,,,{"GA7_MNEMON","GBY_CPLCAN"})
Inclui := .T.

oGDEXA:SetArray(aColsGBY)
FS_ATDTCOL()
oGDEXA:oBrowse:Refresh()  

oGDINT:SetArray(aColsINT)
oGDINT:oBrowse:Refresh()  


FS_ACPMEMO()

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
Static Function FS_DblClk(oObj,nOptFol)
Local cMark 	:= oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]
Local cCodPar   := ""
Local cCodSeq   := ""
Local cCodMat   := ""
 
If ValType(oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]) == "C" .AND. oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "LBTIK/LBNO"
	oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := IIF(cMark == "LBTIK", "LBNO", "LBTIK")
ElseIf oObj:oBrowse:ColPos == nEXACfgMMM .AND. cStatus $ "012" .AND. nOptFol == 1
	If !Empty(oObj:aCols[oObj:oBrowse:nAt,nEXACfgMMM])
		DbSelectArea("GPG")
		DbSetOrder(6)
		If DbSeek(xFilial("GPG") + 	oObj:aCols[oObj:oBrowse:nAt,nEXACfgMMM])
			cCodPar := GPG->GPG_CODPAR
		EndIf
	Else
		DbSelectArea("GBY") 
		DbSetOrder(1)                        
		If DbSeek(xFilial("GBY") + oObj:aCols[oObj:oBrowse:nAt,nEXASolici]) 
			If !Empty(GBY->GBY_CODLOC) 
				DbSelectArea("GP9")
				DbSetOrder(2)
				If DbSeek(xFilial("GP9") + oObj:aCols[oObj:oBrowse:nAt,nEXAProSol] + GBY->GBY_CODLOC)
					cCodPar := GP9->GP9_CODPAR
				EndIf
			EndIf
		EndIf
	EndIf
		
	If HS_CountTB("GPG", "GPG_CODPAR = '" + cCodPar + "'")  > 1
		aRetMMM := FS_CFGMMM(oObj:aCols[oObj:oBrowse:nAt,nEXACfgMMM],cCodPar)
		cCodSeq := aRetMMM[1]
		cCodMat := aRetMMM[2]
		If cCodSeq <> oObj:aCols[oObj:oBrowse:nAt,nEXACfgMMM] 
			oObj:aCols[oObj:oBrowse:nAt,nEXACfgMMM] := cCodSeq
			oObj:aCols[oObj:oBrowse:nAt, nEXADESMMM] := Posicione("GPC",1,xFilial("GPC")+cCodMat,"GPC_DESCRI")
			lAlterou := .T.					
		EndIf 
	Else	
		HS_MSGINF(STR0021,STR0016,STR0017) //"Nใo hแ configura็ใo de Meio de Coleta / Metodo / Mat. Biologico para este procedimento neste setor"###"Atencao" ### "Pedidos de Exames"
	EndIf
ElseIf cStatus == "0" .AND. IIf(nOptFol == 2,oObj:oBrowse:ColPos == nINTCplCan,.F.)
	FS_EMemo("GBY_CPLCAN",STR0022,oObj:aCols[oObj:oBrowse:nAt,nINTSolici]) //"Complemento do Cancelamento"
ElseIf oObj:oBrowse:ColPos == nEXAProSol
	//Nใo Edita
Else
	oObj:EDITCELL( oObj:OBROWSE, oObj:oBrowse:nAt, oObj:oBrowse:nColPos )
EndIf
 	
oObj:Refresh()
Return(Nil)  
 
Static Function FS_MarcT(oObj, nIdMark,nFolder)    
Local nLin		:= 0 
Default nFolder   := 1

&("lMark" + Alltrim(Str(nFolder))) := !&("lMark" + Alltrim(Str(nFolder)))

For nLin := 1 To Len(oObj:aCols)
	If oObj:aCols[nLin, nIdMark] $ "LBTIK/LBNO"
		oObj:aCols[nLin, nIdMark] := IIF(&("lMark" + Alltrim(Str(nFolder))) , "LBNO", "LBTIK")
	EndIf
Next nLin

oObj:Refresh()

Return(Nil)


Static Function FS_CFGMMM(cCodSeq, cCodPar)

Local aArea := getArea()
Local cSql  := ""
Local cTitulo  := ""
Local cCodigo	:= ""
Local aHeadMMM := {}, aColsMMM := {}, nUGPG := 0, nCFGMMM := 0
Local nOpca := 0, nX := 0
Local aRet  := {"",""} // [1]Codigo Sequencial [2] Codigo Material
Local aCpoMMM  := {"GPG_CODSEQ","GPG_CODMCO","GPG_DESMCO","GPG_CODMET","GPG_DESMET","GPG_CODMAT","GPG_DESMAT"}
Local oGDMMM

Inclui := .F.

HS_BDados("GPG", @aHeadMMM, @aColsMMM,@nUGPG, 1,, " GPG.GPG_CODPAR = '" + cCodPar + "' AND GPG.D_E_L_E_T_ <> '*' AND GPG.GPG_FILIAL = '" + xFilial("GPG") + "'",,,,,,,,,,,,,,, aCpoMMM,)
nCFGMMM :=   aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODSEQ"}) 
nMATMMM :=   aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMAT"}) 
cTitulo := STR0023 //"Selecione Configura็ใo de Meio de Coleta / Metodo / Mat. Biologico  "
  
DEFINE MSDIALOG oDlg TITLE cTitulo From 000, 000 To 300, 500 Of oMainWnd Pixel   
	 
	oGDMMM := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHeadMMM, aColsMMM)
	oGDMMM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
	oGDMMM:oBrowse:BlDblClick := { || nOpca := 1, oDlg:End() }
 		
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{ || nOpca := 1, oDlg:End() },{|| nOpca := 0, oDlg:End()})
	 
If nOpcA == 1
	aRet[1] := oGDMMM:aCols[oGDMMM:nAt, nCFGMMM]
	aRet[2] := oGDMMM:aCols[oGDMMM:nAt, nMATMMM]	
//	Return(aRet)
Else
	aRet[1] :=  cCodSeq
EndIf  

Inclui := .T.
 		
RestArea(aArea)
Return(aRet)




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
Static Function FS_EMemo(cCampo, cLabel, cNroSol, lEdit)
 Local oDlgM, oTexto, cTexto	:= ""
 Local nPos := 0, nPosCtrl := 0

lEdit  := IIf(lEdit  == Nil,           .T., lEdit)        
cLabel := IIf(cLabel == Nil,            "", cLabel)

nPos := aScan(aMemCplCan, {|aVet | aVet[1] == cNroSol}) 

If nPos == 0 
	cTexto := ""
Else
	cTexto := aMemCplCan[nPos,2]
EndIf 

DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE STR0022 PIXEL //"Complemento do Cancelamento"

  @ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
  @ 025, 010 GET oTexto VAR cTexto MEMO When lEdit SIZE 178.64, 051 OF oDlgM PIXEL   

DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (lOkCpc := FS_GMemo(cNroSol,cTexto),IIf(lOkCpc,oDlgM:End(),)) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cTexto)),.F.,.T.)                                     


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GMemo บ Autor ณ Rogerio Tabosa     บ Data ณ  16/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua a grava็ใo do memo no Grid                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Prescricao Medica                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GMemo(cNroSol,cTexto)
Local nPos := 0 , nPosRetP := 0

nPos := aScan(aMemCplCan, {|aVet | aVet[1] == cNroSol}) 

If nPos == 0 
	AADD(aMemCplCan,{cNroSol,cTexto,.F.})
Else
	aMemCplCan[nPos,2] := cTexto
EndIf

Return(.T.)    

Static Function FS_ACPMEMO()
Local nFor 	:= 0
Local cMemo := ""   
Local aArea   := GetArea()                         

If Len(oGDINT:aCols) > 0
	For nFor := 1 to Len(oGDINT:aCols)
		DbSelectArea("GBY") 
		DbSetOrder(1)                        
		If DbSeek(xFilial("GBY") + oGDINT:aCols[nFor,nINTSolici]) 
			Inclui := .F.
			cMemo := E_MSMM(GBY->GBY_CPLCAN) 
			Inclui := .T.
		EndIf                        
		If !Empty(cMemo)
			AADD(aMemCplCan,{oGDINT:aCols[nFor,nINTSolici],cMemo,.F.})
		EndIf
	Next nFor
EndIf                            

RestArea(aArea)
Return()

Static Function FS_EFPESQ(cFiltro)
Local nPosV := 0          

nPosV := aScan(oGDPED:aCols, {|aVet| aVet[nPEDCodSeq] == cFiltro})

//oGDPesq:SetArray(aCPesq)
If nPosV > 0 
	oGDPED:oBrowse:Refresh()
	oGDPED:oBrowse:nAt := nPosV
	oGDPED:oBrowse:SetFocus()
	oGDPED:oBrowse:Refresh()	
	If cStatus == "0"      
		FS_AtTela()
	ElseIf cStatus == "1"
		FS_AtDist()  
	ElseIf cStatus == "2"
		FS_AtResul()		
	ElseIf cStatus == "3"
		FS_AtLiber()				
	EndIf
EndIf
  
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATDTCOLบ Autor ณ Rogerio Tabosa     บ Data ณ  18/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atribui a data e hora da coleta para a atual caso          บฑฑ
ฑฑบ          ณ a mesma esteja em branco para todos os exames              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Prescricao Medica                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FS_ATDTCOL()
Local nLin := 0

For nLin :=1 To Len(oGDEXA:aCols)
	If Empty(oGDEXA:aCols[nLin,nEXADATCOL])
		oGDEXA:aCols[nLin,nEXADATCOL] := dDataBase		
		oGDEXA:aCols[nLin,nEXAHORCOL] := Time()
	EndIf
Next nLin

Return()       


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HS_P10DISณ Autor ณ Rogerio Machado Tabosaณ data ณ 22/09/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Laboratorio - Fase Distribuicao                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_P10DIS()

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons 	:= {}
Local cPsqReq	:= Space(TamSx3("GBY_CODPED")[1])
Local oGetReq 
Local oDatCol

Local nGDOpc1	:= GD_UPDATE
Local nGDOpc2	:= GD_UPDATE

Private dDatCol		:= CTOD("")
Private oDlgAut		:= Nil
Private oGDPED  	:= nil
Private oGDEXA  	:= nil 
Private oChkTod, lChkTod := .F.  
Private bKeyF12 	:= SetKey(VK_F12, {|| FS_REABRE()})
Private bKeyF5 		:= SetKey(VK_F5, {|| FS_REFRESH()})
Private aHeadGNJ 	:= {}, aColsGNJ := {}
Private aHeadGBY 	:= {}, aColsGBY := {} 

Private aCpoGNJ  	:= {}
Private aCpoGBY  	:= {"GBY_PROSOL","GA7_MNEMON","GBY_DESPRO","GBY_DATCOL", "GBY_HORCOL","GBY_CFGMMM","GBY_DESMAT","GBY_SOLICI","GBY_LOCSOL","GBY_NOMSOL"}  
Private aCpoAltEx	:= {"GBY_DATCOL", "GBY_HORCOL","GBY_CFGMMM"}
Private aJoinGBY := {{" JOIN " + RetSqlName("GA7") + " GA7", "GA7_MNEMON", "GA7.GA7_CODPRO=GBY.GBY_PROSOL", "GA7_MNEMON"}}
Private aJoinGNJ := {}
Private cCodPed	    := "" 

Private nEXAIdMarc  := 0
Private nEXAProSol  := 0
Private nEXASolici  := 0
Private nEXACfgMMM  := 0
Private nEXADESMMM  := 0
Private nEXADATCOL  := 0
Private nEXAHORCOL  := 0 

Private nPEDRegAte	:= 0 
Private nPEDCodSeq	:= 0
Private nPEDQuarto 	:= 0
Private nPEDLeito 	:= 0


If cTipAte == "0" .OR. Empty(cTipAte)
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC","GAV_QUARTO","GAV_LEITO"}  
Else
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC"}  
EndIf

aJoinGNJ := {	{" JOIN " + RetSqlName("GCY") + " GCY", "GCY_NOME"  , "GCY.GCY_REGATE=GNJ.GNJ_REGATE AND GCY_FILIAL = '" + xFilial("GCY") + "' " + IIf(!Empty(cTipAte), " AND GCY.GCY_ATENDI = '" + cTipAte + "' ", ""), "GCY_NOME"},;
		 		{"" , "GCY.GCY_CODLOC",, "GCY_CODLOC"},;
				{" JOIN " + RetSqlName("GCS") + " GCS", "GCS_NOMLOC"  , " GCS.D_E_L_E_T_ <> '*' AND GCY.GCY_CODLOC=GCS.GCS_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' ", "GCS_NOMLOC"},;//				"GCY_CODLOC,GCY_NOME,GAV_LEITO "
			 	{" LEFT JOIN " + RetSqlName("GAV") + " GAV", "GAV_QUARTO"  , " GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_REGATE=GNJ.GNJ_REGATE AND GAV.GAV_LEITO <> '" + Space(TamSx3("GAV_LEITO")[1]) + "'", "GAV_QUARTO"},;
				{"" , "GAV.GAV_LEITO",, "GAV_LEITO"}}  
				
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
 
 aObjs := {{13, 100, .T., .T.}, ;
           {87, 100, .T., .T.}}     	

 aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
 aPExa := MsObjSize(aInfo, aObjs, .T.,.T.) 
 
 aObjs := {{50, 100, .T., .T.}, ;
           {50, 100, .T., .T.}}     	

 aInfo := {aPPac[1, 2], aPPac[1, 1], aPPac[1, 4], aPPac[1, 3], 0, 0}
 aPFil := MsObjSize(aInfo, aObjs, .T.,.T.)    
 
 
DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cDesLoc + " - " + cDescStat) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
 

	oPanel9 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4]) // Filtros e PEDIDOS
	oPanel9:Align := CONTROL_ALIGN_BOTTOM
	
	oPanel1  := tPanel():New(aPExa[2, 1], aPExa[2, 2],, oPanel9,,,,,, aPExa[2, 3], aPExa[2, 4]) //EXAMES GBY
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT 

	oPanel10  := tPanel():New(aPExa[1, 1], aPExa[1, 2],, oPanel9,,,,,, aPExa[1, 3], aPExa[1, 4]) //CANCELA EXAME E COLETA	
	oPanel10:Align := CONTROL_ALIGN_TOP 
	
	oPanel2 := tPanel():New(aPObj[1, 1], aPObj[1, 2],, oDlgAut,,,,,, aPObj[1, 3], aPObj[1, 4]) // Filtros e PEDIDOS
	oPanel2:Align := CONTROL_ALIGN_TOP

	oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // FiltroS
	oPanel6:Align := CONTROL_ALIGN_TOP         

	oPanel8 := tPanel():New(aPFil[2, 3], aPFil[2, 4],, oPanel6,,,,,, aPFil[2, 3], aPFil[2, 4]) // COD BARRAS
	oPanel8:Align := CONTROL_ALIGN_RIGHT        
	
	oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // PEDIDOS GNJ
	oPanel7:Align := CONTROL_ALIGN_ALLCLIENT
	
    oPanel3 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4])// P09
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	                                           
	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS "Exames" 
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT 

	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	nPEDCodSeq 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_CODSEQ"})
	nPEDRegAte 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_REGATE"})	
	nPEDDatPed 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_DATPED"}) 
	nPEDNome 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_NOME  "})
	nPEDCodLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_CODLOC"})	
	nPEDNomLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCS_NOMLOC"})		
	
	If cTipAte == "0" .OR. Empty(cTipAte)
		nPEDQuarto := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_QUARTO"})		
		nPEDLeito := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_LEITO "})		
		FS_TRATRN(@aColsGNJ)
	EndIf
		
	oGDPED:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadGNJ, aColsGNJ)
	oGDPED:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   
	oGDPED:bChange       := {|| FS_AtDist()} 
	oGDPED:oBrowse:bGotFocus  := {|| FS_AtDist()}

	//Fitros dos Dados                           
	HS_GDPesqu( , , oGDPED, oPanel6, 001,.T.) 
	

  	@003, 035 Say "Dat. Col." Of oPanel8 Pixel COLOR CLR_BLUE // 
	@001, 060 MSGet oDatCol Var dDatCol Picture "@D" Size 50, 010 Of oPanel8 Pixel Color CLR_BLACK    	
  	oBtnFCol := tButton():New(001, 110, "Filtrar", oPanel8, {|| FS_FLDTCOL(dDatCol)}, 025, 012,,,, .T.)  
	
	@001, 150 MSGet oGetReq Var cPsqReq Picture "@!" Size 60, 010 Of oPanel8 Pixel Color CLR_BLACK  
  	oBtnReq := tButton():New(001, 205, STR0008, oPanel8, {|| FS_EFPESQ(cPsqReq)}, 050, 012,,,, .T.)    //"Codigo de Barras"
	
	//Exames
	Inclui := .T.
	HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' " + cCondUrg + " AND GBY_STALAB = '" + cStatus + " '",,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
	oGDEXA := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc1,,,,aCpoAltEx,,,,,, oFolder:aDialogs[1], aHeadGBY, aColsGBY)		
	oGDEXA:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
 	oGDEXA:oBrowse:BlDblClick := {|| FS_DblClk(oGDEXA,1)} 	
                         
	nEXAIdMarc := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_IDMARC"}) 
	nEXAProSol := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_PROSOL"}) 	
	nEXASolici := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_SOLICI"}) 	
	nEXACfgMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_CFGMMM"}) 	
	nEXADESMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DESMAT"}) 		
	nEXADATCOL := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DATCOL"}) 		
	nEXAHORCOL := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_HORCOL"}) 			

	@ 000, 015 TO 018, 135 Label "" OF oPanel10 PIXEL
  	oBtnIMap := tButton():New(003, 020,"Imprime Mapa", oPanel10, {|| FS_IMPMAPA(lChkTod)}, 050, 012,,,, .T.)    //"Impr Mapa"	
	oChkTod := tCheckBox():New(003,075,"Todas Requisi็๕es",{|u|if( pcount()>0,lChkTod:=u,lChkTod)},oPanel10,060,010,,/*{||FS_DESMARCA()}*/,,,,,,.T.)  //"Todos"

  	oBtnCExa := tButton():New(001, 200, "Cancela Exames", oPanel10, {|| FS_CANEXA()}, 050, 012,,,, .T.)    //"Cancela Exames"
  	oBtnCCol := tButton():New(001, 260, "Cancela Coleta", oPanel10, {|| FS_CANCOL()}, 050, 012,,,, .T.)    //"Cancela Coleta"
	//HS_GDPesqu( , , oGDEXA, oPanel10, 001,.T.) 
			
	aAdd(aButtons,  {"PMSRRFSH", {|| FS_Refresh()}, "Atualiza Tela(F5)","Atualiza"})    //"Todos", "Marcar Todos"
	aAdd(aButtons,  {"CHECKED", {|| FS_MarcT(oGDEXA,nEXAIdMarc)}, STR0010,STR0009})    //"Todos", "Marcar Todos"
	aAdd(aButtons,	{"S4WB001N", {|| FS_GRVDIS()}, "Salva","Salva"})  // "Confirma","Confirma Coleta"
//	aAdd(aButtons,	{"EXCLUIR", {|| FS_EXCCOL()}, "Exclui","Exclui Coleta"})  //"Exclui","Exclui Coleta"
	aAdd(aButtons,	{"S4WB007N", {|| FS_PEDEXA(oGDPED:nAt)}, "Pedido Exames","Ped. Exam."})  //	"Ped. Exames","Pedido Exames"
	aAdd(aButtons,	{"BTPESQ_OCEAN", {|| FS_FILSOL()}, "Filtro Setor Solicitante","Filt Setor"})  //	"Ped. Exames","Pedido Exames"	
	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcAut := 0},,aButtons) 
                                                        
If nOpcAut == 1
	FS_GRVDIS(.T.)
EndIf

Return(Nil)

Static Function FS_AtDist(cFiltro)
Local aArea := GetArea()
Local nPos	:= 0

Default cFiltro := ""

aColsGBY := {}

oDlgAut:cTitle := Alltrim(cDesLoc) + " - " + cDescStat +   IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq])," - Pedido: " + oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"")
Inclui := .F.      
If (nPos := ASCAN(aRNs,{|aVet| aVet[1] == oGDPED:nAt})) > 0
	cFiltro += " AND GBY.GBY_RESERV = '" + aRNs[nPos,2] + "' "
EndIf

HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' AND GBY_MTVCAN = '" + Space(TamSx3("GBY_CPLCAN")[1]) + "' AND GBY_STALAB = '" + cStatus + "' " + cCondUrg + cCndDatCol + " " + cFiltro ,,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
Inclui := .T.

oGDEXA:SetArray(aColsGBY)
oGDEXA:oBrowse:Refresh()  
RestArea(aArea)
Return()

Function HS_VLDP10(nVld)
Local aArea := GetArea()
Local lRet := .T.  
Local cCampo	:= ReadVar()

If nVld == 1 // SETOR DO GRUPO DE PERGUNTAS
	lRet := HS_VldCSet(&(ReadVar()), "", cGcsTipLoc, "Analises Clinicas") //"Prontuแrio Eletr๔nico"
ElseIf nVld == 2 // DATA DA COLETA
	If "GBY_DATCOL" $ cCampo .AND. Type("oGDPED") <> "U"
		If &(cCampo) < oGDPED:aCols[oGDPED:nAt, nPEDDatPed]
			HS_MsgInf("A data/hora nใo pode ser anterior a do pedido!",STR0016,STR0017) //"A data/hora nใo pode ser anterior a do pedido!"###"Aten็ใo"### "Validacao Laboratorio"
			lRet := .F.
		EndIf
	EndIf 
ElseIf nVld == 3 // MOTIVO DE CANCELAMENTO
	If "GBY_MTVCAN" $ cCampo
		If HS_CountTB("GES", "GES_CODIGO  = '" + &(cCampo) + "' AND GES_TIPO = '1' ")  == 0
			HS_MsgInf("Motivo de Cancelamento Invalido!",STR0016,STR0017) //"A data/hora nใo pode ser anterior a do pedido!"###"Aten็ใo"### "Validacao Laboratorio"
			lRet := .F.			                      
		EndIf
	EndIf
ElseIf nVld == 4 // DATA DO MAPA
	If "GBY_DATMAP" $ cCampo .AND. Type("oGDPED") <> "U"
		If &(cCampo) < oGDPED:aCols[oGDPED:nAt, nPEDDatPed]
			HS_MsgInf("A data nใo pode ser anterior a do pedido!",STR0016,STR0017) //"A data/hora nใo pode ser anterior a do pedido!"###"Aten็ใo"### "Validacao Laboratorio"
			lRet := .F.
		EndIf
	EndIf 	 
ElseIf nVld == 5
	DbSelectArea("GM1")
	DbSetOrder(1)		
	If !(lRet := DbSeek(xFilial("GM1") + MV_PAR01 + cUserName))
		HS_MsgInf("Usuario sem permissao para acessar o local!", STR0016,STR0017) //"Usuario sem permissao para acessar o local de atendimento "###"Atencao"###"Validacao Laboratorio"
	EndIf
EndIf   

	

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ FS_GRVCOLณ Autor ณ Rogerio Machado Tabosaณ data ณ 15/09/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Rotina de Confirmacao e Gravacao da Coleta                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_GRVDIS(lOk)
//Local lAchou 	:= .F.
Local nGD		:= 0 
Local lSel		:= .F.

Default lOk 	:= .F.
                             

For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.
		Begin Transaction
		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
			RecLock("GBY", .F.)
				GBY->GBY_CFGMMM := oGDEXA:aCols[nGD,nEXACFGMMM]
				GBY->GBY_DATCOL := oGDEXA:aCols[nGD,nEXADATCOL]					
				GBY->GBY_HORCOL := oGDEXA:aCols[nGD,nEXAHORCOL]
			MsUnLock()
		EndIf
		End Transaction
	EndIf
	
Next nGD

If !lSel .AND. !lOk
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel	.AND. !lOk
	HS_MSGINF("Altera็๕es salvas com sucesso!",STR0016,STR0017)//"Altera็๕es salvas com sucesso!","Aten็ใo","Valida็ใo Laborat๓rio"
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatCol + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_AtDist()
EndIf

Return(Nil)  


Static Function FS_FILSOL(lExecut)

Local aArea   := GetArea() 
Local cSql		:= ""
Local aSetor	:= {}		// Vetor utilizado para trazer os setores
Local nOpcI		:= 2
Local nLin		:= 0
Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local cTitulo	:= ""
Local nRecno	:= 0
Local aOrd		:= {'C๓digo', 'Descri็ใo'}
Local cCombo	:= aOrd[1]
Local cCond		:= Space(40)
Local oButton
Local oCombo 
Local oCond
Local cStrRet	:= ""
Default	lExecut	:= .F.

cTitulo := IIf(lExecut,"Consulta Setores Executantes","Consulta Setores Solicitantes")

cSql := "SELECT GCS.GCS_CODLOC, GCS.GCS_NOMLOC, GCS.R_E_C_N_O_ REGPOS FROM " + RetSqlName("GCS") + " GCS"
cSql += " WHERE GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
cSql += " AND GCS_CODLOC IN( "  
If lExecut
	cSql += " SELECT GBY.GBY_CODLOC FROM " + RetSqlName("GBY") + " GBY "
	cSql += " WHERE GBY_FILIAL = '" + xFilial("GBY") + "' AND GBY.D_E_L_E_T_ <> '*'" 
	cSql += " AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + ")"
Else
	cSql += " SELECT GBY.GBY_LOCSOL FROM " + RetSqlName("GBY") + " GBY "
	cSql += " WHERE GBY_FILIAL = '" + xFilial("GBY") + "' AND GBY.D_E_L_E_T_ <> '*'" 
	cSql += " AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + ")"
EndIf

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "TMPLOC"

DbSelectArea("TMPLOC")		

If TMPLOC->(!Eof())
	TMPLOC->(DbGoTop())
	While TMPLOC->(!Eof())
		Aadd( aSetor, 	{lMark, ;
						 TMPLOC->GCS_CODLOC,;
						 TMPLOC->GCS_NOMLOC,;
						 TMPLOC->REGPOS})
		TMPLOC->(DbSkip())
	End
	//+-----------------------------------------------+
	//| Monta a tela para usuario visualizar consulta |
	//+-----------------------------------------------+
	If Len( aSetor ) == 0
		Aviso( cTitulo, "Nใo existem setores a consultar", {"Ok"} )
		Return(.F.)
	Endif
				
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 320,500 PIXEL
	
	oCombo 	:= tComboBox():New(10, 10, {|x| If(PCount() > 0, cCombo := x, cCombo)}, aOrd, 100, 20, oDlg, , {|| FS_MudaOrd(cCombo, @aSetor, @oLbx)},,,,.T.,,,,,,,,,'cCombo')
	@ 25, 10 MSGET oCond VAR cCond PICTURE "@!" SIZE 180, 10 VALID .T. OF oDlg PIXEL
	oButton := tButton():New(25, 195, 'Pesquisar', oDlg, {|| FS_PSQLOC(cCombo, cCond, @aSetor, @oLbx)}, 45, 12, , , , .T.)// /*.F. Caracter .T. pixel*/, /*Reservado*/, /*Reservado*/, /*Reservado*/, /*Bloco de Codigo*/, /*Reservado*/, /*Reservado*/)
	
	@ 40,10 LISTBOX oLbx FIELDS HEADER ;
	" ", "C๓digo", "Descri็ใo" ;
	SIZE 230,095 OF oDlg PIXEL ON DblClick(/*aEval( aSetor,{ |x| x[1] := .F. } ),*/aSetor[oLbx:nAt,1] := IIf(aSetor[oLbx:nAt,1],.F.,.T.) ,oLbx:Refresh() )
				
	oLbx:SetArray( aSetor )
	oLbx:bLine := {|| {Iif(aSetor[oLbx:nAt,1],oOk,oNo),;
						    aSetor[oLbx:nAt,2],;
						    aSetor[oLbx:nAt,3]}}
	
	DEFINE SBUTTON FROM 137,183 TYPE 1 ACTION {|| nRecno := FS_SelLoc(aSetor),nOpcI := 1, oDlg:End()} ENABLE OF oDlg	//Ok
	DEFINE SBUTTON FROM 137,213 TYPE 2 ACTION {|| nOpcI  := 2, oDlg:End()} ENABLE OF oDlg								//Cancelar
	ACTIVATE MSDIALOG oDlg CENTER
				
	If nOpcI == 1
		For nLin := 1 to Len(aSetor)
			If aSetor[nLin,1]
				cStrRet += aSetor[nLin,2] + "/"
			EndIf
		Next nLin
	EndIf
EndIf

If !Empty(cStrRet)
	aColsGNJ := {}
	cStrRet := " AND " + Iif(lExecut," GBY_CODLOC "," GBY_LOCSOL ") + " IN (" + Hs_InSql(cStrRet,2) + ") "	
	cCndLocSol := cStrRet
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS ( SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cStrRet +  " " + cCondUrg + IIf(cStatus == "2",cCndDatMap,cCndDatCol) + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf	
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	If cStatus == "0"
		FS_AtTela(cStrRet)
	ElseIf cStatus == "1"
		FS_AtDist(cStrRet)
	ElseIf cStatus == "2"
		FS_AtResul(cStrRet)	
	ElseIf cStatus == "3"
		FS_AtLiber(cStrRet)			
	EndIf
Else
	cCndLocSol := ""
EndIf

DbSelectArea("TMPLOC")
DbCloseArea()

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PSQLOC บAutor  ณDarcio Sporl        บ Data ณ  12/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada, para localizar o setor                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PSQLOC(cCombo, cCond, aProc, oLbx)
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local nPosCond	:= 1
Local cTitulo	:= "Pesquisa Setor"

If cCombo == "Descri็ใo"
	nPosCond := aScan(aProc, {|x| SubStr(x[3],1,Len(AllTrim(cCond))) == AllTrim(cCond)})//aScan(aProc, {|x| x[3] $ cCond})
Else
	nPosCond := aScan(aProc, {|x| SubStr(x[2],1,Len(AllTrim(cCond))) == AllTrim(cCond)})
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza browse...                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nPosCond > 0
	oLbx:nAt := nPosCond
	
	oLbx:SetArray(aProc)
	oLbx:bLine := {|| {Iif(aProc[oLbx:nAt,1],oOk,oNo),;
							aProc[oLbx:nAt,2],;
							aProc[oLbx:nAt,3]}}
	oLbx:Refresh()
	oLbx:SetFocus()
Else
	Aviso( cTitulo, "Nใo existem setores a consultar", {"Ok"} )
	Return
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MudaOrdบAutor  ณDarcio Sporl        บ Data ณ  12/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada, para mudar a ordem da consulta padrao de     บฑฑ
ฑฑบ          ณsetor                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MudaOrd(cCombo, aProc, oLbx)
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

If cCombo == "Descri็ใo"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ordena em ordem alfabetica....                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aProc := aSort(aProc,,,{|x,y| x[3] < y[3]})
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ordena em ordem de codigo....                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aProc := aSort(aProc,,,{|x,y| x[2] < y[2]})
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza browse...                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oLbx:nAt := 1

oLbx:SetArray(aProc)
oLbx:bLine := {|| {Iif(aProc[oLbx:nAt,1],oOk,oNo),;
						aProc[oLbx:nAt,2],;
						aProc[oLbx:nAt,3]}}
oLbx:Refresh()
oLbx:SetFocus() 
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SelLoc บAutor  ณDarcio Sporl        บ Data ณ  09/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para selecionar o setor solicitante, que      บฑฑ
ฑฑบ          ณdevera ser retornado na tela para o usuario.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SelLoc(aProc)
Local i		:= 0
Local nRet	:= 0

Default aProc := {}
		
For i := 1 to Len(aProc)
	If aProc[i][1] == .T.
		nRet := aProc[i][4]		// Recno
		Exit
	EndIf
Next

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CANCOL บAutor  ณRogerio Tabosa      บ Data ณ  23/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para cancelar a coleta dos exames selecionadosบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CANCOL()
//Local lAchou 	:= .F.
Local nGD		:= 0 
Local lSel		:= .F.                             

For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.
		Begin Transaction
			DbSelectArea("GBY")
			DbSetOrder(1)
			If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
				RecLock("GBY", .F.)
					GBY->GBY_STALAB  := "0" 
					GBY->GBY_DATCOL  := CTOD("")//Space(TamSx3("GBY_DATCOL")[1])
					GBY->GBY_HORCOL  := Space(TamSx3("GBY_HORCOL")[1])
					GBY->GBY_USRCOL  := Space(TamSx3("GBY_USRCOL")[1])					
  		 			GBY->GBY_LGCANC := HS_LogArq()  					
				MsUnLock()

		    Endif
		End Transaction 
	
	EndIf
	
Next nGD

If !lSel 
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel
	HS_MSGINF("Coleta cancelada!",STR0016,STR0017)//"Coleta cancelada!","Aten็ใo","Valida็ใo Laborat๓rio"
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatCol + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_AtDist()
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CANEXA บAutor  ณRogerio Tabosa      บ Data ณ  23/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para cancelar os exames selecionados		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CANEXA()                          

Local aArea 	:= GetArea()
Local oDlgMot, oMotivo,  oDesMot, nOpcA := 0, nGD := 0
Local cCadastro := "Cancelamento de Exame" //"Cancelamento de Exame"
Local cCodMot  	:= CriaVar("GBY_MTVCAN")
Local cDesMot  	:= Space(TamSx3("GES_DESCRI")[1]) 
Local aCodMot  	:= HS_CfgSx3("GBY_MTVCAN")
Local lSel		:= .F.
	
DEFINE MSDIALOG oDlgMot TITLE cCadastro From 09, 00 to 16, 80 of oMainWnd
@ 025, 015 Say aCodMot[SX3->(FieldPos("X3_TITULO"))] Of oDlgMot Pixel COLOR CLR_BLUE
@ 023, 032 MsGet oMotivo VAR cCodMot VALID FS_VldMot(cCodMot, @cDesMot) F3 aCodMot[SX3->(FieldPos("X3_F3"))] Picture aCodMot[SX3->(FieldPos("X3_PICTURE"))] OF oDlgMot Pixel
@ 023, 072 MsGet oDescri VAR cDesMot OF oDlgMot Pixel
oDescri:lReadOnly := .T.
ACTIVATE MSDIALOG oDlgMot CENTERED ON INIT EnchoiceBar(oDlgMot,	{|| nOpcA := 1, oDlgMot:End()}, ;
{|| nOpcA := 0, oDlgMot:End()})

If nOpcA == 0
	Return .T.
Else
	For nGD := 1 To Len(oGDEXA:aCols)
		
		If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
			If !lSel
				If !MsgYesNo("Confirma o cancelamento do(s) exame(s) selecionado(s)?",STR0016) 
					RestArea(aArea)
					Return()
				EndIf
			EndIf
			lSel := .T.
			Begin Transaction
				DbSelectArea("GBY")
				DbSetOrder(1)
				If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
					RecLock("GBY", .F.)
					GBY->GBY_MTVCAN  := cCodMot 
					GBY->GBY_LGCANC := HS_LogArq()
					MsUnLock()
			    Endif
			    If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])
					RecLock("GBY", .F., .F.)
					DbDelete()
					MsUnLock()             
					WriteSx2("GBY")
				EndIf
			End Transaction 		
		EndIf		
	Next nGD
	If !lSel
		HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
	Else 
		HS_MSGINF("Exame(s) cancelado(s)!",STR0016,STR0017)//"Exame(s) cancelado(s)!","Aten็ใo","Valida็ใo Laborat๓rio"
		aColsGNJ := {}
		If cStatus = "1"
			HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatCol + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
			If cTipAte == "0" .OR. Empty(cTipAte)
				FS_TRATRN(@aColsGNJ)
			EndIf
			oGDPED:SetArray(aColsGNJ)
			oGDPED:oBrowse:Refresh()
			FS_AtDist()		
		ElseIf cStatus == "2"
			FS_Refresh()
		EndIf
	EndIf		
EndIf    

RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldMot บ Autor ณ Gilson dA sILVA    บ Data ณ 23/05/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida Motivo de Cancelamento                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldMot(cCodigo, cDescricao)
Local lRet := .T.
Local aArea := GetArea()

If Empty(cCodigo)
	HS_MsgInf("Codigo do Motivo de Cancelamento Invalido.", "Aten็ใo", "Cancelamento de Exame") //
	RestArea(aArea)
	Return(.F.)
EndIf 	

DbSelectArea("GES")
DbSetOrder(1)
If !(DbSeek(xFilial("GES") + cCodigo))
	HS_MsgInf("Motivo de Cancelamento nใo encontrado", "Aten็ใo", "Cancelamento de Exame") //
	lRet := .F.                       
Else
 cDescricao := GES->GES_DESCRI
Endif
RestArea(aArea)
Return lRet

Static Function FS_FLDTCOL(dDatCol)
Local aArea := GetArea()

If !Empty(dDatCol)
	cCndDatCol := " AND GBY_DATCOL = '" + DTOS(dDatCol) + "' "
Else
	cCndDatCol := ""
EndIf

aColsGNJ := {}
HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatCol + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
If cTipAte == "0" .OR. Empty(cTipAte)
	FS_TRATRN(@aColsGNJ)
EndIf
oGDPED:SetArray(aColsGNJ)
oGDPED:oBrowse:Refresh()
FS_AtDist()

RestArea(aArea)
Return()
//	HSPRQUES("GPI", "GPI_CDEXAM", "000000",cQueste,oGDGNJ:aCols[oGDGNJ:nAt, nPEDRegAte]) // Imprime vazio
Static Function FS_IMPMAPA(lGeral)
Local cCodPed 	:= ""
Local cCodPar 	:= ""
Local aMapaG	:= {}
Local aMapaInd	:= {}
Local aHeadExa	:= {}
Local aColsExa	:= {}
Local aCfgExa	:= {}
Local cNumMapa	:= ""
Local nPos,nGD	:= 0
Local nGD2		:= 0

Default lGeral := .F.

If Empty(oGDPED:aCols[oGDPED:nAt, nPEDCodSeq])
	HS_MSGINF("Nใo itens para a impressใo do Mapa com o filtro atual!",STR0016,STR0017)
	Return(Nil)
EndIf	

If !lGeral 
	nPos := aScan(oGDEXA:aCols, {|aVet| aVet[nEXAIdMarc] == "LBTIK"})
	If nPos == 0
		HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"   
		Return(Nil)
	Else
		For nGD := 1 To Len(oGDEXA:aCols)		
			If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK" .OR. nPos == 0
				AADD(aCfgExa, FS_RTCFGEX(oGDEXA:aCols[nGD,nEXAProSol], oGDEXA:aCols[nGD,nEXASolici]))
			EndIf
		Next nGD
	EndIf
Else 
	If !MsgYesNo("Deseja realmente imprimir o Mapa para todas as requisi็๕es filtradas?",STR0016) 
		Return(Nil)
	EndIf
	For nGD := 1 To Len(oGDPED:aCols)
		aHeadExa := {}
		aColsExa := {}
		HS_BDados("GBY", @aHeadExa, @aColsExa,, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[nGD,nPEDCodSeq]),oGDPED:aCols[nGD,nPEDCodSeq],"000000") + "' AND GBY_MTVCAN = '" + Space(TamSx3("GBY_CPLCAN")[1]) + "' AND GBY_STALAB = '" + cStatus + "' " + cCondUrg + cCndDatCol + " " + cCndLocSol ,,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
		For nGD2 := 1 To Len(aColsExa)
			AADD(aCfgExa, FS_RTCFGEX(aColsExa[nGD2,nEXAProSol], aColsExa[nGD2,nEXASolici]))			
		Next nGD2 
	Next nGD
EndIf

aSort(aCfgExa,,,{|x,y| x[3] < y[3]}) // Ordena Por Setor

For nGD := 1 To Len(aCfgExa)
	If Empty(aCfgExa[nGd,5])
		AADD(aMapaG,{aCfgExa[nGd,2],""})
	Else
		AADD(aMapaInd, {aCfgExa[nGd,1],aCfgExa[nGd,2],aCfgExa[nGd,3],aCfgExa[nGd,5],aCfgExa[nGd,6]})				
	EndIf
Next nGD

If Len(aMapaG) > 0 

	cNumMapa := Hs_GNumMap()
	For nGD := 1 To Len(aMapaG)
		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + aMapaG[nGD,1])		
			Begin Transaction
			RecLock("GBY", .F.)
				GBY->GBY_STALAB := "2"
				GBY->GBY_DATMAP	:= dDataBase
				GBY->GBY_HORMAP := Time()
				GBY->GBY_USRMAP := cUsername
				//GBY->GBY_CDQMAP := aMapaG[nGD,4]
				GBY->GBY_NUMMAP := cNumMapa
			MsUnLock()
			End Transaction 
		Endif

	Next nGD
	HSPAHR89(cNumMapa)
EndIf

If Len(aMapaInd) > 0
	For nGD := 1 To Len(aMapaInd)

		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + aMapaInd[nGD,2])		
			Begin Transaction
			RecLock("GBY", .F.)
				GBY->GBY_STALAB := "2"
				GBY->GBY_DATMAP	:= dDataBase
				GBY->GBY_HORMAP := Time()
				GBY->GBY_USRMAP := cUsername
				GBY->GBY_CDQMAP := aMapaInd[nGD,4]
				GBY->GBY_NUMMAP := (cNumMapa := Hs_GNumMap())
			MsUnLock()
			End Transaction 
		Endif
		__cNmMpaInd := cNumMapa
		__cNumSolic := aMapaInd[nGD,2]
		HSPRQUES("GPI", "GPI_CDEXAM", "000000",aMapaInd[nGD,4],aMapaInd[nGD,5]) // Imprime vazio
	Next nGD
EndIf

aColsGNJ := {}
HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatCol + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
If cTipAte == "0" .OR. Empty(cTipAte)
	FS_TRATRN(@aColsGNJ)
EndIf
oGDPED:SetArray(aColsGNJ)
oGDPED:oBrowse:Refresh()
FS_AtDist()	

Return()
           

Static Function FS_RTCFGEX(cProSol, cSolici)
Local aArea		:= GetArea()
Local cCodPar	:= ""
Local cCodLoc	:= ""
Local aRet	:= {cProSol,cSolici,"","","",""}

DbSelectArea("GBY")
DbSetOrder(1)
If DbSeek(xFilial("GBY") + cSolici)
	If !Empty(GBY->GBY_CODLOC)
		cCodLoc := GBY->GBY_CODLOC
		DbSelectArea("GP9")
		DbSetOrder(2)
		If DbSeek(xFilial("GP9") + cProSol + cCodLoc)
			cCodPar := GP9->GP9_CODPAR
			aRet[3] := cCodLoc
			aRet[4] := cCodPar
			aRet[5] := GP9->GP9_MAPA
			aRet[6] := GBY->GBY_REGATE
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHs_GNumMapบ Autor ณ Rogerio tabosa     บ Data ณ 13/10/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera numero sequencial para o Mapa de Trabalho             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function Hs_GNumMap()
Local aArea		:= GetArea()
Local cSql 		:= "" 
Local nMaiorReg := 0
Local cNumMap	:= ""

cSql := " SELECT MAX(GBY_NUMMAP) GBY_MAX"	
cSql += " 	FROM " + RetSQLName("GBY") + " GBY"

cSql := ChangeQuery(cSql)

TCQUERY cSql NEW ALIAS "QRY"
nMaiorReg := Val( IIf(!Empty(QRY->GBY_MAX), QRY->GBY_MAX, "0") ) 
nMaiorReg ++         
DbCloseArea()                

cNumMap := PadL(nMaiorReg, TamSx3("GBY_NUMMAP")[1], "0")

RestArea(aArea)
Return(cNumMap)


Static Function FS_REABRE()

If !Pergunte("HSPP10",.T.)
	Return
EndIf

HSPAHP10(.T.)

oDlgAut:End()

Return(Nil)

Static Function FS_Refresh()
Local aArea	:= GetArea()
ProcRegua(1)
IncProc("Atualizando Dados...")

cLabDis		:= GetMv("MV_LABDIS",,"")                    
cCndDatCol	:= ""
cCndDatMap	:= ""
cCndDatRes	:= ""
cCndLocSol	:= ""
        
If cStatus == "0"     
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " GNJ_FILIAL = '" + xFilial("GNJ") + "' AND EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)		
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh() 
	FS_ATTELA()
ElseIf cStatus == "1"  
	dDatCol := CTOD("")
	lChkTod := .F.
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatCol + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_ATDIST()
ElseIf cStatus == "2"
	dDatMap := CTOD("")
	cNumMapF := Space(TamSx3("GBY_NUMMAP")[1])
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatMap + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()	
	FS_ATRESUL() 
ElseIf cStatus == "3"
	dDatRes := CTOD("") 
	cNumMapF := Space(TamSx3("GBY_NUMMAP")[1])	
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatRes + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	
	FS_ATLIBER()	
EndIf 
ProcRegua(10)
IncProc("Dados atualizados")
RestArea(aArea)
Return()  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HS_P10RESณ Autor ณ Rogerio Machado Tabosaณ data ณ 20/10/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Laboratorio - Fase Resultado                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_P10RES()

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons 	:= {}
Local cPsqReq	:= Space(TamSx3("GBY_CODPED")[1])
Local oGetReq 
Local oNumMap
Local oDatMap
Local nGDOpc1	:= GD_UPDATE
Local nGDOpc2	:= GD_UPDATE

Private dDatMap	:= CTOD("")
Private cNumMapF	:= Space(TamSx3("GBY_NUMMAP")[1])
Private oDlgAut		:= Nil
Private oGDPED  	:= nil
Private oGDEXA  	:= nil 
Private bKeyF12 := SetKey(VK_F12, {|| FS_REABRE()})
Private bKeyF5 		:= SetKey(VK_F5, {|| FS_REFRESH()})
Private aHeadGNJ 	:= {}, aColsGNJ := {}
Private aHeadGBY 	:= {}, aColsGBY := {} 

Private aCpoGNJ  	:= {}
Private aCpoGBY  	:= {"GBY_NUMMAP","GBY_PROSOL","GA7_MNEMON","GBY_DESPRO","GBY_DATMAP", "GBY_HORMAP","GBY_CFGMMM","GBY_DESMAT","GBY_OBSRES","GBY_LOCSOL","GBY_NOMSOL","GBY_SOLICI"}  
Private aCpoAltEx	:= {"GBY_CFGMMM","GBY_OBSRES", "GBY_DATMAP","GBY_HORMAP"}
Private aJoinGBY := {{" JOIN " + RetSqlName("GA7") + " GA7", "GA7_MNEMON", "GA7.GA7_CODPRO=GBY.GBY_PROSOL", "GA7_MNEMON"}}
Private aJoinGNJ := {}

Private nEXAIdMarc  := 0
Private nEXAProSol  := 0
Private nEXASolici  := 0
Private nEXACfgMMM  := 0
Private nEXADESMMM  := 0
Private nEXADATMAP  := 0
Private nEXAHORMAP  := 0 
Private nEXAMNEMON  := 0 
Private nEXADESPRO  := 0 



If cTipAte == "0" .OR. Empty(cTipAte)
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC","GAV_QUARTO","GAV_LEITO"}  
Else
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC"}  
EndIf

aJoinGNJ := {	{" JOIN " + RetSqlName("GCY") + " GCY", "GCY_NOME"  , "GCY.GCY_REGATE=GNJ.GNJ_REGATE AND GCY_FILIAL = '" + xFilial("GCY") + "' " + IIf(!Empty(cTipAte), " AND GCY.GCY_ATENDI = '" + cTipAte + "' ", ""), "GCY_NOME"},;
		 		{"" , "GCY.GCY_CODLOC",, "GCY_CODLOC"},;
				{" JOIN " + RetSqlName("GCS") + " GCS", "GCS_NOMLOC"  , " GCS.D_E_L_E_T_ <> '*' AND GCY.GCY_CODLOC=GCS.GCS_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' ", "GCS_NOMLOC"},;//				"GCY_CODLOC,GCY_NOME,GAV_LEITO "
			 	{" LEFT JOIN " + RetSqlName("GAV") + " GAV", "GAV_QUARTO"  , " GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_REGATE=GNJ.GNJ_REGATE AND GAV.GAV_LEITO <> '" + Space(TamSx3("GAV_LEITO")[1]) + "'", "GAV_QUARTO"},;
				{"" , "GAV.GAV_LEITO",, "GAV_LEITO"}}  

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
 
 aObjs := {{13, 100, .T., .T.}, ;
           {87, 100, .T., .T.}}     	

 aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
 aPExa := MsObjSize(aInfo, aObjs, .T.,.T.) 
 
 aObjs := {{50, 100, .T., .T.}, ;
           {50, 100, .T., .T.}}     	

 aInfo := {aPPac[1, 2], aPPac[1, 1], aPPac[1, 4], aPPac[1, 3], 0, 0}
 aPFil := MsObjSize(aInfo, aObjs, .T.,.T.)    
 
 
DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cDesLoc + " - " + cDescStat) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
 

	oPanel9 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4]) // Filtros e PEDIDOS
	oPanel9:Align := CONTROL_ALIGN_BOTTOM
	
	oPanel1  := tPanel():New(aPExa[2, 1], aPExa[2, 2],, oPanel9,,,,,, aPExa[2, 3], aPExa[2, 4]) //EXAMES GBY
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT 

	oPanel10  := tPanel():New(aPExa[1, 1], aPExa[1, 2],, oPanel9,,,,,, aPExa[1, 3], aPExa[1, 4]) //CANCELA EXAME E COLETA	
	oPanel10:Align := CONTROL_ALIGN_TOP 
	
	oPanel2 := tPanel():New(aPObj[1, 1], aPObj[1, 2],, oDlgAut,,,,,, aPObj[1, 3], aPObj[1, 4]) // Filtros e PEDIDOS
	oPanel2:Align := CONTROL_ALIGN_TOP

	oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // FiltroS
	oPanel6:Align := CONTROL_ALIGN_TOP         

	oPanel8 := tPanel():New(aPFil[2, 3], aPFil[2, 4],, oPanel6,,,,,, aPFil[2, 3], aPFil[2, 4]) // COD BARRAS
	oPanel8:Align := CONTROL_ALIGN_RIGHT        
	
	oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // PEDIDOS GNJ
	oPanel7:Align := CONTROL_ALIGN_ALLCLIENT
	
    oPanel3 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4])// P09
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	                                           
	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS "Exames" 
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT 

	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	nPEDCodSeq := aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_CODSEQ"})
	nPEDRegAte := aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_REGATE"})	
	nPEDDatPed := aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_DATPED"})
	nPEDNome 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_NOME  "})    
	nPEDCodLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_CODLOC"})	
	nPEDNomLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCS_NOMLOC"})		
			
	If cTipAte == "0" .OR. Empty(cTipAte)
		nPEDQuarto := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_QUARTO"})		
		nPEDLeito := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_LEITO "})		
		FS_TRATRN(@aColsGNJ)
	EndIf
	
	oGDPED:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadGNJ, aColsGNJ)
	oGDPED:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   
	oGDPED:bChange       := {|| FS_AtResul()} 	
	oGDPED:oBrowse:bGotFocus  := {|| FS_AtResul()}	

	//Fitros dos Dados                           
	HS_GDPesqu( , , oGDPED, oPanel6, 001,.T.) 
	
	@001, 140 MSGet oGetReq Var cPsqReq Picture "@!" Size 60, 010 Of oPanel8 Pixel Color CLR_BLACK  
  	oBtnReq := tButton():New(001, 205, STR0008, oPanel8, {|| FS_EFPESQ(cPsqReq)}, 050, 012,,,, .T.)    //"Codigo de Barras"
	
	//Exames
	Inclui := .T.
	HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' " + cCondUrg + " AND GBY_STALAB = '" + cStatus + " '",,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
	oGDEXA := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc1,,,,aCpoAltEx,,,,,, oFolder:aDialogs[1], aHeadGBY, aColsGBY)		
	oGDEXA:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
 	oGDEXA:oBrowse:BlDblClick := {|| FS_DblClk(oGDEXA,1)} 	
                         
	nEXAIdMarc := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_IDMARC"}) 
	nEXAProSol := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_PROSOL"}) 	
	nEXASolici := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_SOLICI"}) 	
	nEXACfgMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_CFGMMM"}) 	
	nEXADESMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DESMAT"}) 		
	nEXADATMAP := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DATMAP"}) 		
	nEXAHORMAP := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_HORMAP"})
	nEXAMNEMON := aScan(aHeadGBY, {|aVet| aVet[2] == "GA7_MNEMON"})
	nEXADESPRO := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DESPRO"})
	nEXAOBSRES := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_OBSRES"})
			


  	@003, 010 Say "Num. Mapa" Of oPanel10 Pixel COLOR CLR_BLUE // 
	@001, 040 MSGet oNumMap Var cNumMapF Picture "999999" Size 50, 010 Of oPanel10 Pixel Color CLR_BLACK    	

  	@003, 090 Say "Dat. Mapa" Of oPanel10 Pixel COLOR CLR_BLUE // 
	@001, 115 MSGet oDatMap Var dDatMap Picture "@D" Size 50, 010 Of oPanel10 Pixel Color CLR_BLACK    	
  	oBtnFCol := tButton():New(001, 165, "Filtrar", oPanel10, {|| FS_FLDTMAP(dDatMap, cNumMapF)}, 025, 012,,,, .T.)  

  	oBtnRes  := tButton():New(001, 240,"Laudo Gen.", oPanel10, {|| FS_LDOGEN()}, 040, 012,,,, .T.)    //
  	oBtnRes  := tButton():New(001, 285,"Resultado", oPanel10, {|| FS_RESULTADO()}, 040, 012,,,, .T.)    //
  	oBtnIMap := tButton():New(001, 330,"Reimprime Mapa", oPanel10, {|| FS_RIMPMAP()}, 050, 012,,,, .T.)    //"Impr Mapa"	
  	oBtnCExa := tButton():New(001, 385, "Cancela Exames", oPanel10, {|| FS_CANEXA()}, 050, 012,,,, .T.)    //"Cancela Exames"
  	oBtnCCol := tButton():New(001, 440, "Cancela Mapa", oPanel10, {|| FS_CANMAP()}, 040, 012,,,, .T.)    //"Cancela Coleta"
	//HS_GDPesqu( , , oGDEXA, oPanel10, 001,.T.) 
			
	aAdd(aButtons,  {"PMSRRFSH", {|| FS_Refresh()}, "Atualiza Tela(F5)","Atualiza"})    //
	aAdd(aButtons,  {"CHECKED", {|| FS_MarcT(oGDEXA,nEXAIdMarc)}, STR0010,STR0009})    //"Todos", "Marcar Todos"
	aAdd(aButtons,	{"S4WB001N", {|| FS_GRVRES()}, "Salva","Salva"})  // "Confirma","Confirma Coleta"
	aAdd(aButtons,	{"S4WB007N", {|| HSPAHM08(oGDPED:aCols[oGDPED:nAt,nPEDRegAte])}, "Pedido Exames","Ped. Exam."})  //	"Ped. Exames","Pedido Exames"
	aAdd(aButtons,	{"BTPESQ_OCEAN", {|| FS_FILSOL(.T.)}, "Filtro Setor Executante","Filtra Setor"})  //	"Ped. Exames","Pedido Exames"	
	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcAut := 0},,aButtons) 
                                                        
If nOpcAut == 1
	FS_GRVDIS(.T.)
EndIf

Return(Nil)

Static Function FS_AtResul(cFiltro)

Default cFiltro := ""

aColsGBY := {}

oDlgAut:cTitle := Alltrim(cDesLoc) + " - " + cDescStat + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq])," - Pedido: " + oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"")
Inclui := .F.
HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' AND GBY_MTVCAN = '" + Space(TamSx3("GBY_CPLCAN")[1]) + "' AND GBY_STALAB = '" + cStatus + "' " + cCondUrg + cCndDatMap + " " + cFiltro ,,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
Inclui := .T.

oGDEXA:SetArray(aColsGBY)
oGDEXA:oBrowse:Refresh()  

Return()

Static Function FS_FLDTMAP(dDatMap, cNMapa)
Default cNMapa := ""

If !Empty(dDatMap)
	cCndDatMap := " AND GBY_DATMAP = '" + DTOS(dDatMap) + "' "
Else
	cCndDatMap := ""
EndIf 

If !Empty(cNMapa)
	cCndDatMap += " AND GBY_NUMMAP = '" + PadL(Alltrim(cNMapa),6,"0") + "' "
EndIf	

aColsGNJ := {}
HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatMap + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
If cTipAte == "0" .OR. Empty(cTipAte)
	FS_TRATRN(@aColsGNJ)
EndIf
oGDPED:SetArray(aColsGNJ)
oGDPED:oBrowse:Refresh()
FS_AtResul()

Return()


Static Function FS_CANMAP()
//Local lAchou 	:= .F.
Local nGD		:= 0 
Local lSel		:= .F.                             

For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.
		Begin Transaction
			DbSelectArea("GBY")
			DbSetOrder(1)
			If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
				RecLock("GBY", .F.)
					GBY->GBY_STALAB  := "1" 
					GBY->GBY_DATMAP  := CTOD("")//Space(TamSx3("GBY_DATCOL")[1])
					GBY->GBY_HORMAP  := Space(TamSx3("GBY_HORMAP")[1])
					GBY->GBY_USRMAP  := Space(TamSx3("GBY_USRMAP")[1])					
					GBY->GBY_NUMMAP  := Space(TamSx3("GBY_NUMMAP")[1])										
					GBY->GBY_CDQMAP  := Space(TamSx3("GBY_CDQMAP")[1])
					GBY->GBY_LGCANC	:= HS_LogArq()
				MsUnLock()
		    Endif
		End Transaction 
	
	EndIf
	
Next nGD

If !lSel 
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel
	HS_MSGINF("Mapa(s) cancelado(s)!",STR0016,STR0017)//"Coleta cancelada!","Aten็ใo","Valida็ใo Laborat๓rio"
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatMap + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_AtResul()
EndIf

Return(Nil)
          

Static Function FS_RIMPMAP()
Local aArea		:= GetArea()
Local cSql 		:= ""

If Empty(cNumMapF)
	HS_MSGINF("Realize o filtro do Numero do Mapa para reimpressใo do mesmo!",STR0016,STR0017)
	Return(Nil)
EndIf

cSql := " SELECT GBY_REGATE,GBY_SOLICI,GBY_CDQMAP FROM " + RetSqlName("GBY") + " GBY "
cSql += " WHERE GBY_NUMMAP = '" + cNumMapF + "' AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "'"

cSql := ChangeQuery(cSql)      

TCQUERY cSql NEW ALIAS "QRYMAP"

If !QRYMAP->(Eof())
	If !Empty(QRYMAP->GBY_CDQMAP)
   		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + QRYMAP->GBY_SOLICI)		
			Begin Transaction
			RecLock("GBY", .F.) 			
				GBY->GBY_DTRMAP	:= dDataBase
				GBY->GBY_HRRMAP := Time()
				GBY->GBY_USRRMA := cUsername
			MsUnLock()
			End Transaction 
		Endif 
		__cNmMpaInd := cNumMapF
		__cNumSolic := QRYMAP->GBY_SOLICI
		HSPRQUES("GPI", "GPI_CDEXAM", "000000",QRYMAP->GBY_CDQMAP,QRYMAP->GBY_REGATE) // Imprime vazio				
	Else
		While !QRYMAP->(Eof())
			DbSelectArea("GBY")
			DbSetOrder(1)
			If DbSeek(xFilial("GBY") + QRYMAP->GBY_SOLICI)		
				Begin Transaction
				RecLock("GBY", .F.) 			
					GBY->GBY_DTRMAP	:= dDataBase
					GBY->GBY_HRRMAP := Time()
					GBY->GBY_USRRMA := cUsername
				MsUnLock()
				End Transaction 
			Endif
			QRYMAP->(DbSkip())
		EndDo
		HSPAHR89(cNumMapF)
	EndIf
EndIf
                    
DbSelectArea("QRYMAP")
DbCloseArea()

RestArea(aArea)
Return(Nil)

Static Function FS_RESULTADO()
Local nGD		:= 0
Local lSel		:= .F.
Local lConf		:= .F.
Local cQueste   := ""

For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.

		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
			If !Empty(GBY->GBY_CDQMAP)
				cQueste := GBY->GBY_CDQMAP
			Else
				cQueste := FS_RETQMAP(GBY->GBY_PROSOL, GBY->GBY_CODLOC)
			EndIf
			If !Empty(cQueste)
				aMntPerg := HS_MntPerg(cQueste, Nil,"Laudo - " + IIf(!Empty(oGDEXA:aCols[nGD,nEXAMNEMON]),Alltrim(oGDEXA:aCols[nGD,nEXAMNEMON]) + " - " ,"") + Alltrim(oGDEXA:aCols[nGD,nEXADESPRO]) + " - Pedido: " + oGDPED:aCols[oGDPED:nAt,nPEDCodSeq], , .F., "GPJ", "oGP8",, Nil, CONTROL_ALIGN_ALLCLIENT, .T., "G",,.T.,.T.)
				If aMntPerg[1] == 1			
					HS_GrvResp("GPJ", {{"GPJ->GPJ_CDEXAM", oGDEXA:aCols[nGD,nEXASolici]}, {"GPJ->GPJ_CDQUES", cQueste}} , aMntperg[2])
					lConf := .T.
				EndIf
			Else
				HS_MSGINF("Exame sem parametriza็ใo de Questionแrio para preenchimento do Laudo, nใo ้ possivel atribuir o resultado!",STR0016,STR0017)
				Return(Nil)
				//lConf := FS_LDOGEN(oGDEXA:aCols[nGD,nEXASolici])
			EndIf
			If lConf
				Begin Transaction
				RecLock("GBY", .F.)
					GBY->GBY_STALAB  := "3" 
					GBY->GBY_DATRES  := dDataBase
					GBY->GBY_HORRES  := Time()
					GBY->GBY_USRRES  := cUserName
				MsUnLock()
				End Transaction 
			Endif
	    Endif	
	EndIf
	
Next nGD

If !lSel 
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel .AND. lConf
	HS_MSGINF("Resultado(s) realizados(s) com sucesso!",STR0016,STR0017)//"Coleta cancelada!","Aten็ใo","Valida็ใo Laborat๓rio"
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatMap + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_AtResul()
EndIf

Return(Nil)

Static Function FS_RETQMAP(cCodPro,cCodLoc)
Local aArea 	:= GetArea()
Local cQueste	:= ""

DbSelectArea("GP9")
DbSetOrder(2) // CODPRO + CODLOC
If DbSeek(xFilial("GP9") + cCodPro + cCodLoc)
	cQueste	:= IIf(Empty(GP9->GP9_MAPA),GP9->GP9_LAUDO,GP9->GP9_MAPA)
EndIf

RestArea(aArea)
Return(cQueste)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ FS_TRATRNณ Autor ณ Rogerio Machado Tabosaณ data ณ 30/10/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao para exibir os pedidos e exames na existencia de RNsณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_TRATRN(aDados)
Local aArea		:= GetArea()
Local aVetAux	:= {}//aClone(aDados)
Local nAdd		:= 0
Local aGB2		:= {}
Local nCont,nPos:= 0
Local nCont2	:= 0
Local cRegIn	:= ""
Local cRegVer	:= ""
Local cSql		:= "" 
Local lAddLin	:= .F.

aRNs := {}
If Len(aDados) == 0 
	Return(Nil)
EndIf
For nCont := 1 to Len(aDados) //Verifica se algum registro de atendimento possui RN na GB2
	cRegIn += aDados[nCont,nPEDRegAte] + "/"
Next nCont
cRegIn := HS_InSql(cRegIn, 6)

cSql := " SELECT GB2_REGATE, GB2_NOME, GB2_TPNASC FROM " + RetSqlName("GB2") + " GB2 "
cSql += " WHERE GB2_REGATE IN (" + cRegIn + ") AND D_E_L_E_T_ <> '*' AND GB2_FILIAL = '" + xFilial("GB2") + "' ORDER BY 1"

cSql := ChangeQuery(cSql)

TCQUERY cSql NEW ALIAS "QRYRN"

If !QRYRN->(Eof()) //Verifica se algum registro de atendimento possui RN na GB2		
     While !QRYRN->(Eof())
     	AADD(aGB2, {QRYRN->GB2_REGATE, QRYRN->GB2_NOME, QRYRN->GB2_TPNASC})
     	If cRegVer <> QRYRN->GB2_REGATE
     		cRegVer := QRYRN->GB2_REGATE
     		AADD(aGB2, {QRYRN->GB2_REGATE, "", ' '}) // adiciona mae
     	EndIf
     	QRYRN->(DbSkip())
     EndDo
Else //Caso nao exista retorna e nao meche no aCols
	DbSelectArea("QRYRN")
	DbCloseArea() 
	Return(Nil)
EndIf
DbSelectArea("QRYRN")
DbCloseArea() 

For nCont := 1 to Len(aDados) //Verifica se algum registro de atendimento possui RN na GB2
	nPos := ASCAN(aGB2,{|aVet| aVet[1] == aDados[nCont,nPEDRegAte]})
	If nPos > 0 
		For nCont2 := nPos to Len(aGB2)
			If aGB2[nCont2, 1] == aDados[nCont,nPEDRegAte]
				cSql := " SELECT GAV_RESERV, GAV_CODLOC FROM " + RetSqlName("GAV") + " GAV "
				cSql += " WHERE GAV_REGATE = '" + aDados[nCont,nPEDRegAte] + "' AND GAV_QUARTO = '" + aDados[nCont,nPEDQuarto] + "' "
				cSql += " AND GAV_LEITO = '" + aDados[nCont,nPEDLeito] + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV_FILIAL = '" + xFilial("GAV") + "' "
				cSql += " AND EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = '" + aDados[nCont,nPEDCodSeq] + "' " 
				cSql += " AND GBY_MTVCAN = '" + Space(TamSx3("GBY_CPLCAN")[1]) + "' AND GBY_RESERV = " + IIf(Empty(aGB2[nCont2, 3])," ' ' "," GAV.GAV_RESERV ")  + " AND GBY_STALAB = '" + cStatus + "' " + cCondUrg 
				cSql += " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "'
				cSql += IIf(cStatus == "1",cCndDatCol,IIf(cStatus == "2", cCndDatMap,"")) + ")"

				cSql := ChangeQuery(cSql)
				
				TCQUERY cSql NEW ALIAS "QRYEXA"
				If !QRYEXA->(Eof()) .AND. aGB2[nCont2, 3] == IIf(Empty(aGB2[nCont2, 3]) .AND. !(QRYEXA->GAV_RESERV $ "0/1/2/3/4/5")," ",QRYEXA->GAV_RESERV) 
					lAddLin := .T.			
					AADD(aRNs, {nAdd + 1, aGB2[nCont2,3], QRYEXA->GAV_CODLOC }) // adiciona posicao do grid e TpNasc
					IF !Empty(aGB2[nCont2,2])
						aDados[nCont,nPEDNome] := aGB2[nCont2,2]
						aDados[nCont,nPEDCodLoc]:= QRYEXA->GAV_CODLOC						
						aDados[nCont,nPEDNomLoc]:= Hs_IniPadr("GCS", 1, QRYEXA->GAV_CODLOC, "GCS_NOMLOC",,.F.)
					EndIf
				EndIf               
				DbSelectArea("QRYEXA")
				DbCloseArea() 
			EndIf
		Next nCont2 
		If lAddLin       //Caso exista adiciona no vetor, caso contrario eh linha duplicada
			AADD(aVetAux,aDados[nCont])  
			nAdd ++ 
			lAddLin := .F.
		Endif			
	Else
		AADD(aVetAux,aDados[nCont])
		nAdd ++
	EndIf
Next nCont

aDados := aClone(aVetAux)

RestArea(aArea)
Return(Nil)

Static Function FS_PEDEXA(nPosAt)
Local nPos := 0

If (nPos := ASCAN(aRNs,{|aVet| aVet[1] == nPosAt})) > 0
	If !Empty(aRNs[nPos,2])
		HSPAHM08(oGDPED:aCols[nPosAt,nPEDRegAte], aRNs[nPos,2], aRNs[nPos,3])	
	Else 
		HSPAHM08(oGDPED:aCols[nPosAt,nPEDRegAte])		
	EndIf                                                   
Else
	HSPAHM08(oGDPED:aCols[nPosAt,nPEDRegAte])		
EndIf

Return(Nil)

Static Function FS_LDOGEN(cNrSolici)
Local aArea 	:= GetArea()
Local nGD		:= 0
Local lSel		:= .F.
Local lConf		:= .F.

For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.

		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
			lConf := FS_MEMLDO(oGDEXA:aCols[nGD,nEXASolici])
			If lConf
				Begin Transaction
				RecLock("GBY", .F.)
					GBY->GBY_STALAB  := "3" 
					GBY->GBY_DATRES  := dDataBase
					GBY->GBY_HORRES  := Time()
					GBY->GBY_USRRES  := cUserName
				MsUnLock()
				End Transaction 
			Endif
	    Endif	
	EndIf
	
Next nGD

If !lSel 
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel .AND. lConf
	HS_MSGINF("Laudo(s) realizados(s) com sucesso!",STR0016,STR0017)//"Coleta cancelada!","Aten็ใo","Valida็ใo Laborat๓rio"
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS (SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatMap + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_AtResul()
EndIf
RestArea(aArea)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MEMLDOบ Autor ณ Rogerio Tabosa     บ Data ณ  09/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre campo memo para digitacao do Laudo Generico           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Laboratorio)                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MEMLDO(cNrSolici, lEdit)
Local aArea		:= GetArea()
Local oDlgM, oTexto, cTexto	:= ""
Local nPos 		:= 0
Local nPosCtrl 	:= 0
Local lOkCpc 	:= .F.

Default cNrSolici := ""
Default lEdit	  := .T.

If cStatus <> "2"
	DbSelectArea("GBY")
	DbSetOrder(1)
	If DbSeek(xFilial("GBY") + cNrSolici)	
		If !Empty(GBY->GBY_LDOGEN)
			cTexto := E_MSMM(GBY->GBY_LDOGEN) 
		EndIf
	EndIf
EndIf


DEFINE MSDIALOG oDlgM FROM	50,70 TO 500,800 TITLE "Laudo Gen้rico" PIXEL //"Laudo Gen้rico"
//DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE "Laudo Gen้rico" PIXEL //"Laudo Gen้rico"

  @ 005, 004 TO 200, 360 Label "Laudo" OF oDlgM PIXEL
  @ 015, 010 GET oTexto VAR cTexto MEMO When lEdit SIZE 342, 175 OF oDlgM PIXEL   

DEFINE SBUTTON FROM 210,320 TYPE 1 ACTION (lOkCpc := FS_GRVLDO(cNrSolici,cTexto),IIf(lOkCpc,oDlgM:End(),)) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cTexto)),.F.,.T.)                                     

RestArea(aArea)
Return(lOkCpc)

Static Function FS_GRVLDO(cNrSolici,cTexto)
Local aArea	:= GetArea()
Local lRet 	:= .F.

If !Empty(cTexto)
	DbSelectArea("GBY")
	DbSetOrder(1)
	If (lRet := DbSeek(xFilial("GBY") + cNrSolici))
		MSMM(, TamSx3("GBY_LDOGEN")[1],, cTexto, 1,,, "GBY","GBY_LDOGEN" )
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)	
Return(lRet)

Static Function FS_GRVRES(lOk)
//Local lAchou 	:= .F.
Local nGD		:= 0 
Local lSel		:= .F.

Default lOk 	:= .F.
                             

For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.
		Begin Transaction
		DbSelectArea("GBY")
		DbSetOrder(1)
		If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
			RecLock("GBY", .F.)
				GBY->GBY_CFGMMM := oGDEXA:aCols[nGD,nEXACFGMMM]
				GBY->GBY_OBSRES := oGDEXA:aCols[nGD,nEXAOBSRES]
				GBY->GBY_DATMAP := oGDEXA:aCols[nGD,nEXADATMAP]					
				GBY->GBY_HORMAP := oGDEXA:aCols[nGD,nEXAHORMAP]					
			MsUnLock()
		EndIf
		End Transaction
	EndIf
	
Next nGD

If !lSel .AND. !lOk
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel	.AND. !lOk
	HS_MSGINF("Altera็๕es salvas com sucesso!",STR0016,STR0017)//"Altera็๕es salvas com sucesso!","Aten็ใo","Valida็ใo Laborat๓rio"
	aColsGNJ := {}
	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatMap + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	If cTipAte == "0" .OR. Empty(cTipAte)
		FS_TRATRN(@aColsGNJ)
	EndIf
	oGDPED:SetArray(aColsGNJ)
	oGDPED:oBrowse:Refresh()
	FS_AtResul()
EndIf

Return(Nil)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ HS_P10LIBณ Autor ณ Rogerio Machado Tabosaณ data ณ 10/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Laboratorio - Fase Liberacao                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_P10LIB()

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc :={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons 	:= {}
Local cPsqReq	:= Space(TamSx3("GBY_CODPED")[1])
Local oGetReq 
Local oNumMap
Local oDatMap
Local nGDOpc1	:= GD_UPDATE
Local nGDOpc2	:= GD_UPDATE

Private dDatRes	:= CTOD("")  
Private cNumMapF	:= Space(TamSx3("GBY_NUMMAP")[1])
Private oDlgAut		:= Nil
Private oGDPED  	:= nil
Private oGDEXA  	:= nil 
Private bKeyF12 := SetKey(VK_F12, {|| FS_REABRE()})
Private bKeyF5 		:= SetKey(VK_F5, {|| FS_REFRESH()})
Private aHeadGNJ 	:= {}, aColsGNJ := {}
Private aHeadGBY 	:= {}, aColsGBY := {} 
Private cImgAss		:= ""
Private cCrmAss		:= ""
Private lUsrMed		:= .F.

Private aCpoGNJ  	:= {}
Private aCpoGBY  	:= {"GBY_NUMMAP","GBY_PROSOL","GA7_MNEMON","GBY_DESPRO","GBY_DATRES", "GBY_HORRES","GBY_CFGMMM","GBY_DESMAT","GBY_OBSRES","GBY_LOCSOL","GBY_NOMSOL","GBY_SOLICI"}  
Private aCpoAltEx	:= {""}
Private aJoinGBY := {{" JOIN " + RetSqlName("GA7") + " GA7", "GA7_MNEMON", "GA7.GA7_CODPRO=GBY.GBY_PROSOL", "GA7_MNEMON"}}
Private aJoinGNJ := {}

Private nEXAIdMarc  := 0
Private nEXAProSol  := 0
Private nEXASolici  := 0
Private nEXACfgMMM  := 0
Private nEXADESMMM  := 0
Private nEXADATMAP  := 0
Private nEXAHORMAP  := 0 
Private nEXAMNEMON  := 0 
Private nEXADESPRO  := 0 

PswOrder(2) // indice por Nome
PswSeek(cUserName, .T.)  // Pesquisa o ID no cadastro de usuario	
cRet := HS_IniPadr("SRA", 1, substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1]) , "RA_CODIGO",, .F.)
If !Empty(cRet)
	DbSelectArea("GBJ")
	DbSetOrder(1)
	If DbSeek(xFilial("GBJ") + cRet)
		If GBJ->GBJ_TIPPRO $ "0/1/2" //0-Medico Interno,1-Medico Cooperado,2-Medico Externo
			lUsrMed := .T.
			cImgAss := GBJ->GBJ_BITMAP
			cCrmAss	:= GBJ->GBJ_CRM
		EndIf
	EndIf
EndIf 

If cTipAte == "0" .OR. Empty(cTipAte)
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC","GAV_QUARTO","GAV_LEITO"}  
Else
	aCpoGNJ  	:= {"GNJ_CODSEQ","GNJ_DATPED","GNJ_REGATE", "GCY_NOME","GCY_CODLOC","GCS_NOMLOC"}  
EndIf

aJoinGNJ := {	{" JOIN " + RetSqlName("GCY") + " GCY", "GCY_NOME"  , "GCY.GCY_REGATE=GNJ.GNJ_REGATE AND GCY_FILIAL = '" + xFilial("GCY") + "' " + IIf(!Empty(cTipAte), " AND GCY.GCY_ATENDI = '" + cTipAte + "' ", ""), "GCY_NOME"},;
		 		{"" , "GCY.GCY_CODLOC",, "GCY_CODLOC"},;
				{" JOIN " + RetSqlName("GCS") + " GCS", "GCS_NOMLOC"  , " GCS.D_E_L_E_T_ <> '*' AND GCY.GCY_CODLOC=GCS.GCS_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' ", "GCS_NOMLOC"},;//				"GCY_CODLOC,GCY_NOME,GAV_LEITO "
			 	{" LEFT JOIN " + RetSqlName("GAV") + " GAV", "GAV_QUARTO"  , " GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.GAV_REGATE=GNJ.GNJ_REGATE AND GAV.GAV_LEITO <> '" + Space(TamSx3("GAV_LEITO")[1]) + "'", "GAV_QUARTO"},;
				{"" , "GAV.GAV_LEITO",, "GAV_LEITO"}}  
				

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
 
 aObjs := {{13, 100, .T., .T.}, ;
           {87, 100, .T., .T.}}     	

 aInfo := {aPEnc[2, 2], aPEnc[2, 1], aPEnc[2, 4], aPEnc[2, 3], 0, 0}
 aPExa := MsObjSize(aInfo, aObjs, .T.,.T.) 
 
 aObjs := {{50, 100, .T., .T.}, ;
           {50, 100, .T., .T.}}     	

 aInfo := {aPPac[1, 2], aPPac[1, 1], aPPac[1, 4], aPPac[1, 3], 0, 0}
 aPFil := MsObjSize(aInfo, aObjs, .T.,.T.)    
 
 
DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cDesLoc + " - " + cDescStat) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
 

	oPanel9 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4]) // Filtros e PEDIDOS
	oPanel9:Align := CONTROL_ALIGN_BOTTOM
	
	oPanel1  := tPanel():New(aPExa[2, 1], aPExa[2, 2],, oPanel9,,,,,, aPExa[2, 3], aPExa[2, 4]) //EXAMES GBY
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT 

	oPanel10  := tPanel():New(aPExa[1, 1], aPExa[1, 2],, oPanel9,,,,,, aPExa[1, 3], aPExa[1, 4]) //CANCELA EXAME E COLETA	
	oPanel10:Align := CONTROL_ALIGN_TOP 
	
	oPanel2 := tPanel():New(aPObj[1, 1], aPObj[1, 2],, oDlgAut,,,,,, aPObj[1, 3], aPObj[1, 4]) // Filtros e PEDIDOS
	oPanel2:Align := CONTROL_ALIGN_TOP

	oPanel6 := tPanel():New(aPPac[1, 1], aPPac[1, 2],, oPanel2,,,,,, aPPac[1, 3], aPPac[1, 4]) // FiltroS
	oPanel6:Align := CONTROL_ALIGN_TOP         

	oPanel8 := tPanel():New(aPFil[2, 3], aPFil[2, 4],, oPanel6,,,,,, aPFil[2, 3], aPFil[2, 4]) // COD BARRAS
	oPanel8:Align := CONTROL_ALIGN_RIGHT        
	
	oPanel7 := tPanel():New(aPPac[2, 1], aPPac[2, 2],, oPanel2,,,,,, aPPac[2, 3], aPPac[2, 4]) // PEDIDOS GNJ
	oPanel7:Align := CONTROL_ALIGN_ALLCLIENT
	
    oPanel3 := tPanel():New(aPEnc[2, 1], aPEnc[2, 2],, oDlgAut,,,,,, aPEnc[2, 3], aPEnc[2, 4])// P09
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	                                           
	@ aPObj[2, 1], aPObj[2, 2] FOLDER oFolder SIZE aPObj[2, 3], aPObj[2, 4]  OF oPanel1 PIXEL PROMPTS "Exames" 
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT 

	HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
	nPEDCodSeq := aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_CODSEQ"})
	nPEDRegAte := aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_REGATE"})	
	nPEDDatPed := aScan(aHeadGNJ, {|aVet| aVet[2] == "GNJ_DATPED"})
	nPEDNome 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_NOME  "})    
	nPEDCodLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCY_CODLOC"})	
	nPEDNomLoc 	:= aScan(aHeadGNJ, {|aVet| aVet[2] == "GCS_NOMLOC"})		
			
	If cTipAte == "0" .OR. Empty(cTipAte)
		nPEDQuarto := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_QUARTO"})		
		nPEDLeito := aScan(aHeadGNJ, {|aVet| aVet[2] == "GAV_LEITO "})		
		FS_TRATRN(@aColsGNJ)
	EndIf
	
	oGDPED:= MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], 0,,,,,,,,,, oPanel7, aHeadGNJ, aColsGNJ)
	oGDPED:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   
	oGDPED:bChange       := {|| FS_AtLiber()} 	
	oGDPED:oBrowse:bGotFocus  := {|| FS_AtLiber()}	

	//Fitros dos Dados                           
	HS_GDPesqu( , , oGDPED, oPanel6, 001,.T.) 
	
	@001, 140 MSGet oGetReq Var cPsqReq Picture "@!" Size 60, 010 Of oPanel8 Pixel Color CLR_BLACK  
  	oBtnReq := tButton():New(001, 205, STR0008, oPanel8, {|| FS_EFPESQ(cPsqReq)}, 050, 012,,,, .T.)    //"Codigo de Barras"
	
	//Exames
	Inclui := .T.
	HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' " + cCondUrg + " AND GBY_STALAB = '" + cStatus + " '",,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
	oGDEXA := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc1,,,,aCpoAltEx,,,,,, oFolder:aDialogs[1], aHeadGBY, aColsGBY)		
	oGDEXA:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT 
 	oGDEXA:oBrowse:BlDblClick := {|| FS_DblClk(oGDEXA,1)} 	
                         
	nEXAIdMarc := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_IDMARC"}) 
	nEXAProSol := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_PROSOL"}) 	
	nEXASolici := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_SOLICI"}) 	
	nEXACfgMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_CFGMMM"}) 	
	nEXADESMMM := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DESMAT"}) 		
	nEXADATMAP := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DATRES"}) 		
	nEXAHORMAP := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_HORRES"})
	nEXAMNEMON := aScan(aHeadGBY, {|aVet| aVet[2] == "GA7_MNEMON"})
	nEXADESPRO := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_DESPRO"})
	nEXAOBSRES := aScan(aHeadGBY, {|aVet| aVet[2] == "GBY_OBSRES"})
			

  	@003, 010 Say "Num. Mapa" Of oPanel10 Pixel COLOR CLR_BLUE // 
	@001, 040 MSGet oNumMap Var cNumMapF Picture "999999" Size 50, 010 Of oPanel10 Pixel Color CLR_BLACK    	

  	@003, 090 Say "Dat. Res." Of oPanel10 Pixel COLOR CLR_BLUE // 
	@001, 115 MSGet oDatRes Var dDatRes Picture "@D" Size 50, 010 Of oPanel10 Pixel Color CLR_BLACK    	
  	oBtnFRes := tButton():New(001, 165, "Filtrar", oPanel10, {|| FS_FLDTRES(dDatRes, cNumMapF)}, 025, 012,,,, .T.)  

  	//oBtnRes  := tButton():New(001, 240,"Imp. Resultado", oPanel10, {|| FS_IMPRES()}, 040, 012,,,, .T.)    //
  	oBtnImp  := tButton():New(001, 285,"Imp. Resultado", oPanel10, {|| FS_IMPRES()}, 050, 012,,,, .T.)    //
  	oBtnLib := tButton():New(001, 340,"Liberar", oPanel10, {|| FS_IMPRES(.T.)}, 030, 012,,,, .T.)    //"Impr Mapa"	
  	oBtnCRes := tButton():New(001, 375, "Cancela Resultado", oPanel10, {|| FS_CANRES()}, 050, 012,,,, .T.)    //"Cancela Exames"
  	oBtnEdit := tButton():New(001, 430, "Editar Laudo", oPanel10, {|| FS_EDTLDO()}, 040, 012,,,, .T.)    //"Cancela Coleta"
			
	aAdd(aButtons,  {"PMSRRFSH", {|| FS_Refresh()}, "Atualiza Tela(F5)","Atualiza"})    //
	aAdd(aButtons,  {"CHECKED", {|| FS_MarcT(oGDEXA,nEXAIdMarc)}, STR0010,STR0009})    //"Todos", "Marcar Todos"
//	aAdd(aButtons,	{"S4WB001N", {|| FS_GRVLIB()}, "Salva","Salva"})  // 
	aAdd(aButtons,	{"S4WB007N", {|| HSPAHM08(oGDPED:aCols[oGDPED:nAt,nPEDRegAte])}, STR0013,"Pedido Exames"})  //	"Ped. Exames","Pedido Exames"
	aAdd(aButtons,	{"BTPESQ_OCEAN", {|| FS_FILSOL(.T.)}, "Filtro Setor Executante","Filtra Setor"})  //	"Ped. Exames","Pedido Exames"	
	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcAut := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcAut := 0},,aButtons) 
                                                        
If nOpcAut == 1
	FS_GRVLIB(.T.)
EndIf

Return(Nil)

Static Function FS_AtLiber(cFiltro)

Default cFiltro := ""

aColsGBY := {}

oDlgAut:cTitle := Alltrim(cDesLoc) + " - " + cDescStat + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq])," - Pedido: " + oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"")
Inclui := .F.
HS_BDados("GBY", @aHeadGBY, @aColsGBY,@nUGBY, 1,, " GBY.GBY_CODPED = '" + IIf(!Empty(oGDPED:aCols[oGDPED:nAt,nPEDCodSeq]),oGDPED:aCols[oGDPED:nAt,nPEDCodSeq],"000000") + "' AND GBY_MTVCAN = '" + Space(TamSx3("GBY_CPLCAN")[1]) + "' AND GBY_STALAB = '" + cStatus + "' " + cCondUrg + cCndDatRes + " " + cFiltro ,,,"/",,,,"GBY_IDMARC","'LBNO'",.T.,,,,,,aCpoGBY ,aJoinGBY,,,{"GA7_MNEMON"})
Inclui := .T.

oGDEXA:SetArray(aColsGBY)
oGDEXA:oBrowse:Refresh()  

Return()

Static Function FS_FLDTRES(dDatMap, cNMapa)
Default cNMapa := "" 

If !Empty(dDatRes)
	cCndDatRes := " AND GBY_DATRES = '" + DTOS(dDatRes) + "' "
Else
	cCndDatRes := ""
EndIf 

If !Empty(cNMapa)
	cCndDatRes += " AND GBY_NUMMAP = '" + PadL(Alltrim(cNMapa),6,"0") + "' "
EndIf

aColsGNJ := {}
HS_BDados("GNJ", @aHeadGNJ, @aColsGNJ,, 1,, " EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY.GBY_CODPED = GNJ->GNJ_CODSEQ AND GBY_STALAB = '" + cStatus + "' AND GBY.GBY_CODLOC IN (" + cLocSub + ") " + cCondUrg + cCndDatRes + " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "')  ",,,"/",,,,,,.T.,,,,,, aCpoGNJ, aJoinGNJ)
If cTipAte == "0" .OR. Empty(cTipAte)
	FS_TRATRN(@aColsGNJ)
EndIf
oGDPED:SetArray(aColsGNJ)
oGDPED:oBrowse:Refresh()
FS_AtLiber()

Return()

Static Function FS_IMPRES(lLibera)
Local aArea 	:= GetArea()
Local cSolici 	:= ""
Local cRegAte 	:= ""
Local nGD		:= 0 
Local lSel		:= .F.

Default lLibera	:= .F. 

If lLibera .AND. !lUsrMed
	HS_MSGINF("Somente usuแrios m้dicos podem realizar a libera็ใo do exame!",STR0016,STR0017)//"Somente usuแrios m้dicos podem realizar a libera็ใo do exame!""Aten็ใo","Valida็ใo Laborat๓rio"
	Return(nil)
EndIf

cRegAte := oGDPED:aCols[oGDPED:nAt,nPEDRegAte]

For nGD := 1 To Len(oGDEXA:aCols)	                                                         
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK" 
		cSolici := oGDEXA:aCols[nGD,nEXASolici]
		lSel := .T.	                
		DbSelectArea("GPJ")
		DbSetOrder(1)
		If DbSeek(xFilial("GPJ") + cSolici)
			HSPRQUES("GPJ", "GPJ_CDEXAM", cSolici,GPJ->GPJ_CDQUES,cRegAte, IIf(lUsrMed .OR. lLibera,cImgAss,""), cCrmAss)
		EndIf
		DbSelectArea("GBY")
		DbSetOrder(1)
		If lLibera .AND. DbSeek(xFilial("GBY") + cSolici)		
			Begin Transaction
			RecLock("GBY", .F.)
				GBY->GBY_STALAB  := "4" 
				GBY->GBY_DATLIB  := dDataBase
				GBY->GBY_HORLIB  := Time()
				GBY->GBY_USRLIB  := cUserName
			MsUnLock()
			End Transaction 
	    Endif
	EndIf
Next nGD

If !lSel
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
Else
	FS_REFRESH()
EndIf

RestArea(aArea)
Return()


Static Function FS_CANRES()
//Local lAchou 	:= .F.
Local nGD		:= 0 
Local lSel		:= .F.                             

If !lUsrMed
	HS_MSGINF("Somente usuแrios m้dicos podem realizar o cancelamento do resultado!",STR0016,STR0017)//"Somente usuแrios m้dicos podem realizar o cancelamento do resultado!""Aten็ใo","Valida็ใo Laborat๓rio"
	Return(nil)
EndIf


For nGD := 1 To Len(oGDEXA:aCols)
	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.
		Begin Transaction
			DbSelectArea("GBY")
			DbSetOrder(1)
			If DbSeek(xFilial("GBY") + oGDEXA:aCols[nGD,nEXASolici])		
				RecLock("GBY", .F.)
					GBY->GBY_STALAB  := "2" 
					GBY->GBY_DATRES  := CTOD("")//Space(TamSx3("GBY_DATCOL")[1])
					GBY->GBY_HORRES  := Space(TamSx3("GBY_HORMAP")[1])
					GBY->GBY_LGCANC	:= HS_LogArq()
				MsUnLock()
		    Endif
		End Transaction 	
	EndIf
	
Next nGD

If !lSel 
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
ElseIf lSel
	HS_MSGINF("Resultado(s) cancelado(s)!",STR0016,STR0017)//"Coleta cancelada!","Aten็ใo","Valida็ใo Laborat๓rio"
	FS_REFRESH()
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ FS_EDTLDOณ Autor ณ Rogerio Machado Tabosaณ data ณ 18/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ realiza a edicao das respostas do Laudo                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Gestao Hospitalar                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_EDTLDO()

Local nGD		:= 0 
Local lSel		:= .F.
Local aMntPerg	:= {}  

Private oGP8

If !lUsrMed
	HS_MSGINF("Somente usuแrios m้dicos podem editar o resultado!",STR0016,STR0017)//"Somente usuแrios m้dicos podem realizar o cancelamento do resultado!""Aten็ใo","Valida็ใo Laborat๓rio"
	Return(nil)
EndIf

For nGD := 1 To Len(oGDEXA:aCols)	
	If oGDEXA:aCols[nGD, nEXAIdMarc] == "LBTIK"
		lSel := .T.
		DbSelectArea("GPJ")
		DbSetOrder(1)
		If DbSeek(xFilial("GPJ") + oGDEXA:aCols[nGD,nEXASolici])							
	  		HS_BusResp("GPJ", {{"GPJ->GPJ_CDEXAM", oGDEXA:aCols[nGD,nEXASolici]}}, "GPJ")  		
			aMntPerg := HS_MntPerg(GPJ->GPJ_CDQUES, Nil,"Questionแrio - " + oGDEXA:aCols[nGD,nEXADESPRO], , .F., "GPJ", "oGP8",, Nil, CONTROL_ALIGN_ALLCLIENT, .T., "G",,,.T.)  		
	    	If aMntPerg[1] == 1
	    		HS_GrvResp("GPJ", {{"GPJ->GPJ_CDEXAM",  oGDEXA:aCols[nGD,nEXASolici]}, {"GPJ->GPJ_CDQUES",  GPJ->GPJ_CDQUES}} , aMntperg[2])
	    		HS_MSGINF("Altera็ใo realizada com sucesso!",STR0016,STR0017)//"Coleta cancelada!","Aten็ใo","Valida็ใo Laborat๓rio"
	       	EndIf
		EndIf 							
	EndIf	
Next nGD

If !lSel 
	HS_MSGINF("Selecione ao menos um exame!",STR0016,STR0017) //"Selecione ao menos um exame!","Aten็ใo","Valida็ใo Laborat๓rio"
EndIf

Return(Nil)
