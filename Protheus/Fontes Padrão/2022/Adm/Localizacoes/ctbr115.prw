#INCLUDE "ctbr115.ch"
#Include "PROTHEUS.Ch"

// 17/08/2009 -- Filial com mais de 2 caracteres
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBR115  ³ Autor ³Marcello Gabriel            ³ Data ³ 24/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Livro Diario geral ordenado por lancamento.                     ³±±
±±           ³ Localizacao.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RDMAKE PADRAO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ATUAIZACOES SOFRIDAS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³           Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³GSANTACRUZ  ³12/06/17³ TSSERMI01³Se elimina la imprecion para R3 y variables³±±
±±³            ³        ³ -84      ³en des-uso                                 ³±±
±±³            ³        ³          ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CTBR115()

Private CPERG	   	:= "CTR115" 
Private aSelFil   := {} 

Private titulo		:= "" //Usada en la funcion CtCGCCabTR

 
aSelFil := AdmGetFil(,,,,.F.) 
CTBR115R4()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	   ³ CTBR115R4 ³ Autor³ Daniel Sakavicius	 	³ Data ³ 14/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Livro Diario geral ordenado por lancamento - R4            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ CTBR115R4									             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	  ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR115R4()                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()      

IF Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	

	oReport :PrintDialog()      
Endif

oReport := nil

Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius     ³ Data ³ 14/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                  		  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()  

   
Local CREPORT		:= "CTBR115"
Local CTITULO		:= OemToAnsi(STR0002)		// Emissao do Diario Geral
Local CDESC		:= OemToAnsi(STR0001)		//"Este programa irá imprimir o Livro Diário, ordenado por lancamento contabil."

Local aTamData	:= TAMSX3("CT2_DATA")    
Local aTamDoc		:= TAMSX3("CT2_DOC")
Local aTamLinha	:= TAMSX3("CT2_LINHA")
Local aTamConta	:= TAMSX3("CT1_CONTA")    
Local aTamDesc	:= TAMSX3("CT1_DESC01")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamHist	:= TAMSX3("CT2_HIST")
Local aTamCD		:= TAMSX3("CT2_CCD")
Local aTamCC		:= TAMSX3("CT2_CCC")
Private dFecIni	:=ctod("  /  /  ")
Private dFecFin	:=ctod("  /  /  ")
Private nModo		:=0
Private cMoed 	:=""
Private nCC 		:=0

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
oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC ) 

oReport:SetTotalInLine(.F.)
oReport:SetLandscape() 

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
oSection1  := TRSection():New( oReport, STR0022, {"CT2"},, .F., .F. )    //"Lançamentos"

TRCell():New( oSection1, "CT2_DATA"	,"CT2" ,/*Titulo*/,/*Picture*/,aTamData[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CT2_LOTE"	,	    ,STR0028/*Titulo*/,/*Picture*/,6/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)			//"Lote"
TRCell():New( oSection1, "CT2_SBLOTE"	,	    ,STR0029/*Titulo*/,/*Picture*/,3/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)			//"SubLote"
TRCell():New( oSection1, "CT2_DOC"		,"CT2" ,/*Titulo*/,/*Picture*/,aTamDoc[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CT2_LINHA"	,"CT2" ,STR0023/*Titulo*/,/*Picture*/,aTamLinha[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Seq"
TRCell():New( oSection1, "CCONTADD"	,	    ,STR0024/*Titulo*/,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Conta Debito"
TRCell():New( oSection1, "CDESCDD"		,	    ,STR0021+" "+STR0007/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Descrição Debito"
TRCell():New( oSection1, "CCONTADC"	,	    ,STR0025/*Titulo*/,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Conta Credito"
TRCell():New( oSection1, "CDESCDC"		,	    ,STR0021+" "+STR0008/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Descrição Credito"
TRCell():New( oSection1, "CVALDEB"		, 	    ,STR0007/*Titulo*/,"@E 999,999,999.99"/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CVALCRED"	,	    ,STR0008/*Titulo*/,"@E 999,999,999.99"/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CT2_HIST"	,"CT2" ,/*Titulo*/,/*Picture*/,aTamHist[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CCD"			,	    ,STR0026/*Titulo*/,/*Picture*/,aTamCD[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"C Custo Déb."
TRCell():New( oSection1, "CDESCCD"		,	    ,STR0021/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Descricao C Custo Déb."
TRCell():New( oSection1, "CCC"			,	    ,STR0027/*Titulo*/,/*Picture*/,aTamCC[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"C Custo Cred."
TRCell():New( oSection1, "CDESCCC"		,	    ,STR0021/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)		//"Descricao C Custo Cred."

oSection1:Cell("CCD"   ) :Disable()
oSection1:Cell("CDESCCD"):Disable()
oSection1:Cell("CCC"   ) :Disable()
oSection1:Cell("CDESCCC"):Disable()

oSection1:SetTotalInLine(.F.)                                         
oSection1:SetLineBreak()

oReport:SetUseGC(.f.)
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius	³ Data ³ 14/08/06 ³±±
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
Static Function ReportPrint( oReport )  

Local oSection1 	:= oReport:Section(1)       
Local lResetPag		:= .T.		// Limpa o controle de numeração 
Local m_pag			:= 1    	// controle de numeração de pagina       
Local i			:= 0     
Local lImpLivro	:= .F.
Local lImpTermos	:= .F.
Local cChave		:= ''
Local cFilter		:= ''

Pergunte(cPerg,.f.)
dFecIni	:=MV_PAR01
dFecFin	:=MV_PAR02
cMoed 		:=MV_PAR03
nModo		:=MV_PAR09
nCC			:=MV_PAR11

cTipoSal := MV_PAR05

IF cPaisLoc $ "ARG"
    
	lImpLivro	:= (nModo==1 .or. nModo==2) //Imprimir?  1-Livro  2-Termos  3-Livro e Termos
	lImpTermos	:= (nModo==2 .or. nModo==3)
Endif

aCtbMoeda := CtbMoeda( cMoed )
If Empty( aCtbMoeda[1] )
	Help( " " , 1 , "NOMOEDA" )
	Return
Endif

Titulo := STR0005 //"Livro Diario Geral "
Titulo += If(Empty(dFecIni),"",STR0018+Dtoc(dFecIni)) //" de "
Titulo += If(Empty(dFecFin),"",STR0019+Dtoc(dFecFin)) //" a "
Titulo += " ("+STR0006+Alltrim(aCtbMoeda[2])+")" //"lancamentos em " 

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,MV_PAR02,titulo,,,,,oReport,.T.,@lResetPag,mv_par06,mv_par07,mv_par08,@m_pag)})

For i:=1 to LEN(aSelFil)
	cFilter+="CT2->CT2_FILIAL =='" + xFilial("CT2",aSelFil[i])	+"' .or. "
Next
If len(aSelFil) >0
	cFilter:="("+ left(cFilter,len(cFilter)-5)+") .and. " 
Endif
 
cFilter += "(DTOS(CT2->CT2_DATA) >=  '" + DTOS(dFecIni) + "' .and. "
cFilter += "DTOS(CT2->CT2_DATA) <=  '" + DTOS(dFecFin) + "' .and. "
cFilter += "CT2->CT2_MOEDLC  =  '" + cMoed + "'  "
If cPaisLoc $ "CHI|BOL|PAR|ARG|URU"
	If !(cTipoSal $ '*| ')
		cFilter += ".and. CT2->CT2_TPSALD = '" + cTipoSal +"' "
	EndIf
EndIf
cFilter += ") "
oSection1:SetFilter( cFilter )       
oSection1:Cell("CT2_LOTE"):SetBlock( { || CT2_LOTE } )  
oSection1:Cell("CT2_SBLOTE"):SetBlock( { || CT2_SBLOTE } )	   

oSection1:Cell("CCONTADD"):SetBlock( { || MascaraCTB(CT2_DEBITO ) } )  
oSection1:Cell("CCONTADC"):SetBlock( { || MascaraCTB(CT2_CREDITO) } )		

oSection1:Cell("CDESCDD" ):SetBlock( { || CT1->(MsSeek(xFilial("CT1")+CT2->CT2_DEBITO)),;
														 CT1->CT1_DESC01 } )

oSection1:Cell("CDESCDC" ):SetBlock( { || CT1->(MsSeek(xFilial("CT1")+CT2->CT2_CREDITO)),;
														 CT1->CT1_DESC01 } )

oSection1:Cell("CVALDEB" ):SetBlock( { || Iif(CT2_DC=="1",CT2_VALOR,Iif(CT2_DC=="3",CT2_VALOR,0)) } )		
oSection1:Cell("CVALCRED"):SetBlock( { || Iif(CT2_DC=="2",CT2_VALOR,Iif(CT2_DC=="3",CT2_VALOR,0)) } )	   

If Valtype( nCC ) == 'N'  .And. nCC == 1		//Imprime Centro de Custo?

	oSection1:Cell("CCD"   ) :Enable()
	oSection1:Cell("CDESCCD"):Enable()
	oSection1:Cell("CCC"   ) :Enable()
	oSection1:Cell("CDESCCC"):Enable()
	
	TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT")+Iif(CT2->CT2_DC=="1",CT2->CT2_CCD,CT2->CT2_CCC) })
	oSection1:Cell("CCD"   ) :SetBlock( { || CT2->CT2_CCD } )
	oSection1:Cell("CDESCCD"):SetBlock( { || CTT->(MsSeek(xFilial("CTT")+CT2->CT2_CCD)),CTT->CTT_DESC01 } )		
	oSection1:Cell("CCC"   ) :SetBlock( { || CT2->CT2_CCC } )		
	oSection1:Cell("CDESCCC"):SetBlock( { || CTT->(MsSeek(xFilial("CTT")+CT2->CT2_CCC)),CTT->CTT_DESC01 } )			                                              
EndIf

oBreak1 := TRBreak():New( oSection1, { || CT2->(DTOS(CT2_DATA)+CT2_DOC)}, STR0011 )			//"Total lancamento ==>"	
oBreak2 := TRBreak():New( oSection1, { || CT2->CT2_DATA }, STR0012 )	 							//"Total dia "
oBreak3 := TRBreak():New( oSection1, { || Substr(CT2->(DTOS(CT2_DATA)),5,2) }, STR0013 )	//"Total do mes "	

oReport:SetTotalText(STR0015)		//"Total geral ==>"
	           
oFunc1 := TRFunction():New( oSection1:Cell("CVALDEB" ), , "SUM", oBreak1, , , , .F.,.F. )
oFunc2 := TRFunction():New( oSection1:Cell("CVALCRED"), , "SUM", oBreak1, , , , .F.,.F. )
oFunc1 := TRFunction():New( oSection1:Cell("CVALDEB" ), , "SUM", oBreak2, , , , .F.,.F. )
oFunc2 := TRFunction():New( oSection1:Cell("CVALCRED"), , "SUM", oBreak2, , , , .F.,.F. )
oFunc1 := TRFunction():New( oSection1:Cell("CVALDEB" ), , "SUM", oBreak3, , , , .F.,.T. )
oFunc2 := TRFunction():New( oSection1:Cell("CVALCRED"), , "SUM", oBreak3, , , , .F.,.T. )

oSection1:Print()

If lImpTermos   //impressao dos termos de abertura e encerramento
	cArqAbert := GetMv( "MV_LDIARAB" )
	cArqEncer := GetMv( "MV_LDIAREN" )

	dbSelectArea("SM0")
	aVariaveis:={}

	For i:=1 to FCount()	
		If FieldName(i) == "M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		Else
            If FieldName(i) == "M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	dbSelectArea( "SX1" )

    cChave := Padr( cPerg , Len( x1_grupo ) , ' ' )

	dbSeek( cChave + "01" )
	While ( SX1->X1_GRUPO == cChave ) .And. ! SX1->( Eof() )
		AADD( aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})

		SX1->( dbSkip() )
	EndDo

	If ! File( cArqAbert )
		aSavSet   := __SetSets()
		cArqAbert := CFGX024(,STR0016) // Editor de Termos de Livros //"Diario Geral."
		__SetSets( aSavSet )

		Set(24,Set(24),.t.)
	Endif

	If ! File( cArqEncer )
		aSavSet	  := __SetSets()
		cArqEncer := CFGX024(,STR0016) // Editor de Termos de Livros //"Diario Geral."
		__SetSets( aSavSet )

		Set(24,Set(24),.t.)
	Endif

	If cArqAbert # NIL
		oReport:EndPage()

		ImpTerm2(cArqAbert,aVariaveis,,,,oReport)				
	Endif

	If cArqEncer # NIL
		oReport:EndPage()

		ImpTerm2(cArqEncer,aVariaveis,,,,oReport)				
	Endif	 
Endif
                                                         
Return

