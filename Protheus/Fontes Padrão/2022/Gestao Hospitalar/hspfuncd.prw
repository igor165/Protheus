
#INCLUDE "hspfuncd.ch"
#INCLUDE "PROTHEUS.CH"      
#INCLUDE "TOPCONN.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³HS_SumDesp³ Autor ³ Cibele Ap. L. Peria   ³ Data ³ 04/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os valores sumarizados de todas as despesas de uma ³±±
±±³      			 ³ determinada guia.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNrSeqG: numero sequencial da guia                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_SumDesp(cNrSeqG)
 Local nSumDesp := 0
 Local cArq     := ""
 Local nArq     := 0
 Local cAlias   := ""
 
 DbSelectArea("GCZ")
 DbSetOrder(1)
 If DbSeek(xFilial("GCZ") + cNrSeqG)
  cArq   := IIf(GCZ->GCZ_STATUS $ "0/1", "GD", "GE")
  
  For nArq := 5 to 7
   cAlias := cArq + Str(nArq, 1)
   cPref  := cAlias + "." + cAlias
  
   cSql := "SELECT SUM(" + HS_FValDes(cAlias) + ") SUMDESP"
   cSql +=  " FROM " + RetSqlName(cAlias) + " " + cAlias
   cSql += " WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + "." + "D_E_L_E_T_ <> '*'"
   cSQL +=  " AND " + cPref + "_NRSEQG = '" + cNrSeqG + "'"
   cSQL +=  " AND " + cPref + "_GLODES = '0'"
 
   cSQL := ChangeQuery(cSQL)
   TCQuery cSQL New Alias "TMP"

   DbSelectArea("TMP")
   DbGoTop()
   If !Eof()
    nSumDesp += TMP->SUMDESP
   Endif
   DbCloseArea()

  Next nArq
 Endif 
  
Return(nSumDesp)          

Function Hs_MsgM24(cRegAte, aDesp, cAliasPr, cAliasMM, aTabDesp, cCodPla, cTitulo, cInfAdc)
Local aArea     := GetArea()
Local cUsuAuto  := IIF(HS_VldSx6({{"MV_USUAUTO"}},.F.),GetMv("MV_USUAUTO")+"/","") //Usuários que receberão notificação
Local nI        := 0         

Local nForGuia		:= 0
Local nDesp			:= 0
Local dCpoData		:= CtoD("")   
Local cCpoCodDes	:= ""
Local cCpoDesc		:= ""
Local cUsuario		:= __CUSERID
Local cMsg			:= ""
Local cMsgDesp		:= ""
Default aTabDesp  :=	{	{2, cAliasMM, "MM", nMMCODDES, nMMDATDES, nMMDDESPE, "3"},{4, cAliasPR, "PR", nPRCODDES, nPRDATDES, nPRDDESPE, "4"}}
								//{5, "GE2", "GE2", nGE2CODDES, nGE2DATSOL, nGE2DDESPE, "3"}, {6, "GE3", "GE3",nGE3CODDES, nGE3DATSOL, nGE3DDESPE, "4"}}  // RETIRADA EDICAO E CONTROLE DE ITENS COM PEDIDO DE AUTORIZACAO DO POSTO E DO ATENDIMENTO INTERNACAO (CENTRAL DE AUTORIZACOES)
                       
Default cCodPla   := ""                      
Default cTitulo   := STR0006
Default cInfAdc   := ""
 
If Empty(cUsuAuto)
	Return(nil) 
EndIf
 
PswOrder(1)
PswSeek(__CUSERID,.T.)
cUsuario  := PSWRET(1)[1][2]
 
IIf(Alias() # "GCY",DbSelectArea("GCY"),nil)
IIf(IndexOrd() # 1,DbSetOrder(1),nil)  
IIF(GCY->GCY_REGATE # cRegAte,DbSeek(xFilial("GCY")+cRegAte),nil) 
 
cMsg := STR0001+GCY->GCY_REGATE+STR0002+DtoC(GCY->GCY_DATATE)+" "+GCY->GCY_HORATE+chr(10)+chr(13) //"Atendimento: "###"           Data Atend: "
cMsg += STR0003+GCY->GCY_NOME+chr(10)+chr(13) //"Paciente: "
	
For nForGuia := 1 to Len(aDesp)
 
 If Type("oGDGcz") # "U" 
		If Len(oGdGcz:aCols) >= Len(aDesp)			
	  		cCodPla := oGdGcz:aCols[aDesp[nForGuia, 1] ,nGCZCodPla]
	    	cMsg += STR0004+oGdGcz:aCols[aDesp[nForGuia, 1] ,nGCZNRSEQG]+chr(10)+chr(13)+chr(10)+chr(13) //"Guia: "	 
			If !Empty(cInfAdc)
				cMsg    += cInfAdc+chr(10)+chr(13) 	 
			EndIf
	  
			cMsg += STR0005+chr(10)+chr(13) //"Data Solicitação    Cod Proc    Descrição"
	 
			For nI := 1 to Len(aTabDesp)
				For nDesp := 1 To Len(aDesp[nForGuia, aTabDesp[nI][1]])
					If aDesp[nForGuia, aTabDesp[nI, 1], nDesp][&("n"+aTabDesp[nI, 3]+"StaReg")] # "BR_VERMELHO"
						Loop
					EndIf
					cCpoCodDes := aDesp[nForGuia][aTabDesp[nI, 1]][nDesp][aTabDesp[nI, 4]]
					dCpoData   := aDesp[nForGuia][aTabDesp[nI, 1]][nDesp][aTabDesp[nI, 5]]	   
					cCpoDesc   := aDesp[nForGuia][aTabDesp[nI, 1]][nDesp][aTabDesp[nI, 6]]
	    
					If Hs_DespAut(aTabDesp[nI, 2], cCodPla, cCpoCodDes, dCpoData, aTabDesp[nI, 7])
						cMsgDesp += PadR(DtoC(dCpoData), 22)+PadR(cCpoCodDes, TamSx3("GD7_CODDES")[1])+Space(6)+cCpoDesc +chr(10)+chr(13)
					EndIf
	    
				Next nDesp
			Next nI
		EndIf
	EndIf
Next nForGuia 
  
If !Empty(cMsgDesp)  
	If at("/",cUsuAuto) > 0 
		While at("/",cUsuAuto) > 0
			PswOrder(2)
			If !PswSeek(SubStr(cUsuAuto,1,at("/",cUsuAuto)-1), .T.)
				cUsuAuto := SubStr(cUsuAuto, at("/",cUsuAuto)+1)
				Loop
			EndIf
			WFMessenger( cUsuario, SubStr(cUsuAuto,1,at("/",cUsuAuto)-1), cTitulo+chr(13)+chr(10)+STR0001+GCY->GCY_REGATE, cMsg+cMsgDesp, "1") //"Autorização de Itens - "
			cUsuAuto := SubStr(cUsuAuto, at("/",cUsuAuto)+1)
		EndDo
	EndIf
EndIf
RestArea(aArea)
Return(nil)

Function Hs_DespAut(cAliasDesp, cCodPla, cCodDesp, dDataRef, cOrides)
 Local lRet     := .F.          
 Local cCondOri := ""                   
 Local cCodCon  := Posicione("GCM", 2, xFilial("GCM") + cCodPla, "GCM_CODCON")
 Local cCodGpp := ""
  
 Default dDataRef := dDataBase
 
 cCondOri := "GA4_ORIDES  = '" + cOrides +"' "
 
 lRet := HS_VldVig("GA4", "GA4_FILIAL = '" + xFilial("GA4") + "' AND GA4_CODCON = '" + cCodCon + "' AND " + ;
                        	 	"GA4_CODPLA = '" + cCodPla + "' AND "+cCondOri+" AND GA4_CODDES = '" + cCodDesp + "'", ;
	                          "GA4_DATVIG",, dDataRef)
	If !lRet .And. (cAliasDesp $ "GD7/GE7/GE3")
  cCodGpp := HS_IniPadr("GA7", 1, cCodDesp, "GA7_CODGPP",,.F.)
  lRet := HS_VldVig("GA4", "GA4_FILIAL = '" + xFilial("GA4") + "' AND GA4_CODCON = '" + cCodCon + "' AND " + ;
                         	 	"GA4_CODPLA = '" + cCodPla + "' AND GA4_ORIDES  = '9' AND GA4_CODDES = '" + cCodGpp + "'", ;
	                           "GA4_DATVIG",, dDataRef)	
	EndIF
	
Return(lRet)

Function Hs_FchFt(nFont)
 Local oRet	:= TFont():New("Arial"      	  	,06,06,,.F.,,,,,.F.) 	
 
 If ValType(nFont) == "U"
  Return(oRet)
 EndIf
 
 If nFont == 0
  oRet	:= TFont():New("Arial"      	  	,07,07,,.F.,,,,,.F.)//0 	 
 ElseIf nFont == 1
  oRet	:= TFont():New("Arial"      	  	,09,08,,.F.,,,,,.F.)//1 	
 ElseIf nFont == 2
  oRet	:= TFont():New("Arial"      	  	,09,10,,.F.,,,,,.F.)//2
 ElseIf nFont == 3
  oRet	:= TFont():New("Times New Roman" 	,09,12,,.T.,,,,,.F.)//3
 ElseIf nFont == 4
  oRet	:= TFont():New("Arial"       	  	,10,13,,.T.,,,,,.F.) //4
 ElseIf nFont == 5
  oRet	:= TFont():New("Arial"      	  	,09,20,,.T.,,,,,.F.) 	//5
 ElseIf nFont == 6
  oRet := TFont():New("Arial"      ,9,8  ,.T.,.F.,5,.T.,5,.T.,.F.)//6
 ElseIf nFont == 7
  oRet := TFont():New("Arial"      ,9,10 ,.T.,.T.,5,.T.,5,.T.,.F.)//7
 ElseIf nFont == 8
  oRet := TFont():New("Arial"      ,9,14 ,.T.,.F.,5,.T.,5,.T.,.F.)//8
 ElseIf nFont == 9
  oRet := TFont():New("Arial"      ,9,16 ,.T.,.T.,5,.T.,5,.T.,.F.)//9
 ElseIf nFont == 10
  oRet := TFont():New("Arial"      ,9,18 ,.T.,.T.,5,.T.,5,.T.,.F.)//10
 ElseIf nFont == 11
  oRet := TFont():New("Courier New",10,9 ,.T.,.T.,5,.T.,5,.T.,.F.)//11
 ElseIf nFont == 12
  oRet := TFont():New("Courier New",12,-14,.T.,.T.,5,.T.,5,.T.,.F.)//12
 ElseIf nFont == 13
  oRet := TFont():New("Courier New",12,-13,.T.,.F.,5,.T.,5,.T.,.F.)//13
 EndIf             
 
Return(oRet)  

Function Hs_LockTab(aHsTravas, cAlias, cChave, nOpc)
  Local aArea    := GetArea()
  Local lRet     := .F.
  Local nI       := 0
  Default cChave := "" 
       
  If(nOpc == 2)
   RestArea(aArea)
   return(.T.)
  EndIf
  
  If ValType(cAlias) == "C"
   cAlias := {cAlias}
  EndIf
  
  For nI := 1 to Len(cAlias)
   If Empty(cChave)          
    If (nOpc == 3)
     lRet := .T.
    Else   
    If (lRet := SoftLock(cAlias[nI])) .And. ( aScan(aTravas,{|x| x[1]==Alias() .And. x[2]==RecNo()}) == 0 )
     aAdd(aHsTravas, {cAlias[nI], &(cAlias[nI]+"->(RecNo())"), .F.})
    EndIf
    EndIf 
   Else
    If (lRet := LockByName(cAlias[nI] + cChave)) .And. ( aScan(aTravas,{|x| x[1]==Alias() .And. x[2]==cChave}) == 0 )
     aAdd(aHsTravas, {cAlias[nI], cAlias[nI] + cChave, .T.})    
    EndIf
   EndIf
  Next nI
  
  RestArea(aArea)
Return(lRet)                                                                    

Function HS_UnLockT(aHsTravas)

Local aArea 	:= GetArea()
Local nCntFor	:= 0

If ( aHsTravas!=Nil )
	For nCntFor := 1 To Len(aHsTravas)
  
  If aHsTravas[nCntFor,3]
    UnLockByName(aHsTravas[nCntFor,2])
		Else
   dbSelectArea(aHsTravas[nCntFor,1])
		 dbGoto(aHsTravas[nCntFor,2])
		 MsUnLock()
  EndIf      
  
	Next nCntFor
EndIf

RestArea(aArea)

Return(nil)
//Function HS_ImpBox(nIniVer, nIniHor, nFimVer, nFimHor, cTexto, nColTitu, nCarac, nLinSep, nCorBack, nCorTitu, cConteudo, oFontCont, oFontTit, lCxAberta)
Function HS_ImpBox(aCoords, aTitulo, aTexto, aSepara, nCorBack, lCxAberta, oPrint)

 Local nCntFor  := 0
 //aCoords
 Local nTop := 0, nLeft := 0, nBottom := 0, nRight := 0  
 //aTitulo
 Local cTitulo := "", nColTitu := 3, nCorTitu := 0, oFontTit  
 //aTexto
 Local cTexto  := "", nCorText := 0, oFontText, lCenter := 0     
 //aSepara
 Local nCarac  := 0, nAltSep   := 0
        
 Default aTitulo   := {}   
 Default aTexto    := {}
 Default aSepara   := {}
 Default nCorBack  := nil//Hs_Color(16)
 Default lCxAberta := .F.  
 Default oPrint  := nil
       
 If oPrint == Nil .Or. Len(aCoords) == 0
  Return(.F.)
 EndIf                                 
 
 nTop    := aCoords[1]
 nLeft   := aCoords[2]
 nBottom := aCoords[3]
 nRight  := aCoords[4] 
 
 oPrint:Line(nTop   , nLeft , nBottom, nLeft)  //Linha Vertical |...
 oPrint:Line(nBottom, nLeft , nBottom, nRight) // Linha Horizontal :___:
 oPrint:Line(nTop   , nRight, nBottom, nRight) //Linha Vertical ...|
 
 cTitulo  := IIf(Len(aTitulo) > 0, aTitulo[1], "")
 nColTitu := IIf(Len(aTitulo) > 1 .And. (!Empty(aTitulo[2]) .Or. aTitulo[2] == 0), aTitulo[2], 3)
 nCorTitu := IIf(Len(aTitulo) > 2 .And. (!Empty(aTitulo[3]) .Or. aTitulo[3] == 0), aTitulo[3], Hs_Color(0))
 oFontTit := IIf(Len(aTitulo) > 3, aTitulo[4], TFont():New("Courier New", 06, 06, , .T., , , , .T., .F.))
 
 If !Empty(cTitulo)
  nWidth   := oPrint:GetTextWidth(cTitulo, oFontTit)/IIF(oPrint:GetOrientation() == 1,2.5,2) 
  nHeigth  := oPrint:GetTextHeight(" ", oFontTit)/2
  nColTitu += nLeft
  
  If !lCxAberta 
  oPrint:Line(nTop, nLeft, nTop, (nColTitu - 5)) // Linha Vertical até Inicio do Texto  
  oPrint:Say(nTop - nHeigth, nColTitu, cTitulo, oFontTit,,nCorTitu)  //Imprime Texto  
  oPrint:Line(nTop ,IIF(nColTitu + nWidth > nRight, nRight, nColTitu + nWidth), nTop, nRight) // Imprime Restante da Linha
  Else
   oPrint:Say(nTop - nHeigth, nColTitu, cTitulo, oFontTit,,nCorTitu)  //Imprime Texto  
  EndIf   
 ElseIf !lCxAberta 
  oPrint:Line(nTop, nLeft , nTop, nRight)
 EndIf     

 If nCorBack <> Nil
  oBrush   := TBrush():New("", nCorBack)
  oPrint:FillRect({nTop, nLeft , nBottom, nRight}, oBrush) 
 Endif
                        
 If Len(aTexto) > 0
  cTexto    := IIf(Len(aTexto) > 0 , aTexto[1], "")
  nCorText  := IIf(Len(aTexto) > 1 , aTexto[2], Hs_Color(0))
  oFontText := IIf(Len(aTexto) > 2 , aTexto[3], TFont():New("Courier New", 06, 06, , .T., , , , .T., .F.))
  lCenter    := IIf(Len(aTexto) > 3 , aTexto[4], .F.)
 EndIf
 
 If Len(aSepara) > 0 
  nCarac   := IIf(Len(aSepara) > 0 , aSepara[1], 0)
  nAltSep  := IIf(Len(aSepara) > 1 , aSepara[2]+nTop, nTop+(nBottom - nTop) * 0.3)
 
 
  For nCntFor := 1 to nCarac
   
   oPrint:Line(nAltSep, nLeft + (((nRight - nLeft)/nCarac)*nCntFor), nBottom, nLeft + (((nRight - nLeft)/nCarac)*nCntFor))
  
   If !Empty(cTexto)                              
    nPos :=  (nRight-nLeft)/nCarac
    oPrint:Say( nTop +((nBottom - nTop)/4), nLeft + ((nCntFor-1)*nPos)+(nPos*0.25), SUBSTR(cTexto, nCntFor, 1), oFontText)   
   EndIf   
  
  Next nCntFor 
 ElseIf !Empty(cTexto)                                          
  If lCenter               
   
   nPos := ((nRight - nLeft)/2) - (oPrint:GetTextWidth(cTitulo, oFontTit)/5.6)
   
    oPrint:Say( nTop +((nBottom - nTop)/4), nLeft + nPos, cTexto, oFontText)     
  Else
   oPrint:Say( nTop +((nBottom - nTop)/4), nLeft+5, cTexto, oFontText)    
  EndIf
 EndIf
 
Return(Nil)

Function Hs_RCpCtrl(cAlias, cCpoCodDes, cCpoQtd, nIndice)
 Local aArea := getArea()
 Local cRet  := ""
 Local nSoma := 0
 
 Default nIndice := 1111
 
 DbSelectArea(cAlias)
 DbGoTop()
 
 While &(cAlias)->(!EoF())
  nSoma += val(&(cAlias+"->"+cCpoCodDes)) + &(cAlias+"->"+cCpoQtd)
  DbSkip()
 EndDo                       
  
 nSoma := (nSoma % nIndice) + nIndice

 DbSelectArea(cAlias)
 DbGoTop()
 RestArea(aArea)
Return(nSoma)
           
Function Hs_VldCns(cCNS)
Return(IIF(Substr(cCNS,1,1) $ "7/8/9",Fs_VldCnsP(cCNS),Fs_VldCnsD(cCNS)))         

//Valida Cns Definitivo
Static Function Fs_VldCNSD(cCNS)
 Local lRet := .F.  
 Local cRad   := '000'
 
 If Len(cCNS) < 15
  Return(lRet)
 EndIf

 If (nDig := 11 - (Fs_SomaCns(cCns) % 11)) == 11
  nDig := 0
 ElseIf nDig == 10
  nDig := (11 - (Fs_SomaCns(cCns,,2) % 11))
  cRad := '001'
 EndIf
 
 lRet := SubStr(cCNS, 1, 11)+cRad+AllTrim(Str(nDig)) == cCns
 
Return(lRet)    

//Valida Cns Provisório
Static Function Fs_VldCNSP(cCNS) 
 If Len(cCNS) < 15
  Return(.F.)
 EndIf 
Return(Fs_SomaCns(cCns, 15, ,15) % 11 == 0)    
          
Static Function Fs_SomaCns(cCns, nMulti, nAdiciona, nFator)

 Local nSoma := 0, nI := 0
 
 Default nAdiciona := 0                             
 Default nMulti    := 15                            
 Default nFator    := 11
 
 For nI := 1 to nFator
  
  nSoma += val( substr(cCNS,nI,1) ) * nMulti
  
  nMulti--
 Next
 
Return(nSoma+nAdiciona) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³HS_GBHXPLS³ Autor ³ Rogerio Tabosa      ³ Data ³ 13/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera registro do paciente/beneficiario vindo do PLS na GBH ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMatric: Matricula/Carteirinha do Paciente no PLS          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GBHXPLS(cMatric)
Local aArea		:= GetArea()
Local cQryBA1, cQryBG9,cQryBI3,cQryBA0 	:= ""   
Local cCodPac	:= ""
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", " ")	// Pega a empresa de trabalho do PLS
//Local cFilTrab	:= GetNewPar("MV_FILIPLS", " ")	// Pega a filial de trabalho do PLS
Local cConvPLS	:= GetMv("MV_CONVPLS")	// Verifica qual o convenio da integracao PLS x GH
Local nSaveSx8Len := GetSx8Len()
Local cFilHsp	:= PADR(GetNewPar("MV_FILIHSP", " "),FWSizeFilial())//GetNewPar("MV_FILIHSP", " ")	// Pega a filial de trabalho do HSP

Private	cFilAnt := xFilial("BBD")
Private	cFilAtu	:= xFilial("BBD")
Hs_TabPLS("A",cFilAtu, .T.)
DbSelectArea("GD4")
DbSetOrder(3)
If DbSeek(cFilHsp + cMatric)
	Return(GD4->GD4_REGGER)
EndIf
Hs_TabPLS("F",cFilAtu, .T.)
//Hs_TabPLS("A",cFilAtu)	// Abre as tabelas da empresa referente ao PLS
// Faz verificacao do usuario dentro do PLS e retorna o nome do mesmo
cQryBA1 := "SELECT BA1_NOMUSR, BA1_SEXO, BA1_DATNAS, BA1_MAE, BA1_DRGUSR, BA1_ORGEM, BA1_CPFUSR,"
cQryBA1	+= " BA1_PAI, BA1_ESTCIV, BA1_CEPUSR, BA1_CODMUN, BA1_ESTADO, BA1_ENDERE, BA1_DTVLCR,"
cQryBA1 += " BA1_NR_END, BA1_BAIRRO, BA1_COMEND, BA1_CORNAT, BA1_ESCOLA, BA1_TELEFO, BA1_SANGUE,"
cQryBA1 += " BA1_CODEMP, BA1_DATINC, BA1_CODCLI, BA1_LOJA, BA1_CODSET, BA1_LOCATE, BA1_DDD,"
cQryBA1 += " BA1_CODPLA, BA1_CODINT, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMTIT, BA1_VERSAO,"
cQryBA1 += " BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_TIPOUS, BA3_CODPLA, BA3_VERSAO "
cQryBA1 += "FROM " + RetSqlName("BA1") + " BA1, " + RetSqlName("BA3") + " BA3 "
cQryBA1 += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
cQryBA1 += "  AND BA3.BA3_FILIAL = '" + xFilial("BA3") + "' "
cQryBA1 += "  AND BA1.D_E_L_E_T_ <> '*' "
cQryBA1 += "  AND BA3.D_E_L_E_T_ <> '*' "
cQryBA1 += "  AND BA1.BA1_CODINT = BA3.BA3_CODINT "
cQryBA1 += "  AND BA1.BA1_CODEMP = BA3.BA3_CODEMP "
cQryBA1 += "  AND BA1.BA1_MATRIC = BA3.BA3_MATRIC "
	cQryBA1 += "  AND BA1_CODINT = '" + SubStr(cMatric,1,4) + "' "
cQryBA1 += "  AND BA1_CODEMP = '" + SubStr(cMatric,5,4) + "' "
cQryBA1 += "  AND BA1_MATRIC = '" + SubStr(cMatric,9,6) + "' "
cQryBA1 += "  AND BA1_TIPREG = '" + SubStr(cMatric,15,2) + "' "
cQryBA1 += "  AND BA1_DIGITO = '" + SubStr(cMatric,17,1) + "' "
cQryBA1 += "  OR BA1_MATANT = '" + cMatric + "' "
cQryBA1 += "ORDER BY BA1_NOMUSR"

cQryBA1 := ChangeQuery(cQryBA1)
TCQUERY cQryBA1 NEW ALIAS "BA1USR"

DbSelectArea("BA1USR")

//Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS


DbSelectArea("BA1USR")

Hs_TabPLS("A",cFilAtu, .T.)

GBH->(RecLock("GBH",.T.))
GBH->GBH_FILIAL	:= xFilial("GBH")
GBH->GBH_CODPAC	:= cCodPac := getSx8Num("GBH","GBH_CODPAC")
If BA1USR->BA1_SEXO == "1"
	GBH->GBH_SEXO	:= "0"		//Masculino
Else
	GBH->GBH_SEXO	:= "1"		//Feminino
EndIf
GBH->GBH_NOME	:= ALLTRIM(BA1USR->BA1_NOMUSR)
GBH->GBH_DTNASC	:= StoD(BA1USR->BA1_DATNAS)
GBH->GBH_NOMMAE	:= ALLTRIM(BA1USR->BA1_MAE)
GBH->GBH_RG		:= BA1USR->BA1_DRGUSR
GBH->GBH_ORGEMI	:= BA1USR->BA1_ORGEM
GBH->GBH_CPF	:= BA1USR->BA1_CPFUSR
GBH->GBH_NOMPAI	:= ALLTRIM(BA1USR->BA1_PAI)
If BA1USR->BA1_ESTCIV == "C"
	GBH->GBH_ESTCIV	:= "0"
ElseIf BA1USR->BA1_ESTCIV == "S"
	GBH->GBH_ESTCIV	:= "1"
ElseIf BA1USR->BA1_ESTCIV == "M"
	GBH->GBH_ESTCIV	:= "3"
ElseIf BA1USR->BA1_ESTCIV == "V"
	GBH->GBH_ESTCIV	:= "4"
Else
	GBH->GBH_ESTCIV	:= "2"
EndIf
GBH->GBH_CEP	:= BA1USR->BA1_CEPUSR
GBH->GBH_MUN	:= BA1USR->BA1_CODMUN
GBH->GBH_EST	:= BA1USR->BA1_ESTADO
GBH->GBH_END	:= ALLTRIM(BA1USR->BA1_ENDERE)
GBH->GBH_NUM	:= BA1USR->BA1_NR_END
GBH->GBH_BAIRRO	:= ALLTRIM(BA1USR->BA1_BAIRRO)
GBH->GBH_COMPLE	:= BA1USR->BA1_COMEND
GBH->GBH_CORPEL	:= BA1USR->BA1_CORNAT
GBH->GBH_ESCOLA	:= BA1USR->BA1_ESCOLA
GBH->GBH_TEL	:= AllTrim(BA1USR->BA1_DDD) + AllTrim(BA1USR->BA1_TELEFO)
GBH->GBH_TPSANG	:= BA1USR->BA1_SANGUE
GBH->GBH_DATCAD	:= StoD(BA1USR->BA1_DATINC)

Hs_TabPLS("F",cFilAtu, .T.)

cQryBG9 := "SELECT BG9_HSPEMP "
cQryBG9 += "FROM " + RetSqlName("BG9") + " "
cQryBG9 += "WHERE BG9_FILIAL = '" + xFilial("BG9") + "' "
cQryBG9 += "  AND D_E_L_E_T_ = ' ' "
cQryBG9 += "  AND BG9_CODIGO = '" + BA1USR->BA1_CODEMP + "' "

cQryBG9 := ChangeQuery(cQryBG9)
TCQUERY cQryBG9 NEW ALIAS "BG9USR"

DbSelectArea("BG9USR")

// Fecha as tabelas referente ao PLS

GBH->GBH_CODEMP	:= BG9USR->BG9_HSPEMP

aRetCli :=	PLSAVERNIV(subs(cMatric,1,4),Subs(cMatric,5,4),Subs(cMatric,9,6),BA1USR->BA3_TIPOUS,;
BA1USR->BA3_CONEMP,BA1USR->BA3_VERCON,BA1USR->BA3_SUBCON,BA1USR->BA3_VERSUB,;
nil,Subs(cMatric,15,2),nil,cEmpTrab)

Hs_TabPLS("A",cFilAtu, .T.)

If Len(aRetCli) > 0
	GBH->GBH_CODCLI		:= aRetCli[1][1]
	GBH->GBH_LOJA		:= aRetCli[1][2]
Else
	GBH->GBH_CODCLI		:= ""
	GBH->GBH_LOJA		:= ""
EndIf

GBH->GBH_CODLOC	:= BA1USR->BA1_CODSET
GBH->GBH_IDPATE	:= BA1USR->BA1_LOCATE
GBH->GBH_HORCAD	:= TIME()
GBH->GBH_USRCAD	:= cUserName
GBH->GBH_LOGARQ	:= HS_LOGARQ()
While GetSx8Len() > nSaveSx8Len
	GBH->(ConfirmSX8())
End
GBH->(MsUnLock())

GD4->(RecLock("GD4",.T.))
GD4->GD4_FILIAL	:= xFilial("GD4")
GD4->GD4_REGGER	:= GBH->GBH_CODPAC
GD4->GD4_DTVALI	:= StoD(BA1USR->BA1_DTVLCR)
GD4->GD4_MATRIC	:= ALLTRIM(BA1USR->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))
GD4->GD4_NOMTIT	:= ALLTRIM(BA1USR->BA1_NOMTIT)
If !Empty(BA1USR->BA1_CODPLA)
	GD4->GD4_CODIGO := BA1USR->BA1_CODPLA
Else
	GD4->GD4_CODIGO := BA1USR->BA3_CODPLA
EndIf
GD4->GD4_CODCON := cConvPLS
GD4->GD4_IDPADR	:= "1"				// Plano Padrao
GD4->GD4_CODINT	:= BA1USR->BA1_CODINT
GD4->GD4_CODIGO	:= BA1USR->BA1_CODEMP
If !Empty(BA1USR->BA1_VERSAO)
	GD4->GD4_VERCON := BA1USR->BA1_VERSAO
Else
	GD4->GD4_VERCON := BA1USR->BA3_VERSAO
EndIf

Hs_TabPLS("F",cFilAtu, .T.)

// Seleciona o codigo do plano no GH referente a operadora, plano e versao do PLS
cQryBI3 := "SELECT BI3_HSPPLA, BI3_DESCRI "
cQryBI3	+= "FROM " + RetSqlName("BI3") + "  "
cQryBI3 += "WHERE BI3_FILIAL = '" + xFilial("BI3") + "' "
cQryBI3 += "  AND D_E_L_E_T_ <> '*' "
cQryBI3 += "  AND BI3_CODINT = '" + BA1USR->BA1_CODINT + "' "
If !Empty(BA1USR->BA1_CODPLA)
	cQryBI3 += "  AND BI3_CODIGO = '" + BA1USR->BA1_CODPLA + "' "
Else
	cQryBI3 += "  AND BI3_CODIGO = '" + BA1USR->BA3_CODPLA + "' "
EndIf

cQryBI3 := ChangeQuery(cQryBI3)
TCQUERY cQryBI3 NEW ALIAS "BI3USR"

DbSelectArea("BI3USR")


GD4->GD4_CODPLA	:= BI3USR->BI3_HSPPLA
GD4->GD4_DESCRI := BI3USR->BI3_DESCRI
GD4->GD4_IDEATI	:= "1"

cQryBA0 := "SELECT BA0_NOMINT "
cQryBA0 += "FROM " + RetSqlName("BA0") + " "
cQryBA0 += "WHERE BA0_FILIAL = '" + xFilial("BA0") + "' "
cQryBA0 += "  AND D_E_L_E_T_ = ' ' "
cQryBA0 += "  AND BA0_CODIDE = '" + SubStr(BA1USR->BA1_CODINT,1,1) + "' "
cQryBA0 += "  AND BA0_CODINT = '" + SubStr(BA1USR->BA1_CODINT,2,3) + "' "

cQryBA0 := ChangeQuery(cQryBA0)
TCQUERY cQryBA0 NEW ALIAS "NOMOPE"

Hs_TabPLS("A",cFilAtu, .T.)

DbSelectArea("NOMOPE")

GD4->GD4_DESINT := NOMOPE->BA0_NOMINT

GD4->(MsUnLock())    

Hs_TabPLS("F",cFilAtu, .T.)

If Select("BA1USR") > 0
	DbSelectArea("BA1USR")
	DbCloseArea()
EndIf
If Select("BI3USR") > 0
	DbSelectArea("BI3USR")
	DbCloseArea()
EndIf
If Select("GBHUSR") > 0
	DbSelectArea("GBHUSR")
	DbCloseArea()
EndIf
If Select("BA0USR") > 0
	DbSelectArea("BA0USR")
	DbCloseArea()
EndIf
If Select("BG9USR") > 0
	DbSelectArea("BG9USR")
	DbCloseArea()
EndIf
If Select("NOMOPE") > 0
	DbSelectArea("NOMOPE")
	DbCloseArea()
EndIf
If Select("BI3USR") > 0
	DbSelectArea("BI3USR")
	DbCloseArea()
EndIf
 
RestArea(aArea)
Return(cCodPac)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³HS_GCYXPLS³ Autor ³ Rogerio Tabosa      ³ Data ³ 13/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera registro do atendimento do paciente vindo do PLS na GCY³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegGer: Codigo do Paciente no cadastro de paciente GBH    ³±±
±±³          ³ cAtePls: Codigo do Atendimento no PLS BTH BBD              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GCYXPLS(cRegGer, cAtePls, cCodCBO, cMatric, cStatus)
Local aArea		:= GetArea()
Local cRegAte	:= ""
Local cSql		:= ""
//Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", " ")	// Pega a empresa de trabalho do PLS
//Local cFilTrab	:= GetNewPar("MV_FILIPLS", " ")	// Pega a filial de trabalho do PLS
Local cConvPLS	:= GetMv("MV_CONVPLS")	// Verifica qual o convenio da integracao PLS x GH
Local cEmpHsp	:=IIF(HS_VldSx6({{"MV_EMPRHSP"}},.T.),GetMv("MV_EMPRHSP"),"")

Private	cFilAnt := xFilial("BBD")
Private	cFilAtu	:= xFilial("BBD")

Hs_TabPLS("A",cFilAtu, .T.)

If !(Empty(cAtePls) .AND. cStatus $ "5/6")
	cSql := " SELECT GCY_REGATE FROM GCY" + cEmpHsp + "0 GCY "
	cSql += " WHERE GCY_CDATPL  = '" + cAtePls + "' AND GCY_REGGER = '" + cRegGer + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY_FILIAL = '" + xFilial("GCY") + "'"

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "EXATE"   

	DbSelectArea("EXATE")
	If !Eof()
		cRegAte :=  EXATE->GCY_REGATE 
		DbSelectArea("EXATE")
		DbCloseArea()
		Return(cRegAte)
	EndIf
EndIf

If Select("EXATE") > 0
	DbSelectArea("EXATE")
	DbCloseArea()
EndIf

DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + cRegGer)

DbSelectArea("GA9")
DbSetOrder(1)
DbSeek(xFilial("GA9") + cConvPLS)

RecLock("GCY", .T.)
	GCY->GCY_FILIAL	:= xFilial("GCY")
	GCY->GCY_REGATE := cRegAte := getSx8Num("GCY","GCY_REGATE")//HS_VSxeNum("GCY", "GCY->GCY_REGATE", 1)
	GCY->GCY_DTNASC := GBH->GBH_DTNASC
	GCY->GCY_DATATE := dDataBase
	GCY->GCY_IDADE 	:= HS_A58AGE(GBH->GBH_DTNASC, GCY->GCY_DATATE)
	GCY->GCY_SEXO   := GBH->GBH_SEXO
	GCY->GCY_REGGER := cRegGer
	GCY->GCY_NOME   := GBH->GBH_NOME
	GCY->GCY_CODCRM	:= GA9->GA9_CRMVIR
	GCY->GCY_CRMANM := GA9->GA9_CRMVIR
	GCY->GCY_CODCLI	:= GA9->GA9_CLIPAD
	GCY->GCY_ORIPAC	:= GA9->GA9_ORIPAD
	GCY->GCY_CARATE	:= GA9->GA9_CARPAD
	GCY->GCY_REGIME	:= "1"
	GCY->GCY_ATENDI	:= "1" //Ambulatorio
	GCY->GCY_HORATE	:= TIME()
	GCY->GCY_CODLOC :=	GA9->GA9_LOCATP
	GCY->GCY_ATENDE := cUserName
	GCY->GCY_LOCATE	:=	GA9->GA9_LOCATP
	GCY->GCY_STATUS := "0"
	GCY->GCY_MATRIC	:= cMatric
	GCY->GCY_CDATPL	:= cAtePls    
	GCY->GCY_ACITRA	:= "0"
	ConfirmSX8()
MsUnlock()    

Hs_TabPLS("F",cFilAtu, .T.)

RestArea(aArea)
Return(cRegAte)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³HS_GCZXPLS³ Autor ³ Rogerio Tabosa      ³ Data ³ 13/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera registro da Guia do paciente vindo do PLS na GCZ      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegAte: Codigo do Atendimento do paciente vindo do PLS    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GCZXPLS(cRegAte, cCodPla)
Local aArea		:= GetArea()
Local cNrSeqG	:= ""
Local cConvPLS	:= GetMv("MV_CONVPLS")	// Verifica qual o convenio da integracao PLS x GH

Private	cFilAnt := xFilial("BBD")
Private	cFilAtu	:= xFilial("BBD")     

Hs_TabPLS("A",cFilAtu, .T.)

DbSelectArea("GCZ")
DbSetOrder(2)
If DbSeek(xFilial("GCZ") + cRegAte)
	Return(GCZ->GCZ_NRSEQG)
EndIf

DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + cRegAte) 

DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + GCY->GCY_REGGER)

DbSelectArea("GA9")
DbSetOrder(1)
DbSeek(xFilial("GA9") + cConvPLS) 

RecLock("GCZ", .T.)
	GCZ->GCZ_FILIAL	:= xFilial("GCZ")
	GCZ->GCZ_REGATE := cRegAte 
	GCZ->GCZ_DATATE := dDataBase
	GCZ->GCZ_REGGER := GCY->GCY_REGGER
	GCZ->GCZ_NOME   := GCY->GCY_NOME
	GCZ->GCZ_CODTPG := GA9->GA9_CDGPLA
	GCZ->GCZ_CODCON := cConvPLS
	GCZ->GCZ_CODPLA := cCodPla
	GCZ->GCZ_FILFAT := xFilial("GCZ")
	GCZ->GCZ_FILATE := xFilial("GCZ")
	GCZ->GCZ_STATUS := "0"
	GCZ->GCZ_NRSEQG := cNrSeqG := getSx8Num("GCZ","GCZ_NRSEQG")//HS_VSxeNum("GCZ", "GCZ->GCZ_NRSEQG", 1)
	GCZ->GCZ_LOGARQ := HS_LOGARQ()
	GCZ->GCZ_ATENDI := "1"
	GCZ->GCZ_LOCATE := GCY->GCY_LOCATE
	GCZ->GCZ_DCPARI := dDataBase
	GCZ->GCZ_DCPARF := dDataBase 
	ConfirmSX8()	
MsUnlock()
             
Hs_TabPLS("F",cFilAtu, .T.)

RestArea(aArea)

Return(cNrSeqG)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³HS_PRPENEN³ Autor ³ Rogerio Tabosa        ³ Data ³ 11/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza prescrições pendentes de administração ou        ³±±
±±³          ³ devolução pela enfermagem (GNR)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegAte -> Registro de Atendimento do paciente             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_PRPENEN(cRegAte)

Local aArea := getArea()
Local cSql  := ""
Local cTitulo  := STR0009 //"Medicamentos pendentes de Administração ou Devolução (Enfermagem)"
Local aHeadGHX := {}, aColsGHX := {}, nUGHX := 0
Local nOpca := 0, nX := 0
Local aCpoGHX  := {"B1_COD","B1_DESC","GNR_DATPRE","GNR_HORPRE"}
//Local aCpoGNR  := {"GHX_CDMEDI","GHX_APRESE","GHX_DATPRE"}
Local aJoin		:= {}
Local oGDGHX 

aJoin := {	{" JOIN " + RetSqlName("GNR") + " GNR", "GNR_HORPRE"  , " GNR.GNR_STATUS = '2' AND GNR.GNR_DEVOLV = '0' AND GNR.GNR_ADMINI = '0' AND GNR.D_E_L_E_T_ <> '*' AND GNR.GNR_PRODUT=GHX.GHX_CDMEDI AND GNR.GNR_SEQPRE=GHX.GHX_SEQPRE AND GNR.GNR_REGATE=GHX.GHX_REGATE AND GNR.GNR_FILIAL = '" + xFilial("GNR") + "' ", "GNR_HORPRE"},;
			{" JOIN " + RetSqlName("SB1") + " SB1", "B1_COD"     , " SB1.B1_COD = GNR.GNR_PRODUT AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' ", "B1_COD"},;
 			{"" , "SB1.B1_DESC",, "B1_DESC"},;
 			{"" , "GNR.GNR_DATPRE",, "GNR_DATPRE"}}

HS_BDados("GHX", @aHeadGHX, @aColsGHX,@nUGHX, 1,, " GHX.GHX_REGATE = '" + cRegAte + "' AND GHX.D_E_L_E_T_ <> '*' AND GHX.GHX_FILIAL = '" + xFilial("GHX") + "'",,,"GHX_APRESE/GNR_DATPRE/GNR_HORPRE",,,,,,.T.,,,.T.,,, aCpoGHX,aJoin,,"GNR_DATPRE,GHX_CDMEDI")

If Len(aColsGHX) == 0 
	RestArea(aArea)
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo From 000, 000 To 300, 500 Of oMainWnd Pixel   
	 
	oGDGHX := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHeadGHX, aColsGHX)
	oGDGHX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
	oGDGHX:oBrowse:BlDblClick := { || nOpca := 1, oDlg:End() }
 		
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{ || nOpca := 1, oDlg:End() },{|| nOpca := 0, oDlg:End()})
	 
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_INCLGD4  ºAutor  ³Microsiga           º Data ³  10/22/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Inclusão e Busca de Convenio conforme a Mativid do RDC    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



Function HS_INCLGD4(cRegger,cmatvid)
Local aArea		:= GetArea()
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", " ")	// Pega a empresa de trabalho do PLS
Local nSaveSx8Len := GetSx8Len()
LOCAL lIncNovo:=.T.
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", "99")	// Pega a empresa de trabalho do PLS
Local cFilTrab	:= PADR(GetNewPar("MV_FILIPLS", " "),FWSizeFilial())	// Pega a filial de trabalho do PLS
Local cMatricula	:=""
Local nOrdem	:= 1

Private cFilHsp	:= PADR(GetNewPar("MV_FILIHSP", " "),FWSizeFilial())//GetNewPar("MV_FILIHSP", " ")	// Pega a filial de trabalho do HSP
Private  cConvPLS	:= GetMv("MV_CONVPLS")	// Verifica qual o convenio da integracao PLS x GH



Hs_TabPLS("A",cFilTrab)	// Abre as tabelas da empresa referente ao PLS

If GBH->(FieldPos("GBH_MATVID")) > 0   
	nOrdem := 7
EndIf

DbSelectArea("BA1")
DbSetOrder(nOrdem) //GBH_FILIAL + GBH_MATVID
IF MsSeek(xFilial("BA1") + cMatVid)
	While BA1->(!Eof()) .and.  xFilial("BA1") == BA1->BA1_FILIAL .And. cMatVid == BA1->BA1_MATVID
		
		DbSelectArea("BA0")
		DbSetOrder(1)
		DbSeek(xFilial("BA0") + BA1->BA1_CODINT)
		
		DbSelectArea("BA3")
		DbSetOrder(1)
		If DbSeek(xFilial("BA3") + BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC)
			cCodPlaGH	:= Posicione("BI3",1,xFilial("BI3")+BA1->BA1_CODINT+BA3->BA3_CODPLA,"BI3_HSPPLA")
			cMatricula:= PadR(AllTrim(BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)),len(GD4->GD4_MATRIC))
			Hs_TabPLS("F",cFilTrab)

			DbSelectArea("GD4")
			GD4->(	DbSetOrder(1))   //GD4_FILIAL, GD4_REGGER, GD4_CODPLA, R_E_C_N_O_, D_E_L_E_T_
			IF GD4->(DbSeek(cFilHsp + cRegger  ))
				GD4->(	DbSetOrder(3))   //GD4_FILIAL, GD4_REGGER, GD4_CODPLA, R_E_C_N_O_, D_E_L_E_T_
					If GD4->(DbSeek(cFilHsp + cMatricula  )) .and. Empty(GD4->GD4_CODCON) .OR. GD4->GD4_CODCON == cConvPLS .AND. GD4->GD4_CODPLA == cCodPlaGH
					  //	   IF GD4->GD4_CODPLA == cCodPlaGH
								FS_AtuGD4(cRegger,cFilHsp,.T.,"1",cMatricula)	
					 //		Else 
					//			FS_AtuGD4(cRegger,cFilHsp,.T.,Iif(!Empty(cCodPlaGH),"1","0"),cMatricula)		
					// 		Endif	
				   /*	ElseIF  !Empty(cCodPlaGH) 		
				   			FS_AtuGD4(cRegger,cFilHsp,.F.,"0")
					Endif */		

				   	ElseIF !Empty(cCodPlaGH) 		
				   			FS_AtuGD4(cRegger,cFilHsp,.F.,Iif(!Empty(cCodPlaGH),"1","0"),cMatricula)  // se não for plano padrão do RDC
					Endif		
														
			ElseiF !Empty(cCodPlaGH)  
				FS_AtuGD4(cRegger,cFilHsp,.F.,Iif(!Empty(cCodPlaGH),"1","0"),cMatricula)   //Se possui o Registro na GBH e não Possui nenum registro na GD4 vou Incluir
			Endif
			
		Endif
		BA1->(DbSkip())
	EndDo
	FS_GD4ATUPD(cRegger)
Endif


If Select("BA1") > 0
	DbSelectArea("BA1")
	DbCloseArea()
EndIf

If Select("GD4") > 0
	DbSelectArea("GD4")
	DbCloseArea()
EndIf

RestArea(aArea)

Return(.t.)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_BuscGD4 ºAutor  ³Microsiga           º Data ³  10/22/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Inclusão de Convenio/Plano da Vida do PLS no RDC         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function  FS_AtuGD4(creger,cFili,lachou,cPpadr,cMatricula)
local aCGD4 := {}
local cSQL:=""
Local aArea		:= GetArea()
local lret:=.F.
Local i:=1


GD4->(RecLock("GD4",!lachou))
GD4->GD4_FILIAL	:= cFili
GD4->GD4_REGGER	:= creger
GD4->GD4_DTVALI	:= iif(!Empty(BA1->BA1_DATBLO),BA1->BA1_DATBLO,BA1->BA1_DTVLCR)
GD4->GD4_MATRIC	:= ALLTRIM(BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))
GD4->GD4_NOMTIT	:= ALLTRIM(BA1->BA1_NOMTIT)
If !Empty(BA1->BA1_CODPLA)
	GD4->GD4_CODIGO := BA1->BA1_CODPLA
Else
	GD4->GD4_CODIGO := BA3->BA3_CODPLA
EndIf
GD4->GD4_CODCON := cConvPLS
GD4->GD4_IDPADR	:= FS_GD4PADR(cReger, lachou,BA1->BA1_DATBLO)  //ativo	// Plano Padrao
GD4->GD4_CODINT	:= BA1->BA1_CODINT
//GD4->GD4_CODIGO	:= BA1->BA1_CODEMP
If !Empty(BA1->BA1_VERSAO)
	GD4->GD4_VERCON := BA1->BA1_VERSAO
Else
	GD4->GD4_VERCON := BA3->BA3_VERSAO
EndIf

GD4->GD4_CODPLA	:= BI3->BI3_HSPPLA
GD4->GD4_DESCRI := BI3->BI3_DESCRI
GD4->GD4_IDEATI	:= iif (!Empty(BA1->BA1_DATBLO) .and. BA1->BA1_DATBLO < dDatabase ,"0","1")  //ativo
GD4->GD4_DESINT := BA0->BA0_NOMINT   
//GD4->GD4_IDDOAC	:= iif (Empty(BA1->BA1_DATBLO) .AND. (BA1->BA1_DTVLCR > dDataBase) ,"1","0")  //posicionado
GD4->(MsUnLock())
 

if GBH->(FieldPos("GBH_USUARI")) > 0 .and. GD4->GD4_IDEATI ='1'  .and. i==1 //pimeiro plano ativo

		DbSelectArea("GBH")
		DbSetOrder(1)
		If DbSeek(xFilial("GBH") + creger)
			GBH->(RecLock("GBH",.F.))
	   		GBH->GBH_USUARI	:=cMatricula
			GBH->(MsUnLock())
			 i+=1 		
        Endif 

Endif
 
      
RestArea(aArea)
Return()   
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna se o paciente já tem plano padrão e grava como não padrão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function FS_GD4PADR(cRegGer, lFound,dDatBloq)
Local aArea := getArea()
Local cPadr := "1"
If lFound // Caso seja atualização retorna o proprio dado e não altera
	If dDatBloq == dDatabase
		cPadr := "0"
		RestArea(aArea)
		Return(cPadr)
	Endif
		RestArea(aArea)	
		Return(GD4->GD4_IDPADR)
EndIf

GD4->(DbSetOrder(2))
If GD4->(MsSeek(xFilial("GD4") + cRegGer + "1"))
	cPadr := "0"
Else
	cPadr := "1"
EndIf
	If dDatBloq == dDatabase
		cPadr := "0"
		RestArea(aArea)	
		Return(cPadr)
	Endif
RestArea(aArea)
Return(cPadr)

     




/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atauliza o pplano padrão caso o atual esteja vencido				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function FS_GD4ATUPD(cRegGer)
Local aArea 		:= getArea()
Local cMatricAtu	:= ""


GD4->(DbSetOrder(2))
If GD4->(MsSeek(xFilial("GD4") + cRegGer + "1"))
	If GD4->GD4_DTVALI < dDataBase
		RecLock("GD4",.F.)
			GD4->GD4_IDPADR := "0"
		MsUnlock()
		GD4->(DbGoTop())	
		GD4->(DbSetOrder(1))
		If GD4->(MsSeek(xFilial("GD4") + cRegGer))		
			While !GD4->(Eof()) .AND. GD4->GD4_REGGER == cRegGer
				If GD4->GD4_IDPADR == "0" .AND. GD4->GD4_DTVALI > dDataBase
					RecLock("GD4",.F.)
						GD4->GD4_IDPADR := "1"
						cMatricAtu := GD4->GD4_MATRIC
					MsUnlock()					
					GBH->(DbSetOrder(1))
					If GBH->(MsSeek(xFilial("GBH") + cRegGer))	.And. GBH->(FieldPos("GBH_USUARI")) > 0
						RecLock("GBH",.F.)
							GBH->GBH_USUARI := cMatricAtu
						MsUnlock()										
					EndIf
					Return()
				EndIf 
				GD4->(DbSkip())				
			EndDo
		EndIf
	EndIf
EndIf       
//~Verifica se apoas a atualização não existir plano padrão e atualiza o primeiro como padrão
GD4->(DbSetOrder(2))
If !GD4->(MsSeek(xFilial("GD4") + cRegGer + "1"))
	GD4->(DbSetOrder(1))
	If GD4->(MsSeek(xFilial("GD4") + cRegGer))
		RecLock("GD4",.F.)
			GD4->GD4_IDPADR := "1"
			cMatricAtu := GD4->GD4_MATRIC
		MsUnlock()
		GBH->(DbSetOrder(1))
		If GBH->(MsSeek(xFilial("GBH") + cRegGer)).And. GBH->(FieldPos("GBH_USUARI")) > 0
			RecLock("GBH",.F.)
				GBH->GBH_USUARI := cMatricAtu
			MsUnlock()
		EndIf
	EndIf
EndIf


RestArea(aArea)
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³HS_NFEINTE³ Autor ³ Totvs				    ³ Data ³ 21/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Dados para preencher a tag Intermediario na NFE    ³±±
±±³          ³ Sera executada pela equipe padrão NFE                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumNota -> Numero da Nota						          ³±±
±±³			 ³ cNumSerie -> Numero Serie Nota					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ cNumCPF -> Numero CPF do paciente Guia Da Nota	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//<CPFCNPJINTERMEDIARIO>  
//Caso seja retornado em branco o padrão entende que nao irá ter a TAG de INTERMEDIARIO
Function HS_NFEINTE(cNumNota,cNumSerie)
Local aArea   	  := GetArea()
Local cNumCPF 	  := "" 
Local cNumInsMun  := ""
Local lRetDados	  := GetNewPar("MV_HSPNFIN",.F.)
Default cNumNota  := ""
Default cNumSerie := ""

If lRetDados .And. !Empty(cNumNota) .And. !Empty(cNumSerie)	
	// Posiciona GCZ - Guias de Atendimentos         
	DbSelectArea("GCZ")
	GCZ->(DbSetOrder(18))//I - GCZ_FILIAL+GCZ_NRNOTA+GCZ_SERIE                                                                                                                                 
	If GCZ->(MsSeek(xFilial("GCZ")+cNumNota+cNumSerie)) .And. !Empty(GCZ->GCZ_CODCON)
		// Posiciona GA9 - Dados Convenio
		DbSelectArea("GA9")
		GA9->(DbSetOrder(1))//GA9_FILIAL+GA9_CODCON                                                                                                                                           
		If GA9->(MsSeek(xFilial("GA9")+GCZ->GCZ_CODCON)).And. !Empty(GA9->GA9_CGC)
			cNumCPF := GA9->GA9_CGC
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA       
			If SA1->(MsSeek(xFilial("SA1")+GA9->(GA9_CODCLI+GA9_LOJA))).And. !Empty(SA1->A1_INSCRM)
				cNumInsMun := SA1->A1_INSCRM
			Endif 
		Endif
	Endif
Endif

RestArea(aArea)

Return({cNumCPF,cNumInsMun})
