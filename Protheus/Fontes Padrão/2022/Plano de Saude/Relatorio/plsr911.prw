
#INCLUDE "Protheus.ch"
#INCLUDE "plsr911.ch"
#include "PLSMGER.CH"
#include "COLORS.CH"
#Include "MsOle.Ch"

#define FAIXAETARIA 	1
#define TIPO 			2
#define MASCULINO 		3
#define FEMININO 		4
#define TOTMASCFEM 		5
#define VALORMASCULINO 6
#define VALORFEMININO 	7
#define TOTAL 			8

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR911    ºAutor  ³Paulo Carnelossi   º Data ³  14/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relatorio de proposta comercial no MS-WORD          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR911()    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir a Proposta de "
Local cDesc2 := STR0002 //"Vendas."
Local cDesc3 := ""
Local nOpca 		:= 0
Local aSays 		:= {}, aButtons := {}, lPrint := .T.
Private cCadastro 	:= STR0003 //"P r o p o s t a   C o m e r c i a l"
Private cTitulo:= STR0003 //"P r o p o s t a   C o m e r c i a l"
Private cNumTel
Private cArqDoc := ""

Private cPerg   := "PLR911"
Private aGeral 	:= {}

Inclui := .F.//setado variavel Inclui como Falso p/ nao dar erro criavar

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Codigo                                           ³
//³ mv_par02 // Loja                                             ³
//³ mv_par03 // Numero da Proposta                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
AADD(aSays,cDesc1+cDesc2)
AADD(aSays,STR0019)//"Os parametros para emissao deverao ser confirmados."

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )    
AADD(aButtons, { 4,.T.,{|| cArqDoc:=Arq_SelCop("PLSR911.CFG", cTitulo, STR0023, STR0024 ) } } )    //"Selecione a Proposta para Impressao", "Nao existem arquivos de propostas"
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons,, 160 )
	
IF nOpca == 1
	Processa( { || PLSR911Imp()},cTitulo,STR0020)//"Processando ..."
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR911Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 14/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao Proposta Comercial via integracao com MS-Word     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR911Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR911Imp(lEnd,wnRel,cString)

Local nVlrContrato := 0
Local nGrauRisco := 0
Local aHeaderA, aHeaderS, aHeaderP, aColsA, aColsS, aColsP, aTrabS, aTrabA, aTrabP, nI
Local aDadosCon, cSequen
Local aHeaderSUS, aCposSUS, aCamposSUS := { 	"US_COD", ;
								"US_LOJA", ;
								"US_NOME", ;
								"US_NREDUZ", ;
								"US_TIPO", ;
								"US_END", ;
								"US_MUN", ;
								"US_BAIRRO", ;
								"US_CEP", ;
								"US_EST", ;
								"US_DDI", ;
								"US_DDD", ;
								"US_TEL", ;
								"US_FAX", ;
								"US_EMAIL", ;
								"US_URL", ;
								"US_ULTVIS", ;
								"US_VEND", ;
								"US_CGC", ;
								"US_ORIGEM", ;
								"US_STATUS"}
								
If Empty(cArqDoc)
	MsgStop(STR0021)  //"Não encontrado proposta (Documento Word)!"
	Return
EndIf	

Store Header "SUS" TO aCposSUS For .T.

dbSelectArea("SUS")
DbSetOrder(1)
If ! dbSeek(xFilial("SUS")+mv_par01+mv_par02)
   MsgStop(STR0006) //"Não encontrado cliente!"
   Return
EndIf

nI := 1
aHeaderSUS := {}
While nI <= Len(aCposSUS)
	If ASCAN(aCamposSUS, Trim(aCposSUS[nI][2])) > 0
		aAdd(aHeaderSUS, {	.T., ;              			// se imprime o campo 
									Trim(aCposSUS[nI][2]),; 	// nome do campo
									Trim(aCposSUS[nI][1]),; 	//descricao do campo
									Trim(aCposSUS[nI][1]),; 	//titulo do campo
									Trim(aCposSUS[nI][2]),; 	//nome do campo novamente
									aCposSUS[nI][4] } )     	// tamanho do campo
	EndIf
	nI++
End

dbSelectArea("BL2")
If ! dbSeek(xFilial("BL2")+mv_par01+mv_par02+mv_par03)
   MsgStop(STR0007) //"Não encontrado proposta para este cliente!"
   Return
EndIf

dbSelectArea("BL4")
Store Header "BL4" TO aHeaderA For .T.

BL4->(DbSetOrder(1))
aColsA := {}
If BL4->(DbSeek(xFilial("BL4")+mv_par01+mv_par02+mv_par03)) 
   Store COLS "BL4" TO aColsA FROM aHeaderA VETTRAB aTrabA ;
   While BL4->(BL4_FILIAL+BL4_CODIGO+BL4_LOJA+BL4_SEQUEN) == xFilial("BL4")+mv_par01+mv_par02+mv_par03
Endif                                  

dbSelectArea("BL3")
Store Header "BL3" TO aHeaderP For .T.

BL3->(DbSetOrder(1))
aColsP := {}
If BL3->(DbSeek(xFilial("BL3")+mv_par01+mv_par02+mv_par03)) 
   Store COLS "BL3" TO aColsP FROM aHeaderP VETTRAB aTrabP;
   While BL3->(BL3_FILIAL+BL3_CODIGO+BL3_LOJA+BL3_SEQUEN) == xFilial("BL3")+mv_par01+mv_par02+mv_par03
Endif                                  

dbSelectArea("BL8")
Store Header "BL8" TO aHeaderS For .T.
aColsS := {}

BL8->(DbSetOrder(1))
If BL8->(DbSeek(xFilial("BL8")+mv_par01+mv_par02))
   Store COLS "BL8" TO aColsS FROM aHeaderS VETTRAB aTrabS ;
   While BL8->(BL8_FILIAL+BL8_CODIGO+BL8_LOJA) == xFilial("BL8")+mv_par01+mv_par02
Endif                                  

aGeral := aClone(Plsa910BL9(aHeaderA,aColsA,aHeaderS,aColsS,aHeaderP,aColsP,mv_par03,BL2->BL2_FAIFAM))
If	SUS->(FieldPos("US_FORMULA")) > 0
    M->US_FORMULA := SUS->US_FORMULA
Endif    
PlsVlrCont(@nVlrContrato, @nGrauRisco, aGeral)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Documento MS-Word                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MyTermoViaWord(cArqDoc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SUS")

Ferase(cArqDoc)  //apaga o arquivo de trabalho DOC
cArqDoc	:=	StrTran(cArqDoc,".DOC",".INI")
Ferase(cArqDoc) //apaga o arquivo ini conjunto do DOC

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ARQ_SELCOPºAutor  ³Paulo Carnelossi    º Data ³  14/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna nome do arquivo .doc copiado para \SIGAADV baseado º±±
±±ºDesc.     ³ no arquivo de configuracao                                 º±±
±±º          ³ objetivo original de imprimir PROPOSTA                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Arq_SelCop(cArqCfg, cTituloJanela, cAcao, cMsgExc)
Local oDlg, oBox, nOpca := 0, cFileDoc := ""
Local aListaDoc := {}, aProprDoc := {}
LOCAL bOK      := {|| nOpca := 1,oDlg:End()}
LOCAL bCancel  := {|| nOpca := 0,oDlg:End()}
LOCAL aButtons := {}

If cArqCfg == NIL
	cArqCfg := Alltrim(FunName())+".CFG"
EndIf
	
If !File(cArqCfg)
   MsgStop(cMsgExc)
   Return
EndIf

LerArqTxt(cArqCfg, aListaDoc, aProprDoc)

If Empty(aListaDoc)
   MsgStop(cMsgExc)
   Return
Endif                            

DEFINE MSDIALOG oDlg TITLE cTituloJanela FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault() 

@ 001,001 LISTBOX oBox FIELDS HEADER  cAcao COLSIZES 100,060,060,060,060 SIZE  338,165 OF oDlg 

oBox:SetArray(aListaDoc)
oBox:bLine   	:= {|| { aListaDoc[oBox:nAt] } }
oBox:BLDBLCLICK := {|| cFileDoc := aProprDoc[oBox:nAt,1]+aProprDoc[oBox:nAt,2] }
oBox:BCHANGE 	:= {|| cFileDoc := aProprDoc[oBox:nAt,1]+aProprDoc[oBox:nAt,2] }

ACTIVATE DIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)

If nOpca == 0
	cFileDoc := ""
Else
	cArqIni := StrTran(cFileDoc, ".DOC", ".INI")
	If File(cFileDoc) .And. File(cArqIni)
		cArqTrb := CriaTrab(,.F.)
		__CopyFile(cFileDoc, cArqTrb+".DOC")
		__CopyFile(cArqIni, cArqTrb+".INI")
		cFileDoc := cArqTrb+".DOC"
	Else
	   	MsgStop(STR0021)
		cFileDoc := ""
    EndIf
EndIf

Return(cFileDoc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LerArqTxt ºAutor  ³Paulo Carnelossi    º Data ³  03/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Leitura do arquivo texto com informacoes das propostas      º±±
±±º          ³armazenadas em documentos word                              º±±
±±º          ³as informacoes sao gravadas nos arrays  aListaDoc,aProprDoc º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LerArqTxt(cArqTxt, aListaDoc, aProprDoc)
Local cPathDoc := "\SIGAADV\", cFileDoc := "PROPOSTA.DOC"

If FT_FUSE(cArqTxt) == -1
	MsgStop(STR0022)//"Falha na abertura do arquivo. Verifique se o mesmo não está em uso."
	
Else
	
	FT_FGOTOP()
	
	While ! FT_FEOF()
		
		cLinha := Alltrim(FT_FREADLN())
		
		If ! Empty(cLinha) .And. Left(cLinha,1) = "[" .And. Right(cLinha, 1) = "]"
		   //Titulo do Arquivo de Proposta
		   aAdd(aListaDoc, StrTran(Subs(cLinha, 2), "]",""))
		   lAvanca := .T.
		   
		ElseIf ! Empty(cLinha) .And. (nPosIgual := AT("=", cLinha) ) > 0
			//Propriedades do arquivo doc
			While ! FT_FEOF() .And. ! Empty(cLinha) .And. Left(cLinha,1) != "[" .And.;
					Right(cLinha, 1) != "]" .And. (nPosIgual := AT("=", cLinha) ) > 0
			
			    If Upper(Alltrim(Left(cLinha, nPosIgual-1))) == "FILEPATH"
				   cPathDoc := Alltrim(Subs(cLinha,nPosIgual+1))
				ElseIf Upper(Alltrim(Left(cLinha, nPosIgual-1))) == "FILENAME"
				   cFileDoc := Alltrim(Subs(cLinha,nPosIgual+1))
				EndIf
				FT_FSKIP()
				cLinha := Alltrim(FT_FREADLN())
				lAvanca := .F.
			End
			
			//path e nome do arquido de proposta
			aAdd(aProprDoc, {cPathDoc, cFileDoc})
			
		Else
			lAvanca := .T.
			
		EndIf
		
		If lAvanca
			FT_FSKIP()
		EndIf
		
	End 
	
EndIf	

FT_FUSE()

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MyTermoViaWord³ Autor ³Wagner Mobile Costa ³Data ³ 08/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Termo de Abertura/Encerramento de Livro utilizando ³±±
±±³          ³ integracao com MsWord                                      ³±±
±±³          ³ Funcao igual a TermoViaWord com condicao de executar       ³±±
±±³          ³ code blocks declarado no arquivo INI( apos sinal de igual  ³±±
±±³          ³ escrever {BLOCODECODIGO}{||FuncaoX()} )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  = Nome do arquivo .DOC que contem variaveis de auto-³±±
±±³          ³          macao de documento, as substituicoes estao no ar- ³±±
±±³          ³          quivo cArquivo + .INI                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MyTermoViaWord(cArquivo)

Local 	oWord, cVar, uConteudo
Local 	bError, bBlockExec
Local 	cPathTmp	:= Alltrim(QdoPath()[3]) /// QdoPath() na QdoxFun.prw
Local	nPrint		:= nFecha := 1

__CopyFile(cArquivo, cPathTmp+cArquivo)
	
aSavSet:=__SetSets()

oWord := OLE_CreateLink()

OLE_SetPropertie( oWord, oleWdPrintBack, .F.)
OLE_SetPropertie( oWord, oleWdVisible, .T.)

OLE_OpenFile(oWord, cPathTmp+cArquivo)   

If File(StrTran(Upper(cArquivo), ".DOC", ".INI"))
	FT_FUse(StrTran(Upper(cArquivo), ".DOC", ".INI"))
	FT_FGotop()

	bError 	:= 	ErrorBlock({|e| ApMsgAlert(StrTran(Upper(cArquivo), ".DOC", ".INI") +;
				Chr(13) + Chr(10) + "Variavel " + cVar + Chr(13) + Chr(10) +;
				"Definida incorretamente como " +;
				Subs(cLinha, At("=", cLinha) + 1, Len(cLinha))) })
	
	While ( !FT_FEof() )
		cLinha 	  := FT_FREADLN()
		cVar	  := Left(cLinha, At("=", cLinha) - 1)
		uConteudo := AllTrim(Subs(cLinha, At("=", cLinha) + 1, Len(cLinha)))
		
		If Left(UPPER(uConteudo),15) == "{BLOCODECODIGO}"
		    bBlockExec := MontaBlock(Subs(uConteudo,16))
			Eval(bBlockExec)
		ElseIf cVar = "PRINT_WORD_PADRAO"
			nPrint := Val(uConteudo)
		ElseIf cVar = "FECHA_WORD"
			nFecha := Val(uConteudo)
		Else
			uConteudo := &uConteudo
			If uConteudo <> Nil
				OLE_SetDocumentVar(oWord, cVar, uConteudo)
			eNDIF
		Endif
		FT_FSkip()
	EndDo
	
	ErrorBlock(bError)
	FT_FUse()
Endif
	
OLE_UpdateFields( oWord )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Qtde de Copias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
OLE_SetProperty( oWord, '208', .F. )
If nPrint = 1
	OLE_PrintFile( oWord, 'PART', 1, 1, 1)
Endif	

If nFecha = 1
	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord )
Endif
	
__SetSets(aSavSet)
Set(24,Set(24),.t.)
	
Return .T.


//---------------------------------------------------------------------------------//
//Macros a serem executadas no MS-Word

/* 
Option Base 1

Sub InsereLinhaBranco()
   
    Dim Font_Arial As Font
    Dim MyaRange() As String
    
    Set Font_Arial = New Font
    
    Font_Arial.Name = "Arial"
    Font_Arial.Size = 10
    Font_Arial.Bold = True
   
    ActiveWindow.View.ShowHiddenText = True
    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = "MARCA___TABELA"
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindContinue
        .Format = False
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With
    Selection.Find.Execute
    Selection.HomeKey Unit:=wdLine
    Selection.MoveLeft Unit:=wdCharacter, Count:=1

    Selection.SelectRow
    Selection.Font = Font_Arial
    
    Selection.Cells(2).Select
    
    Font_Arial.Size = 8
    Selection.Font = Font_Arial
    Font_Arial.Size = 10

    Selection.SelectRow
    Selection.ParagraphFormat.Alignment = wdAlignParagraphRight
    Selection.SelectRow
    
    Selection.Cells.VerticalAlignment = wdCellAlignVerticalCenter

    Selection.SelectRow
    i = 0
    ReDim MyaRange(Selection.Cells.Count) As String
    
    For Each aCell In Selection.Cells
        i = i + 1
        MyaRange(i) = Replace(aCell.Range.Text, vbTab, "")
        MyaRange(i) = Replace(MyaRange(i), vbCrLf, "")
        MyaRange(i) = Replace(MyaRange(i), vbCr, "")
        MyaRange(i) = Replace(MyaRange(i), Chr(7), "")
    Next aCell

    Selection.InsertRowsAbove 1
    
    Selection.SelectRow
    i = 1
    For Each aCell In Selection.Cells
        aCell.Range.Text = MyaRange(i)
        i = i + 1
    Next aCell
    
    Selection.SelectRow
     
    Selection.Font = Font_Arial
    Selection.Cells(2).Select
    
    Font_Arial.Size = 8
    Selection.Font = Font_Arial
    Font_Arial.Size = 10

    Selection.SelectRow
    Selection.ParagraphFormat.Alignment = wdAlignParagraphRight
    Selection.SelectRow
    Selection.Cells.VerticalAlignment = wdCellAlignVerticalCenter

    ActiveWindow.View.ShowHiddenText = False
        
End Sub
Sub DelColFant()
    
    ActiveWindow.View.ShowHiddenText = True
    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = "COL__XYZ"
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindContinue
        .Format = True
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With
    Selection.Find.Execute
    Selection.Columns.Delete
    ActiveWindow.View.ShowHiddenText = False

End Sub
*/              

//---------------------------------------------------------------------------------//

/* 
VARIAVEIS DECLARADAS NO DOCUMENTO WORD

FAIXAETARIA
TIPO
MASCULINO
FEMININO
TOTMASCFEM
VALORMASCULINO
VALORFEMININO
TOTAL

NOMECLIENTE=COD LOJA NOME
ENDERECOCLIENTE=END+BAIRRO+MUNICIPIO+ESTADO
CEPCLIENTE=
TELEFONECLIENTE=                         
PROPOSTA=
TIPOPROPOSTA=
PLANO=

    
*/
    

