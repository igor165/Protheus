#INCLUDE "PROTHEUS.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "FISA066.CH"                        
#INCLUDE "SHELL.CH"
#include "FILEIO.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ FISA066  ³ Autor ³ Laura Medina          ³ Data ³16/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Declaración Anual de operaciones con Terceros.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³A. Rodriguez³21/10/13³          ³Implementación P11                    ³±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±³Alf. Medrano³29/12/16³SERINN001-542³creación de tablas temporales con  ³±±
±±³            ³        ³          ³FWTemporaryTable en funcion TrbConso()³±±
±±³            ³        ³          ³se inicializa varible oTmpTable en fun³±±
±±³            ³        ³          ³FISA066                               ³±±
±±³Alf. Medrano³17/01/17³SERINN001-542³Merge Main vs 12.1.15              º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FISA066()

Local aArea		:=  GetArea()
Local cTitulo	:=	STR0001 //"Instrucoes Normativas"
Local cMsg1		:=	STR0002 //"Este programa genera el archivo para la Declaración Anual de Operaciones con Terceros,  "
Local cMsg2		:=	STR0003 //"con la estructura especifica para entregar al SUNAT (Superintendencia Nacional de Aduanas  "
Local cMsg3		:=	STR0004 //"y Administración Tributaria), tal cual Lay Out de las Instrucción Normativas. Debe ejecutarse"
Local cMsg4		:=	STR0005 //"en modo monousuario. "
Local nOpcA		:= 0
Local nTotReg   := 0
Local cPerg		:= "FISA066"
Local cNorma	:= ""
Local cDest		:= ""
Local cDir      := ""
Local cVar      := ""
Local aFilsCalc	:= {}
Local cFilBack  := cFilAnt
Local nForFilial:= 0
Local cMsg      := ""
Local cNewFile  := ""
Local cDrive    := ""
Local cExt      := ""
Local cDirRec	:= "" 
Local nProcFil	:= 0
Local aProcFil	:= {.F.,cFilAnt}
Local nX		:= 0
Local aTrab		:=	{}    
Local aArcDAOT  := {{"Costos.txt",1},;
					{"Ingresos.txt",2}}
                  //Nombre del archivo y rutina a ejecutar    
Local nloop     := 0 

Private dDmainc
Private dDmaFin
Private nMoedTit := 1
Private cNrLivro
Private nMes
Private nAno
Private aReturn   := {}
Private nRutina   := 0 //Numero de la rutina a ejecutar     
Private cFlAnte   :=  cFilAnt 
Private dDataDe	  := Ctod("//")
Private dDataAte  := Ctod("//")
private 	oTmpTable

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
//³Variavel "lExitPFil" utilizada para indicar ao processamento do FISR099 que a rotina irah       ³
//³   utilizar a pergunta "Seleciona Filiais" para algum tratamento especifico, porem nao havera a ³
//³   necessidade de criar pastas separadas para cada arquivo resultado. Um exemplo de utilizacao  ³
//³   deste tratamento eh a DAPIMG, onde utiliza a pergunta para consolidar os dados de todas as   ³
//³    filiais em um unico arquivo de resultado. Para se utilizar esta funcionalidade, basta       ³
//³     alterar no .INI o conteudo desta variavel para .T.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
Private lExitPFil  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface com o usuario                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

FormBatch(cTitulo,{OemToAnsi(cMsg1),OemToAnsi(cMsg2),OemToAnsi(cMsg3),OemToAnsi(cMsg4)},;
	{ { 5,.T.,{|o| Pergunte(cPerg,.T.) }},;
	{ 1,.T.,{|o| nOpcA := 1,o:oWnd:End()}},;
	{ 2,.T.,{|o| nOpca := 2,o:oWnd:End()}}})

If ( nOpcA==1 )
	cNorma   := AllTrim("DAOTPE")+ ".INI"    //cambiar
	cDir     := AllTrim(MV_PAR02)
	//nProcFil := MV_PAR03    
	nProcFil := 2 //No seleccionar sucursales
	dDataDe	 := Ctod("01/01/" + str(MV_PAR01))
	dDataAte := Ctod("31/12/" + str(MV_PAR01))

	//aFilsCalc := MatFilCalc( MV_PAR03 == 1 )
	aFilsCalc := MatFilCalc( .F.)

	If Empty( aFilsCalc )
		Return
	EndIf
                                    
	For nloop:= 1 to len(aArcDAOT) //Contiene los nombres de los archivos    
	
        cDest  := aArcDAOT[nloop,1] 
        nRutina:= aArcDAOT[nloop,2]    //1.Pagos/2.Cobros
        
		For nForFilial := 1 To Len( aFilsCalc )
	
			If aFilsCalc[ nForFilial, 1 ]   //Si selecciona la sucursal 01/02.. 
	
				cFilAnt := aFilsCalc[ nForFilial, 2 ]				
				cNewFile := cDir + cDest
				
				SplitPath(cNewFile,@cDrive,@cDir,@cDest,@cExt)
	
				cDir := cDrive + cDir
				cDest+= cExt
				
				If nProcFil == 1
					cDirRec := cDir + cFilAnt + "\"
					aProcFil := {.T.,cFilAnt}
				Else
					cDirRec := cDir
					aProcFil := {.F.,cFilAnt}
				EndIf
				
				Makedir(cDirRec)
	
				dbSelectArea("SX3")
				dbSetOrder(1)
				Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reabre os Arquivos do Modulo desprezando os abertos pela Normativa      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbCloseAll()
				OpenFile(SubStr(cNumEmp,1,2))
	
			EndIf
	
			If Type("lExitPFil")=="L" .And. lExitPFil
				DirRemove(cDirRec)
				Exit
			EndIf
	
		Next nForFilial                              
	Next nloop

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ferase no array aTrab                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aTrab)
	Ferase(AllTrim(aTrab[nX][1]))
Next

dbSelectArea("SF3")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilBack
RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ReadNorma ³ Autor ³Eduardo Riera          ³ Data ³17.07.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Leitura dos arquivos de Instrucao Normativa       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com o Lay-Out da Instr.Normativa                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Arquivo                                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReadNorma(cNorma, lImprime, cMdb, cMaskVlr, lXml, lTSF, lQuebralin,lNfse)

Local aNorma 	:= {}
Local cLinha 	:= ""
Local aArq      := {{}}
Local aAlias 	:= {{}}//{NIL,NIL,NIL}
Local aPre	 	:= {{}}
Local aPos	 	:= {{}}
Local aPreReg	:= {{}}
Local aPosReg	:= {{}}
Local aStru  	:= {{}}
Local aConteudo	:= {{}}
Local aContReg	:= {{}}
Local aIni      := {{}}
Local cAux		:= ""
Local aArea		:= GetArea()
Local nNivel   	:= 1
Local aImprime 	:= {.F.,,,,.F.}
Local aDelimit  := {{}}
Local aConsolidado	:=	{{"cFilAnt", "cFilAnt", "", ""}}
Local aChv		:=	{{}}
Local aOrd		:=	{""}
Local cLay      := ""
Local nAt		:=	0

Default cMaskVlr	:=	""
Default cMdb 		:= 	{}
Default lImprime	:=	.F.
Default lXml		:=	.F.
Default lTSF		:=	.F.//Indica se o processamento sera via TSF ou ERP
Default lNfse		:=	.F.//Indica se o processamento sera via TSS ou ERP
Default lQuebralin  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do Arquivo a Ser Lido                                         ³
//³                                                                        ³
//³[XXX] Onde XXX eh o Alias Principal - Identifica um Registro de Arquivo³
//³(ARQ) Definicao do Nome do Arquivo TXT referente ao Bloco []            ³
//³(PRE) Pre-Processamento do Registro de Arquivo                          ³
//³(PREREG) Pre-Processamento para cada registro do Alias Principal        ³
//³WWWWWWWWWW X YYY Z CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC ³
//³|          | |   | |                                                    ³
//³|          | |   | -> Conteudo                                          ³
//³|          | |   | -> Numero de Decimais                                ³
//³|          | | -----> Tamanho da Coluna                                 ³
//³|          | -------> Formato de Gravacao ( Numerico Caracter Data      ³
//³| ------------------> Nome da Coluna                                    ³
//³(POSREG) Pos-Processamento para cada registro do Alias Principal        ³
//³(POS) Pos-Processamento do Registro de Arquivo                          ³
//³(INI:<Nome>) Normativa a ser processada apos este registro.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Abertura do Arquivo NormaXXX.Ini                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (File(cNorma))
	FT_FUse(cNorma)
	FT_FGotop()

	While ( !FT_FEof() )
		cLinha := FT_FREADLN()

		Do Case
		Case "["==SubStr(cLinha,1,1)
			If ( !Empty(aAlias[nNivel]) )
				aadd(aNorma,{ aAlias,aPre,aPreReg,aPos,aPosReg,aStru,aConteudo,aArq,aContReg,aINI, aImprime, aDelimit, aConsolidado, aChv, aOrd,cLay})
				aPre 		:= {{}}
				aPreReg 	:= {{}}
				aPos		:= {{}}
				aPosReg		:= {{}}
				aStru		:= {{}}
				aConteudo	:= {{}}
				aContReg	:= {{}}
				aINI    	:= {{}}					
				aAlias		:= {{}} //{NIL,NIL,NIL}
				nNivel   	:= 1
				aArq        := {{}}
				aDelimit 	:= {{}}
				aConsolidado:=	{{"cFilAnt", "cFilAnt", "", ""}}
				aChv		:=	{{}}
			EndIf
			nAt	:=	0
			If (nAt := At(" ",cLinha))==0
				If (nAt := At("]",cLinha))==0
					If (nAt := At("}",cLinha))==0
						nAt	:=	Len(AllTrim(cLinha))-1
					Else
						nAt	-=	2
					EndIf
				Else
					nAt	-=	2
				EndIf
			Else
				nAt	-=	2
			EndIf
				
			aAlias[nNivel] := SubStr(cLinha,2,nAt)
			
			If nNivel <= 1			
				cLay       := AllTrim(SubStr(cLinha,6,Len(cLinha)-6))
				If Len(cLay)>47
					cLay   := SubStr(cLay,1,47)+"..."
				EndIf
			EndIf
			aImprime 	:= {.F.,,,,.F.}
			aOrd		:=	{""}
		Case "{"==SubStr(cLinha,1,1)
			nNivel++
			nAt	:=	0
			If (nAt := At(" ",cLinha))==0
				If (nAt := At("]",cLinha))==0
					If (nAt := At("}",cLinha))==0
						nAt	:=	Len(AllTrim(cLinha))-1
					Else
						nAt	-=	2
					EndIf
				Else
					nAt	-=	2
				EndIf
			Else
				nAt	-=	2
			EndIf
			aadd(aAlias,SubStr(cLinha,2,nAt))
			aadd(aPre,{})
			aadd(aPreReg,{})
			aadd(aPos,{})
			aadd(aPosReg,{})
			aadd(aStru,{})
			aadd(aConteudo,{})
			aadd(aContReg,{})
			aadd(aINI,{})
			aadd(aArq,{})
			aadd(aDelimit,{})
			aAdd(aConsolidado, {"cFilAnt", "cFilAnt", "", ""})
			aadd(aChv,{})
			aadd(aOrd,"")

			//Identifica em que ordem deve ser impresso um determinado registro no INI. Esta clausula deve ser utilizada para os blocos
			//	que nao possuem Alias, ou seja, deve ser XXX e que o bloco esteja no INI principal (nao podendo estar dentro de um outro
			//	INI chamado pelo principal. Ex: SISIF). Um exemplo de utilizacao eh para totalizador, onde os valores calculados durante o
			//	o processamento do INI deverao compor o registro HEADER, na primeira linha do meio-magnetico.
			//	- Sua clausula pode indicar TOP para o primeiro registro do meio-magnetico ou BOT (Bottom) para o ultimo registro do meio-magnetico.
			//	- Se nao for informado, sera considerado na posicao em que aparecer no INI.
			//
			//INI Utilizado: GIARS.INI
		Case "(ORD"==SubStr (cLinha,1,4)
			aOrd[nNivel]	:=	AllTrim (SubStr (cLinha, 6))

			//Esta chave eh utilizada para otimizar o while quando nao for possivel implementar um FSQUERY por exemplo, esta chave faz
			//	parte do while para a tabela passada como Alias no bloco do registro.
		Case "(CHV"==SubStr (cLinha,1,4)
			aChv[nNivel]	:=	AllTrim (SubStr (cLinha, 6))

		Case "//"==SubStr (cLinha,1,2)
			//Nao faz nada, pois eh comentario.                                        	

			//Esta clausula define uma mascara padrao para todos os campos valores gerados pela IN no meio-magnetico.
			//	Ex. MANAD.INI: @MASKVLR="@E 9999999.99"
		Case "@MASKVLR="==SubStr (cLinha,1,9)
			cMaskVlr	:=	&(AllTrim (SubStr (cLinha, 10)))

		Case "(CONSOLIDADO)"==SubStr (cLinha,1,13)
			aConsolidado[nNivel]	:=	&(AllTrim (SubStr (cLinha, 14)))

		Case "(ARQ"==SubStr(cLinha,1,4) .And.(")"==SubStr(cLinha,5,1).or.")"==SubStr(cLinha,6,1)).And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ("&"$cAux)
				cAux	:=	&(AllTrim(SubStr (cAux, At ("&", cAux)+1)))
			EndIf
			//
			If ( !Empty(cAux) )
				aadd(aArq[nNivel],cAux)
			EndIf
		Case "(PRE"==SubStr(cLinha,1,4) .And.(")"==SubStr(cLinha,5,1).or.")"==SubStr(cLinha,6,1)).And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ( !Empty(cAux) )
				aadd(aPre[nNivel],cAux)                         
			EndIf
		Case !lTSF .And. !lNfse  .And. "(IMP"==SubStr(cLinha,1,4) 
			aImprime	:=	&(AllTrim (AllTrim (SubStr (cLinha, 6))))

		Case !lTSF .And. !lNfse .And. "(LEG"==SubStr(cLinha,1,4)

		Case !lTSF .And. !lNfse .And. "(CMP"==SubStr(cLinha,1,4)

		Case "(DEL"==SubStr(cLinha,1,4)
			If ("&"$AllTrim (AllTrim (SubStr (cLinha, 6))))
				aDelimit[nNivel]	:=	&(SubStr (AllTrim (SubStr (cLinha, 6)),2))
			Else
				aDelimit[nNivel]	:=	AllTrim (AllTrim (SubStr (cLinha, 6)))
			EndIf

		Case "(PREREG"==SubStr(cLinha,1,7) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,10))
			If ( !Empty(cAux) )
				aadd(aPreReg[nNivel],cAux)
			EndIf

		Case "(POS"==SubStr(cLinha,1,4) .And.(")"==SubStr(cLinha,5,1).or.")"==SubStr(cLinha,6,1)) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ( !Empty(cAux) )
				aadd(aPos[nNivel],cAux)
			EndIf

		Case "(POSREG"==SubStr(cLinha,1,7) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,10))
			If ( !Empty(cAux) )
				aadd(aPosReg[nNivel],cAux)
			EndIf

		Case "(CONT"==SubStr(cLinha,1,5) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ( !Empty(cAux) )
				aadd(aContReg[nNivel],cAux)
			EndIf	

		Case "(INI:"==SubStr(cLinha,1,5)
			cAux := AllTrim(SubStr(cLinha,6))
			If ( !Empty(cAux) )
				aadd(aIni[nNivel],Left(cAux,Len(cAux)-1))
			EndIf	
		Case "@MDB="==SubStr(cLinha,1,5)
			cMdb	:=	AllTrim (SubStr (cLinha,6))
		Case "@XML"==SubStr(cLinha,1,4)
			lXml	:=	.T.
		Case "@QUEBRA"==SubStr(cLinha,1,7)
			lQuebralin	:= .F.
		OtherWise
			If !lImprime .And. aImprime[1]
				lImprime	:=	.T.
			EndIf
			If ( !Empty(aAlias[nNivel]) ) .And. !Empty(SubStr(cLinha,01,10))
				aadd(aStru[nNivel], {	SubStr(cLinha,01,10) ,; 		//Campo
					SubStr(cLinha,12,01) ,; 		//Tipo
					Val(SubStr(cLinha,14,03)) ,; 	//Tamanho
					Val(SubStr(cLinha,18,01)) })	//Decimal

				aadd(aConteudo[nNivel], SubStr(cLinha,20) )

			EndIf

		EndCase
		FT_FSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o ultimo registro                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(aAlias[nNivel]) )   //Agrega el ultimo item al arreglo aNorma 
		aadd(aNorma,{ aAlias,aPre,aPreReg,aPos,aPosReg,aStru,aConteudo,aArq,aContReg,aINI, aImprime, aDelimit, aConsolidado, aChv, aOrd , cLay})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha o Arquivo NormaXXX.INI                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUse()
Else
	If lTSF .Or. lNfse
		cTSFHelp:="NORMAERRO1"+CHR(13)+CHR(10)
	Else	
		Help(" ",1,"NORMAERRO1")
	Endif
EndIf

RestArea(aArea)

Return(aNorma)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ProcNorma ³ Autor ³Eduardo Riera          ³ Data ³17.07.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Processamento de Instr.Normativa                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Arquivo da Normativa                                 ³±±
±±³          ³ExpC2: Arquivo de Destino                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcNorma(cNorma,cDest,cDir,aProcFil,aTrab,lTSF,aCfg,lNfse,aNfse)

Local aArea 	 := GetArea()
Local lImprime	 :=	.F.
Local cMdb		 :=	""
Local cMaskVlr   :=	""
Local lXml       := .F.
Local lQuebralin := .T.
Local aNorma     :=	ReadNorma(cNorma, @lImprime, @cMdb, @cMaskVlr, @lXml, lTSF, @lQuebralin,lNfse)
Local cTrab	     := CriaTrab(,.F.)+".TXT"
Local nHandle    := 0
Local nX     	 := 0
Local lApaga   	 := .T.
Local aArqSpool  := {}
Local cBuffer    := ""
Local aBufferFim := {}
Local nIndBuf    := 0
Local nExcluidos := 0

Default  lTSF    := .F.//.F.(Default)-Processamento via ERP|.T.-Processamento via TSF
Default  lNfse   := .F.//.F.(Default)-Processamento via ERP|.T.-Processamento via TSS
Default  cDir    := ""
Default  aProcFil:= Iif(lTSF,{},Iif(lNfse,{},{.F.,cFilAnt}))
Default  aTrab	 :=	{}
Default  aCFG	 :=	{} //Variavel Especifico TSF
Default  aNfse	 := {}
Private cTSFHelp := "" //Variavel Especifico TSF

nHandle          := FCreate(cTrab,0)

If ( FError() == 0 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declara Variaveis que podem ser utilizadas nas Normativas.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private _aTotal[110]
	Private lAbtMT950	:=	.F.
	Private cDirNorma	:= cDir
	Private aParTSF		:=	aCfg
	Private aParNfse	:=	aNfse
    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o Numero de Registros da Normativa a Processar                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTSF .And. !lNfse
		ProcRegua(Len(aNorma)+1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa a Normativa                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval(aNorma,{|x| IncProc(x[16]),"",aadd(aBufferFim,RegNorma(x,@nHandle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,@aTrab,lTSF,lQuebralin,lNfse))})
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa a Normativa                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval(aNorma,{|x|,"",aadd(aBufferFim,RegNorma(x,@nHandle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,@aTrab,lTSF,lQuebralin,lNfse))})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encerra o arquivo binario                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a gravacao no Cliente                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTSF .And. !lNfse
		For nX := 1 to len(aNorma) 
			If len(aNorma[nX][8][1]) > 0 
				If !Empty(aNorma[nX][8][1][1])
					If (aNorma[nX][11][1])	//Se for para gerar registro no spool
						If (nPosSC:=aScan(aTrab,{|ax| AllTrim(aX[2])==AllTrim(aNorma[nX][8][1][1])}))>0
							aAdd (aArqSpool, AllTrim(aTrab[nPosSC,1]))
						EndIf
					EndIf
					lApaga := .F.
				EndIf
			EndIf	
		Next nX	
	
		For nX := 1 To Len(aBufferFim)
			If aBufferFim[nX]<>Nil .And. (Empty(aBufferFim[nX]) .Or. (!"T"$SubStr (aBufferFim[nX], 1, 1) .And. !"B"$SubStr (aBufferFim[nX], 1, 1)))
				aDel(aBufferFim,nX)
				nExcluidos++
				nX := 0
			EndIf
		Next nX      
		aSize(aBufferFim,Len(aBufferFim)-nExcluidos)
    Endif
	If !Empty (aBufferFim)
		cTrabSC	:= CriaTrab(,.F.)+".TXT"
		If lTSF
			nHdle:= FCreate ("\FTP\SINTEGRA\"+cDir+Alltrim(cDest)+".TXT",0)	
		ElseIF lNfse
			If ( ValType(aNFSe[1][20]) <> "U" )
				nHdle:= FCreate (cDir+Alltrim(cDest)+If(aNFSe[1][20],".XML",".TXT"),0)
			Else
				nHdle:= FCreate (cDir+Alltrim(cDest)+".TXT",0)
			EndIf
		Else
			nHdle:= FCreate (cTrabSC, 0)       			
	    Endif
		For nIndBuf := 1 To Len(aBufferFim)
			If ("T"$SubStr (aBufferFim[nIndBuf], 1, 1))
				FWrite(nHdle, SubStr (aBufferFim[nIndBuf], 2)+ Iif(lQuebralin,Chr(13)+Chr(10),"") )
			EndIf
		Next nIndBuf
		FT_FUse (cTrab)
		FT_FGoTop ()
		Do While !FT_FEoF ()
			cBuffer := FT_FReadLn ()
			FWrite(nHdle, cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
			//
			FT_FSkip ()
		EndDo
		For nIndBuf := 1 To Len(aBufferFim)
			If ("B"$SubStr (aBufferFim[nIndBuf], 1, 1))
				FWrite(nHdle, SubStr (aBufferFim[nIndBuf], 2)+Iif(lQuebralin,Chr(13)+Chr(10),""))
			EndIf
		Next nIndBuf

		FT_FUse ()
		FClose (nHdle)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
		//³A partir do momento que estah variavel "lExitPFil" passou a ter conteudo .T.,    ³
		//³   nao utilizo a funcionalidade de criacao de arquivos em pastas distintas, gero ³
		//³   um unico arquivo que terah em seu conteudo todas as filiais consolidadas.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
		If Type("lExitPFil")=="L" .And. At(cFilAnt+"\",cDir)>0 .And. lExitPFil 
	 		cDir	:=	Left(cDir,At(cFilAnt+"\",cDir)-1)
	 	EndIf
	 		
		If !lTSF .And. !lNfse               
			aAdd(aArqSpool,cTrabSC)
		Endif
		FErase (cDir+cDest)                     
		__CopyFIle(cTrabSC,cDir+cDest)
				
		If lNfse
			FErase(cTrab)
		EndIf			
	Else	
		If lApaga         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
			//³A partir do momento que estah variavel "lExitPFil" passou a ter conteudo .T.,    ³
			//³   nao utilizo a funcionalidade de criacao de arquivos em pastas distintas, gero ³
			//³   um unico arquivo que terah em seu conteudo todas as filiais consolidadas.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
	 		If Type("lExitPFil")=="L" .And. At(cFilAnt+"\",cDir)>0 .And. lExitPFil
	 			cDir	:=	Left(cDir,At(cFilAnt+"\",cDir)-1)
	 		EndIf
		         
			If lTSF .Or. lNfse
				FErase (cDir+cDest)                     			
			Else		
				aAdd(aArqSpool,cTrab)
			Endif
			Ferase(cDir+cDest)  
			__CopyFIle(cTrab,cDir+cDest) 
		Else
			If !lTSF .And. !lNfse .And. !lAbtMT950 
				If cPaisLoc <> "MEX" 
					Aviso(STR0005,; //"Instrucoes Normativas"
						STR0006,; //"Esta instrucao normativa possui arquivos de destino especificos e portanto o parametro de destino nao foi respeitado!"
						{"OK"})
				Endif
			Endif
		EndIf	
	EndIf
Else                
	If lTSF .Or. lNfse
		cTSFHelp := "NORMAERRO2"+CHR(13)+CHR(10)
	Else	
		Help(" ",1,"NORMAERRO2")
	Endif
EndIf
If !lTSF .And. !lNfse
	If (lImprime) .And. !(lAbtMt950) 
		ImpSpool (cNorma, cDest, cDir, aArqSpool,aTrab)
	EndIf   
Endif
//
If !Empty (cMdb)
	If (File (cDir+cMdb))
		FErase (cDir+cMdb)
	EndIf
	WaitRun ("TxtToMdb "+cDir+cDest+" "+cDir+cMdb+" -ver=4", SW_HIDE)
EndIf
If lTSF    
	If Len(aParTSF)>0       
		aParTSF[1][17]+=cTSFHelp
	Endif	
Endif       
If lNfse
	If Len(aParNfse)>0       
		aParNfse[1][15]+=cTSFHelp
	Endif	
Endif       
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RegNorma  ³ Autor ³Eduardo Riera          ³ Data ³17.07.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa um registro de Instrucao Normativa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Registro da Norma                                    ³±±
±±³          ³ExpN1: Handle do Arquivo a Ser Gravado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RegNorma(aReg,nHandle,cTrab,cDir, cMaskVlr, lXml,aProcFil,aTrab,lTSF,lQuebralin,lNfse)

Local aArea		:= GetArea()
Local aArea1	:= {}
Local aArea2	:= {}
Local aArea3	:= {}
Local aAlias	:= aReg[1]
Local aPre	 	:= aReg[2]
Local aPreReg	:= aReg[3]
Local aPos		:= aReg[4]
Local aPosReg   := aReg[5]
Local aStru		:= aReg[6]
Local aConteudo := aReg[7]
Local aArq		:= aReg[8]
Local aContReg	:= aReg[9]
Local aINI      := aReg[10]
Local aDelimit	:= aReg[12]
Local aConsolidado := aReg[13]
Local aChv		:= aReg[14]
Local aOrd		:= aReg[15]
Local cFilDe		:=	""
Local cFilAte		:=	""
Local cChaveCons	:=	""
Local cCmpGrvCon	:=	""
Local aArqNew		:=	{}
Local uConteudo
Local cBuffer		:= ""
Local nCntFor		:= 0
Local bError
Local lContinua 	:= Len(aStru) > 0
Local nNivel    	:= 0
Local cDelimit  	:= ""
Local aAreaSm0	 	:= {}
Local cBufferFim 	:= ""
Local aChvNivel		:= {.F., .F., .F.}
Local aSkipChv		:=	{.F., .F., .F.}
Default lTSF 		:= .F.
Default lXml 		:= .F.                                               
Default aProcFil	:= Iif(lTSF,.F.,Iif(lNfse,.F.,{.F.,cFilAnt}))
Default aTrab		:=	{}

If !lTSF .And. !lNfse
	aAreaSm0:= SM0->(GetArea ())

	//lAbtMt950 - Aborta a rotina
	If (lAbtMT950) 
	    RestArea(aAreaSm0)
		Return (cBufferFim)
	EndIf
	
	If aAlias[1] <> "XXX"
		dbSelectArea(aAlias[1])
	EndIf
	
	aArea1 := GetArea()   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona o cFilAnt sempre na filial que esta sendo processada³
	//³atraves da selecao do aFisCalc.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  aProcFil[1]
		cFilAnt := aProcFil[2]
	Endif
	cFilDe		:=	&(aConsolidado[1][1])	//Filial de passado pelo INI
	cFilAte		:=	&(aConsolidado[1][2])	//Filial ate passado pelo INI
	cChaveCons	:=	aConsolidado[1][3]
	cCmpGrvCon	:=	aConsolidado[1][4]                       
	If Empty (cFilDe) .And. Empty (cFilAte)
		cFilDe		:=	cFilAnt
		cFilAte		:=	cFilAnt
	EndIf
	If !lTSF .And. !lNfse .And. (cFilDe#cFilAte)
		TrbConso (1, 1, aStru, cChaveCons, @aArqNew)
	EndIf
	DbSelectArea("SM0")                    
	SM0->(DbGoTop())
	SM0->(DbSeek (cEmpAnt+cFilDe, .T.))
Else
	//lAbtMt950 - Aborta a rotina
	If (lAbtMT950) 
		Return (cBufferFim)
	EndIf
	If !"XXX"$aAlias[1]
		dbSelectArea(aAlias[1])
	EndIf
	aArea1 := GetArea()   
EndIf

Do While lTSF .Or. lNfse .Or. (SM0->(!Eof()) .And. SM0->M0_CODIGO+SM0->M0_CODFIL<=cEmpAnt+cFilAte)
	If !lTSF .And. !lNfse
		cFilAnt	:=	SM0->M0_CODFIL
	Endif	
	If !"XXX"$aAlias[1]
		dbSelectArea(aAlias[1])
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o Pre-Processamento                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEval(aPre[1],{|x| &(x) })
	If !"XXX"$aAlias[1]
		dbSelectArea(aAlias[1])

		aChvNivel[1] := ( Len(aChv)>=1 .And. !Empty(aChv[1]) )
		While ( !Eof() ) .And. lContinua .And. Iif (aChvNivel[1], &(aChv[1]), .T.)
			cBuffer := ""
			aSkipChv	:=	{.T., .F., .F.}	//Controle para execucao do skip de cada nivel, este controle eh utilizado para quando a IN estah usando a clausula CHV.
			If (sfVldPReg (@aPreReg[1], @nHandle, lQuebralin))
				cDelimit	:=	AllTrim (aDelimit[1])
				cBuffer		+=	""
				//
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ha casos em que o delimitador eh so considerado no meio, ou so no inicio e fim, ou so no meio e fim, portanto foi criado a seguinte regra:                             ³
				//³A clausula (DEL) no INI devera ser criada na seguinte estrutura:                                                                                                       ³
				//³Ex: (DEL)|IMF, onde | eh o delimitador, I eh para gerar no incio de cada linha, M eh para gerar entre os campos de cada linha e F eh para gerar no final de cada linha.³
				//³Algumas formas de se utilizar:                                                                                                                                         ³
				//³(DEL)|MF                                                                                                                                                               ³
				//³(DEL)|M                                                                                                                                                                ³
				//³(DEL)|IMF                                                                                                                                                              ³
				//³(DEL)|IF                                                                                                                                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTSF .And. !lNfse .And. (cFilDe#cFilAte)//Somente para o Nivel 1, inicialmente resolver o caso do MANAD
					ConsoFil (aArqNew, cChaveCons, 1, aStru, aConteudo, cCmpGrvCon)
					DbSelectArea (aAlias[1])
					(aAlias[1])->(DbSkip ())
					Loop
				EndIf

				If (Len (cDelimit)>1)
					If ("I"$SubStr (cDelimit, 2))
						cBuffer	+=	SubStr (cDelimit, 1, 1)
					EndIf
				EndIf

				For nCntFor := 1 To Len(aStru[1])
					bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[1]+"->"+aStru[1][nCntFor][1]+"|"+aConteudo[1][nCntFor],3,1) })
					
					BEGIN SEQUENCE

				       uConteudo := &(aConteudo[1][nCntFor])

						Do Case
						Case ( aStru[1][nCntFor][2] == "N" )

							If ( uConteudo == Nil )
								uConteudo := 0
							EndIf

							If Empty (cMaskVlr) .Or. (aStru[1][nCntFor][4])==0
								uConteudo := NoRound(uConteudo*(10**(aStru[1][nCntFor][4])),aStru[1][nCntFor][4])
								//
								If (!Empty (aDelimit[1]))
									cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[1][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[1][nCntFor][3])))
								Else
									cBuffer += StrZero(uConteudo,aStru[1][nCntFor][3])									
								EndIf
							Else
								cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
							EndIf

						Case ( aStru[1][nCntFor][2] == "D" )

							If ( uConteudo == Nil )
								uConteudo := dDataBase
							EndIf
							cBuffer += PadR(Dtos(uConteudo),aStru[1][nCntFor][3])

						Case ( aStru[1][nCntFor][2] == "C" )

							If ( uConteudo == Nil )
								uConteudo := ""
							EndIf

							If (!Empty (aDelimit[1]))
								cBuffer += AllTrim(uConteudo)
							Else   
								If !lXML .And. aStru[1][nCntFor][3]<>0
									cBuffer += PadR(uConteudo,aStru[1][nCntFor][3])
								Else                                                
									cBuffer += uConteudo
								EndIf
							EndIf

						EndCase

					END SEQUENCE
					ErrorBlock(bError)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ha casos em que o delimitador eh so considerado no meio, ou so no inicio e fim, ou so no meio e fim, portanto foi criado a seguinte regra:                             ³
					//³A clausula (DEL) no INI devera ser criada na seguinte estrutura:                                                                                                       ³
					//³Ex: (DEL)|IMF, onde | eh o delimitador, I eh para gerar no incio de cada linha, M eh para gerar entre os campos de cada linha e F eh para gerar no final de cada linha.³
					//³Algumas formas de se utilizar:                                                                                                                                         ³
					//³(DEL)|MF                                                                                                                                                               ³
					//³(DEL)|M                                                                                                                                                                ³
					//³(DEL)|IMF                                                                                                                                                              ³
					//³(DEL)|IF                                                                                                                                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Len (cDelimit)>1)
						If (nCntFor==Len(aStru[1]))
							If ("F"$SubStr (cDelimit, 2))
								cBuffer	+=	SubStr (cDelimit, 1, 1)
							EndIf
						Else
							If ("M"$SubStr (cDelimit, 2))
								cBuffer	+=	SubStr (cDelimit, 1, 1)
							EndIf
						EndIf
					EndIf

				Next nCntFor

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetua a Gravacao da Linha                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cBuffer)
					FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
					If !lTSF .And. !lNfse .And. ( Ferror()!=0 )
						Help(" ",1,"NORMAERRO4") 
					ElseIf ( Ferror()!=0 )
						cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Incrementa o contador  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aEval(aContReg[1],{|x| &(x) })     	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³FIM DO PRIMEIRO NIVEL                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aAlias)>=2
					If !"XXX"$aAlias[2]
						dbSelectArea(aAlias[2])
					EndIf
					aArea2 := GetArea()

					aEval(aPre[2],{|x| &(x) })

					If !"XXX"$aAlias[2]

						aChvNivel[2] := Len (aChv)>=2 .And. !Empty (aChv[2])
						While ( !Eof() )  .And. Iif (aChvNivel[2], &(aChv[2]), .T.)
							cBuffer := ""
							aSkipChv	:=	{.T., .T., .F.}	//Controle para execucao do skip de cada nivel, este controle eh utilizado para quando a IN estah usando a clausula CHV.
							If (sfVldPReg (@aPreReg[2], @nHandle, lQuebralin))

								cDelimit	:=	AllTrim (aDelimit[2])
								If (Len (cDelimit)>1)
									If ("I"$SubStr (cDelimit, 2))
										cBuffer	+=	SubStr (cDelimit, 1, 1)
									EndIf
								EndIf

								For nCntFor := 1 To Len(aStru[2])
									bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[2]+"->"+aStru[2][nCntFor][1]+"|"+aConteudo[2][nCntFor],3,1) })
									BEGIN SEQUENCE
										uConteudo := &(aConteudo[2][nCntFor])
										Do Case
										Case ( aStru[2][nCntFor][2] == "N" )
											If ( uConteudo == Nil )
												uConteudo := 0
											EndIf

											If Empty (cMaskVlr) .Or. (aStru[2][nCntFor][4])==0
												uConteudo := NoRound(uConteudo*(10**(aStru[2][nCntFor][4])),aStru[2][nCntFor][4])
												If (!Empty (aDelimit[2]))
													cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[2][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[2][nCntFor][3])))
												Else
													cBuffer += StrZero(uConteudo,aStru[2][nCntFor][3])
												EndIf
											Else
												cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
											EndIf

										Case ( aStru[2][nCntFor][2] == "D" )
											If ( uConteudo == Nil )
												uConteudo := dDataBase
											EndIf
											cBuffer += PadR(Dtos(uConteudo),aStru[2][nCntFor][3])
										Case ( aStru[2][nCntFor][2] == "C" )
											If ( uConteudo == Nil )
												uConteudo := ""
											EndIf
											If (!Empty (aDelimit[2]))
												cBuffer += AllTrim(uConteudo)
											Else   
												If !lXML .And. aStru[2][nCntFor][3]<>0
													cBuffer += PadR(uConteudo,aStru[2][nCntFor][3])
												Else                                                
													cBuffer += uConteudo
												Endif
											EndIf

										EndCase
									END SEQUENCE
									ErrorBlock(bError)

									If (Len (cDelimit)>1)
										If (nCntFor==Len(aStru[2]))
											If ("F"$SubStr (cDelimit, 2))
												cBuffer	+=	SubStr (cDelimit, 1, 1)
											EndIf
										Else
											If ("M"$SubStr (cDelimit, 2))
												cBuffer	+=	SubStr (cDelimit, 1, 1)
											EndIf
										EndIf
									EndIf

								Next nCntFor
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Efetua a Gravacao da Linha  nivel 2                                     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty(cBuffer)
									FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
									If ( Ferror()!=0 )
										If lTSF .Or. lNfse
											cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)																   
										Else                    
										   	Help(" ",1,"NORMAERRO4")
										Endif   
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Incrementa o contador  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aEval(aContReg[2],{|x| &(x) })
							EndIf	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Inicio do nivel 3                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Len(aAlias)==3
								dbSelectArea(aAlias[3])
								aArea3 := GetArea()
								aEval(aPre[3],{|x| &(x) })

								aChvNivel[3] := Len (aChv)>=3 .And. !Empty (aChv[3])
								While ( !Eof() ) .And. Iif (aChvNivel[3], &(aChv[3]), .T.)
									cBuffer := ""
									aSkipChv	:=	{.T., .T., .T.}	//Controle para execucao do skip de cada nivel, este controle eh utilizado para quando a IN estah usando a clausula CHV.

									If (sfVldPReg (@aPreReg[3], @nHandle, lQuebralin))

										cDelimit	:=	AllTrim (aDelimit[3])
										If (Len (cDelimit)>1)
											If ("I"$SubStr (cDelimit, 2))
												cBuffer	+=	SubStr (cDelimit, 1, 1)
											EndIf
										EndIf

										For nCntFor := 1 To Len(aStru[3])
											bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[3]+"->"+aStru[3][nCntFor][1]+"|"+aConteudo[3][nCntFor],3,1) })
											BEGIN SEQUENCE
												uConteudo := &(aConteudo[3][nCntFor])
												Do Case
												Case ( aStru[3][nCntFor][2] == "N" )
													If ( uConteudo == Nil )
														uConteudo := 0
													EndIf

													If Empty (cMaskVlr) .Or. (aStru[3][nCntFor][4])==0
														uConteudo := NoRound(uConteudo*(10**(aStru[3][nCntFor][4])),aStru[3][nCntFor][4])
														If (!Empty (aDelimit[3]))
															cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[3][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[3][nCntFor][3])))
														Else
															cBuffer += StrZero(uConteudo,aStru[3][nCntFor][3])
														EndIf
													Else
														cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
													EndIf

												Case ( aStru[3][nCntFor][2] == "D" )
													If ( uConteudo == Nil )
														uConteudo := dDataBase
													EndIf
													cBuffer += PadR(Dtos(uConteudo),aStru[3][nCntFor][3])
												Case ( aStru[3][nCntFor][2] == "C" )
													If ( uConteudo == Nil )
														uConteudo := ""
													EndIf
													If (!Empty (aDelimit[3]))
														cBuffer += AllTrim(uConteudo)
													Else   
														If !lXML .And. aStru[3][nCntFor][3]<>0
															cBuffer += PadR(uConteudo,aStru[3][nCntFor][3])
														Else                                                
															cBuffer += uConteudo
														Endif
													EndIf
													
												EndCase
											END SEQUENCE
											ErrorBlock(bError)

											If (Len (cDelimit)>1)
												If (nCntFor==Len(aStru[3]))
													If ("F"$SubStr (cDelimit, 2))
														cBuffer	+=	SubStr (cDelimit, 1, 1)
													EndIf
												Else
													If ("M"$SubStr (cDelimit, 2))
														cBuffer	+=	SubStr (cDelimit, 1, 1)
													EndIf
												EndIf
											EndIf

										Next nCntFor
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Efetua a Gravacao da Linha  nivel 3                                     ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !Empty(cBuffer)
											FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
											If ( Ferror()!=0 )
												If lTSF .Or. lNfse
													cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
												Else	
													Help(" ",1,"NORMAERRO4")
												Endif
											EndIf
										EndIf
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Incrementa o contador  ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aEval(aContReg[3],{|x| &(x) })
									EndIf	
									aEval(aPosReg[3],{|x| &(x) })
									dbSelectArea(aAlias[3])
									dbSkip()
								EndDo
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Efetua o Pos-Processamento do nivel 3         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aEval(aPos[3],{|x| &(x) })
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Efetua o INI-Processamento do nivel 3         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aEval(aINI[3],{|x| ProcIni(x,nHAndle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,@aTrab,lNfse) })
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Esta condicao se deve quando estiver utilizando a clausula (CHV), pois nao devo       ³
								//³   retornar a Area salva antes do while, pois quando estiver utilizando esta clausula ³
								//³   e sair do while jah estarah posicionado no proximo registro que deverah ser pro-   ³
								//³   cessado novamente desde o nivel anterior, ou seja, neste caso, nivel 2.            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aChvNivel[3]
									RestArea(aArea3)
								EndIf
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Fim do nivel 3         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Len(aArq)>2
								If Len(aArq[3]) >= 1 .And. !Empty(aArq[3][1])
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Fecha e efetua a gravacao por bloco ³		
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									FClose(nHAndle)		
									// Caso seja necessario utilizar alguma informacao lancada em tempo de execucao no nome do arquivo, sera necessario gravar em um _aTotal
									If ("_ATOTAL["$Upper(aArq[3][1]))
										aArq[3][1]	:=	&(aArq[3][1])
									EndIf
									Ferase(cDir+aArq[3][1])
									__CopyFIle(cTrab,cDir+aArq[3][1])
									Aadd(aTrab,{cTrab,aArq[3][1]})
									cTrab	:= CriaTrab(,.F.)+".TXT"
									nHAndle  := FCreate(cTrab,0)
								EndIf						   	
							EndIf
							aEval(aPosReg[2],{|x| &(x) })
							dbSelectArea(aAlias[2])
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratamento para quando estiver utilizando a clausula (CHV) (condicao para o while).        ³
							//³OBS: Nao precisarei dar SKIP novamente quando sair do terceiro NIVEL que tenha             ³
							//³         o controle pela clausula (CHV), pois jah estara no proximo registro e nao deverah ³
							//³         dar o SKIP novamente e sim voltar e processar o registro atual desde o nivel ante-³
							//³         rior, ou seja, neste caso o nivel 2                                               ³
							//³OBS 2: A condicao abaixo determina NAO serah dado SKIP quando possuir a clausula CHV no    ³
							//³         bloco em execucao, quando o alias do nivel 2 for igual ao alias do nivel 3 e quan-³
							//³         estiver executado o while do nivel 3, onde jah foi executado o SKIP e a tabela jah³
							//³         jah saiu do while com SKIP.                                                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !(aChvNivel[3] .And. Len (aAlias)>=3 .And. aAlias[2]==aAlias[3] .And. aSkipChv[3])
								dbSkip()
							EndIf
						EndDo
					Else
						cBuffer := ""
						If (sfVldPReg(@aPreReg[2], @nHandle, lQuebralin))

							cDelimit	:=	AllTrim (aDelimit[2])
							If (Len (cDelimit)>1)
								If ("I"$SubStr (cDelimit, 2))
									cBuffer	+=	SubStr (cDelimit, 1, 1)
								EndIf
							EndIf				
							For nCntFor := 1 To Len(aStru[2])
								bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[2]+"->"+aStru[2][nCntFor][2]+"|"+aConteudo[2][nCntFor],3,1) })
								BEGIN SEQUENCE			
									uConteudo := &(aConteudo[2][nCntFor])			
									Do Case
									Case ( aStru[2][nCntFor][2] == "N" )					
										If ( uConteudo == Nil )
											uConteudo := 0
										EndIf

										If Empty (cMaskVlr) .Or. (aStru[2][nCntFor][4])==0
											uConteudo := NoRound(uConteudo*(10**(aStru[2][nCntFor][4])),aStru[2][nCntFor][4])
											If (!Empty (aDelimit[2]))
												cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[2][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[2][nCntFor][3])))
											Else
												cBuffer += StrZero(uConteudo,aStru[2][nCntFor][3])
											EndIf
										Else
											cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
										EndIf

									Case ( aStru[2][nCntFor][2] == "D" )
										If ( uConteudo == Nil )
											uConteudo := dDataBase
										EndIf
										cBuffer += PadR(Dtos(uConteudo),aStru[2][nCntFor][3])
									Case ( aStru[2][nCntFor][2] == "C" )
										If ( uConteudo == Nil )
											uConteudo := ""
										EndIf
										If (!Empty (aDelimit[2])) .Or. Empty(uConteudo)
											cBuffer += AllTrim (uConteudo)
										Else
											cBuffer += PadR(uConteudo,aStru[2][nCntFor][3])
										EndIf
									EndCase
								END SEQUENCE
								ErrorBlock(bError)

								If (Len(cDelimit)>1)
									If (nCntFor==Len(aStru[2]))
										If ("F"$SubStr (cDelimit, 2))
											cBuffer	+=	SubStr (cDelimit, 1, 1)
										EndIf
									Else
										If ("M"$SubStr (cDelimit, 2))
											cBuffer	+=	SubStr (cDelimit, 1, 1)
										EndIf
									EndIf
								EndIf

							Next nCntFor
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Efetua a Gravacao da Linha                                              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(cBuffer)
								If ("TOP"$aOrd[2])
									cBufferFim += "T"+cBuffer
								ElseIf ("BOT"$aOrd[2])
									cBufferFim += "B"+cBuffer
								Else                  
									FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
									If ( Ferror()!=0 )
										If lTSF .OR. lNfse
											cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
										Else	
											Help(" ",1,"NORMAERRO4")
										Endif
									EndIf
								EndIf
							EndIf
							aEval(aPosReg[2],{|x| &(x) })
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Incrementa o contador  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aEval(aContReg[2],{|x| &(x) })     			
						EndIf					
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetua o Pos-Processamento do nivel 2         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aEval(aPos[2],{|x| &(x) })
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetua o INI-Processamento do nivel 2         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aEval(aINI[2],{|x| ProcIni(x,nHAndle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,@aTrab,lNfse) })
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Esta condicao se deve quando estiver utilizando a clausula (CHV), pois nao devo       ³
					//³   retornar a Area salva antes do while, pois quando estiver utilizando esta clausula ³
					//³   e sair do while jah estarah posicionado no proximo registro que deverah ser pro-   ³
					//³   cessado novamente desde o nivel anterior, ou seja, neste caso, nivel 1.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(aChvNivel[2])
						RestArea(aArea2)
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Fim do nivel 2         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aArq)>=2
					If Len(aArq[2]) >= 1 .And. !Empty(aArq[2][1])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Fecha e efetua a gravacao por bloco ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FClose(nHAndle)
						If ("_ATOTAL["$Upper(aArq[2][1]))
							aArq[2][1]	:=	&(aArq[2][1])
						EndIf		
						Ferase(cDir+aArq[2][1])
						__CopyFIle(cTrab,cDir+aArq[2][1])
						Aadd(aTrab,{cTrab,aArq[2][1]})
						cTrab	:= CriaTrab(,.F.)+".TXT"
						nHAndle  := FCreate(cTrab,0)
					EndIf				   	
				EndIf
				aEval(aPosReg[1],{|x| &(x) })	
			EndIf

			dbSelectArea(aAlias[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para quando estiver utilizando a clausula (CHV) (condicao para o while).        ³
			//³OBS: Nao precisarei dar SKIP novamente quando sair do terceiro/segundo NIVEL que tenha     ³
			//³         o controle pela clausula (CHV), pois jah estarah no proximo registro e nao deverah³
			//³         dar o SKIP novamente e sim voltar e processar o registro atual desde o nivel ante-³
			//³         rior, ou seja, neste caso o nivel 1                                               ³
			//³OBS 2: A condicao abaixo determina NAO serah dado SKIP quando possuir a clausula CHV no    ³
			//³         bloco em execucao, quando o alias do nivel 1 for igual ao alias do nivel 2 e quan-³
			//³         estiver executado o while do nivel 2, onde jah foi executado o SKIP e a tabela jah³
			//³         jah saiu do while com SKIP.                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(aChvNivel[2] .And. Len (aAlias)>=2 .And. aAlias[1]==aAlias[2] .And. aSkipChv[2])
				dbSkip()
			EndIf
		EndDo
	Else
		cBuffer := ""
		If (sfVldPReg(@aPreReg[1], @nHandle, lQuebralin))

			cDelimit	:=	AllTrim (aDelimit[1])
			If (Len (cDelimit)>1)
				If ("I"$SubStr (cDelimit, 2))
					cBuffer	+=	SubStr (cDelimit, 1, 1)
				EndIf
			EndIf

			For nCntFor := 1 To Len(aStru[1])
				bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[1]+"->"+aStru[1][nCntFor][1]+"|"+aConteudo[1][nCntFor],3,1) })
				BEGIN SEQUENCE			
					uConteudo := &(aConteudo[1][nCntFor])			
					Do Case
					Case ( aStru[1][nCntFor][2] == "N" )					
						If ( uConteudo == Nil )
							uConteudo := 0
						EndIf

						If Empty (cMaskVlr) .Or. (aStru[1][nCntFor][4])==0
							uConteudo := NoRound(uConteudo*(10**(aStru[1][nCntFor][4])),aStru[1][nCntFor][4])
							If (!Empty (aDelimit[1]))
								cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[1][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[1][nCntFor][3])))
							Else
								cBuffer += StrZero(uConteudo,aStru[1][nCntFor][3])
							EndIf
						Else
							cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
						EndIf

					Case ( aStru[1][nCntFor][2] == "D" )
						If ( uConteudo == Nil )
							uConteudo := dDataBase
						EndIf
						cBuffer += PadR(Dtos(uConteudo),aStru[1][nCntFor][3])
					Case ( aStru[1][nCntFor][2] == "C" )
						If ( uConteudo == Nil )
							uConteudo := ""
						EndIf
						
						If (!Empty (aDelimit[1]))
							cBuffer += AllTrim (uConteudo)
						Else
							If !lXML .And. aStru[1][nCntFor][3]<>0
								cBuffer += PadR(uConteudo,aStru[1][nCntFor][3])
							Else                                                
								cBuffer += uConteudo
							Endif
						EndIf
					EndCase
				END SEQUENCE
				ErrorBlock(bError)

				If (Len(cDelimit)>1)
					If (nCntFor==Len(aStru[1]))
						If ("F"$SubStr (cDelimit, 2))
							cBuffer	+=	SubStr (cDelimit, 1, 1)
						EndIf
					Else
						If ("M"$SubStr (cDelimit, 2))
							cBuffer	+=	SubStr (cDelimit, 1, 1)
						EndIf
					EndIf
				EndIf

			Next nCntFor
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a Gravacao da Linha                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cBuffer)
				If ("TOP"$aOrd[1])
					cBufferFim += "T"+cBuffer
				ElseIf ("BOT"$aOrd[1])
					cBufferFim += "B"+cBuffer
				Else
					FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
					If ( Ferror()!=0 )
						If lTSF .OR. lNfse
							cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
						Else	
							Help(" ",1,"NORMAERRO4")
						Endif
					EndIf
				EndIf
			EndIf
			aEval(aPosReg[1],{|x| &(x) })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Incrementa o contador  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aContReg[1],{|x| &(x) })     			
		EndIf
	EndIf
	If lTSF .OR. lNfse
		Exit
	Else
		SM0->(DbSkip ())
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTSF .And. !lNfse
	RestArea(aAreaSm0)
    cFilAnt	:=	cFlAnte
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua o Pos-Processamento                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aPos[1],{|x| &(x) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua o INI-Processamento do nivel 1         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aINI[1],{|x| ProcIni(x,@nHAndle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,@aTrab,lNfse) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura demais areas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea1)
RestArea(aArea)

If !lTSF .And. !lNfse .And. (cFilDe#cFilAte)
	GeroConso (nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
	TrbConso (2,,,, aArqNew)
EndIf   
If Len(aArq) >= 1
	If Len(aArq[1]) >= 1  .And. !Empty(aArq[1][1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha e efetua a gravacao por bloco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FClose(nHAndle)
		// Caso seja necessario utilizar alguma informacao lancada em tempo de execucao no nome do arquivo, sera necessario gravar em um _aTotal
		If ("_ATOTAL["$Upper(aArq[1][1]))
			aArq[1][1]	:=	&(aArq[1][1])
		EndIf		
		Ferase(cDir+aArq[1][1])
		__CopyFile(cTrab,cDir+aArq[1][1])
		Aadd(aTrab,{cTrab,aArq[1][1]})
		cTrab	:= CriaTrab(,.F.)+".TXT"
		nHAndle  := FCreate(cTrab,0)
	EndIf	
EndIf
Return(cBufferFim)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ProcIni   ³ Autor ³ Eduardo Jose Zanardo   ³ Data ³03/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a Clausula INI                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function ProcIni(cIniName,nHAndle,cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,aTrab,lNfse)
Local aNorma := {}

Default aProcFil := {.F.,cFilAnt}
Default  aTrab	 :=	{}

If ( !Empty(cIniName) )
	aNorma := ReadNorma(cIniName)                                          
	aEval(aNorma,{|x| RegNorma(x,@nHandle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,@aTrab,lTSF,lQuebralin,lNfse)})
EndIf

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfVldPReg ³ Autor ³ Gustavo G. Rueda      ³ Data ³26.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para validar o (PREREG) dos INI's, podendo ³±±
±±º          ³inserir uma condicao ou uma funcao retornando uma string.   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL: .T./.F.                                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array contendo todos PreReg                          ³±±
±±³          ³ExpN2: Controle                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function sfVldPReg (aPreReg, nHandle, lQuebralin)
Local	lRet	:=	.T.
Local	nInd	:=	0
Local	aArea	:=	GetArea ()
Local	xVar
Local   cVar
//
If (Len (aPreReg)<>0)
	For nInd := 1 To Len (aPreReg)
		cVar	:= aPreReg[nInd]
		xVar	:=	&(aPreReg[nInd])
		If (ValType(xVar)=="C") .And. !":="$cVar
			FWrite (nHandle, xVar+Iif(lQuebralin,Chr(13)+Chr(10),""))
			lRet	:=	.T.
		Else
			If (ValType (xVar)=="L")
				If !xVar
					lRet	:=	xVar
					Exit
				EndIf
			Else
				lRet	:=	.T.
			EndIf
		EndIf
	Next nInd
EndIf
RestArea (aArea)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ImpSpool  ³ Autor ³ Gustavo G. Rueda      ³ Data ³26.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada atraves dos ini's para impressao em spool  ³±±
±±º          ³de informacoes sob um layout basico.                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL: lRet - .T./.F.                                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC: cNorma - Arquivo INI de configuracao.                 ³±±
±±³          ³ExpC: cDest - Nome do arquivo txt gerado                    ³±±
±±³          ³ExpC: cDir - Nome do diretorio onde o txt foi gerado.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBS       ³Para impressao deste relatório e necessario que as clausulas³±±
±±³          ³abaixo estejam configuradas conforme seguem:                ³±±
±±³          ³1 - Da mesma forma que o (PRE) deve ser criado uma clausula ³±±
±±³          ³chamada (IMP) onde devera conter um array com a primeira po-³±±
±±³          ³sicao indicando se o registro deve ser impresso (.T.) ou nao³±±
±±³          ³(.F.), caso esta clausula nao exista sera considerado .F. e ³±±
±±³          ³nenhum campo do registro sera impresso. A segunda e a ter-  ³±±
±±³          ³ceira posicao deste array definido pela clausula (IMP)      ³±±
±±³          ³he utilizada para indicar a coordenada do                   ³±±
±±³          ³campo chave de cada registro, onde a segunda posicao indica ³±±
±±³          ³a posicao inicial e a terceira posicao indica a qtd de len  ³±±
±±³          ³para este campo. A quarta posicao indica o nome do campo    ³±±
±±³          ³digitado no ini que indique o campo chave do registro. Ex:  ³±±
±±³          ³(IMP){.T.,1,2,"SEQ01"}                                      ³±±
±±³          ³2 - Quando um campo for impresso deve ter um label de 20 ca-|±±
±±³          ³racteres contando com as aspas logo apos a qtd de casas de- ³±±
±±³          ³cimais, em seguida deve se deixar um espaco em branco e in- ³±±
±±³          ³dicar novamente entre aspas com o tamanho de 20 caracteres  ³±±
±±³          ³a PICTURE a ser utilizada para a coluna em questao, em se-  ³±±
±±³          ³guida deve-se deixar outro espaco em branco e idicar o      ³±±
±±³          ³conteudo do campo, conforme atualmente utilizado. Ex:       ³±±
±±³          ³SEQ01      C 002 0 "TP             " "@!             " "TO" ³±±
±±³          ³3 - Para a impressao do relatorio, a qtd de len para uma    ³±±
±±³          ³coluna he a mesma definido no ini. No exemplo acima, o len  ³±±
±±³          ³da coluna para o campo SEQ01 he de 2 caracteres, portanto,  ³±±
±±³          ³o label da coluna deve respeitar esta regra.                ³±±
±±³          ³4 - Ao final do ini a ser utilizada esta funcao, deve-se    ³±±
±±³          ³inserir a seguinte chamada de funcao. Ex:                   ³±±
±±³          ³ImpSpool (MV_PAR03, MV_PAR04, MV_PAR05), onde:              ³±±
±±³          ³MV_PAR03 = Arquivo ini de configuracao.                     ³±±
±±³          ³MV_PAR04 = Arquivo txt gerado atraves do ini.               ³±±
±±³          ³MV_PAR05 = Diretorio destino do arquivo txt gerado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpSpool (cNorma, cDest, cDir, aArqSpool,aTrab)
Local 		aArea		:=	GetArea ()
Local		lRet		:=	.T.
Local 		cTitulo  	:= 	STR0010
Local 		cDesc1  	:= 	STR0009
Local 		cDesc2  	:= 	""
Local 		cDesc3  	:= 	""
Local 		wnrel   	:= 	"FISR099"
Local 		NomeProg	:= 	"FISR099"

Private 	Tamanho 	:= 	"G" 	// P/M/G
Private 	Limite  	:= 	220 	// 80/132/220
Private 	lEnd    	:= 	.F.		// Controle de cancelamento do relatorio
Private 	m_pag   	:= 	1  		// Contador de Paginas
Private	    nLastKey	:= 	0  		// Controla o cancelamento da SetPrint e SetDefault
Private 	aReturn 	:= { STR0010, 1,STR0011, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"   

Default     aTrab		:=	{}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel	:=	SetPrint ("", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., Tamanho,, .F.)
//
If (nLastKey==27)
	Return (lRet)
Endif
//
SetDefault (aReturn, "")
//
If (nLastKey==27)
	Return (lRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preparacao do inicio de processamento do arquivo pre-formatado          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus ({|lEnd| GeraSpool (cNorma, cDest, cDir, aArqSpool,aTrab)}, cTitulo)
//
If (aReturn[5]==1)
	Set Printer To
	ourspool(wnrel)
Endif
MS_FLUSH()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea (aArea)
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraSpool ³ Autor ³ Gustavo G. Rueda      ³ Data ³26.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL: lRet - .T./.F.                                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC: cNorma - Arquivo INI de configuracao.                 ³±±
±±³          ³ExpC: cDest - Nome do arquivo txt gerado                    ³±±
±±³          ³ExpC: cDir - Nome do diretorio onde o txt foi gerado.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraSpool (cNorma, cDest, cDir, aArqSpool,aTrab)
Local	lRet		:=	.T.
Local	nTamNorma	:=	0
Local	nTamTxt		:=	0
Local	nReadNorma	:=	0
Local	nReadTxt	:=	0
Local	nHandleNorma:=	0
Local	nHandleTxt	:=	0
Local	nByteNorma	:=	1
Local	nByteTxt	:=	1
Local	cTitulo		:=	""
Local	lFirst		:=	.T.
Local	aColImp		:=	{}
Local	aImprime	:=	{.F.,,,,.F.}	//1-Indica se imprime (.T. ou .F.), 2-Posicao inicial chave registro, 3-Len do indentificador, 4-Nome do campo na estrutura do ini, 5-Analitico(.f.) ou Sintetico (.t.)
Local	aLidosNorma	:=	{}
Local	aLidosTxt	:=	{}
Local	cLinhaNorma	:=	""
Local	cLinhaTxt	:=	""
Local	cLinha		:=	""
Local	cLinha2		:=	""
Local	cChaveNorma	:=	""
Local	cChaveTxt	:=	""
Local	nInd		:=	1
Local	aColuna		:=	{}
Local	nLin		:=	99
Local	nTipo		:=	18
Local	nPosInicial	:=	1
Local	nIniCampo	:=	0
Local	nLenCampo	:=	0
Local	cDetCampo	:=	""
Local	aDetImp		:=	{}
Local	cTipoCampo	:=	""
Local	cMaskCampo	:=	""
Local	cFundo		:=	""
Local	cDivisao	:=	""
Local	lNumber		:=	.T.
Local	lGerou		:=	.T.
Local	cBarra		:=	""
Local	nLinPag		:=	60
Local	lLinha		:=	.T.
Local	cLegenda	:=	""
Local	cDecimal	:=	""
Local	aCampos		:=	{}
Local	nPosCampos	:=	0
Local	aArqSpoolX	:=	aArqSpool
Local	nI			:=	0
Local	lLoop		:=	.F.
Local	lVariosArq	:=	Len (aArqSpoolX)>0
Local	cDelimitador:=	""
Local	nCmpDel		:=	0
Local	lSintetico	:=	aImprime[5]
Local	nLenCmp		:=	0
Local	cArqBloco	:=	""	//Nome do arquivo para controle, pois com este nome me certifico de que o arquivo TXT

Default aTrab		:=	{}

//  gerado aberto no momento se refere a IN ou a um bloco dela (no caso de varios arquivos. Ex: NORMA086/SINCONF)
//
If (File(cNorma)) .And. ((File(cDir+cDest)) .Or. lVariosArq)
	nHandleNorma	:=	FOpen (cNorma)
	nTamNorma		:=	FSeek (nHandleNorma, 0, 2)
	FSeek (nHandleNorma, 0, 0)
	nReadNorma 	:= 	FRead (nHandleNorma, @cLinha, nTamNorma)
	// 
	lVariosArq	:=	Len(aArqSpoolX)>1
	If !lVariosArq  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quando for uma IN para um arquivo TXT gerado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqBloco	:=	aArqSpoolX[1]
	EndIf
	//
	For nI := 1 To Len (aArqSpoolX)
		FT_FUse(aArqSpoolX[nI])
		FT_FGotop()
		//
		While nByteNorma<=nTamNorma .And. ( !FT_FEof() )
			aLidosNorma	:=	LerLinha (cLinha, nByteNorma)	//Funcao utilizada para ler registro a registro do txt gerado.
			cLinhaNorma	:=	Subs( aLidosNorma[1], 1 , Len(Alltrim( aLidosNorma[1] ))-1)
			nByteNorma	:=	aLidosNorma[2]
			//
			If (lVariosArq)	//Somente Para inis que utilizam a clausula (ARQ)
				If (AllTrim (SubStr (cLinhaNorma, 1, 1))$"[{")
					lLoop	:=	.F.
				EndIf
				//
				If (lLoop)
					Loop
				EndIf
			EndIf
			//
			Do Case
			Case (AllTrim (SubStr (cLinhaNorma, 1, 1))$"[{") .Or. nByteNorma>nTamNorma
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Impressao efetuada a cada bloco ou quando o proximo while for falso.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (aImprime[1]) .And. !(lFirst) .And. (aArqSpoolX[nI]$cArqBloco)
					cFundo		:=	""
					cDivisao	:=	""
					cBarra		:=	""
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste for monta-se o nome das colunas e o fundo para ser utilizado pela funcao FMTLIN³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nInd := 1 To Len (aColImp)
						aAdd (aColuna, AllTrim (SubStr (aColImp[nInd][7], 1, aColImp[nInd][4])))
						//
						cFundo		+=	"|"+Replicate ("#", aColImp[nInd][4])
						cDivisao	+=	"+"+Replicate ("-", aColImp[nInd][4])
					Next nInd
					cFundo		+=	"|"
					cDivisao	+=	"+"
					cBarra		:=	Replicate ("-", Len (cFundo))
					//
					While ( !FT_FEof() )
						//
						lGerou	:=	.F.
						lNumber	:=	.F.
						If ValType (cChaveNorma)=="N"
							lNumber		:=	.T.
							cChaveNorma	:=	StrZero (cChaveNorma, Len (AllTrim (cChaveTxt)))
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Padronizo a comparacao, pois pode ocorrer de em algum registro o len do campo chave for diferente de um outro registro.  ³
						//³Ex: Por default, na maioria dos registros os campos chaves possuem 2 caracteres mais em um registro em especifico,       ³
						//³o campo chave he formado por 3 caracteres, portanto na proxima passagem por esta linha, quando a qtd de caracteres for 2,³
						//³tera de ser transformada para 2 caracteres antes da comparacao. O exemplo he de 2, mas pode ser a qualquer qtd.          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If  cChaveNorma==Left (cChaveTxt, Len (AllTrim (cChaveNorma)))
							cChaveTxt	:=	Left (cChaveTxt, Len (AllTrim (cChaveNorma)))
						EndIf
						//
						If cChaveNorma<>cChaveTxt
							cLinhaTxt	:=	FT_FReadLn()

							If (lVariosArq)	//Se o ini gerar mais de um arquivo aceito todos os registros contidos no arquivo como o mesmo bloco.
								cChaveTxt	:=	cChaveNorma		//Somente Para inis que utilizam a clausula (ARQ)
							Else
								cChaveTxt	:=	SubStr (cLinhaTxt, aImprime[2], aImprime[3])
							EndIf
							//
							If lNumber
								cChaveNorma	:=	StrZero (Val (cChaveNorma), Len (AllTrim (cChaveTxt)))
							EndIf
						EndIf
						//
						If (cChaveNorma==cChaveTxt)
							lGerou	:=	.T.
							//
							If nLin>=nLinPag
								nLin	:=	cabec (STR0008, "", "", "FISA066", "G", nTipo)
							EndIf
							//
							nLin++
							FmtLin ({cTitulo}, STR0007,,"@X", @nLin)
							FmtLin ({}, cBarra,,, @nLin)
							FmtLin (aColuna, cFundo,,"@X", @nLin)
							FmtLin ({}, cDivisao,,, @nLin)
							//
							lLinha	:=	.F.
							//
							While ( !FT_FEof() ) .And. ( cChaveNorma == cChaveTxt )
								//Soh zero quando for analitico pois nao precisarah acumular (no caso do sintetico)
								If !lSintetico
									aDetImp	:=	{}
								EndIf
								//
								If nLin>=nLinPag
									If (lLinha)
										lLinha	:=	.F.
										FmtLin ({}, cBarra,,, @nLin)
									EndIf
									FmtLin ({}, STR0013,,, @nLin)
									nLin	:=	cabec (STR0008, "", "", "FISR099", "G", nTipo)
									nLin++
									FmtLin ({cTitulo}, STR0007,,"@X", @nLin)
									FmtLin ({}, cBarra,,, @nLin)
								EndIf
								//
								For nInd := 1 To Len (aColImp)
									cTipoCampo	:=	aColImp[nInd][2]
									nIniCampo	:=	aColImp[nInd][3]
									nLenCampo	:=	aColImp[nInd][4]
									nDecimal	:=	aColImp[nInd][5]
									//Quando for analitico gero linha a linha do arquivo texto
									If !lSintetico
										If Empty (cDelimitador)
											If ("N"$cTipoCampo)
												If (nDecimal<>0)
													cMaskCampo	:=	A950Tm (Val (SubStr (cLinhaTxt, nIniCampo, nLenCampo)), nLenCampo, nDecimal)
													cDetCampo	:=	IntToDec (SubStr (cLinhaTxt, nIniCampo, nLenCampo), cMaskCampo, nDecimal)
												Else
													cDetCampo	:=	SubStr (cLinhaTxt, nIniCampo, nLenCampo)
												EndIf
											ElseIf ("C"$cTipoCampo)
												cMaskCampo	:=	A950Tm (SubStr (cLinhaTxt, nIniCampo, nLenCampo), nLenCampo, nDecimal)
												cDetCampo	:=	Transform (SubStr (cLinhaTxt, nIniCampo, nLenCampo), cMaskCampo)
											ElseIf ("D"$cTipoCampo)
												cDetCampo	:=	StrZero (Day(StoD (SubStr (cLinhaTxt, nIniCampo, nLenCampo))),2)+"/"+StrZero (Month(StoD (SubStr (cLinhaTxt, nIniCampo, nLenCampo))),2)+"/"+Right (StrZero (Year(StoD (SubStr (cLinhaTxt, nIniCampo, nLenCampo))),4), 2)
											EndIf
										Else
											nCmpDel	:=	aColImp[nInd][8]
											cDetCampo	:=	RetCmpDel (cLinhaTxt, cDelimitador, nCmpDel)
										EndIf
										//
										aAdd (aDetImp, cDetCampo)

										//Se for sintetico soh gero o totalizador
									Else
										cDetCampo	:=	Space (nLenCampo)
										//Monto o totalizador somente para campos numericos
										If ("N"$cTipoCampo)
											//Este 6 define que somente irei pegar campo que armazenarah valor a ser
											//	totalizado. Ex: Aliquota possui no maximo 6 (999.99)
											If (nDecimal<>0) .And. (nLenCampo>6)
												cMaskCampo	:=	A950Tm (Val (SubStr (cLinhaTxt, nIniCampo, nLenCampo)), nLenCampo, nDecimal)
												cDetCampo	:=	SubStr (cLinhaTxt, nIniCampo, nLenCampo)
												//
												If (Len (aDetImp)<Len (aColImp))//Para a primeira linha do txt inicializo o array com um add, nas proximas vou acumulando
													aAdd (aDetImp, {Val (cDetCampo), cMaskCampo, nDecimal})
												Else
													aDetImp[nInd][1]	+=	Val (cDetCampo)
												EndIf
											EndIf
										EndIf
										//
										//Este add somente serah executado para a primeira linha quando o conteudo da
										//	variavel cDetCampo estiver em branco.
										If Empty (cDetCampo) .And. (Len (aDetImp)<Len (aColImp))
											aAdd (aDetImp, {cDetCampo, "", 0})
										EndIf
									EndIf
								Next nInd
								//
								//Somente gero linha a linha quando for analitico
								If !lSintetico
									FmtLin (aDetImp, cFundo,,, @nLin)
								EndIf
								lLinha	:=	.T.
								//
								FT_FSkip()
								cLinhaTxt := FT_FReadLn()
								//
								If (lVariosArq)	//Se o ini gerar mais de um arquivo aceito todos os registros contidos no arquivo como o mesmo bloco.
									cChaveTxt	:=	cChaveNorma		//Somente Para inis que utilizam a clausula (ARQ)
								Else
									cChaveTxt	:=	SubStr (cLinhaTxt, aImprime[2], aImprime[3])
								EndIf
							EndDo
							//
							If (cChaveNorma<>cChaveTxt)
								Exit
							EndIf
						Else
							FT_FSkip()
							cLinhaTxt := FT_FReadLn()
							//
							If (lVariosArq)	//Se o ini gerar mais de um arquivo aceito todos os registros contidos no arquivo como o mesmo bloco.
								cChaveTxt	:=	cChaveNorma		//Somente Para inis que utilizam a clausula (ARQ)
							Else
								cChaveTxt	:=	SubStr (cLinhaTxt, aImprime[2], aImprime[3])
							EndIf
						EndIf
					EndDo
					//
					If (lGerou)
						//
						//Somente gero quando for sintetico pois trata-se do totalizador de cada registro
						If lSintetico
							For nInd := 1 To Len (aDetImp)
								cDetCampo	:=	aDetImp[nInd][1]
								If !Empty (cDetCampo)
									cDetCampo	:=	IntToDec (aDetImp[nInd][1], aDetImp[nInd][2], aDetImp[nInd][3])
								EndIf
								aDetImp[nInd]	:=	cDetCampo
							Next nInd
							FmtLin (aDetImp, cFundo,,, @nLin)
						EndIf
						FmtLin ({}, cBarra,,, @nLin)
						If !Empty (cLegenda)
							FmtLin ({cLegenda}, STR0014,,"@X", @nLin)
							cLegenda	:=	""
						EndIf
					Else
						FT_FGotop()
					EndIf
				EndIf
				//
				cTitulo		:=	AllTrim (SubStr (cLinhaNorma, 5, At ("]", cLinhaNorma)-5))
				lFirst		:=	.F.
				aImprime	:=	{.F.,,,,.F.}
				aColImp		:=	{}
				aColuna		:=	{}
				nPosInicial	:=	1
				cChaveNorma	:=	""
				aCampos		:=	{}
				cDelimitador:= 	""
				nCmpDel		:=	0
				aDetImp		:=	{}
				//
				If (lVariosArq)	//Somente para ini com clausula (ARQ)
					cChaveTxt	:=	""
				EndIf
				//
			Case "(DEL)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				cDelimitador:=	SubStr (AllTrim (SubStr (cLinhaNorma, 6)), 1, 1)

			Case "(ARQ)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				cArqBloco	:=	AllTrim (SubStr (cLinhaNorma, 6))
				If ("&"$cArqBloco)
					cArqBloco	:=	&(AllTrim(SubStr (cArqBloco, At ("&", cArqBloco)+1)))
				EndIf
				cArqBloco	:=	If(aScan(aTrab,{|ax|AllTrim(aX[2])$AllTrim(cArqBloco)})>0,aTrab[aScan(aTrab,{|ax|AllTrim(aX[2])$AllTrim(cArqBloco)}),1],cArqBloco)
				cArqBloco	:=	AllTrim(cArqBloco)

				If !(aArqSpoolX[nI]$cArqBloco)
					lLoop	:=	.T.
				EndIf

			Case "(IMP)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				aImprime	:=	&(AllTrim (SubStr (cLinhaNorma, 6)))
				lSintetico 	:= 	Iif (Len (aImprime)<>5, .F., &(aImprime[5]))

			Case "(LEG)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				cLegenda	:=	&(AllTrim (SubStr (cLinhaNorma, 6)))

			Case "(CMP)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				aCampos	:=	&(AllTrim (SubStr (cLinhaNorma, 6)))

			Case !(AllTrim (SubStr (cLinhaNorma, 1, 1))$"(") .And. (aImprime[1])
				//
				nCmpDel++
				nPosCampos	:=	aScan (aCampos, {|aX| aX[1]==AllTrim (SubStr (cLinhaNorma, 01, 10))})
				//
				If nPosCampos<>0
					nLenCmp	:=	Iif (Len (aCampos[nPosCampos])==3, aCampos[nPosCampos][3], Val(SubStr (cLinhaNorma, 14, 3)))
					aAdd (aColImp, {AllTrim (SubStr (cLinhaNorma, 01, 10)), SubStr (cLinhaNorma, 12, 01), nPosInicial, nLenCmp, Val (SubStr (cLinhaNorma, 18, 01)), SubStr (cLinhaNorma, 20), Iif (Empty (aCampos[nPosCampos][2]), aCampos[nPosCampos][1], aCampos[nPosCampos][2]), nCmpDel})
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Este if trata o codigo de identificacao de cada registro como fixo no proprio ini para³
				//³posterior associacao com o txt gerado.                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aImprime[1] .And. (AllTrim (SubStr (cLinhaNorma, 01, 10))$aImprime[4]) .And. !(lVariosArq)
					cChaveNorma	:=	&(AllTrim (SubStr (cLinhaNorma, 20)))

				ElseIf (lVariosArq)	//Somente Para inis que utilizam a clausula (ARQ)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o ini gerar varios arquivos como por exemplo a NORMA086, essume-se que cada arquivo identifica um registro  e o codigo³
					//³de identificacao de cada registro e assumido como ALL.                                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cChaveNorma	:=	"ALL"
				EndIf
				//
				nPosInicial	+=	Val(SubStr (cLinhaNorma, 14, 3))
			EndCase
			//
		EndDo
		//
		FT_FUse()
	Next nI
	//
	FClose (nHandleNorma)
	FT_FUse()
EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LerLinha  ³ Autor ³ Gustavo G. Rueda      ³ Data ³28.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para ler linha-a-linha de um arquivo texto.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA[1]: String lida                                        ³±±
±±³          ³ExpA[2]: Bytes lidos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC: cLinha - Buffer do arquivo a ser processado           ³±±
±±³          ³ExpN: nInicio - Byte inicial para leitura                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FISR099        |                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LerLinha (cLinha, nInicio)
Local 	cString 	:= 	""
Local	nLidos 		:=	nInicio
//
While .T.
	cChar 		:= 	SubStr (cLinha, nLidos, 1)
	cString		+=	cChar
	nLidos++
	//
	If cChar==chr (10)
		cString := cString
		Exit
	EndIf
EndDo
Return {cString, nLidos}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A950Tm    ³ Autor ³ Gustavo G. Rueda      ³ Data ³28.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para retornar a Picture para um numero ou  ³±±
±±³          ³caracter.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC: cRetPic - Picture formada no processamento. No caso   ³±±
±±³          ³de Numero sera retornado @E.... e no caso de caracter @!.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpU: uCampo - Conteudo de um campo a ser processado        ³±±
±±³          ³ExpN: nLen - Numero de bytes para formatar a picture        ³±±
±±³          ³ExpN: nDec - Numero de bytes para a casa decimal            ³±±
±±³          ³ExpN: lEstrang - Nao considera nenhuma picture para casos   ³±±
±±³          ³estrangeiros.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FISR099        |                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A950Tm (uCampo, nLen, nDec, lEstrang)
Local	cPic		:=	""
Local	cRetPic		:=	""
Local	nInicio		:=	0
//
lEstrang := Iif (lEstrang==Nil, .F., lEstrang)
//
If nDec==NIL
	nDec	:=	GetMv("mv_cent")
EndIf
//
If Valtype (uCampo)=="N"
	cPic := Iif (GetMv("mv_milhar"), "999,999,999,999,999,999,999,999", "9999999999999999999999999999999")+Iif (nDec>0, ("."+Replicate ("9", nDec)),"")
ElseIf Valtype (uCampo)=="C"
	cRetPic := "@!"
EndIf
//
nInicio	:=	Len (cPic)-nLen
nInicio++
//
While (nInicio<=Len (cPic)) .And. Valtype (uCampo)=="N"
	If !(nInicio==Len (cPic)-nLen .And. SubStr (cPic, nInicio, 1)$".,")
		cRetPic	+=		SubStr (cPic, nInicio, 1)
	EndIf
	//
	nInicio++
End
//
If !(lEstrang) .And. !"@!"$cRetPic
	cRetPic	:=	"@E "+cRetPic
EndIf
Return (cRetPic)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IntToDec  ³ Autor ³Gustavo G. Rueda       ³ Data ³28.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para conversao dos valores gravados nos arquivos     ³±±
±±³          ³ textos conforme instrucao normativa. Especificamente para  ³±±
±±³          ³ numeros decimais.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> nDec - numero convertido.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cInt - Numerono formato de caracter a ser convertido³±±
±±³          ³ExpC -> cMask - Mascara a ser utilizada apos conversao.     ³±±
±±³          ³ExpN -> nDec - Qtd de casas decimais.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FISR099        |                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IntToDec (cInt, cMask, nDec)
Local		cDec	:=	""
//
nDec := Iif (nDec==Nil, 2, nDec)
If (ValType (cInt)$"N")
	cInt	:=	Str (cInt)
EndIf
//
cDec	:=	Transform (Val (Left (AllTrim (cInt), Len (AllTrim (cInt))-nDec)+"."+Right (AllTrim (cInt), nDec)), cMask)
Return (cDec)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |TrbConso  ºAutor  ³Gustavo             º Data ³  05/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Crio TRB conforme estrutura do registro contida no INI.     º±±
±±º          ³Esta rotina eh somente utilizado para inis que possuem a    º±±
±±º          ³ clausula (CONSOLIDADO), para que seja processado o bloco   º±±
±±º          ³ para o range de filiais apontado nesta clausula.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TrbConso (nNewDel, nNivel, aStru, cChaveCons, aArqNew)
Local	lRet		:=	.T.
Local	nX			:=	0
Local	aStruXZ		:=	{}
Local	cChave		:=	""
Local	cCampo		:=	""
Local	cTipo		:=	""
Local	nTamanho	:=	0
Local	nDecimal	:=	0
Local	cNomeTrb	:=	""
Local aChave := {}
//
If (nNewDel==1)
	cNomeTrb	:=	"XZ"+StrZero (nNivel, 1, 0)
	//
	For nX := 1 To Len (aStru[nNivel])
		cCampo		:=	AllTrim (aStru[nNivel][nX][1])
		cTipo		:=	AllTrim (aStru[nNivel][nX][2])
		nTamanho	:=	aStru[nNivel][nX][3]
		nDecimal	:=	aStru[nNivel][nX][4]
		aAdd (aStruXZ, {cCampo, cTipo, nTamanho, nDecimal})
		//
		If (AllTrim (cCampo)$cChaveCons)
			
			AADD(aChave,ALLTRIM(cCampo))
			
		EndIf
		
	Next nX
	
	If Len(aChave) == 0
		AADD(aChave,ALLTRIM(aStru[nNivel][1][1]) ) //primer campo
	EndIf

	cArq	:= criatrab(nil,.F.)
	oTmpTable := FWTemporaryTable():New(cNomeTrb)
	oTmpTable:SetFields( aStruXZ ) 
	//crea indice
	oTmpTable:AddIndex('T1ORD', aChave)
	//Creacion de la tabla
	oTmpTable:Create()
	aArqNew	:=	{cNomeTrb, cArq}
Else
	dbSelectArea(aArqNew[1])
	dbCloseArea()
	If oTmpTable <> Nil  
		oTmpTable:Delete() 
		oTmpTable := Nil 
	Endif
	
	aArqNew	:=	{}
EndIf
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |ConsoFil  ºAutor  ³Gustavo             º Data ³  05/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alimento o TRB gerado pela funcao TrbConso acumulando con-  º±±
±±º          ³ a chave apontada na clausula (CONSOLIDADO).                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConsoFil (aArqNew, cChaveCons, nNivel, aStru, aConteudo, cCmpGrvCon)
Local	lRet	:=	.T.
Local	nCntFor		:=	0
Local	uConteudo
Local	cString		:=	""
Local	aGrava		:=	{}
Local	aAcumula	:=	{}
Local	cChave		:=	""

For nCntFor := 1 To Len (aStru[nNivel])
	uConteudo 	:= 	&(aConteudo[nNivel][nCntFor])
	cCampo		:=	AllTrim (aStru[nNivel][nCntFor][1])
	cTipo		:=	aStru[nNivel][nCntFor][2]
	//
	Do Case
	Case (cTipo == "N")
		If ( uConteudo == Nil )
			uConteudo := 0
		EndIf
		cString	:=	Str (uConteudo, aStru[nNivel][nCntFor][3], aStru[nNivel][nCntFor][4])

	Case (aStru[1][nCntFor][2]=="D")
		If (uConteudo==Nil)
			uConteudo := dDataBase
		EndIf
		cString	:=	PadR (Dtos (uConteudo), aStru[nNivel][nCntFor][3])

	Case (cTipo=="C")
		If (uConteudo==Nil)
			uConteudo := ""
		EndIf
		cString := PadR (uConteudo, aStru[nNivel][nCntFor][3])

	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se o conteudo (cString) faz parte da chave de pesquisa pelo indice criado no TRB³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cCampo$cChaveCons)
		cChave	+=	cString
		aAdd (aGrava, {cCampo, uConteudo})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico se o conteudo mesmo nao fazendo parte do indice deve ser gravado no Reclock(.T.)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (cCampo$cCmpGrvCon)
		aAdd (aGrava, {cCampo, uConteudo})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravo os Reclock (.F.), acumuladores de valores³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		aAdd (aAcumula, {cCampo, uConteudo})
	EndIf
Next nCntFor
//
DbSelectArea (aArqNew[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faco a inclusao no TRB conforme chave³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(aArqNew[1])->(DbSeek(cChave))
	RecLock (aArqNew[1], .T.)
	For nCntFor := 1 To Len (aGrava)
		(aArqNew[1])->(FieldPut (&(aArqNew[1]+"->(FieldPos('"+aGrava[nCntFor][1]+"'))"), aGrava[nCntFor][2]))
	Next nCntFor
Else
	RecLock (aArqNew[1], .F.)
EndIf
For nCntFor := 1 To Len (aAcumula)
	(aArqNew[1])->&(aAcumula[nCntFor][1])	+=	aAcumula[nCntFor][2]
Next nCntFor
MsUnLock ()
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GeroConso ºAutor  ³Gustavo             º Data ³  05/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faco While no TRB criado e alimentado que servira de base   º±±
±±º          ³ para a gravacao da funcao GrvBuffer com o TRB ja consolidadoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nHandle -> Handle do txt para gravacao.                     º±±
±±º          ³aDelimit -> Flags para a inclusao dos delimitadores         º±±
±±º          ³aStru -> Estrutura do arquivo TRB criado.                   º±±
±±º          ³aArqNew -> Alias e Nome Fisico do TRB criado.               º±±
±±º          ³aAlias -> Alias apontado no INI para o bloco (SOMENTE UTI-  º±±
±±º          ³ LIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA ESTAOº±±
±±º          ³ ACUMULADOS NO TRB CRIADO)                                  º±±
±±º          ³aConteudo -> Conteudo apontado no INI para o bloco (SOMENTE º±±
±±º          ³ UTILIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA  º±±
±±º          ³ ESTAO ACUMULADOS NO TRB CRIADO)                            º±±
±±º          ³aPosReg -> Conteudo apontado no INI para a clausula (POSREG)º±±
±±º          ³aContReg -> Conteudo apontado no INI para a clausula (CONT) º±±
±±º          ³cMaskVlr -> Mascara padrao para os campos valores apontado  º±±
±±º          ³ no INI atraves da clausula (MASKVLR)                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeroConso (nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
Local	lRet	:=	.T.
//                     
DbSelectArea (aArqNew[1])
(aArqNew[1])->(DbGoTop ())
//
While !(aArqNew[1])->(Eof ())
	//
	GrvBuffer (nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
	//
	(aArqNew[1])->(DbSkip ())
EndDo
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GeroConso ºAutor  ³Gustavo             º Data ³  05/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao do registro do TRB no meio-magnético               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nHandle -> Handle do txt para gravacao.                     º±±
±±º          ³aDelimit -> Flags para a inclusao dos delimitadores         º±±
±±º          ³aStru -> Estrutura do arquivo TRB criado.                   º±±
±±º          ³aArqNew -> Alias e Nome Fisico do TRB criado.               º±±
±±º          ³aAlias -> Alias apontado no INI para o bloco (SOMENTE UTI-  º±±
±±º          ³ LIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA ESTAOº±±
±±º          ³ ACUMULADOS NO TRB CRIADO)                                  º±±
±±º          ³aConteudo -> Conteudo apontado no INI para o bloco (SOMENTE º±±
±±º          ³ UTILIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA  º±±
±±º          ³ ESTAO ACUMULADOS NO TRB CRIADO)                            º±±
±±º          ³aPosReg -> Conteudo apontado no INI para a clausula (POSREG)º±±
±±º          ³aContReg -> Conteudo apontado no INI para a clausula (CONT) º±±
±±º          ³cMaskVlr -> Mascara padrao para os campos valores apontado  º±±
±±º          ³ no INI atraves da clausula (MASKVLR)                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvBuffer(nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
Local	cBuffer		:=	""
Local	nCntFor		:=	0
Local	cDelimit	:=	AllTrim (aDelimit[1])
//         
If (Len (cDelimit)>1)
	If ("I"$SubStr (cDelimit, 2))
		cBuffer	+=	SubStr (cDelimit, 1, 1)
	EndIf
EndIf
//
For nCntFor := 1 To Len(aStru[1])
	cTipo		:=	ValType ((aArqNew[1])->&(aStru[1][nCntFor][1]))
	//
	bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[1]+"->"+aStru[1][nCntFor][1]+"|"+aConteudo[1][nCntFor],3,1) })
	//
	BEGIN SEQUENCE
		uConteudo := (aArqNew[1])->&(aStru[1][nCntFor][1])
		Do Case
		Case (aStru[1][nCntFor][2]=="N")
			If ( uConteudo == Nil )
				uConteudo := 0
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
			//³Quando possuir mascara apontada no INI, utilizo-a no transform para gravacao no TXT.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
			If Empty (cMaskVlr) .Or. (aStru[1][nCntFor][4])==0
				uConteudo := NoRound (uConteudo*(10**(aStru[1][nCntFor][4])), aStru[1][nCntFor][4])

				If (!Empty (aDelimit[1]))
					cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[1][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[1][nCntFor][3])))
				Else
					cBuffer += StrZero (uConteudo, aStru[1][nCntFor][3])
				EndIf
			Else
				cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
			EndIf

		Case (aStru[1][nCntFor][2]=="D")
			If (uConteudo==Nil)
				uConteudo := dDataBase
			EndIf
			cBuffer += PadR (Dtos (uConteudo), aStru[1][nCntFor][3])
		Case (aStru[1][nCntFor][2]=="C")
			If ( uConteudo == Nil )
				uConteudo := ""
			EndIf

			If (!Empty (aDelimit[1]))
				cBuffer += AllTrim (uConteudo)
			Else
				cBuffer += PadR (uConteudo, aStru[1][nCntFor][3])
			EndIf
		EndCase
	END SEQUENCE

	ErrorBlock(bError)

	If (Len (cDelimit)>1)
		If (nCntFor==Len (aStru[1]))
			If ("F"$SubStr (cDelimit, 2))
				cBuffer	+=	SubStr (cDelimit, 1, 1)
			EndIf
		Else
			If ("M"$SubStr (cDelimit, 2))
				cBuffer	+=	SubStr (cDelimit, 1, 1)
			EndIf
		EndIf
	EndIf

Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Gravacao da Linha                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cBuffer)
	FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
	If ( Ferror()!=0 )
		Help(" ",1,"NORMAERRO4")
	EndIf
EndIf
aEval(aPosReg[1],{|x| &(x) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Incrementa o contador  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aContReg[1],{|x| &(x) })
Return
