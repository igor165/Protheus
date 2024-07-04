#Include "CTBR112.Ch"
#Include "PROTHEUS.Ch"

// 17/08/2009 -- Filial com mais de 2 caracteres
Static lImpSX1 := .T.

Static lIsRedStor := FindFunction("IsRedStor") .and. IsRedStor() //Used to check if the Red Storn Concept used in russia is active in the system | Usada para verificar se o Conceito Red Storn utilizado na Russia esta ativo no sistema | Se usa para verificar si el concepto de Red Storn utilizado en Rusia esta activo en el sistema

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR112  � Autor � Pilar S. Albaladejo   � Data � 09.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Diario Geral por Documento Fiscal                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR112(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR112()

Private NVALTD		:= 0
Private NVALTC		:= 0
Private NVALTDANT := NVALTD 
Private NVALTCANT := NVALTC		

Private titulo		:= ""
Private nomeprog	:= "CTBR112"
Private NMESDEB 	:= 0
Private NMESCRED  	:= 0

CTBR112R4()


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR112R4 � Autor� Daniel Sakavicius		� Data � 11/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Diario Geral por Documento Fiscal - R4                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR112R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR112R4()                                                       
PRIVATE oReport

lImpSX1 := ( GetMv("MV_IMPSX1") == "S" )

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01  	      	// Data Inicial                          �
//� mv_par02            // Data Final                            �
//� mv_par03            // Moeda?                                �
//� mv_par04			// Set Of Books			    		     �
//� mv_par05			// Tipo Lcto? Real / Orcad / Gerenc / Pre�
//� mv_par06  	      	// Pagina Inicial                        �
//� mv_par07         	// Pagina Final                          �
//� mv_par08         	// Pagina ao Reiniciar                   �
//� mv_par09         	// So Livro/Livro e Termos/So Termos     �
//� mv_par10         	// Imprime Balancete                     �
//� mv_par11         	// Imprime Plano de contas               � 
//� mv_par12         	// Imprime Valor 0.00	                 �
//� mv_par13         	// Impr Cod(Normal/Reduz/Cod.Impressao)  � /// CT1_CODIMP
//� mv_par14            // Num.linhas p/ o diario?				 � 
//����������������������������������������������������������������
oReport := ReportDef()      

//Variaveis utilizadas para o controle de numeracao da pagina - funcao CtCGCCabTR
Private nPagIni		:= mv_par06 // parametro da pagina inicial
Private nPagFim		:= mv_par07	// parametro da pagina final
Private nReinicia	:= mv_par08	// parametro de reinicio de pagina
Private l1StQb		:= .T.		// primeira quebra
Private lNewVars	:= .T.		// inicializa as variaveis
Private m_pag		:= 1    	// controle de numera��o de pagina
Private nBloco      := 1		// controle do bloco a ser impresso
Private nBlCount	:= 0		// contador do bloco impresso

Public lPrintZero	:= Iif(mv_par12 == 1,.T.,.F.)

IF Valtype( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	

	oReport:PrintDialog()      
Endif

oReport := Nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 11/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()  

Local aArea	   		:= GetArea()   
Local CREPORT		:= "CTBR112"
Local CTITULO		:= OemToAnsi(STR0006)			//"Emissao Diario Geral por Documento Fiscal "
Local CDESC			:= OemToAnsi(STR0001)+;			//"Este programa ira imprimir o Diario Geral por Documento Fiscal,"
					   OemToAnsi(STR0002)     		//"de acordo com os parametros sugeridos pelo usuario."
Local cTransp		:= ""
Local cDeTramD		:= ""
Local cDeTramC		:= ""
Local cPerg		   	:= "CTR112"			  
Local CLANCTO		:= ""
Local CVALDEB		:= ""
Local CVALCRED		:= ""
Local cMsgT			:= ""
Local cMoeda		:= ""
Local aCtbMoeda		:= {}
Local lRet		 	:= .T.  
Local cSeparador    := ""

Public cMascara		:= ""
Public cDescMoeda 	:= ""
Public cPicture		:= ""
Public nDecimais	:= 0
Public aTamConta	:= TAMSX3("CT1_CONTA")    
Public aTamVal		:= TAMSX3("CT2_VALOR")
Public aTamHist		:= TAMSX3("CT2_HIST")

Pergunte( 'CTR112' , .T. )

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)		     �
//����������������������������������������������������������������
// faz a valida��o do livro
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

cMoeda		:= mv_par03
cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf

cPicture 	:= aSetOfBook[4]

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport, cPicture, nDecimais, cMascara, cSeparador, cDescMoeda ) }, CDESC ) 

oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)
oReport:SetPortrait(.T.)

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1  := TRSection():New( oReport, STR0021, {"CT2"},, .F., .F. )    //"Lan�amentos Cont�beis"

TRCell():New( oSection1, "CT2_DATA"		,"CT2" ,/*Titulo*/,/*Picture*/,aTamConta[1]	,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CT2_DEBITO"	,"CT2" ,/*Titulo*/,/*Picture*/,aTamConta[1]	,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CT2_CREDIT"	,"CT2" ,/*Titulo*/,/*Picture*/,aTamConta[1]	,/*lPixel*/,/*CodeBlock*/)

//*********************************************
// Tratamento para Impress�o do Correlativo   *
//*********************************************
If cPaisLoc $ "CHI|ARG"
	// Ativa a Quebra de linha do historico caso utilize correlativo
	TRCell():New( oSection1, "CT2_HIST"		,"CT2" ,/*Titulo*/,/*Picture*/,aTamHist[1] 	,/*lPixel*/,/*CodeBlock*/,,.T.)
	TRCell():New( oSection1, "CLANCTO"		,	   ,STR0018   ,/*Picture*/,25			,/*lPixel*/,/*CodeBlock*/)		//"Numero Lancto"
Else
	TRCell():New( oSection1, "CT2_HIST"		,"CT2" ,/*Titulo*/,/*Picture*/,aTamHist[1] 	,/*lPixel*/,/*CodeBlock*/)
	TRCell():New( oSection1, "CLANCTO"		,	   ,STR0018   ,/*Picture*/,20			,/*lPixel*/,/*CodeBlock*/)		//"Numero Lancto"
EndIf

TRCell():New( oSection1, "CVALDEB"		, 	   ,STR0019   ,/*Picture*/,aTamVal[1]	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Debito"
TRCell():New( oSection1, "CVALCRED"		,	   ,STR0020	  ,/*Picture*/,aTamVal[1]	,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")		//"Vlr.Credito"

oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderPage(.T.)		//Define o cabecalho da secao como padrao                                       

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius    � Data � 11/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport, cPicture, nDecimais, cMascara, cSeparador, cDescMoeda )  

Local oSection1 	:= oReport:Section(1)
Local oFunc1
Local oFunc2
Local nIndexC 		:= 0
Local cTipoAnt   	:= ""
Local lPula			:= Iif(mv_par10==1,.T.,.F.) 
Local lImpLivro		:=.t.                         
Local lImpTermos	:=.f.
Local cMSGT			:= SubStr(STR0014,3,25)
Local i				:= 0
Local nLinReport    := 1 //10
Local nMaxLin		:= mv_par14
Local lSalLin := Iif(MV_PAR15==1,.T.,.F.)

//Variaveis utilizadas para o controle de numeracao da pagina - funcao CtCGCCabTR
Local lResetPag		:= .T.		// Limpa o controle de numera��o
Local m_pag			:= 1    	// controle de numera��o de pagina
Local nBloco    	:= 1		// controle do bloco a ser impresso
Local nBlCount		:= 0		// contador do bloco impresso

If mv_par14 > If(oReport:GetOrientation()== 1/*PORTRAIT*/,90,65)
	Alert(STR0022+Alltrim(Str(If(oReport:GetOrientation()== 1/*PORTRAIT*/,90,65)))+STR0023)  //"Para esta vers�o do relatorio o n�mero de linhas n�o pode ser maior que "##" linhas"
	oReport:CancelPrint()
	Return
Endif

aSetOfBook := CTBSetOf(mv_par04)

// mascara do valor
cPicture   :=  aSetOfBook[4]
If Empty( cPicture ) .Or. cPicture == Nil
	cPicture := "@E " + TmContab(CT2->CT2_VALOR,aTamVal[1],nDecimais)
Endif

//��������������������������������������������������������������Ŀ
//| titulo do relatorio                                          |
//����������������������������������������������������������������
titulo		:= 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) +;
				DTOC(mv_par02) + OemToAnsi(STR0011) + cDescMoeda + CtbTitSaldo(mv_par05)  

//��������������������������������������������������������������Ŀ
//| cabe�alho do relatorio                                       |
//����������������������������������������������������������������
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,mv_par02,titulo,,,,,oReport,.T.,@lResetPag,mv_par06,mv_par07,mv_par08,@m_pag,@nBloco,@nBlCount) } )				

//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par09 == 1 ; lImpLivro := .T. ; lImpTermos := .F.
	Case mv_par09 == 2 ; lImpLivro := .T. ; lImpTermos := .T.
	Case mv_par09 == 3 ; lImpLivro := .F. ; lImpTermos := .T.      
EndCase		                                                  
                                
//��������������������������������������������������������������Ŀ
//� Filtros do relatorio                                         �
//����������������������������������������������������������������
cFilter := "CT2->CT2_FILIAL =  '" + xFilial("CT2") +"' .and. "
cFilter += "DTOS(CT2->CT2_DATA) >=  '"+DTOS(mv_par01)+"' .and. "
cFilter += "DTOS(CT2->CT2_DATA) <=  '"+DTOS(mv_par02)+"' .and. "
cFilter += "CT2->CT2_MOEDLC  =  '"+mv_par03+"' .and. "
cFilter += "CT2->CT2_TPSALD  =  '"+mv_par05+"'  "

oSection1:SetFilter( cFilter )                                                             
                                                                                            
oSection1:Cell("CT2_DEBITO" ):SetBlock( { || ImpEntCont(cMascara,cSeparador,.T.) } )
oSection1:Cell("CT2_CREDIT"):SetBlock( { || ImpEntCont(cMascara,cSeparador,.F.) } )

//*********************************************
// Tratamento para Impress�o do Correlativo   *
//*********************************************
If cPaisLoc $ "CHI|ARG"
	oSection1:Cell("CLANCTO"):SetBlock( { || (CT2->CT2_LOTE+CT2->CT2_SBLOTE+" "+CT2->CT2_SEGOFI+CT2->CT2_LINHA) })	
Else
	oSection1:Cell("CLANCTO"):SetBlock( { || (CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA) })
EndIf


oSection1:Cell("CVALDEB" ):SetBlock( { || ValorCTB( Iif( CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3" , CT2->CT2_VALOR , 0 ) ,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.)})
oSection1:Cell("CVALCRED"):SetBlock( { || ValorCTB( Iif( CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3" , CT2->CT2_VALOR , 0 ) ,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.)})

//��������������������������������������������������������������Ŀ
//� Impress�o do DE TRANSPORTE                                   �
//����������������������������������������������������������������
oReport:OnPageBreak( {|| InicPagina(oSection1,aTamVal,nDecimais,cPicture,@nLinReport) } ) 

//total do dia
oBreak1 := TRBreak():New( oSection1, { || DTOS(CT2->CT2_DATA)}, STR0015 )									//"Totais deste dia =======>"

oBreak1:OnBreak( {||nLinReport += 3,;
					iif(lSalLin .And. oSection1:Printing(),(oReport:Skipline(),nLinReport++),),;
					InicValor() })

oFunc1 := TRFunction():New( oSection1:Cell("CVALDEB" ), ,"SUM", oBreak1,/*Titulo*/,cPicture,;
									{ || Iif(CT2->CT2_DC=="1" .Or. CT2->CT2_DC=="3",;
									CT2->CT2_VALOR, 0	) },.F.,.F.,.F.,oSection1)

oFunc2 := TRFunction():New( oSection1:Cell("CVALCRED"), ,"SUM", oBreak1,/*Titulo*/,cPicture,;
									{ || Iif(CT2->CT2_DC=="2" .Or. CT2->CT2_DC=="3",;
									CT2->CT2_VALOR, 0	) },.F.,.F.,.F.,oSection1)

//total do mes
oBreak2 := TRBreak():New( oSection1, { || Substr(DToS(CT2->CT2_DATA),1,6)}, STR0016 )									//"Totais deste mes =======>"
oBreak2:OnBreak( {||nLinReport += 3,If(lSalLin .And. oSection1:Printing(),(oReport:Skipline(),nLinReport++),),InicValor() })

oFunc3 := TRFunction():New( oSection1:Cell("CVALDEB" ), ,"SUM", oBreak2,/*Titulo*/,cPicture,;
									{ || Iif(CT2->CT2_DC=="1" .Or. CT2->CT2_DC=="3",CT2->CT2_VALOR, 0)},.T.,.F.,.F.,oSection1)
 
oFunc4 := TRFunction():New( oSection1:Cell("CVALCRED"), ,"SUM", oBreak2,/*Titulo*/,cPicture,;
									{ || Iif(CT2->CT2_DC=="2" .Or. CT2->CT2_DC=="3",;
									CT2->CT2_VALOR, 0	) },.T.,.F.,.F.,oSection1)


oSection1:SetTotalText(STR0017)		//"Total Geral ============>"

//��������������������������������������������������������������Ŀ
//� Controle de linhas impressas no relatorio                    �
//����������������������������������������������������������������
oSection1:OnPrintLine( {|| CTR112Maxl( nMaxLin, @nLinReport, cPicture, .T. ) } )
oSection1:Print()

oReport:EndReport()

//��������������������������������������������������������������Ŀ
//� Impress�o do Balancete Modelo 1                              �
//����������������������������������������������������������������
If mv_par10 == 1
	Ctbr040R4()

	Pergunte( "CTR112" , .F. )
EndIf

//��������������������������������������������������������������Ŀ
//� Impress�o do Plano de Contas                                 �
//����������������������������������������������������������������
If mv_par11 == 1
	Ctbr010R4( mv_par03 )
Endif

If lImpTermos 							// Impressao dos Termos
	Pergunte( "CTR112", .F. )
	
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
	dbSeek( padr( "CTR112" , Len( X1_GRUPO ) , ' ' ) + "01" )

	While ! Eof() .And. SX1->X1_GRUPO  == padr( "CTR112" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

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
Endif

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InicPagina�Autor  �Renato F. Campos    � Data �  07/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime no inicio de cada pagina "valor de transporte"      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB - Diario                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function InicPagina(oSection1,aTamVal,nDecimais,cPicture,nLinReport)
Local lColDbCr 		:= lIsRedStor // Disconsider cTipo in ValorCTB function, setting cTipo to empty
DEFAULT oSection1 := oReport:Section(1)

If oSection1:Printing()              
	If oReport:page() > If(lImpSX1, mv_par06+1, mv_par06)
	
		oReport:Skipline()
		oReport:PrintText(STR0014,oReport:NROW)		
		oReport:PrintText(ValorCTB(NVALTDANT,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,,.F.,lColDbCr),oReport:NROW,oSection1:Cell("CVALDEB" ):ColPos()-14)          		
		oReport:PrintText(ValorCTB(NVALTCANT,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,,.F.,lColDbCr),oReport:NROW,oSection1:Cell("CVALCRED" ):ColPos()-20)          		
		oReport:Skipline()
		oReport:Skipline()
		                    
        nLinReport := 1           
        NVALTDANT := NVALTCANT := 0
	EndIF
		
EndIf	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CTR112MaxL    �Autor � Renato F. Campos � Data � 01/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Faz a quebra de pagina de acordo com o parametro passado   ���
���          � no relatorio.                                              ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Numero maximo de linhas definido no relatorio      ���
���          � EXPL2 - Contador de linhas impressas no relatorio          ���
�������������������������������������������������������������������������͹��
���Retorno   � nil                                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Diario Geral                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTR112MaxL(nMaxLin,nLinReport, cPicture, lIncrVal )
Local oSection1 := oReport:Section(1)
Local nMaxLin1

Local lColDbCr 		:= lIsRedStor // Disconsider cTipo in ValorCTB function, setting cTipo to empty
nLinReport++
nMaxLin1 := nMaxLin

If ! Empty( NVALTD ) .Or. ! Empty( NVALTC )
	nMaxLin1 := nMaxLin1 - 1
Endif

If nLinReport > nMaxLin1 - 5
	IF oSection1:Printing()
		oReport:Skipline()
		oReport:PrintText(STR0013,oReport:NROW)
		oReport:PrintText(ValorCTB(NVALTD,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,,.F.,lColDbCr),oReport:NROW,oSection1:Cell("CVALDEB" ):ColPos()-14)          		
		oReport:PrintText(ValorCTB(NVALTC,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,,.F.,lColDbCr),oReport:NROW,oSection1:Cell("CVALCRED" ):ColPos()-20)          		
		oReport:Skipline()
		NVALTDANT := NVALTD 
		NVALTCANT := NVALTC		
		NVALTD := 0
		NVALTC := 0
	EndIf

	oReport:EndPage()

EndIf

If lIncrVal
	If CT2->CT2_DC=="1" .Or. CT2->CT2_DC=="3"
		NVALTD += CT2->CT2_VALOR
	EndIf
			
	If 	CT2->CT2_DC=="2" .Or. CT2->CT2_DC=="3"
		NVALTC += CT2->CT2_VALOR
	EndIf
EndIf

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InicValor �Autor  �Microsiga           � Data �  23/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa totalizador a transportar                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function InicValor()

If CT2->CT2_DC=="1" .Or. CT2->CT2_DC=="3"
	NVALTD := CT2->CT2_VALOR
EndIf
		
If 	CT2->CT2_DC=="2" .Or. CT2->CT2_DC=="3"
	NVALTC := CT2->CT2_VALOR
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ImpEntCont� Autor � Marcio Menon		    � Data � 16/10/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a impressao do c�digo da Entidade Contabil, conforme   ���
���          �a op��o do parametro mv_par13.							  ���
���          �						                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB         	                           				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
				cRet := EntidadeCTB(CT1->CT1_RES,0 ,00,20,.F.,cMascara,cSeparador,,,,,.F.)
			ElseIf mv_par13 == 3 			 	/// Impressao do Codigo de Impressao (se o campo existir)
				cRet := EntidadeCTB(CT1->CT1_CODIMP,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
			Else										/// Impressao do Codigo Normal
				cRet := EntidadeCTB(CT2->CT2_DEBITO,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
			Endif
		Else
			cRet := EntidadeCTB(CT2->CT2_DEBITO,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
		Endif
	Endif                              
Else                 
	If !Empty(CT2->CT2_CREDIT)
		dbSelectArea("CT1")
		dbSetOrder(1)
		If MsSeek(xFilial("CT1")+CT2->CT2_CREDIT,.F.)
			If mv_par13 == 2							/// Impressao do Codigo Reduzido
				cRet := EntidadeCTB(CT1->CT1_RES,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
			ElseIf mv_par13 == 3 						/// Impressao do Codigo de Impressao (se o campo existir)
				cRet := EntidadeCTB(CT1->CT1_CODIMP,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
			Else										/// Impressao do Codigo Normal
				cRet := EntidadeCTB(CT2->CT2_CREDIT,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
			Endif
		Else
			cRet := EntidadeCTB(CT2->CT2_CREDIT,0,0,20,.F.,cMascara,cSeparador,,,,,.F.)
		Endif
	Endif
EndIf	

Return cRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ctbr112Flt� Autor � Pilar S. Albaladejo   � Data � 13/06/03 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Realiza a "filtragem" dos registros do Diario Doc Fiscal    ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �Ctbr112Flt(oMeter,oText,oDlg,lEnd,cMoeda,dDataIni,dDataFim, ���
���           �           cSaldo)   	        							         ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � oMeter 		= Objeto oMeter                                 ���
���           � oText  		= Objeto oText                                  ���
���           � oDlg   		= Objeto oDlg                                   ���
���           � lEnd   		= Acao do Codeblock                             ���
���           � cMoeda 		= Moeda                                         ���
���           � dDataIni 	= Data Inicial                                  ���
���           � dDataFim 	= Data Final                                    ���
���           � cSaldo		= Tipo de Saldo                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ctbr112Flt(oMeter,oText,oDlg,lEnd,cMoeda,dDataIni,dDataFim,cSaldo)

oMeter:nTotal := CT2->(RecCount())

dbSelectArea("CT2")
dbSetOrder(1)
MsSeek(xFilial()+dtos(dDataIni),.T.)

While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And. ;
	CT2->CT2_DATA >= dDataIni .And. CT2->CT2_DATA <= dDataFim 

	IF CT2->CT2_VALOR == 0 .Or. CT2->CT2_TPSALD != cSaldo .Or. CT2->CT2_MOEDLC <> cMoeda
		dbSkip()
		Loop
	EndIF

	If CT2->CT2_DC == "1"
		Ctbr420Grv(cMoeda,cSaldo,"1","4")
	ElseIf CT2->CT2_DC == "2"
		Ctbr420Grv(cMoeda,cSaldo,"2","4")
	ElseIf CT2->CT2_DC == "3"     
		Ctbr420Grv(cMoeda,cSaldo,"3","4")
	EndIf
	
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSkip()
Enddo

Return      
