#Include "CTBR110.Ch"
#Include "PROTHEUS.Ch"

Static __cSegOfi := ""
Static lIsRedStor := FindFunction("IsRedStor") .and. IsRedStor() //Used to check if the Red Storn Concept used in russia is active in the system | Usada para verificar se o Conceito Red Storn utilizado na Russia esta ativo no sistema | Se usa para verificar si el concepto de Red Storn utilizado en Rusia esta activo en el sistema
Static nRowSize := Nil
STATIC __oTempTable
 
/*/
//Alterado tradução das colunas de Debito e Credito para Pais Mexico
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR110  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 09.11.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Diario Geral                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR110(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctbr110()
Local cFilIni		:= cFilAnt    
Private titulo		:= ""
Private nomeprog	:= "CTBR110"
Private l1StQb		:= .T.         
Private nTransC	 	:= 0 
Private nTransD	 	:= 0 
Private aSelFil	 	:= {}
Private lPECTR110 	:= ExistBlock("CTR110VAR")
Private lCpoNACSeq  := CT2->( FieldPos( "CT2_NACSEQ" ) > 0)  

__cSegOfi := SuperGetMV("MV_SEGOFI",,"0")

If TRepInUse() 
CTBR110R4()
Else
	CTBR110R3()
EndIf

cFilAnt := cFilIni
nRowSize := Nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR110R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 09/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Diario Geral - R4                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR110R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR110R4()                                                       
PRIVATE oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01  	      	// Data Inicial                          ³
//³ mv_par02            // Data Final                            ³
//³ mv_par03            // Moeda?                                ³
//³ mv_par04			// Set Of Books			    		     ³
//³ mv_par05			// Tipo Lcto? Real / Orcad / Gerenc / Pre³
//³ mv_par06  	      	// Pagina Inicial                        ³
//³ mv_par07         	// Pagina Final                          ³
//³ mv_par08         	// Pagina ao Reiniciar                   ³
//³ mv_par09         	// So Livro/Livro e Termos/So Termos     ³
//³ mv_par10         	// Imprime Balancete                     ³
//³ mv_par11         	// Imprime Plano de contas               ³ 
//³ mv_par12         	// Imprime Valor 0.00	                 ³
//³ mv_par13         	// Impr Cod(Normal/Reduz/Cod.Impressao)  ³ /// CT1_CODIMP
//³ mv_par14            // Num.linhas p/ o diario?				 ³ 
//| mv_par15               Salta linha entre contas?             |
//| mv_par16               Descricao na Moeda?                   |
//| mv_par17               Balancete Modelo?					 |
//| mv_par18               Seleciona Filiais?					 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()      

IF Valtype( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport:PrintDialog()      
Endif

oReport := Nil

Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 09/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()  

Local aArea	   		:= GetArea()   
Local CREPORT		:= "CTBR110"
Local CTITULO		:= OemToAnsi(STR0006)				// Emissao do Diario Geral
Local CDESC			:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)	// "Este programa ir  imprimir o Di rio Geral Modelo 1"
Local cTransp		:= ""
Local cDeTramD		:= ""
Local cDeTramC		:= ""
Local cPerg		   	:= "CTR110"			  
Local CLANCTO		:= ""
Local CVALDEB		:= ""
Local CVALCRED		:= ""
Local cMsgT			:= ""
Local cSeparador    := ""
Local cMoeda		:= ""
Local aCtbMoeda		:= {}
Local lRet		 	:= .T. 
Public cMascara		:= ""
Public cDescMoeda 	:= ""
Public cPicture		:= ""
Public nDecimais		:= 0
Public aTamVal		:= TAMSX3("CT2_VALOR")
Public nTamQuebra	:= 0      
Public nTamLanc		:= 0
Public nTamConta	:= 40  
Public nTamHist		:= 40

If !Pergunte( 'CTR110' , .T. )
	lRet := .F.
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// faz a validação do livro
if lRet .And. !Empty( mv_par04 ) 
	if ! VdSetOfBook( mv_par04 , .F. )
		lRet := .F.
	endif
Endif

IF lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par04)
	
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
	EndIf	
Endif

If lRet .And. mv_par18 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf
Else
	aSelFil := {cFilAnt} 
EndIf 
	
If !lRet	
	Set Filter To
	Return
EndIf

If !Empty(aSetOfBook[5])
	MsgInfo(STR0043+CHR(13)+STR0044,STR0045) 
	Return
Endif

cMoeda		:= mv_par03
cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf

// mascara do valor
cPicture 	:= aSetOfBook[4]
If Empty( cPicture ) .Or. cPicture == Nil
	cPicture := "@E " + TmContab(CT2->CT2_VALOR,aTamVal[1],nDecimais)
Endif
                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport := TReport():New( CREPORT,CTITULO,cPerg, { |oReport| ReportPrint( oReport, cPicture, nDecimais, cMascara, cSeparador, cDescMoeda ) }, CDESC ) 

nRowSize := Iif( Valtype(nRowSize) == "U", 32, nRowSize)

//Habilitado o parametro de personalização porém,
// não será permitido a alteração das sections
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)
oReport:SetPortrait(.T.) 

If cPaisLoc=="PAR"
	oReport:SetLandscape()			// Formato paisagem
	oReport:oPage:nPaperSize := 9	// Impressão em papel A4 - LandScape
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
           
If cPaisLoc $ "CHI|ARG"
	nTamLanc := 32
Else
	nTamLanc := 20
Endif
     
If cPaisLoc<>"PAR"
	nTamQuebra := ((nTamConta *2) + nTamLanc + nTamHist)
Else	
	nTamQuebra := 204-Iif(!lCpoNACSeq,7,0)
EndIf	

oSection1  := TRSection():New( oReport, STR0033, {"CT2"},,.F.,.F.,,,,,,,,,,If(cPaisLoc<>"PAR",.T.,.F.)/*AutoAjuste*/,)    //"TOTALIZADORES DIA / MÊS / GERAL"   
  
TRCell():New( oSection1, "DATA"	   		,"CT2",/*Titulo*/	,/*Picture*/,nTamQuebra,	/*lPixel*/,/*CodeBlock*/,/*"LEFT"*/,,"LEFT") 
TRCell():New( oSection1, "CDEBITO"		, 	   ,/*STR0022*/   ,/*Picture*/,aTamVal[1]+20	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Debito"
TRCell():New( oSection1, "CCREDITO"		,	   ,/*STR0023*/	  ,/*Picture*/,aTamVal[1]+20	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Credito"
oSection1:Cell("CDEBITO"):lHeaderSize	:= .F.
oSection1:Cell("CCREDITO"):lHeaderSize  := .F.

oSection1:SetHeaderSection(.F.)  
oSection1:SetReadOnly()
oSection1:SetEdit(.F.)//Inibido as celulas para não possibilitar personalização

oSection2  := TRSection():New( oReport, STR0026 , {"CT2"},, .F., .F.,,,,,,,,,,.T./*AutoAjuste*/, )    //"Lançamentos Contábeis"
//TRCell():New( oSection2, "CT2_DATA"		,"CT2" ,/*Titulo*/,/*Picture*/,10	,/*lPixel*/,/*CodeBlock*/)

If cPaisLoc=="PAR"
	
	If lCpoNACSeq
		TRCell():New( oSection2, "CT2_NACSEQ" ,"CT2",/*"Numero Asto"Titulo*/,/*Picture*/,TamSX3("CT2_NACSEQ")[1],/*lPixel*/,/*CodeBlock*/)
	EndIf		
	
	TRCell():New( oSection2, "CT2_DEBITO"	,"CT2" ,/*Titulo*/,/*Picture*/,TamSX3("CT1_CONTA")[1]+LEN(Alltrim(cMascara)),/*lPixel*/,/*CodeBlock*/)
	TRCell():New( oSection2, "DESCTADB","","Desc. Conta"/*Titulo*/,/*Picture*/,TamSX3("CT1_DESC01")[1],/*lPixel*/,/*{|| code-block de impressao }*/)//Descrição Conta
	TRCell():New( oSection2, "CT2_CREDIT"	,"CT2" ,/*Titulo*/,/*Picture*/,TamSX3("CT1_CONTA")[1]+LEN(Alltrim(cMascara)),/*lPixel*/,/*CodeBlock*/)
	TRCell():New( oSection2, "DESCTACR","","Desc. Conta"/*Titulo*/,/*Picture*/,TamSX3("CT1_DESC01")[1],/*lPixel*/,/*{|| code-block de impressao }*/)//Descrição Conta
Else
	TRCell():New( oSection2, "CT2_DEBITO"	,"CT2" ,/*Titulo*/,/*Picture*/,TamSX3("CT1_CONTA")[1]+LEN(Alltrim(cMascara))+5,/*lPixel*/,/*CodeBlock*/)
	TRCell():New( oSection2, "CT2_CREDIT"	,"CT2" ,/*Titulo*/,/*Picture*/,TamSX3("CT1_CONTA")[1]+LEN(Alltrim(cMascara))+5,/*lPixel*/,/*CodeBlock*/)
EndIf

// Controle de quebra de historico para contas com mais de 20 digitos
TRCell():New( oSection2, "CT2_HIST"		,"CT2" ,/*Titulo*/,/*Picture*/,nTamHist+15	,/*lPixel*/,/*CodeBlock*/,/*"LEFT"*/,.T.,"LEFT",.T.,,.F.)

If __cSegOfi != "0"
	TRCell():New( oSection2, "CLANCTO"		,	   ,STR0024 + "-SEGOFI"   ,/*Picture*/,nTamLanc		,/*lPixel*/,/*CodeBlock*/)		//"Numero Lancto"
Else
	TRCell():New( oSection2, "CLANCTO"		,	   ,STR0024 ,/*Picture*/,nTamLanc	,/*lPixel*/,/*CodeBlock*/)		//"Numero Lancto"
EndIf   
If cPaisLoc=="PAR"
	TRCell():New( oSection2, "CVALDEB"		, 	   ,STR0022   ,/*Picture*/,aTamVal[1]	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Debito"
	TRCell():New( oSection2, "CVALCRED"		,	   ,STR0023	  ,/*Picture*/,aTamVal[1],/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Credito"
Else
	TRCell():New( oSection2, "CVALDEB"		, 	   ,STR0022   ,/*Picture*/,aTamVal[1]+26	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Debito"
	TRCell():New( oSection2, "CVALCRED"		,	   ,STR0023	  ,/*Picture*/,aTamVal[1]+20	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Credito"
EndiF	
oSection2:Cell("CT2_DEBITO"):lHeaderSize  := .F.
oSection2:Cell("CT2_CREDIT"):lHeaderSize := .F.
//oSection2:Cell("CT2_HIST"):lHeaderSize := .F.
oSection2:Cell("CLANCTO"):lHeaderSize  := .F.
oSection2:Cell("CVALDEB"):lHeaderSize  := .F.
oSection2:Cell("CVALCRED"):lHeaderSize := .F.

If cPaisLoc=="PAR"

	If lCpoNACSeq
		oSection2:Cell("CT2_NACSEQ"):lHeaderSize  := .F.
	EndIf
	
	oSection2:Cell("DESCTADB"):lHeaderSize    := .F.
	oSection2:Cell("DESCTACR"):lHeaderSize    := .F.
EndIf


oSection2:SetTotalInLine(.F.)
oSection2:SetReadOnly()
oSection2:SetEdit(.F.)//Inibido as celulas para não possibilitar personalização
                           
oSection3  := TRSection():New( oReport, STR0034, ,, .F., .F.,,,,,,,,,,.T./*AutoAjuste*/,)    //"Transporte"
If cPaisLoc=="PAR"
	TRCell():New( oSection3,"Transporte", /*Alias*/, /*Titulo*/, /*Picture*/,nTamQuebra)     
	TRCell():New( oSection3,"CDEBTRANSP",,STR0022,/*Picture*/,aTamVal[1],/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")     //"Vlr.Debito"
	TRCell():New( oSection3,"CCREDTRANSP",,STR0023,/*cPicture*/,aTamVal[1],/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")     //"Vlr.Credito"
Else
	TRCell():New( oSection3, "Transporte", /*Alias*/, /*Titulo*/, /*Picture*/,nTamQuebra)     
	TRCell():New( oSection3, "CDEBTRANSP"	, 	   ,STR0022   ,/*Picture*/,aTamVal[1]+20	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Debito"
	TRCell():New( oSection3, "CCREDTRANSP"	,	   ,STR0023	  ,/*cPicture*/,aTamVal[1]+20	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Credito"
EndIf	
oSection3:Cell("CDEBTRANSP"):lHeaderSize  := .F.
oSection3:Cell("CCREDTRANSP"):lHeaderSize := .F.

//Não Imprimir cabeçalho
if MV_PAR19 == 2               
    oReport:HideHeader() 
	oReport:OnPageBreak( { || oReport:SkipLine(6)})
Endif

oSection3:SetHeaderSection(.F.)   
oSection3:SetReadOnly()   
oSection3:SetEdit(.F.)//Inibido as celulas para não possibilitar personalização
                   
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius	³ Data ³ 09/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, cPicture, nDecimais, cMascara, cSeparador, cDescMoeda )  

Local oSection1 	:= oReport:Section(1)     
Local oSection2 	:= oReport:Section(2)     
Local oSection3 	:= oReport:Section(3)     
Local oFunc1
Local oFunc2
Local nIndexC 		:= 0
Local cTipoAnt   	:= ""
Local lPula			:= Iif(mv_par10==1,.T.,.F.) 
Local lImpLivro		:=.t.                         
Local lImpTermos	:=.f.
Local cMSGT			:= SubStr(STR0014,3,25)
Local i				:= 0
Local nLinReport    := 6
Local nMaxLin		:= mv_par14
Local lSalLin 		:= Iif(MV_PAR15==1,.T.,.F.)
Local lResetPag		:= .T.
Local m_pag			:= 1 // controle de numeração de pagina
Local l1StQb		:= .T.  
Local nPagIni		:= mv_par06
Local nPagFim		:= mv_par07
Local nReinicia		:= mv_par08
Local nBloco		:= 0
Local nBlCount		:= 1  
Local nPaginas      := mv_par06      
Local dDataAnt      
Local lNovoDia		:= .T. 
Local lNovoMes	    := .F.
Local nToDiaC		:= 0 
Local nToDiaD		:= 0
Local nToMesC		:= 0 
Local nToMesD		:= 0    
Local nGeralC		:= 0
Local nGeralD		:= 0
Local lFim			:= .F.
Local nK			:= 0  
Local cFilOld	   	:= cFilAnt
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local nMonth        :=0
Local nYear        	:=0
Local lMesMeio      :=.f.
Local aMeses 		:= {STR0047,;	// "Janeiro"
						STR0048,;	// "Fevereiro"
						STR0049,;	// "Março"
						STR0050,;	// "Abril"
						STR0051,;	// "Maio"
						STR0052,;	// "Junho"
						STR0053,;	// "Julho"
						STR0054,;	// "Agosto"
						STR0055,;	// "Setembro"
						STR0056,;	// "Outubro"
						STR0057,;	// "Novembro"
						STR0058 }	// "Dezembro"
						
Local lColDbCr 		:= lIsRedStor // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Public lPrintZero	:= Iif(mv_par12 == 1,.T.,.F.)   

//Limitação de linhas para impressão do relatório.
If oReport:GetOrientation() == 1 .And. mv_par14 > 86 //Retrato 
	//Alert("Atenção. Para esta versão do relatório, o número de linhas não pode ser maior que 75.")
	nMaxLin := 86
ElseIf oReport:GetOrientation() == 2 .And. mv_par14 > 60 //Paisagem
	//Alert("Atenção. Para esta versão do relatório, o número de linhas não pode ser maior que 58.")
	nMaxLin := 60 
EndIf     

oSection2:SetHeaderPage(.T.) // Define o cabecalho da secao como padrao      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par09 == 1 ; lImpLivro := .T. ; lImpTermos := .F.
	Case mv_par09 == 2 ; lImpLivro := .T. ; lImpTermos := .T.
	Case mv_par09 == 3 ; lImpLivro := .F. ; lImpTermos := .T.      
EndCase		                                                  

aSetOfBook := CTBSetOf(mv_par04)
cPicture 	:= aSetOfBook[4]

If Empty( cPicture ) .Or. cPicture == Nil	
	cPicture := "@E 999,999,999,999,999.99"	 //cPicture := "@E " + TmContab(CT2->CT2_VALOR,aTamVal[1],nDecimais)	
Endif  
              
For nK := 1 to Len(aSelFil)
	cFilAnt := aSelFil[nK]
	SM0->(DbSeek(cEmpAnt+cFilAnt))
	nToDiaC		:= 0 
	nToDiaD		:= 0
	nToMesC		:= 0 
	nToMesD		:= 0    
	nGeralC		:= 0
	nGeralD		:= 0
	
	lFim := .F.	
	If lImpLivro
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| titulo do relatorio                                          |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		titulo		:= 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) + DTOC(mv_par02) + OemToAnsi(STR0011) + cDescMoeda + CtbTitSaldo(mv_par05) + OemToAnsi(STR0035) + cFilAnt 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| cabeçalho do relatorio                                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		oReport:SetCustomText( {|| (Pergunte("CTR110",.F.),CtCGCCabTR(,,,,,mv_par02,titulo,,,,,oReport,.T.,@lResetPag,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)) } )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtros do relatorio                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilter := "CT2->CT2_FILIAL == xFilial() .and. "
		cFilter += "DTOS(CT2->CT2_DATA) >= '" + DTOS( mv_par01 ) + "' .and. "
		cFilter += "DTOS(CT2->CT2_DATA) <= '" + DTOS( mv_par02 ) + "' .and. "
		cFilter += "CT2->CT2_MOEDLC = '" + mv_par03 + "' .and. "
		cFilter += "CT2->CT2_TPSALD = '" + mv_par05 + "' .and."
		cFilter += "CT2->CT2_VALOR <> 0 " 
						
		oSection2:SetFilter( cFilter )   
		
		oReport:SetMeter( RecCount() )  
				
	 	oSection1:OnPrintLine( {|| CTR110Maxl( nMaxLin, @nLinReport, cPicture )} )	  
	 	oSection2:OnPrintLine( {|| CTR110Maxl( nMaxLin, @nLinReport, cPicture )} )	  	
	
		If __cSegOfi != "0"
			oSection2:Cell("CLANCTO"):SetBlock( { || (CT2->CT2_LOTE+CT2->CT2_SBLOTE+"-"+CT2->CT2_SEGOFI+" "+CT2->CT2_LINHA) })
		Else
			oSection2:Cell("CLANCTO"):SetBlock( { || (CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA) })
		EndIf
        
		oSection2:Cell("CT2_HIST" ):SetBlock( { || Alltrim(CT2->CT2_HIST) })

		oSection2:Cell("CVALDEB" ):SetBlock( { || ValorCTB(Iif(CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3" , CT2->CT2_VALOR , 0 ) ,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbcr)})		
		oSection2:Cell("CVALCRED"):SetBlock( { || ValorCTB(Iif(CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3" , CT2->CT2_VALOR , 0 ),,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbcr)})		
		
	  	oSection2:Cell("CT2_DEBITO" ):SetBlock( { || ImpEntCont(cMascara,cSeparador,.T.) } ) 
	  	oSection2:Cell("CT2_CREDIT"):SetBlock( { || ImpEntCont(cMascara,cSeparador,.F.) } )
	  	
	  	If cPaisLoc=="PAR"
			
			If lCpoNACSeq
				oSection2:Cell("CT2_NACSEQ" ):SetBlock( { || CT2->CT2_NACSEQ } ) 
			EndIf
			
			oSection2:Cell("DESCTADB"):SetBlock( { || Iif(!Empty(CT2->CT2_DEBITO),CtbDescMoeda("CT1->CT1_DESC"+CtbMoeda(mv_par03)[1]),"") })
			oSection2:Cell("DESCTACR"):SetBlock( { || Iif(!Empty(CT2->CT2_CREDIT),CtbDescMoeda("CT1->CT1_DESC"+CtbMoeda(mv_par03)[1]),"") })
		EndIf
	
		oSection1:Cell("DATA"):SetBlock( { || Iif( lFim, STR0017, Iif(lNovoMes, STR0016 + IIF(lMesMeio, STR0046 + aMeses[nMonth] + STR0059 + Alltrim(Str(nYear)) ,""), Iif (lNovoDia, CT2->CT2_DATA, STR0015)))})     		     
	  	
	 	oSection1:Cell("CDEBITO"):SetBlock( { || Iif( lFim, ValorCTB( nGeralD,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbcr), Iif(lNovoDia, nil,;		
	 	Iif (lNovoMes, ValorCTB( nToMesD,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbcr), ValorCTB( nToDiaD,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbcr))))})  		
	 	oSection1:Cell("CCREDITO"):SetBlock( { || Iif( lFim, ValorCTB( nGeralC,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbcr), Iif(lNovoDia, nil,;		
	    Iif (lNovoMes, ValorCTB( nToMesC,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbcr), ValorCTB( nToDiaC,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbcr))))})  		
	
		oSection3:Cell("CDEBTRANSP"):SetBlock( { || ValorCTB( nTransD,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbcr)})  		
	  	oSection3:Cell("CCREDTRANSP"):SetBlock( { || ValorCTB( nTransC,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbcr)})  		
		oSection3:Cell("TRANSPORTE"):SetBlock( { || Iif(nLinReport == 10, DTOC(dDataAnt) + " " + STR0014, STR0013)}) 
	
		If CT2->( !EOF() ) 
			If Month(MV_PAR01) < Month(CT2->CT2_DATA) .and. Year(MV_PAR01) <= Year(CT2->CT2_DATA)
				nMonth := Month(MV_PAR01)                                                        
				nYear := Year(MV_PAR01)
				While ((nYear < Year(CT2->CT2_DATA)) .OR. ((nYear = Year(CT2->CT2_DATA)) .AND. (nMonth < Month(CT2->CT2_DATA))))
	 				lMesMeio:=.T.       
	 				lNovoDia:=.F.
			 		lNovoMes	:= .T.
					nToMesC		:= 0
					nToMesD 	:= 0 
					nTransC 	:= 0
			   		nTransD 	:= 0
				 	oSection1:Init()
					oSection1:PrintLine()
					oSection1:Finish()  			   		
					lNovoMes	:= .F. 
					nMonth++         
					If nMonth == 13
						nMonth:=1      
						nYear++										
					Endif 
					lMesMeio:=.F.
					lNovoDia:=.T.
				EndDo  
		        nMonth:=0     
			Endif
		
			While CT2->( !EOF() ) 

				If oReport:Cancel()
					oReport:CancelPrint()
				   	return
				EndIf   			
		   	
				dDataAnt := CT2->CT2_DATA   
				lNovoDia := .T.    
				nToDiaC  := 0
				nToDiaD  := 0
				nTransC  := 0
		   		nTransD  := 0
				
				//Imprime a data				
				oSection1:Init()
		      	oSection1:PrintLine() 
		 		oSection1:Finish()				
				nLinReport += 2
				
				oSection2:Init()		
				While CT2->CT2_DATA == dDataAnt  
			
				    If oReport:Cancel()
						oReport:CancelPrint()
						return
				    EndIf        
		
					lNovoDia := .F.   
										
					oSection2:PrintLine()
					
					NewImpCompl(,CT2->CT2_DATA, CT2->CT2_LOTE, CT2->CT2_SBLOTE, CT2->CT2_DOC, CT2->CT2_SEQLAN,; 
								CT2->CT2_EMPORI, CT2->CT2_FILORI,CT2->CT2_SEQHIS, MV_PAR03, @nLinReport)
					
					nLinReport++
										
					If lSalLin
		      		   oReport:SkipLine(1)  
		      		   nLinReport++
		    	  	EndIf 
					oReport:IncMeter()   
								
					If CT2->CT2_DC=="1" .Or. CT2->CT2_DC=="3"
						nToDiaD += CT2->CT2_VALOR 
						nToMesD += CT2->CT2_VALOR 
						nTransD += CT2->CT2_VALOR  
						nGeralD += CT2->CT2_VALOR  
					EndIf
					
					If 	CT2->CT2_DC=="2" .Or. CT2->CT2_DC=="3"
						nToDiaC += CT2->CT2_VALOR 
						nToMesC += CT2->CT2_VALOR 				
						nTransC += CT2->CT2_VALOR  	
						nGeralC += CT2->CT2_VALOR  							
					EndIf
					
					CT2->( dbSkip() )
				EndDo  
				
				oSection2:Finish()	
				
				//Imprime os totais do dia 				
				oSection1:Init() 
				oSection1:PrintLine()
				oSection1:Finish()
				nLinReport := nLinReport + 1
								
				If Month(CT2->CT2_DATA) != Month(dDataAnt)   
					nMonth := Month(dDataAnt) 
					nYear  := Year(dDataAnt)   
					If EMPTY(CT2->CT2_DATA)   
				 		lNovoMes	:= .T.					
					 	oSection1:Init()
						oSection1:PrintLine()
						oSection1:Finish()  
						nToMesC		:= 0
						nToMesD 	:= 0 
						nTransC 	:= 0
				   		nTransD 	:= 0
						lNovoMes	:= .F. 
						nMonth++    
						If nMonth == 13
							nMonth:=1      
							nYear++										
						Endif	     
					Else
			   	 		While ((nYear< Year(CT2->CT2_DATA)) .OR.( (nYear== Year(CT2->CT2_DATA)) .AND. (nMonth < Month(CT2->CT2_DATA))  ))
			   	 			If (nMonth!= Month(CT2->CT2_DATA).OR.nYear != Year(CT2->CT2_DATA) ) .and. (nMonth!= Month(dDataAnt) .or. nYear!= Year(dDataAnt))
			   	 				lMesMeio:=.T.
		   		 			eNDIF
					 		lNovoMes	:= .T.
						 	oSection1:Init()
							oSection1:PrintLine()
							oSection1:Finish()  
							nToMesC		:= 0
							nToMesD 	:= 0 
							nTransC 	:= 0
					   		nTransD 	:= 0
							lNovoMes	:= .F. 
							nMonth++         
							If nMonth == 13
								nMonth:=1      
								nYear++										
							Endif 							
							lMesMeio:=.F.
						EndDo  
					Endif 
				Endif    
			EndDo
			
			While ((nYear< Year(MV_PAR02)) .or. ( (nYear == Year(MV_PAR02) .and. (nMonth <= Month(MV_PAR02)) )))
				lMesMeio:=.T.
		 		lNovoMes	:= .T.
			 	oSection1:Init()
				oSection1:PrintLine()
				oSection1:Finish()  
				nToMesC		:= 0
				nToMesD 	:= 0 
				nTransC 	:= 0
		   		nTransD 	:= 0
				lNovoMes	:= .F. 
				nMonth++ 
				If nMonth == 13
					nMonth:=1      
					nYear++										
				Endif 
				lMesMeio:=.F.
			EndDo
							  
			lFim := .T.
		 	oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()
			
			oReport:EndPage()
		Else
			nMonth := Month(MV_PAR01)                                                        
			nYear := Year(MV_PAR01)
			While ((nYear < Year(MV_PAR02)) .OR. ((nYear = Year(MV_PAR02)) .AND. (nMonth <= Month(MV_PAR02))))
	 			lMesMeio:=.T.       
	 			lNovoDia:=.F.
		 		lNovoMes	:= .T.
				nToMesC		:= 0
				nToMesD 	:= 0 
				nTransC 	:= 0
		   		nTransD 	:= 0
			 	oSection1:Init()
				oSection1:PrintLine()
				oSection1:Finish()  			   		
				lNovoMes	:= .F. 
				nMonth++         
				If nMonth == 13
					nMonth:=1      
					nYear++										
				Endif 
				lMesMeio:=.F.
				lNovoDia:=.T.
			EndDo  
			lFim := .T.
		 	oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()
			oReport:EndPage()			
		EndIf
	Endif   	
Next

nGeralD := 0
nGeralC	:= 0
lFim := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressão do Balancete Modelo 1                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par10 == 1
	If MV_PAR17 == 1
		Ctbr040R4()
	ElseIf	MV_PAR17 == 2
		Ctbr043R4()	
	EndIf
	Pergunte( "CTR110" , .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressão do Plano de Contas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par11 == 1
	Ctbr010R4( mv_par03 )
Endif

If lImpTermos 							// Impressao dos Termos
	oReport:HideHeader()
	oSection2:Hide()

	Pergunte( "CTR110", .F. )
	
	cArqAbert:=GetMv("MV_LDIARAB")
	cArqEncer:=GetMv("MV_LDIAREN")

	dbSelectArea("SM0")
	aVariaveis:={}

	For i:=1 to FCount()	
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		Else
            If FieldName(i)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek( padr( "CTR110" , Len( X1_GRUPO ) , ' ' ) + "01" )

	While ! Eof() .And. SX1->X1_GRUPO  == padr( "CTR110" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	dbSelectArea( "CVB" )
	CVB->(dbSeek( xFilial( "CVB" ) ))
	For i:=1 to FCount()
		If FieldName(i)=="CVB_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		ElseIf FieldName(i)=="CVB_CPF"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 999.999.999-99")})
		Else
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
	AADD(aVariaveis,{"M_MES",MesExtenso()})
	AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})

	If lPECTR110
		aVariaveis := 	ExecBlock("CTR110VAR",.F.,.F.,{aVariaveis,nPagIni,nPagFim,nReinicia})
	EndIf

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		oReport:EndPage()
		ImpTerm2(cArqAbert,aVariaveis,,,,oReport)		
	Endif

	If cArqEncer#NIL
		oReport:EndPage()
		ImpTerm2(cArqEncer,aVariaveis,,,,oReport)
	Endif	 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| cabeçalho do relatorio                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:EndPage()
	oReport:ShowHeader()
	oSection2:Show()

Endif

cFilAnt := cFilOld
RestArea(aAreaSM0)	
RestArea(aArea)		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |CTR110MaxL    ºAutor ³ Renato F. Campos º Data ³ 01/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz a quebra de pagina de acordo com o parametro passado   º±±
±±º          ³ no relatorio.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPL1 - Numero maximo de linhas definido no relatorio      º±±
±±º          ³ EXPL2 - Contador de linhas impressas no relatorio          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Diario Geral                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function CTR110MaxL(nMaxLin, nLinReport, cPicture)
Local oSection1 := oReport:Section(1)
Local oSection3 := oReport:Section(3)       
Local nLinhas   := 0 
Local nRowParam	:= 0

nRowParam := nRowSize * nMaxLin
 
If oSection1:Printing()
	nLinhas := 4
Else
	nLinhas := 1
	If MV_PAR15 == 1
		nLinhas++
	EndIf
Endif

If ( oReport:Row() > nRowParam )
	If nTransC > 0 .OR. nTransD > 0   
		oSection3:Init()
		oSection3:Printline() 
		oSection3:Finish()
		
 		oReport:EndPage() 	
		nLinReport := 10
		
		oSection3:Init()
		oSection3:Printline()
		oSection3:Finish()
		oReport:Skipline() 		
    Else  
  		nLinReport := 6
 		oReport:EndPage()
	EndIf 	
EndIf   

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ImpEntCont³ Autor ³ Marcio Menon		    ³ Data ³ 16/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao do código da Entidade Contabil, conforme   ³±±
±±³          ³a opção do parametro mv_par13.							  ³±±
±±³          ³						                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB         	                           				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpEntCont(cMascara, cSeparador , lDeb )  
Local cRet := ""

DEFAULT cMascara   := GetMv("MV_MASCARA")
DEFAULT cSeparador := '' 

If lDeb
	If !Empty(CT2->CT2_DEBITO)					/// Se a Conta a Debito estiver preenchida
	  	dbSelectArea("CT1")
	   	dbSetOrder(1)
		If MsSeek(xFilial("CT1")+CT2->CT2_DEBITO,.F.)	/// e existir no plano de contas
			If mv_par13 == 2							/// Impressao do Codigo Reduzido
				cRet := EntidadeCTB(CT1->CT1_RES,0 ,00,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
			ElseIf mv_par13 == 3 			 	/// Impressao do Codigo de Impressao (se o campo existir)
				cRet := EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
			Else										/// Impressao do Codigo Normal
				cRet := EntidadeCTB(CT2->CT2_DEBITO,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
			Endif
		Else
			cRet := EntidadeCTB(CT2->CT2_DEBITO,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
		Endif
	Endif                              
Else                 
	If !Empty(CT2->CT2_CREDIT)
	   	dbSelectArea("CT1")
	  	dbSetOrder(1)
		If MsSeek(xFilial("CT1")+CT2->CT2_CREDIT,.F.)
			If mv_par13 == 2							/// Impressao do Codigo Reduzido
				cRet := EntidadeCTB(CT1->CT1_RES,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
			ElseIf mv_par13 == 3 						/// Impressao do Codigo de Impressao (se o campo existir)
				cRet := EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
			Else										/// Impressao do Codigo Normal
				cRet := EntidadeCTB(CT2->CT2_CREDIT,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
			Endif
		Else
			cRet := EntidadeCTB(CT2->CT2_CREDIT,0,0,nTamConta,.F.,cMascara,cSeparador,,,,,.F.)
		Endif
	Endif
EndIf	
        
dbSelectArea("CT2")
Return cRet

/*
-------------------------------------------------------- RELEASE 3 -------------------------------------------------------------
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR110R3³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 09.11.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Diario Geral                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR110(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR110R3()

Local WnRel
Local aCtbMoeda	:={}

LOCAL cString	:= "CT2"
LOCAL cDesc1 	:= OemToAnsi(STR0001)  //"Este programa ir  imprimir o Di rio Geral Modelo 1, de acordo"
LOCAL cDesc2 	:= OemToAnsi(STR0002)  //"com os parƒmetros sugeridos pelo usuario. Este modelo e ideal"
LOCAL cDesc3	:= OemToAnsi(STR0003)  //"para Plano de Contas que possuam codigos nao muito extensos"

Local Titulo 	:= OemToAnsi(STR0006)				// Emissao do Diario Geral
Local lRet		:= .T.  
Local nQuadro	:= 0  

PRIVATE Tamanho	:= "M"
PRIVATE aLinha  := { }
PRIVATE aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"

PRIVATE cPerg   	:= "CTR110"
PRIVATE nomeprog	:= "CTBR110"
PRIVATE nLastKey	:= 0
PRIVATE lSalLin		:= .T.

If ( !AMIIn(34) )	// Acesso somente pelo SIGACTB
	Return
EndIf

wnrel := "CTBR110"

If !Pergunte( 'CTR110' , .T. )
	lRet := .F.
EndIf

If lRet .And. mv_par18 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf
Else
	aSelFil := {cFilAnt} 
EndIf 

If mv_par14 > 65
	Alert(STR0042)
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01  	      	// Data Inicial                          ³
//³ mv_par02            // Data Final                            ³
//³ mv_par03            // Moeda?                                ³
//³ mv_par04			// Set Of Books				    		     ³
//³ mv_par05			// Tipo Lcto? Real / Orcad / Gerenc / Pre³
//³ mv_par06  	      	// Pagina Inicial                        ³
//³ mv_par07         	// Pagina Final                          ³
//³ mv_par08         	// Pagina ao Reiniciar                   ³
//³ mv_par09         	// So Livro/Livro e Termos/So Termos     ³
//³ mv_par10         	// Imprime Balancete                     ³
//³ mv_par11         	// Imprime Plano de contas               ³ 
//³ mv_par12         	// Imprime Valor 0.00	                 ³
//³ mv_par13         	// Impr Cod(Normal/Reduz/Cod.Impressao)  ³ /// CT1_CODIMP
//³ mv_par14            // Num.linhas p/ o diario?				 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

Private aQuadro := { "","","","","","","",""}              

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next	

CtbCarTxt()

lSalLin := Iif(MV_PAR15==1,.T.,.F.)

If mv_par10 = 1
	Pergunte("CTR040",.T.)
	Pergunte("CTR110",.F.)	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// faz a validação do livro
if ! Empty( mv_par04 ) 
	if ! VdSetOfBook( mv_par04 , .F. )
		lRet := .F.
	endif
Endif

IF lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par04)
	
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
	EndIf	
Endif

If !lRet	
	Set Filter To
	Return
EndIf

If !Empty(aSetOfBook[5])
	MsgInfo(STR0043+CHR(13)+STR0044,STR0045) 
	Return
Endif

If aReturn[4] == 2 // Paisagem
	Tamanho := "G"
EndIf	

// SetDefault(aReturn,cString)
SetDefault(aReturn,cString,,,Tamanho,aReturn[4])

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR110Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR110IMP ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 10/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Diario Geral                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ CTR110Imp(lEnd,wnRel,cString,aSetOfBook,aCebMoeda)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅ±±
±±³Parametros ³ ExpL1   - A‡ao do Codeblock                                ³±±
±±³           ³ ExpC1   - T¡tulo do relat¢rio                              ³±±
±±³           ³ ExpC2   - Mensagem                                         ³±±
±±³           ³ ExpA1   - Matriz ref. Config. Relatorio                    ³±±
±±³           ³ ExpA2   - Matriz ref. a moeda                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR110Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local Cbcont
Local Cabec1		:= OemToAnsi(STR0007)
Local Cabec2		:= OemToAnsi(STR0008)
Local Titulo		:= ""

Local cPicture
Local cDescMoeda
Local cSeparador	:= ""
Local cMascara
Local cLote			:= ""
Local cSubLote		:= ""
Local cDoc			:= ""
Local cCancel		:= OemToAnsi(STR0012)

Local dData			:= Ctod("")
Local dDataFim		:= mv_par02

Local lData			:= .T.
Local lImpLivro		:= .T.
Local lImpTermos	:= .F.								
Local lPrintZero	:= Iif(mv_par12 == 1,.T.,.F.)
Local nTotDiaD		:= 0
Local nTotDiaC		:= 0
Local nTotMesD		:= 0
Local nTotMesC		:= 0
Local nTotDeb		:= 0
Local nTotCred	 	:= 0
Local nDia
Local nMes
Local nTamDeb		:= 15			// Tamanho da coluna de DEBITO
Local nTamCrd		:= 14			// Tamanho da coluna de CREDITO
Local nRecCT2		:= 0
Local nColDeb		:= 102			// Coluna de impressao do DEBITO
Local nColCrd		:= 118			// Coluna de impressao do CREDITO

Local bPular		:= { || 	CT2->CT2_MOEDLC <> cMoeda .Or.;                    
								CT2->CT2_VALOR = 0 .Or.;
								(CT2->CT2_TPSALD # mv_par05 .And. mv_par05 # "*") }
Local cFilCT1		:= xFilial("CT1")
Local cSeqLan		:= ""
Local cSeqHis		:= ""
Local cEmpOri		:= ""
Local cFilOri		:= ""
Local nPagIni		:= mv_par06
Local nPagFim		:= mv_par07
Local nReinicia		:= mv_par08
Local nBloco		:= 0
Local nBlCount		:= 0
Local i
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local lNewPAGFIM	:= If(nReinicia > nPagFim,.T.,.F.)
Local nMaxLin   	:= mv_par14
Local LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))
Local nInutLin		:= 1
Local aPosCol 		:= {0,0,0,0,0,0}
Local ntamHist		:= TamSX3("CT2_HIST")[1] 	
Local l1StQb		:= .T.    
Local nK		 	:= 0 
Local cFilOld  		:= cFilAnt
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local lPrimeiro	 	:= .F.
Local lTemDiario 	:= .F.
Local lNoZero		:= .F.
Local cHist			:= ""  
Local nLinHist      := 0
Local nContador		:= 0
Local nYear 		:=0
Local nMonth 		:=0
Local aMeses 		:= {STR0047,;	// "Janeiro"
						STR0048,;	// "Fevereiro"
						STR0049,;	// "Março"
						STR0050,;	// "Abril"
						STR0051,;	// "Maio"
						STR0052,;	// "Junho"
						STR0053,;	// "Julho"
						STR0054,;	// "Agosto"
						STR0055,;	// "Setembro"
						STR0056,;	// "Outubro"
						STR0057,;	// "Novembro"
						STR0058 }	// "Dezembro"

m_pag   			:= mv_par06

CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

Private cMoeda

aPosCol := {0,21,42,83,102,118,55}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
cMoeda	:= mv_par03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando definicoes para impressao -> Decimais, Picture,   ³
//³ Mascara da Conta                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf

cPicture 	:= aSetOfBook[4]

Titulo		:= 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) +;
				DTOC(mv_par02) + OemToAnsi(STR0011) + cDescMoeda + CtbTitSaldo(mv_par05)

dbSelectAre("CT2")
dbSetOrder(1)
SetRegua(Reccount())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par09==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par09==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par09==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

If TamSX3("CT1_CONTA")[1] > 30 .OR. TamSX3("CT1_CONTA")[1]+LEN(Alltrim(cMascara)) > 30 .or. aReturn[4]==2

	//********************************************************
	//  Layout 01 - Utilizado em Modo Paisagem ou quando     *
	//  a conta + mascara são maiores que 30 caratreres      *
	//********************************************************
	// Conta Debito  	= 40
	// Conta Credito  	= 40
	// Historico 		= 40
	// Numero        	= 28
	TAMANHO := "G"
	Cabec1	:= OemToAnsi(STR0027) //"                   C O N T A                                                     H I S T ó R I C O                        Número                                  V  A  L  O  R"
    Cabec2	:= OemToAnsi(STR0028) //"D é B I T O                              C R é D I T O                                                                     Lancto                           Débito              Crédito"
	aPosCol := {0,41,81,122,147,169,115}
	ntamHist:= 40 

ElseIf TamSX3("CT1_CONTA")[1]+LEN(Alltrim(cMascara)) > 20 .and. aReturn[4]==1

	If cPaisLoc $ "CHI|ARG"
		//*************************************************************
		//  Layout 02 - Utilizado em Modo Retrato e quando a conta  + *
		//  mascara são maiores que 20 caratreres e pais CHI ou ARG   *
		//*************************************************************
		// Conta Debito  	= 25
		// Conta Credito  	= 25
		// Historico 		= 20
		// Numero        	= 28		

		Cabec1	:= 	OemToAnsi(STR0031) //"                 C O N T A                          H I S T O R I C O    NUMERO                                   V  A  L  O  R"
		Cabec2	:= 	OemToAnsi(STR0032) //"D E B I T O               C R E D I T O                                  LANCTO                                DEBITO        CREDITO"
		aPosCol := {0,26,52,73,102,118,55}
		ntamHist:= 20 
	Else	

		//********************************************************
		//  Layout 03 - Utilizado em Modo Retrato e quando a     *
		//  conta  + mascara não são maiores que 20 caratreres       *
		//********************************************************
		// Conta Debito  	= 25
		// Conta Credito  	= 25
		// Historico 		= 30
		// Numero        	= 18

		Cabec1	:= OemToAnsi(STR0029) //"                      C O N T A                               H I S T O R I C O      NUMERO                          V  A  L  O  R"
 		Cabec2	:= OemToAnsi(STR0030) //"D E B I T O                    C R E D I T O                                         LANCTO                      DEBITO        CREDITO"
 		aPosCol := {0,26,52,83,101,118,55}  
		ntamHist:= 30  		                        	
	EndIf   
	
EndIf

// Força tamanho
LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))           

For nK := 1 to Len(aSelFil)
	
	cFilAnt := aSelFil[nK]
	nTotDiaD		:= 0
	nTotDiaC		:= 0
	nTotMesD		:= 0
	nTotMesC		:= 0
	nTotDeb		:= 0
	nTotCred	 	:= 0
	lPrimeiro	:= .T.
  	dbSelectArea("CT2")
  	dbSeek(xFilial()+Dtos(mv_par01),.T.)		
	nMonth := Month(MV_PAR01)                                                        
	nYear := Year(MV_PAR01)       	
	  	
	While lImpLivro .And. !Eof() .and. CT2->CT2_FILIAL == xFilial() .And.;
			DTOS(CT2->CT2_DATA) <= DTOS(mv_par02)   
	
		IF lEnd
			@Prow()+1, 0 PSAY cCancel 
			Exit
		EndIF
	
		If Eval(bPular)
			dbSkip()
			Loop
		EndIf
		
		If lPrimeiro
			Titulo:= OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) +;
			DTOC(mv_par02) + OemToAnsi(STR0011) + cDescMoeda + CtbTitSaldo(mv_par05) + OemToAnsi(STR0035) + cFilAnt 
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
			CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho) 
			lPrimeiro := .F.  
			
			While ((nYear <= Year(CT2->CT2_DATA)) .AND. (nMonth < Month(CT2->CT2_DATA)))		
				If li > nMaxLin 
				  	CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
					CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
				EndIF   
				@li,aPosCol[1] PSAY OemToAnsi(STR0016 +STR0046 + aMeses[nMonth] + STR0059 + Alltrim(Str(nYear)))				
				ValorCTB(nTotMesD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
				ValorCTB(nTotMesC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
				nTotMesD := 0
				nTotMesC := 0
				li+=1
				nMonth++         
				If nMonth == 13
					nMonth:=1      
					nYear++										
				Endif 
			EndDo			
	   EndIf
	   
		nMes 	:= Month(CT2->CT2_DATA)
			
		While ! Eof() .And. CT2->CT2_FILIAL == xFilial() .And. ;
			DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) .And.;
			Month(CT2->CT2_DATA) == nMes

		
			If Eval(bPular)
				dbSkip()

				If nMes <> Month(CT2->CT2_DATA)
					nMonth	:= nMonth++
				Endif
				
				Loop
			EndIf
	
			nDia := Day(CT2->CT2_DATA)
			lData:= .T.	
			lTemDiario 	:= .T.
			
			While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And.;
				DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) .And.;
				Month(CT2->CT2_DATA) == nMes .And. Day(CT2->CT2_DATA) == nDia ////varre o dia
	
				IF lEnd
					@Prow()+1, 0 PSAY cCancel 
					Exit
				EndIF
	
				IncRegua()
	
				If Eval(bPular)
					dbSkip()
					
					If nMes <> Month(CT2->CT2_DATA)
						nMonth	:= nMonth++
					Endif
										
					Loop
				EndIf
			
				cDoc 		:= CT2->CT2_DOC
				cLote		:= CT2->CT2_LOTE
				cSubLote	:= CT2->CT2_SBLOTE
	
				// Loop para imprimir mesmo lote / documento / continuacao de historico
				While !Eof() .And. CT2->CT2_FILIAL == xFilial() 		.And.;
									CT2->CT2_DOC == cDoc 				.And.;
									CT2->CT2_LOTE == cLote 			.And.;
									CT2->CT2_SBLOTE == cSubLote 		.And.;
							   DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) 	.And.;
					          Month(CT2->CT2_DATA) == nMes 			.And.;
					            Day(CT2->CT2_DATA) == nDia
	
					If Eval(bPular)
						dbSkip()
						
						If nMes <> Month(CT2->CT2_DATA)
							nMonth	:= nMonth++
						Endif
						
						Loop
					EndIf 

					If li > nMaxLin 
						//	Imprime "a transportar ----->" ao final da pagina
						If nTotDiaD <> 0 .or. nTotDiaC <> 0
							@li,055 PSAY OemToAnsi(STR0013)						// A transportar
							If nTotDiaD <> 0
								ValorCTB(nTotDiaD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
							EndIf
							If nTotDiaC <> 0
								ValorCTB(nTotDiaC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
							EndIf                                               
							li++
						EndIF             
	
					  	CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
	
						CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
						// Imprime "de transporte -------->" no inicio da pagina
						If (nTotDiaD <> 0 .or. nTotDiaC <> 0)
							li++                                           
							@li,000 PSAY DTOC(CT2->CT2_DATA)
							@li,055 PSAY OemToAnsi(STR0014)
							If nTotDiaD <> 0
								ValorCTB(nTotDiaD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
							EndIf
							If nTotDiaC <> 0
								ValorCTB(nTotDiaC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
							EndIf                                               
								li+=1
						EndIF
					EndIF   
					
					If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"	
						nTotDeb 	+= CT2->CT2_VALOR
						nTotDiaD	+= CT2->CT2_VALOR
						nTotMesD	+= CT2->CT2_VALOR
					EndIf
					If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
						nTotCred 	+= CT2->CT2_VALOR
						nTotdiaC 	+= CT2->CT2_VALOR
						nTotMesC 	+= CT2->CT2_VALOR
					EndIf

					If lData
						li++
						@ li, 000 PSAY DTOC(CT2->CT2_DATA)
						li++
						lData := .F.
					EndIf
					
					If lSalLin
						li++
					EndIf
					
					If !Empty(CT2->CT2_DEBITO)					/// Se a Conta a Debito estiver preenchida
						dbSelectArea("CT1")
						dbSetOrder(1)
						If MsSeek(cFilCT1+CT2->CT2_DEBITO,.F.)	/// e existir no plano de contas
							If mv_par13 == 2							/// Impressao do Codigo Reduzido
							EntidadeCTB(CT1->CT1_RES,li,00,25,.F.,cMascara,cSeparador)
							ElseIf mv_par13 == 3 			 	/// Impressao do Codigo de Impressao (se o campo existir)
							EntidadeCTB(CT1->CT1_CODIMP,li,00,25,.F.,cMascara,cSeparador)
							Else										/// Impressao do Codigo Normal
							EntidadeCTB(CT2->CT2_DEBITO,li,00,25,.F.,cMascara,cSeparador)
							Endif
						Else
						EntidadeCTB(CT2->CT2_DEBITO,li,00,25,.F.,cMascara,cSeparador)						
						Endif
					Endif                              
					                 
					If !Empty(CT2->CT2_CREDIT)
						dbSelectArea("CT1")
						dbSetOrder(1)
						If MsSeek(cFilCT1+CT2->CT2_CREDIT,.F.)
							If mv_par13 == 2							/// Impressao do Codigo Reduzido
							EntidadeCTB(CT1->CT1_RES,li,aPosCol[2],25,.F.,cMascara,cSeparador)			
							ElseIf mv_par13 == 3 						/// Impressao do Codigo de Impressao (se o campo existir)
							EntidadeCTB(CT1->CT1_CODIMP,li,aPosCol[2],25,.F.,cMascara,cSeparador)
							Else										/// Impressao do Codigo Normal
							EntidadeCTB(CT2->CT2_CREDIT,li,aPosCol[2],25,.F.,cMascara,cSeparador)					
							Endif
						Else
						EntidadeCTB(CT2->CT2_CREDIT,li,aPosCol[2],25,.F.,cMascara,cSeparador)					
						Endif
					Endif 
					
				 	//**********************************
	        		// Controle de quebra do historico *
	        		//**********************************

					// Procura pelo complemento de historico        
					nRecCT2 := CT2->(Recno())
					dData	:= CT2->CT2_DATA
					cSeqLin := CT2->CT2_LINHA
					cSeqHis	:= CT2->CT2_SEQHIS
					cEmpOri	:= CT2->CT2_EMPORI
					cFilOri	:= CT2->CT2_FILORI
					cSeqLan := CT2->CT2_SEQLAN 
				 	
					cHist := ImpCompl(CT2->CT2_DATA, CT2->CT2_LOTE, CT2->CT2_SBLOTE, CT2->CT2_DOC, CT2->CT2_SEQLAN, CT2->CT2_EMPORI, CT2->CT2_FILORI,CT2->CT2_SEQHIS, MV_PAR03)
	     			nLinHist := mlCount(cHist, nTamHist)
	
	        	    For nContador := 1 To nLinHist
						@ li, aPosCol[3] PSAY MemoLine(cHist, nTamHist, nContador)    
						
	        	        If nContador == 1
	        	   		 	If cPaisLoc $ "CHI|ARG"
				   				@ li, aPosCol[4] PSAY CT2->CT2_LOTE+CT2->CT2_SBLOTE+"-"+CT2->CT2_SEGOFI+" "+CT2->CT2_LINHA
							Else								
								@ li, aPosCol[4] PSAY CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA
							EndIf 					
	
			        		nValor := CT2->CT2_VALOR
							If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"
								ValorCTB(nValor,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
							EndIf
							If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
								ValorCTB(nValor,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
							EndIf

	        	        Endif
	        	        
	        	        If nContador < nLinHist
		        	        li++    

							If li >= nMaxlin .And. ( nLinHist-nContador > 1 )
								//	Imprime "a transportar ----->" ao final da pagina
								If (nTotDiaD <> 0 .or. nTotDiaC <> 0)
									@li,aPosCol[7] PSAY OemToAnsi(STR0013)						// A transportar
									If nTotDiaD <> 0
										ValorCTB(nTotDiaD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
									EndIf
									If nTotDiaC <> 0
										ValorCTB(nTotDiaC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
									EndIf                                               
									li++
								EndIF             
	
								CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
	
								CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
								// Imprime "de transporte -------->" no inicio da pagina
								If (nTotDiaD <> 0 .or. nTotDiaC <> 0)
									li++                 
									@ li, 000 PSAY DTOC(CT2->CT2_DATA)
									@li,aPosCol[7] PSAY OemToAnsi(STR0014)
									If nTotDiaD <> 0
										ValorCTB(nTotDiaD,li,aPosCol[5]-1,nTamDeb,nDecimais,.F.,cPicture,"1")
									EndIf
									If nTotDiaC <> 0
										ValorCTB(nTotDiaC,li,aPosCol[6]-1,nTamCrd,nDecimais,.F.,cPicture,"2")
									EndIf                                               
										li+=1
								EndIF        
							EndIF						
		        	        
					 	Endif
						        	        
	        	   	Next nContador   
        	   
					li++ 
									
				  	dbSelectArea("CT2")
			        dbSkip()
			        
			        If nMes <> Month(CT2->CT2_DATA)
			        	nMonth	:= nMonth++
			        Endif
			        
				EndDo
			EndDO

			If lEnd
				Exit
			Endif	
			IF (nTotDiad+nTotDiac)>0
				@li,aPosCol[7] PSAY OemToAnsi(STR0015)			// Totais do Dia
				ValorCTB(nTotDiaD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
				ValorCTB(nTotDiaC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
				nTotDiaD	:= 0
				nTotDiaC	:= 0
			EndIF
		EndDO
		If lEnd
			Exit
		End	
		
		// Totais do Mes
		IF (nTotMesd+nTotMesc) > 0
			li++
			@li,aPosCol[7] PSAY OemToAnsi(STR0016)				// Totais do Mes
			ValorCTB(nTotMesD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
			ValorCTB(nTotMesC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
			nTotMesD := 0
			nTotMesC := 0
			li+=1
			lNoZero := .T.

		EndIF

		While ( (nYear <= Year(CT2->CT2_DATA)) .AND. (nMonth < Month(CT2->CT2_DATA)) .And. nMonth <= Month(mv_par02) ) //varre o mês
			If li > nMaxLin 
			  	CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
				CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
			EndIF   	
			If !lNoZero		
				@li,aPosCol[1] PSAY OemToAnsi(STR0016 + STR0046 + aMeses[nMonth] + STR0059 + Alltrim(Str(nYear)))				
				ValorCTB(nTotMesD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
				ValorCTB(nTotMesC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
			EndIf
			nTotMesD := 0
			nTotMesC := 0
			li+=1
			nMonth++         
			If nMonth == 13
				nMonth:=1      
				nYear++										
			Endif 
			lNoZero := .F.
		EndDo	
	EndDO
	
	IF (nTotDiad+nTotDiac)>0 .And. !lEnd
		// Totais do Dia - Ultimo impresso
		li++
		@li,aPosCol[7] PSAY OemToAnsi(STR0015)				// Totais do Dia
		ValorCTB(nTotDiaD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotDiaC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
		li++
	
		// Totais do Mes - Ultimo impresso
		@li,aPosCol[7] PSAY OemToAnsi(STR0016)  			// Totais do Mes
		ValorCTB(nTotMesD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotMesC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
		li++
	EndIF
	
	// Total Geral impresso     
	While ((nYear <= Year(mv_par02)) .AND. (nMonth <= Month(mv_par02))) .AND. (STR(nYear,4) + STRZero(nMonth,2)  < SubStr(DToS(CT2->CT2_DATA),1,6))  
			
		If li > nMaxLin 
		  	CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
			CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
		EndIF   			
		
		If !lNoZero	
			@li,aPosCol[1] PSAY OemToAnsi(STR0016 +STR0046  + aMeses[nMonth] + STR0059 + Alltrim(Str(nYear)))				
			ValorCTB(nTotMesD,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
			ValorCTB(nTotMesC,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
		EndIf	
		nTotMesD := 0
		nTotMesC := 0
		li+=1
		nMonth++         
		
		If nMonth == 13
			nMonth:=1      
			nYear++										
		Endif
		lNoZero := .F.
	EndDo	
	
	IF !lEnd
		@li,aPosCol[7] PSAY OemToAnsi(STR0017)				// Total Geral
		ValorCTB(nTotDeb ,li,aPosCol[5],nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotCred,li,aPosCol[6],nTamCrd,nDecimais,.F.,cPicture,"2")
		li++
	EndIF
	
	nLinAst := GetNewPar("MV_INUTLIN",0)
	If li < nMaxLin .and. nLinAst <> 0 .and. !lEnd
		For nInutLin := 1 to nLinAst
			li++
			@li,00 PSAY REPLICATE("*",LIMITE)	
			If li == nMaxLin 
				Exit
			EndIf
		Next
	EndIf
	
	dbSelectarea("CT2")
	dbSetOrder(1)
	Set Filter To  
	
	
	If mv_par10 == 1 .or. mv_par11 == 1
		If (li + 3) <  60
			@57,00 PSAY __PrtfatLine()
	  	  	@58,01 Psay STR0020   // ("Microsiga Software S/A")
	 	   	If Tamanho == "M"
	    		@58,100 Psay STR0021 + " " + Time()  //"Hora Termino: "
	    	ElseIf Tamanho == "G"
		    	@58,190 Psay STR0021 + " " + Time()  //"Hora Termino: "
	    	Else
		    	@58,050 Psay STR0021 + " " + Time()  //"Hora Termino: "
			EndIf               
			@59,00 PSAY __PrtfatLine()
		EndIf	
	EndIf
Next

If mv_par10 == 1
	If lTemDiario .OR. Aviso(STR0036,STR0037, { STR0038,STR0039 }) == 2  // "Atencao"##"Diario nao contem dados para os parametros especificados. Continuar Imprimindo Balancete?"##"Nao"##"Sim"
		If mv_par17 == 1
			Ctbr040R3( wnRel )
		ElseIf mv_par17 == 2
			Ctbr043R4() //Direcionado pela descontinuaç?o do r3 no CTBR43R3
		EndIf		   
		Pergunte( "CTR110" , .F. )
	EndIf
EndIf 

If mv_par11 == 1
	If lTemDiario .OR. Aviso(STR0036,STR0040, { STR0038,STR0039 }) == 2  //"Atencao"##"Diario nao contem dados para os parametros especificados. Continuar Imprimindo Plano de contas?"##"Nao"##"Sim"
		Ctbr010R3( @wnRel,mv_par02,mv_par03)
	Endif
Endif

If lImpTermos 							// Impressao dos Termos
	Pergunte( "CTR110" , .F. )
	
	cArqAbert:=GetMv("MV_LDIARAB")
	cArqEncer:=GetMv("MV_LDIAREN")

	dbSelectArea("SM0")
	aVariaveis:={}

	For i:=1 to FCount()	
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform( FieldGet(i) , "@R 99.999.999/9999-99" )})
		Else
            If FieldName(i)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek( Padr( "CTR110" , Len( X1_GRUPO ) , ' ' ) + "01" )

	While ! Eof() .And. SX1->X1_GRUPO == Padr( "CTR110" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	dbSelectArea( "CVB" )
	CVB->(dbSeek( xFilial( "CVB" ) ))
	For i:=1 to FCount()
		If FieldName(i)=="CVB_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		ElseIf FieldName(i)=="CVB_CPF"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 999.999.999-99")})
		Else
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
	AADD(aVariaveis,{"M_MES",MesExtenso()})
	AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})

	If lPECTR110
		aVariaveis := 	ExecBlock("CTR110VAR",.F.,.F.,{aVariaveis,nPagIni,nPagFim,nReinicia})
	EndIf

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
	Endif

	If cArqEncer#NIL
		ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
	Endif	 
Endif
         
If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End
MS_FLUSH()        

cFilAnt := cFIlOld
RestArea(aAreaSM0)	
RestArea(aArea)   

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCompl  ºAutor  ³Totvs		         º Data ³  22/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 */
Static Function ImpCompl(dData, cLote, cSubLote, cDoc, cSeqLan, cEmpOri, cFilOri, cSeqHist, cMoeda)

Local aArea    	:= GetArea()
Local cHist 	:= ""
Local cFilCT2   := CT2->(xFilial("CT2"))
Local lProcHist := .T.
Local lseqLan 	:= .T.
Local nRecCT2   := CT2->(Recno())  

If Select("CT2HIST") == 0
	ChkFile("CT2",.F.,"CT2HIST")
EndIf
	
dbSelectArea("CT2HIST")
dbSetOrder(10)
lProcHist := CT2HIST->(dbSeek(cFilCT2+DTOS(dData)+cLote+cSubLote+cDoc+cSeqLan+cEmpOri+cFilOri+"01"+cSeqHist))
lseqLan   := CT2HIST->CT2_SEQLAN == cSeqLan    

If lProcHist

	cHist := Alltrim(CT2HIST->CT2_HIST)
	
	CT2HIST->(dbSkip())
   
	//Preenche o complemento do historico
	While !CT2HIST->(Eof()) .And.;
		CT2HIST->CT2_FILIAL == cFilCT2 .And.;
		CT2HIST->CT2_LOTE == cLote .And.;
		CT2HIST->CT2_SBLOTE == cSubLote .And.;
		CT2HIST->CT2_DOC == cDoc .And.;
		CT2HIST->CT2_EMPORI == cEmpOri .And.;
		CT2HIST->CT2_FILORI == cFilOri .And.;
		DTOS(CT2HIST->CT2_DATA) == DTOS(dData) .And. lseqLan
		
		If CT2HIST->CT2_MOEDLC <> '01'.And. (CT2HIST->CT2_DC <> "4" ) 
			CT2HIST->(dbSkip())                     
			Loop
		EndIf 

		If (cSeqHist <> CT2HIST->CT2_SEQHIS) .And. (CT2HIST->CT2_DC == "4" )

			cHist := cHist + ' ' + Alltrim(CT2HIST->CT2_HIST)
			CT2HIST->(dbSkip())
		Else 
			Exit
		EndIf

	EndDo

Else
	CT2HIST->(dbSeek(cFilCT2+DTOS(dData)+cLote+cSubLote+cDoc+cSeqLan+cEmpOri+cFilOri+cMoeda+cSeqHist))
	cHist := Alltrim(CT2HIST->CT2_HIST)

EndIf   

CT2HIST->(DbCloseArea())

dbSelectArea("CT2")
CT2->(dbGoto(nRecCT2))

RestArea( aArea )
Return cHist

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  NewImpCompl  ºAutor  ³Totvs		        º Data ³  22/09/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a impressao do complemento do historico dos lanca-  º±±
±±º          ³mentos                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 */ 
Static Function NewImpCompl(cFilSeek, dData, cLote, cSubLote, cDoc, cSeqLan, cEmpOri,; 
							cFilOri, cSeqHist, cMoeda, nLinReport)

Local cOrderBy	:= ""
Local cHistorico:= ""	

Local nI		:= 0

Local aSeek		:= {}
Local aResult	:= {{"CT2_HIST"}}

Local oSection2
Local aAreaCT2	:= CT2->(GetArea())
Default cFilSeek	:= XFilial("CT2")

//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQHIS
aAdd(aSeek,{"CT2_FILIAL",cFilSeek})
aAdd(aSeek,{"CT2_DATA",dData})
aAdd(aSeek,{"CT2_LOTE",cLote})
aAdd(aSeek,{"CT2_SBLOTE",cSubLote})
aAdd(aSeek,{"CT2_DOC",cDoc})
aAdd(aSeek,{"CT2_SEQLAN",cSeqLan})
aAdd(aSeek,{"CT2_EMPORI",cEmpOri})
aAdd(aSeek,{"CT2_FILORI",cFilOri})
aAdd(aSeek,{"CT2_MOEDLC",cMoeda})
aAdd(aSeek,{"CT2_DC","4"})

aEval(aSeek,{|x| cOrderBy += x[1] + "," })

cOrderBy := SubStr(cOrderBy,1,Len(cOrderBy)-1)

ATFSeekTable("CT2",aSeek,aResult,.T.,cOrderBy,.T.)

If ( Len(aResult) > 1 )

	oSection2 := oReport:Section(2)

	For nI := 1 to Len(oSection2:aCell)
				
		If (Alltrim(oSection2:aCell[nI]:cName) <> "CT2_HIST")
			oSection2:Cell(oSection2:aCell[nI]:cName):Hide()
		EndIf

	Next nI

	For nI := 2 to Len(aResult)
		
		cHistorico := aResult[nI,1]
		oSection2:Cell("CT2_HIST"):SetBlock({|| Alltrim(cHistorico) })
		oSection2:PrintLine()
		
		nLinReport++

	Next nI
		
	For nI := 1 to Len(oSection2:aCell)
			
		If (Alltrim(oSection2:aCell[nI]:cName) <> "CT2_HIST")
			oSection2:Cell(oSection2:aCell[nI]:cName):Show()
		EndIf

	Next nI

	oSection2:Cell("CT2_HIST"):SetBlock({|| Alltrim(CT2->CT2_HIST) })

EndIf	
RestArea(aAreaCT2)	
Return()