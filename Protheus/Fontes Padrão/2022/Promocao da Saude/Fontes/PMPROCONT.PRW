#INCLUDE "PMPROCONT.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBROWSE.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMPROCONT  บAutor  ณMicrosiga         บ Data ณ  11/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao para chamar a tela de Contato telefonico.           บฑฑ
ฑฑบ          ณ 			                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PMPROCONT(cVida)

Local cCadastro := STR0001  //"Contato Telef๔nico"
Local cChave    := ""
Local oTel      := ""
Local cTel      := ""
Local cNome     := ""
Local oHist     := ""
Local cHist     := ""
Local aSize     := {}              
Local aObjects  := {}
Local aPPanel   := {}
Local nOpcA     := 0
Local aAreaBOT  := BOT->(GetArea())
Local lPassou   := .F.
Local nPVida    := 0
Local nPData    := 0
Local nPHora    := 0
Local nPTel     := 0
Local nPHist    := 0
Local nTamNome  := Val(Space( (TamSx3( "BTS_NOMUSR" )[1]) ))
Local lrTel	  := .T.

Private aTela   := {}
Private aGets   := {}
Private aCols	:= {}
Private aHeader := {}
Private nUBOT   := 0
Private oFolder := 0
Private nLBOT   := 0
Private OBOT
                       

DbSelectArea("BTS")
BTS->(DbSetOrder(1))
DbSeek(xFilial("BTS")+cVida)

cTel	:=BTS->BTS_TELEFO    
cNome	:=BTS->BTS_NOMUSR

If Empty(cTel)
	If MsgYesno(STR0007,STR0008)//""O Paciente nใo possui Telefone cadastrado! , Deseja incluir assim mesmo um contato ?""##"Aten็ใo"
		lrTel:=.T.
	Else 
		lrTel:=.F.
		return(nil) 
	Endif
Endif	

If lrTel
nLBOT := HS_BDados("BOT", @aHeader, @aCols, @nUBOT, 3,,,,,,,,,,,,,,,,,,) 
                                        
aSize	:= MsAdvSize(.T.)
   
aAdd( aObjects, { 100, 020, .T., .T.} ) 
aAdd( aObjects, { 100, 070, .T., .T.} ) 
aAdd( aObjects, { 100, 010, .T., .T.} )                                               
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlgBOT TITLE cCadastro From 000, 000 To 500, 700 Of oMainWnd Pixel   //000 000 400 600

	oBOT :=   MsNewGetDados():New(092, 005, 230, 345,0,,,,,,99999,,,, oDlgBOT, aHeader, aCols)    // 000 000 300 500
oBOT:oBrowse:BlDblClick := {|| FS_SHOWHIST(@cHist,cVida, oBOT:aCols[oBOT:nAt][nPData], oBOT:aCols[oBOT:nAt][nPHora],oBOT:aCols[oBOT:nAt][nPHist], @oHist     ) }

GeraBot(aCols,aHeader,oBOT,cVida,cTel)

nPTel  := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_TELEFO"})
nPHist := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_HISTOR"})
nPData := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_DATA"})
nPHora := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_HORA"})


If len(oBOT:aCols) > 0
		cTel  := Iif (!Empty(oBOT:aCols[oBOT:nAt][nPTel]),oBOT:aCols[oBOT:nAt][nPTel],cTel)
	cHist := oBOT:aCols[oBOT:nAt][nPHist]    
ELSE
	cHist := ""
EndIf

DEFINE FONT oFontPen NAME "Arial" SIZE 12,24 BOLD
	DEFINE FONT oFontNome NAME "Arial" SIZE 06,24 BOLD
	@005, 005 Say STR0009  Of oDlgBOT Pixel COLOR CLR_BLUE //"Paciente: "
	@003, 050 Say cNome Of oDlgBOT SIZE nTamNome, 010 FONT oFontNome Pixel Color CLR_RED
	
	@015, 005 Say STR0002       Of oDlgBOT Pixel COLOR CLR_BLUE //"Telefone Principal"
	@013, 050 Say cTel Of oDlgBOT SIZE 100, 010 FONT oFontPen Pixel Color CLR_RED
	
	@025, 005 Say STR0003 Of oDlgBOT Pixel COLOR CLR_BLUE //"Descri็ใo do contato"
	@033, 005 GET oHist VAR cHist MEMO SIZE 340, 050 Of oDlgBOT WHEN Empty(cHist) Pixel Color CLR_BLACK

	@075, 005 Say STR0004 Of oDlgBOT Pixel COLOR CLR_BLUE //"Historico de Telefonemas"
	
	oBtnFil := tButton():New(235, 245,STR0010	, oDlgBOT, {||oDlgBOT:End()}, 030, 012,,,, .T.)//"Sair"
	oBtnFil := tButton():New(235, 280,STR0011	,oDlgBOT, {|| MsgRun(STR0005,,{||IncBot(aCols,aHeader,oBOT,cVida,@cHist)})}, 030, 012,,,, .T.) //"Incluir"
	oBtnFil := tButton():New(235, 315,STR0012	, oDlgBOT, {|| MsgRun(STR0006,, {||GravaBot(oBOT,aHeader,cVida,cHist)})}, 030, 012,,,, .T.) //"Gravar"
	
	ACTIVATE MSDIALOG oDlgBOT

EndIf
		
Return(NIL)    
//BOT_FILIAL+BOT_MATVID+DTOS(BOT_DATA)+BOT_HORA",;//CHAVE
Static Function FS_SHOWHIST(cTexto, cVida, dData, cHora, cTxtHis, oHist) 
Local aArea := getArea()
If !Empty(cTxtHis)
	cTexto := cTxtHis
Else 
	DbSelectArea("BOT")
	BOT->(DbSetorder(1))
	If BOT->(MsSeek(xFilial("BOT") + cVida + DTOS(dData) + cHora))
		cTexto := BOT->BOT_HISTOR //E_MSMM(BOT->BOT_HISTOR)
	EndIf
EndIf   
oHist:Refresh()
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraBot  บAutor  ณMicrosiga           บ Data ณ  11/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao para alimentar o acols da tabela BOT - Contato      บฑฑ
ฑฑบ          ณ telefonico.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GeraBot(aCols,aHeader,oBOT,cVida,cTel)
Local cSQL := ""
Local nInd := 0 

Private aAux := {}

oBOT:aCols := {}

cSQL := "SELECT * FROM "
cSQL += RetSqlName("BOT")
cSQL += " WHERE BOT_FILIAL = '"+xFilial("BOT")+"' "
cSQL += "AND BOT_MATVID = '"+cVida+"' "
cSQL += "AND D_E_L_E_T_ = ''"

cSQL	:= ChangeQuery(cSQL)
PlsQuery(cSQL,"TRBBOT")

If TRBBOT->(EOF()) 
	aadd(oBOT:aCols,{})
	nTamCols := Len(oBOT:aCols)

	For nInd := 1 To Len(oBOT:aHeader)+1
		aadd(oBOT:aCols[nTamCols],nInd)
	  	If nInd <= Len(oBOT:aHeader)
			oBOT:aCols[nTamCols,nInd]    := CriaVar(oBOT:aHeader[nInd,2])
			
			If AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "MATVID"
				oBOT:aCols[nTamCols,nInd] := cVida
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "DATA"
				oBOT:aCols[nTamCols,nInd] := dDataBase
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "HORA"
				oBOT:aCols[nTamCols,nInd] := Time()
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "TELEFO"
				oBOT:aCols[nTamCols,nInd] := cTel
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "HISTOR"
				oBOT:aCols[nTamCols,nInd] := ""
			Endif
  		Else
  			oBOT:aCols[nTamCols,nInd] := .F.
		Endif
	Next nInd
Else
While !TRBBOT->(EOF())
	aadd(oBOT:aCols,{})
	nTamCols := Len(oBOT:aCols)
	BOT->(DbGoTo(TRBBOT->R_E_C_N_O_))                                                                        
	
	For nInd := 1 To Len(oBOT:aHeader)+1
		aadd(oBOT:aCols[nTamCols],nInd)
		If nInd <= Len(oBOT:aHeader)
			oBOT:aCols[nTamCols,nInd]    := CriaVar(oBOT:aHeader[nInd,2])
			
			If AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "MATVID"
				oBOT:aCols[nTamCols,nInd] := TRBBOT->BOT_MATVID
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "DATA"
				oBOT:aCols[nTamCols,nInd] := TRBBOT->BOT_DATA
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "HORA"
				oBOT:aCols[nTamCols,nInd] := TRBBOT->BOT_HORA
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "TELEFO"
				oBOT:aCols[nTamCols,nInd] := TRBBOT->BOT_TELEFO
				
			ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "HISTOR"
				oBOT:aCols[nTamCols,nInd] := "" //BOT->BOT_HISTOR
			Endif
		Else
			oBOT:aCols[nTamCols,nInd] := .F.
		Endif
	Next nInd  
	TRBBOT->(dbSkip())
EndDo
EndIf

If Select("TRBBOT") > 0
  TRBBOT->(dbCloseArea())
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IncBot   บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para incluir informa็๕es na tela de  				  บฑฑ
ฑฑบ          ณ contato telefonico                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncBot(aCols,aHeader,oBOT,cVida,cHist)

Local cTel := ""
Local nInd := 0

dbSelectArea("BOT")
dbSetOrder(1)//BOT_FILIAL, BOT_MATVID
dbGoTop()

oBOT:lChgField := .F.
oBOT:AddLine(.T., .F.)
oBOT:lNewLine := .F.

// 1 - BTS_FILIAL, BTS_MATVID
cTel := Posicione("BTS", 1, xFilial("BTS") + cVida, "BTS_TELEFO") 

For nInd := 1 To Len(oBOT:aHeader)+1
	nTamCols := Len(oBOT:aCols)
	If nInd <= Len(oBOT:aHeader)
		//oBOT:aCols[nTamCols,nInd]    := CriaVar(oBOT:aHeader[nInd,2])
		
		If AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "MATVID"
			oBOT:aCols[nTamCols,nInd] := cVida
			
		ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "DATA"
			oBOT:aCols[nTamCols,nInd] := ddataBase
			
		ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "HORA"
			oBOT:aCols[nTamCols,nInd] := Time()
			
		ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "TELEFO"
			oBOT:aCols[nTamCols,nInd] := cTel
			
		ElseIf AllTrim(Subs(oBOT:aHeader[nInd,2],5,6)) == "HISTOR"
			oBOT:aCols[nTamCols,nInd] := ""
		Endif
	Else
		oBOT:aCols[nTamCols,nInd] := .F.
	Endif
Next nInd  
 
cHist := ""

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaBot  บAutor  ณMicrosiga          บ Data ณ  11/22/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para grava็ใo da tabela BOT - Contato Telefonico    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GravaBot(oBOT,aHeader,cVida,cHist)
Local nC := 0

nPVida  := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_MATVID"})
nPData  := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_DATA"})
nPHora  := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_HORA"})
nPTel   := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_TELEFO"})
nPHist  := Ascan(oBOT:aHeader,{|x| Alltrim(x[2])=="BOT_HISTOR"})

If !Empty(cHist)
	
	For nC := 1 To Len(oBOT:aCols)
		DbSelectArea("BOT")
		BOT->(DbSetorder(1))
		If !BOT->(MsSeek(xFilial("BOT") + oBOT:aCols[nC][nPVida] + DTOS(oBOT:aCols[nC][nPData]) + oBOT:aCols[nC][nPHora])) // so grava o historico de nao encontrar
			If EmPty(oBOT:aCols[nC][nPHist])
				BOT->(RecLock("BOT",.T.))
				BOT->BOT_FILIAL := xFilial("BOT")
				BOT->BOT_MATVID := oBOT:aCols[nC][nPVida]
				BOT->BOT_DATA   := oBOT:aCols[nC][nPData]
				BOT->BOT_HORA   := oBOT:aCols[nC][nPHora]
				BOT->BOT_TELEFO := oBOT:aCols[nC][nPTel]
				BOT->BOT_HISTOR := cHist
				BOT->(MsUnlock())
				MSMM(, TamSx3("BOT_HISTOR")[1],, oBOT:aCols[nC][nPHist], 1,,, "BOT","BOT_HISTOR" )
			EndIf
		EndIf
	Next nC

	oDlgBOT:End()
Else
	MsgInfo(STR0013)//"Inclua a Descri็ao do Contato"
EndIf
 
Return