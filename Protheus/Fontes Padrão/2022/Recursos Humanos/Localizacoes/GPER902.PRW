#INCLUDE "Protheus.CH"
#INCLUDE "GPER902.CH"
#DEFINE   nColMax	2350
#DEFINE   nLinMax	1900

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpinss   บAutor  ณTiago Malta           บ Data ณ  10/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio Mensal INSS .                                       บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                          บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ|A.Shibao	 |24/10/2013|THOVM6     |Alterado para Sx1 para Gestao de     |ฑฑ
ฑฑ|            |          |           |Empresas,compatibilizado para v11    |ฑฑ
ฑฑณ            ณ          ณ           ณ                                     ณฑฑ
ฑฑณJonathan Glzณ07/05/2015ณ PCREQ-4256ณSe elimina funcion AjustaSx1 la cual ณฑฑ
ฑฑณ            ณ          ณ           ณmodifica el diccionario de datos(SX1)ณฑฑ
ฑฑณ            ณ          ณ           ณpor motivo de ajuste nueva estructuraณฑฑ
ฑฑณ            ณ          ณ           ณde SXs para V12                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER902()

Local cDesc    	:= STR0001
Local Titulo   	:= STR0001
Local WnRel     := "GPER902"
Local aOrd	    := {}

Private cAlias   := "SRA"
Private cPerg    := "GPER902"
Private aReturn	 := { STR0002, 1 , STR0003 , 2, 2, 1,'',1 }

	Pergunte(cPerg,.F.)

	WnRel 	:= SetPrint( cAlias,WnRel,cPerg,@Titulo,cDesc,,,.F.,aOrd,,,,.F. )

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cAlias)

	If nLastKey == 27
		Return
	EndIf

	Processa({|lEnd| GPER902P() })

 	MS_FLUSH()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPINSS   บAutor  ณMicrosiga           บ Data ณ  02/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GPER902P()

Local cFilDe   := ""		//	Filial De
Local cFilAt   := ""		//	Filial At้
Local cMatDe   := ""		//	Matricula De
Local cMatAt   := ""		//	Matricula At้
Local cCCDe    := ""		//	Centro de Custo De
Local cCCAt    := ""		//	Centro de Custo At้
Local cSit     := ""		//	Situacoes a Imp.
Local cCat     := ""		//	Categorias a Imp.
Local cPer     := ""		//	Situacoes a Imp.
Local cNpg     := ""		//	Categorias a Imp.
Local cProc    := ""		//	Categorias a Imp.
Local cRot     := ""		//	Categorias a Imp.
Local cSitQuery:= ""
Local cCatQuery:= ""
Local nReg     := 0
Local cQuerySra:=""
Local nAlt     := 0
Local cPathPict := GetSrvProfString("Startpath","")
Local nFolha    := 1
Local nDMes     := 0
Local aAfast    := {}
Local nDiasFal  := 0
Local dDtaini   := ctod("//")
Local dDtafim   := ctod("//")
Local cAnoMes   := ""
Local nCount    := 0
Local P_DIASMES := Alltrim( Posicione( "RCA",1,xFilial("RCA")+"P_DIASMES","RCA_CONTEU" ) )
Local lImp1V    := .T.
Local nValFol   := 0
Local nValSFN   := 0
Local nValSS    := 0
Local nTotFol   := 0
Local nTotSFN   := 0
Local nTotSS    := 0
Local nTotSal   := 0
Local cAliasSra := ""
Local cAlias    := ""
Local nTotPag   := 0
Local nTotPag1   := 0
Local nTotPag2   := 0
Local nTotPag3   := 0
Local nBaseInss  := 0


Private oFont09, oFont09n,oFont10,oFont10n,oFont14n

	IF Substr(cPathPict,Len(cPathPict),1) <> "\"
		cPathPict += "\"
	Endif

	cPathPict += "GPER902.bmp"

	cFilDe := MV_PAR01		//	Filial De
	cFilAt := MV_PAR02		//	Filial At้
	cMatDe := MV_PAR03		//	Matricula De
	cMatAt := MV_PAR04		//	Matricula At้
	cCCDe  := MV_PAR05		//	Centro de Custo De
	cCCAt  := MV_PAR06		//	Centro de Custo At้
	cSit   := MV_PAR07		//	Situacoes a Imp.
	cCat   := MV_PAR08		//	Categorias a Imp.
	cPer   := MV_PAR09		//	Situacoes a Imp.
	cNpg   := MV_PAR10		//	Categorias a Imp.
	cProc  := MV_PAR11		//	Categorias a Imp.

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
	cQuerySra	+= "AND   RA_PROCES  = '"	+ cProc  	+"' "

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

   	oPrint 	:= TMSPrinter():New( STR0001 )
//	oPrint:SetPortrait()
	oPrint:SetLandscape()

	oFont07 := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont09 := TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont09n:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)
	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont14n:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)

	oPrint:StartPage()
	oPrint:SayBitmap(100 ,100 ,cPathPict,3200,2300)

	ProcRegua((cAliasSra)->(RecCount()))

	dbSelectArea(cAliasSra)
	(cAliasSra)->( dbgotop() )

	While (cAliasSra)->( !eof() )

 		IncProc((cAliasSra)->RA_FILIAL+" - "+(cAliasSra)->RA_MAT+" - "+(cAliasSra)->RA_NOME)

 		nValFol := 0
 		nValSFN := 0
 		nValSS  := 0
 		nDiasFal:= 0
 		nBaseInss:=0

		cAlias := fBuscaDesc( (cAliasSra)->RA_FILIAL , (cAliasSra)->RA_MAT , cPer , cNPG , "FOL" )

		IF SELECT(cAlias) > 0
			(cAlias)->( dbgotop() )

			While (cAlias)->( !eof() )
				IF (cAlias)->RD_PD == FGETCODFOL("0064")//FOLHA
			    	nValFol  += (cAlias)->RD_VALOR
				ELSEIF (cAlias)->RD_PD == FGETCODFOL("0070")//13o
			    	nValSFN  += (cAlias)->RD_VALOR
				ELSEIF (cAlias)->RD_PD == FGETCODFOL("0065")//FERIAS
			    	nValSFN  += (cAlias)->RD_VALOR
				ELSEIF (cAlias)->RD_PD == FGETCODFOL("0783")// Seg Social Emp.
			    	nValSS   += (cAlias)->RD_VALOR
			 	ENDIF

			 	IF  (cAlias)->RD_PD == FGETCODFOL("0013")// Base
				 	nBaseInss += (cAlias)->RD_VALOR
				ENDIF

				cAnoMes := (cAlias)->RD_DATARQ
				(cAlias)->( dbskip() )
			Enddo
		Endif

 	   	IF nValFol > 0 .OR. nValSFN > 0

            IF (cAliasSra)->RA_SITFOLH == "D"
               	dDtaini := Max( SToD((cAliasSra)->RA_ADMISSA) , CTOD( "01/"+Substr(cAnoMes,5,2) + "/" + Substr(cAnoMes,1,4) ) )
            	dDtafim := Dtoc(SToD( (cAliasSra)->RA_DEMISSA ))
            ELSE
               	dDtaini := Max( SToD((cAliasSra)->RA_ADMISSA ), CTOD( "01/"+Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) ) )
            	dDtafim := CTOD( Alltrim(STR(f_UltDia(dDtaini))) + '/' +Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) )
            Endif

           	nDMes     := IIF(P_DIASMES=='S',f_UltDia(dDtaini),30)

           	// Apura faltas nas ausencias (SR8)
			fBuscaAfast(dDtaini,dDtafim,@aAfast)
			Aeval( aAfast, { |x| iif( x[05]=="1"      , nDiasFal += x[11] , 0 ) } )

			nDMes -= nDiasFal

		    IF lImp1V
	        	oPrint:say (580 , 2730 , Str(nFolha) ,oFont10)
	        	oPrint:say (560 , 1950 , MesExtenso(Substr(cAnoMes,5,2)) ,oFont10)
	        	oPrint:say (560 , 2350 , Substr(cAnoMes,1,4) ,oFont10)
	        	lImp1V := .F.
	     	ENDIF

			oPrint:say (953+nAlt ,175  , Substr( (cAliasSra)->RA_NISSPS ,1,15) ,oFont07)
	 		oPrint:say (953+nAlt ,420  , Substr( (cAliasSra)->RA_NOME ,1,26) ,oFont10)
	 		oPrint:say (950+nAlt ,1020 , Substr(fDesc("SRJ",(cAliasSra)->RA_CODFUNC,"RJ_DESC"),1,30),oFont09)
	 		oPrint:say (953+nAlt ,1490 , Transform( nBaseInss , "@E 999,999.99") ,oFont09)
			oPrint:say (953+nAlt ,1740 , Transform( nValSFN , "@E 999,999.99") ,oFont09)
	 		oPrint:say (953+nAlt ,1990 , Transform( nBaseInss , "@E 999,999.99") ,oFont09)
	 		oPrint:say (953+nAlt ,2280 , Transform( nValFol , "@E 999,999.99") ,oFont09)
			oPrint:say (953+nAlt ,2570 , Transform( nValSS  , "@E 999,999.99") ,oFont09)
	 		nTotSFN += nValSFN
	 		nTotFol += nValFol
	 		nTotSS  += nValSS
	 		nTotSal += nBaseInss

		 	nAlt += 60

		 	nCount ++
	 	Endif

 		(cAliasSra)->( dbskip() )

 	 	IF (1000+nAlt) >= nLinMax


			IF nFolha > 1

				oPrint:say (880 ,1485 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
				oPrint:say (880 ,1745 , Transform( nTotPag1 , "@E 99,999,999.99") ,oFont09n)
				oPrint:say (880 ,2005 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
		 		oPrint:say (880 ,2300 , Transform( nTotPag2 , "@E 99,999,999.99") ,oFont09n)
				oPrint:say (880 ,2600 , Transform( nTotPag3  , "@E 99,999,999.99") ,oFont09n)
			Endif

		    oPrint:say (110 ,1600 , SM0->M0_INSCANT ,oFont10)
 	 	    oPrint:say (110 ,2550 , SM0->M0_CNAE ,oFont10)
 	 	    oPrint:say (180 ,1550 , SM0->M0_NOMECOM ,oFont10)
 	 	    oPrint:say (240 ,1600 , SM0->M0_ENDCOB ,oFont10)
 	 	    oPrint:say (290 ,1600 , SM0->M0_CIDCOB ,oFont10)
 	 	    oPrint:say (340 ,2000 , SM0->M0_CGC ,oFont10)
   	 	    oPrint:say (290 ,2150 , SM0->M0_CEPCOB  ,oFont10)
   	 	    oPrint:say (290 ,2540 , SM0->M0_TEL  ,oFont10)

		   	oPrint:say (1960 ,1435 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
			oPrint:say (1960 ,1680 , Transform( nTotPag1 , "@E 99,999,999.99") ,oFont09n)
		 	oPrint:say (1960 ,1935 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
	 	  	oPrint:say (1960 ,2220 , Transform( nTotPag2 , "@E 99,999,999.99") ,oFont09n)
			oPrint:say (1960 ,2510 , Transform( nTotPag3  , "@E 99,999,999.99") ,oFont09n)

			nTotPag  += nTotSal
 			nTotPag1 += nTotSFN
	 		nTotPag2 += nTotFol
 	 		nTotPag3 += nTotSS

 	 		nTotSFN := 0
	 		nTotFol := 0
	 		nTotSS  := 0
	 		nTotSal := 0

	 		nFolha ++

			oPrint:EndPage()

			oPrint:StartPage()

			oPrint:SayBitmap(100 ,100 ,cPathPict,3200,2300)

			lImp1V := .T.
			nAlt   := 0
		ELSEIF (cAliasSra)->( eof() )

		IF nFolha > 1
				oPrint:say (880 ,1485 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
				oPrint:say (880 ,1745 , Transform( nTotPag1 , "@E 99,999,999.99") ,oFont09n)
				oPrint:say (880 ,2005 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
		 		oPrint:say (880 ,2300 , Transform( nTotPag2 , "@E 99,999,999.99") ,oFont09n)
				oPrint:say (880 ,2600 , Transform( nTotPag3  , "@E 99,999,999.99") ,oFont09n)
		Endif

		    oPrint:say (110 ,1600 , SM0->M0_INSCANT ,oFont10)
 	 	    oPrint:say (110 ,2550 , SM0->M0_CNAE ,oFont10)
 	 	    oPrint:say (180 ,1550 , SM0->M0_NOMECOM ,oFont10)
 	 	    oPrint:say (240 ,1600 , SM0->M0_ENDCOB ,oFont10)
 	 	    oPrint:say (290 ,1600 , SM0->M0_CIDCOB ,oFont10)
 	 	    oPrint:say (340 ,2000 , SM0->M0_CGC ,oFont10)
   	 	    oPrint:say (290 ,2150 , SM0->M0_CEPCOB  ,oFont10)
   	 	    oPrint:say (290 ,2540 , SM0->M0_TEL  ,oFont10)


 	 	    nTotPag  += nTotSal
 			nTotPag1 += nTotSFN
	 		nTotPag2 += nTotFol
 	 		nTotPag3 += nTotSS

		   	oPrint:say (1960 ,1435 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
			oPrint:say (1960 ,1680 , Transform( nTotPag1 , "@E 99,999,999.99") ,oFont09n)
		 	oPrint:say (1960 ,1935 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
	 	  	oPrint:say (1960 ,2220 , Transform( nTotPag2 , "@E 99,999,999.99") ,oFont09n)
			oPrint:say (1960 ,2510 , Transform( nTotPag3  , "@E 99,999,999.99") ,oFont09n)

			oPrint:say (2120 ,900 , Transform( nTotPag , "@E 99,999,999.99") ,oFont09n)
			oPrint:say (2180 ,900 , Transform( nTotPag3  , "@E 99,999,999.99") ,oFont09n)
	  		oPrint:say (2250 ,900 , Transform( nTotPag2 , "@E 99,999,999.99") ,oFont09n)
	  		oPrint:say (2330 ,900 , Transform( Round(nTotPag2+nTotPag3,0), "@E 99,999,999.99") ,oFont09n)


			nTotSFN := 0
	 		nTotFol := 0
	 		nTotSS  := 0
	 		nTotSal := 0
		Endif

	Enddo

	IF nCount == 0
		Alert(STR0004)
		Return()
	Endif

	oPrint:EndPage()

	oPrint:Preview()

	IF SELECT(cAlias) > 0
		(cAlias)->( dbclosearea() )
	Endif

	IF SELECT(cAliasSra) > 0
  		(cAliasSra)->( dbCloseArea() )
 	Endif
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
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fBuscaDesc( cFil , cMat ,  cPer , cNPG , cRot )

Local cQuery	:= ""
Local cAliasSRD := ""

	cAliasSRD 	:= "QrySRD"
	cQuery 		:= "SELECT RD_DATARQ, RD_MAT,RD_PD, RD_VALOR, RD_HORAS"
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
