#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "GPEM800.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM800  ³ Autor ³ ABEL APARECIDO RIBEIRO³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de arquivo texto Mapa SHST                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Kato ³28/11/08³      ³Declaracao do array adD210Log.		      ³±±
±±³Tiago Malta ³07/01/10³00280/³Alterado o conteudo da variavel cFilDe e  ³±±
±±³            ³        ³  2010³cFilAte para space(FWGETTAMFILIAL).       ³±±
±±³ Alex       ³22/12/10³29463/³ Atender Nova Interface Totvs 11.5 utili- ³±±
±±³            ³        ³  2010³ zando a funcao MsAdvSize.                ³±± 
±±³Tiago Malta ³27/05/11³29463/³Alterado as posições dos objetos usando a ³±±
±±³            ³        ³  2010³ função retcoords.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function GPEM800()
Local nOpca 	:= 0
Local bBtnCalcule							//bloco do botão OK
Local bPergunte								//bloco para o pergunte
Local cSays			:= OemToAnsi(STR0002)	//"Este programa gera o arquivo texto do Quadro de Pessoal"
Local oDlg
Local oBtnCalcule
Local oBtnEnd
Local oBtnPergunte
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local aRetcoords

Private cFilDe := cFilAte := Space(FWGETTAMFILIAL)
Private cTxtParam := ""
Private oAnoMes, oTxtParam, aParamQP
Private cAnoMes := Space(6)
Private cPerg   := Padr("GPEM800",10)
Private adD210Log:= Array(3)
Private lNomResp:= .F.
Private lLog050 := lLog051 := lLog058 := lLog067 := lLog073 := .F.
Private nSOmaVal := 0 
Pergunte(cPerg,.F.)

DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13 BOLD
cTxtParam := OemToAnsi(Gpem800QbrPar(cPerg))
cBlkGet :=  "{ | u | If( PCount() == 0, cTxtParam,cTxtParam:= u ) }"
cBlKVld :=  "{|| .T. }"
cBlKWhen := "{|| .F. }"
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()  
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 75	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aRetcoords      := RetCoords(1,4,0,15,1,0,,,aAdvSize)

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Geração do Arquivo texto do Quadro de Pessoal"
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Descricao da Janela                                                      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
	@ aObjSize[1][1]+5 , aObjSize[1][2]+5 TO oDlg:nBottom*0.37,oDlg:nRight*0.49 OF oDlg PIXEL  //@ 11,12 TO 100,245 OF oDlg PIXEL
	@ aRetcoords[1][1] , aRetcoords[1][2] SAY cSays Of oDlg Pixel  FONT oFont1 // "Este programa gera o arquivo texto do Quadro de Pessoal"
	@ aRetcoords[2][1] , aRetcoords[2][2] SAY STR0003 Of oDlg Pixel FONT oFont1 // "Parametros:"
	oTxtParam := TMultiGet():New(aRetcoords[3][1] , aRetcoords[3][2],&cBlKGet,oDlg,200,50,,.F.,,,,.T.,,.F.,&(cBlkWhen),.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Funcoes em GpFiltro  - Blocos de Execucao dos filtros                    ³
	³ GpFiltro - Chama a janela principal do cadastro de filtros               ³
	³ GpFltAlsGet - Retorna a expressao para elaborar o filtro                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	AADD(aButtons, {"LogOcorr" ,{ || GPM800Log() },STR0005,STR0005} )
	AADD(aButtons, {"Parametros" ,{ || Pergunte("GPEM800",.T.), cTxtParam := OemToAnsi(Gpem800QbrPar(cPerg)), oTxtParam:Refresh() },STR0003,STR0003} )
	
	bSet15		:= { || nOpca := 1, IF( GPM800Ok()( ),oDlg:End(), nOpca:=0 ) }
	bSet24		:= { || oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Filial de                                         ³
//³ mv_par02 - Filial Ate                                        ³
//³ mv_par03 - Ano Base                                          ³
//³ mv_par04 - Nome do Arquivo                                   ³
//³ mv_par05 - Local do Arquivo                                  ³
//³ mv_par06 - NIF da Entidade                                   ³
//³ mv_par07 - Nome de Contato                                   ³
//³ mv_par08 - Fone Principal                                    ³
//³ mv_par09 - Fone Alternativo                                  ³
//³ mv_par10 - Fax Contato                                       ³
//³ mv_par11 - Email                                             ³
//³ mv_par12 - Empresa Fabricante Aplicativo                     ³
//³ mv_par13 - Nome do Aplicativo                                ³
//³ mv_par14 - Versão do Aplicativo                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nOpca == 1
	ProcGpe({|lEnd| f800GravaQP()})  // Chamada do Processamento
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM800GetFile ºAutor  ³Abel RIbeiro      º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do Relatorio de Log de Processamento.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPM800GetFile()
Local cArq
mvRet := Alltrim(ReadVar())
cArq := Space(80)
cTipo := STR0015+".txt"+")   | *."+"txt"+"  " // "Arquivos Mapa SHST (*.txt)   | *.txt  "
cGetFile := cGetFile("",OemToAnsi(STR0016),0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY) //"Selecione o Diretorio"
If Empty(cGetFile)
	Return(.F.)
Endif
&mvRet := cGetFile
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM800Log     ºAutor  ³Abel Ribeiro      º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do Relatorio de Log de Processamento.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM800Log()
cPathFile := ""
cExtRel := ".##R"
cPathFile := ( __RelDir + "GPEM800" + cExtRel )
If File(cPathFile)
	OurSpool( "GPEM800" )
	Ms_Flush()
Else
	MsgStop(STR0013) // "Não existe Log de Processamento para exibir"
Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM800Ok  ºAutor  ³Microsiga           º Data ³  22/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM800Ok()
Return (MsgYesNo(OemToAnsi(STR0012),OemToAnsi(STR0007))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"
/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem800QbrPar³Autor³ Abel Ribeiro           ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o texto dos parametros separado em linhas      		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem800QbrPar(cPerg)
nLinha := 1
nStrPar := 1
cTxtPar := ""
cTxtSX1 := ""
dbSelectArea("SX1")
dbSetOrder(1)
dbSeek(cPerg)
aParamQP := {}
While !Eof() .And. SX1->X1_GRUPO == cPerg
	cTxtSX1 += AllTrim(SX1->X1_PERGUNT)+":'"
	cVarX1 := AllTrim(SX1->X1_VAR01)
	If SX1->X1_TIPO == "C"
		cContX1 := AllTrim(&cVarX1)
	ElseiF SX1->X1_TIPO == "N"
		cContX1 := AllTrim(Transform(&cVarX1,SX1->X1_PICTURE))
	ElseiF SX1->X1_TIPO == "D"
		cContX1 := Dtoc(&cVarX1)
	Endif
	Aadd(aParamQP,{SX1->X1_PERGUNT+" : ",cContX1})
	cTxtSX1 +=  cContX1+"' ; " 
	dbSkip()
EndDo
While nStrPar <= Len(cTxtSX1)
	If nLinha > 6
		Exit
	Endif
	cTxtPar += Substr(cTxtSX1,nStrPar,80)+Chr(13)
	nStrPar+=80  
	nLinha++
EndDo
While nLinha <= 6
	cTxtPar += Chr(13)
	nLinha++
EndDo
Return(cTxtPar)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³f800GravaQP    ºAutor  ³Abel Ribeiro        º Data ³02/09/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de gravacao do arquivo texto do quadro de pessoal   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION f800GravaQP()
Local nY
Private cNomArq, nHdl
Private contafun, nTotal
Private cEOL    := CHR(13)+CHR(10)
Private aEstab  := {}
Private aIRCT   := {}
Private cFilProc
Private aInfo 	:= {}
Private aLog    := aLogTot := {}
Private aTitle	:= {}
Private aTotRegs 
Private cAno    := ''
Private	cNomEmp := ''
Private cMORADA := ''
Private cLocalidade := '' 
Private cCodPostal  := '' 
Private cSufixo     := '' 
Private cLocalPostal:= '' 
Private cTelefone   := '' 
Private cFax := ''   
Private cDistrito:= '' 
Private cCodConsel := ''
Private cCNAE      := ''
Private lPri       := .T.
Private lLOG       := .F.
Private lLog550    := .F.
Private lErro      := .F.
Private aD210Log   := aRRAY(3)
Private aM221Log   := aRRAY(3)
Private aM222Log   := aRRAY(2)
Private aM224Log   := aRRAY(3)
Private aM225Log   := aRRAY(2)
Private aM243Log   := aRRAY(6)
Private aM245Log   := aRRAY(5)
Private aM25ALog   := aRRAY(5)
Private aM25DLog   := aRRAY(8)
Private aM25ILog   := aRRAY(7)
Private aM262Log   := aRRAY(5)
Private aM273Log   := aRRAY(6)
Private aM550Log   := aRRAY(6)

IF !CHKFILE("RGR")
   return()
ENDIF   

cQuery := " SELECT * "
cQuery += " FROM "+	RetSqlName("RGR")
cQuery += " WHERE RGR_FILIAL >= '" + MV_PAR01 + "' AND RGR_FILIAL <= '" + MV_PAR02+ "' AND "
cQuery += "       RGR_ANOBAS  = '" + MV_PAR03 + "' AND "
 
If TcSrvType() != "AS/400"
	cQuery += " D_E_L_E_T_ <> '*' "		
EndIf		                                                               
cQuery += " ORDER BY RGR_FILIAL,RGR_REGIST,RGR_SEQ,RGR_CAMPO "

IF SELECT('QRGR') > 0
	QRGR->( dbCloseArea() )
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRGR', .F., .T.)

dbSelectArea("QRGR")
If QRGR->(Eof())
	Return
Endif
// Monta array com as filiais que serao processadas pela rotina                   
aFilProc := {}
dbSelectArea("SM0")
cEmpFilOld := CNUMEMP
cEmpFilAtu := CEMPANT + mv_par01
dbSeek(cEmpFilAtu,.T.)
While !Eof() .And. SM0->M0_CODIGO+SM0->M0_CODFIL <= CEMPANT+mv_par02
	aAdd(aFilProc,{SM0->M0_CODFIL,SM0->M0_FILIAL+"/"+SM0->M0_NOME+"/"+M0_NOMECOM,SM0->M0_CGC})
	dbSkip()
EndDo


dbSelectArea("QRGR")

aTotRegs := array(21)
aFill(aTotRegs,0)
aLog := {}
For nY := 1 To Len(aFilProc)
	cLin1 := ''
	lTemArq := .F.
	dbSelectArea("QRGR")
	
	cFilAtu := aFilProc[nY][1]          // Filial + empresa a processar

	If aTotRegs[11] == 0
		cLog := STR0010                     // "Filial processada: "
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[11] := len(aLog)
		Aadd(aLog[aTotRegs[11]], cFilAtu+"-"+aFilProc[nY][2]) 
	EndIf	         
	
		cLin1    := f800GrvCab('000',cFilAtu)        // Chama rotina de geracao do cabecalho - informacoes de contato
		cExt     := IIF(!".TXT" $ Upper(mv_par04),".txt","")

		// nome do arquivo no formato NIF_AAAA.TXT
		// se foi escolhida mais de uma filial, o nome sera criado automaticamente
		// nome formado por caminho + nome + extensao

		cNomArq := AllTrim(mv_par05)+Iif(mv_par01==mv_par02,+AllTrim(mv_par04),AllTrim(aFilProc[nY][3])+"_"+Substr(mv_par03,1,4)+"_"+STRZERO(nY,4,0))+cExt
		nHdl    := fCreate(cNomArq)
        
	    fWrite(nHdl,cLin1,Len(cLin1))                  // Grava Linha de Cabecalho		

		If nHdl == -1
			MsgStop(STR0017+cNomArq+STR0018,STR0007)   // ###"O arquivo de nome "###" nao pode ser gravado! Verifique os parametros."###"Atencao!"
			Return
		Endif
        
	
	    IF  QRGR->(!EOF())                  
            
            cFilProc := QRGR->RGR_FILIAL
		    nTotal   := RECCOUNT()
		    cAno     := QRGR->RGR_ANOBAS    
		    cTipReg  := QRGR->RGR_TIPREG

	
		    lTemArq := .T.		
		    dbSelectArea("QRGR")

		    ProcRegua( nTotal )
		
		    While !Eof() .And. QRGR->RGR_FILIAL  <= cFilAtu 
			      
			      cTipo    := QRGR->RGR_REGIST
			      cDet     := ''
                  cSeq     := QRGR->rgr_seq    
                  cTipReg  := QRGR->RGR_TIPREG
                  cDescri  := QRGR->RGR_DESCRI     
                  
			       IF ctipreg = "M"  .and. cSeq == "000"
			          QRGR->(DBSKIP()) 
			          Loop
			       endif   
			     
			      IncProc(QRGR->RGR_REGIST + "-" + STRZERO(RECNO(),3))
		          
		          IF cTipReg == "M"
		             While cTipo == QRGR->RGR_REGIST  .And. cSeq == QRGR->RGR_SEQ 
			            
			            IF lPri                                                
                           cDet := cTipo
                           lPri := .F. 
                        ENDIF
                                
                	    cLin  := f800GrvDet(cTIPO,cSeq)               // monta a linha com dados do funcionario
                        
			            QRGR->(DBSKIP())   
			         EnDDO
		          Else
			         While cTipo == QRGR->RGR_REGIST  
			            
				            IF lPri .and. cTipReg <> "V"                                               
	                           cDet := cTipo
	                           lPri := .F. 
	                        ENDIF
	                                
	                	    cLin  := f800GrvDet(cTIPO,cSeq)               // monta a linha com dados do funcionario
	                        
				            QRGR->(DBSKIP())   
				      EnDDO
		          ENDIF
		          
			      cLin += cEOL                                                
		   
			      IF !Empty(cLin)
				     fWrite(nHdl,cLin,Len(cLin))
				     lTemArq := lPri := .T. 
				     cDET := ''             
				  ENDIF
				  
			      //Grava Log somente dos Registros Empresa e Estabelecimento
			      
			      IF cTipo == "100" .Or. cTipo == "200"
	                 f800LogTipo(cTipo,cMorada,cLocalidade,cCodPostal,cSufixo,cLocalPostal,cTelefone,cFAX,cDistrito,cCodConsel,cCNAE)
			      ENDIF
			      
			      IF llOG
			         f800LogTipo(cTipo)
			         llOG := .F.
			      ENDIF
			      
			      dbSelectArea("QRGR")
			      cTipo := QRGR->RGR_REGIST
		    EndDo                  
		    // Fecha o arquivo gerado somente se houver registros validos
		    IF lTemArq
			   fClose(nHdl)
		    Endif
	    Else
		    // Log informando que nao foram encontrados registros para processar
		    If aTotRegs[12] == 0
			   cLog := STR0041               // "Não foram encontrados registros para processar nesta filial"
			   Aadd(aTitle,cLog)  
			   Aadd(aLog,{})
			   aTotRegs[12] := len(aLog)
			   Aadd(aLog[aTotRegs[12]], aFilProc[nY][2] + STR0044 ) 
		    EndIf	
	    Endif  
	    
	    
	    If aTotRegs[1] == 0 .and. aTotRegs[2] == 0 .and. aTotRegs[3] == 0 .and. aTotRegs[4]==0 .and. ;
	       aTotRegs[5] == 0 .and. !lErro
	       
		   If aTotRegs[6] == 0
		      cLog := STR0008 // "Arquivo texto do Mapa de SHST Gerado com sucesso!"
			  Aadd(aTitle,cLog)  
			  Aadd(aLog,{})
			  aTotRegs[6] := len(aLog)
		   EndIf	
		   Aadd(aLog[aTotRegs[6]], STR0009 ) // "Nao foi encontrada nenhuma inconsistencia durante a geracao."
	    ELSE
	       IF aTotRegs[6] == 0
		      cLog := STR0008                // "Arquivo texto do Mapa de SHST Gerado com sucesso!"
			  Aadd(aTitle,cLog)  
			  Aadd(aLog,{})
			  aTotRegs[6] := len(aLog)
		   EndIf	
		   Aadd(aLog[aTotRegs[6]], STR0114 ) // "Arquivo Gerado, mas Há inconsistência em alguns campos, verifique o arquivo de Log."
	    EndIf   
Next

If aTotRegs[7] == 0
	cLog := STR0047+Chr(13) // "Informações para gerar o arquivo texto do Mapa SHST."
	Aadd(aTitle,cLog)  
	Aadd(aLog,{})
	aTotRegs[7] := len(aLog)
	Aadd(aLog[aTotRegs[7]], STR0003) //"Parâmetros"
	For nY := 1 To Len(aParamQP)
		Aadd(aLog[aTotRegs[7]], aParamQP[nY][1]+aParamQP[nY][2] )
	Next
EndIf	

fMakeLog(aLog,aTitle,,,"GPEM800",STR0011,"G","L",,.F.) // "Log de ocorrências da geração do arquivo texto do Mapa SHST"

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³f800LogTipo    ºAutor  ³ABEL RIBEIRO        º Data ³04/09/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina p/ verificar se campos dos registros  estao corretosº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cria Log de Inconsistencia de registros conforme o tipo    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f800LogTipo(cTipo,cMorada,cLocalidade,cCodPostal,cSufixo,cLocalPostal,cTelefone,cFAX,cDistrito,cCodConsel,cCNAE)
If cTipo == '000'    //Registro Header 
	/*/
	Registro de Contato					
	Nome do Contato							    A 			70		S 		Padr(mv_par07,100)
	Telefone Principal						    N 			9		S 		Padr(mv_par08,100)
	Telefone Alternativo 					    N 			9		S 		Padr(mv_par09,100)
	Fax Contato  							    N 			9		S 		Padr(mv_par10,100)
	E-mail     							        N 			70		S 		Padr(mv_par11,100)
	Empresa Fabricante    				        N 			70		S 		Padr(mv_par12,100)
	Nome do Aplicativo					        N 			40		S 		Padr(mv_par13,100)
	Versão do Aplicativo 				        N 			20		S 		Padr(mv_par14,100)
	
	/*/
	cTxtOco := ""
	cTxtOco += Iif(Empty(mv_par07),STR0021,"") 	// "Nome "
	cTxtOco += Iif(Empty(mv_par08),STR0022,"") 	// "Fone Principal"
	cTxtOco += Iif(Empty(mv_par09),STR0023,"") 	// "Fone Alteranativo
	cTxtOco += Iif(Empty(mv_par10),STR0025,"") 	// "Fax
	cTxtOco += Iif(Empty(mv_par11),STR0024,"") 	// "E-mail
	cTxtOco += Iif(Empty(mv_par12),STR0026,"") 	// "Nome da Empresa responsavel
	cTxtOco += Iif(Empty(mv_par13),STR0027,"") 	// "Nome do Aplicativo
	cTxtOco += Iif(Empty(mv_par14),STR0028,"") 	// "Versão do Aplicativo
	
	If !Empty(cTxtOco)
		If aTotRegs[1] == 0
			cLog := STR0038                           // "Inconsistências nas informações do Contato"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[1] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[1]], cTxtOco ) 
	    lErro      := .T.
	Endif   
	
ElseIf cTipo == '100'   

	/*
	Registro da Empresa					

    Nome ou designação social da Entidade 	          70	A	
    Endereço	                                      60	A	
    Localidade										  40	A	
    Código Postal									   4	N	
    Sufixo Postal									   3	N	
    Localidade Postal								  40	A	
    Telefone										   9	N	
    Fax											   	   9	N	
    Código de Distrito								   2	N	Valida por tabela                           Código de Concelho								   2	N	Valida por tabela
    Código de Actividade Económica (CAE-Ver.2.1)	   5	N	Valida por tabela	
	/*/     

	cTxtOco := ""
	cTxtOco += Iif(Empty(cMorada),STR0029,"") 			// "Endereco "
	cTxtOco += Iif(Empty(cLocalidade),STR0030,"") 		// "Bairro "
	cTxtOco += Iif(Empty(cCodPostal),STR0031,"") 		// "Codigo Postal "
	cTxtOco += Iif(Empty(cSufixo),STR0033,"") 	    	// "Sufixo Postal
	cTxtOco += Iif(Empty(cLocalPostal),STR0032,"") 		// "Descricao do Codigo Postal "
	cTxtOco += Iif(Empty(cTelefone),STR0035,"")    	    // "Telefone "
	cTxtOco += Iif(Empty(cFax),STR0036,"")      	    // "Fax "
	cTxtOco += Iif(Empty(cDistrito),STR0037,"") 		// "Cod. Distrito "
	cTxtOco += Iif(Empty(cCodConsel),STR0038,"")    	// "Codigo Consel
	cTxtOco += Iif(Empty(cCNAE),STR0039,"") 	        // "Cod. Atividade Economica"
	
	If !Empty(cTxtOco)
		If aTotRegs[2] == 0
			cLog := STR0044                             // "Inconsistencias no Cadastro da Empresa"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[2] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[2]], cTxtOco ) 
	    lErro      := .T.
	Endif

ElseIf cTipo == '200'    

	/*
	Registro do estabelecimento

	Nº do Estabelecimento 						N 			4		S 		
	Nome do Estabelecimento 					A 			70		S 		
	Morada 										A 			60		S 		
	Localidade 									A 			40		S 		
	Código Postal 								N 			4		S 		
	Sufixo Postal                               N           3      
	Localidade Postal (descritivo) 				A 			40		S 		
	Telefone 									N 			9		S 		
	Fax   	 									N 			9		S 		
	Código de Distrito                      	N 			2		S 		
	Código de Concelho                       	N 			2		S 		
	Cód. Atividade Economica  	                N 			5		S 		
	*/                                                            
	
	cTxtOco := ""
	cTxtOco += Iif(Empty(cMorada),STR0029,"") 		    // "Endereco "
	cTxtOco += Iif(Empty(cLocalidade),STR0030,"") 	    // "Bairro "
	cTxtOco += Iif(Empty(cCodPostal),STR0031,"") 		// "Codigo Postal "
	cTxtOco += Iif(Empty(cSufixo),STR0033,"") 		    // "Sufixo Postal "      
	cTxtOco += Iif(Empty(cLocalPostal),STR0034,"") 		// "Localidade Postal "
	cTxtOco += Iif(Empty(cTelefone),STR0035,"")    	    // "Telefone "
	cTxtOco += Iif(Empty(cFax),STR0036,"")      	    // "Fax "
	cTxtOco += Iif(Empty(cDistrito),STR0037,"") 	    // "Código Distrito
	cTxtOco += Iif(Empty(cCodConsel),STR0038,"") 	    // "Cod. Municipio"
	cTxtOco += Iif(Empty(cCNAE),STR0034,"") 	        // "Cod. Atividade Economica"
	
	If !Empty(cTxtOco)
		If aTotRegs[3] == 0
			cLog := STR0045 // "Inconsistencias no Cadastro do Estabelecimento"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[3] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[3]], cTxtOco ) 
	    lErro      := .T.
	Endif                 
ElseIf cTipo == '210'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aD210Log[1]),STR0056,"") 	    // "Informe o tipo de Segurança,Higiene e Sáude (1 ou 2"  
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aD210Log[2]),STR0057,"") 	    // "Informe o Tipo de Atividade de Segurança (1,2,3 ou 4)"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aD210Log[3]),STR0058,"") 		// "Informe o Tipo de Atividade de Saúde (1,2,3 ou 4)"
		
		If !Empty(cTxtOco)
			If aTotRegs[4] == 0
				cLog := STR0055                             //"Inconsistências na Pasta Organização SHST"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[4] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[4]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '221'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM221Log[1]),STR0060,"") 	    // "Informe o Nome do Médido do Trabalho"  
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM221Log[2]),STR0061,"") 	    //  "Informe o Nr. da Cédula Profissional MT"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM221Log[3]),STR0062,"") 		// "Informe o Nr. de Horas Mensais" 
		
		If !Empty(cTxtOco)
			If aTotRegs[5] == 0
				cLog := STR0059                             //"Inconsistências na Pasta Serviços Internos e Externos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[5] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[5]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '222'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM222Log[1]),STR0064,"") 	    // "Informe o Nome do Técnico de Segurança e Higiene"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM222Log[2]),STR0065,"") 	    //  "Informe o Nível de Certificação "
		
		If !Empty(cTxtOco)
			If aTotRegs[8] == 0
				cLog := STR0059                             //"Inconsistências na Pasta Serviços Internos e Externos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[8] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[8]], cTxtOco ) 
	    lErro      := .T.
		Endif                 

ElseIf cTipo == '224'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM224Log[1]),STR0060,"") 	    // "Informe o Nome do Médido do Trabalho"  
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM224Log[2]),STR0061,"") 	    //  "Informe o Nr. da Cédula Profissional MT"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM224Log[3]),STR0062,"")  		// "Informe o Nr. de Horas Mensais" 
		
		
		If !Empty(cTxtOco)
			If aTotRegs[13] == 0
				cLog := STR0066                             //"Inconsistências na Pasta Pessoal do Serviço de Segurança - Serviços Externos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[13] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[13]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '225'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM225Log[1]),STR0064,"") 	    // "Informe o Nome do Técnico de Segurança e Higiene"
		cTxtOco += Iif(Empty(aM225Log[2]),STR0065,"") 	    // "Informe o Nível de Certificação "
		
		If !Empty(cTxtOco)
			If aTotRegs[14] == 0
				cLog := STR0066                             //"Inconsistências na Pasta Pessoal do Serviço de Segurança - Serviços Externos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[14] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[14]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '243'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM243Log[1]),STR0068,"") 	    // "Informe o Objetivo da Ação de Formação "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM243Log[2]),STR0069,"") 	    // "Informe o Nro. de Açoes Realizadas, deve ser maior que 0"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM243Log[3]),STR0070,"") 	    // "Informe a Duração da ação em Horas, deve ser maior que 0"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM243Log[4]),STR0071,"") 	    // "Informe os Destinatários "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM243Log[5]),STR0072,"") 	    // "Informe o Nr. de Participantes H"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM243Log[6]),STR0073,"") 	    // "Informe o Nr. de Participantes M"
		
		If !Empty(cTxtOco)
			If aTotRegs[15] == 0
				cLog := STR0067                             //"Inconsistências na Pasta Atividade SHST - Ações de Formação "
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[15] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[15]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '245'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM245Log[1]),STR0075,"")     	    // "Informe o Objetivo da Ação de Formação "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM245Log[2]),STR0076,"") 	        // "Informe o Nro. de Açoes Realizadas, deve ser maior que 0"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM245Log[3]),STR0077,"") 	        // "Informe a Duração da ação em Horas, deve ser maior que 0"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM245Log[4]),STR0078,"") 	        // "Informe o Nr. de Participantes H"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM245Log[5]),STR0079,"") 	        // "Informe o Nr. de Participantes M"
		cTxtOco += cEOL
		
		If !Empty(cTxtOco)
			If aTotRegs[16] == 0
				cLog := STR0074                             //"Inconsistências na Pasta Atividade SHST - Formação Pessoal "
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[16] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[16]], cTxtOco )
	    lErro      := .T.
			 
		Endif                 
ElseIf cTipo == '25A'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM25ALog[1]),STR0081,"") 	    // "Informe o Código do Agente Físico 01 a 07"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25aLog[2]),STR0082,"") 	    // "Informe Nº Trab. Expostos - H"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25aLog[3]),STR0083,"") 	    // Informe Nº Trab. Expostos - M"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25aLog[4]),STR0084,"") 	    // "Informe Nº Avaliações,deve ser > 0 "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25aLog[5]),STR0085,"") 	    // "Informe o Resultado última avaliação"          
		If !Empty(cTxtOco)
			If aTotRegs[17] == 0
				cLog := STR0080                             //""Inconsistências  na pasta Atividades desenvolvidas - Agentes Químicos identificados"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[17] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[17]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '25D'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM25DLog[1]),STR0087,"") 	    // "Informe o Código do Agente Químico"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25DLog[2]),STR0088,"") 	    // "Informe o Código EINECS "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25DLog[3]),STR0089,"") 	    // "Informe 0 Nº Trab. Expostos - H"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25DLog[4]),STR0090,"") 	    // "Informe o Nº Trab. Expostos - M "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25DLog[5]),STR0091,"") 	    // ""Informe o Código Medida Adotada "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25DLog[6]),STR0092,"") 	    // "Informe Nº Avaliações,deve ser > 0 "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25DLog[7]),STR0093,"") 	    // "Informe o Resultado última avaliação"
		
		If !Empty(cTxtOco)
			If aTotRegs[18] == 0
				cLog := STR0086                             //"Inconsistências na Atividades desenvolvidas - Agentes Químicos identificados "       
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[18] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[18]], cTxtOco ) 
	    lErro      := .T.
		Endif                 

ElseIf cTipo == '25I'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM25ILog[1]),STR0095,"") 	    // "Informe Código Identificação Agente Biológico"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25ILog[2]),STR0096,"") 	    // "Informe Classificação do Agente Biológico "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25ILog[3]),STR0097,"") 	    // "Informe o Nº Trab. Expostos - H"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25ILog[4]),STR0098,"") 	    // "Informe o Nº Trab. Expostos - M "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25ILog[5]),STR0099,"") 	    // ""Informe o Código Medida Adotada "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25ILog[6]),STR0100,"") 	    // "Informe Nº Avaliações,deve ser > 0 "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM25ILog[7]),STR0101,"") 	    // "Informe o Resultado última avaliação"
		
		If !Empty(cTxtOco)
			If aTotRegs[19] == 0
				cLog := STR0094                             //"Inconsistências na Atividades desenvolvidas - Agentes Biológicos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[19] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[19]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '262'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM262Log[1]),STR0103,"") 	    // "Informe Descrição do Tipo de vacinação"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM262Log[2]),STR0104,"") 	    // "Nº de Inoculações "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM262Log[3]),STR0105,"") 	    // "Nº de Trabalhadores - H"
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM262Log[4]),STR0106,"") 	    // "Nº de Trabalhadores - M"
		
		If !Empty(cTxtOco)
			If aTotRegs[20] == 0
				cLog := STR0102                             //"Inconsistências Atividades desenvolvidas - Ações de imunização"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[20] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[20]], cTxtOco ) 
	    lErro      := .T.
		Endif                 
ElseIf cTipo == '273'    
		cTxtOco := ""
		cTxtOco += Iif(Empty(aM273Log[1]),STR0108,"") 	    // "Código da doença Profissional "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM273Log[2]),STR0109,"") 	    // "Especificação da Doença "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM273Log[3]),STR0110,"") 	    // "Participados - H "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM273Log[4]),STR0111,"") 	    // "Confirmados  - H "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM273Log[5]),STR0112,"") 	    // "Participados - M "
		cTxtOco += cEOL
		cTxtOco += Iif(Empty(aM273Log[6]),STR0113,"") 	    // "Confirmados  - M "
		
		If !Empty(cTxtOco)
			If aTotRegs[21] == 0
				cLog := STR0107                             //"Inconsistências na Pasta Acidentes de Trabalho e Doenças Profissionais "
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[21] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[21]], cTxtOco ) 
	    lErro      := .T.
		Endif                 

Endif                           
	                   
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f800GrvCab³ Autor ³ Abel Ribeiro          ³ Data ³03/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cabecalho dos arquivos a serem gerados                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function f800GrvCab(cTipo,cFilAtu)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Filial de                                         ³
//³ mv_par02 - Filial Ate                                        ³
//³ mv_par03 - Ano Base                                          ³
//³ mv_par04 - Nome do Arquivo                                   ³
//³ mv_par05 - Local do Arquivo                                  ³
//³ mv_par06 - NIF da Entidade                                   ³
//³ mv_par07 - Nome de Contato                                   ³
//³ mv_par08 - Fone Principal                                    ³
//³ mv_par09 - Fone Alternativo                                  ³
//³ mv_par10 - Fax Contato                                       ³
//³ mv_par11 - Email                                             ³
//³ mv_par12 - Empresa Fabricante Aplicativo                     ³
//³ mv_par13 - Nome do Aplicativo                                ³
//³ mv_par14 - Versão do Aplicativo                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                   
cCAB := ''

If cTipo == '000'
	cCab := cTipo                        // Tipo de Registro
	cCab += mv_par03                     // Ano Base
	cCab += STRZERO(mv_par06,9)          // NIF da Empresa
	cCab += PADR(mv_par07,70) 	         // Nome do Contato
	cCab += PADR(STRZERO(mv_par08,9),9)	 // Telefone Principal
	cCab += PADR(STRZERO(mv_par09,9),9)	 // Telefone Alternativo
	cCab += PADR(STRZERO(mv_par10,9),9)       // Fax
	cCab += PADR(mv_par11,70)     // e-mail
	cCab += PADR(mv_par12,70)	  // NOme da Empresa Fabricante
	cCab += PADR(mv_par13,40)	  // Nome do Aplicativo
	cCab += PADR(mv_par14,20)	  // Versão do Aplicativo
	cCab += cEOL 				  // caracter de fim de linha 
	f800LogTipo(cTipo)
Endif

Return(cCab)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f800GrvDet³ Autor ³ Abel Ribeiro          ³ Data ³21/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Detalhe dos Registros gravar no arquivo TXT                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            
                              
Function f800GrvDet(cTIPO,cSeq,cDESCRI)                      // Monta a linha com dados 
IF cTIPO == "100"
	/*
	C012	Tipo de Registo	3	A
	C013	Nome ou designação social da Entidade	70	A
	C014	Endereço	60	A
	C015	Localidade	40	A
	C016	Código Postal	4	N
	C017	Sufixo Postal	3	N
	C018	Localidade Postal	40	A
	C019	Telefone	9	N
	C020	Fax	9	N
	C021	Código de Distrito	2	N
	C022	Código de Concelho	2	N
	C023	Código de Actividade Económica (CAE-Ver.2.1)	5	N
	C024	Nº Estabelecimentos - Continente	4	N
	C025	Nº Estabelecimentos - R.A. Açores	4	N
	C026	Nº Estabelecimentos - R.A. Madeira	4	N
	C027	Nº de Trabalhadores do Quadro-H	5	N
	C028	Nº de Trabalhadores do Quadro-M	5	N
	C029	Nº de Trabalhadores não pertencentes ao Quadro-H	5	N
	C030	Nº de Trabalhadores não pertencentes ao Quadro-M	5	N
	*/
	    IF QRGR->RGR_TIPO = "N"                                // Grava com zeros a esquerda campos numericos
	       IF QRGR->RGR_CAMPO $ "C024/C025/C026"
 	          nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	          cDET += STRZERO(VAL(nCPO),4,0)
 	       ELSEIF QRGR->RGR_CAMPO $ "C027/C028/C029/C030"     
 	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
 	              cDET += STRZERO(VAL(nCPO),5,0)
	 	   ENDIF 
	    ENDIF
        IF QRGR->RGR_CAMPO == "C012"
		   cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)
		ELSEIF QRGR->RGR_CAMPO == "C013"
		   cNomEmp := SUBSTR(QRGR->RGR_DESCRI,1,70)
		   cDet += cNomEmp
	    ELSEIF QRGR->RGR_CAMPO == "C014"
	           cMORADA := SUBSTR(QRGR->RGR_DESCRI,1,60)
	           cDet += cMORADA
	    ELSEIF QRGR->RGR_CAMPO == "C015"
	           cLocalidade := SUBSTR(QRGR->RGR_DESCRI,1,40)
	           cDet    += cLocalidade
	    ELSEIF QRGR->RGR_CAMPO == "C016"
	           cCodPostal := SUBSTR(QRGR->RGR_DESCRI,1,4)
	           cDet += cCodPostal
	    ELSEIF QRGR->RGR_CAMPO == "C017"
	           cSufixo := SUBSTR(QRGR->RGR_DESCRI,1,3)
	           cDet += cSufixo
	    ELSEIF QRGR->RGR_CAMPO == "C018"
	           cLocalPostal := SUBSTR(QRGR->RGR_DESCRI,1,40)
	           cDet += cLocalPostal
	    ELSEIF QRGR->RGR_CAMPO == "C019"
	           cTelefone := SUBSTR(QRGR->RGR_DESCRI,1,9)
	           cDet +=  cTelefone
	    ELSEIF QRGR->RGR_CAMPO == "C020"
	           cFax := SUBSTR(QRGR->RGR_DESCRI,1,9)
	           cDet +=  cFax
	    ELSEIF QRGR->RGR_CAMPO == "C021"
	           nCPO       := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	           cDIstrito := STRZERO(VAL(nCPO),2,0)
	           cDet +=  cDIstrito
	    ELSEIF QRGR->RGR_CAMPO == "C022"   
    	       nCPO       := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	           cCodConsel := STRZERO(VAL(nCPO),2,0)
	           cDet +=  cCodConsel
	    ELSEIF QRGR->RGR_CAMPO == "C023"
	           nCPO  := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
 	           cCNAE := STRZERO(VAL(nCPO),5,0)
	           cDet +=  cCNAE
	    ENDIF                     

ELSEIF cTIPO == "200"		             
       /* Nome                                            		Tam Tipo
	    Nome ou designação social								70	A
		Endereço Estabelecimento								60	A
		Localidade												40	A
		Código Postal											4	N
		Sufixo Postal											3	N
		Localidade Postal										40	A
		Telefone												9	N
		Fax														9	N
		Código Distrito											2	N
		Código Concelho											2	N
		C.A.E											   		5	N
		C043 Nº de Trabalhadores do Quadro-H					4	N
		C044 Nº de Trabalhadores do Quadro-M					4	N
		C045 Nº de Trabalhadores não pertencentes ao Quadro-H	4	N
		C046 Nº de Trabalhadores não pertencentes ao Quadro-M	4	N
		C047 Nº de Contribuinte Segurança Social				11	N
		*/ 

        IF QRGR->RGR_TIPO == "N"
           IF QRGR->RGR_CAMPO $ "C043/C044/C045/C046" 
              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	          cDET += STRZERO(VAL(nCPO),4,0)
           ENDIF
           IF QRGR->RGR_CAMPO == "C047" 
              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,11)
 	          cDET += STRZERO(VAL(nCPO),11,0)
           ENDIF
        ENDIF      
        IF QRGR->RGR_CAMPO == "C031"
           cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)
        ELSEIF QRGR->RGR_CAMPO == "C032"
               cNomemp := SUBSTR(QRGR->RGR_DESCRI,1,70)                             //Endereço Estabelecimento
               cDet += cNomEmp
        ELSEIF QRGR->RGR_CAMPO == "C033"
              cMORADA := SUBSTR(QRGR->RGR_DESCRI,1,60)
              cDet += cMorada
        ELSEIF QRGR->RGR_CAMPO == "C034"                                    //Localidade
               cLocalidade := SUBSTR(QRGR->RGR_DESCRI,1,40)         
               cDet += cLocalidade
        ELSEIF QRGR->RGR_CAMPO == "C035"

               cCodPostal := SUBSTR(QRGR->RGR_DESCRI,1,4)
               cDet += cCodPostal
        ELSEIF QRGR->RGR_CAMPO == "C036"
               cSufixo := SUBSTR(QRGR->RGR_DESCRI,1,3)
               cDet += cSufixo
        ELSEIF QRGR->RGR_CAMPO == "C037"
               cLocalPostal := SUBSTR(QRGR->RGR_DESCRI,1,40)
               cDet += cLocalPostal
        ELSEIF QRGR->RGR_CAMPO == "C038"
               cTelefone := SUBSTR(QRGR->RGR_DESCRI,1,9)
               cDet += cTelefone
        ELSEIF QRGR->RGR_CAMPO == "C039"
               cFax    := SUBSTR(QRGR->RGR_DESCRI,1,9)
               cDet += cFax
        ELSEIF QRGR->RGR_CAMPO == "C040"          
	           nCPO       := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	           cDIstrito := STRZERO(VAL(nCPO),2,0)
	           cDet +=  cDIstrito
        ELSEIF QRGR->RGR_CAMPO == "C041"
    	       nCPO       := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	           cCodConsel := STRZERO(VAL(nCPO),2,0)
	           cDet +=  cCodConsel
        ELSEIF QRGR->RGR_CAMPO == "C042"
	           nCPO  := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
 	           cCNAE := STRZERO(VAL(nCPO),5,0)
	           cDet +=  cCNAE
        ENDIF    
        
       
ELSEIF cTIPO == "210"
		/*
		C048	Tipo de Registo	3	A
		C049	Segurança, Higiene, e Saúde - Conjunto/Separado	1	N
		C050	Actividade de Segurança e Higiene	1	N
		C051	Actividade de Saúde	1	N
		*/
        /* Se o campo C050 = 1 ou 4 ou o campo C051 = 1 
           o campo C058 tem de ser preenchido com o Nome do Director/Responsável dos Serviços internos ou do Trabalhador designado;
        */
       IF QRGR->RGR_CAMPO == "C050" 
          IF ALLTRIM(QRGR->RGR_DESCRI) $ "1*4" 
             lLog051 := .T.
          Endif
       Endif         

       IF QRGR->RGR_CAMPO == "C051" .And. lLog051
          IF ALLTRIM(QRGR->RGR_DESCRI) == "1"
             lLog058 := .T.
          Endif
       ENDIF         
		 /*
		  Se o campo C050 = 2 ou 3 ou o campo C051 = 2 ou 3 
		  o campo C067 tem de ser preenchido com o nome da empresa prestadora dos Serviços interempresas ou externos 
		  e o campo C073 tem de ser preenchido com o Nome do Director/Responsável dos Serviços interempresas ou externos;
		 */                                                                    
	 	 IF QRGR->RGR_CAMPO == "C049" 
		    IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
		       adD210Log[1] := ALLTRIM(QRGR->RGR_DESCRI)
		       lLog :=.T.
	        ENDIF 
   		    cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
		 ELSEIF QRGR->RGR_CAMPO == "C050" 
		        IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
		           adD210Log[2] := ALLTRIM(QRGR->RGR_DESCRI)
		           lLog :=.T.
		        ElseIF ALLTRIM(QRGR->RGR_DESCRI) $ "2*3" 
		           lLog051 := .T.
		        Endif 
		        cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
		 ELSEIF QRGR->RGR_CAMPO == "C051" .and. lLog051 
		        IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
		           adD210Log[3] := ALLTRIM(QRGR->RGR_DESCRI)
		           lLog :=.T.
		        ELSEIF ALLTRIM(QRGR->RGR_DESCRI) $ "2*3"
		               lLog067 := .T.
		        Endif 
  		        cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
		 ELSEIF QRGR->RGR_CAMPO == "C048" 
 	            cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)
 	     ENDIF
ELSEIF cTipo == "220"	
       /*
		C052	Tipo de Registo	3	A
		C053	Serviço Interno - Médicos Trabalho	2	N
		C054	Serviço Interno - Enfermeiros do Trabalho	2	N
		C055	Serviço Interno - Outros Enfermeiros	2	N
		C056	Serviço Interno - Técnicos Segurança e Higiene	2	N
		C057	Serviço Interno - Outro Pessoal	2	N
		C058	Nome do Responsável dos Serviços Internos	70	A
		
       */        
	   IF  QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
	       IF QRGR->RGR_CAMPO $ "C053/C054/C055/C056/C057"
	          nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	          cDET += STRZERO(VAL(nCPO),2,0)
	       ENDIF   
	   ENDIF
  	   IF QRGR->RGR_CAMPO == "C058" 
 	      cDet += SUBSTR(QRGR->RGR_DESCRI,1,70)
	   ELSEIF QRGR->RGR_CAMPO == "C052" 
	          cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)
	   ENDIF
ELSEIF 	cTIPO $ "25B/25C/25E/25F/25G/25H/25J/25K/25L/25P/25Q/240/242/253/254/255/257/258/259/263/265/272/274"   
        
        cDET   += StrTran(ALLTRIM(QRGR->RGR_DESCRI), cEOL, "")
          
ELSEIF cTIPO == "221"
        /*                                  Tam Tipo
		C059	Tipo de Registo	3	S
		C060	Nome Médico Trabalho	70	A
		C061	Nº Cédula Profissional MT	5	N
		C062	Nº Horas mensais	3	N
		
	    */
        IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
           IF QRGR->RGR_CAMPO == "C061" 
              IF EMPTY(QRGR->RGR_DESCRI)
                 aM221Log[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	             lLOG := .T.
 	          ENDIF   
 	          nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
 	          cDET += STRZERO(VAL(nCPO),5,0)
 	       ELSEIF QRGR->RGR_CAMPO == "C062"
                  IF EMPTY(QRGR->RGR_DESCRI)
                     aM221Log[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   

 	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	              cDET += STRZERO(VAL(nCPO),3,0)
 	       ENDIF        
 	    ELSE              
 	       IF QRGR->RGR_CAMPO == "C060"
              IF EMPTY(QRGR->RGR_DESCRI)
                 aM221Log[1] := QRGR->RGR_DESCRI
                 lLOG := .T.
              ENDIF
              cDet += SUBSTR(QRGR->RGR_DESCRI,1,70) 
	       ELSEIF QRGR->RGR_CAMPO == "C059"
	              cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	       ENDIF
	   ENDIF    
ELSEIF cTIPO == "222"
	   /*
		C063	Tipo de Registo	3	N
		C064	Nome do Técnico de Segurança e Higiene	70	A
		C065	Nível de Certificação	1	N
	   */
            
 	   IF QRGR->RGR_TIPO = "N"                          // Grava com zeros a esquerda campos numericos
          IF QRGR->RGR_CAMPO == "C065" 
 	          IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
                     aM222Log[2] := QRGR->RGR_DESCRI         // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
               ENDIF
               nCPO := ALLTRIM(QRGR->RGR_DESCRI)
 	           cDET += STR(VAL(nCPO),1)
 	   ELSE   
	       IF QRGR->RGR_CAMPO == "C064" 
 	          IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
                 aM222Log[1] := QRGR->RGR_DESCRI         // Grava Log para este Campo
 	             lLOG := .T.
              ENDIF
	          cDet += SUBSTR(QRGR->RGR_DESCRI,1,70)
           ENDIF
 	   ENDIF       
ELSEIF cTIPO == "223"
        /*
		C066	Tipo de Registo	3	A
		C067	Nome Empresa(s) Prestadora(s)	70	A
		C068	Serviço Externo - Médicos Trabalho	2	N
		C069	Serviço Externo - Enfermeiros do Trabalho	2	N
		C070	Serviço Externo - Outros Enfermeiros	2	N
		C071	Serviço Externo - Técnicos Segurança e Higiene	2	N
		C072	Serviço Externo - Outro Pessoal	2	N
		C073	Nome do Responsável dos Serviços Externos	70	A
		*/   
			
			IF QRGR->RGR_CAMPO == "C067"  .and. (lLog051 .or. lLog067)
	           IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI)) 
	              lLog073 := .T.
	              If aTotRegs[9] == 0                          //"Inconsistências na Pasta Organização SHST"
			         cLog := STR0055             
					 Aadd(aTitle,cLog)  
					 Aadd(aLog,{})
					 aTotRegs[9] := len(aLog)
				  EndIf	
				  Aadd(aLog[aTotRegs[9]], STR0051 ) 	        //"Nome da empresa prestadora dos Serviços interempresas ou externos deve ser preenchida                
	   			Endif 
    		ENDIF
	        IF QRGR->RGR_CAMPO == "C073"  .and. lLog073
	   			IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI)) 
			      If aTotRegs[10] == 0            
					 cLog := STR0055                    //"Inconsistências na Pasta Organização SHST"
					 Aadd(aTitle,cLog)  
					 Aadd(aLog,{})
					 aTotRegs[10] := len(aLog)
				  EndIf	                                
				  Aadd(aLog[aTotRegs[10]], STR0052 ) 	             //"Nome do Director/Responsável dos Serviços interempresas ou externos deve ser preenchida"         
			   ENDIF                
			ENDIF

			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
			   nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	           cDET += STRZERO(VAL(nCPO),2,0)

	 	    ELSE
	 	        IF QRGR->RGR_CAMPO $ "C067/C073"
			       cDET += SUBSTR(QRGR->RGR_DESCRI,1,70)
  	            ELSEIF QRGR->RGR_CAMPO == "C066"  
  	                   cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
                ENDIF
	 	    ENDIF
ELSEIF cTIPO == "224"
 	 	   /*                                   TAM TIPO
			C074	Tipo de Registo	3	A
			C075	Nome Médico Trabalho	70	A
			C076	Nº Cédula Profissional MT	5	N
			C077	Nº Horas mensais	3	N
			*/
 	 	    IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
	           IF QRGR->RGR_CAMPO == "C076" 
	              IF EMPTY(QRGR->RGR_DESCRI)
                     aM224Log[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
 	              cDET += STRZERO(VAL(nCPO),5,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C077"   
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM224Log[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
	 	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	                  cDet += STRZERO(VAL(nCPO),3,0)
	 	       ENDIF       
	 	    ELSE   
	 	       IF QRGR->RGR_CAMPO == "C075" 
	 	          IF EMPTY(QRGR->RGR_DESCRI)
                     aM224Log[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF 
 	              cDet += SUBSTR(QRGR->RGR_DESCRI,1,70)  
	 	       ENDIF
	 	    ENDIF   
ELSEIF cTIPO == "225"                                      
            /*
			C078	Tipo de Registo	3	A
			C079	Nome do Técnico de Segurança e Higiene	70	A
			C080	Nível de Certificação	1	N
		    */

		    IF QRGR->RGR_TIPO = "N"                          // Grava com zeros a esquerda campos numericos
	           IF QRGR->RGR_CAMPO == "C080" 
	 	          IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
                     aM225Log[2] := QRGR->RGR_DESCRI         // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
               ENDIF
	           nCPO := ALLTRIM(QRGR->RGR_DESCRI)
 	           cDET += STR(VAL(nCPO),1)
	 	    ELSE   
		       IF QRGR->RGR_CAMPO == "C078"  
  	              cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
		       ELSEIF QRGR->RGR_CAMPO == "C079" 
	 	          IF EMPTY(ALLTRIM(QRGR->RGR_DESCRI))
                     aM225Log[1] := QRGR->RGR_DESCRI         // Grava Log para este Campo
 	                 lLOG := .T.                        
 	              ENDIF
 	              cDet += SUBSTR(QRGR->RGR_DESCRI,1,70)   
               ENDIF
            ENDIF
ELSEIF cTIPO == "230"
			/*	 	     
			C081	Tipo de Registo	3	A
			C082	Trab. < 18 anos - H	4	N
			C083	Trab. < 18 anos - M	4	N
			C084	Trab. 18 a 49 anos - H	4	N
			C085	Trab. 18 a 49 anos - M	4	N
			C086	Trab. > 49 anos - H	4	N
			C087	Trab. > 49 anos - M	4	N
			C088	Trab. Horário Normal - H	4	N
			C089	Trab. Horário Normal - M	4	N
			C090	Trab. Turno Fixo - H	4	N
			C091	Trab. Turno Fixo - M	4	N
			C092	Trab. Turno Rotativo - H	4	N
			C093	Trab. Turno Rotativo - M	4	N
			C094	Trab. Horário Nocturno - H	4	N
			C095	Trab. Horário Nocturno - M	4	N
			C096	Trab. Outros Horários - H	4	N
			C097	Trab. Outros Horários - M	4	N
			C098	Nº Total horas trabalhadas	9	N
			
			*/ 	    
	 	    IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
	           IF QRGR->RGR_CAMPO == "C098"  
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,9)
 	              cDET += STRZERO(VAL(nCPO),9,0)
	 	       ELSE
  	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
	 	       ENDIF 
	 	    ELSEIF QRGR->RGR_CAMPO == "C081"  
  	               cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
 	 	    ENDIF
ELSEIF cTIPO == "241"
            /*
			C100	Tipo de Registo	3	A
			C101	Inform.Riscos - 1 - H	4	N
			C102	Inform.Riscos - 1 - M	4	N
			C103	Inform.Riscos - 2 - H	4	N
			C104	Inform.Riscos - 2 - M	4	N
			C105	Inform.Riscos - 3 - H	4	N
			C106	Inform.Riscos - 3 - M	4	N
			C107	Inform.Riscos - 4 - H	4	N
			C108	Inform.Riscos - 4 - M	4	N
			C109	Inform.Riscos - 5 - H	4	N
			C110	Inform.Riscos - 5 - M	4	N
			C111	Inform.Riscos - 6 - H	4	N
			C112	Inform.Riscos - 6 - M	4	N
			C113	Inform.Riscos - 7 - H	4	N
			C114	Inform.Riscos - 7 - M	4	N
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
	 	    ELSE                          
	 	        IF QRGR->RGR_CAMPO == "C100"  
  	               cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	 	        ENDIF
	 	    ENDIF    
ELSEIF cTIPO == "243"	
			/*
			C116	Tipo de Registo	3	A
			C117	Objectivos da Acção Formação		100	A
			C118	Nº Acções realizadas				3	N
			C119	Duração média cada acção (horas)	3	N
			C120	Destinatários 						100	A
			C121	Nº Participantes - H				4	N
			C122	Nº Participantes - M				4	N
			*/	 
			
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
	 	       IF QRGR->RGR_CAMPO $ "C118"
   	              IF EMPTY(QRGR->RGR_DESCRI)
                     aM243Log[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF
	 	          nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	              cDET += STRZERO(VAL(nCPO),3,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C119"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM243Log[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
 	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	                  cDET += STRZERO(VAL(nCPO),3,0)
 	           ELSEIF QRGR->RGR_CAMPO == "C121"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM243Log[5] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
 	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)      
 	           ELSEIF QRGR->RGR_CAMPO == "C122"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM243Log[6] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
 	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)      
 	           ENDIF          
	 	    ELSE                   
	 	       IF QRGR->RGR_CAMPO == "C117"
   	              IF EMPTY(QRGR->RGR_DESCRI)
                     aM243Log[1] := QRGR->RGR_DESCRI          // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF
   			      cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
 	           ELSEIF QRGR->RGR_CAMPO == "C120"   
 	           	       IF EMPTY(QRGR->RGR_DESCRI)
                          aM243Log[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                      lLOG := .T.
 	                   ENDIF 
			           cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
 	           ENDIF
	 	    ENDIF
	 	    
ELSEIF cTIPO == "244"	
			/*                                 TAM TIPO
			C123	Tipo de Registo	3	A
			C124	Nº Trab. Sem Formação - H	4	N
			C125	Nº Trab. Sem Formação - M	4	N
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
	 	    ELSE
	 	          IF QRGR->RGR_CAMPO == "C123"  
                     cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	              ENDIF
	 	    ENDIF
ELSEIF cTIPO == "245"	
            /*
			C126	Tipo de Registo				3	A
			C127	Objectivos Acção Formação	100	A
			C128	Nº Acções realizadas		3	N
			C129	Duração média cada acção (h)3	N
			C130	Nº Participantes - H		4	N
			C131	Nº Participantes - M		4	N
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
			   IF QRGR->RGR_CAMPO == "C128"
	              IF EMPTY(QRGR->RGR_DESCRI)
                     aM245Log[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	              cDET += STRZERO(VAL(nCPO),3,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C129" 
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM245Log[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF   
	 	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	                  cDET += STRZERO(VAL(nCPO),3,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C130" 
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM245Log[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF   
	 	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 		              cDET += STRZERO(VAL(nCPO),4,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C131" 
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM245Log[5] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF   
	 	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 		              cDET += STRZERO(VAL(nCPO),4,0)
	 	       ENDIF
	 	    ELSE 
	 	          IF QRGR->RGR_CAMPO == "C127"
	 	             IF EMPTY(QRGR->RGR_DESCRI)
                        aM245Log[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                    lLOG := .T.
 	                 ENDIF   
 	                 cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
 	             ENDIF        
	 	    ENDIF 
         
ELSEIF cTIPO == "246"	
/*
C132	Tipo de Registo	3	A
C133	Razões Consulta 1 - Destinatários	100	A
C134	Razões Consulta 1 - Forma			100	A
C135	Razões Consulta 1 - Nº Acções	3	N
C136	Razões Consulta 2 - Destinatários	100	A
C137	Razões Consulta 2 - Forma			100	A
C138	Razões Consulta 2 - Nº Acções	3	N
C139	Razões Consulta 3 - Destinatários	100	A
C140	Razões Consulta 3 - Forma			100	A
C141	Razões Consulta 3 - Nº Acções	3	N
C142	Razões Consulta 4 - Destinatários	100	A
C143	Razões Consulta 4 - Forma			100	A
C144	Razões Consulta 4 - Nº Acções	3	N
C145	Razões Consulta 5 - Destinatários	100	A
C146	Razões Consulta 5 - Forma			100	A
C147	Razões Consulta 5 - Nº Acções	3	N
C148	Razões Consulta 6 - Destinatários	100	A
C149	Razões Consulta 6 - Forma			100	A
C150	Razões Consulta 6 - Nº Acções	3	N
C151	Razões Consulta 7 - Destinatários	100	A
C152	Razões Consulta 7 - Forma			100	A
C153	Razões Consulta 7 - Nº Acções	3	N
*/
			
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
               nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	           cDET += STRZERO(VAL(nCPO),3,0)
	 	    ELSE  
	 	       IF QRGR->RGR_CAMPO $ "C133/C134/C136/C137/C139/C140/C142/C143/C145/C146/C148/C149/C151/C152" 
  			      cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
	 	       ELSEIF QRGR->RGR_CAMPO == "C132"  
  	                   cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	 	       ENDIF
	 	    ENDIF      
ELSEIF cTIPO == "250"	
			/*
			C154	Tipo de Registo	3	A
			C155	Objecto da Intervenção - Instalações	1	N
			C156	Natureza da Intervenção - Instalações	1	N
			C157	Natureza da Intervenção - Instalações	1	N
			C158	Natureza da Intervenção - Instalações	1	N
			C159	Natureza da Intervenção - Instalações	1	N
			C160	Objecto da Intervenção - Equipamentos	1	N
			C161	Natureza da Intervenção - Equipamentos	1	N
			C162	Natureza da Intervenção - Equipamentos	1	N
			C163	Natureza da Intervenção - Equipamentos	1	N
			C164	Natureza da Intervenção - Equipamentos	1	N
			C165	Objecto da Intervenção - Processos	1	N
			C166	Natureza da Intervenção - Processos	1	N
			C167	Natureza da Intervenção - Processos	1	N
			C168	Natureza da Intervenção - Processos	1	N
			C169	Natureza da Intervenção - Processos	1	N
			C170	Objecto da Intervenção - Postos de Trabalho	1	N
			C171	Natureza da Intervenção - Postos de Trabalho	1	N
			C172	Natureza da Intervenção - Postos de Trabalho	1	N
			C173	Natureza da Intervenção - Postos de Trabalho	1	N
			C174	Natureza da Intervenção - Postos de Trabalho	1	N
			
*/   
			 IF QRGR->RGR_CAMPO == "C154"  
  	            cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	         ELSE
			    cDet += Alltrim(QRGR->RGR_DESCRI)
			 ENDIF   
ELSEIF cTIPO == "251"	
			/*
			C175	Tipo de Registo	3	A
			C176	Nome Empresa Auditora	70	A
			C177	Nº de Auditorias	2	N
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,2)
 	           cDET += STRZERO(VAL(nCPO),2,0)
	 	    ELSEIF QRGR->RGR_CAMPO == "C175"  
                   cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	        ELSEIF QRGR->RGR_CAMPO == "C176"  
			   cDet += SUBSTR(QRGR->RGR_DESCRI,1,70)
	 	    ENDIF	                 
ELSEIF cTIPO == "252"	
/*
C178	Tipo de Registo						3	A
C179	Tipo de Iluminação - Natural		1	N
C180	Tipo de Iluminação - Mista			1	N
C181	Tipo de Iluminação - Artificial		1	N
C182	Tipo de Iluminação - De Emergência	1	N
C183	Medidas - 1 - Nº de Avaliações		3	N
C184	Medidas - 1 - Resultado				1	A
C185	Medidas - 2 - Nº de Avaliações		3	N
C186	Medidas - 2 - Resultado				1	A
C187	Medidas - 3 - Nº de Avaliações		3	N
C188	Medidas - 3 - Resultado				1	A
C189	Medidas - 4 - Nº de Avaliações		3	N
C190	Medidas - 4 - Resultado				1	A
C191	Medidas - 5 - Descrição				100	A
C192	Medidas - 5 - Nº de Avaliações		3	N
C193	Medidas - 5 - Resultado				1	A
*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
			   IF QRGR->RGR_CAMPO $ "C183/C185/C187/C189/C192"
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	              cDET += STRZERO(VAL(nCPO),3,0)
	 	       ELSEIF QRGR->RGR_CAMPO $ "C179/C180/C181/C182"
	 	              cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
	 	       ENDIF       
	 	    ELSE
	           IF QRGR->RGR_CAMPO == "C191"  
			      cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
			   ELSEIF QRGR->RGR_CAMPO $ "C184/C186/C188/C190/C193" 
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
			   ENDIF
			ENDIF      
ELSEIF cTIPO == "256"	
/*                                             TAM
C197	Tipo de Registo							3	A
C198	Ambiente Térmico - 1 - Nº de Avaliações	3	N
C199	Ambiente Térmico - 1 - Resultado		1	A
C200	Ambiente Térmico - 2 - Nº de Avaliações	3	N
C201	Ambiente Térmico - 2 - Resultado		1	A
C202	Ambiente Térmico - 3 - Nº de Avaliações	3	N
C203	Ambiente Térmico - 3 - Resultado		1	A
C204	Ambiente Térmico - 4 - Nº de Avaliações	3	N
C205	Ambiente Térmico - 4 - Resultado		1	A
C206	Ambiente Térmico - 5 - Nº de Avaliações	3	N
C207	Ambiente Térmico - 5 - Resultado 		1	A
C208	Ambiente Térmico - 6 - Nº de Avaliações	3	N
C209	Ambiente Térmico - 6 - Resultado 		1	A
C210	Ambiente Térmico - 7 - Descrição		100	A
C211	Ambiente Térmico - 7 - Nº de Avaliações	3	N
C212	Ambiente Térmico - 7 - Resultado   		1	A
*/
			IF QRGR->RGR_TIPO = "N"
			   IF QRGR->RGR_CAMPO $ "C198/C200/C202/C204/C206/C208/C211"
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	              cDET += STRZERO(VAL(nCPO),3,0)
 	           ENDIF   
	 	    ELSE
	 	       IF QRGR->RGR_CAMPO == "C210"  
			      cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
               ELSEIF QRGR->RGR_CAMPO $ "C199/C201/C203/C205/C207/C209/C212"
			      cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
	 	       ENDIF
	 	    ENDIF      
ELSEIF cTIPO == "25A"	
			/*	 	    
			C216	Tipo de Registo					3	A
			C217	Código do Agente Físico			2	A
			C218	Nº Trab. Expostos - H			4	N
			C219	Nº Trab. Expostos - M			4	N
			C220	Código Medidas Adoptadas - 1	2	A
			C221	Código Medidas Adoptadas - 2	2	A
			C222	Código Medidas Adoptadas - 3	2	A
			C223	Nº Avaliações					3	N
			C224	Resultado última avaliação		2	A
			*/	
   			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
		       IF QRGR->RGR_CAMPO == "C218"
	              IF EMPTY(QRGR->RGR_DESCRI)
                     aM25ALog[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
	           ELSEIF QRGR->RGR_CAMPO == "C219"
	                  IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ALog[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF 
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)
               ELSEIF QRGR->RGR_CAMPO == "C223"
	                  IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ALog[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF 
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	                  cDET += STRZERO(VAL(nCPO),3,0)
	 	       ENDIF
	 	    ELSE                        
	 	       IF QRGR->RGR_CAMPO = "C217"
   	              IF EMPTY(QRGR->RGR_DESCRI)
                     aM25ALog[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF                             
 	              cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
	           ELSEIF QRGR->RGR_CAMPO == "C224"
	                 IF EMPTY(QRGR->RGR_DESCRI)
                        aM25ALog[5] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                    lLOG := .T.
 	                 ENDIF
      	             cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
 	 	       ELSEIF QRGR->RGR_CAMPO $ "C220/C221/C222"
	                 cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
 	 	       ENDIF
 	 	    ENDIF        
ELSEIF cTIPO == "25D"	
			/*	
			C227	Tipo de Registo					3	A
			C228	Código do Agente Químico (Id)	4	N
			C229	Código EINECS					10	A
			C230	Menção de risco					3	A
			C231	Nº Trab. Expostos - H			4	N
			C232	Nº Trab. Expostos - M			4	N
			C233	Código Medida Adoptada			2	A
			C234	Nº Avaliações					3	N
			C235	Resultado última avaliação		2	A
			*/
   			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
		       IF QRGR->RGR_CAMPO == "C228"
		          IF EMPTY(QRGR->RGR_DESCRI)
                     aM25DLog[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C231"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF   
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C232"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[5] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF   
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C234"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[7] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF   
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	                  cDET += STRZERO(VAL(nCPO),3,0)
	 	       ENDIF
	 	    ELSE                                  
     		   IF QRGR->RGR_CAMPO == "C227"  
                  cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	 	       ELSEIF QRGR->RGR_CAMPO == "C229"     
	 	              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF                                                                 
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,10)
			   ELSEIF QRGR->RGR_CAMPO == "C233"     
			          IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[6] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
			   ELSEIF QRGR->RGR_CAMPO == "C235"     
			          IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[7] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
			   ELSEIF QRGR->RGR_CAMPO == "C230"     
			          IF EMPTY(QRGR->RGR_DESCRI)
                         aM25DLog[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,3)
			   ENDIF   
	 	    ENDIF     
ELSEIF cTIPO == "25I"	
			/*		 	    
			C240	Tipo de Registo	3	A
			C241	Identificação do Agente Biológico	100	A
			C242	Classificação do Agente Biológico	1	N
			C243	Nº Trab. Expostos - H	4	N
			C244	Nº Trab. Expostos - M	4	N
			C245	Código Medida Adoptada	2	A
			C246	Nº Avaliações	3	N
			C247	Resultado última avaliação	2	A
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
		       IF QRGR->RGR_CAMPO == "C242"
		          IF EMPTY(QRGR->RGR_DESCRI)
                     aM25ILog[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
 	              cDET += SUBSTR(QRGR->RGR_DESCRI,1,1)
	 	       ELSEIF QRGR->RGR_CAMPO == "C243"
		              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ILog[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF    	              
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C244"
		              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ILog[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF    	              
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	                  cDET += STRZERO(VAL(nCPO),4,0)
	 	       ELSEIF QRGR->RGR_CAMPO == "C246"
		              IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ILog[6] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF    	              
   	                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,3)
 	                  cDET += STRZERO(VAL(nCPO),3,0)
	 	       ENDIF
	 	    ELSE 
	 	       IF QRGR->RGR_CAMPO == "C241"     
	 	          IF EMPTY(QRGR->RGR_DESCRI)
                     aM25ILog[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
			      cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
			   ELSEIF QRGR->RGR_CAMPO == "C245"     
			          IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ILog[5] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
			   ELSEIF QRGR->RGR_CAMPO == "C247"     
			          IF EMPTY(QRGR->RGR_DESCRI)
                         aM25ILog[7] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                     lLOG := .T.
 	                  ENDIF
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,2)
			   ENDIF   
	 	    ENDIF
ELSEIF cTIPO == "25M"	
			/*
			C251	Tipo de Registo	3	A
			C252	Beneficiações/Correcções - 1	1	N
			C253	Beneficiações/Correcções - 2	1	N
			C254	Beneficiações/Correcções - 3	1	N
			C255	Beneficiações/Correcções - 4	1	N
			C256	Beneficiações/Correcções - 5	1	N
			C257	Beneficiações/Correcções - 6	1	N
			C258	Beneficiações/Correcções - 7	1	N
			C259	Beneficiações/Correcções - 8	1	N
			C260	Beneficiações/Correcções - 9	1	N
			C261	Beneficiações/Correcções - 10	1	N
			C262	Beneficiações/Correcções - 11	1	N
			C263	Beneficiações/Correcções - 12 - Descrição	100	A
			C264	Beneficiações/Correcções - 12	1	A
			*/ 
			IF QRGR->RGR_TIPO = "N"        
 	           cDET += SUBSTR(QRGR->RGR_DESCRI,1,1)
		    ELSE
		        IF QRGR->RGR_CAMPO = "C263"
			       cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
			    ELSEIF QRGR->RGR_CAMPO = "C264"
			       cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
			    ENDIF   
            ENDIF
ELSEIF cTIPO == "25N"	
			/*
			C265	Tipo de Registo	3	A
			C266	Interv. nos Locais de Trabalho -1- Nº Trab. - H	4	N
			C267	Interv. nos Locais de Trabalho -1- Nº Trab. - M	4	N
			C268	Interv. nos Locais de Trabalho -2- Nº Trab. - H	4	N
			C269	Interv. nos Locais de Trabalho -2- Nº Trab. - M	4	N
			C270	Interv. nos Locais de Trabalho -3- Nº Trab. - H	4	N
			C271	Interv. nos Locais de Trabalho -3- Nº Trab. - M	4	N
			C272	Interv. nos Locais de Trabalho -4- Nº Trab. - H	4	N
			C273	Interv. nos Locais de Trabalho -4- Nº Trab. - M	4	N
			C274	Interv. nos Locais de Trabalho -5- Nº Trab. - H	4	N
			C275	Interv. nos Locais de Trabalho -5- Nº Trab. - M	4	N
			C276	Interv. nos Locais de Trabalho -6- Nº Trab. - H	4	N
			C277	Interv. nos Locais de Trabalho -6- Nº Trab. - M	4	N
			C278	Interv. nos Locais de Trabalho -7- Nº Trab. - H	4	N
			C279	Interv. nos Locais de Trabalho -7- Nº Trab. - M	4	N
			C280	Interv. nos Locais de Trabalho -8- Nº Trab. - H	4	N
			C281	Interv. nos Locais de Trabalho -8- Nº Trab. - M	4	N
			C282	Interv. nos Locais de Trabalho -9- Nº Trab. - H	4	N
			C283	Interv. nos Locais de Trabalho -9- Nº Trab. - M	4	N
			C284	Interv. nos Locais de Trabalho -10- Nº Trab. - H	4	N
			C285	Interv. nos Locais de Trabalho -10- Nº Trab. - M	4	N
			C286	Interv. nos Locais de Trabalho -11- Nº Trab. - H	4	N
			C287	Interv. nos Locais de Trabalho -11- Nº Trab. - M	4	N
			C288	Interv. nos Locais de Trabalho -12- Descrição	100	A
			C289	Interv. nos Locais de Trabalho -12- Nº Trab. - H	4	N
			C290	Interv. nos Locais de Trabalho -12- Nº Trab. - M	4	N
			C291	Interv. nas Práticas de Trabalho -1- Nº Trab. - H	4	N
			C292	Interv. nas Práticas de Trabalho -1- Nº Trab. - M	4	N
			C293	Interv. nas Práticas de Trabalho -2- Nº Trab. - H	4	N
			C294	Interv. nas Práticas de Trabalho -2- Nº Trab. - M	4	N
			C295	Interv. nas Práticas de Trabalho -3- Nº Trab. - H	4	N
			C296	Interv. nas Práticas de Trabalho -3- Nº Trab. - M	4	N
			C297	Interv. nas Práticas de Trabalho -4- Nº Trab. - H	4	N
			C298	Interv. nas Práticas de Trabalho -4- Nº Trab. - M	4	N
			C299	Interv. nas Práticas de Trabalho -5- Nº Trab. - H	4	N
			C300	Interv. nas Práticas de Trabalho -5- Nº Trab. - M	4	N
			C301	Interv. nas Práticas de Trabalho -6- Nº Trab. - H	4	N
			C302	Interv. nas Práticas de Trabalho -6- Nº Trab. - M	4	N
			C303	Interv. nas Práticas de Trabalho -7- Nº Trab. - H	4	N
			C304	Interv. nas Práticas de Trabalho -7- Nº Trab. - M	4	N
			C305	Interv. nas Práticas de Trabalho -8- Nº Trab. - H	4	N
			C306	Interv. nas Práticas de Trabalho -8- Nº Trab. - M	4	N
			C307	Interv. nas Práticas de Trabalho -9- Nº Trab. - H	4	N
			C308	Interv. nas Práticas de Trabalho -9- Nº Trab. - M	4	N
			C309	Interv. nas Práticas de Trabalho -10- Nº Trab. - H	4	N
			C310	Interv. nas Práticas de Trabalho -10- Nº Trab. - M	4	N
			C311	Interv. nas Práticas de Trabalho -11- Descrição	100	A
			C312	Interv. nas Práticas de Trabalho -11- Nº Trab. - H	4	N
			C313	Interv. nas Práticas de Trabalho -11- Nº Trab. - M	4	N
			C314	Disp. Prev.Riscos Mov.Manual Carga - H	4	N
			C315	Disp. Prev.Riscos Mov.Manual Carga - M	4	N
			C316	Disp. Prev.Riscos Posturas - H	4	N
			C317	Disp. Prev.Riscos Posturas - M	4	N
			C318	Disp. Prev.Riscos Equip.c/Visor - H	4	N
			C319	Disp. Prev.Riscos Equip.c/Visor - M	4	N
			C320	Outros Dispositivos - Descrição	100	A
			C321	Outros Dispositivos - H	4	N
			C322	Outros Dispositivos - M	4	N
			*/
			
			IF QRGR->RGR_TIPO = "N"
			      nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
	 	    ELSE
                  IF QRGR->RGR_CAMPO $ "C288/C311/C320"
			         cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
                  ENDIF
	 	    ENDIF
  
ELSEIF cTIPO == "25O"	
			/*      
			C323	Tipo de Registo	3	A
			C324	Protec. Colectiva - Riscos -1- NºTrab - H		4	N
			C325	Protec. Colectiva - Riscos -1- NºTrab - M		4	N
			C326	Protec. Colectiva - Riscos -2- NºTrab - H		4	N
			C327	Protec. Colectiva - Riscos -2- NºTrab - M		4	N
			C328	Protec. Colectiva - Riscos -3- NºTrab - H		4	N
			C329	Protec. Colectiva - Riscos -3- NºTrab - M		4	N
			C330	Protec. Colectiva - Riscos -4- NºTrab - H		4	N
			C331	Protec. Colectiva - Riscos -4- NºTrab - M		4	N
			C332	Protec. Colectiva - Riscos -5- NºTrab - H		4	N
			C333	Protec. Colectiva - Riscos -5- NºTrab - M		4	N
			C334	Protec. Colectiva - Riscos -6- NºTrab - H		4	N
			C335	Protec. Colectiva - Riscos -6- NºTrab - M		4	N
			C336	Protec. Colectiva - Riscos -7- NºTrab - H		4	N
			C337	Protec. Colectiva - Riscos -7- NºTrab - M		4	N
			C338	Protec. Colectiva - Riscos -8- NºTrab - H		4	N
			C339	Protec. Colectiva - Riscos -8- NºTrab - M		4	N
			C340	Protec. Colectiva - Riscos -9- Descrição		100	A
			C341	Protec. Colectiva - Riscos -9- NºTrab - H		4	N
			C342	Protec. Colectiva - Riscos -9- NºTrab - M		4	N
			C343	Tipos EPI's Utilizados - 1 - NºTrab - H			4	N
			C344	Tipos EPI's Utilizados - 1 - NºTrab - M			4	N
			C345	Tipos EPI's Utilizados - 2 - NºTrab - H			4	N
			C346	Tipos EPI's Utilizados - 2 - NºTrab - M			4	N
			C347	Tipos EPI's Utilizados - 3 - NºTrab - H			4	N
			C348	Tipos EPI's Utilizados - 3 - NºTrab - M			4	N
			C349	Tipos EPI's Utilizados - 4 - NºTrab - H			4	N
			C350	Tipos EPI's Utilizados - 4 - NºTrab - M			4	N
			C351	Tipos EPI's Utilizados - 5 - NºTrab - H			4	N
			C352	Tipos EPI's Utilizados - 5 - NºTrab - M			4	N
			C353	Tipos EPI's Utilizados - 6 - NºTrab - H			4	N
			C354	Tipos EPI's Utilizados - 6 - NºTrab - M			4	N
			C355	Tipos EPI's Utilizados - 7 - NºTrab - H			4	N
			C356	Tipos EPI's Utilizados - 7 - NºTrab - M			4	N
			C357	Tipos EPI's Utilizados - 8 - NºTrab - H			4	N
			C358	Tipos EPI's Utilizados - 8 - NºTrab - M			4	N
			C359	Tipos EPI's Utilizados - 9 - NºTrab - H			4	N
			C360	Tipos EPI's Utilizados - 9 - NºTrab - M			4	N
			C361	Tipos EPI's Utilizados - 10 - NºTrab - H		4	N
			C362	Tipos EPI's Utilizados - 10 - NºTrab - M		4	N
			C363	Tipos EPI's Utilizados - 11 - NºTrab - H		4	N
			C364	Tipos EPI's Utilizados - 11 - NºTrab - M		4	N
			C365	Tipos EPI's Utilizados - 12 - NºTrab - H		4	N
			C366	Tipos EPI's Utilizados - 12 - NºTrab - M		4	N
			C367	Tipos EPI's Utilizados - 13 - NºTrab - H		4	N
			C368	Tipos EPI's Utilizados - 13 - NºTrab - M		4	N
			C369	Tipos EPI's Utilizados - 14 - NºTrab - H		4	N
			C370	Tipos EPI's Utilizados - 14 - NºTrab - M		4	N
			C371	Tipos EPI's Utilizados - 15 - Descrição	 		100	A
			C372	Tipos EPI's Utilizados - 15 - NºTrab - H		4	N
			C373	Tipos EPI's Utilizados - 15 - NºTrab - M		4	N
			C374	Medidas Protec. Indiv. - 1						1	N
			C375	Medidas Protec. Indiv. - 2						1	N
			C376	Medidas Protec. Indiv. - 3						1	N
			C377	Medidas Protec. Indiv. - 4						1	N
			C378	Medidas Protec. Indiv. - 5						1	N
			C379	Medidas Protec. Indiv. - 6						1	N
			C380	Medidas Protec. Indiv. - 7 - Descrição			100	A
			C381	Medidas Protec. Indiv. - 7						1	N
			
			*/
			IF QRGR->RGR_TIPO = "N"   
			   IF QRGR->RGR_CAMPO $ "C374/C375/C376/C377/C378/C379/C381"                            // Grava com zeros a esquerda campos  
                  cDet += SUBSTR(QRGR->RGR_DESCRI,1,1)
               ELSE
                  nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	              cDET += STRZERO(VAL(nCPO),4,0)
 	           ENDIF   
	 	    ELSE 
	 	        IF QRGR->RGR_CAMPO $ "C340/C371/C380"
			       cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
                ENDIF
	 	    ENDIF
ELSEIF cTIPO == "260"	
			/*
			C382	Tipo de Registo	3	A	=260	S
			C383	Exames Admissão < 18 anos - H				4	N		
			C384	Exames Admissão < 18 anos - M				4	N		
			C385	Exames Admissão - 18 e 49 anos - H			4	N		
			C386	Exames Admissão - 18 e 49 anos - M			4	N		
			C387	Exames Admissão > 49 anos - H				4	N		
			C388	Exames Admissão > 49 anos - M				4	N		
			C389	Exames Periódicos < 18 anos - H				4	N		
			C390	Exames Periódicos < 18 anos - M				4	N		
			C391	Exames Periódicos - 18 e 49 anos - H		4	N		
			C392	Exames Periódicos - 18 e 49 anos - M		4	N		
			C393	Exames Periódicos > 49 anos - H				4	N		
			C394	Exames Periódicos > 49 anos - M				4	N		
			C395	Exames Ocas. - 1 - < 18 anos - H			4	N		
			C396	Exames Ocas. - 1 - < 18 anos - M			4	N		
			C397	Exames Ocas. - 1 - Entre 18 e 49 anos - H	4	N		
			C398	Exames Ocas. - 1 - Entre 18 e 49 anos - M	4	N		
			C399	Exames Ocas. - 1 - > 49 anos - H			4	N		
			C400	Exames Ocas. - 1 - > 49 anos - M			4	N		
			C401	Exames Ocas. - 2 - < 18 anos - H			4	N		
			C402	Exames Ocas. - 2 - < 18 anos - M			4	N		
			C403	Exames Ocas. - 2 - Entre 18 e 49 anos - H	4	N		
			C404	Exames Ocas. - 2 - Entre 18 e 49 anos - M	4	N		
			C405	Exames Ocas. - 2 - > 49 anos - H	  		4	N		
			C406	Exames Ocas. - 2 - > 49 anos - M			4	N		
			C407	Exames Ocas. - 3 - < 18 anos - H			4	N		
			C408	Exames Ocas. - 3 - < 18 anos - M			4	N		
			C409	Exames Ocas. - 3 - Entre 18 e 49 anos - H	4	N		
			C410	Exames Ocas. - 3 - Entre 18 e 49 anos - M	4	N		
			C411	Exames Ocas. - 3 - > 49 anos - H			4	N		
			C412	Exames Ocas. - 3 - > 49 anos - M			4	N		
			C413	Exames Ocas. - 4 - < 18 anos - H			4	N		
			C414	Exames Ocas. - 4 - < 18 anos - M			4	N		
			C415	Exames Ocas. - 4 - Entre 18 e 49 anos - H	4	N		
			C416	Exames Ocas. - 4 - Entre 18 e 49 anos - M	4	N		
			C417	Exames Ocas. - 4 - > 49 anos - H			4	N		
			C418	Exames Ocas. - 4 - > 49 anos - M			4	N		
			C419	Exames Ocas. - 5 - < 18 anos - H			4	N		
			C420	Exames Ocas. - 5 - < 18 anos - M			4	N		
			C421	Exames Ocas. - 5 - Entre 18 e 49 anos - H	4	N		
			C422	Exames Ocas. - 5 - Entre 18 e 49 anos - M	4	N		
			C423	Exames Ocas. - 5 - > 49 anos - H			4	N		
			C424	Exames Ocas. - 5 - > 49 anos - M			4	N		
			C425	Exames Ocas. - 6 - < 18 anos - H			4	N		
			C426	Exames Ocas. - 6 - < 18 anos - M			4	N		
			C427	Exames Ocas. - 6 - Entre 18 e 49 anos - H	4	N		
			C428	Exames Ocas. - 6 - Entre 18 e 49 anos - M	4	N		
			C429	Exames Ocas. - 6 - > 49 anos - H			4	N		
			C430	Exames Ocas. - 6 - > 49 anos - M			4	N		
			C431	Exames Ocas. - 7 - < 18 anos - H			4	N		
			C432	Exames Ocas. - 7 - < 18 anos - M			4	N		
			C433	Exames Ocas. - 7 - Entre 18 e 49 anos - H	4	N		
			C434	Exames Ocas. - 7 - Entre 18 e 49 anos - M	4	N		
			C435	Exames Ocas. - 7 - > 49 anos - H			4	N		
			C436	Exames Ocas. - 7 - > 49 anos - M			4	N		
			C437	Exames Ocas. - 8 - < 18 anos - H			4	N		
			C438	Exames Ocas. - 8 - < 18 anos - M			4	N		
			C439	Exames Ocas. - 8 - Entre 18 e 49 anos - H	4	N		
			C440	Exames Ocas. - 8 - Entre 18 e 49 anos - M	4	N		
			C441	Exames Ocas. - 8 - > 49 anos - H			4	N		
			C442	Exames Ocas. - 8 - > 49 anos - M			4	N		
			C443	Exames Ocas. - 9 - < 18 anos - H			4	N		
			C444	Exames Ocas. - 9 - < 18 anos - M			4	N		
			C445	Exames Ocas. - 9 - Entre 18 e 49 anos - H	4	N		
			C446	Exames Ocas. - 9 - Entre 18 e 49 anos - M	4	N		
			C447	Exames Ocas. - 9 - > 49 anos - H			4	N		
			C448	Exames Ocas. - 9 - > 49 anos - M			4	N		
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	           cDET += STRZERO(VAL(nCPO),4,0)
	 	    ENDIF
ELSEIF cTIPO == "261"	
			/*
			C451	Tipo de Registo	3	A
			C452	Exame Sangue - Total Exames	4	N
			C453	Exame Sangue - Exames obrigatórios	4	N
			C454	Exame Urina - Total Exames	4	N
			C455	Exame Urina - Exames obrigatórios	4	N
			C456	Exame Rx Tórax - Total Exames	4	N
			C457	Exame Rx Tórax - Exames obrigatórios	4	N
			C458	Exame Audiograma - Total Exames	4	N
			C459	Exame Audiograma - Exames obrigatórios	4	N
			C460	Exame Outros - Total Exames	4	N
			C461	Exame Outros - Exames obrigatórios	4	N
			
			*/ 
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	           cDET += STRZERO(VAL(nCPO),4,0)
	 	    ENDIF
ELSEIF cTIPO == "262"	
			/*
			C462	Tipo de Registo	3	A
			C463	Tipo de vacinação - Descrição	100	A
			C464	Nº de Inoculações	4	N
			C465	Nº de Trabalhadores - H	4	N
			C466	Nº de Trabalhadores - M	4	N
						*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
   	           IF QRGR->RGR_CAMPO == "C464"
		          IF EMPTY(QRGR->RGR_DESCRI)
                     aM262Log[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                 lLOG := .T.
 	              ENDIF   
 	           ELSEIF QRGR->RGR_CAMPO == "C465"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
	                     aM262Log[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	                 lLOG := .T.
	 	              ENDIF   
	 	       ELSEIF QRGR->RGR_CAMPO == "C466"
	 	              IF EMPTY(QRGR->RGR_DESCRI)
	                     aM262Log[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	                 lLOG := .T.
	 	              ENDIF   
	 	       ENDIF    
   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	           cDET += STRZERO(VAL(nCPO),4,0)
 	 	    ELSE                                  
 	 	          IF QRGR->RGR_CAMPO == "C463"
		             IF EMPTY(QRGR->RGR_DESCRI)
                        aM262Log[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
 	                    lLOG := .T.
 	                  ENDIF   
			          cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)
			      ENDIF       
 	 	    ENDIF       
	 	    
ELSEIF cTIPO == "264"	
			/*
			C468	Tipo de Registo	3	A
			C469	Nº de Acções	4	N
			C470	Nº Trabalhadores Abrangidos - H	4	N
			C471	Nº Trabalhadores Abrangidos - M	4	N
			
			*/															
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
 	           cDET += STRZERO(VAL(nCPO),4,0)
	 	    ENDIF
ELSEIF cTIPO == "270"	
			/*
			C473	Tipo de Registo	3	A
			C474	Nas Instal.-Acid.Trabalho < 1dia - H			4	N
			C475	Nas Instal.-Acid.Trabalho < 1dia - M			4	N
			C476	Nas Instal.-Acid.Trabalho - 1 a 3 dias- H		4	N
			C477	Nas Instal.-Acid.Trabalho - 1 a 3 dias - M		4	N
			C478	Nas Instal.-Acid.Trabalho - 4 a 30 dias- H		4	N
			C479	Nas Instal.-Acid.Trabalho - 4 a 30 dias - M		4	N
			C480	Nas Instal.-Acid.Trabalho > 30 dias- H	 		4	N
			C481	Nas Instal.-Acid.Trabalho > 30 dias - M			4	N
			C482	Nas Instal.-Acid.Trabalho - Mortal - H			4	N
			C483	Nas Instal.-Acid.Trabalho - Mortal - M			4	N
			C484	Nas Instal.-Trab.Perdido - 1 a 3 dias- H		4	N
			C485	Nas Instal.-Trab.Perdido - 1 a 3 dias - M		4	N
			C486	Nas Instal.-Trab.Perdido - 4 a 30 dias- H		5	N
			C487	Nas Instal.-Trab.Perdido - 4 a 30 dias - M		5	N
			C488	Nas Instal.-Trab.Perdido > 30 dias- H			5	N
			C489	Nas Instal.-Trab.Perdido > 30 dias - M			5	N
			C490	Fora  Instal.-Acid.Trabalho < 1dia - H			4	N
			C491	Fora  Instal.-Acid.Trabalho < 1dia - M			4	N
			C492	Fora  Instal.-Acid.Trabalho - 1 a 3 dias- H		4	N
			C493	Fora Instal.-Acid.Trabalho - 1 a 3 dias - M		4	N
			C494	Fora  Instal.-Acid.Trabalho - 4 a 30 dias- H	4	N
			C495	Fora  Instal.-Acid.Trabalho - 4 a 30 dias -M	4	N
			C496	Fora Instal.-Acid.Trabalho > 30 dias- H			4	N
			C497	Fora Instal.-Acid.Trabalho > 30 dias - M		4	N
			C498	Fora  Instal.-Acid.Trabalho - Mortal - H		4	N
			C499	Fora Instal.-Acid.Trabalho - Mortal - M			4	N
			C500	Fora Instal.-Trab.Perdido - 1 a 3 dias- H		4	N
			C501	Fora Instal.-Trab.Perdido - 1 a 3 dias - M		4	N
			C502	Fora  Instal.-Trab.Perdido - 4 a 30 dias- H		5	N
			C503	Fora  Instal.-Trab.Perdido - 4 a 30 dias - M	5	N
			C504	Fora das Instal.-Trab.Perdido > 30 dias- H		5	N
			C505	Fora das Instal.-Trab.Perdido > 30 dias - M		5	N
			C506	MeiosTransp.-Acid.Trabalho < 1dia - H			4	N
			C507	MeiosTransp.-Acid.Trabalho < 1dia - M			4	N
			C508	MeiosTransp.-Acid.Trabalho - 1 a 3 dias-H		4	N
			C509	MeiosTransp.-Acid.Trabalho - 1 a 3 dias-M		4	N
			C510	MeiosTransp.-Acid.Trabalho 4 a 30 dias-H		4	N
			C511	MeiosTransp.-Acid.Trabalho 4 a 30 dias-M		4	N
			C512	MeiosTransp.-Acid.Trabalho > 30 dias- H			4	N
			C513	MeiosTransp.-Acid.Trabalho > 30 dias - M		4	N
			C514	MeiosTransp.-Acid.Trabalho - Mortal - H			4	N
			C515	MeiosTransp.-Acid.Trabalho - Mortal - M			4	N
			C516	MeiosTransp.-Trab.Perdido 1 a 3 dias- H			4	N
			C517	MeiosTransp.-Trab.Perdido 1 a 3 dias - M		4	N
			C518	MeiosTransp.-Trab.Perdido  4 a 30 dias- H		5	N
			C519	MeiosTransp.-Trab.Perdido  4 a 30 dias- M		5	N
			C520	Meios Transp.-Trab.Perdido > 30 dias- H			5	N
			C521	Meios Transp.-Trab.Perdido > 30 dias - M		5	N
			
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
			   IF QRGR->RGR_CAMPO $ "C486/C487/C488/C489/C502/C503/C504/C505/C518/C519/C520/C521"
 	               nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
	 	           cDET += STRZERO(VAL(nCPO),5,0)
	 	       ELSE     
	   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
	 	           cDET += STRZERO(VAL(nCPO),4,0)
	 	       ENDIF
	 	    ENDIF
ELSEIF cTIPO == "271"	
			/*
			C522	Tipo de Registo	3	A
			C523	In itinere-Acid.Trabalho < 1dia - H			4	N
			C524	In itinere-Acid.Trabalho < 1dia - M			4	N
			C525	In itinere-Acid.Trabalho - 1 a 3 dias- H	4	N
			C526	In itinere-Acid.Trabalho - 1 a 3 dias - M	4	N
			C527	In itinere-Acid.Trabalho - 4 a 30 dias- H	4	N
			C528	In itinere-Acid.Trabalho - 4 a 30 dias - M	4	N
			C529	In itinere-Acid.Trabalho > 30 dias- H		4	N
			C530	In itinere-Acid.Trabalho > 30 dias - M		4	N
			C531	In itinere-Acid.Trabalho - Mortal - H		4	N
			C532	In itinere-Acid.Trabalho - Mortal - M		4	N
			C533	In itinere-Trab.Perdido - 1 a 3 dias- H		4	N
			C534	In itinere-Trab.Perdido - 1 a 3 dias - M	4	N
			C535	In itinere-Trab.Perdido - 4 a 30 dias- H	5	N
			C536	In itinere-Trab.Perdido - 4 a 30 dias - M	5	N
			C537	In itinere-Trab.Perdido > 30 dias- H		5	N
			C538	In itinere-Trab.Perdido > 30 dias - M		5	N
			C539	Nº Acidentes - Horário Normal - H			4	N
			C540	Nº Acidentes - Horário Normal - M			4	N
			C541	Nº Acidentes - Turno Fixo - H				4	N
			C542	Nº Acidentes - Turno Fixo - M				4	N
			C543	Nº Acidentes - Turno Rotativo - H			4	N
			C544	Nº Acidentes - Turno Rotativo - M			4	N
			C545	Nº Acidentes - Horário Nocturno - H			4	N
			C546	Nº Acidentes - Horário Nocturno - M			4	N
			C547	Nº Acidentes - Outro Horário - H			4	N
			C548	Nº Acidentes - Outro Horário - M			4	N
			
			*/
			IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
			   IF QRGR->RGR_CAMPO $ "C535/C536/C537/C538"
   	              nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,5)
 	              cDET += STRZERO(VAL(nCPO),5,0)
	 	       ELSE     
	   	           nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
	 	           cDET += STRZERO(VAL(nCPO),4,0)
	 	       ENDIF
	 	    ELSE     
	 	       IF QRGR->RGR_CAMPO == "C522"  
                  cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	 	       ENDIF
	 	    ENDIF
ELSEIF cTIPO == "273"	
		 /*
		C550	Tipo de Registo	3	A
		C551	Código Doença Profissional	4	N
		C552	Especificação da doença	150	A
		C553	Participados - H	4	N
		C554	Confirmados - H	4	N
		C555	Participados - M	4	N
		C556	Confirmados - M	4	N
		
		 */	  
		 
	    /*
	       Se o campo C549 = 9999 o campo C550 deve ser preenchido com a especificação da doença (não constante da tabela) em texto livre
		*/
		
		IF QRGR->RGR_CAMPO == "C549"  
		   IF ALLTRIM(QRGR->RGR_DESCRI) == "9999"
		      lLog550 := .T.
		   Endif 
		EnDIF
		      
		IF QRGR->RGR_CAMPO == "C550"  .and. lLog550
		   If aTotRegs[7] == 0                  
			  cLog := STR0053                   //"O campo C550 deve ser preenchido com a especificação da doença " 
			  Aadd(aTitle,cLog)  
			  Aadd(aLog,{})
			  aTotRegs[7] := len(aLog)
		   EndIf	
		  Aadd(aLog[aTotRegs[7]], STR0049+" "+Alltrim(QRGR->RGR_TIPREG)+"-"+STR0050 + " "+AllTrim(QRGR->RGR_CAMPO) ) 	                
		ENDIF                
	    
	    IF QRGR->RGR_CAMPO == "C551"
           nSomaVal += VAL(ALLTRIM(QRGR->RGR_DESCRI))
        ELSEIF QRGR->RGR_CAMPO == "C553"
               nSomaVal += VAL(ALLTRIM(QRGR->RGR_DESCRI))
               IF nSomaVal = 0
                  If aTotRegs[8] == 0                  
		             cLog := STR0054                   //"O somatório dos Campos C551 e C553 tem que ser Maior que 0 " 
			         Aadd(aTitle,cLog)  
			         Aadd(aLog,{})
			         aTotRegs[8] := len(aLog)
		          EndIf	
		          Aadd(aLog[aTotRegs[8]], STR0049+" "+Alltrim(QRGR->RGR_TIPREG)+"-"+STR0050 + " "+AllTrim(QRGR->RGR_CAMPO) ) 	                
	           ENDIF
        ENDIF    

	    // O somatório dos campos C551 e C553, caso exista registo deste tipo (M273), tem de ser superior a 0 (zero)
			
		 IF QRGR->RGR_TIPO = "N"                      // Grava com zeros a esquerda campos numericos
            IF QRGR->RGR_CAMPO == "C551" 
 	           IF EMPTY(QRGR->RGR_DESCRI)
	              aM273Log[1] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	          lLOG := .T.
	 	       ENDIF   
	 	    ELSEIF QRGR->RGR_CAMPO == "C553"    
 	               IF EMPTY(QRGR->RGR_DESCRI)
	                  aM273Log[3] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	              lLOG := .T.
	 	           ENDIF   
            ELSEIF QRGR->RGR_CAMPO == "C554"    
 	               IF EMPTY(QRGR->RGR_DESCRI)
	                  aM273Log[4] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	              lLOG := .T.
	 	           ENDIF   
            ELSEIF QRGR->RGR_CAMPO == "C555"    
 	               IF EMPTY(QRGR->RGR_DESCRI)
	                  aM273Log[5] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	              lLOG := .T.
	 	           ENDIF   
            ELSEIF QRGR->RGR_CAMPO == "C556"    
 	               IF EMPTY(QRGR->RGR_DESCRI)
	                  aM273Log[6] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	              lLOG := .T.
	 	           ENDIF   
            ENDIF
            nCPO := SUBSTR(ALLTRIM(QRGR->RGR_DESCRI),1,4)
            cDET += STRZERO(VAL(nCPO),4,0)
	 	 ELSE        
	          IF QRGR->RGR_CAMPO == "C550"  
                 cDet := SUBSTR(QRGR->RGR_DESCRI,1,3)             
	 	      ELSEIF QRGR->RGR_CAMPO == "C552"    
 	                 IF EMPTY(QRGR->RGR_DESCRI)
	                    aM273Log[2] := QRGR->RGR_DESCRI     // Grava Log para este Campo
	 	                lLOG := .T.
	 	             ENDIF   
 	                 cDet += SUBSTR(QRGR->RGR_DESCRI,1,100)+SPACE(50)
	 	      ENDIF
	 	 ENDIF  	
ELSEIF cTIPO == "999"
	
	   cDet := cTIPO
ENDIF	 	 
Return(cDet)

