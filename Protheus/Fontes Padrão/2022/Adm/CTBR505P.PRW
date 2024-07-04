#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBR505P.CH"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CTBR505P
Imprime o relatório Balançete Financeiro para o setor Público

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return 
/*/
//---------------------------------------------------------------------------------------
Function CTBR505P()
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local nHandle       := 0
Local lRet          := .T.

PRIVATE cPerg	   	:= "CTR505P" 
Private nomeprog	:= "CTBR505P"       
Private aSelFil		:={} 

If !Pergunte(cPerg,.T.) 
	Return .F.
Endif    

// Faz a validacao das filiais
If lRet .And. mv_par12 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
EndIf

// Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
// Gerencial -> montagem especifica para impressao)
// faz a validação do livro
If lRet .And. !Empty( mv_par03 ) 
	If !VdSetOfBook( mv_par03 , .F. )
		lRet := .F.
	EndIf
EndIf

If lRet .And. (mv_par06==1)
	If Empty(mv_par07)
		MsgAlert(STR0001) //"O Arquivo com a nota explicativa não foi informado."
		lRet := .F.
	Else
		If (nHandle := FOpen(mv_par07, 3)) < 0
			MsgAlert(STR0013) //"O arquivo da Nota Explicativa (.TRM) nao pode estar como somente leitura."
			lRet := .F.
		Else
			FClose(nHandle)
		EndIf
	EndIf
EndIf

If lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par03)
	
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par04, aSetOfBook[9])

	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf	
        
	cDescMoeda 	:= AllTrim(aCtbMoeda[3])
	        
	oReport := ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda) 

	oReport:PrintDialog()
	      
EndIf

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)  
local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR505P"
Local cTITULO		:= Capital(STR0002)//"BALANÇETE FINANCEIRO"
Local cDESC			:= STR0003 //"Este programa ira imprimir o Balancete Financeiro, de acordo com os parâmetros informados pelo usuário."
Local nTamDesc		:= TAMSX3("CTS_DESCCG")[1]  
Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local dInicial 		:= mv_par01
Local dFinal 		:= mv_par02
                         
//Filtra Filiais
If mv_par12 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

//__________________________________________________________________________
// Criacao do componente de impressao                                       |
//                                                                          |
// TReport():New                                                            |
// ExpC1 : Nome do relatorio                                                |
// ExpC2 : Titulo                                                           |
// ExpC3 : Pergunte                                                         |
// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao   |
// ExpC5 : Descricao                                                        |
//__________________________________________________________________________|

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dInicial,dFinal,aSetOfBook), .T., oReport:CancelPrint())}, CDESC)
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        		
oReport:ParamReadOnly()

IF GetNewPar("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 6

//_________________________________________________________________________
// Criacao da secao utilizada pelo relatorio                               |
//                                                                         |
// TRSection():New                                                         |
// ExpO1 : Objeto TReport que a secao pertence                             |
// ExpC2 : Descricao da seçao                                              |
// ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
//         sera considerada como principal para a seção.                   |
// ExpA4 : Array com as Ordens do relatório                                |
// ExpL5 : Carrega campos do SX3 como celulas                              |
//         Default : False                                                 |
// ExpL6 : Carrega ordens do Sindex                                        |
//         Default : False                                                 |
//_________________________________________________________________________|

oSection1  := TRSection():New( oReport, STR0004, {"cArqTmp"},, .F., .F. ) //"Detalhe"

nTamDesc += 3
nTamVal  += 20

If mv_par11 == 3
	nTamDesc += nTamVal
EndIf

// Colunas referentes ao Ativo
TRCell():New( oSection1, "CONTA"     , ,""/*Titulo*/,/*Picture*/ ,nTamDesc  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/ ,      /*cAlign*/, .T. /*lLineBreak*/,       ,,,.T.)
TRCell():New( oSection1, "VALCONTA"  , ,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)

oSection1:SetTotalInLine(.F.)

/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL" ,,STR0005,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/) //"Código"
TRCell():New(oSecFil,"EMPRESA",,STR0006,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0007,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Unidade de negócio"
TRCell():New(oSecFil,"NOMEFIL",,STR0008,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Filial"

oReport:DisableOrientation() 

RestArea(aArea)
           
Return(oReport)
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Imprime o relatorio definido pelo usuario de acordo com as
secoes/celulas criadas na funcao ReportDef definida acima.
Nesta funcao deve ser criada a query das secoes se SQL ou
definido o relacionamento e filtros das tabelas em CodeBase.

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return .T.
/*/
//---------------------------------------------------------------------------------------
Static Function ReportPrint( oReport,Titulo, dInicial, dFinal, aSetOfBook)  
Local oSection1 	:= oReport:Section(1)  
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aLinhas		:= {}
Local nLinha		:= 0
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cArqTrm		:= ""                                       
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamEmp		:= 0
Local nTamUnNeg		:= 0
Local nTamTit		:= 0
Local nSaldo		:= 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local oSecFil		:= oReport:Section("SECFIL") 
Local aSM0			:= {}  
Local nI 
Local lCharSinal	:= .F.
Local cMoeda        := mv_par04
Local cSuperior     := ""
Local lImpTot       := .F.
Local nTotal		:= 0
Local lImpSal       := .F.

DEFAULT cTitulo    := ""
DEFAULT dInicial   := StoD("")
DEFAULT dFinal     := StoD("")
DEFAULT aSetOfBook := CTBSetOf(mv_par03)

oReport:SetPageNumber( MV_PAR05 )

If  Empty(aSetOfBook[5])
	MsgAlert(STR0009) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

// imprime a lista de filiais selecionadas para o relatorio
If Len(aSelFil) > 1
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + STR0010 + ")") //"Filiais selecionadas para o relatorio"
	nTamTit := Len(oReport:Title())
	oSecFil:Init()  
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

	For nI := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nI]})
		If nLinha > 0
			cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
			oSecFil:PrintLine()
		Endif
	Next
	oReport:SetTitle(cTitulo)
	oSecFil:Finish()
	oReport:EndPage()
Endif

aCtbMoeda := CtbMoeda(cMoeda, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)
cPicture 	:= aSetOfBook[4]
lComNivel	:= .T.
m_pag 		:= mv_par05

// Monta Arquivo Temporario para Impressao
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						dInicial,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		   				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		   				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par04,;
		   				mv_par10,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		   				,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,,aSelFil)},;
		    STR0011, Titulo) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")
dbGoTop()

#DEFINE C_CONTA			1
#DEFINE C_DESC			2
#DEFINE C_SITNORMAL		3
#DEFINE C_NIVEL    		4
#DEFINE C_IDENTIFI		5
#DEFINE C_SALDOATU		6
#DEFINE C_TIPOCONTA		7
#DEFINE C_SUPERIOR		8

lImpSal := ( FieldPos("IMPSAL") > 0 )  //verificar no arquivo cArqTmp se tem o campo IMPSAL  (DESCIDA)

While !Eof()
	
	nSaldo := 0
	
	If TIPOCONTA = "2"
		If lImpSal .And. IMPSAL == "1"
			nSaldo := SALDOATUDB*-1
		ElseIf lImpSal .And. IMPSAL == "2"
			nSaldo := SALDOATUCR
		ElseIf lImpSal .And. IMPSAL == "3"
			nSaldo := SALDOATU 
		ElseIf lImpSal .And. IMPSAL == "4"
			nSaldo := SALDOANT 
		Else
			nSaldo := SALDOATU      //SE CAMPO NAO ESTIVER PREENCHIDO RETORNA SEMPRE SALDO ATUAL (DESCIDA)
		EndIf
	EndIf

	Aadd(aLinhas, {	CONTA,;		//[1]
					DESCCTA,;	//[2]
					NORMAL,;	//[3]
					NIVEL,;		//[4]
					IDENTIFI,;	//[5]
					nSaldo,;	//[6]
					TIPOCONTA,; //[7]
					SUPERIOR})	//[8]

	DbSkip()
EndDo

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 

If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

dbselectArea("CT2")
oSection1:Init()

aTamVal[1] += 8

For nI := 1 To Len(aLinhas)

	nLinha := nI
	cSuperior := AllTrim(aLinhas[nI,C_SUPERIOR])

	If Empty(cSuperior)			
		lImpTot := .F.

		If aLinhas[nLinha,C_CONTA] > "1"			
			nTotal := ImpLinTot(oReport,nTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)		
			oReport:EndPage()
		EndIf	

		oSection1:Cell("CONTA"):SetBlock({ || aLinhas[nLinha,C_DESC] })
		oSection1:Cell("VALCONTA"):SetBlock( { || AllTrim(DtoC(dFinal)) } )		
		oSection1:PrintLine()		
		oReport:ThinLine()			
	ElseIf cSuperior == "1"		
		If lImpTot
			nTotal := ImpLinTot(oReport,nTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)
		EndIf		

		ImpQbrLin(oReport)

		oSection1:Cell("CONTA"):SetBlock({ || aLinhas[nLinha,C_DESC] })
		oSection1:Cell("VALCONTA"):SetBlock( { || "" } )
		oSection1:PrintLine()		
		oReport:ThinLine()			
	ElseIf cSuperior == "2"		
		If lImpTot
			nTotal := ImpLinTot(oReport,nTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)
		EndIf		

		ImpQbrLin(oReport)

		oSection1:Cell("CONTA"):SetBlock({ || aLinhas[nLinha,C_DESC] })
		oSection1:Cell("VALCONTA"):SetBlock( { || "" } )	
		oSection1:PrintLine()		
		oReport:ThinLine()	
	Else	
		// Se Imprime Valor Zerado = Não
		If mv_par08 <> 1 .And. aLinhas[nLinha,C_SALDOATU] == 0
			Loop
		Endif

		lImpTot := .T.
		
		cDescImp := Space(3)

		If mv_par11 == 1
			cDescImp += aLinhas[nLinha,C_CONTA]
		ElseIf mv_par11 == 2
			cDescImp += aLinhas[nLinha,C_DESC]
		ElseIf mv_par11 == 3
			cDescImp += AllTrim(aLinhas[nLinha,C_CONTA])+" - "+aLinhas[nLinha,C_DESC]
		EndIf
		
		oSection1:Cell("CONTA"):SetBlock( { || cDescImp } )
		oSection1:Cell("VALCONTA"):SetBlock( { || ValorCTB( aLinhas[nLinha,C_SALDOATU],,,aTamVal[1],nDecimais,.T.,cPicture,;
												aLinhas[nLinha,C_SITNORMAL],aLinhas[nLinha,C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )				
		
		nTotal += aLinhas[nLinha,C_SALDOATU]		
	EndIf
	
	If !Empty(cSuperior) .And. !(cSuperior$("1/2"))
		oSection1:PrintLine()
	EndIf		
	
Next nI

nTotal := ImpLinTot(oReport,nTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)

oSection1:Finish()

If mv_par06==1
	oReport:EndPage()
	cArqTRM 	:= mv_par07
	aVariaveis	:= {}

	// Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek( padr( "CTR505P" , Len( X1_GRUPO ) , ' ' ) + "01" ) )

	Do While SX1->X1_GRUPO == padr( "CTR505P" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	Enddo

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0012) //"Responsáveis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
	Endif	 
EndIf

oReport:EndPage()

Return .T.
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpLinTot

Imprime linha de total

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return 0
/*/
//---------------------------------------------------------------------------------------
Static Function ImpLinTot(oReport,nTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lCharSinal)
Local oSection1 := oReport:Section(1)

DEFAULT nTotal     := 0
DEFAULT aLinhas    := {}
DEFAULT nLinha     := 0
DEFAULT aTamVal    := {}
DEFAULT nDecimais  := 0
DEFAULT cPicture   := ""
DEFAULT cTpValor   := ""
DEFAULT lCharSinal := .F.

oReport:ThinLine()
oSection1:Cell("CONTA"):SetBlock({ || "TOTAL"})
oSection1:Cell("VALCONTA"):SetBlock( { || ValorCTB( nTotal,,,aTamVal[1],nDecimais,.T.,cPicture,;
										aLinhas[nLinha,C_SITNORMAL],aLinhas[nLinha,C_CONTA],,,cTpValor,,,.F.,,lCharSinal) } )
oSection1:PrintLine()

Return 0
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpQbrLin

Imprime quebra de linha

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return .T.
/*/
//---------------------------------------------------------------------------------------
Static Function ImpQbrLin(oReport)
Local oSection1 := oReport:Section(1)

oSection1:Cell("CONTA"):SetBlock({ || ""})
oSection1:Cell("VALCONTA"):SetBlock( { || "" } )
oSection1:PrintLine()

Return 

