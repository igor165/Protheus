#INCLUDE "ctbr501.ch"
#Include "PROTHEUS.Ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr501	� Autor � TOTVS					� Data � 01.12.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demostrativo de balancos patrimoniais  		 		  	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbR501()

PRIVATE cPerg := "CTR501"    

CTBR501R4()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR501R4 � Autor� TOTVS					� Data � 01.12.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demostrativo de balancos patrimoniais - Portugal           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR115R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR501R4()                           
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.

Private nomeprog	:= "CTBR501"       
//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������            
If ! CtrVld501(cPerg)
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)		     �
//����������������������������������������������������������������
// faz a valida��o do livro
if ! Empty( mv_par02 ) 
	if ! VdSetOfBook( mv_par02 , .F. )
		lRet := .F.
	endif
Endif

IF lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par02)
	
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03, aSetOfBook[9])
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf	
        
	oReport := ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)      
	oReport :PrintDialog()
	      
EndIf
Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � TOTVS					� Data � 01.12.10 ���
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
Static Function ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)  
local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR501"
Local cTITULO		:= Capital(STR0001)		// BALANCOS PATRIMONIAIS
Local cDESC			:= STR0012 + STR0013
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 10
Local dFinal 		:= CTOD(SPACE(8))

cTitulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo )		// Titulo definido SetOfBook  
If Valtype(mv_par11)=="N" .And. (mv_par11 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

If Empty(MV_PAR08)
	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dFinal	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo
Else
	dFinal:= MV_PAR08
EndIf     

nAno := year(dFinal)

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
oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dFinal), .T., oReport:CancelPrint())}, CDESC)
oReport:SetPortrait(.T.)
//oReport:ParamReadOnly()
//IF GETNEWPAR("MV_CTBPOFF",.T.)
//	oReport:SetEdit(.F.)
//ENDIF	

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 8

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
oSection1  := TRSection():New( oReport, STR0014, {"cArqTmp"},, .F., .F. )      // "Detalhe"

TRCell():New( oSection1, "DESCCTA", , STR0015  /*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",,"CENTER")
TRCell():New( oSection1, "NOTAS"  , , STR0016 /*Titulo*/,/*Picture*/,20  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",,"CENTER")
TRCell():New( oSection1, "SALDOATU", , STR(nAno)+CRLF+STR0007/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER")
TRCell():New( oSection1, "SALDOANT", , STR(nAno-1)+CRLF+STR0007/*Titulo*/,/*Picture*/,aTamVal[1] +nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER")


oSection1:SetTotalInLine(.F.)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDatabase,cTitulo,,,,,oReport) } )

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � TOTVS				� Data � 01.12.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(ExpO1,ExpC1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Obj. do relatorio	                              ���
���          � ExpC1 = Titulo do relatorio (sera' atualizado conf. param.)���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relatorio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport,Titulo, dFinal )  
Local oSection1 	:= oReport:Section(1)  
Local oSection2 	:= oReport:Section(2)  
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aColunas		:= { {}, {} }
Local aMaxCol		:= {	{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 },;
							{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 } }
Local cTpValor		:= GetMV("MV_TPVALOR")
Local lImpTrmAux	:= (mv_par05 == 1)
Local cArqTrm		:= ""    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= mv_par09 // RFC - 22/01/07 - BOPS 103653
Local lSaltaLin		:= .T.

oReport:SetPageNumber( MV_PAR04 )

If  Empty(CTBSetOf(mv_par02)[5])
	ApMsgAlert(	STR0008) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

dFinalA := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9]) 

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]  

lComNivel	:= .T.

m_pag := mv_par04
//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao							  �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		   				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		   				"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
		   				MV_PAR10,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		   				,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc)},;
			STR0006, Titulo) //"Criando Arquivo Temporario..."


IndRegua("cArqTmp",cArqTmp,"Str(cArqTmp->COLUNA)+CONTA",,,OemToAnsi(STR0006))  //"Selecionando Registros..."

dbSelectArea("cArqTmp") 
dbGoTop()

oSection1:Cell("DESCCTA"):SetBlock( { || cArqtmp->DESCCTA } )    
oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB( cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,;
									                 cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB( cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,;
									                 cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,,,.F. ) } )

oSection1:Init()

oReport:SetLineHeight(40)  
oSection1:SetBorder(5)
oSection1:SetCellBorder(3) 

While ! Eof() 

 	If lSaltaLin .And. cArqTmp->COLUNA == 2
 		
 		oSection1:Cell("DESCCTA"):Hide()  
		oSection1:Cell("SALDOATU"):Hide()
		oSection1:Cell("SALDOANT"):Hide()
 
 		oSection1:PrintLine()
		oSection1:PrintLine()   
		
		oSection1:Cell("DESCCTA"):Show()  
		oSection1:Cell("SALDOATU"):Show()
		oSection1:Cell("SALDOANT"):Show()
		
		lSaltaLin := .F.	
	Endif   
	
	If !(mv_par07 == 2 .And. cArqTmp->SALDOATU == 0 .And. cArqTmp->SALDOANT == 0 .And. cArqTmp->TIPOCONTA == '2')
		oSection1:PrintLine()
	Endif
	
	dbSkip() 
		
EndDo 

oSection1:Finish()   
 
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

If lImpTrmAux
	cArqTRM 	:= mv_par06
	aVariaveis	:= {}

    // Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek( padr( "CTR501" , Len( X1_GRUPO ) , ' ' ) + "01" ) )

	Do While SX1->X1_GRUPO == padr( "CTR501" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	Enddo
	
	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0009) // "Respons�veis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
	Endif	 
Endif


Return .T.

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � CtrVld501    � Autor � Wagner Mobile Costa	� Data � 25/10/01 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica as perguntas dos relatorios                           ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � Siga                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Function CtrVld501(cPerg)


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return .F.
EndIf

If ! Pergunte(cPerg,.T.) 
	Return .F.
Endif                    

If Empty(mv_par01)	
	Help(" ",1,"NOEXCONTAB")	
	Return .F.		
Else
	CTG->(dbSetOrder(1))
	If CTG->(! DbSeek(xFilial() + mv_par01))
		Help(" ",1,"NOEXISCALE")
		Return .F.
	EndIf
EndIf

Return .T.

