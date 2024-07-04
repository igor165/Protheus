#Include "PanelOnLine.ch"     
#Include "HSPPGONL.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TopConn.ch"
#include "msgraphi.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HSPPGONL  ³ Autor ³ Marco Bianchi         ³ Data ³ 18/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Painel de Gestao.                                             ³±±
±±³          ³Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FATPGONL(oPGOnline)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPPGONL(oPGOnline)


Local aToolBar  := {}
Local nI		:= 0
Local cString   := ""
Local aPainel	:= {}
Local cStrFun	:= ""

cStrFun	:= FUNNAME()

If "10" $ GetVersao(.F.) 
	If !HS_ExisDic({{"T", "GTA"}},.F.)
		Return
	EndIf                    
EndIf

If Empty(cStrFun)
	aPainel := HS_RTPGON()
else
	aPainel := HS_2RTPGON()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atendimentos Cancelados                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Botao de Help do Painel
//1=Simples;2=Grafico Pizza;3-Grafico Barra;4-Grafico Linha
For nI := 1 to Len(aPainel)
	If aPainel[nI,8] == "1" // Tipo simples
		aToolBar  := {}
		cString := aPainel[nI,5] 
		Aadd( aToolBar, { "S4WB016N",cString,"{ || MsgInfo('"+cString+"') }" } )
		PANELONLINE oPGOnline ADDPANEL ;
		TITLE aPainel[nI,1];
		DESCR aPainel[nI,1];
		TYPE 2 ;	
		ONLOAD aPainel[nI,2] ;                             
		REFRESH 10 ;
		DEFAULT 1 ;	      
		TOOLBAR aToolBar ;	
		NAME aPainel[nI,3];
		TITLECOMBO IIf(!Empty(aPainel[nI,7]),aPainel[nI,7],STR0003) 
	EndIf
Next nI
                                        

For nI := 1 to Len(aPainel)
	If aPainel[nI,8] == "2" .OR. aPainel[nI,8] == "3"// Grafico pizza / Barra
		aToolBar  := {}
		cString := aPainel[nI,5] 
		Aadd( aToolBar, { "S4WB016N",cString,"{ || MsgInfo('"+cString+"') }" } )
		Aadd( aToolBar, { "S4WB010N",cString,"{ || HSPPO020(" + aPainel[nI,3] + ",.T.) }" } )		
		PANELONLINE oPGOnline ADDPANEL ;
		TITLE aPainel[nI,1];
		DESCR aPainel[nI,1];
		TYPE 2 ;
		PARAMETERS "HSPPO020";
		ONLOAD aPainel[nI,2] ;                             
		REFRESH 10 ;
		DEFAULT 3 ;	      
		TOOLBAR aToolBar ;	
		NAME aPainel[nI,3]
		
	EndIf
Next nI

For nI := 1 to Len(aPainel)
	If aPainel[nI,8] == "4" // Grafico linha/comparativo
		aToolBar  := {}
		cString := aPainel[nI,5] 
		Aadd( aToolBar, { "S4WB016N",cString,"{ || MsgInfo('"+cString+"') }" } )
		PANELONLINE oPGOnline ADDPANEL ;
		TITLE aPainel[nI,1];
		DESCR aPainel[nI,1];
		TYPE 4 ;
		PARAMETERS "HSPPO030";
		ONLOAD aPainel[nI,2] ;                             
		REFRESH 10 ;
		DEFAULT 1 ;	      
		TOOLBAR aToolBar ;	
		NAME aPainel[nI,3]
		
	EndIf
Next nI


 
Return                                   
               

Function HS_2RTPGON()
Local aArea   	:= GetArea()
Local aPain		:= {} 

DbSelectArea("GTA")
DbGoTop()                                                                                                                  //5                  6                 7                    8
While !EOF()
	//                     1                                  2                                3            4
	AADD(aPain,{Alltrim(GTA->GTA_TITULO),"HSPPO0" + Iif(GTA->GTA_TIPOIN=="1","10",IIf(GTA->GTA_TIPOIN=="2","20",IIf(GTA->GTA_TIPOIN=="3","20","30"))) +"(" + Alltrim(Str(Recno())) + ")",Alltrim(Str(Recno())),2,Alltrim(GTA->GTA_HELPIN),GTA->GTA_REFRES,Alltrim(GTA->GTA_TITCMB),GTA->GTA_TIPOIN,})
	DbSkip()	
End    

RestArea(aArea)
Return aPain  


Function HS_RTPGON()
Local cEnvServ := GetEnvServer()  
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
Local cNomArq	:= "C:\PROTHEUS10AUX\PROTHEUS_DATA10\CONFIGPGONL.txt"// "" 
//Local cArqNf    := "" 
Local cArqRead	:= ""
Local aPain		:= {}
Local aAux		:= {}
Local nPos		:= 0 
Local cLibVers := ""

If GetRemoteType(@cLibVers) == 5 //"5"
	cNomArq := "\CONFIGPGONL.txt"
elseIf SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "CONFIGPGONL.txt"
Else
	cNomArq := cDirRaiz + "\CONFIGPGONL.txt"
EndIf       
//cArqNf:=fOpen(cNomArq)

cArqRead := MemoRead(cNomArq)//fReadStr(cArqNf, 65535)// 
While (nPos := At("***", cArqRead)) > 0	
	aAux := FS_TRATSTR(Substr(cArqRead, 1, nPos - 1 ))
	cArqRead := Substr(cArqRead, nPos + 3, Len(cArqRead) )
	If Len(aAux) == 8
		AADD(aPain,{aAux[1],aAux[2],aAux[3],IIf(!Empty(aAux[4]) .AND. Type(aAux[4]) == "C",Val(aAux[4]),2) ,aAux[5],aAux[6],aAux[7],aAux[8],})
	EndIf
End  
//FClose(cArqNf)

Return aPain  
              

Static Function FS_TRATSTR(cStr)
Local aLinha 		:= {}
Local nPos1 	:= 0
Local cStrAux		:= ""

While (nPos1 := At("|", cStr)) > 0	
	cStrAux := Substr(cStr, 1, nPos1 - 1 )
	cStrAux := StrTran(cStrAux, Chr(13), "")
	cStrAux := StrTran(cStrAux, Chr(10), "")	
	AADD(aLinha, cStrAux)
	cStr   := Substr(cStr, nPos1 + 1 , Len(cStr) )	
End 

Return aLinha

Function HS_Grphpg(cTitulo, aValores, nType,cTitHelp)
Local nI := 0


 DEFINE DIALOG oDlg TITLE "Impressao do Grafico" FROM 180,180 TO 580,700 PIXEL 


  // Cria o gráfico
  oGraphic := TMSGraphic():New( 01,01,oDlg,,,RGB(239,239,239),260,184)  
  oGraphic:SetTitle(cTitulo,"", CLR_BLACK, A_LEFTJUST, GRP_TITLE )
  oGraphic:SetMargins(2,6,6,6)
  oGraphic:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)

 
  @ 185, 065 BUTTON "Imprimir"   SIZE 30,10 OF oDlg PIXEL ACTION ( Hs_GrvGrf( oGraphic,cTitulo,cTitHelp )) 
  @ 185, 100 BUTTON "3D"   SIZE 30,10 OF oDlg PIXEL ACTION ( oGraphic:l3D := !oGraphic:l3D ) 
  @ 185, 135 BUTTON "Zoom + "   SIZE 30,10 OF oDlg PIXEL ACTION ( oGraphic:ZoomIn() )  
  @ 185, 170 BUTTON "Zoom - "   SIZE 30,10 OF oDlg PIXEL ACTION ( oGraphic:ZoomOut() ) 


  // Itens do Gráfico
  nSerie := oGraphic:CreateSerie( nType ) 
  
	For nI := 1 to Len(aValores)		  
		oGraphic:Add(nSerie, aValores[nI,2], aValores[nI,1], aValores[nI,3] )
	Next


 ACTIVATE DIALOG oDlg CENTERED 
Return

Function Hs_GrvGrf( oMSGraphic,cfTit,cgTit ) 
 Local bGrvGf := {|N,L| oMSGraphic:SaveToBMP(N,L), Hs_PrtGraf(N,cfTit,cgTit)}  //"Experimente Mais um nivel de Zoom para viabilizar a impressao Ok..."###"Aviso"###"Monta o grafico" 
 Eval( bGrvGf, "GrafB.BMP", "\" )
 oMSGraphic:SaveToImage("GrafI.PNG","\","PNG")	
Return( Nil )  

Function Hs_PrtGraf( cNameGF,cfTit,cgTit )
 Local oFont1 := TFont():New("Arial",9,14 ,.T.,.F.,5,.T.,5,.T.,.F.), oFont2 := TFont():New("Arial",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)
 Local bImpGf := {|N| IIf(File(N),Eval( bSetaI, N ),) } 
 Local bSetaI := {|N| oPrint:=TMSPrinter():New(""), oPrint:Setup(), oPrint:StartPage(),oPrint:Say(100,200,cgTit,oFont2),/*oPrint:Say(200,150,cgTit,oFont2),*/ oPrint:SayBitmap( 300,100,N, 3000, 2100 ), oPrint:endpage(), oPrint:PRINT(), Ms_Flush() }
 Eval( bImpGf, "\"+cNameGF )
Return( Nil )
