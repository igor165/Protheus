// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "OFIOA380.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA380 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Feriados SX5 Tabela 63                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA380
Private aFeriados 	:= {}
Private cData     	:= "  /  /  "
Private cDesc     	:= space(45)
Private ni        	:= 0
Private cFil		:= space(len(SX5->X5_FILIAL))
Private nTp			:= 0

If ExistBlock("OA380FIL") //Ponto de entrada para retornar a filial que se deseja trabalhar no filtro.
	cFil := ExecBlock("OA380FIL",.f.,.f.)
EndIf

FS_LISFER(1) //Lista os feriados

If Len(aFeriados) == 0
	aFeriados := {{cData,cDesc," ",0,cFil}}
Else
	aSort(aFeriados,1,,{|x,y| x[5]+x[3] < y[5]+y[3] })
EndIf

DEFINE MSDIALOG oDlgF FROM 000,000 TO 028,050 TITLE STR0001 OF oMainWnd
	@ 007,009 SAY STR0002 SIZE 30,08 OF oDlgF PIXEL COLOR CLR_BLUE
	@ 007,030 SAY STR0003 SIZE 100,08 OF oDlgF PIXEL COLOR CLR_BLUE
	@ 014,030 SAY STR0004 SIZE 100,08 OF oDlgF PIXEL COLOR CLR_BLUE
	@ 026,009 SAY STR0018+"   :" SIZE 30,08 OF oDlgF PIXEL COLOR CLR_BLUE
	@ 025,026 MSGET oFilial VAR cFil F3 IIf(GetVersao(.f.)=="P10","SM0","SM0_01") VALID FS_LISFER(2) SIZE 35,08 OF oDlgF PIXEL COLOR CLR_BLUE
	@ 026,072 SAY (STR0019) SIZE 100,08 OF oDlgF PIXEL COLOR CLR_RED
	@ 038,009 SAY STR0005 SIZE 30,08 OF oDlgF PIXEL COLOR CLR_BLUE
 	@ 037,026 MSGET oData VAR cData PICTURE "99/99/99" SIZE 35,08 OF oDlgF PIXEL COLOR CLR_HBLUE
	@ 038,072 SAY (STR0006+left(Transform(date(),"@D"),6)+STR0007+Transform(dDataBase,"@D")) SIZE 100,08 OF oDlgF PIXEL COLOR CLR_RED
	@ 050,009 SAY STR0008  SIZE 30,08 OF oDlgF PIXEL COLOR CLR_BLUE 
 	@ 049,026 MSGET oDesc VAR cDesc  SIZE 110,08 OF oDlgF PIXEL COLOR CLR_HBLUE
	@ 007,137 BUTTON oInclui  PROMPT OemToAnsi(STR0009) OF oDlgF SIZE 55,10 PIXEL  ACTION (Processa( {|| FS_INCLUIR() , FS_MUDADATA() , oData:SetFocus() } ))
   	@ 017,137 BUTTON oAltera  PROMPT OemToAnsi(STR0010) OF oDlgF SIZE 55,10 PIXEL  ACTION (Processa( {|| FS_ALTERAR(oLbx1:nAt,1) , FS_MUDADATA() , oLbx1:SetFocus() } ))
	@ 027,137 BUTTON oExclui  PROMPT OemToAnsi(STR0011) OF oDlgF SIZE 55,10 PIXEL  ACTION (Processa( {|| FS_EXCLUIR(oLbx1:nAt,1) , FS_MUDADATA() , oLbx1:SetFocus() } ))
   	@ 037,137 BUTTON oSair  PROMPT OemToAnsi(STR0012) OF oDlgF SIZE 55,10 PIXEL  ACTION (oDlgF:End())
	@ 068,003 LISTBOX oLbx1 FIELDS HEADER OemToAnsi(STR0018),OemToAnsi(STR0013),OemToAnsi(STR0014) COLSIZES 30,35,90 SIZE 192,133 OF oDlgF PIXEL ON CHANGE( FS_MUDADATA() )
	oLbx1:SetArray(aFeriados)
   	oLbx1:bLine := { || {aFeriados[oLbx1:nAt,5],aFeriados[oLbx1:nAt,1],aFeriados[oLbx1:nAt,2]}}
   	@ 001,003 TO 063,195 LABEL "" OF oDlgF PIXEL 
   	ACTIVATE MSDIALOG oDlgF CENTER 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MUDADATA³ Autor ³ Andre Luis Almeida  ³ Data ³ 14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza na tela os campos Filial, Data e Descricao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDADATA()      
	If Len(aFeriados) > 0
		cFil :=aFeriados[oLbx1:nAt,5]
		cData:=aFeriados[oLbx1:nAt,1]
		cDesc:=aFeriados[oLbx1:nAt,2]
		oFilial:Refresh()
		oData:Refresh()
		oDesc:Refresh()
	EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LISFER  ³ Autor ³ Caio Fraporti       ³ Data ³ 11/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os feriados de acordo com a filial selecionada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LISFER(nTp)

Local cQuery 	:= ""
Local cSQLFer	:= "ALIASSQL"
aFeriados 	:= {}

cQuery := "SELECT SX5.X5_DESCRI, SX5.X5_FILIAL, SX5.R_E_C_N_O_ SX5RECNO FROM "+RetSqlName("SX5")+" SX5"
cQuery += " WHERE SX5.X5_TABELA = '63'"
If !Empty(cFil)
	cQuery += "	AND SX5.X5_FILIAL = '"+cFil+"' "
Endif
cQuery += " AND SX5.D_E_L_E_T_=' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLFer , .F., .T. )
While !( cSQLFer )->( Eof() )
	If left((cSQLFer)->(X5_DESCRI),1) # "*"
		Aadd(aFeriados,{ left((cSQLFer)->(X5_DESCRI)+space(10),10) , substr((cSQLFer)->(X5_DESCRI)+space(42),13,42) , substr((cSQLFer)->(X5_DESCRI),4,2)+substr((cSQLFer)->(X5_DESCRI),1,2)+substr((cSQLFer)->(X5_DESCRI),7,2) , (cSQLFer)->(SX5RECNO), (cSQLFer)->(X5_FILIAL) })
	EndIf
	( cSQLFer )->( DbSkip() )
EndDo
( cSQLFer )->( DbCloseArea() )

If nTp == 2
	aSort(aFeriados,1,,{|x,y| x[5]+x[3] < y[5]+y[3] })
	oLbx1:SetArray(aFeriados)
	oLbx1:bLine := { || {aFeriados[oLbx1:nAt,5],aFeriados[oLbx1:nAt,1],aFeriados[oLbx1:nAt,2]}}
	oLbx1:Refresh()
EndIf	

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_INCLUIR ³ Autor ³ Andre Luis Almeida  ³ Data ³ 14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui feriados SX5 Tabela 63                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INCLUIR()
Local cX5Chave := ""
If cData # "  /  /  " .and. substr(cData,1,2) > "00" .and. substr(cData,1,2) < "32" .and. substr(cData,4,2) > "00" .and. substr(cData,4,2) < "13" .and. ( substr(cData,7,2) == "  " .or. ( val(substr(cData,7,2)) >= 0 .and. val(substr(cData,7,2)) <= 99 ) )
	If substr(cData,7,1) == " "
		cData := left(left(cData,5)+space(12),12)
	EndIf
	If Len(aFeriados) == 0
		aFeriados := {}
	EndIf

   	cX5Chave := FM_SQL("SELECT MAX(X5_CHAVE) FROM " + RetSQLName("SX5") + " SX5 WHERE SX5.X5_FILIAL = '"+cFil+"' AND SX5.X5_TABELA = '63' AND SX5.D_E_L_E_T_ = ' '")
   	ni := Val(cX5Chave)+1
   	
   	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek(cFil+"63")
	While !Eof() .and. SX5->X5_TABELA == "63" .and. SX5->X5_FILIAL == cFil
	   	If Left(SX5->X5_DESCRI,12) == left(cData+space(12),12) .and. SX5->X5_FILIAL == cFil
			MsgStop(STR0020,STR0021)
			Return()
		EndIf
   		DbSelectArea("SX5")
		DbSkip() 
	EndDo
   	
   	DbSelectArea("SX5")
   	RecLock("SX5",.t.)
    	SX5->X5_FILIAL := cFil
    	SX5->X5_TABELA := "63"
    	SX5->X5_CHAVE  := strzero(ni,3)
    	SX5->X5_DESCRI := left(cData+space(12),12)+left(cDesc+space(42),42)
    	SX5->X5_DESCSPA:= left(cData+space(12),12)+left(cDesc+space(42),42)
    	SX5->X5_DESCENG:= left(cData+space(12),12)+left(cDesc+space(42),42)
   	MsUnLock()
	aFeriados := {}
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek(cFil+"63")
	While !Eof() .and. SX5->X5_TABELA == "63" .and. SX5->X5_FILIAL == cFil
		If left(SX5->X5_DESCRI,1) # "*"
			Aadd(aFeriados,{ left(SX5->X5_DESCRI+space(10),10) , substr(SX5->X5_DESCRI+space(42),13,42) , substr(SX5->X5_DESCRI,4,2)+substr(SX5->X5_DESCRI,1,2)+substr(SX5->X5_DESCRI,7,2) , SX5->(RecNo()), SX5->X5_FILIAL })
		EndIf
		DbSelectArea("SX5")
		DbSkip() 
	EndDo
	aSort(aFeriados,1,,{|x,y| x[5]+x[3] < y[5]+y[3] })
	oLbx1:SetArray(aFeriados)
	oLbx1:bLine := { || {aFeriados[oLbx1:nAt,5],aFeriados[oLbx1:nAt,1],aFeriados[oLbx1:nAt,2]}}
	oLbx1:Refresh() 
Else
	MsgAlert(STR0016,STR0015)
EndIf
Return()
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ALTERAR ³ Autor ³ Andre Luis Almeida  ³ Data ³ 14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera feriados cadastrados SX5 Tabela 63                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ni = Posição no vetor aFeriados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTERAR(ni)
If cData # "  /  /  " .and. substr(cData,1,2) > "00" .and. substr(cData,1,2) < "32" .and. substr(cData,4,2) > "00" .and. substr(cData,4,2) < "13" .and. ( substr(cData,7,2) == "  " .or. ( val(substr(cData,7,2)) >= 0 .and. val(substr(cData,7,2)) <= 99 ) )
	If substr(cData,7,1) == " "
		cData := left(left(cData,5)+space(12),12)
	EndIf
  	aFeriados[ni,1] := cData
  	aFeriados[ni,2] := cDesc
  	aFeriados[ni,3] := substr(cData,4,2)+substr(cData,1,2)+substr(cData,7,2)
   	DbSelectArea("SX5")
   	DbGoto(aFeriados[ni,4])
   	RecLock("SX5",.f.)
    	SX5->X5_DESCRI := left(cData+space(12),12)+left(cDesc+space(42),42)
      	SX5->X5_DESCSPA:= left(cData+space(12),12)+left(cDesc+space(42),42)
      	SX5->X5_DESCENG:= left(cData+space(12),12)+left(cDesc+space(42),42)
   	MsUnLock()
   	aSort(aFeriados,1,,{|x,y| x[5]+x[3] < y[5]+y[3] })
   	oLbx1:SetArray(aFeriados)
  	oLbx1:bLine := { || {aFeriados[oLbx1:nAt,5],aFeriados[oLbx1:nAt,1],aFeriados[oLbx1:nAt,2]}}
   	oLbx1:Refresh()
Else
	MsgAlert(STR0016,STR0015) 
EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_EXCLUIR ³ Autor ³ Andre Luis Almeida  ³ Data ³ 14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui feriados cadastrados SX5 Tabela 63                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ni = Posição no vetor aFeriados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EXCLUIR(ni)
Local aAux := {}
Local nj   := 0
If aFeriados[1,1] # " " 
	If MsgYesNo(STR0017+aFeriados[ni,1]+" - "+aFeriados[ni,2],STR0015)
 		For nj := 1 to len(aFeriados)
      		If ni # nj
				Aadd(aAux,{ aFeriados[nj,1] , aFeriados[nj,2] , aFeriados[nj,3] , aFeriados[nj,4], aFeriados[nj,5] } )
			Else
			   DbSelectArea("SX5")
   				DbGoto(aFeriados[ni,4])
	   			RecLock("SX5",.f.,.t.)
   	   				DbDelete()
		   		MsUnLock()
			EndIf
      	Next
      	aFeriados := aClone(aAux)
		If Len(aFeriados) == 0
		   aFeriados := {{"  /  /  ",space(45)," ",0,space(len(SX5->X5_FILIAL))}}
		EndIf
		aSort(aFeriados,1,,{|x,y| x[5]+x[3] < y[5]+y[3] })
   		oLbx1:SetArray(aFeriados)
	  	oLbx1:bLine := { || {aFeriados[oLbx1:nAt,5],aFeriados[oLbx1:nAt,1],aFeriados[oLbx1:nAt,2]}}
   		oLbx1:Refresh()
	EndIf
EndIf
Return()
