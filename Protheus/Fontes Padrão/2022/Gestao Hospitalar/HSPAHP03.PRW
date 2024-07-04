//#INCLUDE "HSPAHP03.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//Static cDadosErro := ""
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPAHp03 ³ Autor ³ Rogerio Machado Tabosa³ data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indicadores			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gestao Hospitalar                            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP03()         

Private cCadastro	:= "Indicadores"
Private aRotina 	:={	{OemtoAnsi("Pesquisar"),  "axPesqui" , 0, 1, 0, nil}, ;    //"Pesquisar"
						{OemtoAnsi("Visualizar"), "HS_P03Atu", 0, 2, 0, nil}, ;    //"Visualizar"
						{OemToAnsi("Incluir"),    "HS_P03Atu" , 0, 3, 0, nil},; //"Incluir"
						{OemtoAnsi("Alterar"),    "HS_P03Atu", 0, 4, 0, nil}, ;    //"Alterar"
						{OemtoAnsi("Excluir"),    "HS_P03Atu", 0, 5, 0, nil}}    //"Excluir"  
		                	//{OemtoAnsi("Excluir"), "HS_P03Atu", 0, 5, 0, nil}}    //"Excluir"  

         
DbSelectArea("GTA")
DbSetOrder(1)
mBrowse(6, 1, 22, 75, "GTA",,,,,, ,,,,,,,, )

Return(Nil)

Function HS_P03ATU(cAliasP03, nRegP03, nOpcP03)

Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {} 
Local aButtons 	:= {}
Local nI		:= 0

//Local aCpoGta    := aClone(aCpoAlt) 
Private aCpoAlt 	:= { "GTA_TITULO", "GTA_HELPIN", "GTA_TIPOIN",  "GTA_TITCMB", "GTA_CMB1  ", "GTA_CMB2  ","GTA_CMB3  ","GTA_VALINI","GTA_VALFIM","GTA_APREVL"} 
Private aCpoGta 	:= { "GTA_CODIND","GTA_TITULO", "GTA_HELPIN", "GTA_TIPOIN", "GTA_TITCMB", "GTA_CMB1  ", "GTA_CMB2  ","GTA_CMB3  ","GTA_VALINI","GTA_VALFIM","GTA_APREVL"} 
Private nOpcInd   
Private cTipLoc     := ""    
Private cCodigo 	:= "0" // Codigo do Indicador
Private cTexto 		:= ""
Private oEncGta 	:= nil
Private oGetRes 	:= nil
Private oGetProc  	:= nil
Private oGetSol 	:= nil
Private oGetMat 	:= nil
Private oGetOpm 	:= nil
//Private aHeadInd := {}, aColsInd := {}
Private aHeadGtb 	:= {}, aColsGtb := {}
Private aHeadRes 	:= {}, aColsRes := {}
Private nGtbNome	:= 0

Private cMes		:= StrZero(Month(dDataBase),2)
Private cAno		:= Substr(DTOC(dDataBase),7,4)
Private dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Private dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Private dDataIniA	:= CTOD("01/01/"+cAno)
Private dDataFimA 	:= CTOD("31/12/"+cAno)
Private cMesAnt		:= IIf(cMes == "01", "12", StrZero(Val(cMes)-1,2))
Private cAnoAnt		:= Iif(cMesAnt == "12",Str(Val(cAno)-1),cAno)                           
Private dDtIniDAn	:= CTOD("01/"+cMesAnt+"/"+cAnoAnt)
Private dDtFimDAn	:= CTOD(StrZero(F_ULTDIA(dDtIniDAn),2)+"/"+cMesAnt+"/"+cAnoAnt)
Private cDatIniAn	:= DTOS(dDtIniDAn)
Private cDatFimAn	:= DTOS(dDtFimDAn)




Private aCpoGtb  := {"GTB_CODITE","GTB_NOME  ","GTB_QUERY ","GTB_FORMAT","GTB_COLOR ","GTB_COMBO "} 
//Private aCpoRes  := {"HSP_COUNT ","HSP_DESCRI"}

Private Inclui 		:= .T. 

Private nGDOpc		:= GD_UPDATE + GD_DELETE + GD_INSERT
Private aMemo		:= {}
Private nLastKey	:= 0

Hs_ExisDic({{"T","GTA"}},.T.)

aAdd(aHeadRes,{"Contador","HSP_COUNT","",  08,0, "",,"N","" ,"R",,,,"V"})  //"Pacote    "
aAdd(aHeadRes,{"Descricao","HSP_DESCRI","@!", 50,0,,,"C",         ,"R",,,,"V"}) //"Descricao "
           

 aSize := MsAdvSize() 
 aObjs := {{100, 050, .T., .T.,.T.}, ;
           {100, 050, .T., .T., .T.}} 
 aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObj := MsObjSize(aInfo, aObjs, .T.)
 aObjs := {{100, 065, .T., .T.},;
           {100, 035, .T., .T.}} 

 aInfo := {aPObj[1, 2], aPObj[1, 1], aPObj[1, 4], aPObj[1, 3], 0, 0}
 aPEnc := MsObjSize(aInfo, aObjs, .T.)    

 aObjs := {{100, 30, .T., .T.},;
           {100, 70, .T., .T.}} 

 aInfo := {aPObj[2, 2], aPObj[2, 1], aPObj[2, 4], aPObj[2, 3], 0, 0}
 aPAux := MsObjSize(aInfo, aObjs, .T.) 
   
    
 aObjs := {{13, 100, .T., .T.}, ;
           {87, 100, .T., .T.}}     	

 aInfo := {aPEnc[1, 2], aPEnc[1, 1], aPEnc[1, 4], aPEnc[1, 3], 0, 0}
 aPPac := MsObjSize(aInfo, aObjs, .T.,.T.) 
 
 
DEFINE MSDIALOG oDlgAut TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL

	oPanel1  := tPanel():New(aPObj[2, 1], aPObj[2, 2],, oDlgAut,,,,,, aPObj[2, 3], aPObj[2, 4]) //Itens da solicitacao
	oPanel1:Align := CONTROL_ALIGN_BOTTOM
	
	oPanel2 := tPanel():New(aPObj[1, 1], aPObj[1, 2],, oDlgAut,,,,,, aPObj[1, 3], aPObj[1, 4]) // Filtros e Pacientes
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	RegToMemory("GTA", nOpcP03 == 3)
	If nOpcP03 == 3 //Inclusao
		M->GTA_CODIND := GetSXENum("GTA", "GTA_CODIND",, 1) 
	EndIf
	
	oEncGta := MsMGet():New("GTA", 0, nOpcP03,,,, aCpoGta, {aPObj[2, 2], aPObj[2, 2], aPObj[1, 1], aPObj[1, 3]}, aCpoAlt, ,,,, oPanel2,, .T.,,,,,, .T.)	
	oEncGta:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	
	HS_BDados("GTB", @aHeadGtb, @aColsGtb,, 1,, " GTB->GTB_CODIND = '" + M->GTA_CODIND + "' ",,,"/",,,,,,.T.,,,,,, aCpoGtb)	
	
	nGtbNome 	:= aScan(aHeadGtb, {|aVet| aVet[2] == "GTB_NOME  "})
	nGtbFormat 	:= aScan(aHeadGtb, {|aVet| aVet[2] == "GTB_FORMAT"})		
	nGtbColor 	:= aScan(aHeadGtb, {|aVet| aVet[2] == "GTB_COLOR "})		
	nGtbCombo 	:= aScan(aHeadGtb, {|aVet| aVet[2] == "GTB_COMBO "})			
	nGtbCodIte 	:= aScan(aHeadGtb, {|aVet| aVet[2] == "GTB_CODITE"})
	nGtbQuery 	:= aScan(aHeadGtb, {|aVet| aVet[2] == "GTB_QUERY "})	

	If Empty(aColsGtb[1,nGtbCodIte])
		aColsGtb[1,nGtbCodIte] := StrZero(1,Len(GTB->GTB_CODITE))
	EndIf
	
	oGetIte := MsNewGetDados():New(aPObj[2, 1], aPObj[2, 2], aPObj[2, 3], aPObj[2, 4], nGDOpc,,,"+GTB_CODITE",,,99999,,,, oPanel1, aHeadGtb, aColsGtb)
	oGetIte:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetIte:bChange := {|| FS_CODITE()}
	oGetIte:oBrowse:bLostFocus := {|| FS_CODITE()}
	oGetIte:oBrowse:bDelete := {|| oGetIte:DelLine(),oGetIte:oBrowse:Refresh(),FS_CODITE() }
	oGetIte:oBrowse:BlDblClick := {|| FS_DbClik(oGetIte)}
	oGetIte:oBrowse:bCustomEditCol := {|| FS_DbClik(oGetIte)}
	
	FS_CODITE()
	
	For nI := 1 to Len(oGetIte:aCols) //Carrega memos cadastrados
		DbSelectArea("GTB")
		DbSetOrder(1)
		If  DbSeek(xFilial("GTB") + M->GTA_CODIND + oGetIte:aCols[nI, nGtbCodIte])
			If !Empty(GTB->GTB_QUERY)				
				AADD(aMemo,{oGetIte:aCols[nI,nGtbCodIte],Alltrim(GTB->GTB_QUERY)})
			EndIf
		EndIf
	Next nI

	If nOpcP03 == 3 .OR. nOpcP03 == 4
		aAdd(aButtons,	{"S4WB001N", {|| FS_SALVAR()}, "Salvar", "Salvar"})
	EndIf

	
	
 ACTIVATE MSDIALOG oDlgAut ON INIT EnchoiceBar(oDlgAut, {|| nOpcInd := 1,oDlgAut:End()}, ;
                                                        {|| oDlgAut:End(), nOpcInd := 0},,aButtons) 
                                                        
If nOpcInd == 0
  While __lSx8
   RollBackSxe()
  End 
Else
	If nOpcP03 == 3 .OR. nOpcP03 == 4	
		FS_SALVAR(.T.)
	ElseIf nOpcP03 == 5
		FS_EXCIND(M->GTA_CODIND)
		HS_ATTXTI()		
	EndIf
EndIf

Return(.T.)  

Static Function FS_EXCIND(cCodInd)
Local aArea   := getArea()

DbSelectArea("GTA")
DbSetOrder(1)
If DbSeek(xFilial("GTA") + cCodInd)
	Begin Transaction
		RecLock("GTA", .F., .F.)
	    DbDelete()
	    MsUnLock()             
	    WriteSx2("GTA")
	    DbSelectArea("GTB")
		DbSetOrder(1)
	    If DbSeek(xFilial("GTB") + cCodInd)
	    	While !GTB->(Eof()) .AND. GTB->GTB_CODIND = cCodInd 
				RecLock("GTB", .F., .F.)
			    DbDelete()
			    MsUnLock()             
			    WriteSx2("GTB")	    	
	    		GTB->(DbSkip())
	    	End
	    EndIf
	End Transaction
EndIf

RestArea(aArea) 
Return(Nil)


Static Function FS_DbClik(oGet)

If len(oGet:aCols) == 0
	Return(Nil)
EndIf

If oGet:oBrowse:ColPos == nGtbQuery
	FS_QUERY(oGet:nAt)
Else
	oGet:EDITCELL( oGet:OBROWSE, oGet:oBrowse:nAt, oGet:oBrowse:nColPos )
EndIf
  
Return(Nil)
      
Static Function FS_QUERY(nLinha)
Local nPos	:= 0 
Local aArea   := getArea()

DEFINE MSDIALOG oDlgM FROM	62,100 TO 500,600 TITLE "Query" PIXEL 

	If (nPos := aScan(aMemo, {| aVet | aVet[1] == oGetIte:aCols[nLinha, nGtbCodIte] .And. !Empty(aVet[2])})) == 0
		DbSelectArea("GTB")
		DbSetOrder(1)
		If  DbSeek(xFilial("GTB") + M->GTA_CODIND + oGetIte:aCols[nLinha, nGtbCodIte])
			If !Empty(GTB->GTB_QUERY)
				cTexto := GTB->GTB_QUERY
				AADD(aMemo,{oGetIte:aCols[nLinha,nGtbCodIte],cTexto})
			Else
				cTexto := ""			
			EndIf
		Else
			cTexto := ""
		EndIf
	Else
		cTexto := aMemo[nPos,2]
	EndIf

	@ 010, 009 TO 100, 240 Label "Query" OF oDlgM PIXEL
	@ 020, 015 GET oTexto VAR cTexto MEMO SIZE 215, 070 OF oDlgM PIXEL 
	
	oBtn1 := tButton():New(106, 200, "Analisar", oDlgM, {|| FS_ANAQRY()}, 030, 012,,,, .T.) 	  
	
	oPanelR := tPanel():New(050, 050,, oDlgM,,,,,,100, 100) 
	oPanelR:Align := CONTROL_ALIGN_BOTTOM 
	
	oGetRes := MsNewGetDados():New(000, 050, 100, 100, 0,,,,,,,,,, oPanelR, aHeadRes, aColsRes)
	oGetRes:oBrowse:Align := CONTROL_ALIGN_BOTTOM 
	oGetRes:oBrowse:BlDblClick := {|| Nil }    

DEFINE SBUTTON FROM 106,160 TYPE 1 ACTION (FS_CHGITE(nLinha),oDlgM:End()) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cTexto)),.F.,.T.) 

RestArea(aArea) 
Return

Static Function FS_CHGITE(nLinha) 
Local nPos := 0

If (nPos := aScan(aMemo, {| aVet | aVet[1] == oGetIte:aCols[nLinha, nGtbCodIte] })) == 0
	AADD(aMemo,{oGetIte:aCols[nLinha,nGtbCodIte],cTexto})
Else                       
	aMemo[nPos,2] := cTexto
EndIf
	
Return(Nil)


Static Function FS_CODITE()
/*Local nI	:= 0
Local nIte	:= 0
Local nGGTB	:= Len(aHeadGtb) + 1 
//oGetIte:aCols[oGetIte:nAt,]
For nI := 1 To Len(oGetIte:aCols)
	If !oGetIte:aCols[nI , nGGtb]
		nIte++
		oGetIte:aCols[nI , nGtbCodIte] := nIte	 
	Else		
		nIte++
	EndIf
Next nI   // */

Return(Nil)


Static Function FS_ANAQRY()
Local cQuery 	:= ""
Local nPosRes	:= 0 
Local aDefault	:= {0,"",.F.}
Local aStruInd	:= {}
Local nPosStru	:= 0
Local lDescr	:= .T.
//Local cAliasTmp	:= GetNextAlias() 
oGetRes:aCols	:= {}
If Len(oGetRes:aCols) >= 1 .AND. !Empty(oGetRes:aCols[1,2])
	AADD(oGetRes:aCols,aDefault)
EndIf

If Empty(cTexto)
	HS_MSGINF("Informe a pesquisa a ser analisada!","Atenção","Indicadores")
	If Len(oGetRes:aCols) == 0 
		AADD(oGetRes:aCols,aDefault)
	EndIf
	Return(Nil)
EndIf

cQuery := FS_INDQry(cTexto)

If !FS_VLDQRY(cQuery) 
	Return(Nil)
EndIf

If Len(oGetRes:aCols) == 0 
	AADD(oGetRes:aCols,aDefault)
EndIf

If !("FROM " $ cQuery)
	HS_MSGINF("Pesquisa Incorreta [Clausula FROM inexistente]!","Atenção","Indicadores")
	If Len(oGetRes:aCols) == 0 
		AADD(oGetRes:aCols,aDefault)
	EndIf	
	Return(Nil)
EndIf
                                                     
cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TMPQRYRES"

If Select("TMPQRYRES") > 0
	DbSelectArea("TMPQRYRES")
	aStruInd := DbStruct()
	If (nPosStru := aScan(aStruInd, {| aVet | aVet[1] == "CONTADOR" })) == 0
		HS_MSGINF("A coluna CONTADOR é necessária na pesquisa ","Atenção","Analise Indicadores")
		TMPQRYRES->(DbCloseArea())
		Return(Nil)
	ElseIf (nPosStru := aScan(aStruInd, {| aVet | aVet[1] == "DESCRICAO" })) == 0
		lDescr := .F.
	EndIf
EndIf
	

While !TMPQRYRES->(Eof())
	If Len(oGetRes:aCols) == 1 .AND. Empty(oGetRes:aCols[1,2])
		nPosRes := 1
	Else
		oGetRes:AddLine(.F., .F.)
	    oGetRes:lNewLine := .F.
	    nPosRes := Len(oGetRes:aCols)
	EndIf                    
	oGetRes:nAt := nPosRes    
	oGetRes:aCols[nPosRes, 1] := TMPQRYRES->CONTADOR
	oGetRes:aCols[nPosRes, 2] := IIf(lDescr,TMPQRYRES->DESCRICAO," ")
	TMPQRYRES->(DbSkip())
End

TMPQRYRES->(DbCloseArea())

oGetRes:oBrowse:Refresh()

Return(Nil)

Static Function FS_SALVAR(lOk)
Local aArea   	:= GetArea()
Local lFound	:= .F.
Local cCodInd	:= M->GTA_CODIND
Local nI		:= 0
Local nGGTB		:= Len(aHeadGtb) + 1 
Local nPosQ		:= 0

DbSelectArea("GTA")
DbSetOrder(1)
lFound := DbSeek(xFilial("GTA") + M->GTA_CODIND)

RecLock("GTA", !lFound)
//    HS_GRVCPO("GTA")            
	If !lFound
    	GTA->GTA_CODIND := HS_VSxeNum("GTA", "M->GTA_CODIND", 1)
	EndIf
	GTA->GTA_FILIAL := xFilial("GTA")
	GTA->GTA_TITULO := M->GTA_TITULO
	GTA->GTA_HELPIN := M->GTA_HELPIN
	GTA->GTA_TIPOIN := M->GTA_TIPOIN
    GTA->GTA_REFRES := M->GTA_REFRES
	GTA->GTA_TITCMB := M->GTA_TITCMB
	GTA->GTA_CMB1 	:= M->GTA_CMB1
	GTA->GTA_CMB2 	:= M->GTA_CMB2
	GTA->GTA_CMB3 	:= M->GTA_CMB3		
	GTA->GTA_VALINI	:= M->GTA_VALINI
	GTA->GTA_VALFIM := M->GTA_VALFIM
	GTA->GTA_APREVL	:= M->GTA_APREVL	
	
MsUnlock()

For nI := 1 to Len(oGetIte:aCols)
	If (nPosQ := aScan(aMemo, {| aVet | aVet[1] == oGetIte:aCols[nI , nGtbCodIte] .And. !Empty(aVet[2])})) == 0
		HS_MSGINF("Necessário atribuir uma pesquisa para o indicador!","Atenção","Indicadores")
		Return(Nil)                                                                            
	EndIf
	DbSelectArea("GTB")
	DbSetOrder(1)	
	lFound := DbSeek(xFilial("GTB") + cCodInd + oGetIte:aCols[nI , nGtbCodIte] )
	If !Empty(oGetIte:aCols[nI , nGtbNome]) .AND. !oGetIte:aCols[nI , nGGtb]		
		RecLock("GTB", !lFound)
		    //HS_GRVCPO("GTB", oGetIte:aCols, oGetIte:aHeader, nI)
		    GTB->GTB_FILIAL := xFilial("GTB")
		    GTB->GTB_CODIND := cCodInd 
			GTB->GTB_NOME 	:= oGetIte:aCols[nI , nGtbNome] 
			GTB->GTB_FORMAT := oGetIte:aCols[nI , nGtbFormat] 			
			GTB->GTB_COLOR := oGetIte:aCols[nI , nGtbColor] 			
			GTB->GTB_COMBO := oGetIte:aCols[nI , nGtbCombo] 
		    GTB->GTB_QUERY	:= aMemo[nPosQ,2]
		    GTB->GTB_CODITE	:= oGetIte:aCols[nI , nGtbCodIte]
		MsUnlock()
	ElseIf oGetIte:aCols[nI , nGGtb]
	    RecLock("GTB", .F., .F.)
	     DbDelete()
	    MsUnLock()             
	    WriteSx2("GTB")	
	EndIf
Next nI

If !lOK
	HS_MSGINF("Atualização Salva com Sucesso!","Atenção","Indicadores")
	aColsGtb := {} 
	aHeadGtb := {} 
	HS_BDados("GTB", @aHeadGtb, @aColsGtb,, 1,, " GTB->GTB_CODIND = '" + M->GTA_CODIND + "' ",,,"/",,,,,,.T.,,,,,, aCpoGtb)	
	oGetIte:SetArray(aColsGtb)
	oGetIte:oBrowse:Refresh()
EndIf

HS_ATTXTI()
RestArea(aArea)
Return

Static Function FS_INDQry(cQuery)
 Local cStr := "", xValor, cQryAux := ""

 While (nPos1 := At("[", cQuery)) > 0
  If (nPos2 := At("]", cQuery)) > 0
  
   cStr   := Substr(cQuery, nPos1 + 1 , nPos2 - nPos1 - 1 )
   xValor := &(cStr)  
   
   If ValType(xValor) == "C"
    cQryAux := xValor
   ElseIf ValType(xValor) == "N"
    cQryAux := Str(xValor)
   ElseIf ValType(xValor) == "D"
    cQryAux := "'" + DtoS(xValor) + "'"
   Else
    cQryAux := "'" + xValor + "'"
   EndIf
  
   cQuery := StrTran(cQuery, "[" + cStr, cQryAux,,1)
   cQuery := StrTran(cQuery, "]", "",,1)
   
   xValor := Nil
  Else
   HS_MsgInf("Sintaxe incorreta", "Atenção","Análise") 
   Exit
  EndIf
 End

Return(cQuery)


Static Function FS_VLDQRY(cQuery)
Local bBlock   	:= ErrorBlock(), bErro := ErrorBlock( { |e| ChekBug(e) } )
Local nHandle  	:= fCreate("Analise_Indicadores.Log", 0)
//Local lRet		:= .T.
Private lRetErro := .T.

Begin Sequence

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TMPVLD", .F., .F.)

	If Select("TMPVLD") > 0
		DbSelectArea("TMPVLD")
		DbCloseArea()
	EndIf 
  
	HS_MsgInf("Análise finalizada","Atenção","Análise EDI")

 End Sequence

 ErrorBlock(bBlock)

Return(lRetErro)

Static Function Chekbug(e)
Local cDadosErro := ""
If e:gencode > 0
 	cDadosErro := "Pilha: " + e:ERRORSTACK
	HS_MsgInf("Erro: " + e:Description + Chr(13) + Chr(10) + cDadosErro,"Atenção","Análise Indicadores")
	If Select("TMPVLD") > 0
		DbSelectArea("TMPVLD")
		DbCloseArea()
	EndIf 
	lRetErro:=.F.
EndIf
Break
Return(lRetErro)


Function HS_ATTXTI() 
Local cEnvServ := GetEnvServer()  
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
Local cNomArq	:= "" 
Local cStrGrava	:= ""
Local cArqNf        := ""

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "CONFIGPGONL.txt"
Else
	cNomArq := cDirRaiz + "\CONFIGPGONL.txt"
EndIf  


FErase(cNomArq)

cArqNf:=fCreate(cNomArq)

DbSelectArea("GTA")
DbGoTop()                                                                                                                  //5                  6                 7                    8
While !EOF()
	cStrGrava	:= Alltrim(GTA->GTA_TITULO) + "|" + "HSPPO0" + Iif(GTA->GTA_TIPOIN=="1","10",IIf(GTA->GTA_TIPOIN=="2","20",IIf(GTA->GTA_TIPOIN=="3","20","30"))) +"(" + Alltrim(Str(Recno())) + ")" + "|" + Alltrim(Str(Recno())) + "|" +  "2"  + "|" + Alltrim(GTA->GTA_HELPIN) + "|" +  Alltrim(Str(GTA->GTA_REFRES)) + "|" +  Alltrim(GTA->GTA_TITCMB) + "|" + GTA->GTA_TIPOIN + "|***" + Chr(13) + Chr(10)
	FWrite(cArqNf,cStrGrava)
	DbSkip()	
End    

FClose(cArqNf)

Return(Nil)   

