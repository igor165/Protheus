#include "protheus.ch"
#include "Birtdataset.ch"
#include "CTBR818.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR818ds³ Autor ³Jonathan Gonzalez      ³ Data ³ 30/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicion de columnas y query de recuperacion de datos del³±±
±±³          ³  dataset C818ds.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³jonathan glz³08/09/15³TTHAMD³Se cambia la forma de imprimir el archivo ³±±
±±³            ³        ³      ³Termino Auxiliares para que no permita    ³±±
±±³            ³        ³      ³imprimir archivo mayoresa 2 mil caracteres³±±
±±³jonathan glz³23/10/15³TTKUXV³Se cambia la manera de usar la instruccion³±±
±±³            ³        ³      ³dbselectarea() para archivos temporales y ³±±
±±³            ³        ³      ³se pase la variable cArqTmp entre comillas³±±
±±³            ³        ³      ³al momento de hacer el dbselectarea().    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset C818ds
	title STR0003 //Origenes e inversiones de recursos
	description STR0003 //Origenes e inversiones de recursos
	PERGUNTE "CTR520"

columns
	define column EMPRE type character size 60   label STR0011 //Nom. Emp
	define column REGPA type character size 60   label STR0012 //Reg. Pat
	define column TITUL type character size 100  label STR0013 //Titulo
	define column IMAGE type character size 20   label STR0014 //Imagen
	define column FCEMI type character size 12   label STR0015 //Fcha Emi
	define column FCREF type character size 12   label STR0016 //Fcha Ref
	define column TCONT type character size 30   label STR0017 //Titl Con
	define column TACTU type character size 30   label STR0018 //Titl Act
	define column TANTE type character size 30   label STR0019 //Titl Ant
	define column DSCON type character size 60   label STR0020 //Desc Con
	define column VALAC type character size 30   label STR0021 //Val. Act
	define column VALAN type character size 30   label STR0022 //Val. Ant
	define column NPAGI type numeric   size 6    label STR0026 //Num Pag
	define column ARCHI type character size 2000 label STR0023 //Archivo

define query "SELECT  EMPRE, REGPA, TITUL, IMAGE, FCEMI, FCREF, TCONT, "+;
                     "TACTU, TANTE, DSCON, VALAC, VALAN, NPAGI, ARCHI  "+;
             "FROM   %WTable:1%  "

process dataset
	Local cWTabAlias
	Local lRet			:= .F.
	Local cREPORT		:= "CTBR520"
	Local cSayItem	:= CtbSayApro("CTD")
	Local aTamDesc	:= TAMSX3("CTS_DESCCG")
	Local aTamVal		:= TAMSX3("CT2_VALOR")
	Local nDecimais

	Private aSetOfBook := {}
	Private cEjrConta  := self:execParamValue("MV_PAR01") //ejercicio contable
	Private cCodConfL  := self:execParamValue("MV_PAR02") //Cod. Conf. libros
	Private cMoneda    := self:execParamValue("MV_PAR03") //moneda
	Private nPosAntLP  := self:execParamValue("MV_PAR04") //Pos. ant. L/P
	Private dFcGanPer  := self:execParamValue("MV_PAR05") //fch. ganancias/perdidas
	Private nDemosVar  := self:execParamValue("MV_PAR06") //dem. Varacion
	Private nNomInici  := self:execParamValue("MV_PAR07") //nomina inicial
	Private nImprAuxi  := self:execParamValue("MV_PAR08") //imp aux
	Private cPathAuxi  := self:execParamValue("MV_PAR09") //path aux.
	Private cImprAuxi  := self:execParamValue("MV_PAR10") //Tipo saldo
	Private nTituloVi  := self:execParamValue("MV_PAR11") //titulo vision
	Private cTITULO    := Capital(STR0001)  //ESTADO DE ORIGENES E INVERSIONES DE RECURSOS

		aSetOfBook	:= CTBSetOf(cCodConfL)

		cTitulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo )	// Titulo definido SetOfBook

		If Valtype(nTituloVi)=="N" .And. (nTituloVi == 1)
			cTitulo := CTBNomeVis( aSetOfBook[5] )
		EndIf

		if ::isPreview()
		endif

	   cWTabAlias := ::createWorkTable()
	   chkFile("CT1")

	   //Regla de avance de la impresion.
		Processa({|_lEnd| lRet := CTR818rpt(cWTabAlias)}, ::title())

		if !lRet
	        MsgInfo(STR0010) //"No hay datos que cumplan la condicion "
		else
			MsgInfo(STR0009) // Impresion concluida satisfactoriamente
		endif

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTR818rpt  ³ Autor ³ Jonathan Gonzalez    ³ Data ³ 30/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza el llenado de las columnas del dataset de acuerdo la³±±
±±³          ³definicion especificada.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet: Returna .T. o .F., Si no se encontraron datos para el ³±±
±±³          ³llenado del dataset.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabla Temporal                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR818rpt(cWTabAlias)
	Local aCtbMoeda	:= {}
	Local cSeparador	:= ""
	Local cPicture
	Local cDescMoeda
	Local cTipoAnt	:= ""
	Local dFinal		:= CTOD("  /  /  ")
	Local aSetOfBook	:= CTBSetOf(cCodConfL)
	Local cTpValor	:= GetMV("MV_TPVALOR")
	Local lImpTrmAux	:= Iif(nImprAuxi == 1,.T.,.F.)
	Local aTamVal		:= TAMSX3("CT2_VALOR")
	Local bCondVal
	Local cnt			:= 0
	Local nI	       := 0
	Local cArqTmp

	Private aDatos := {.f., ""}

		//Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
		//Gerencial -> montagem especifica para impressao)
		//faz a validação do livro
		if ! VdSetOfBook( cCodConfL , .T. )
		   return .F.
		endif

		CTG->(dbSelectArea("CTG"))
		CTG->(dbSetOrder(1))
		If MsSeek(xFilial()+cEjrConta,.F.)
			While CTG->(! Eof()) .and. CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = cEjrConta
				dFinal    	:= CTG->CTG_DTFIM
				CTG->(DbSkip())
			EndDo
		EndIf

		dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))  //Fecha anterior
		cEjrConta	:= dFinal //Fecha actual

		aCtbMoeda := CtbMoeda(cMoneda, aSetOfBook[9])
		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
		    Return
		Endif

		cDescMoeda 	:= AllTrim(aCtbMoeda[3])
		nDecimais 	:= DecimalCTB(aSetOfBook,cMoneda)

		cPicture 	:= aSetOfBook[4]
		If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
			cPicture := ""
		Endif

		//Monta Arquivo Temporario para Impressao
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					dFinalA+1,dFinal,"","", "",Repl("Z", Len(CT1->CT1_CONTA)),;
					"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
					"",Repl("Z", Len(CTH->CTH_CLVL)),cMoneda,;
					cImprAuxi,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30),,,,,;
					nPosAntLP = 1, dFcGanPer)},STR0004, STR0003) //"Criando Arquivo Temporario...", "Origens e Aplicacoes de recursos"

		cArqTmp ->(dbSelectArea("cArqTmp"))
		cArqTmp ->(dbGoTop())

		//Conteo de archivo temporal para regra de avance.
			count to nCount
			cArqTmp -> (dbGotop())
			ProcRegua(nCount)

		/*
		±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		Explicacion de parametros de la funcion ValorCTB
		ValotCTB(ExpN1, ExpN2, ExpN3, ExpN4, ExpN5, ExpL1, ExpC1, ExpC2, ExpC3, ExpL2, ExpO1, ExpC4, ExpC5, ExpL3, ExpL4)

		Parametros	 ExpN1 = Valor
					 ExpN2 = Numero da Linha
					 ExpN3 = Numero da Coluna
					 ExpN4 = Tamanho
					 ExpN5 = Numero de Decimais
					 ExpL1 = Se devera ser impresso com sinal ou nao.
					 ExpC1 = Picture
					 ExpC2 = Tipo
					 ExpC3 = Conta
					 ExpL2 = Se eh grafico ou nao
					 ExpO1 = Objeto oPrint
					 ExpC4 = Tipo do sinal utilizado
					 ExpC5 = Identificar [USADO em modo gerencial]
					 ExpL3 = Imprime zero
					 ExpL4 = Se .F., inves de imprimir retornara o valor como caracter.
		±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		*/
		While cArqTmp->(!Eof())
			cnt++
			Incproc()

			bCondVal := { || (cArqTmp->IDENTIFI < "5") .And. (cArqTmp->DESCCTA <> "-") }

			RecLock(cWTabAlias, .T.)
				(cWTabAlias)->EMPRE := AllTrim( SM0->M0_NOMECOM )
				(cWTabAlias)->REGPA := Alltrim( SM0->M0_CGC )
				(cWTabAlias)->TITUL := cTitulo
				(cWTabAlias)->IMAGE := "lgrl"+cEmpAnt+".bmp"
				(cWTabAlias)->FCEMI := Dtoc(MsDate())
				(cWTabAlias)->FCREF := DTOC(dDataBase)
				(cWTabAlias)->TCONT := STR0006+cDescMoeda+")"
				(cWTabAlias)->TACTU := Dtoc(dFinal)
				(cWTabAlias)->DSCON := If(cArqTmp->DESCCTA <> "-", cArqTmp->DESCCTA, "")
							                            //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
				(cWTabAlias)->VALAC := If(Eval(bCondVal),ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),"" )
				(cWTabAlias)->NPAGI := nNomInici
				If nDemosVar == 1
					(cWTabAlias)->TANTE := Dtoc(dFinalA)
							                                //ValotCTB(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5,ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpO1,ExpC4,ExpC5,ExpL3,ExpL4)
					(cWTabAlias)->VALAN := If(Eval(bCondVal),ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),"" )
				EndIf

			(cWTabAlias)->(MsUnlock())

			cArqTmp->(DbSkip())
		EndDo

		//Valida si se imprimira el archivo de Termo Aux.
		If lImpTrmAux
			while !aDatos[1]
				aDatos := {.f.,""}
				ValTermCTB("CTR520")
			enddo

			RecLock(cWTabAlias, .T.)
				(cWTabAlias)->ARCHI := aDatos[2]
			(cWTabAlias)->(MsUnlock())
		Endif

		DbSelectArea("cArqTmp")
		Set Filter To
		dbCloseArea()

		If Select(cArqTmp) == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIF

			lRet := cnt > 0

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR818IM ³ Autor ³ Alfredo. Medrano      ³ Data ³05/12/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Termo de Abertura/Encerramento de Livro             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR818IM(cArquivo,aVariavel)                               ³±±
±±³          ³ Parametros:                                                 ³±±
±±³          ³ cArquivo=Nome do Arquivo que contem script a ser impresso   ³±±
±±³          ³          XXXXXXXX.XXX                                       ³±±
±±³          ³ aVariavel=Array com                                         ³±±
±±³          ³           {{Variavel no script,Conteudo a Substituir},...}  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cText: Cadena de caracteres con el contenido del archiv .TRM ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR818IM(cArquivo,aVariavel)
	Local cTermo       := ""
	Local aTermo       := {""}
	Local ni           := 1
	Local nj           := 1
	Local nTamArq      := 0
	Local aParametros  := {}
	Local nLinTermo    := 0
	Local nColTermo    := 0
	Local CR           := Chr(13)+Chr(10)
	Local cAux         := ""
	Local cAux2        := ""
	Local nY           := 0
	Local cText        := ""

		If cArquivo <> Nil .And. ".DOC" $ Upper(cArquivo) .And. File(cArquivo)
			TermoViaWord(cArquivo)  // Regresa un String vacio si la impresion es por word
			Return cText
		Endif

		// Verifica se arquivo existe
		If  Empty(cArquivo) .or. !File(cArquivo)
			Return cText
		Endif

		//Carrega arquivo
		nTerHdl :=FOPEN(cArquivo,2+64)
		nTamArq :=FSEEK(nTerHdl,0,2)
		xBuffer :=Space(nTamArq)
		FSEEK(nTerHdl,0,0)
		FREAD(nTerHdl,@xBuffer,nTamArq)
		FCLOSE(nTerHdl)

		// Ao desmontar o arquivo para impressao, transforma os Chr(141) para Chr(13) atraves da HardCr()
		// e elimina os codigos Chr(10) de quebra de linha para que o contole da quebra seja feito apenas
		// pelo chr(13) na montagem do Vetor de Impressao
		cTermo  := strtran(xBuffer , chr(10) , "")
		While !empty(cTermo)
		      ni := at( chr(13), cTermo )
		      If ni > 0
		            AADD(aTermo,Left(cTermo,ni-1))
		            cTermo := Substr(cTermo,ni+1)
		      Else
		            aadd(aTermo,cTermo)
		            cTermo:=""
		      Endif
		EndDo

		//Substitui variaveis
		nTamTerm:=Len(aTermo)

		nNumPar:=0
		aEval(aVariavel,{ |x| IIf(!Empty(x[1]),nNumPar:=nNumPar+1,)})

		For ni:=1 to nTamTerm
		      For nj:=1 to nNumPar
		            cTipo:=Valtype(aVariavel[nj,2])
		            Do Case
		            Case cTipo=="N"
		                  cValor:=LTrim(Str(aVariavel[nj,2]))
		            Case cTipo=="D"
		                  cValor:=DtoC(aVariavel[nj,2])
		            Case cTipo=="L"
		                  cValor:=IIF(aVariavel[nj,2],STR0024,STR0025) // "SIM"  ### "NAO"
		            Case cTipo=="C"
		                  cValor:=aVariavel[nj,2]
		            EndCase
		            //Tratamento para substituir exatamente o campo requerido, pois estava
		            //   ocorrendo de existir um campo _CPF e _CPFRES na mesma tabela e
		            //   quando ele iria procurar o _CPF para substituir, alterava onde estava
		            //   o _CPFRES.
		            If At(aVariavel[nj,1], aTermo[ni])>0
		                  cAux  :=    SubStr(aTermo[ni],At(aVariavel[nj,1], aTermo[ni]))
		                  cAux2 :=    ""
		                  For nY := 1 To Len(cAux)
		                        If IsAlpha(SubStr(cAux,nY,1)) .Or. SubStr(cAux,nY,1)$"_1234567890"
		                             cAux2 += SubStr(cAux,nY,1)
		                        Else
		                             Exit
		                        EndIf
		                  Next nY
		                  //Somente quando for o mesmo campo entre a tabela e o exigido no layout do termo.
		                  If cAux2==aVariavel[nj,1]
		                  	aTermo[ni]:=StrTran(aTermo[ni],aVariavel[nj,1],cValor)
		                  EndIf
		            EndIf
		      Next
		Next
		// Imprime termo
		For ni:=1 to nTamTerm
			cText += aTermo[ni] + chr(13) + chr(10)
		Next

Return cText

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValTermCTB ³ Autor ³ Jonathan Gonzalez     ³ Data ³04/09/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida que el tamaño del archivo TRM no sea mayor a 2,000   ³±±
±±³Descri‡…o ³ caracteres.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValTermCTB(cPregunta)                                       ³±±
±±³          ³ cPregunta := Nombre del Grupo de preguntas.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aDatos: una valor booleano y contenido del archivo .TRM     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValTermCTB(cPregunta)
Local nTerHdl
Local nTamArq
Local xBuffer
Local cArqTrm		:= ""

	cArqTRM    := cPathAuxi
	aVariaveis := {}

	SX1->( dbSeek( padr( cPregunta, Len( SX1->X1_GRUPO ) , ' ' ) + "01" ) )

	While SX1->X1_GRUPO == padr( cPregunta , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	EndDo

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := cfgx024(cArqTRM,STR0005) // "Responsáveis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		nTerHdl :=FOPEN(cArqTRM,2+64)
		nTamArq :=FSEEK(nTerHdl,0,2)
		xBuffer :=Space(nTamArq)

		FSEEK(nTerHdl,0,0)
		FREAD(nTerHdl,@xBuffer,nTamArq)
		FCLOSE(nTerHdl)

		if nTamArq < 2000 .and. Len(xBuffer) < 2000
			aDatos := {.T.,CTBR818IM(cArqTRM,aVariaveis,,,)}
		else
			MSGALERT(STR0029, STR0030)//El archivo de Terminos Auxiliares (.TRM) a imprimir es mayor a 2,000 caracteres,
			                          //por favor edite el archivo o cree uno nuevo.
			                          //Imp. Terminos Auxiliares
			aSavSet:=__SetSets()
			cArqTRM := cfgx024(cArqTRM,STR0005) // "Responsáveis..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)

			aDatos := {.f.,""}
		endif
	Endif
return aDatos