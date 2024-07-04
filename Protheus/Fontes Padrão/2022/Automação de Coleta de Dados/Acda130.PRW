#INCLUDE "Acda130.ch" 
#INCLUDE "Protheus.ch"
#INCLUDE "DBTREE.CH"
#INCLUDE "TCBROWSE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDA130  ³ Autor ³ ACD                   ³ Data ³ 25/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Geral Logs                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function ACDA130
PRIVATE aRotina := Menudef()
PRIVATE cCadastro:= STR0003 //"Consulta Geral Log de Eventos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acessar os parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12, { || FilBrowCB0() } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CB0")
            
FilBrowCB0(.f.)
CB0->(DbSetorder(1))
mBrowse(6,1,22,75,"CB0") //,,,,,,,"A130RANGE()","A130RANGE()")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F12 e Limpa filtro casa exista                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12	To
dbSelectArea("CB0")
CB0->(DbClearFilter())
Return  
                                        
Function A130Range()
Return xFilial("CB0")+"01"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FilBrowCB0 ³ Autor ³ ACD 						 ³ Data ³ 26/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra o Browse apos a parametrizacao com Tecla F12          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDA130                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FilBrowCB0(lPerg)
// melhorar utilizacao do parametro MV_LOCALIZ - ASV
DEFAULT lPerg := .t.
pergunte("AIA105",lPerg)
If mv_par01 == 2
   Set Filter To CB0->CB0_TIPO=="01" .AND. CB0->CB0_QTDE>0
Else
   Set Filter To CB0->CB0_TIPO=="01"
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDA131  ³ Autor ³ ACD ³ Data ³ 26/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a dialog da consulta                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA131()
Local aDialogs := {""}

Local nTop     := oMainWnd:nTop+23
Local nLeft    := oMainWnd:nLeft+5
Local nBottom  := oMainWnd:nBottom-60
Local nRight   := oMainWnd:nRight-10
Local aPos     := {0,0,((nBottom-nTop)/2)-24,(nRight-nLeft)/2-130}

// objetos
Private oPanel,oTree,oFolder,oLbx,oEnc,oEncOP,oEncNS,oEncNE
Private oDlg,oFont 
private nTamCargo := 50
Private cEtiPrincipal
Private aTree		:={}
Private aGeral  	:={}
Private aEventos	:={}
Private aOps      :={}
Private aOpsEti   :={}
Private aNFEEti   :={}
Private aNFSEti   :={}
Private aHeader	:={}
Private aCols		:={}
Private n			:=1
Private lCarrega  := .f.

cEtiPrincipal := CB0->CB0_CODETI    
Processa({|| CarregaVetores()})
If ! lCarrega
	Help("",1,"Recno")
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona para carregar variaveis de memoria do CBG  ³
//³ Executa esse processo para agilizar na visualizacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cCadastro Of oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
// Folder do Tree e Panel
oFolder :=TFolder():New(12,0,{STR0004},{},oDlg,,,, .T., .F.,nRight-nLeft,nBottom-nTop-12,) //"Informacoes da Etiqueta "
oFolder:aDialogs[1]:oFont :=oDlg:oFont
// Informacoes para montagem do Tree
oTree:= dbTree():New(2, 2,((nBottom-nTop)/2)-24,129,oFolder:aDialogs[1],,,.T.)
oTree:bChange := {||  Click(aPos)}
oTree:blDblClick := {|| DBClick()}
oTree:SetFont(oFont)
oTree:lShowHint:= .F.                  
oPanel := TPanel():New(2,130,'',oFolder:aDialogs[1], oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-130,((nBottom-nTop)/2)-20,.T.,.T. )
Montatree()

// monta enchoice dos dados principal
oEnc:=MsMGet():New("CB0",CB0->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,)
oEnc:Show()

// monta enchoice OP
oEncOP:=MsMGet():New("SC2",SC2->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,)
oEncOP:Hide()

// monta enchoice Nota de entrada
oEncNS:=MsMGet():New("SF2",SF2->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,)
oEncNS:Hide()

// monta enchoice nota de entrada
oEncNE:=MsMGet():New("SF1",SF1->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,)
oEncNE:Hide()

// monta browse      
aCols	:= aClone(aGeral)
n		:= 1
dbselectarea('CBG')
oLbx 	:= MSGetDados():New(aPos[1],aPos[2],aPos[3],aPos[4],2,,,,nil,,1,,,,,,,oPanel)		
oLbx:oBrowse:Default()	
oLbx:oBrowse:Hide()

ACTIVATE MSDIALOG oDlg ON INIT Montatree() .and. EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,)
Release Object oTree
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Click    ³ Autor ³ ACD                   ³ Data ³ 11/03/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que exibe os movimentos dos lotes/sub-lotes           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Click(aPos)
Local cCargo	:= oTree:GetCargo()      
Local nPos      
oTree:Refresh()
If oLbx==NIL .or. oEnc==NIL .or. oEncOP ==NIL .or. oEncNS==NIL .or. oEncNE == NIL
   Return .t.
EndIF          

oEnc:Hide()
oEncOP:Hide()
oEncNS:Hide()
oEncNE:Hide()
oLbx:oBrowse:Hide()        

If Left(cCargo,4) == "0100" 	// todos os eventos              
	aCols	:= aClone(aGeral)
	n		:= 1
	dbselectarea('CBG')
   oLbx:Show()
   oLbx:oBrowse:Refresh()
ElseIf Left(cCargo,2) == "01" .and. Subs(cCargo,5,2) == "  "	// todos os eventos	oEnc:Hide()                  
	nPos := aScan(aEventos,{|x| x[1] == Subs(cCargo,3,2)})
	If ! Empty(nPos)
		aCols	:= aClone(aEventos[nPos,2])
		n		:= 1
		dbselectarea('CBG')
	   oLbx:Show()
   	oLbx:oBrowse:Refresh()                          
	EndIf   	
ElseIf Subs(cCargo,5,4)=="%OP%"  .and. Subs(cCargo,20,5) == "     "                       
	SC2->(DbSetorder(1))
	If SC2->(DbSeek(xFilial()+Alltrim(Subs(cCargo,9))))
		oEncOP:Show()   
		oEncOP:Refresh()		
	EndIf   
ElseIf Subs(cCargo,5,4)=="%NE%"  .and. Subs(cCargo,26,5) == "     "                       
	SF1->(DbSetorder(1))
	If SF1->(DbSeek(xFilial()+Alltrim(Subs(cCargo,9))))
		oEncNE:Show()   
		oEncNE:Refresh()		
	EndIf   
ElseIf Subs(cCargo,5,4)=="%NS%"  .and. Subs(cCargo,18,5) == "     "                       
	SF2->(DbSetorder(1))
	If SF2->(DbSeek(xFilial()+Alltrim(Subs(cCargo,9))))
		oEncNS:Show()   
		oEncNS:Refresh()		
	EndIf   
Else 
	CB0->(DbSetOrder(1))  
	nPos:= Rat("%CB0%",cCargo)
	If ! Empty(nPos)
		CB0->(DbSeek(xFilial()+Subs(cCargo,nPos+5)))
	ELSE
		CB0->(DbSeek(xFilial()+cEtiPrincipal))
	EndIf		           
	If CB0->(! Eof())
		oEnc:Show()   
		oEnc:Refresh()	
	EndIf		
EndIf    
oPanel:Refresh()  
oTree:Refresh()
Return .t.

Static Function DBClick()
Local cCargo	:= oTree:GetCargo()      
Local nPos     :=0                        
Local aUmEvento:={}
Local nPosOp   :=0     
Local nPosNe   :=0
Local nPosSE  := 0
Local	nPosFor := 0
Local nPosLjF := 0
Local nPosNS   :=0
Local nPosSS  := 0      

Local nEtiAux := 0

Local aOpTemp

Local nX,nX2
Local cEtiTemp
Local cEtiAnt 
If Left(cCargo,4) == "0100" 	// todos os eventos              
	Return .t.
ElseIf Left(cCargo,2) == "01" .and. Subs(cCargo,5,2) == "  "	// todos os eventos
	nPos 		:= aScan(aEventos,{|x| x[1] == Subs(cCargo,3,2)})
	If ! Empty(nPos)
		aUmEvento:= aClone(aEventos[nPos,2])	
	EndIf		
	//Analise se tem OP
	nPosOp   := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_OP"})
	If ! Empty(nPosOp)
	   aOpTemp:={}        
		For nX:= 1 to Len(aUmEvento)
			If ! Empty(aUmEvento[nX,nPosOp])
				AtuaOps(aUmEvento[nX,nPosOp])
		     	If Ascan(aOpTemp,Left(aUmEvento[nX,nPosOp],6)) == 0
			     	aadd(aOpTemp,Left(aUmEvento[nX,nPosOp],6))
				EndIf  	
	     	EndIf                                     
		Next               
		For nX:= 1 to len(aOpTemp)
			nPos := aScan(aOps,{|x| x[1] == aOpTemp[nX]})
			For nX2:= 1 to len(aOps[nPos,2])                                                                          
			   If ! oTree:TreeSeek(Padr(Left(cCargo,4)+"%OP%"+aOps[nPos,2,nX2],nTamCargo))
				   oTree:TreeSeek(Padr(cCargo,nTamCargo))
				   oTree:AddItem(STR0005+aOps[nPos,2,nX2], Padr(Left(cCargo,4)+"%OP%"+aOps[nPos,2,nX2],nTamCargo), "PMSDOC","PMSDOC",,, 2) //"OP "
				EndIf	
	 		Next
		Next
		oTree:Refresh()
	EndIf
	//Analise se tem nota de entrada, nota de Saida e etiqueta auxiliar
	nPosNE  := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_NOTAE"})
	nPosSE  := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_SERIEE"})
	nPosFor := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_FORN"})
	nPosLjF := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_LOJFOR"})	
	nPosNS  := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_NOTAS"})
	nPosSS  := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_SERIES"})
	nEtiAux := aScan(aHeader,{|x| Alltrim(x[2]) == "CBG_ETIAUX"})
	
	If ! Empty(nPosNE) .or. ! Empty(nPosNS) .or. ! Empty(nEtiAux)
		For nX:= 1 to Len(aUmEvento)                              
			If ! Empty(aUmEvento[nX,nPosNE]) .and. ! oTree:TreeSeek(Padr(Left(cCargo,4)+"%NE%"+aUmEvento[nX,nPosNE]+aUmEvento[nX,nPosSE]+aUmEvento[nX,nPosFor]+aUmEvento[nX,nPosLjF],nTamCargo))
					oTree:TreeSeek(Padr(Left(cCargo,4),nTamCargo))	
					oTree:AddItem(STR0006+aUmEvento[nX,nPosNE]+" "+aUmEvento[nX,nPosSE]+" "+; //"Nota Entrada "
															aUmEvento[nX,nPosFor]+" "+	aUmEvento[nX,nPosLjF],;
															Padr(Left(cCargo,4)+"%NE%"+aUmEvento[nX,nPosNE]+aUmEvento[nX,nPosSE]+;
															aUmEvento[nX,nPosFor]+aUmEvento[nX,nPosLjF],nTamCargo), "PMSDOC","PMSDOC",,, 2)				
			EndIf	
			If ! Empty(aUmEvento[nX,nPosNS]) .and. ! oTree:TreeSeek(Padr(Left(cCargo,4)+"%NS%"+aUmEvento[nX,nPosNS]+aUmEvento[nX,nPosSS],nTamCargo))
					oTree:TreeSeek(Padr(Left(cCargo,4),nTamCargo))	
					oTree:AddItem(STR0007+aUmEvento[nX,nPosNS]+" "+aUmEvento[nX,nPosSS],; //"Nota Saida "
															Padr(Left(cCargo,4)+"%NS%"+aUmEvento[nX,nPosNS]+aUmEvento[nX,nPosSS],nTamCargo), "PMSDOC","PMSDOC",,, 2)				
			EndIf				
			If ! Empty(aUmEvento[nX,nEtiAux]) .and. ! oTree:TreeSeek(Padr(Left(cCargo,4)+"%CB0%"+aUmEvento[nX,nEtiAux],nTamCargo))
					oTree:TreeSeek(Padr(Left(cCargo,4),nTamCargo))	
					oTree:AddItem(STR0008+aUmEvento[nX,nEtiAux],Padr(Left(cCargo,4)+"%CB0%"+aUmEvento[nX,nEtiAux],nTamCargo), "BMPCPO","BMPCPO",,, 2)				 //"Auxiliar "
	     	EndIf                              
		Next               
	EndIf	
	oTree:Refresh()
ElseIf Subs(cCargo,5,4)=="%OP%"  .and. Subs(cCargo,20,5) == "     "                       
  	//Analise se tem etiqueta para esta OP
	CarregaEt(Alltrim(Subs(cCargo,9)),"OP")
   nPos := Ascan(aOpsEti,{|x| x[1]==Alltrim(Subs(cCargo,9))})
   If ! Empty(nPos)                  
		For nX:= 1 to len(aOpsEti[nPos,2])
			If !oTree:TreeSeek(Padr(Left(cCargo,19)+"%CB0%"+aOpsEti[nPos,2,nX,1],nTamCargo))
		   	oTree:AddItem(aOpsEti[nPos,2,nX,2]+" "+aOpsEti[nPos,2,nX,1], Padr(Left(cCargo,19)+"%CB0%"+aOpsEti[nPos,2,nX,1],nTamCargo), "BMPCPO","BMPCPO",,, 2)
			EndIf		   	
		Next
	EndIf		           
ElseIf Subs(cCargo,5,4)=="%NE%"  .and. Subs(cCargo,26,5) == "     "                       
  	//Analise se tem etiqueta para esta Nota fiscal de entrada
	CarregaEt(Alltrim(Subs(cCargo,9)),"NE")
   nPos := Ascan(aNFEEti,{|x| x[1]==Alltrim(Subs(cCargo,9))})
   If ! Empty(nPos)                  
		For nX:= 1 to len(aNFEEti[nPos,2])
			If !oTree:TreeSeek(Padr(Left(cCargo,25)+"%CB0%"+aNFEEti[nPos,2,nX,1],nTamCargo))
		   	oTree:AddItem(aNFEEti[nPos,2,nX,1], Padr(Left(cCargo,25)+"%CB0%"+aNFEEti[nPos,2,nX,1],nTamCargo), "BMPCPO","BMPCPO",,, 2)
			EndIf		   	
		Next
	EndIf		           
ElseIf Subs(cCargo,5,4)=="%NS%"  .and. Subs(cCargo,18,5) == "     "                       
  	//Analise se tem etiqueta para esta Nota fiscal de Saida
	CarregaEt(Alltrim(Subs(cCargo,9)),"NS")
   nPos := Ascan(aNFSEti,{|x| x[1]==Alltrim(Subs(cCargo,9))})
   If ! Empty(nPos)                  
		For nX:= 1 to len(aNFSEti[nPos,2])
			If !oTree:TreeSeek(Padr(Left(cCargo,17)+"%CB0%"+aNFSEti[nPos,2,nX,1],nTamCargo))
		   	oTree:AddItem(aNFSEti[nPos,2,nX,1], Padr(Left(cCargo,17)+"%CB0%"+aNFSEti[nPos,2,nX,1],nTamCargo), "BMPCPO","BMPCPO",,, 2)
			EndIf		   	
		Next
	EndIf		           
ElseIf at("%CB0%",cCargo) > 0
   cEtiAnt  :=  cEtiPrincipal
	cEtiTemp := Subst(cCargo,at("%CB0%",cCargo)+5,10)
	If cEtiTemp # cEtiPrincipal        
		cEtiPrincipal:=cEtiTemp
		Processa({||CarregaVetores()})
		If ! lCarrega
			Help("",1,"Recno")
			cEtiPrincipal:= cEtiAnt  
			Return
		EndIf
		Montatree()		
		oTree:Refresh()
	EndIf
Else                                                  
EndIf                                    
Return .t.

Static Function AtuaOps(cOp)
Local nOrder := CBG->(IndexOrd())
Local nRec   := CBG->(RECNO())
Local nPos,nPos2
Local aTemp:={}
nPos := Ascan(aOps,{|x| x[1] ==Left(cOP,6)})
If ! Empty(nPos)
   Return 
EndIf           
CBG->(DbSetOrder(4))  
CBG->(DbSeek(xFilial()+Left(cOP,6)))         
While CBG->(!Eof() .And. xFilial("CB0")+Left(cOP,6) == CBG_FILIAL+Left(CBG_OP,6))
   nPos := Ascan(aTemp,{|x| x==CBG->CBG_OP})
   If Empty(nPos)
		aadd(aTemp,CBG->CBG_OP)
	EndIf		                    
	CBG->(DbSkip())
Enddo              
CBG->(DbSetOrder(nOrder))  
CBG->(DbGoto(nRec))  
aadd(aOps,{Left(cOP,6),aClone(aTemp)})
Return



Static Function Montatree()
Local aArea	   := GetArea()
Local nX
Local aLinhas := aTree            
oTree:BeginUpdate()
oTree:reset()

oTree:AddItem(cEtiPrincipal+Space(18), Padr("0000",nTamCargo), "BMPCONS",,,, 2) 
oTree:AddItem(STR0009,"0100", "BMPCONS",,,, 2) //"Eventos"
oTree:TreeSeek(Padr("0100",nTamCargo))
For nX := 1 To Len(aLinhas)                                                     
	oTree:AddItem(aLinhas[nX,1], Padr("01"+aLinhas[nX,2],nTamCargo), "F5_NULL","F6_NULL",,, 2)                
Next nX              

oTree:EndUpdate()
oTree:Refresh()
oTree:TreeSeek(Padr("0000",nTamCargo))
RestArea(aArea)
Return .T.


Static Function Al_CriaHeader()
Local nI		:= 0
Local cAlias 	:= "CBG"
Local aTmpheader:= {}
Local aHeadAUX	:= aClone( APBuildHeader( cAlias ) )

For nI := 1 to Len(aHeadAUX)
	If X3USO(aHeadAUX[nI,7]) .and. cNivel >= GetSx3Cache(trim(aHeadAUX[nI,2]), "X3_NIVEL") 
		AADD(aTmpHeader,{ TRIM(aHeadAUX[nI,1]),aHeadAUX[nI,2],aHeadAUX[nI,3],aHeadAUX[nI,4],aHeadAUX[nI,5],aHeadAUX[nI,6],aHeadAUX[nI,7],aHeadAUX[nI,8],aHeadAUX[nI,7],,aHeadAUX[nI,10] } )
	EndIf
Next nI 

Return aTmpheader
          
Static Function CarregaVetores()
Local nPos,nPos2
Local aTemp,nX
Local aUsers
aTree		:={}
aGeral  	:={}
aEventos	:={}
aOps     :={}
aOpsEti  :={}
aNFEEti  :={}
aNFSEti  :={}
aHeader	:={}
aCols		:={}

dbSelectArea("CBG")
CBG->(dbSetOrder(3))
If ! CBG->(dbSeek(xFilial("CB0")+cEtiPrincipal))
	lCarrega := .f.
	Return .f.
EndIf      
aHeader 	:= aClone(Al_CriaHeader()) 
aTree:={}                         
ProcRegua(CBG->(RecCount()))
While CBG->(!Eof() .And. xFilial("CB0")+cEtiPrincipal == CBG_FILIAL+CBG_CODETI)
	IncProc(STR0010) //"Carregando...."
	//Alimenta o array do Tree
   nPos := Ascan(aTree,{|x| x[2]==CBG->CBG_EVENTO})                               
   If Empty(nPos)
		CBG->(AADD(aTree,{Tabela("J2",CBG_EVENTO,.f.),CBG_EVENTO}))
		nPos:= len(aTree)
	EndIf	  
	aTemp:= {}                     
	For nX := 1 to len(aHeader)                                     
		If Alltrim(aHeader[nX,2]) =='CBG_NOMEUS' 
			PswOrder(1)
			If PswSeek(CBG->(FieldGet(FieldPos("CBG_USUARI"))))
			   aUsers:= PswRet(1)
				aadd(aTemp,aUsers[1,2] )  
			EndIf
		ElseIf Alltrim(aHeader[nX,2]) =='CBG_NOMEOP'                                                       
			aadd(aTemp,Posicione("CB1",1,XFILIAL("CB1")+CBG->(FieldGet(FieldPos("CBG_CODOPE"))),"CB1_NOME"))
		ElseIf Alltrim(aHeader[nX,2]) =='CB5_DESCEV'                                      
			aadd(aTemp,TABELA("J2",CBG->(FieldGet(FieldPos("CBG_EVENTO"))),.F.))		
		ElseIf Alltrim(aHeader[nX,2]) =='CBG_DESPRO'
			aadd(aTemp,Posicione("SB1",1,XFILIAL("SB1")+CBG->(FieldGet(FieldPos("CBG_CODPRO"))),"B1_DESC"))
		Else
			aadd(aTemp,CBG->(FieldGet(FieldPos(aHeader[nX,2]))))
		EndIf	
 	Next
	//Alimenta o array geral      
	aadd(aGeral,aClone(aTemp))
	//Alimenta o array por envento
	nPos := aScan(aEventos,{|x| x[1] == CBG->CBG_EVENTO})
	If Empty(nPos)
	   aadd(aEventos,{CBG->CBG_EVENTO,{}})
	   nPos := Len(aEventos)
	EndIf
	aadd(aEventos[nPos,2],aClone(aTemp))
	CBG->(dbSkip())
EndDo
lCarrega := .t.
Return .t.                                   

Static Function CarregaEt(cDoc,cModo)
Local nOrder := CBG->(IndexOrd())
Local nRec   := CBG->(RECNO())   
Local nPos,nPos2
Local cTipo                                       
nPos := Ascan(aOpsEti,{|x| x[1]==cDoc})
If ! Empty(nPos)  
	Return 
EndIf                             
If cModo == "OP"
	CBG->(DbSetOrder(4))  
	CBG->(DbSeek(xFilial()+cDoc))         
	While CBG->(!Eof() .And. xFilial("CB0")+cDoc == CBG_FILIAL+CBG_OP)
		cTipo := Tabela("J2",CBG->CBG_EVENTO)
	   nPos := Ascan(aOpsEti,{|x| x[1]==CBG->CBG_OP})
	   If Empty(nPos)  
	   	aadd(aOpsEti,{CBG->CBG_OP,{}})
	      nPos:= Len(aOpsEti)
		EndIf        
		nPos2:=Ascan(aOpsEti[nPos,2],{|x| x[1]== CBG->CBG_CODETI})
		If Empty(nPos2)
			aadd(aOpsEti[nPos,2],{CBG->CBG_CODETI,cTipo})
		EndIf	
		CBG->(DbSkip())
	Enddo              
ElseIf cModo =="NE"
	CBG->(DbSetOrder(5))  
	CBG->(DbSeek(xFilial()+cDoc))         
	While CBG->(!Eof() .And. xFilial("CB0")+cDoc == CBG_FILIAL+CBG_NOTAE+CBG_SERIEE+CBG_FORN+CBG_LOJFOR)
		cTipo := Tabela("J2",CBG->CBG_EVENTO)
	   nPos := Ascan(aNFEEti,{|x| x[1]==CBG_NOTAE+CBG_SERIEE+CBG_FORN+CBG_LOJFOR})
	   If Empty(nPos)  
	   	aadd(aNFEEti,{CBG_NOTAE+CBG_SERIEE+CBG_FORN+CBG_LOJFOR,{}})
	      nPos:= Len(aNFEEti)
		EndIf        
		nPos2:=Ascan(aNFEEti[nPos,2],{|x| x[1]== CBG->CBG_CODETI})
		If Empty(nPos2)
			aadd(aNFEEti[nPos,2],{CBG->CBG_CODETI,cTipo})
		EndIf	
		CBG->(DbSkip())
	Enddo              
ElseIf cModo =="NS"	
	CBG->(DbSetOrder(6))  
	CBG->(DbSeek(xFilial()+cDoc))         
	While CBG->(!Eof() .And. xFilial("CB0")+cDoc == CBG_FILIAL+CBG_NOTAS+CBG_SERIES)
		cTipo := Tabela("J2",CBG->CBG_EVENTO)
	   nPos := Ascan(aNFSEti,{|x| x[1]==CBG_NOTAS+CBG_SERIES})
	   If Empty(nPos)  
	   	aadd(aNFSEti,{CBG_NOTAS+CBG_SERIES,{}})
	      nPos:= Len(aNFSEti)
		EndIf        
		nPos2:=Ascan(aNFSEti[nPos,2],{|x| x[1]== CBG->CBG_CODETI})
		If Empty(nPos2)
			aadd(aNFSEti[nPos,2],{CBG->CBG_CODETI,cTipo})
		EndIf	
		CBG->(DbSkip())
	Enddo              
EndIf
CBG->(DbSetOrder(nOrder))  
CBG->(DbGoto(nRec))  
Return                        

/*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 24/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {  {STR0001,"AxPesqui", 0 , 1},; //"Pesquisar"
 				{ STR0002,"ACDA131", 0 , 2} } //"Consulta"

 
 RETURN aRotMenu


