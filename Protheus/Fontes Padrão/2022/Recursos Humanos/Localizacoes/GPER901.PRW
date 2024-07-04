#INCLUDE "Protheus.CH"
#INCLUDE "GPER901.CH"
#DEFINE   nColMax	2350
#DEFINE   nLinMax	2450

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออออออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER901   บAutor            ณTiago Malta         บ Data ณ  09/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออออออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMapa de Liquida็ใo IRT.                                               บฑฑ
ฑฑบ          ณ                                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data     ณ BOPS           ณ  Motivo da Alteracao                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณTiago Malta ณ 05/03/10 ณ----------------ณ Cria็ใo do parametro de periodo.       ณฑฑ
ฑฑณClaudinei S.ณ 14/12/11 ณ00000032280/2011ณ Inclusใo do perํodo de apura็ใo no     ณฑฑ
ฑฑณ            ณ          ณ          TEELU5ณ cabe็alho do relat๓rio.                ณฑฑ
ฑฑณMohanad Odehณ 27/02/12 ณ00000003643/2012ณ Ajuste na defini็ใo do tamanho dos     ณฑฑ
ฑฑณ            ณ          ณ          TENHDDณ campos de pergunta (SX1) Filial De e   ณฑฑ
ฑฑณ            ณ          ณ                ณ Filial At้ na fun็ใo AjustaSX1         ณฑฑ
ฑฑณFabio G.	 ณ 04/06/12 ณ00000017300/2012ณ Inclusao da opcao Nacinalidade no Rela-ณฑฑ
ฑฑณ            ณ          ณ          TFID88ณ torio.                                 ณฑฑ
ฑฑณM. Silveira ณ 23/08/13 ณ          THSF49ณ Ajuste no cabecalho para atender a LGT.ณฑฑ
ฑฑณ            ณ          ณ                ณ                                        ณฑฑ
ฑฑณJonathan Glzณ 07/05/15 ณ      PCREQ-4256ณ Se elimina funcion AjustaSx1 la cual   ณฑฑ
ฑฑณ            ณ          ณ                ณ modifica el diccionario de datos(SX1)  ณฑฑ
ฑฑณ            ณ          ณ                ณ por motivo de ajuste nueva estructura  ณฑฑ
ฑฑณ            ณ          ณ                ณ de SXs para V12                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER901()

Local Titulo   	:= STR0001
Local cDesc    	:= STR0001
Local WnRel     := "GPER901"
Local aOrd	    := {}

Private cAlias   := "SRA"
Private cPerg    := "GPER901"
Private aReturn	 := { STR0002, 1,STR0003, 2, 2, 1,'',1 }
Private cAliasSra:=""
Private cQuerySra:=""
Private aInfo    := {}

	Pergunte(cPerg,.F.)

	WnRel 	:= SetPrint( cAlias,WnRel,cPerg,@Titulo,cDesc,,,.F.,aOrd,,,,.F. )

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cAlias)

	If nLastKey == 27
		Return
	EndIf

	Processa({|lEnd| GPER901P() })

	IF SELECT(cAliasSra) > 0
		(cAliasSra)->( dbCloseArea() )
	Endif

	MS_FLUSH()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER901P  บAutor  ณTiago Malta         บ Data ณ  02/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o Relatorio                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GPER901P()

Local cFilDe    := ""		//	Filial De
Local cFilAt    := ""		//	Filial At้
Local cFilAtu	:= "!!"		//	Filial que esta sendo impressa
Local cMatDe    := ""		//	Matricula De
Local cMatAt    := ""		//	Matricula At้
Local cCCDe     := ""		//	Centro de Custo De
Local cCCAt     := ""		//	Centro de Custo At้
Local cSit      := ""		//	Situacoes a Imp.
Local cCat      := ""		//	Categorias a Imp.
Local cPer      := ""       //  Periodo
Local cNPG      := ""       //  Numero de Pag.
Local cDtEmissa := ""		//  Data da emissao
Local cSitQuery := ""
Local cCatQuery := ""
Local nReg      := 0
Local nAlt      := 0
Local nValorIRT := 0
Local cPathPict := GetSrvProfString("Startpath","")
Local nSaltot   := 0
Local nValtot   := 0
Local nBaseIrt  := 0
Local cAlias    := 0
Local cPAno     := ""
Local cPMes		:= ""
Local nNac		:= 0
Local nNumPg	:= 1

Private oFont10,oFont10n,oFont12,oFont12n,oFont14n


	IF Substr(cPathPict,Len(cPathPict),1) <> "\"
		cPathPict += "\"
	Endif

	cPathPict += "LogoIrt.bmp"

	cFilDe := MV_PAR01			//	Filial De
	cFilAt := MV_PAR02			//	Filial At้
	cMatDe := MV_PAR03			//	Matricula De
	cMatAt := MV_PAR04			//	Matricula At้
	cCCDe  := MV_PAR05			//	Centro de Custo De
	cCCAt  := MV_PAR06			//	Centro de Custo At้
	cSit   := MV_PAR07			//	Situacoes a Imp.
	cCat   := MV_PAR08			//	Categorias a Imp.
	cPer   := MV_PAR09			//	Periodo
	cNPG   := MV_PAR10			//	Numero de Pag.
	cNac   := MV_PAR11	   		//	Nacionalidade
	cPAno  := SUBSTR(cPer,1,4)  //	Ano de apura็ใo
	cPMes  := SUBSTR(cPer,5,2)  //  Mes de apura็ใo
	cDtEm  := MV_PAR12  		//  Data de emissao
	cTMoeda:= MV_PAR13  		//  Moeda

	cTMoeda   := If( !Empty(MV_PAR13) .And. MV_PAR13=2, "US$", "KZ")
	cDtEmissa := Transform( dToC(cDtEm), "@R 99/99" ) + "/" + cValToChar(Year(cDtEm ))

	For nReg:=1 to Len(cSit)
		cSitQuery += "'"+Subs(cSit,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSit)
			cSitQuery += ","
		Endif
	Next nReg

	For nReg:=1 to Len(cCat)
		cCatQuery += "'"+Subs(cCat,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCat)
			cCatQuery += ","
		Endif
	Next nReg

	cAliasSra 	:= "QrySRA"
	cQuerySra	:= "SELECT * FROM "	+ RetSqlName( "SRA" ) + " SRA1 "
	cQuerySra	+= " Where RA_FILIAL>= '"	+ cFilDe	+"' "
	cQuerySra	+= "AND   RA_FILIAL	<= '"	+ cFilAt	+"' "
	cQuerySra	+= "AND   RA_MAT	>= '"	+ cMatDe	+"' "
	cQuerySra	+= "AND   RA_MAT	<= '"	+ cMatAt	+"' "
	cQuerySra	+= "AND   RA_CC		>= '"	+ cCCDe 	+"' "
	cQuerySra	+= "AND   RA_CC		<= '"	+ cCCAt 	+"' "
	cQuerySra	+= "AND   RA_SITFOLH IN ("	+ cSitQuery	+") "
	cQuerySra	+= "AND   RA_CATFUNC IN ("	+ cCatQuery	+") "

	If nNac == 1
		cQuerySra += "AND   RA_NACIONA = 204 "
	ElseIf nNac == 2
		cQuerySra += "AND   RA_NACIONA <> 204 "
	EndIf

	If TcSrvType() == "AS/400"
		cQuerySra += "AND SRA1.@DELETED@ = ' ' "
	Else
		cQuerySra += "AND SRA1.D_E_L_E_T_ = ' ' "
	Endif

	IF Select(cAliasSra) > 0
		(cAliasSra)->( dbCloseArea() )
	Endif

	cQuery 		:= ChangeQuery(cQuerySra)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySra),cAliasSra)

	ProcRegua((cAliasSra)->(RecCount()))

	dbSelectArea(cAliasSra)
	(cAliasSra)->( dbgotop() )

	fInfo(@aInfo, (cAliasSra)->RA_FILIAL)
	cFilAtu := (cAliasSra)->RA_FILIAL

   	oPrint 	:= TMSPrinter():New(STR0001)
	oPrint:SetPortrait()

	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	oFont12 := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont13n:= TFont():New("Courier New",13,13,,.T.,,,,.T.,.F.)
	oFont14n:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)

	oPrint:StartPage()

	oPrint:SayBitmap(25 ,50 , cPathPict , 140 , 140 )
	oPrint:say (070, 0050, aInfo[3] ,oFont13n)
	oPrint:say (160, 0050, STR0001 + " - " + MesExtenso(cPMes) + "/" + cPAno, oFont14n)
	oPrint:say (250, 0050, "Data de emissใo: " + cDtEmissa, oFont10)
	oPrint:say (250, 1300, "Valores em " + cTMoeda, oFont10)
	oPrint:say (250, 2100, "Pแgina: " + cValToChar(nNumPg), oFont10)

	oPrint:line(290, 0035, 290 ,nColMax) 				 	//Linha Horizontal

	oPrint:say (350, 0050, STR0004,				oFont10n)	//Funcionario (Matricula)
	oPrint:say (350, 0300, STR0005,				oFont10n)	//Nome
	oPrint:say (350, 1300, "Valor Colectแvel",	oFont10n)	//Valor Colectavel (Salario)
	oPrint:say (350, 1700, STR0007,				oFont10n)	//Liquidado
	oPrint:say (350, 2100, "Taxa M้dia",		oFont10n)	//Taxa Media

	While (cAliasSra)->( !eof() )

		If cFilAtu # (cAliasSra)->RA_FILIAL
			fInfo(@aInfo, (cAliasSra)->RA_FILIAL)
			cFilAtu := (cAliasSra)->RA_FILIAL
		EndIf

 		IncProc((cAliasSra)->RA_FILIAL+" - "+(cAliasSra)->RA_MAT+" - "+(cAliasSra)->RA_NOME)

 		nValorIRT := 0
 		nBaseIrt  := 0

		cAlias := fBuscaDesc( (cAliasSra)->RA_FILIAL , (cAliasSra)->RA_MAT ,  cPer , cNPG , "FOL" )

 		While (cAlias)->(!eof())

 		    IF (cAlias)->RD_PD == FGETCODFOL("0066")
	 		    nValorIRT += (cAlias)->RD_VALOR
	 		ELSEIF (cAlias)->RD_PD == FGETCODFOL("0067")
	 			nValorIRT += (cAlias)->RD_VALOR
	 		ELSEIF (cAlias)->RD_PD == FGETCODFOL("0071")
	 			nValorIRT += (cAlias)->RD_VALOR
	 		ELSEIF (cAlias)->RD_PD == FGETCODFOL("0015")
	 			nBaseIrt :=  (cAlias)->RD_VALOR
	 		ENDIF

	 		(cAlias)->(dbskip())
	 	Enddo

 		IF ( nValorIRT > 0 .or. nBaseIrt > 0 )

	 		oPrint:say (400+nAlt ,050  , (cAliasSra)->RA_MAT                                           ,oFont12)
	 		oPrint:say (400+nAlt ,300  , (cAliasSra)->RA_NOME                                          ,oFont12)
	 		oPrint:say (400+nAlt ,1300 , Transform(   nBaseIrt                     , "@E 999,999.99")  ,oFont12)
			oPrint:say (400+nAlt ,1700 , Transform(   nValorIRT                    , "@E 999,999.99")  ,oFont12)
			oPrint:say (400+nAlt ,2050 , Transform( ( nValorIRT / nBaseIrt ) * 100 , "@E 999,999.99")  ,oFont12)

		 	nSaltot += nBaseIrt
		 	nValtot += nValorIRT

		 	nAlt    += 50
 		Endif

 		(cAliasSra)->( dbskip() )

 	 	IF (400+nAlt) >= nLinMax

			oPrint:EndPage()
			nAlt 	:= 0
			nNumPg	+= 1

			oPrint:SayBitmap(25 ,50 , cPathPict , 140 , 140 )
			oPrint:say (070, 0050, aInfo[3] ,oFont13n)
			oPrint:say (160, 0050, STR0001 + " - " + MesExtenso(cPMes) + "/" + cPAno, oFont14n)
			oPrint:say (250, 0050, "Data de emissใo: " + cDtEmissa, oFont10)
			oPrint:say (250, 1300, "Valores em " + cTMoeda, oFont10)
			oPrint:say (250, 2100, "Pแgina: " + cValToChar(nNumPg), oFont10)

			oPrint:line(290, 0035, 290 ,nColMax) 				 	//Linha Horizontal

			oPrint:say (350, 0050, STR0004,				oFont10n)	//Funcionario (Matricula)
			oPrint:say (350, 0300, STR0005,				oFont10n)	//Nome
			oPrint:say (350, 1300, "Valor Colectแvel",	oFont10n)	//Valor Colectavel (Salario)
			oPrint:say (350, 1700, STR0007,				oFont10n)	//Liquidado
			oPrint:say (350, 2100, "Taxa M้dia",		oFont10n)	//Taxa Media

		Elseif (cAliasSra)->(eof())
 	 	   	oPrint:line( 450+nAlt ,035   , 450+nAlt , nColMax) 					 	 	//Linha Horizontal
		 	oPrint:say ( 500+nAlt ,050   , STR0009  , oFont12n)
		 	oPrint:say ( 500+nAlt ,1240  , Transform( nSaltot , "@E 999,999,999.99") ,oFont12)
		 	oPrint:say ( 500+nAlt ,1640  , Transform( nValtot , "@E 999,999,999.99") ,oFont12)
			oPrint:EndPage()
		Endif

	Enddo

	oPrint:EndPage()

	oPrint:Preview()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfBuscaDesc บAutor ณTiago Malta         บ Data ณ  03/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que busca valores do acumulado                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fBuscaDesc( cFil , cMat ,  cPer , cNPG , cRot )

Local cQuery	:= ""
Local cAliasSRD := ""

	cAliasSRD 	:= "QrySRD"
	cQuery 		:= "SELECT RD_DATARQ, RD_MAT,RD_PD, RD_VALOR, RD_HORAS "
	cQuery 		+= "FROM "	+ RetSqlName( "SRD" )	+ " SRD1 "
	cQuery 		+= "Where RD_FILIAL	= '"	+ cFil	+"' "
	cQuery 		+= "AND   RD_MAT	= '"	+ cMat	+"' "
	cQuery 		+= "AND   RD_PERIODO= '"	+ cPer	+"' "
	cQuery 		+= "AND   RD_SEMANA	= '"	+ cNPG	+"' "
	cQuery 		+= "AND   RD_ROTEIR	= '"	+ cRot	+"' "

	If TcSrvType() == "AS/400"
		cQuery += "AND SRD1.@DELETED@ = ' ' "
	Else
		cQuery += "AND SRD1.D_E_L_E_T_ = ' ' "
	Endif
	IF Select(cAliasSRD) > 0
		(cAliasSRD)->( dbCloseArea() )
	Endif
	cQuery 		:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD)

	dbSelectArea(cAliasSRD)
	(cAliasSRD)->(dbgotop())

Return(cAliasSRD)
