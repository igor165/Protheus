#Include "CTBR190.Ch"
#Include "PROTHEUS.Ch"

// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR190	� Autor � Gustavo Henrique  	� Data � 28.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Classe de Valor / Conta       			 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctbr190()    											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso    	 � Generico     											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR190()
PRIVATE titulo		:= "" 
Private nomeprog	:= "CTBR190"
PRIVATE aSelFil	:= {}
PRIVATE lTodasFil := .F.

CTBR190R4()

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR190R4 � Autor� Daniel Sakavicius		� Data � 01/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Classe de Valor / Conta - R4  					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR190R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR190R4() 
Local cPerg	   		:= "CTR190"			       
Local cArqTmp

Private cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Private cSayClVl		:= CtbSayApro("CTH")

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������

oReport := ReportDef( @cArqTmp )      

If !Empty( oReport:uParam )
	Pergunte( cPerg, .T. )
	    
	If Empty(mv_par10)                       
	   Help(" ",1,"NOMOEDA")
	   Return
	Endif	
	
	If (mv_par35 == 1) .and. ( Empty(mv_par36) .or. Empty(mv_par37) )
		cMensagem	:= STR0023	// "Favor preencher os parametros Grupos Receitas/Despesas e Data Sld Ant. Receitas/Despesas ou "
		cMensagem	+= STR0024	// "deixar o parametro Ignora Sl Ant.Rec/Des = Nao "
		MsgAlert(cMensagem,"Ignora Sl Ant.Rec/Des")	
    	Return
	EndIf
	
	If mv_par38 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil(@lTodasFil)
		If Len( aSelFil ) <= 0
			Return
		Endif
	EndIf 
EndIf	

oReport :PrintDialog()      

If Select("cArqTmp") > 0
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()

	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase("cArqInd"+OrdBagExt())
	EndIf
EndIf	

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 01/09/06 ���
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
Static Function ReportDef( cArqTmp )   
local aArea	   		:= GetArea()   
Local cReport		:= "CTBR190"
Local cTitulo		:= OemToAnsi(STR0003)+ Upper(cSayClVl)+" / "+Upper(OemToAnsi(STR0021)) 	//"Balancete de Verificacao  / Conta"
Local cDesc			:= OemToAnsi(STR0001)+ Upper(cSayClVl)+" / "+Upper(OemToAnsi(STR0021))	//"Este programa ira imprimir o Balancete de  /Conta"
Local cPerg	   		:= "CTR190"			       
Local aTamConta		:= TAMSX3("CT1_CONTA")    
Local aTamCLVL		:= TAMSX3("CTH_CLVL")    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= TAMSX3("CTH_DESC01")
Local nDecimais

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

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport, cTitulo, cPerg, { |oReport| ReportPrint( oReport, @cArqTmp ) }, cDesc ) 
oReport:ParamReadOnly()
oReport:SetLandscape()

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
oSection0  := TRSection():New( oReport, Capital(cSayClVl), {"cArqTmp", "CTH"},, .F., .F. )        
TRCell():New( oSection0, "CLVL"	 , 		,Capital(STR0025)/*Titulo*/	,/*Picture*/,aTamClvl[1]+5/*Tamanho*/,/*lPixel*/,{ || EntidadeCTB(cArqTmp->CLVL,,,20,.F.,cMascara2,cSepara2,,,,,.F.) }/*CodeBlock*/)  //"CODIGO"
TRCell():New( oSection0, "DESCCLVL" , 	,Capital(STR0026)/*Titulo*/	,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,{ || (cArqTMP->DESCCLVL) }/*CodeBlock*/)  //"DESCRICAO"
TRPosition():New( oSection0, "CTH", 1, {|| xFilial("CTH") + cArqTMP->CLVL })

oSection0:SetLineStyle()
oSection0:SetNoFilter({"cArqTmp", "CTH"})

oSection1  := TRSection():New( oSection0, Capital(STR0021), {"cArqTmp", "CT1"},, .F., .F. )

TRCell():New( oSection1, "CONTA"	 , ,Capital(STR0025)/*Titulo*/,/*Picture*/,aTamConta[1] + 21/*Tamanho*/,/*lPixel*/, {|| IIF(cArqTmp->TIPOCONTA=="2","  ","")+EntidadeCTB(cArqTmp->CONTA ,,,70,.F.,cMascara1,cSepara1,,,,,.F.) }/*CodeBlock*/)  //"CODIGO"
TRCell():New( oSection1, "DESCCTA"  , ,Capital(STR0026)/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/	, {|| cArqTmp->DESCCTA }/*CodeBlock*/)  //"DESCRICAO"
TRCell():New( oSection1, "SALDOANT" , ,Capital(STR0027)/*Titulo*/,/*Picture*/,aTamVal[1]+5/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")  //"SALDO ANTERIOR"
TRCell():New( oSection1, "SALDODEB" , ,Capital(STR0028)/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")  //"DEBITO"
TRCell():New( oSection1, "SALDOCRD" , ,Capital(STR0029)/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER")   //"CREDITO"
TRCell():New( oSection1, "MOVIMENTO", ,Capital(STR0030)/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER") //"MOVIMENTO DO PERIODO"
TRCell():New( oSection1, "SALDOATU" , ,Capital(STR0031)/*Titulo*/,/*Picture*/,aTamVal[1]+5/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER") //"SALDO ATUAL"
TRPosition():New( oSection1, "CT1", 1, {|| xFilial("CT1") + cArqTMP->CONTA})

oSection1:SetTotalInLine(.F.)          
oSection1:SetNoFilter({"cArqTmp"})
oSection1:SetLinesBefore(0)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 01/09/06 ���
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
Static Function ReportPrint( oReport, cArqTmp )  
Local oSection0 	:= oReport:Section(1)    
Local oSection1 	:= oReport:Section(1):Section(1)

Local aSetOfBook
Local aCtbMoeda	:= {}
Local cDescMoeda

Local cPicture

Local cClVlAnt 		:= ""
Local cSegAte   	:= mv_par14
Local cSegClAte   	:= mv_par29

Local dDataLP		:= mv_par28
Local dDataFim		:= mv_par02

Local lFirstPage	:= .T.
Local lPula			:= .F.
Local l132			:= .F.
Local lImpAntLP		:= Iif(mv_par27 == 1,.T.,.F.)
Local lJaPulou		:= .F.
Local lPrintZero	:= Iif(mv_par23==1,.T.,.F.)
Local lPulaSint		:= Iif(mv_par22==1,.T.,.F.) 
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.)

Local nDecimais
Local nDivide		:= 0

Local nDigitAte	:= 0
Local nDigClAte	:= 0
Local lRecDesp0		:= Iif(mv_par35==1,.T.,.F.)
Local cRecDesp		:= mv_par36
Local dDtZeraRD		:= mv_par37    
Local cFilter		:= ""
Local oBreak, oBreak1, oFuncDeb, oFuncCred, oFuncMov, oTotDeb, oTotCred, oTotMov
Local oFuncPerDeb, oFuncPerCred, oFuncPerMov, oTotPerDeb, oTotPerCred, oTotPerMov
Local lCtiSint      := ( mv_par34 == 1 .OR. mv_par34 == 3 ) 

Local cTipoAnt  	:= ""

Local aTamVal		:= TAMSX3("CT2_VALOR")

Local lColDbCr 		:= IIf(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local lRedStorn		:= IIf(cPaisLoc $ "RUS",SuperGetMV("MV_REDSTOR",.F.,.F.),.F.) // Parameter to activate Red Storn

Private cMascara1	:= ""
Private cMascara2	:= ""
Private	cSepara1	:= ""
Private cSepara2	:= ""


//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			 �
//����������������������������������������������������������������
If !ct040Valid(mv_par08)
	lRet := .F.
Else
   aSetOfBook := CTBSetOf(mv_par08)
Endif

aCtbMoeda  	:= CtbMoeda(mv_par10,nDivide)

cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)

If mv_par25 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par25 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par25 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	

//Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1 	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf

// Mascara da Classe de Valor
If Empty(aSetOfBook[8])
	cMascara2 := ""
Else
	cMascara2 := RetMasCtb(aSetOfBook[8],@cSepara2)
EndIf

cPicture 		:= aSetOfBook[4]

If !ct040Valid(mv_par08)
	Return
Else
   aSetOfBook := CTBSetOf(mv_par08)
Endif

If mv_par25 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par25 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par25 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	
             
//��������������������������������������������������������������Ŀ
//� Carrega titulo do relatorio: Analitico / Sintetico			 �
//����������������������������������������������������������������

If mv_par07 == 1 //sintetica
	Titulo:=	OemToAnsi(STR0007) + Upper(cSayClVl)+ " / "+Upper(OemToAnsi(STR0021))		//"BALANCETE SINTETICO DE  /CONTA"
ElseIf mv_par07 == 2 //analitica
	Titulo:=	OemToAnsi(STR0006) + Upper(cSayClVl)+ " / "+Upper(OemToAnsi(STR0021)) 	//"BALANCETE ANALITICO DE  /CONTA"
ElseIf mv_par07 == 3 //ambas
	Titulo:=	OemToAnsi(STR0008) + Upper(cSayClVl)+ " / "+Upper(OemToAnsi(STR0021))		//"BALANCETE DE / CONTA"
EndIf

Titulo += 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) + Dtoc(mv_par02) + ;
				OemToAnsi(STR0011) + cDescMoeda

If mv_par12 > "1"
	Titulo += " (" + Tabela("SL", mv_par12, .F.) + ")"
EndIf

If nDivide > 1			
	Titulo += " (" + OemToAnsi(STR0022) + Alltrim(Str(nDivide)) + ")"
EndIf	

oReport:SetPageNumber( mv_par11 ) // numera��o da pagina
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport) } )

oSection0:SetLineCondition( {|| ( cClVlAnt := cArqTmp->CLVL, .T.) } )
oSection1:SetTotalText({||Capital(STR0020)+" "+Capital(Alltrim(cSayClVl))+ " : "+cClVlAnt}) //Total 

oReport:SetTotalText(Capital(STR0018)) 
oReport:SetTotalInLine(.F.)          

If mv_par26 == 2 
	oSection1:Cell("CONTA"):SetBlock( { || IIF(cArqTmp->TIPOCONTA=="2","  ","")+EntidadeCTB(cArqTmp->CTARES,,,70,.F.,cMascara1,,,,,,.F.) } )		
Else
	oSection1:Cell("CONTA"):SetBlock( { || IIF(cArqTmp->TIPOCONTA=="2","  ","")+EntidadeCTB(cArqTmp->CONTA ,,,70,.F.,cMascara1,cSepara1,,,,,.F.) } )
EndIf	

oSection1:Cell("DESCCTA")	:SetBlock( { || cArqTmp->DESCCTA } )                                                                     
oSection1:Cell("SALDOANT")	:SetBlock( { || ValorCTB(cArqTmp->SALDOANT	,,,aTamVal[1]-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL, , , , , ,lPrintZero,.F./*lSay*/) } )		
oSection1:Cell("SALDODEB")	:SetBlock( { || ValorCTB(cArqTmp->SALDODEB	,,,aTamVal[1],nDecimais,.F.,cPicture,cArqTmp->NORMAL, , , , , ,lPrintZero,.F./*lSay*/,lColDbCr) } ) 
oSection1:Cell("SALDOCRD")	:SetBlock( { || ValorCTB(cArqTmp->SALDOCRD	,,,aTamVal[1],nDecimais,.F.,cPicture,cArqTmp->NORMAL, , , , , ,lPrintZero,.F./*lSay*/,lColDbCr) } ) 
//Imprime Movimento
If mv_par19 = 1
	oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO	,,,aTamVal[1]-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL, , , , , ,lPrintZero,.F./*lSay*/) } )	
ElseIf mv_par19 = 2 //Nao imprime movimento
	oSection1:Cell("MOVIMENTO"):Disable()
Endif
oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB(cArqTmp->SALDOATU	,,,aTamVal[1]-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL, , , , , ,lPrintZero,.F./*lSay*/) } )		

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CTI","",mv_par03,mv_par04,,,,,mv_par05,mv_par06,mv_par10,;
				mv_par12,aSetOfBook,mv_par15,mv_par16,mv_par17,mv_par18,;
				l132,.T.,,"CTH",lImpAntLP,dDataLP, nDivide,lVlrZerado,,,;
				mv_par30,mv_par31,mv_par32,mv_par33,,,,,,,,,oSection0:GetAdvplExp('CT1'),lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,,,aSelFil,,,,,,,,lCtiSint,lTodasFil)},;
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor�rio..."
				OemToAnsi(STR0003)+cSayClVl)   //"Balancete Verificacao Conta /"      
				
oSection1:SetParentFilter({|cParam| cArqTmp->CLVL == cParam  },{|| cArqTmp->CLVL })  

If mv_par07 == 1					// So imprime Sinteticas
	cFilter := "cArqTmp->TIPOCONTA  <>  '2'  "
	If mv_par34 == 1					// So imprime Sinteticas
		cFilter += ".and. cArqTmp->TIPOCLVL  <>  '2'  "
	ElseIf mv_par34 == 2				// So imprime Analiticas
		cFilter += ".and. cArqTmp->TIPOCLVL  <>  '1'  "
	EndIf
ElseIf mv_par07 == 2				// So imprime Analiticas
	cFilter := "cArqTmp->TIPOCONTA  <>  '1'  "
	If mv_par34 == 1					// So imprime Sinteticas
		cFilter += ".and. cArqTmp->TIPOCLVL  <>  '2'  "
	ElseIf mv_par34 == 2				// So imprime Analiticas
		cFilter += ".and. cArqTmp->TIPOCLVL  <>  '1'  "
	EndIf
EndIf

If mv_par34 == 1 .and. Empty(cFilter)					// So imprime Sinteticas
	cFilter := "cArqTmp->TIPOCLVL  <>  '2'  "
ElseIf mv_par34 == 2 .and. Empty(cFilter)				// So imprime Analiticas
	cFilter := "cArqTmp->TIPOCLVL  <>  '1'  "
EndIf

// Verifica Se existe filtragem Ate o Segmento
If ! Empty( cSegAte )
	nDigitAte := CtbRelDig( cSegAte, cMascara1 )
	If !Empty(cFilter)
		cFilter += " .and. "
	EndIf	 	
		 	
	cFilter += ( 'Len(Alltrim(cArqTmp->CONTA)) <= ' + alltrim( Str( nDigitAte )) )  
EndIf	 
           
// Verifica Se existe filtragem Ate o Segmento
If ! Empty( cSegClAte )
	nDigClAte := CtbRelDig( cSegClAte, cMascara2 )
	If !Empty(cFilter)
		cFilter += " .and. "
	EndIf	 	
		 	
	cFilter += ( 'Len(Alltrim(cArqTmp->CLVL)) <= ' + alltrim( Str( nDigClAte )) )  
EndIf	 
    
   
oSection1:SetFilter( cFilter )                                                

oBreak:= TRBreak():New(oReport, {|| cArqTmp->CLVL },  )

If mv_par21 == 1 //Pula Pagina? 1 = Sim   2 = Nao
	oBreak:SetPageBreak(.T.)
Else
	oBreak:SetPageBreak(.F.)
Endif

If mv_par13 == 1				// Grupo Diferente
	oBreak1:= TRBreak():New(oReport, {|| cArqTmp->GRUPO },  )
	oBreak1:SetPageBreak(.T.)
EndIf          

//Totalizadores
oFuncDeb 	:= TRFunction():New(oSection1:Cell("SALDODEB") , ,"SUM", oBreak 	,,/*[ cPicture ]*/,{ || TotSaldo(1) }/*[ uFormula ]*/,,.T.,.F.,oSection1)
oFuncCred 	:= TRFunction():New(oSection1:Cell("SALDOCRD") , ,"SUM", oBreak	,,/*[ cPicture ]*/,{ || TotSaldo(2) }/*[ uFormula ]*/,,.T.,.F.,oSection1)

If mv_par19 = 1
	oFuncMov := TRFunction():New(oSection1:Cell("MOVIMENTO"), ,"SUM", oBreak,,/*[ cPicture ]*/,{ || Iif(cArqTMP->TIPOCONTA="1",0,cArqTMP->MOVIMENTO) }/*[ uFormula ]*/,,.T.,.F.,oSection1)
Endif

oFuncDeb:Disable()
oFuncCred:Disable()

If mv_par19 = 1
	oFuncMov:Disable()
EndIf

oFuncPerDeb 	:= TRFunction():New(oSection1:Cell("SALDODEB") , ,"SUM", /*oBreak*/ 	,,/*[ cPicture ]*/,{ || TotSaldo(1) }/*[ uFormula ]*/,.F.,.T.,.F.,oSection1)
oFuncPerCred 	:= TRFunction():New(oSection1:Cell("SALDOCRD") , ,"SUM", /*oBreak*/	,,/*[ cPicture ]*/,{ || TotSaldo(2) }/*[ uFormula ]*/,.F.,.T.,.F.,oSection1)

If mv_par19 = 1
	oFuncPerMov := TRFunction():New(oSection1:Cell("MOVIMENTO"), ,"SUM", /*oBreak*/,,/*[ cPicture ]*/,{ || Iif(cArqTMP->TIPOCONTA="1",0,cArqTMP->MOVIMENTO) }/*[ uFormula ]*/,.F.,.T.,.F.,oSection1)
Endif

oFuncPerDeb:Disable()
oFuncPerCred:Disable()

If mv_par19 = 1
	oFuncPerMov:Disable()
EndIf

oTotDeb := TRFunction():New(oSection1:Cell("SALDODEB") , ,"ONPRINT", /*oBreak */	,,/*[ cPicture ]*/,/*[ uFormula ]*/,,.F.,.F.,oSection1)
oTotDeb:SetFormula( {|| ValorCTB(oFuncDeb:GetValue(),,,aTamVal[1],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero, .F.,lColDbCr)})
oTotCred := TRFunction():New(oSection1:Cell("SALDOCRD") , ,"ONPRINT", /*oBreak*/	,,/*[ cPicture ]*/,/*[ uFormula ]*/,,.F.,.F.,oSection1)
oTotCred:SetFormula( {|| ValorCTB(oFuncCred:GetValue(),,,aTamVal[1],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero, .F.,lColDbCr) })

If mv_par19 = 1
	oTotMov := TRFunction():New(oSection1:Cell("MOVIMENTO"), ,"ONPRINT", /*oBreak*/,,/*[ cPicture ]*/,/*[ uFormula ]*/,,.T.,.F.,oSection1)
	If lRedStorn
		oTotMov:SetFormula( {|| nTotMov := RedStorTt(oFuncDeb:GetValue(),oFuncCred:GetValue(),,,"T") , ValorCTB(nTotMov,,,aTamVal[1]-2,nDecimais,.T.,cPicture,Iif(nTotMov<0,"1","2"), , , , , ,lPrintZero, .F.,lColDbCr)})
	Else
		oTotMov:SetFormula( {|| nTotMov := oFuncCred:GetValue()-oFuncDeb:GetValue() , ValorCTB(nTotMov,,,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero, .F.)})
	Endif	
Endif

oTotPerDeb := TRFunction():New(oSection1:Cell("SALDODEB") , ,"ONPRINT", /*oBreak */	,,/*[ cPicture ]*/,/*[ uFormula ]*/,.F.,.T.,.F.,oSection0)
oTotPerDeb:SetFormula( {|| ValorCTB(oFuncPerDeb:GetValue(),,,17,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero, .F.,lColDbCr)})
oTotPerCred := TRFunction():New(oSection1:Cell("SALDOCRD") , ,"ONPRINT", /*oBreak*/	,,/*[ cPicture ]*/,/*[ uFormula ]*/,.F.,.T.,.F.,oSection0)
oTotPerCred:SetFormula( {|| ValorCTB(oFuncPerCred:GetValue(),,,17,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero, .F.,lColDbCr) })

If mv_par19 = 1
	oTotPerMov := TRFunction():New(oSection1:Cell("MOVIMENTO"), ,"ONPRINT", /*oBreak*/,,/*[ cPicture ]*/,/*[ uFormula ]*/,.F.,.T.,.F.,oSection1)
	If lRedStorn
		oTotPerMov:SetFormula( {|| nTotMov := RedStorTt(oFuncPerDeb:GetValue(),oFuncPerCred:GetValue(),,,"T") , ValorCTB(nTotMov,,,aTamVal[1]-2,nDecimais,.T.,cPicture,Iif(nTotMov<0,"1","2"), , , , , ,lPrintZero, .F.,lColDbCr)})
	Else
		oTotPerMov:SetFormula( {|| nTotMov := oFuncPerCred:GetValue()-oFuncPerDeb:GetValue() , ValorCTB(nTotMov,,,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero, .F.)})
	Endif
Endif

oSection1:OnPrintLine( {|| ( IIf( lPulaSint .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2")), oReport:skipLine(),NIL),;
								 cTipoAnt := cArqTmp->TIPOCONTA;
							)  }) 

oSection0:Print()		

oBreak:SetPageBreak(.F.)
If mv_par13 == 1
	oBreak1:SetPageBreak(.F.)
Endif
Return

Static Function TotSaldo(nTpSld)
Local nTotDeb := 0
Local nTotCrd := 0
Local nRet := 0

If mv_par07 != 1					// Imprime Analiticas ou Ambas
	If cArqTMP->TIPOCONTA == "2"
		If (mv_par34 != 1 .And. cArqTMP->TIPOCLVL == "2")
			nTotDeb 		:= cArqTMP->SALDODEB 
			nTotCrd    		:= cArqTMP->SALDOCRD
		ElseIf (mv_par34 == 1 .And. cArqTMP->TIPOCLVL != "2"	)
				nTotDeb 		:= cArqTMP->SALDODEB 
				nTotCrd    		:= cArqTMP->SALDOCRD			
		EndIf	
	Endif
Else
	If (cArqTMP->TIPOCONTA == "1" .And. Empty(cArqTMP->SUPERIOR))
		If (mv_par34 != 1 .And. cArqTMP->TIPOCLVL == "2")
			nTotDeb 		:= cArqTMP->SALDODEB 
			nTotCrd    		:= cArqTMP->SALDOCRD
		ElseIf (mv_par34 == 1 .And. cArqTMP->TIPOCLVL != "2"	)
			nTotDeb 		:= cArqTMP->SALDODEB 
			nTotCrd    		:= cArqTMP->SALDOCRD	
		EndIf	
	EndIf		
Endif

If nTpSld=1
	nRet := nTotDeb
Else	
	nRet := nTotCrd
EndIf

Return(nRet)