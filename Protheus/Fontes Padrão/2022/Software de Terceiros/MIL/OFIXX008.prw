// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Protheus.ch"
#include "OFIXX008.ch"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXX008   | Autor |  Manoel Filho         | Data | 03/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Encerramento Manual de OS                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXX008()

Private aRotina   := MenuDef()
Private cCadastro := STR0001

OX008ENC()

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX008ENC   | Autor |  Manoel Filho         | Data | 03/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Encerramento Manual de OS                                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX008ENC()

Local aRet := {}
Local aParamBox := {}
Local dDatIni := Ctod("")
Local dDatFin := Ctod("")
Local cnOSIni := Space(TamSx3("VO1_NUMOSV")[1])
Local cnOSFin := Space(TamSx3("VO1_NUMOSV")[1])
Local cQuery, cQSER := "SQLSERV"
Local nCntFor := 0
Local bOk     := LoadBitmap( GetResources(), "LBOK" )
Local bNo     := LoadBitmap( GetResources(), "LBNO" )
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lContinua := .f.

Private aVetOS  := {}

aAdd(aParamBox,{1,STR0002,cTod(""),x3Picture("VO1_DATABE"),"","","",50,.f.})
aAdd(aParamBox,{1,STR0003,cTod(""),x3Picture("VO1_DATABE"),"MV_PAR02 >= MV_PAR01","","",50,.f.})
aAdd(aParamBox,{1,STR0004,Space(TamSx3("VO1_NUMOSV")[1]),x3Picture("VO1_NUMOSV"),"Vazio() .or. (FG_STRZERO('MV_PAR03',8) .and. (ExistCpo('VO1',MV_PAR03)))","VO1","",0,.f.})
aAdd(aParamBox,{1,STR0005,Space(TamSx3("VO1_NUMOSV")[1]),x3Picture("VO1_NUMOSV"),"If(Vazio(MV_PAR03),Vazio(),(FG_STRZERO('MV_PAR04',8) .and.(ExistCpo('VO1',MV_PAR04) .and. MV_PAR04 >= MV_PAR03)))","VO1","",0,.f.})

If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.,.F.) //
	
	dDatIni := aRet[1]
	dDatFin := aRet[2]
	cnOSIni := aRet[3]
	cnOSFin := aRet[4]
	
	cQuery := "SELECT VO1.VO1_NUMOSV, VO1.VO1_PROVEI, VO1.VO1_LOJPRO, VO1.VO1_DATABE, VO1.VO1_STATUS, VO1.VO1_CHASSI, SA1.A1_NREDUZ, VO1.R_E_C_N_O_ VO1RECNO "
	cQuery += " FROM "+RetSQLName("VO1")+" VO1 JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " AND SA1.A1_COD = VO1.VO1_PROVEI AND SA1.A1_LOJA = VO1.VO1_LOJPRO "
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.VO1_STATUS <> 'F' "
	If !Empty(MV_PAR01)
		cQuery += " AND VO1_DATABE >= '"+dtos(MV_PAR01)+"' "
	Endif
	If !Empty(MV_PAR02)
		cQuery += " AND VO1_DATABE <= '"+dtos(MV_PAR02)+"' "
	Endif
	If !Empty(MV_PAR03)
		cQuery += " AND VO1_NUMOSV >= '"+MV_PAR03+"' "
	Endif
	If !Empty(MV_PAR04)
		cQuery += " AND VO1_NUMOSV <= '"+MV_PAR04+"' "
	Endif
	cQuery += " AND VO1.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSER, .F., .T. )
	// aVetOS
	// 1o Elemento - selecao
	// 2o Elemento - Numero da OS
	// 3o Elemento - Código/Loja/Nome do Proprietario do Veiculo
	// 4o Elemento - Chassi do Veículo
	// 5o Elemento - Data de Abertura
	// 6o Elemento - STATUS
	// 7o Elemento - Recno do VO1
	While !(cQSER)->(Eof())
		cStatusF := FMX_OSSTAT((cQSER)->(VO1_NUMOSV))
		If ( Empty(cStatusF) .or. cStatusF == "F" ) .and. (cQSER)->(VO1_STATUS) <> "F"
			aadd(aVetOS,{.f.,(cQSER)->(VO1_NUMOSV), (cQSER)->(VO1_PROVEI)+"/"+(cQSER)->(VO1_LOJPRO)+"-"+(cQSER)->(A1_NREDUZ), (cQSER)->(VO1_CHASSI), StoD((cQSER)->(VO1_DATABE)),(cQSER)->(VO1_STATUS),(cQSER)->(VO1RECNO)})
		Endif
		(cQSER)->(DbSkip())
	Enddo
	(cQSER)->(dbCloseArea())
	
	If !(Len(aVetOS) > 0 )
		
		MsgInfo(STR0006,STR0007)
		
	Else
		
		DEFINE FONT oTitTela NAME "Arial" SIZE 10,13 BOLD
		
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		//                L   A     LF    AF
		// LF - expande Largura
		// AF - expande Altura
		aAdd( aObjects, { 0 , 0 , .T. , .T. } )
		aPos := MsObjSize( aInfo, aObjects )
		
		While .t.
			nOpca 	  := 0
			lContinua := .f.
			
			DEFINE MSDIALOG ooEncOS FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
			ooEncOS:lEscClose := .F.
			
			// 1o Elemento - selecao
			// 2o Elemento - Numero da OS
			// 3o Elemento - Código/Loja/Nome do Proprietario do Veiculo
			// 4o Elemento - Chassi do Veículo
			// 5o Elemento - Data de Abertura
			// 6o Elemento - STATUS
			// 7o Elemento - Recno do VO1
			@ aPos[1,1]-2,aPos[1,2] TO aPos[1,3],aPos[1,4] LABEL "" OF ooEncOS PIXEL
			@ aPos[1,1]+5,aPos[1,2]+3 LISTBOX oLbVetOS FIELDS HEADER (" "),;
			VO1->(RetTitle("VO1_NUMOSV")),;
			VO1->(RetTitle("VO1_PROVEI")),;
			VO1->(RetTitle("VO1_CHASSI")),;
			VO1->(RetTitle("VO1_DATABE")),;
			VO1->(RetTitle("VO1_STATUS")) ;
			COLSIZES 20,95,95,95,95,95 SIZE aPos[1,4]-9,aPos[1,3]-aPos[1,1]-8 OF ooEncOS PIXEL ON DBLCLICK ( Iif(oLbVetOS:nColPos==1,(IIf(aVetOS[oLbVetOS:nAt,1],aVetOS[oLbVetOS:nAt,1]:=.F.,aVetOS[oLbVetOS:nAt,1]:=.T.),IIf(aVetOS[oLbVetOS:nAt,1],bOk,bNo)), OX008MOS() ) )
			
			oLbVetOS:SetArray(aVetOS)
			oLbVetOS:bLine := { || { IIf(aVetOS[oLbVetOS:nAt,1],bOk,bNo) ,;
			aVetOS[oLbVetOS:nAt,2] ,;
			aVetOS[oLbVetOS:nAt,3] ,;
			aVetOS[oLbVetOS:nAt,4] ,;
			aVetOS[oLbVetOS:nAt,5] ,;
			aVetOS[oLbVetOS:nAt,6] }}
			
			ACTIVATE MSDIALOG ooEncOS CENTER ON INIT (EnchoiceBar(ooEncOS, { || nOpca := 1, ooEncOS:End() } , { || nOpca := 2,ooEncOS:End() },,))
			
			If nOpca == 1
				For nCntFor := 1 to len(aVetOS)
					If aVetOS[nCntFor,1]
						lContinua := .t.
					Endif
				Next
				If lContinua
					If MsgYesNo(STR0008,STR0007)
						DbSelectArea("VO1")
						For nCntFor := 1 to len(aVetOS)
							If aVetOS[nCntFor,1]
								DbGoTo(aVetOS[nCntFor,7])
								RecLock("VO1",.f.)
								VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV,"F")
								MsUnlock()
							Endif
						Next
						MsgInfo(STR0009,STR0007)
					Else
						Loop
					Endif
				Else
					MsgInfo(STR0010,STR0007)
				Endif
			Endif
			exit
		Enddo
	Endif
Endif
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OX008MOS ³ Autor ³ Manoel Filho                      ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta de OS                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX008MOS()
aCampos   := {}
inclui    := .f.
altera    := .f.
visualiza := .t.
nopc      := 2
DbSelectArea("VO1")
OC060("VO1",aVetOS[oLbVetOS:nAt,7],nopc)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Manoel Filho                      ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) -                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
aRotina := { 	{ "" , "axPesqui"   , 0 , 1},;	// Pesquisar
				{ "" , "OC060"      , 0 , 2},;	// Visualizar
				{ "" , "OX008ENC"   , 0 , 4}}	// Encerrar
Return aRotina