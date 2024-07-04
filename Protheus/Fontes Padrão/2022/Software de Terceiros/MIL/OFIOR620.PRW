#Include "OFIOR620.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³OFIOR620ºAutor³ Ronaldo / Andre Luis Almeida ºData³ 04/10/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Estoque Minimo e Seguranca Oficina                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Auto Pecas / Oficina                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR620()

Private cTitulo  := STR0001 //Estoque Minimo e Seguranca Oficina
Private cDesc1   := cTitulo
Private cDesc2   := ""
Private cDesc3   := ""
Private cNomeRel := "OFIOR620"
Private cPerg    := "OFR620"
Private cAlias   := "SB1"
Private cabec1   := STR0002 //Item (Grupo/Codigo/Descricao)                Estoque: Disponivel  Minimo Seguran
Private cabec2   := ""
Private nLin     := 1
Private aPag     := 1
Private m_Pag    := 1
Private aReturn  := { STR0003, 1,STR0004, 2, 2, 1, "",1 }//Zebrado # Administracao
Private cTamanho := "P" // P/M/G
Private Limite   := 80  // 80/132/220
Private aOrdem   := {}
Private nLastKey := 0
Private nCaracter:= 15
Private lB1_ESTMIN := ( SB1->(FieldPos("B1_ESTMIN")) # 0 ) 

//AADD(aRegs,{STR0009 , "", "", "mv_ch1", "N", 1                             , 0, 0, "C", '', "mv_par01", STR0005, "" , "" , "" , "" , STR0010 , "" , "" , "" , "" , STR0011 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""    , "" , "" , "" ,{STR0012},{},{}})
//AADD(aRegs,{STR0013 , "", "", "mv_ch2", "C", SB1->(TamSx3("B1_GRUPO")[1]) , 0, 0, "G", '', "mv_par02", ""     , "" , "" , "" , "" , ""      , "" , "" , "" , "" , ""      , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SBM" , "" , "" , "" ,{STR0014},{},{}})
//AADD(aRegs,{STR0017 , "", "", "mv_ch3", "C", SB1->(TamSx3("B1_GRUPO")[1]) , 0, 0, "G", '', "mv_par03", ""     , "" , "" , "" , "" , ""      , "" , "" , "" , "" , ""      , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SBM" , "" , "" , "" ,{STR0018},{},{}})
//AADD(aRegs,{STR0015 , "", "", "mv_ch4", "C", SB1->(TamSx3("B1_CODITE")[1]), 0, 0, "G", '', "mv_par04", ""     , "" , "" , "" , "" , ""      , "" , "" , "" , "" , ""      , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SB1" , "" , "" , "" ,{STR0016},{},{}})
//AADD(aRegs,{STR0019 , "", "", "mv_ch5", "C", SB1->(TamSx3("B1_CODITE")[1]), 0, 0, "G", '', "mv_par05", ""     , "" , "" , "" , "" , ""      , "" , "" , "" , "" , ""      , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SB1" , "" , "" , "" ,{STR0020},{},{}})

cNomeRel:=SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
If nLastKey == 27
	Return
Endif
Pergunte(cPerg,.f.)

SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_OFR620(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
MS_Flush()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FS_OFR620ºAutor³ Ronaldo / Andre Luis Almeida ºData³04/10/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Impressao do Estoque Minimo e Seguranca Oficina             º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OFR620
Local lIM     := .t. // Imprime Estoque Minimo
Local lIS     := .t. // Imprime Estoque Seguranca
Local ni      := 0
Local nQtd    := 0   // Qtde Disponivel
Local cAno    := strzero(Year(dDatabase),4)
Local cMes    := strzero(Month(dDatabase)-1,2)
Local cQuery  := ""
Local nEstMin := 0
Local nEstSeg := 0
If cMes == "00"
	cAno := strzero(Year(dDatabase)-1,4)
	cMes := "12"
EndIf
If MV_PAR01 # 3
	If MV_PAR01 == 1
		cTitulo := STR0005 //Estoque Minimo
		cabec1  := STR0006 //Item (Grupo/Codigo/Descricao)                Estoque: Disponivel  Minimo        
		lIM := .t. // Minimo
		lIS := .f. // Seguranca
	Else // MV_PAR01 == 2
		cTitulo := STR0007 //Estoque Seguranca
		cabec1  := STR0008 //Item (Grupo/Codigo/Descricao)                Estoque: Disponivel       Seguranca
		lIM := .f. // Minimo
		lIS := .t. // Seguranca
	EndIf
EndIf
DbSelectArea("SB1")
DbSetOrder(7)
DbSeek( xFilial("SB1") + IIf(!Empty(MV_PAR02),MV_PAR02,"") , .t. )
SetRegua( ( RecCount() / 300 ) )
ni := 0
nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
while !Eof() .and. xFilial("SB1") == SB1->B1_FILIAL
	ni++
	If ni == 300
		ni := 0
		IncRegua()
	EndIf
	If !Empty(MV_PAR02) .and. MV_PAR02 > SB1->B1_GRUPO
		SB1->(dbSkip())
		Loop
	EndIf
	If !Empty(MV_PAR03) .and. MV_PAR03 < SB1->B1_GRUPO
		Exit
	EndIf
	If !Empty(MV_PAR04) .and. MV_PAR04 > SB1->B1_CODITE
		SB1->(dbSkip())
		Loop
	EndIf
	If !Empty(MV_PAR05) .and. MV_PAR05 < SB1->B1_CODITE
		SB1->(dbSkip())
		Loop
	EndIf
	nEstMin := 0
	nEstSeg := 0
	If lIM 
		If lB1_ESTMIN
			nEstMin := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTMIN")
		Else
			nEstMin := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_EMIN")
		EndIf
	EndIf
	If lIS
		nEstSeg := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTSEG")
	EndIf
	If ( nEstMin+nEstSeg > 0 ) 
		If MV_PAR01 == 3 .or. ( MV_PAR01 == 1 .and. nEstMin > 0 ) .or. ( MV_PAR01 == 2 .and. nEstSeg > 0 )
			cQuery := "SELECT SUM(SB2.B2_QATU) AS QTDE FROM "+RetSQLName("SB2")+" SB2 WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND "
			cQuery += "SB2.B2_COD='"+SB1->B1_COD+"' AND SB2.B2_LOCAL>='01' AND SB2.B2_LOCAL<='50' AND SB2.D_E_L_E_T_=' '"
			nQtd := FM_SQL(cQuery)
			SBL->(DbSetOrder(1))
			SBL->(DbSeek( xFilial("SBL") + SB1->B1_COD + cAno + cMes , .f. ))
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
			Endif
			@nLin++ , 00 Psay SB1->B1_GRUPO +" "+ left(SB1->B1_CODITE,25) + left(SB1->B1_DESC,23) +" "+ SBL->BL_ABCVEND+SBL->BL_ABCCUST + transform(nQtd,"@E 9999,999") + IIf(lIM,Transform(nEstMin,"@E 9999,999"),space(8)) + If(lIS,Transform(nEstSeg,"@E 9999,999"),space(8))
        EndIf
	EndIf
	SB1->(dbSkip())
EndDo
Return