#INCLUDE "Protheus.ch"
#INCLUDE "TMSA595.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA595    ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enderecamento de Documentos sem Controle de Estoque         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSA595()

//Tratamento para chamar automaticamente a rotina de enderecamento com controle de estoque
//caso a TES do parametro MV_TESDR esteja configurada para isso
If TmsChkTES('1')
	If SF4->F4_ESTOQUE == "S"
		TMSA590()
		Return .F.
	EndIf
Else
	Return .F.
EndIf

While .T.
	If Pergunte( "TMA595", .T. )
		TMA595Proc()
	Else
		Exit
	EndIf
EndDo	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595Proc ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa os Enderecamentos         							     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595Proc                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595Proc()

Local aObjects  := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize()
Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aButtons  := {}
Local nTamMax   := 0
Local nOpcA     := 0

Private oGetD
Private aHeader     := TMA595Head()       
Private aCols       := {}
Private	aRotina    := { { "", "", 0, 1 } , { "", "", 0, 2 } ,	 { "", "", 0, 3 } }
Private nPosArmazem := 2

MsgRun(STR0005,"",{|| aCols := TMA595Cols() }) //"Aguarde, verificando enderecamentos..."

nTamMax := Len(aCols)

SetKey( VK_F4, {||TMA595Pesq()} )

If nTamMax > 0
	Aadd(aButtons,{'PESQUISA',{||TMA595Pesq()},STR0002 + " - <F4>" ,STR0002 }) //"Pesquisa - <F4>"
	
	Aadd( aObjects, { 100, 100, .T., .T., .F. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE STR0001 OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5] //"Enderecamento de Documentos"
		oGetD := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],3,,,,.F.,,,,nTamMax)
		oGetD:oBrowse:aAlter := {"DB_LOCAL", "DB_LOCALIZ", "DUH_UNITIZ", "DUH_CODANA"}
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| IIF(oGetD:TudoOk(),(nOpcA:=1,oDlg:End()),)},{||oDlg:End()},,aButtons))
	
	//-- Grava Enderecamento
	If nOpcA == 1
		TMA595Grv()
	EndIf
Else
	Help(' ', 1, 'TMSA59502') //Nao existe registro relacionado a este codigo.
EndIf

SetKey( VK_F4, NIL )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595Head ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem do aHeader         							           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595Head                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595Head()

Local aRet      := {}
Local aRetUsr   := {}
Local cAcao     := "1"
Local lTm595Cpo := ExistBlock("TM595CPO")
Local nCont     := 0
Local lProduto  := (DUH->(FieldPos('DUH_CODPRO'))>0)

aTam := TamSX3("B1_LOCALIZ")	
Aadd(aRet, {STR0003,"B1_LOCALIZ", PesqPict("SB1","B1_LOCALIZ" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"SB1"," "}) //"Carregado"
aTam:=TamSX3("DB_LOCAL")
Aadd(aRet,{RetTitle("DB_LOCAL")	,"DB_LOCAL"		,PesqPict("SDB","DB_LOCAL"	,atam[1]),aTam[1],aTam[2],"TMA595AtuE(aCols[n,1]=='N')",USADO, "C" ,"SDB"," "})
aTam:=TamSX3("DB_LOCALIZ")
Aadd(aRet,{RetTitle("DB_LOCALIZ"),"DB_LOCALIZ"	,PesqPict("SDB","DB_LOCALIZ",atam[1]),aTam[1],aTam[2],"TMA595EndC(aCols[n,nPosArmazem],M->DB_LOCALIZ,,aCols[n,1]=='N')",USADO, "C" ,"SDB"," "})
If FindFunction('TmsChkVer') .And. TmsChkVer('11','R7')
	aTam := TamSX3("DUH_UNITIZ")		
	Aadd(aRet, {RetTitle("DUH_UNITIZ"),"DUH_UNITIZ" ,PesqPict("DUH","DUH_UNITIZ",aTam[1]),aTam[1],aTam[2],"TMA595AtuE(aCols[n,1]=='N')",USADO, "C" ,"DUH"," "})
	aTam := TamSX3("DUH_CODANA")		
	Aadd(aRet, {RetTitle("DUH_CODANA"),"DUH_CODANA" ,PesqPict("DUH","DUH_CODANA",aTam[1]),aTam[1],aTam[2],"TMA595AtuE(aCols[n,1]=='N')",USADO, "C" ,"DUH"," "})	
EndIf



If lProduto
	aTam:=TamSX3("B1_COD")
	Aadd(aRet,{RetTitle("B1_COD"),"B1_COD",PesqPict("SB1","B1_COD",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"SB1"," "})

	aTam:=TamSX3("B1_DESC")
	Aadd(aRet,{RetTitle("B1_DESC"),"B1_DESC",PesqPict("SB1","B1_DESC",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"SB1"," "})

EndIf

aTam := TamSX3("DT6_FILDOC")	
Aadd(aRet, {RetTitle("DT6_FILDOC"),"DT6_FILDOC"	,PesqPict("DT6","DT6_FILDOC" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6"," "})
aTam := TamSX3("DT6_DOC")	
Aadd(aRet, {RetTitle("DT6_DOC"),"DT6_DOC"	,PesqPict("DT6","DT6_DOC" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6","V"})
aTam := TamSX3("DT6_SERIE")	
Aadd(aRet, {RetTitle("DT6_SERIE"),"DT6_SERIE"	,PesqPict("DT6","DT6_SERIE" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6"," "})
aTam := TamSX3("DUD_VIAGEM")	
Aadd(aRet, {RetTitle("DUD_VIAGEM"),"DUD_VIAGEM" ,PesqPict("DUD","DUD_VIAGEM",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTQ"," "})
aTam := TamSX3("DT6_FILDES")	
Aadd(aRet, {RetTitle("DT6_FILDES"),"DT6_FILDES" ,PesqPict("DT6","DT6_FILDES",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6"," "})
aTam := TamSX3("DUH_QTDVOL")	
Aadd(aRet, {RetTitle("DUH_QTDVOL"),"DUH_QTDVOL" ,PesqPict("DUH","DUH_QTDVOL",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DUH"," "})
If lTm595Cpo //-- PE - Permite ao usuario adicionar campos no aHeader
	aRetUsr:= ExecBlock("TM595CPO",.F.,.F.,{cAcao})
	If ValType(aRetUsr) == "A"
		For nCont := 1 To Len(aRetUsr)
			Aadd(aRet,aRetUsr[nCont])
		Next	
	EndIf
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595Cols ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem do aCols         							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595Cols                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595Cols()

Local aRet      := {}
Local aDados    := {}
Local cLocal    := Space(Len(DUH->DUH_LOCAL))
Local cLocaliz  := Space(Len(DUH->DUH_LOCALI))
Local cQuery    := ""
Local aArea     := GetArea()
Local lTm595Cpo := ExistBlock("TM595CPO")
Local cAcao     := "2"
Local nCont     := 0
Local aDadosUsr := {}
Local lProduto  := (DUH->(FieldPos('DUH_CODPRO'))>0)
Local cUnitiz   := ""
Local cCodAna	 := ""

cUnitiz   := Space(Len(DUH->DUH_UNITIZ))
cCodAna   := Space(Len(DUH->DUH_CODANA))

cQuery := "SELECT DUH_LOCAL, DUH_LOCALI, DUD_FILDOC, DUD_DOC, DUD_SERIE, DUH_UNITIZ, DUH_CODANA, "
cQuery += "MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, "
cQuery += "MIN(DT6_FILDES) DT6_FILDES, DUH_QTDVOL FROM "
cQuery += RetSqlName("DUD") + " DUD "

cQuery += " JOIN " + RetSqlName("DTC") + " DTC ON "
cQuery += "   DTC.DTC_FILIAL = '" +xFilial("DTC")+ "'"
cQuery += "   AND DTC.DTC_FILDOC = DUD.DUD_FILDOC "
cQuery += "   AND DTC.DTC_DOC = DUD.DUD_DOC "
cQuery += "   AND DTC.DTC_SERIE = DUD.DUD_SERIE "
cQuery += "   AND DTC.DTC_QTDVOL > 0 "
cQuery += "   AND DTC.D_E_L_E_T_ = ' '"

cQuery += " JOIN " + RetSqlName("DT6") + " DT6 ON "
cQuery += "   DT6.DT6_FILIAL = '" +xFilial("DT6")+ "'"
cQuery += "   AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
cQuery += "   AND DT6.DT6_DOC = DUD.DUD_DOC "
cQuery += "   AND DT6.DT6_SERIE = DUD.DUD_SERIE "
cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

If mv_par12 == 2 //Documentos sem Enderecar? NAO
	cQuery += " JOIN " + RetSqlName("DUH")+" DUH ON "
Else
	cQuery += " LEFT JOIN " + RetSqlName("DUH")+" DUH ON "
EndIf

cQuery += "   DUH.DUH_FILIAL  = '"+xFilial("DUH")+"'"	
cQuery += "   AND DUH.DUH_NUMNFC = DTC.DTC_NUMNFC "
cQuery += "   AND DUH.DUH_SERNFC = DTC.DTC_SERNFC "
cQuery += "   AND DUH.DUH_CLIREM = DTC.DTC_CLIREM "
cQuery += "   AND DUH.DUH_LOJREM = DTC.DTC_LOJREM "
cQuery += "   AND DUH.DUH_FILORI  = '"+cFilAnt+"'"
cQuery += "   AND DUH.DUH_LOCAL   BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
cQuery += "   AND DUH.DUH_LOCALI  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"	
cQuery += "   AND DUH.D_E_L_E_T_  = ' '"

cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
cQuery += "   AND DUD.DUD_FILORI = '"+cFilAnt+"'"
cQuery += "   AND DUD.DUD_FILDOC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
cQuery += "   AND DUD.DUD_DOC    BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
cQuery += "   AND DUD.DUD_SERIE  BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"

cQuery += "   AND DUD.DUD_SERTMS IN ( '2', '3' ) "
cQuery += "   AND DUD.D_E_L_E_T_ = ' '

If mv_par11 == 2 //Mostra Documento Carregado? NAO
	cQuery += "AND DUD.DUD_STATUS  = '1' "
Else
	cQuery += "AND DUD.DUD_STATUS IN ( '1', '3' ) "
EndIf		

If mv_par12 == 1 //Documentos sem Enderecar? SIM
	cQuery += " AND DUD.DUD_ENDERE <> '2' "
Else
	cQuery += " AND DUD.DUD_ENDERE = '2' "
EndIf
                         
cQuery += " GROUP BY DUH_LOCAL, DUH_LOCALI, DUH_QTDVOL, DUD_FILDOC, DUD_DOC, DUD_SERIE, DUH_UNITIZ, DUH_CODANA "
If lProduto
	cQuery += ", DUH_CODPRO"
EndIf

cQuery := ChangeQuery(cQuery)

cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

(cAliasNew)->( DbGoTop() )

While (cAliasNew)->(!Eof())
	aDados := {}
	If Empty((cAliasNew)->DUH_LOCAL)
		cLocal   := Space(Len(DUH->DUH_LOCAL))                                  		
		cLocaliz := Space(Len(DUH->DUH_LOCALI))
	Else
		cLocal   := (cAliasNew)->DUH_LOCAL
		cLocaliz := (cAliasNew)->DUH_LOCALI
	EndIf						                     
	If Empty((cAliasNew)->DUH_UNITIZ)
		cUnitiz  := Space(Len(DUH->DUH_UNITIZ))                                  		
		cCodAna  := Space(Len(DUH->DUH_CODANA))
	Else
		cUnitiz  := (cAliasNew)->DUH_UNITIZ
		cCodAna  := (cAliasNew)->DUH_CODANA
	EndIf						                       
	

	Aadd( aDados, If((cAliasNew)->DUD_STATUS == "3","S","N") )
	Aadd( aDados, cLocal   					)
	Aadd( aDados, cLocaliz 					)
	Aadd( aDados, cUnitiz  					)
	Aadd( aDados, cCodAna   				)

	If lProduto
		DTC->( DbSetOrder(3) ) //--DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
		If DTC->( DbSeek( xFilial('DTC') + (cAliasNew)->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )
			Aadd( aDados, DTC->DTC_CODPRO )
			AAdd( aDados, Posicione('SB1', 1, xFilial('SB1') + DTC->DTC_CODPRO, 'B1_DESC' ) )
		EndIf
	EndIf

	Aadd( aDados, (cAliasNew)->DUD_FILDOC	)
	Aadd( aDados, (cAliasNew)->DUD_DOC   	)
	Aadd( aDados, (cAliasNew)->DUD_SERIE 	)
	Aadd( aDados, (cAliasNew)->DUD_VIAGEM	)
	Aadd( aDados, (cAliasNew)->DT6_FILDES	)
	Aadd( aDados, (cAliasNew)->DUH_QTDVOL	)	

	If lTm595Cpo //-- PE - Permite ao usuario adicionar campos no aCols
		aDadosUsr := ExecBlock("TM595CPO",.F.,.F.,{cAcao,(cAliasNew)->DUD_FILDOC,(cAliasNew)->DUD_DOC,(cAliasNew)->DUD_SERIE})
		If ValType(aDadosUsr) == "A"
			For nCont := 1 To Len(aDadosUsr)
				Aadd(aDados,aDadosUsr[nCont])
			Next		
		EndIf
	EndIf	

	//Cuidado ao mudar as ultimas posicoes deste array, como temos o ponto de entrada que pode
	//manipular este array, estas duas ultimas posicoes tem um tratamento com Len(aHeader)
	Aadd( aDados, .F. 						)
	Aadd( aDados, cLocal+cLocaliz			)                           
	Aadd( aDados, cUnitiz			 		)                           
	Aadd( aDados, cCodAna					)                           
	Aadd( aRet, aClone(aDados) 				)
	
	(cAliasNew)->(DbSkip())
EndDo

(cAliasNew)->( DbCloseArea() )
RestArea(aArea)

If Len(aRet) > 0
	If lProduto
		aRet := Asort(aRet,,, { |x,y| x[2] + x[3] + x[6] + x[7] + x[8]  < y[2] + y[3] + x[6] + x[7] + x[8] } )	
	Else
		aRet := Asort(aRet,,, { |x,y| x[2] + x[3] + x[4] + x[5] + x[6]  < y[2] + y[3] + x[4] + x[5] + x[6] } )
	EndIf
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595EndC ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastra Local         							                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595EndC                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595EndC(cLocal, cLocaliz, lHelp, lAltDoc)

Local lRet 		   := .T.

Default cLocal     := ""
Default cLocaliz   := ""
Default lHelp      := .T.
Default lAltDoc    := .T.

If lAltDoc
	SBE->(dbSetOrder(1))
	If !SBE->(MsSeek(xFilial("SBE")+ cLocal + cLocaliz ) )
		If !Empty(cLocal) .And. !Empty(cLocaliz) .And. If(lHelp,MsgYesNo(STR0006, { STR0007, STR0008 }),.T.) //"O Local/Endereco informado nao esta cadastrado. Deseja Cadastrar ?" ### "Sim" ### "Nao"
			RegToMemory('SBE',.T.)
			M->BE_LOCAL   := cLocal
			M->BE_LOCALIZ := cLocaliz
			AxIncluiAuto("SBE",,,3,SBE->(Recno()) )
			RecLock("SBE", .F.)
			SBE->BE_DATGER := dDataBase
			SBE->BE_HORGER := Left(StrTran(Time(),":",""),4)
			SBE->(MsUnLock())
		Else
			Return ( .F. )
		EndIf
	EndIf
	
	If lHelp
		TMA595AtuE() //-- Atualiza Flag de Enderecamento
	EndIf
Else
	Help(' ', 1, 'TMSA59501') //"Documento ja carregado, o Endereco nao podera ser alterado"
	Return .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595Pesq ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pesquisa Endereco / Documento  				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595Pesq                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595Pesq()

Local cArmazem  := Space(02)
Local cEndereco := Space(15)
Local cFilDoc   := Space(02)
Local cDocto    := Space(Len(DT6->DT6_DOC)) 
Local cSerie    := Space(03)
Local nOpcao    := 0
Local lProduto  := (DUH->(FieldPos('DUH_CODPRO'))>0)
Local oDlg 

DEFINE MSDIALOG oDlg FROM 00,00 TO 170,490 PIXEL TITLE STR0004 //"Gera Enderecamento"

@ 05,05 SAY   STR0009   PIXEL //"Armazem"
@ 05,80 MSGET cArmazem    SIZE 20, 10 OF oDlg PIXEL 

@ 20,05 SAY   STR0010  PIXEL //"Endereco"
@ 20,80 MSGET cEndereco   SIZE 60, 10 OF oDlg PIXEL 
	
@ 35,05 SAY   STR0011 PIXEL //"Fil.Docto"
@ 35,80 MSGET cFilDoc     SIZE 20, 10 OF oDlg PIXEL 

@ 50,05 SAY   STR0012      PIXEL //"CTRC"
@ 50,80 MSGET cDocto      SIZE 60, 10 OF oDlg PIXEL 

@ 65,05 SAY   STR0013     PIXEL //"Serie"
@ 65,80 MSGET cSerie      SIZE 30, 10 OF oDlg PIXEL 

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())
	
ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	If !Empty(cArmazem) .And. !Empty(cEndereco)
		If ( nPos:= Ascan(aCols, { |x| x[2] + x[3] == cArmazem + cEndereco } ) ) > 0
			oGetD:oBrowse:nAt := nPos
			oGetD:oBrowse:Refresh()
		EndIf
	ElseIf !Empty(cFilDoc) .And. !Empty(cDocto) .And. !Empty(cSerie)
	
		If lProduto			
			nPos := Ascan(aCols, { |x| x[6] + x[7] + x[8] == cFilDoc + cDocto + cSerie } ) 		
		Else
			nPos := Ascan(aCols, { |x| x[4] + x[5] + x[6] == cFilDoc + cDocto + cSerie } ) 		
		EndIf
		
		If nPos > 0
			oGetD:oBrowse:nAt := nPos
			oGetD:oBrowse:Refresh()
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595AtuE ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualizacao dos Enderecos 	                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595AtuE                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595AtuE(lAltDoc)

Local nPosAltDoc  := 0
Local nPosFilDoc  := Ascan(aHeader, { |x| x[2] == "DT6_FILDOC" } )
Local nPosDoc     := Ascan(aHeader, { |x| x[2] == "DT6_DOC"    } )
Local nPosSerie   := Ascan(aHeader, { |x| x[2] == "DT6_SERIE"  } )

Default lAltDoc := .T.

nPosAltDoc := Len(aHeader)+1

If !TMSLocaliz('',aCols[n,nPosFilDoc],aCols[n,nPosDoc],aCols[n,nPosSerie])
	Help(' ', 1, 'TMSA59503') //"O Produto deste documento nao controla enderecamento"
	Return .F.
EndIf

If lAltDoc
	aCols[n,nPosAltDoc] := .T.
Else
	Help(' ', 1, 'TMSA59501') //"Documento ja carregado, o Endereco nao podera ser alterado"
	Return .F.
EndIf	
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA595Grv  ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 26/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava Enderecamento  				                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA595Grv                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA595                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMA595Grv(nOpcx,cLocal,cLocaliz,cFilDoc,cDocto,cSerie, lEndUnitiz)

Local nCnt       := 0
Local cLocalAnt  := ""
Local nPosLocal  := 0
Local nPosFilDoc := 0
Local nPosDoc    := 0
Local nPosSerie  := 0
Local nPosCodPro := 0
Local lProduto   := (DUH->(FieldPos('DUH_CODPRO'))>0)    
Local nPosCodAna := 0
Local cUnitiz 	  := ""
Local cCodAna	  := ""       
Local nPosUniAnt := 0
Local lAtualiza  := .T.   
                       

Default cFilDoc  := ""
Default cDocto	  := ""
Default cSerie	  := ""
Default cLocal   := ""
Default cLocaliz := ""
Default nOpcx 	  := 3
Default lEndUnitiz := .T.

If Type('aHeader') == 'A' .And. IsInCallStack(AllTrim('TMSA590'))
	nPosLocal   := Ascan(aHeader, { |x| x[2] == "DB_LOCAL"   } )
	nPosLocaliz := Ascan(aHeader, { |x| x[2] == "DB_LOCALIZ" } )
	
	nPosUnitiz  := Ascan(aHeader, { |x| x[2] == "DUH_UNITIZ" } )
	nPosCodAna  := Ascan(aHeader, { |x| x[2] == "DUH_CODANA" } )	
	
	nPosFilDoc  := Ascan(aHeader, { |x| x[2] == "DT6_FILDOC" } )
	nPosDoc     := Ascan(aHeader, { |x| x[2] == "DT6_DOC"    } )
	nPosSerie   := Ascan(aHeader, { |x| x[2] == "DT6_SERIE"  } )
	nPosCodPro  := Ascan(aHeader, { |x| x[2] == "B1_COD"     } )
	nPosAtu     := Len(aHeader)+1
	nPosLocAnt  := Len(aHeader)+2
	nPosUniAnt  := Len(aHeader)+3
	nPosAnaAnt  := Len(aHeader)+4
	
	aCols := Asort(aCols,,, { |x,y| x[nPosAtu] > y[nPosAtu] } )
EndIf	
DTC->(DbSetOrder(3))
DUH->(DbSetOrder(1))
If Type('aCols') == 'A' .And. IsInCallStack(AllTrim('TMSA590'))
	For nCnt := 1 To Len(aCols)
	
		If !aCols[nCnt,nPosAtu]
			Exit
		EndIf
	
		cLocal     := aCols[nCnt, nPosLocal]
		cLocaliz   := aCols[nCnt, nPosLocaliz]
		cUnitiz    := aCols[nCnt, nPosUnitiz]
		cCodAna    := aCols[nCnt, nPosCodAna]
		cFilDoc    := aCols[nCnt, nPosFilDoc]
		cDocto     := aCols[nCnt, nPosDoc]
		cSerie     := aCols[nCnt, nPosSerie]
		cLocalAnt  := aCols[nCnt, nPosLocAnt]
		cUnitizAnt := aCols[nCnt, nPosUniAnt]
		cCodAnaAnt := aCols[nCnt, nPosAnaAnt]
	
		//-- Verifica Endereco
		TMA595EndC(cLocal, cLocaliz, .F.)
				
		If !Empty(cLocal) .And. !Empty(cLocaliz)
			DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDocto+cSerie))
			While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE  == ;
					xFilial("DTC") + cFilDoc + cDocto + cSerie
					
				If DUH->(MsSeek(xFilial("DUH")+cFilAnt+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
					lAtualiza:= cLocal+cLocaliz <> cLocalAnt .Or. cUnitiz+cCodAna <> cUnitizAnt+cCodAnaAnt
					If lAtualiza					
						RecLock("DUH",.F.)
						DUH->DUH_LOCAL  := cLocal
						DUH->DUH_LOCALI := cLocaliz
						DUH->DUH_FILDES := Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRDES,"DUY_FILDES")
						DUH->DUH_UNITIZ := cUnitiz
						DUH->DUH_CODANA := cCodAna 				
						MsUnlock()
					EndIf
				Else
					RecLock("DUH",.T.)
					DUH->DUH_FILIAL := xFilial("DUH")
					DUH->DUH_FILORI := cFilAnt
					DUH->DUH_NUMNFC := DTC->DTC_NUMNFC
					DUH->DUH_SERNFC := DTC->DTC_SERNFC
					DUH->DUH_CLIREM := DTC->DTC_CLIREM
					DUH->DUH_LOJREM := DTC->DTC_LOJREM
					DUH->DUH_QTDVOL := DTC->DTC_QTDVOL
					DUH->DUH_LOCAL  := cLocal
					DUH->DUH_LOCALI := cLocaliz     			
					DUH->DUH_FILDES := Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRDES,"DUY_FILDES")
					DUH->DUH_STATUS := "1"
					
					If lProduto
						DUH->DUH_CODPRO := DTC->DTC_CODPRO
					EndIf
					
					DUH->DUH_UNITIZ := cUnitiz
					DUH->DUH_CODANA := cCodAna 				
	
					MsUnLock()
				EndIf
				DTC->(DbSkip())                              	
			EndDo
		EndIf
		If lAtualiza
			DLGA010Sta(3,cUnitizAnt,cCodAnaAnt,'','',,,,'1')   	          //--Atualiza Status do Unitizador Anterior
			DLGA010Sta(3,cUnitiz,cCodAna,cLocal,cLocaliz,,,,'1')		          //--Atualiza Status do Unitizador Atual	
		EndIf
	Next nCnt	                                                                                              	
Else		                                                                                                    
	If nOpcx == 3
		If Empty(cLocal)
		   cLocal := SuperGetMv('MV_TMSLOCP',,'99') 
		EndIf   

	                       
		//-- Verifica Endereco
		TMA595EndC(cLocal, cLocaliz, .F.)
				
		If !Empty(cLocal) 
			If lEndUnitiz //--Endereca Unitizador
				cUnitiz := Posicione('DUH',1,(cSeekDUH := IIf(FwModeAccess('DUH',3) == 'E',DTC->DTC_FILORI,xFilial("DUH"))+DTC->DTC_FILORI+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM),'DUH_UNITIZ')
				cCodAna := DUH->DUH_CODANA
			EndIf				
			RecLock("DUH",.T.)
			DUH->DUH_FILIAL := xFilial("DUH")
			DUH->DUH_FILORI := cFilAnt
			DUH->DUH_NUMNFC := DTC->DTC_NUMNFC
			DUH->DUH_SERNFC := DTC->DTC_SERNFC
			DUH->DUH_CLIREM := DTC->DTC_CLIREM
			DUH->DUH_LOJREM := DTC->DTC_LOJREM
			DUH->DUH_QTDVOL := DTC->DTC_QTDVOL
			DUH->DUH_LOCAL  := cLocal
			DUH->DUH_LOCALI := cLocaliz     			
			DUH->DUH_FILDES := Posicione("DUY",1,xFilial("DUY")+DTC->DTC_CDRDES,"DUY_FILDES")
			DUH->DUH_STATUS := "1"
			If lProduto
				DUH->DUH_CODPRO := DTC->DTC_CODPRO
			EndIf
			If lEndUnitiz
				DUH->DUH_UNITIZ := cUnitiz
	 			DUH->DUH_CODANA := cCodAna
			EndIf			                            
			MsUnLock()
		EndIf	
		//--Atualiza Status do Unitizador na chegada da viagem	
		If lEndUnitiz
				DLGA010Sta(3,DUH->DUH_UNITIZ,DUH->DUH_CODANA,cLocal,cLocaliz,,,,'1')
		EndIf
	ElseIf nOpcx == 5
		If DUH->(MsSeek(xFilial("DUH")+cFilAnt+DTC->(DTC->DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO)))
			cUnitiz := DUH->DUH_UNITIZ
			cCodAna := DUH->DUH_CODANA
			RecLock("DUH",.F.)
			dbDelete()
			MsUnlock()
		EndIf      
		Posicione('DTA',1,xFilial('DTA')+DTC->(DTC_FILDOC+DTC_DOC+DTC_SERIE),'DTA_FILDCA')		
		DLGA010Sta(3,cUnitiz,cCodAna,DTA->DTA_LOCAL,DTA->DTA_LOCALI,DTA->DTA_FILDCA,DTA->DTA_FILORI,DTA->DTA_VIAGEM,,.T.)
	EndIf     		

EndIf
        
Return
