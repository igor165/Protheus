#Include "CTBR508P.ch"
#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CTBR508P
Imprime o relatório ESTIMATIVA E COMPENSAÇÃO DA RENUNCIA DE RECEITA

@author TOTVS
@since 07/08/2020
@version 12.1.31
@return 
/*/
//---------------------------------------------------------------------------------------
Function CTBR508P()
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local lRet          := .T.

PRIVATE cPerg	   	:= "CTR508P" 
Private nomeprog	:= "CTBR508P"       
Private aSelFil		:={} 

If !Pergunte(cPerg,.T.) 
	Return .F.
Endif    

// Faz a validacao das filiais
If lRet .And. mv_par07 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
EndIf

// Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
// Gerencial -> montagem especifica para impressao)
// faz a validação do livro
If lRet .And. !Empty( mv_par02 ) 
	If !VdSetOfBook( mv_par02, .F. )
		lRet := .F.
	EndIf
EndIf

If lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par02)

	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03, aSetOfBook[9])

	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf	
	        
	oReport := ReportDef() 

	oReport:PrintDialog()
	      
EndIf

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 07/08/2020
@version 12.1.31
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR508P"
Local cTitulo		:= STR0001 //"ANEXO DE METAS FISCAIS - DEMONSTRATIVO VII - ESTIMATIVA E COMPENSAÇÃO DA RENUNCIA DE RECEITA"
Local cDESC			:= STR0002 //"Este programa ira imprimir o Relatório, de acordo com os parâmetros informados pelo usuário."
Local nTamDesc		:= 250
Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local cAnoRef  		:= mv_par01
Local aSetOfBook    := CTBSetOf(mv_par02)

//Filtra Filiais
If mv_par07 == 1 .And. Len( aSelFil ) <= 0
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
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,cAnoRef,aSetOfBook), .T., oReport:CancelPrint())}, CDESC)
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

nTamVal  += 20
oSection1  := TRSection():New( oReport,"DETALHE", {"cArqTmp"},, .F., .F. ) 
TRCell():New(oSection1,"CONTA"  ,,""/*Titulo*/,/*Picture*/ ,nTamDesc  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/ ,      /*cAlign*/, .T. /*lLineBreak*/,        ,,,.T.)
TRCell():New(oSection1,"RECEITA",,"" /*Titulo*/,/*Picture*/,30        /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,       /*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"VALCTA1",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"VALCTA2",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"VALCTA3",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
oSection1:SetTotalInLine(.F.)

oSecFil := TRSection():New(oReport,"SECFIL")
TRCell():New(oSecFil,"CODFIL" ,,STR0003,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/) //"Código"
TRCell():New(oSecFil,"EMPRESA",,STR0004,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0005,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)   //"Unidade de negócio"
TRCell():New(oSecFil,"NOMEFIL",,STR0006,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Filial"

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
@since 07/08/2020
@version 12.1.31
@return .T.
/*/
//---------------------------------------------------------------------------------------
Static Function ReportPrint( oReport,Titulo,cAnoRef,aSetOfBook)  
Local oSecFil		:= oReport:Section("SECFIL") 
Local oSection1 	:= oReport:Section("DETALHE")  
Local cArqTmp       
Local cPicture
Local nLinha		:= 0                              
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamEmp		:= 0
Local nTamUnNeg		:= 0
Local nTamTit		:= 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local nI 
Local cMoeda        := mv_par03
Local cTpSld        := mv_par04
Local dDataIni      := StoD("")
Local dDataFin      := StoD("")
Local oHashLin      := tHashMap():New()
Local aCtbMoeda		:= {}
Local aSM0			:= {}  
Local aLinhas		:= {}
Local aLinAux       := {}
Local aSaldoPer     := {}
Local aTotal        := {}
Local aTotAux       := {}
Local nDivide		:= 1
Local cDescDiv      := ""
Local cDesc         := ""
Local cDesSint      := ""

Private lComNivel	:= .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

DEFAULT cTitulo    := ""
DEFAULT cAnoRef    := Year(dDataBase)
DEFAULT aSetOfBook := CTBSetOf(mv_par02)

If  Empty(aSetOfBook[5])
	MsgAlert(STR0007) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

If mv_par05 == 2			// Divide por cem
	nDivide := 100	
ElseIf mv_par05 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par05 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

If nDivide > 1
	cDescDiv := "("+STR0008+cValToChar(nDivide)+")" //"Div. "
EndIf

aSetOfBook[9] := nDivide

aCtbMoeda := CtbMoeda(cMoeda, nDivide)

nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

cPicture 	:= aSetOfBook[4]

If Empty(cPicture)
	aTamVal[1] += 8
    cPicture := "@E "+TmContab(0,aTamVal[1],nDecimais)
EndIf

// imprime a lista de filiais selecionadas para o relatorio
If Len(aSelFil) > 1	
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " ("+STR0009+")") //"Filiais selecionadas para o relatorio"
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

#DEFINE C_CONTA			1
#DEFINE C_DESC			2
#DEFINE C_SITNORMAL		3
#DEFINE C_NIVEL    		4
#DEFINE C_IDENTIFI		5
#DEFINE C_SALDOATU		6
#DEFINE C_TIPOCONTA		7
#DEFINE C_DESCCONT		8

aPerSld := CTbRtPer(cAnoRef)

For nI := 1 to Len(aPerSld)
    
    cArqTmp  := ""
    dDataIni := aPerSld[nI,1]
    dDataFin := aPerSld[nI,2]

    // Monta Arquivo Temporario para Impressao
    MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
                            dDataIni,dDataFin,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
                            "",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
                            "",Repl("Z", Len(CTH->CTH_CLVL)),cMoeda,;
                            cTpSld,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
                            ,,,,,,,nDivide,,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,,aSelFil)},;
                STR0010+cValToChar(Year(dDataIni)), Titulo)  //"Carregando valores de "

    dbSelectArea("cArqTmp")
    dbGoTop()

    While !Eof()
        
        If !oHashLin:Get( CONTA, @aLinAux )            
            aSaldoPer := Array(3)
            aSaldoPer[nI] := Abs(SALDOATU)
            HMSet(oHashLin, CONTA, { CONTA,;	 //[1]
                                     DESCCTA,;	 //[2]
                                     NORMAL,;	 //[3]
                                     NIVEL,;	 //[4]
                                     IDENTIFI,;	 //[5]
                                     aSaldoPer,; //[6]
                                     TIPOCONTA,; //[7]
                                     DESCCONT} )
        Else            
            aLinAux[6,nI] := Abs(SALDOATU)
            HMSet(oHashLin, CONTA, aLinAux)
        EndIf

        DbSkip()
    EndDo
    
    DbSelectArea("cArqTmp")
    Set Filter To
    dbCloseArea() 

    If Select("cArqTmp") == 0
        FErase(cArqTmp+GetDBExtension())
        FErase(cArqTmp+OrdBagExt())
    EndIF	

Next nI

dbselectArea("CT2")

aTotal := Array(3)
aTotal[1] := 0
aTotal[2] := 0
aTotal[3] := 0			

aTotAux := aClone(aTotal)

HMList(oHashLin, @aLinhas)

aSort(aLinhas,,,{|x,y| x[1] < y[1]})

oSection1:Init()

For nI := 1 To Len(aLinhas)
    
    nLinha := nI

	If aLinhas[nI,2,C_NIVEL] == 1		
        If nLinha <> 1
            ImpQbrLin(oReport) 	            
         
            ImpLinTot(oReport,aTotal,cPicture,"TOTAL")
         
            ImpQbrLin(oReport) 	

            aTotAux := aClone(aTotal)

            aTotal[1] := 0
            aTotal[2] := 0
            aTotal[3] := 0

            oReport:ThinLine()            
            oSection1:Cell("RECEITA"):SetBlock( { || "" } )	
        Else
            oSection1:Cell("RECEITA"):SetBlock( { || "RECEITA" } )		
        EndIf

        oSection1:Cell("CONTA"):SetBlock({ || aLinhas[nLinha,2,C_DESC] })	
		oSection1:Cell("VALCTA1"):SetBlock( { || Year(aPerSld[1,1]) } )		
        oSection1:Cell("VALCTA2"):SetBlock( { || Year(aPerSld[2,1]) } )		
        oSection1:Cell("VALCTA3"):SetBlock( { || Year(aPerSld[3,1]) } )		
		oSection1:PrintLine()		
		oReport:ThinLine()				
	Else	
		// Se Imprime Valor Zerado = Não
		If mv_par06 <> 1 .And.; 
			aLinhas[nLinha,2,C_SALDOATU,1] == 0 .And.;
			aLinhas[nLinha,2,C_SALDOATU,2] == 0 .And.;
			aLinhas[nLinha,2,C_SALDOATU,3] == 0 
			Loop
		Endif

        cDesc := AllTrim(aLinhas[nLinha,2,C_DESC])
        If !Empty(aLinhas[nLinha,2,C_DESCCONT])
            cDesc += ", "+AllTrim(aLinhas[nLinha,2,C_DESCCONT])
        EndIf

		If aLinhas[nLinha,2,C_TIPOCONTA]=="1"            
            cDesSint := cDesc
            oSection1:Cell("CONTA"):SetBlock( { || cDesSint } )            
        Else
            If Left(aLinhas[nLinha,2,C_CONTA],1) == "1"
                oSection1:Cell("RECEITA"):SetBlock( { || cDesc } )
            Else
                oSection1:Cell("CONTA"):SetBlock( { || cDesc } )  
                oSection1:Cell("RECEITA"):SetBlock( { || "" } )
            EndIf
            oSection1:Cell("VALCTA1"):SetBlock( { || Transform(aLinhas[nLinha,2,C_SALDOATU,1],cPicture) })
            oSection1:Cell("VALCTA2"):SetBlock( { || Transform(aLinhas[nLinha,2,C_SALDOATU,2],cPicture) })
            oSection1:Cell("VALCTA3"):SetBlock( { || Transform(aLinhas[nLinha,2,C_SALDOATU,3],cPicture) })
            oSection1:PrintLine()            
            
            aTotal[1] += aLinhas[nLinha,2,C_SALDOATU,1]
		    aTotal[2] += aLinhas[nLinha,2,C_SALDOATU,2]
		    aTotal[3] += aLinhas[nLinha,2,C_SALDOATU,3]
            
            If !Empty(cDesSint)
                cDesSint := ""
                ImpQbrLin(oReport)            
            EndIf
        EndIf
		
	EndIf		
	
Next nI

ImpQbrLin(oReport) 	            
         
ImpLinTot(oReport,aTotal,cPicture,STR0011) //"TOTAL"

aTotal[1] := aTotal[1] - aTotAux[1]
aTotal[2] := aTotal[2] - aTotAux[2]
aTotal[3] := aTotal[3] - aTotAux[3]

oReport:ThinLine()            

ImpLinTot(oReport,aTotal,cPicture,STR0012) //"SALDO TOTAL"

oSection1:Finish()

aSize(aTotal ,  0)
aSize(aTotAux,  0)
aSize(aLinhas,  0)
aSize(aCtbMoeda,0)
aSize(aSM0,     0)
aSize(aSaldoPer,0) 

aTotal    := nil
aTotAux   := nil
aLinhas   := nil
aCtbMoeda := nil
aSM0      := nil
aSaldoPer := nil

oReport:EndPage()

Return .T.
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpLinTot

Imprime linha de total

@author TOTVS
@since 07/08/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------
Static Function ImpLinTot(oReport,aTotal,cPicture,cTextTot)
Local oSection1 := oReport:Section("DETALHE")

DEFAULT aTotal     := {}
DEFAULT cPicture   := ""
DEFAULT cTextTot   := ""

oSection1:Cell("CONTA"):SetBlock({ || "" })	
oSection1:Cell("RECEITA"):SetBlock( { || cTextTot } )		            
oSection1:Cell("VALCTA1"):SetBlock( { || Transform(aTotal[1],cPicture) } )		
oSection1:Cell("VALCTA2"):SetBlock( { || Transform(aTotal[2],cPicture) } )		
oSection1:Cell("VALCTA3"):SetBlock( { || Transform(aTotal[3],cPicture) } )		
oSection1:PrintLine()	

Return 
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpQbrLin

Imprime quebra de linha

@author TOTVS
@since 07/08/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------
Static Function ImpQbrLin(oReport)
Local oSection1 := oReport:Section("DETALHE")

oSection1:Cell("CONTA"):SetBlock({ || ""})
oSection1:Cell("RECEITA"):SetBlock({ || ""})
oSection1:Cell("VALCTA1"):SetBlock( { || "" } )
oSection1:Cell("VALCTA2"):SetBlock( { || "" } )
oSection1:Cell("VALCTA3"):SetBlock( { || "" } )
oSection1:PrintLine()

Return 
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CTbRtPer

Retorna o array com os períodos do demonstrativo

@author TOTVS
@since 07/08/2020
@version 12.1.31
@return aRetPer - Array com os períodos a serem processados
/*/
//---------------------------------------------------------------------------------------
Static Function CTbRtPer(cAnoRef)
Local aRetPer := {}
Local cAnoAux := ""
Local nI      := 0

DEFAULT cAnoRef := Year(dDataBase)

aAdd(aRetPer,{StoD(cAnoRef+"0101"),StoD(cAnoRef+"1231")})

For nI := 1 to 2
    cAnoAux := cValToChar(Val(cAnoRef)+nI)
    aAdd(aRetPer,{StoD(cAnoAux+"0101"),StoD(cAnoAux+"1231")})
Next nI

Return aRetPer
