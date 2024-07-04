#Include "Co_Impc.ch"
#include "FiveWin.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CO_IMPC()³ Autor ³ Denis Martins            ³ Data ³ 06.10.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Edicao das al¡quotas de impostos de ICA e Fuente               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Localizacoes Colombia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS    ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Denis Martins³06/10/99³XXXXXX   ³Inicializacao...                         ³±±
±±³ Denis Martins³02/09/00³XXXXXX   ³Melhoramento nas Funcoes AIVAALTERA,AICA-³±±
±±³              ³        ³XXXXXX   ³ALTERA.                                  ³±±
±±³ Rubens Pante ³16/02/01³xxxxxx   ³Criado arquivo .CH exclusivo para este   ³±±
±±³              ³        ³         ³progama. Retirado rodape "total de itens"³±±
±±³              ³        ³         ³desnecessario das janelas de edicao. Pa- ³±±
±±³              ³        ³         ³ronizado os titulos das janelas.         ³±±
±±³ Rubens Pante ³05/08/01³xxxxxx   ³Acertadas rotinas para utilizarem somente³±±
±±³ M.Camargo    ³09/11/15³PCREQ-   ³Merge V12.1.8                            ³±±
±±³              ³        ³4262     ³                                         ³±±
±±³   Marco A.   ³28/12/16³SERINN001³Se aplica CTREE para evitar la creacion  ³±±
±±³              ³        ³-538     ³de tablas temporales de manera fisica    ³±±
±±³              ³        ³         ³en system.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function co_impc()

	Private cFilSFF := xFilial("SFF")

	mv_par01 := 0
	//Variaveis utilizadas para parametros
	//mv_par01  // Tabla generica de ? Ret. ICA, Ret. Fuente /Ret. TIMBRE
	If Pergunte("GAF000", .T.)
		IF mv_par01 == 1
			ACOICA()
		ElseIf mv_par01 == 2
			ACOFUENTE()
		ElseIf mv_par01 == 3
			ACOTIMBRE()
		EndIf
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOICA()  ºAutor  ³Denis Martins       º Data ³  06/10/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Edicao das aliquotas de Retencao de ICA                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACOICA()

	Local aIndexSFF		:= {}
	Local bFiltraBrw
	Local cFiltraSFF 	:= ""

	aRotina 	:= {{OemToAnsi(STR0001), "AImpVisual"	, 0, 2},;
					{OemToAnsi(STR0002), "AImpIncluir"	, 0, 3},;
					{OemToAnsi(STR0003), "AImpAlterar"	, 0, 4},;
					{OemToAnsi(STR0004), "AImpExcluir"	, 0, 5} }
	aFixe		:= {}
	nUsado		:= 0
	cCadastro	:= OemToAnsi(STR0005) //"Retencion de ICA"

	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("FF_ZONFIS")
	aAdd(aFixe,{ AllTrim(X3Titulo()), SX3->X3_CAMPO } )
	dbSeek("FF_COD_TAB")
	aAdd(aFixe,{ AllTrim(X3Titulo()), SX3->X3_CAMPO } )
	dbSeek("FF_CFO_C")
	aAdd(aFixe,{ AllTrim(X3Titulo()), SX3->X3_CAMPO } )

	dbSelectArea("SFF")
	dbSetOrder(11)
	If cPaisLoc == "COL"
		cFiltraSFF	:=	"FF_FILIAL == '" + xFilial("SFF") + "' .And. SubStr(FF_IMPOSTO,1,2) == 'IC'"
	EndIf
	bFiltraBrw 	:= {|| FilBrowse("SFF",@aIndexSFF,@cFiltraSFF) }
	Eval(bFiltraBrw)

	mBrowse(6,1,22,75,"SFF",aFixe)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SFF",aIndexSFF)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AImpVisual  ºAutor  ³Denis Martins       º Data ³  06/10/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelas Rotinas de Visualizacao dos Impostos º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AImpVisual(cAlias, nReg, nOpcx)
	
	If mv_par01 == 1
		AIcaVisual(cAlias, nReg, nOpcx)
	ElseIf mv_par01 == 2
		ARfuVisual(cAlias, nReg, nOpcx)    
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AImpIncluir ºAutor  ³Denis Martins       º Data ³  06/10/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelas Rotinas de Inclusao dos Impostos     º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AImpIncluir()
	
	If mv_par01 == 1
		AicaInclui()
	ElseIf mv_par01 == 2
		ARfuInclui()
	EndIf
	
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AImpAlterar ºAutor  ³Denis Martins       º Data ³  06/10/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelas Rotinas de Alteracao dos Impostos    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AimpAlterar(cAlias, nReg, nOpcx)
	
	If mv_par01 == 1
		AicaAltera(cAlias, nReg, nOpcx)
	ElseIf mv_par01 == 2
		ARfuAltera(cAlias, nReg, nOpcx)	
	EndIf
	
Return             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AImpExcluir ºAutor  ³Denis Martins       º Data ³  06/10/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelas Rotinas de Exclusao  dos Impostos    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AimpExcluir(cAlias, nReg, nOpcx)

	If mv_par01 == 1
		AicaExclui(cAlias, nReg, nOpcx)
	ElseIf mv_par01 == 2
		ARfuExclui(cAlias, nReg, nOpcx)
	EndIf
	
Return
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³AICAVISUALºAuthor ³Denis Martins       º Date ³  10/23/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualizacao de ICA                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ CO_IMPC - Impostos Colombia                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AIcaVisual(cAlias,nReg,nOpcx)
	
	Local nY	:= 0
	Local nI	:= 0
	Local nSFF	:= SFF->(Recno()) 
	
	aColunas	:= {"FF_CFO_C","FF_ZONFIS","FF_COD_TAB","FF_ALIQ","FF_FXDE","FF_PERC","FF_FLAG"}
	aHeader		:= {}
	aCols		:= {}
	nUsado		:= 0  
	cDesc		:= Space(30)
	nOpcx		:= 2

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	aAdd(aCols,Array(nUsado+1))

	For nY := 1 to nUsado
		If ( aHeader[nY,10] != "V")
			aCols[1,nY] := CriaVar(aHeader[nY,2])
		EndIf
	Next nY
	aCols[1,nUsado+1] := .F.
	aCopiaCols 		  := Aclone(aCols[1])

	cNum := SFF->FF_IMPOSTO
	
	//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
	aC := {}
	
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.

	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","ExecBlock('VerNomSFB',.f.,.f.,,.t.)",,})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})

	aR:={}

	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}
	//Validacoes na GetDados da Modelo 2
	cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"
	//Montando aCols
	nCnt := 0
	cCFOc   := SFF->FF_CFO_C
	cZonFis := SFF->FF_ZONFIS
	cCodTab := SFF->FF_COD_TAB

	VerNomSFB()

	dbSelectArea("SFF")
	dbSetOrder(5)
	dbSeek(cFilSFF+cNum+cCFOc+cZonFis)
	While !EOF()
		If SFF->FF_COD_TAB == cCodTab
			nCnt:=nCnt+1
		EndIf
		dbSkip()
	EndDo

	If nCnt == 0
		Help(" ",1,"NOITENS")
		Return
	EndIf

	aRecnos	:=	Array(nCnt)

	//Montando aCols
	nCnt := 0
	nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
	nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
	nCodTab := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_COD_TAB"})
	nZon    := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})

	lAchei := .F.
	dbSelectArea("SFF")
	dbSetOrder(5)
	dbSeek(cFilSFF+cNum+cCFOc+cZonFis)
	While !Eof() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C+FF_ZONFIS == cFilSFF+cNum+cCFOc+cZonFis
		If SFF->FF_COD_TAB == cCodTab
			nCnt := nCnt+1
			If nCnt > 1
				aAdd(aCols, Aclone(aCopiaCols))
			EndIf
			aCOLS[nCnt,nAliq]    := SFF->FF_ALIQ
			aCOLS[nCnt,nCFOc]    := SFF->FF_CFO_C
			aCOLS[nCnt,nFaDe]    := SFF->FF_FXDE
			aCOLS[nCnt,nPerc]    := SFF->FF_PERC   
			aCOLS[nCnt,nCodTab]  := SFF->FF_COD_TAB
			aCOLS[nCnt,nZon]     := SFF->FF_ZONFIS
			aCOLS[nCnt,nUsado+1] := .F.
			aRecnos[nCnt]	       :=	SFF->(Recno())
			lAchei := .T.
		EndIf
		dbSkip()      
	EndDo

	// Variaveis do Rodape do Modelo 2
	nTotalItens := nCnt
	// Chamada da Modelo2
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	lRetMod2 := Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

	dbSelectArea("SFF")
	dbSetOrder(11)
	dbGoTo(nSFF)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AicaInclui ºAutor  ³Denis Martins       º Data ³  06/10/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelas Rotinas de Alteracao dos Impostos    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AicaInclui()
	
	Local nX := 0
	Local nI := 0
	Local nY := 0
	
	aColunas  := {"FF_CFO_C","FF_ZONFIS","FF_COD_TAB","FF_ALIQ","FF_FXDE","FF_PERC"}
	aHeader   := {}
	aCols     := {}
	nCnt	  := 0
	cNum	  := Space(03)
	nUsado    := 0
	cCampo    := ""
	nI        := 0 
	cDesc     := Space(30)
	nOpcx     := 3

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	aAdd(aCols,Array(nUsado+1))  

	For nI := 1 to nUsado
		cCampo := Alltrim(aHeader[nI,2])
		If aHeader[nI,10] #"V"
			If aHeader[nI,8] == "C"
				aCOLS[1,nI] := SPACE(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCOLS[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCOLS[1,nI] := dDataBase
			ElseIf aHeader[nI,8] == "M"
				aCOLS[1,nI] := ""
			Else
				aCOLS[1,nI] := .F.
			EndIf
		Else
			aCols[1,nI] := CriaVar(cCampo)
		EndIf
	Next nI
	aCOLS[1,nUsado+1] := .F.
	
	//Array com descricao dos campos do Cabecalho do Modelo 2
	aC := {}

	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.

	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","VerNomSFB()",,.T.})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})
	
	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}

	//Array com coordenadas do Rodape no modelo2
	aR := {}
	//Inclusao do Modelo 2
	cLinhaOk := "ExecBlock('coverif',.F.,.F.,,.T.)" 
	cTudoOk  := "ExecBlock('covtudo',.F.,.F.,,.T.)"	

	RetMod2:= Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

	If RetMod2
		nMaxArray   := 0
		nTotalItens := 0
		nMaxArray   := Len(aCols)
		aRecnos     := {}
		nCntItem    := 1

		nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
		nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
		nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
		nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
		nCodTab := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_COD_TAB"})
		nZon    := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})

		For nX := 1 to nMaxArray
			IF !aCols[nX,Len(aCols[nX])]
				dbSelectArea("SFF")
				RecLock("SFF",.T.)
				Replace FF_FILIAL  With xFilial("SFF"),;
				FF_ALIQ    With aCols[nX,nAliq],;
				FF_CFO_C   With aCols[nX,nCFOc],;
				FF_FXDE	 With aCols[nX,nFaDe],;
				FF_ZONFIS  With aCols[nX,nZon],;
				FF_COD_TAB With aCols[nX,nCodTab],;
				FF_FLAG    With "0",; 
				FF_IMPOSTO With cNum
				
				//Atualiza dados do corpo do Remito.
				For nY := 1 To nUsado
					If aHeader[nY,10] #"V"
						cCampo := AllTrim(aHeader[nY,2])
						FieldPut(FieldPos(cCampo),aCols[nX,nY])
					EndIf
				Next nY
				nTotalItens := nTotalItens + 1
				dbUnLock() 
			EndIf
		Next nX  
	EndIf       

	dbSelectArea("SFF")
	dbSetOrder(11)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AicaAlteraºAutor  ³Denis Martins       º Data ³  10/07/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³     Alteraca de ICA - Impostos de Industria e Comercio     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CO_IMPC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AicaAltera(cAlias,nReg,nOpcx)
	
	Local nI	:= 0 
	Local nY	:= 0
	Local nX	:= 0  
	Local nSFF	:= SFF->(Recno()) 

	aColunas:= {"FF_CFO_C","FF_ZONFIS","FF_COD_TAB","FF_ALIQ","FF_FXDE","FF_PERC","FF_FLAG"}
	aHeader := {}
	aCols   := {}
	nUsado  := 0
	cDesc   := Space(30)
	nOpcx   := 6

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	aAdd(aCols,Array(nUsado+1))

	For nY := 1 to nUsado
		If ( aHeader[nY,10] != "V")
			aCols[1,nY] := CriaVar(aHeader[nY,2])
		EndIf
	Next nY

	aCols[1,nUsado+1]	:= .F.
	aCopiaCols 			:= Aclone(aCols[1])
	cNum   := SFF->FF_IMPOSTO
	cCFOc  := SFF->FF_CFO_C
	cZonfis:= SFF->FF_ZONFIS
	cCodIca:= SFF->FF_COD_TAB

	//Montando aCols
	nCnt := 0

	//Array com descricao dos campos do Cabecalho do Modelo 2
	aC:={}
	
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.

	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","ExecBlock('VerNomSFB',.F.,.F.,,.T.)",,.F.})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})

	VerNomSFB()
	//Variaveis do Rodape do Modelo 2
	nTotalItens := 0

	aR:={}

	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}

	//Validacoes na GetDados da Modelo 2
	cLinhaOk:="ExecBlock('coverif',.F.,.F.,,.T.)"
	cTudoOk :="ExecBlock('covtalt',.F.,.F.,,.T.)"

	aGetEdit := {}

	dbSelectArea("SFF")
	dbSetOrder(5)
	dbGoTop()
	dbSeek(cFilSFF+cNum+cCFOc+cZonfis)
	While !Eof() 
		If SFF->FF_COD_TAB == cCodIca
			nCnt := nCnt +1
		EndIf   
		dbSkip()
	EndDo	  

	If nCnt == 0
		Help(" ",1,"NOITENS")
		Return
	EndIf

	//aCols	:=	Array(nCnt,9)
	aRecnos	:=	Array(nCnt)
	//Montando aCols
	nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
	nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
	nCodTab := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_COD_TAB"})
	nZon    := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})

	nCnt := 0
	dbSelectArea("SFF")
	dbSetOrder(5)   
	dbSeek(cFilSFF+cNum+cCFOc+cZonFis)
	While !EOF() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C+FF_ZONFIS == cFilSFF+cNum+cCFOc+cZonFis
		If FF_COD_TAB == cCodIca 
			nCnt:=nCnt+1
			If nCnt > 1
				aAdd(aCols, Aclone(aCopiaCols))
			EndIf
			aCOLS[nCnt,nAliq]   := SFF->FF_ALIQ
			aCOLS[nCnt,nCFOc]   := SFF->FF_CFO_C  
			aCOLS[nCnt,nFaDe]   := SFF->FF_FXDE 
			aCOLS[nCnt,nPerc]   := SFF->FF_PERC    
			aCOLS[nCnt,nCodTab] := SFF->FF_COD_TAB
			aCOLS[nCnt,nZon]    := SFF->FF_ZONFIS
			aCOLS[nCnt,nUsado+1]:= .F.
			aRecnos[nCnt]		 := SFF->(Recno())
			cVerAltera           := SFF->FF_FLAG
		EndIf
		dbSkip()
	EndDo
	nTotalItens :=0               
	nTotalItens := nCnt
	aVer := aClone(aCols) 

	//Chamada da Modelo2
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	If cVerAltera == "1"
		MsgStop(OemToAnsi(STR0008))  //"No es posible modificar"

		dbSelectArea("SFF")
		dbSetOrder(11)

		Return
	EndIf   
	lRetMod2:=Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente
	If lRetMod2
		nCntItem:= 1
		For nX := 1 to Len(aCols)
			IF !aCols[nX,Len(aCols[nX])]
				//Se e um iten novo, incluir-lo , senao so atualizar
				If nX > nTotalItens
					RecLock("SFF",.T.)
				Else
					SFF->(DbGoTo(aRecnos[nX]))
					RecLock("SFF",.F.)
				EndIf
				Replace 	FF_FILIAL  With xFilial("SFF")
				
				//Atualiza dados do corpo da Tabela.
				For nY := 1 to nUsado
					If aHeader[nY][10] #"V"
						cVar := Trim(aHeader[nY,2])
						If cVar == "FF_ALIQ"
							Replace FF_ALIQ     	With aCols[nX,nY]
						ElseIf cVar == "FF_CFO_C"
							Replace FF_CFO_C   	    With aCols[nX,nY]
						ElseIf cVar == "FF_FXDE"
							Replace FF_FXDE      	With aCols[nX,nY]
						ElseIf cVar == "FF_PERC"
							Replace FF_PERC     	With aCols[nX,nY]
						ElseIf cVar == "FF_COD_TAB"
							Replace FF_COD_TAB  	With aCols[nX,nY]
						ElseIf cVar == "FF_ZONFIS"
							Replace FF_ZONFIS   	With aCols[nX,nY] 
						EndIf
					EndIf
				Next nY
				MsUnLock()
				nCntItem:=nCntItem + 1
			Else
				If nX <=	nTotItens
					SFF->(DbGoTo(aRecnos[nX]))
					RecLock("SFF",.F.)
					SFF->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next nX
	EndIf   

	dbSelectArea("SFF")
	dbSetOrder(11)
	dbGoTo(nSFF)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AicaExcluiºAutor  ³Denis Martins       º Data ³  10/07/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³     Exclusao de ICA - Impostos de Industria e Comercio     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ /Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AicaExclui(cAlias,nReg,nOpcx)
	
	Local nY := 0
	Local nI := 0
	
	aColunas:= {"FF_CFO_C","FF_ZONFIS","FF_COD_TAB","FF_ALIQ","FF_FXDE","FF_PERC","FF_FLAG"}
	aHeader := {}
	aCols   := {}
	nUsado  := 0
	cDesc   := Space(30)
	nOpcx   := 5
	aRecnos := {}

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	aAdd(aCols,Array(nUsado+1))

	For nY := 1 to nUsado
		If ( aHeader[nY,10] != "V")
			aCols[1,nY] := CriaVar(aHeader[nY,2])
		EndIf
	Next nY

	aCols[1,nUsado+1] := .F.
	aCopiaCols		   := aClone(aCols[1])

	cNum   := SFF->FF_IMPOSTO
	cCFOc  := SFF->FF_CFO_C
	cZonfis:= SFF->FF_ZONFIS
	cCodIca:= SFF->FF_COD_TAB

	//Montando aCols
	nCnt := 0
	nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
	nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
	nCodTab := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_COD_TAB"})
	nZon    := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})

	lAchei := .F.
	dbSelectArea("SFF")
	dbSetOrder(5)
	dbSeek(cFilSFF+cNum+cCFOc+cZonFis)
	While !Eof() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C+FF_ZONFIS == cFilSFF+cNum+cCFOc+cZonFis
		If SFF->FF_COD_TAB == cCodIca
			nCnt := nCnt + 1
			If nCnt > 1
				aAdd(aCols, Aclone(aCopiaCols))
			EndIf
			aCOLS[nCnt,nAliq]    := SFF->FF_ALIQ
			aCOLS[nCnt,nCFOc]    := SFF->FF_CFO_C
			aCOLS[nCnt,nFaDe]    := SFF->FF_FXDE
			aCOLS[nCnt,nPerc]    := SFF->FF_PERC   
			aCOLS[nCnt,nCodTab]  := SFF->FF_COD_TAB
			aCOLS[nCnt,nZon]     := SFF->FF_ZONFIS
			aCOLS[nCnt,nUsado+1] := .F.
			aAdd(aRecnos, SFF->(Recno()))
			lAchei := .T.
		EndIf
		dbSkip()      
	EndDo

	//Array com descricao dos campos do Cabecalho do Modelo 2
	aC := {}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.

	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","ExecBlock('VerNomSFB',.F.,.F.,,.T.)",,.F.})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})

	VerNomSFB()
	//Variaveis do Rodape do Modelo 2
	nTotalItens := nCnt

	aR:={}

	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}

	//Validacoes na GetDados da Modelo 2
	aGetEdit := {}

	nCnt := 0

	dbSelectArea("SFF")
	dbSetOrder(5)
	dbGoTop()
	dbSeek(xFilial("SFF")+cNum+cCFOc+cZonfis)
	While !Eof() 
		If SFF->FF_COD_TAB == cCodIca
			nCnt := nCnt +1
		EndIf   
		dbSkip()
	EndDo	  

	If nCnt == 0
		Help(" ",1,"NOITENS")
		Return
	EndIf

	aRecnos	:=	Array(nCnt)
	//Montando aCols
	nCnt := 0         

	nTotalItens := nCnt
	aVer := aClone(aCols) 

	//Chamada da Modelo2
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	lRetMod2 := Modelo2(cCadastro,aC,aR,aCGD,nOpcx,".T.",".T.")

	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente
	If lRetMod2  
		lAchei := .F.
		dbSelectArea("SFF")
		dbSetOrder(5)   
		dbSeek(cFilSFF+cNum+cCFOc+cZonFis)
		While !Eof() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C+FF_ZONFIS == cFilSFF+cNum+cCFOc+cZonFis
			If SFF->FF_COD_TAB == cCodIca
				RecLock("SFF",.F.)
				dbDelete()
				dbUnLock()           
				lAchei := .T.
			EndIf   
			dbSkip()   
		EndDo
	EndIf   

	dbSelectArea("SFF")
	dbSetOrder(11)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOFUENTE ºAutor  ³Denis Martins       º Data ³  10/23/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel pelo Direcionamento dos Calculos Retencao da    º±±
±±º          ³Fonte                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function ACOFUENTE() 

	Local aIndexSFF		:= {}
	Local bFiltraBrw
	Local cFiltraSFF 	:= ""

	aRotina :=	{{OemToAnsi(STR0001),"AImpVisual", 0,2},;
				{OemToAnsi(STR0002),"AImpIncluir",0,3},;
				{OemToAnsi(STR0003),"AImpAlterar",0,4},;
				{OemToAnsi(STR0004),"AImpExcluir",0,5} }

	aHeader := {}
	aCols   := {}                   
	aFixe   := {}
	nUsado  := 0
	cCadastro := OemToAnsi(STR0009) //"Retencion en la Fuente"

	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("FF_CFO_C")
	aAdd(aFixe,{ AllTrim(X3Titulo()), SX3->X3_CAMPO } )

	If cPaisLoc == "COL"
		dbSelectArea("SFF")
		dbSetOrder(5)
		cFiltraSFF	:=	"FF_FILIAL == '" + xFilial("SFF") + "' .And. SubStr(FF_IMPOSTO,1,2) == 'RF'"
		bFiltraBrw 	:= {|| FilBrowse("SFF",@aIndexSFF,@cFiltraSFF) }
		Eval(bFiltraBrw)
	EndIf

	mBrowse(6,1,22,75,"SFF",aFixe)

	If cPaisLoc == "COL"
		//Finaliza o uso da funcao FilBrowse e retorna os indices padroes.
		EndFilBrw("SFF",aIndexSFF)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARFUVISUALºAutor  ³Denis Martins       º Data ³  03/02/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel pela rotina de visualizacao da Retencao na Fonteº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ARFUVISUAL(cAlias, nReg, nOpcx)
	
	Local nY	:= 0
	Local nI	:= 0                         
	Local nSFF 	:= SFF->(Recno()) 
	
	aColunas:= {"FF_CFO_C","FF_ALIQ","FF_FXDE","FF_PERC","FF_FLAG"}
	aHeader := {}
	aCols   := {}
	nUsado  := 0  
	cDesc   := Space(30)
	nOpcx   := 2

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	aCopiaCols := Array(nUsado+1)

	For nY := 1 to nUsado
		If ( aHeader[nY,10] != "V")
			aCopiaCols[nY] := CriaVar(aHeader[nY,2])
		EndIf
	Next nY
	aCopiaCols[nUsado+1] := .F.

	//Array com descricao dos campos do Cabecalho do Modelo 2
	aC := {}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","ExecBlock('VerNomSFB',.f.,.f.,,.t.)",,})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})
	
	aR:={}

	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}

	//Validacoes na GetDados da Modelo 2
	cLinhaOk := "ExecBlock('coverif',.F.,.F.,,.T.)" 
	cTudoOk  := "ExecBlock('covtudo',.F.,.F.,,.T.)"	

	//Montando aCols
	nCnt	:= 0
	cNum    := SFF->FF_IMPOSTO
	cCFOc   := SFF->FF_CFO_C
	VerNomSFB()

	//Montando aCols
	nCnt := 0            
	nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
	nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"}) 
	nRegAtu := SFF->(Recno()) 
	dbSelectArea("SFF")
	dbSetOrder(5)
	dbSeek(cFilSFF+cNum+cCFOc)
	While ! EOF() .And. cFilSFF+cNum+cCFOc == FF_FILIAL+FF_IMPOSTO+FF_CFO_C
		nCnt := nCnt+1
		aAdd(aCols, ACLONE(aCopiaCols))
		aCOLS[nCnt][nAliq]   := SFF->FF_ALIQ
		aCOLS[nCnt][nCFOc]   := SFF->FF_CFO_C
		aCOLS[nCnt][nFaDe]   := SFF->FF_FXDE
		aCOLS[nCnt][nPerc]   := SFF->FF_PERC
		aCOLS[nCnt][6]       := .F.
		dbSkip()
	EndDo

	If nCnt > 0
		// Variavel do Rodape do Modelo 2
		nTotalItens :=nCnt
		lRetMod2:=Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

		dbSelectArea("SFF")
		dbSetOrder(5)
		dbGoTo(nSFF)
	Else
		Help(" ",1,"NOITENS")
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARFUINCLUIºAutor  ³Denis Martins       º Data ³  03/02/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel pela Rotina de Inclusao de Retencao na Fonte    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ARFUINCLUI(cAlias,nReg,nOpcx)
	
	Local nX := 0
	Local nI := 0
	
	aColunas  := {"FF_CFO_C","FF_ALIQ","FF_FXDE","FF_PERC","FF_ZONFIS"}
	nUsado    := 0  
	cDesc	  := Space(30)
	cNum      := Space(3)
	aHeader   := {}
	aCols     := {}
	lAchou    := .F.
	lRet	  := .T.
	nOpcx     := 3

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	aAdd(aCols,Array(nUsado+1))  

	For nI := 1 to nUsado
		cCampo := Alltrim(aHeader[nI,2])
		If aHeader[nI,10] #"V"
			If aHeader[nI,8] == "C"
				aCOLS[1,nI] := SPACE(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCOLS[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCOLS[1,nI] := dDataBase
			ElseIf aHeader[nI,8] == "M"
				aCOLS[1,nI] := ""
			Else
				aCOLS[1,nI] := .F.
			EndIf
		Else
			aCols[1,nI] := CriaVar(cCampo)
		EndIf
	Next nI
	aCOLS[1,nUsado+1] := .F.
	nTotalItens := 0

	//Array com descricao dos campos do Cabecalho do Modelo 2
	aC := {}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","ExecBlock('VerNomSFB',.f.,.f.,,.t.)",,})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})
	
	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}
	
	//Array com coordenadas do Rodape no modelo2
	aR := {}
	
	//Inclusao do Modelo 2
	cLinhaOk := "ExecBlock('coverif',.F.,.F.,,.T.)"
	cTudoOk  := "ExecBlock('covtudo',.F.,.F.,,.T.)"

	dbSelectArea("SFF")
	dbSetOrder(5)
	RetMod2:= Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
	dbSelectArea("SFF")

	If RetMod2            
		nMaxArray := 0
		nMaxArray := Len(aCols)
		aRecnos := {}
		nCntItem:= 1
		nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
		cCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
		nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
		nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
		nZonF   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})

		For nX := 1 to nMaxArray
			If !aCols[nX,Len(aCols[nX])]
				RecLock("SFF",.T.)
				Replace FF_FILIAL  With xFilial("SFF"),;
				FF_ALIQ    With aCols[nX,nAliq],;         
				FF_CFO_C   With aCols[nX,cCFOc],;           
				FF_FXDE	   With aCols[nX,nFaDe],;           
				FF_PERC    With aCols[nX,nPerc],;
				FF_ZONFIS  With aCols[nX,nZonF],;          
				FF_IMPOSTO With cNum,;
				FF_FLAG    With "0"                        	        
				dbUnLock()
			EndIf
		Next nX
	EndIf

	dbSelectArea("SFF")
	dbSetOrder(5)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARFUALTERAºAutor  ³Denis Martins       º Data ³  10/23/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Responsavel pela Alteracao de Retencao na Fonte-Colombia  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ARFUALTERA(cAlias,nReg,nOpcx)

	Local nX	:= 0
	Local nY	:= 0
	Local nI	:= 0      
	Local nSFF 	:= SFF->(Recno())
	
	aColunas:= {"FF_CFO_C","FF_ALIQ","FF_FXDE","FF_PERC","FF_ZONFIS"}
	aHeader := {}
	aCols   := {}            
	aRecnos := {}
	nUsado  := 0    
	cDesc   := Space(30)
	nOpcx   := 6

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	cNum   := SFF->FF_IMPOSTO
	cCFOc  := SFF->FF_CFO_C         
	nAlit  := Alltrim(Str(SFF->FF_ALIQ))
	nFad   := Alltrim(Str(SFF->FF_FXDE))
	nPert  := Alltrim(Str(SFF->FF_PERC))
	
	//Montando aCols
	nCnt := 0
	
	//Array com descricao dos campos do Cabecalho do Modelo 2
	aC:={}
	aAdd(aC, {"cNum"	, {15,009}, OemToAnsi(STR0007)	, "@!", "ExecBlock('VerNomSFB'	, .F.	, .F., , .T.)",,.F.})
	aAdd(aC, {"cDesc"	, {15,070},						, "@!", 						, 		, .F.})

	VerNomSFB()
	
	//Variaveis do Rodape do Modelo 2
	nTotalItens := nCnt

	aR := {}
	
	//Array com coordenadas da GetDados no modelo2
	aCGD := {44,5,118,315}
	
	//Validacoes na GetDados da Modelo 2
	cLinhaOk:="ExecBlock('coverif',.F.,.F.,,.T.)"
	cTudoOk :="ExecBlock('covtalt',.F.,.F.,,.T.)"

	aGetEdit := {}
	
	//Montando aCols
	nCnt	:= 0         
	nAliq	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
	nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
	nZonF   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})

	dbSelectArea("SFF")
	dbSetOrder(5)   
	dbSeek(cFilSFF+cNum+cCFOc)
	Do While !EOF() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C == cFilial+cNum+cCFOc 
		nCnt:=nCnt+1
		aAdd(aCols,Array(nUsado+1))
		aAdd(aRecnos,SFF->(Recno()))
		aCOLS[nCnt,nAliq]   := SFF->FF_ALIQ
		aCOLS[nCnt,nCFOc]   := SFF->FF_CFO_C  
		aCOLS[nCnt,nFaDe]   := SFF->FF_FXDE 
		aCOLS[nCnt,nPerc]   := SFF->FF_PERC
		aCOLS[nCnt,nZonF]   := SFF->FF_ZONFIS    
		aCOLS[nCnt,nUsado+1]:= .F.
		cVerAltera			 := SFF->FF_FLAG	
		dbSkip()
	EndDo
	If nCnt == 0
		Help(" ",1,"NOITENS")

		dbSelectArea("SFF")
		dbSetOrder(5)

		Return
	EndIf

	nTotalItens := nCnt
	aVer := aClone(aCols) 
	//+--------------------------------------------------------------+
	//ª Chamada da Modelo2                                           ª
	//+--------------------------------------------------------------+
	If cVerAltera == "1"
		MsgStop("Nao e possivel Alterar")
		dbSelectArea("SFF")
		dbSetOrder(5)
		Return
	EndIf   
	lRetMod2:=Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
	If lRetMod2
		nCntItem:= 1
		For nX := 1 to Len(aCols)
			IF !aCols[nX,Len(aCols[nX])]
				
				//Se e um iten novo, incluir-lo , senao so atualizar
				If nX > nTotalItens
					RecLock("SFF",.T.)
				Else
					SFF->(DbGoTo(aRecnos[nX]))
					RecLock("SFF",.F.)
				EndIf
				Replace FF_FILIAL  With xFilial("SFF")
				
				//Atualiza dados do corpo da Tabela.
				For nY := 1 to Len(aHeader)
					If aHeader[nY][10] #"V"
						cVar := Trim(aHeader[nY][2])
						If cVar == "FF_ALIQ"
							Replace FF_ALIQ     	With aCols[nX,nY]
						ElseIf cVar == "FF_CFO_C"
							Replace FF_CFO_C   	    With aCols[nX,nY]
						ElseIf cVar == "FF_FXDE"
							Replace FF_FXDE      	With aCols[nX,nY]
						ElseIf cVar == "FF_PERC"
							Replace FF_PERC     	With aCols[nX,nY]
						ElseIf cVar == "FF_ZONFIS"
							Replace FF_ZONFIS     	With aCols[nX,nY]
						EndIf
					EndIf
				Next nY
				MsUnLock()
				nCntItem:=nCntItem + 1
			Else
				If nX <= nTotItens
					SFF->(DbGoTo(aRecnos[nX]))
					RecLock("SFF",.F.)
					SFF->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next nX
	EndIf   

	dbSelectArea("SFF")
	dbSetOrder(5)
	dbGoTo(nSFF)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARFUEXCLUIºAutor  ³Denis Martins       º Data ³  10/07/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³     Exclusao de IVA - Impostos de Valor Agregado           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ /Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ArFuExclui(cAlias,nReg,nOpcx)

	Local nI := 0
	
	aColunas:= {"FF_CFO_C","FF_ALIQ","FF_FXDE","FF_PERC","FF_FLAG"}
	aHeader := {}
	aCols   := {}
	aRecnos := {}
	nUsado  := 0
	cDesc   := Space(30)
	nOpcx   := 5

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 TO Len(aColunas)
		dbSeek(aColunas[nI])
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <=cNivel .And. ! Eof()
			nUsado++
			aAdd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf   
		dbSkip()
	Next

	cNum   := SFF->FF_IMPOSTO
	cCFOc  := SFF->FF_CFO_C         
	cZonFis:= Space(02)
	nAlit  := Alltrim(Str(SFF->FF_ALIQ))
	nFad   := Alltrim(Str(SFF->FF_FXDE))
	nPert  := Alltrim(Str(SFF->FF_PERC))
	
	//Montando aCols
	nCnt := 0
	aC:={}
	aAdd(aC,{"cNum"      ,{15,009} ,OemToAnsi(STR0007),"@!","ExecBlock('VerNomSFB',.F.,.F.,,.T.)",,.F.})
	aAdd(aC,{"cDesc"     ,{15,070} ,,"@!",,,.F.})

	VerNomSFB()
	
	//Variaveis do Rodape do Modelo 2
	nTotalItens := nCnt

	aR:={}
	
	//Array com coordenadas da GetDados no modelo2
	aCGD:={44,5,118,315}
	
	//Validacoes na GetDados da Modelo 2
	aGetEdit := {}
	nCnt := 0
	
	//Montando aCols
	nCnt    := 0         
	nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCFOc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nFaDe   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_FXDE"})
	nPerc   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_PERC"})
	dbSelectArea("SFF")
	dbSetOrder(5)   
	dbSeek(cFilSFF+cNum+cCFOc)
	While !EOF() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C == cFilSFF+cNum+cCFOc 
		nCnt := nCnt + 1
		aAdd(aCols, Array(nUsado+1))
		aAdd(aRecnos,Recno())
		aCOLS[nCnt,nAliq]   := SFF->FF_ALIQ
		aCOLS[nCnt,nCFOc]   := SFF->FF_CFO_C  
		aCOLS[nCnt,nFaDe]   := SFF->FF_FXDE 
		aCOLS[nCnt,nPerc]   := SFF->FF_PERC    
		aCOLS[nCnt,nUsado+1]:= .F.
		dbSkip()           
	EndDo       

	nTotalItens := nCnt
	aVer := aClone(aCols) 

	// Chamada da Modelo2
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	lRetMod2 := Modelo2(cCadastro,aC,aR,aCGD,nOpcx,".T.",".T.")

	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente
	If lRetMod2  
		dbSelectArea("SFF")
		dbSetOrder(5)   
		dbSeek(cFilSFF+cNum+cCFOc)
		Do While !EOF() .And. FF_FILIAL+FF_IMPOSTO+FF_CFO_C == cFilSFF+cNum+cCFOc 
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()           
			dbSkip()           
		EndDo   
	EndIf   

	dbSelectArea("SFF")
	dbSetOrder(5)

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦AIMPCTES  ¦ Autor ¦ Denis Martins         ¦ Data ¦ 06/10/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica o tipo do TES - Compras                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ CO_IMPC                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 08/10/99 ==> Function AIMPCTES()
Function AIMPCTES()

	If !Empty(M->FF_CFO_C)
		If SubStr(M->FF_CFO_C,1,3) <= "500"
			If !(SubStr(M->FF_CFO_C,1,1) $ "1/2/3")
				Help(" ",1,"F4_CFERR")
				Return .F.
			EndIf
		Else
			If (SubStr(M->FF_CFO_C,1,1) $ "5/6/7")
				Help(" ",1,"F4_CFERR")
				Return .F.
			EndIf
		EndIf
	EndIf
Return .T.

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦AIMPVTES  ¦ Autor ¦ Denis Martins         ¦ Data ¦ 06/10/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica o tipo do TES - Vendas                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ CO_IMPC                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 08/10/99 ==> Function AIMPVTES()
Function AIMPVTES()

	If !Empty(M->FF_CFO_V)
		If SubStr(M->FF_CFO_V,1,3) > "500"
			If !(SubStr(M->FF_CFO_V,1,1) $ "5/6/7")
				Help(" ",1,"F4_CFERR")
				Return .F.
			EndIf
		Else
			If (SubStr(M->FF_CFO_V,1,1) $ "1/2/3")
				Help(" ",1,"F4_CFERR")
				Return .F.
			EndIf
		EndIf
	EndIf
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerNomSFB ºAutor  ³Denis Martins       º Data ³  02/07/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³        Verifica nome de Imposto Arquivo SFB                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CO_IMPC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VerNomSFB()

	If mv_par01 == 1
		If SubStr(cNum,1,2) != "IC"
			Help(OemToAnsi(STR0010),1,OemToAnsi(STR0011)) //"Impuesto debe empiezar con IC"
			lRet := .F.
			Return(lRet)
		EndIf
	EndIf                                
	dbSelectArea("SFB")
	dbSetOrder(1)
	dbSeek(xFilial("SFB")+cNum)
	If Found()
		cDesc := SFB->FB_DESCR 
		lRet := .T.
	Else           
		Help(OemToAnsi(STR0012),1,"ARCHIVO.SFB") //"Verifique la integridad del archivo SFB"
		lRet := .F.    
	EndIf
	
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³COVERIF   ºAuthor ³Denis Martins       º Date ³  10/11/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe Imposto para Municipio                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ Generico Colombia                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function coverif()

	Local nAchou	:= 0
	Local lRet		:= .T.
	Local nAliq		:= 0		
	
	nAliq   := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})
	nCodIca := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_COD_TAB"})
	nCodFis := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C"})
	nZonFis := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ZONFIS"})
	
	If mv_par01 == 1 // Retencao de ICA
		cProcura	:= aCols[n,nCodIca] + aCols[n,nCodFis] + aCols[n, nZonFis]
		nAchou		:= aScan(aCols, {|x| cNum + x[nCodIca] + x[nCodFis] + x[nZonFis] == cNum + cProcura})
	ElseIf mv_par01 == 2 // Retencao na Fonte
		nPerc    := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_PERC"})
		nFade    := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_FXDE"})
		cProcura := Alltrim(Str(aCols[n,nAliq])) + aCols[n, nCodFis] + Alltrim(Str(aCols[n, nFade])) 
		nAchou   := aScan(aCols, {|x| cNum + Alltrim(Str(x[nAliq])) + x[nCodFis] + Alltrim(Str(x[nFade])) == cNum + cProcura})
	EndIf

	If nAchou > 0 .And. nAchou != n
		HELP(" ", 1, "JAGRAVADO")
		lRet := .F.
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³COVTUDO   ºAuthor ³Denis Martins       º Date ³  10/14/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se Imposto ja esta gravado no Arquivo              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ Impostos Colombia - CO_IMPC                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function covtudo()

	Local nX := 0
	
	lAchou	:= .F.
	lRet	:= .T.
	nX		:= 1
	nCodIca	:= aScan(aHeader, {|x| Alltrim(x[2]) == "FF_COD_TAB"})
	nCFOc   := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_CFO_C"	})
	cZonFis := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_ZONFIS"	})
	nAliq   := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_ALIQ"	})
	nPerc   := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_PERC"	})
	nFade   := aScan(aHeader, {|x| Alltrim(x[2]) == "FF_FXDE"	})

	If mv_par01 == 1 // Retencao de ICA
		For nX := 1 to Len(aCols)
			dbSelectArea("SFF")
			dbSetOrder(5)
			While !EOF()
				If FF_FILIAL + FF_IMPOSTO + FF_CFO_C + FF_ZONFIS + FF_COD_TAB == cFilSFF + cNum + aCols[nX,nCFOc] + aCols[nX,cZonFis] + aCols[nX,nCodIca]
					HELP(" ", 1, "JAGRAVADO")
					lRet := .F.
					Return lRet
				EndIf
				dbSkip()
			EndDo
		Next nX
	ElseIf mv_par01 == 2
		dbSelectArea("SFF")
		dbSetOrder(5)
		For nX := 1 to Len(aCols)
			While !EOF()                                                       
				cProcura := cFilSFF + cNum + aCols[nX, nCFOc] + Alltrim(Str(aCols[nX, nAliq])) + Alltrim(Str(aCols[n, nPerc])) + Alltrim(Str(aCols[n,nFaDe]))
				If FF_FILIAL + FF_IMPOSTO + FF_CFO_C + Alltrim(Str(FF_ALIQ)) + Alltrim(Str(FF_PERC)) + Alltrim(Str(FF_FXDE)) == cProcura
					HELP(" ", 1, "JAGRAVADO")
					lRet := .F.
					Return lRet
				EndIf
				dbSkip()
			EndDo
		Next nX
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³CovTalt() ºAuthor ³Denis Martins       º Date ³  10/26/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³No caso de Alteracao - ICA/IVA                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ CO_IMPC - Impostos Colombia                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CovTalt()

	nCodIca	:= aScan(aHeader, {|x| Alltrim(x[2]) == "FF_COD_TAB"})
	nCFOc	:= aScan(aHeader, {|x| Alltrim(x[2]) == "FF_CFO_C"})
	cZonFis	:= aScan(aHeader, {|x| Alltrim(x[2]) == "FF_ZONFIS"}) 
	nAliq	:= aScan(aHeader, {|x| Alltrim(x[2]) == "FF_ALIQ"})
	nFaDe	:= aScan(aHeader, {|x| Alltrim(x[2]) == "FF_FXDE"})
	lRet	:= .T.
	
	If mv_par01 == 1 // ICA
		If (aCols[n,nCodIca] != aVer[n,nCodIca]) .Or. (aCols[n,nCFOc] != aVer[n,nCFOc]) .Or. (aCols[n,cZonFis] != aVer[n,cZonFis])
			dbSelectArea("SFF")
			dbSetOrder(5)
			dbGoTop()
			nIca    := aCols[n,nCodIca]
			nCodFis := aCols[n,nCFOc]
			cZon    := aCols[n,cZonFis]
			Do While !EOF()
				If FF_FILIAL + FF_IMPOSTO + FF_CFO_C + FF_ZONFIS + FF_COD_TAB == cFilSFF + cNum + aCols[n,nCFOc] + aCols[n,cZonFis] + aCols[n,nCodIca]
					HELP(" ",1,"JAGRAVADO")
					lRet:=.F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	ElseIf mv_par01 == 2   	//Retencion en La Fuente
		If (aCols[n,nCFOc] != aVer[n,nCFOc]) .Or. (Alltrim(Str(aCols[n,nAliq])) != Alltrim(Str(aVer[n,nAliq]))).Or.;
		(aCols[n,nFade] != aVer[n,nFade]) 
			dbSelectArea("SFF")
			dbSetOrder(5)
			dbGoTop()
			nCodFis := aCols[n,nCFOc]
			nAlic   := Alltrim(Str(aCols[n,nAliq]))
			nFad    := Alltrim(Str(aCols[n,nFade]))
			Do While !EOF()
				If FF_FILIAL + FF_IMPOSTO + FF_CFO_C + Alltrim(Str(FF_ALIQ)) + Alltrim(Str(FF_FXDE)) == cFilSFF + cNum + nCodFis + nAlic + nFad
					HELP(" ",1,"JAGRAVADO")
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf        
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOTIMBRE ºAutor  ³Marcello            ºFecha ³ 07/05/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para manutencao da tabela de aliquotas para retecao  º±±
±±º          ³de timbre                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ co_impc                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACOTIMBRE()

	Local cAlias	:= ""
	Local cQuery	:= ""
	Local cAliasSFF	:= ""
	Local cArqTmp	:= ""
	Local cFilSFF	:= xFilial("SFF")
	Local aOrdem	:= {}

	Private aFixe		:= {}
	Private aCposTmp	:= {}
	Private oTmpTable	:= Nil

	aFixe:=	{{RetTitle("FF_ALIQ")	, "FF_ALIQ"		, "N", TamSX3("FF_ALIQ")[1]		, TamSX3("FF_ALIQ")[2]	, X3Picture("FF_ALIQ")},;
			{ RetTitle("FF_FXDE")	, "FF_FXDE"		, "N", TamSX3("FF_FXDE")[1]		, TamSX3("FF_FXDE")[2]	, X3Picture("FF_FXDE")},;
			{ RetTitle("FF_DATAVLD"), "FF_DATAVLD"	, "D", TamSX3("FF_DATAVLD")[1]	, 0						, X3Picture("FF_DATAVLD")}}

	aCposTmp :=	{{"FF_ALIQ"		, "N", TamSX3("FF_ALIQ")[1]		, TamSX3("FF_ALIQ")[2]},;
				{ "FF_FXDE"		, "N", TamSX3("FF_FXDE")[1]		, TamSX3("FF_FXDE")[2]},;
				{ "FF_DATAVLD"	, "D", TamSX3("FF_DATAVLD")[1]	, 0},;
				{ "NUMREC"		, "N", 10						, 0}}

	aRotina :=	{{STR0001	, "ACOTIMBREM", 0, 2, 0, Nil},;	// Visualizar
				{ STR0002	, "ACOTIMBREM", 0, 3, 0, Nil},;	// Incluir
				{ STR0003	, "ACOTIMBREM", 0, 4, 0, Nil},;	// Modificar
				{ STR0004	, "ACOTIMBREM", 0, 6, 0, Nil}}	// Borrar

	cCadastro := "Retencao" + "TIMBRE"
	
	cAlias := GetNextAlias()
	
	aOrdem := {"FF_DATAVLD"}
	
	oTmpTable := FWTemporaryTable():New(cAlias)
	oTmpTable:SetFields(aCposTmp)
	oTmpTable:AddIndex("IN1", aOrdem)
	
	oTmpTable:Create()
	
	cQuery := ""
	#IFDEF TOP
		cQuery := "SELECT FF_FILIAL, FF_IMPOSTO, FF_FXDE, FF_ALIQ, FF_DATAVLD, R_E_C_N_O_ FROM " + RetSqlName("SFF")
		cQuery += " WHERE FF_FILIAL = '" + cFilSFF + "'"
		cQuery += " AND FF_IMPOSTO = 'TIM'"
		cQuery += " AND D_E_L_E_T_ = ''"
		cAliasSFF := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSFF,.F.,.T.)
		TCSetField(cAliasSFF,"FF_DATAVLD","D",8,0)
		(cAliasSFF)->(DbGoTop())
	#ELSE
		cAliasSFF := "SFF"
		dbSelectArea("SFF")
		dbSetOrder(9)
		DbSeek(cFilSFF+"TIM")
	#ENDIF
	
	dbSelectArea(cAliasSFF)
	While ((cAliasSFF)->FF_FILIAL == cFilSFF) .And. ((cAliasSFF)->FF_IMPOSTO == "TIM")
		RecLock(cAlias,.T.)
		Replace (cAlias)->FF_FXDE		With (cAliasSFF)->FF_FXDE
		Replace (cAlias)->FF_ALIQ		With (cAliasSFF)->FF_ALIQ
		Replace (cAlias)->FF_DATAVLD	With (cAliasSFF)->FF_DATAVLD
		#IFDEF TOP
			Replace (cAlias)->NUMREC	With (cAliasSFF)->R_E_C_N_O_
		#ELSE
			Replace (cAlias)->NUMREC	With SFF->(Recno())
		#ENDIF
		(cAlias)->(DbCommit())
		(cAliasSFF)->(DbSkip())
	EndDo
	#IFDEF TOP
		DbSelectArea(cAliasSFF)
		DbCloseArea()
	#ENDIF
	DbSelectArea(cAlias)
	dbGoTop()
	mBrowse(6, 1, 22, 75, cAlias, aFixe)
	
	DbSelectArea(cAlias)
	DbCloseArea()
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
	
Return

/*         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOTIMBREMºAutor  ³Marcello            ºFecha ³ 07/05/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para manutencao da tabela de aliquotas para retecao  º±±
±±º          ³de timbre                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ co_impc                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACOTIMBREM(cAlias, nReg, nOpc)

	Local lAlt	:= .F.
	Local lOk	:= .F.
	Local nX	:= 0
	Local nY	:= 0
	Local nDat	:= 0
	Local cCpo	:= ""
	Local aCpos	:= {}
	Local aVals	:= {}
	Local oDlg	:= Nil
	Local oBrow	:= GetObjBrow()

	oBrow:lDisablePaint := .F.

	lIncl := (aRotina[nOpc,4] == 3)
	lAlt  := (aRotina[nOpc,4] == 4)
	
	For nX := 1 To Len(aFixe)
		If aFixe[nX,2] == "FF_DATAVLD"
			nDat := nX
		EndIf
		aAdd(aCpos,{aFixe[nX,1],aFixe[nX,2],PesqPict("SFF",aFixe[nX,2]),TamSX3(aFixe[nX,2])[1],TamSX3(aFixe[nX,2])[2],Nil,Nil,"C",Nil,Nil,Nil,Nil})
	Next
	
	If lIncl
		aAdd(aVals,{0,0,Date(),.F.})
	Else
		aAdd(aVals,{(cAlias)->FF_ALIQ,(cAlias)->FF_FXDE,(cAlias)->FF_DATAVLD,.F.})
	EndIf
	
	DEFINE MSDIALOG oDlg FROM 6,1 TO 200,500 TITLE cCadastro Of oMainWnd PIXEL
	oBrwCpo := MsNewGetDados():New(0,0,100,100,If((lIncl .Or. lAlt),GD_UPDATE,),"AllwaysTrue()","AllwaysTrue()","",,,,,,,oDlg,aCpos,aVals)
	oBrwCpo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| aVals := Aclone(oBrwCpo:aCols),lOk:=ACOTIMBREV(cAlias,lIncl,If(nDat > 0,aVals[1,nDat],Ctod("//"))),If(lOk,oDlg:End(),)},{||lOk:=.F.,oDlg:End()}) CENTERED
	
	If aRotina[nOpc][4] > 2
		If lOk
			DbSelectArea("SFF")
			If lIncl .Or. lAlt
				If lAlt
					SFF->(DbGoto( (cAlias)->NUMREC) )
					RecLock("SFF",.F.)
				Else
					RecLock(cAlias,.T.)
					RecLock("SFF",.T.)
					Replace FF_FILIAL	With xFilial("SFF")
					Replace FF_IMPOSTO	With "TIM"
				EndIf
				For nY := 1 To Len(aFixe)
					cCpo := aFixe[nY,2]
					Replace SFF->(&cCpo) With aVals[1,nY]
					//
					Replace (cAlias)->(&cCpo) With aVals[1,nY]
				Next
				Replace (cAlias)->NUMREC With SFF->(RECNO())
				SFF->(MsUnLock())
				(cAlias)->(MsUnLock())
				DbCommitAll()
			Else
				SFF->(DbGoto((cAlias)->NUMREC))
				RecLock("SFF",.F.)
				DbDelete()
				MsUnLock()
				DbSelectArea(cAlias)
				RecLock(cAlias,.F.)
				DbDelete()
				MsUnLock()
				DbCommitAll()
			EndIf
			oBrow:Refresh()
		EndIf
	EndIf
	DbSelectArea(cAlias)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOTIMBREVºAutor  ³Marcello            ºFecha ³ 07/05/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para verificação das informacoes a serem gravadas na º±±
±±º          ³tabela de aliquotas retencao de TIMBRE.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ co_impc                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACOTIMBREV(cAlias, lIncl, dValid)

	Local lRet := .T.

	If Empty(dValid)
		MsgAlert(STR0013)
		lRet := .F.
	Else
		If lIncl
			If (cAlias)->(DbSeek(Dtos(dValid)))
				lRet := .F.
				MsgAlert(STR0014)
			EndIf
		EndIf
	EndIf
	
Return(lRet)
