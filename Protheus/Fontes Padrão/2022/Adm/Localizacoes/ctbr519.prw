#INCLUDE "ctbr519.ch"
#Include "PROTHEUS.Ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CtbR519   � Autor� PAULO AUGUSTO     	� Data � 04/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demostrativo de resultado                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CtbR519       											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�26/06/15�PCREQ-4256�Se elimina la funcion CTR519SX1() la  ���
���            �        �          �cual realiza modificacion a SX1 por   ���
���            �        �          �motivo de adecuacion a fuentes a nueva���
���            �        �          �estructura de SX para Version 12.     ���
���Jonathan Glz�09/10/15�PCREQ-4261�Merge v12.1.8                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CtbR519(lExterno,aPerg,cReport,cTitulo,cDesc,nomeprog,cPerg,aDescCab)                           

Private dFinalA
Private dFinal
Default aDescCab:={}
Default CPERG	:= "CTR519"                                     
Default nomeprog:="CTBR519"    
Default	cTitulo:=OemToAnsi(STR0001) //"DEMONSTRATIVO DO PTU"
Default lExterno :=.F.  
Default cDesc:=		OemToAnsi(STR0002) +; //" Este programa ir� imprimir o Demonstracao"
			 	OemToAnsi(STR0003)  //"da Participacao de Utilidade dos Trabalhadores"
Default CREPORT		:= "CTBR519"	   					
//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������            
If !lExterno
	Pergunte( CPERG, .T. )
Else
	If Len(aPerg)>=6
		MV_PAR01:=aPerg[1]
		MV_PAR02:=aPerg[2]
		MV_PAR03:=aPerg[3]
		MV_PAR04:=aPerg[4]
		MV_PAR05:=aPerg[5] 
		MV_PAR06:=aPerg[6]
	Else
		MsgStop(STR0004) //"Array de pergunta fora do padrao do relatorio"
	EndIf
		
EndIf

If Empty(mv_par01)	
	MsgAlert(STR0005         )	 //"A pergunta Exercicio Contabil nao pode ficar em branco..."
	Return .F.		
Else
	CTG->(DbSeek(xFilial() + mv_par01))
EndIf

dbSelectArea("CTN")
dbSetOrder(1)
If !MsSeek(xFilial()+mv_par02)
	Help(" ",1,"NOSETOFB")	
	Return .F.	
EndIf

oReport := ReportDef(cReport,@cTitulo,cDesc,nomeprog,cPerg,aDescCab)      
oReport :PrintDialog()      

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Paulo Augusto    		� Data � 22/01/07 ���
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
Static Function ReportDef(cReport,cTitulo,cDesc,nomeprog,cPerg,aDescCab)     

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local cDescMoeda 	:= ""
local aArea	   	:= GetArea()   
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)				  �
//����������������������������������������������������������������
If !ct040Valid(mv_par02)
	Return
EndIf	
             
lMovPeriodo	:= (mv_par05 == 1)

CTG->(DbSeek(xFilial() + mv_par01))

	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dFinal	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo
	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	If lMovPeriodo
		dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
	EndIf

CTITULO		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], CTITULO)		// Titulo definido SetOfBook
If Valtype(mv_par08)=="N" .And. (mv_par08 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf
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
oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC ) 
oReport:SetCustomText( {||		 CTBR519CAB(     ,      ,     ,      ,      ,dFinal  ,ctitulo,          ,     ,       ,    ,oReport,aDescCab,nomeprog) } )
oReport:ParamReadOnly()

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
oSection1  := TRSection():New( oReport,"Contas/Saldos", {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"

TRCell():New( oSection1, "ATIVO"    ,"",""/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"(Em "
TRCell():New( oSection1, "COLUNA1"	 ,"",""/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "COLUNA2"	 ,"",""/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "DC_SALATU","",""/*Titulo*/,/*Picture*/,2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

oSection1:Cell("COLUNA1"):SetHeaderAlign("RIGHT")
oSection1:Cell("COLUNA2"):SetHeaderAlign("RIGHT")

oSection1:SetTotalInLine(.F.) 

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Paulo Augusto    	� Data � 22/01/07 ���
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
Static Function ReportPrint( oReport )  

Local oSection1 	:= oReport:Section(1) 
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local lin 			:= 3001
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lImpTrmAux	:= .F.
Local cArqTrm		:= ""
Local lVlrZerado	:= .F.
Local lMovPeriodo
Local aTamVal		:= TAMSX3("CT2_VALOR")

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

lMovPeriodo	:= (mv_par05 == 1)

m_pag := mv_par07
//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dFinalA+1,dFinal," "," "," ",Repl("Z", Len(CT1->CT1_CONTA)),;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
			"1",aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30),,,,,;
			.F., ,,lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,,;
			lMovPeriodo)},STR0006, "")  //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

oSection1:Cell("DC_SALATU"):SetTitle("")

oSection1:Cell("ATIVO"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA="2",cArqTmp->DESCCTA,cArqTmp->DESCCTA),"") } )		

If mv_par05 = 1

	If cArqTmp->COLUNA < 2
	oSection1:Cell("COLUNA1" ):SetBlock( { || Iif( cArqTmp->MOVIMENTO > 0,;
															  ValorCTB(cArqTmp->MOVIMENTO,,,aTamVal[1],nDecimais,.T.,cPicture,;
														     cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),0) } )	
	Else
	oSection1:Cell("COLUNA2" ):SetBlock( { || Iif( cArqTmp->MOVIMENTO > 0,;
															  ValorCTB(cArqTmp->MOVIMENTO,,,aTamVal[1],nDecimais,.T.,cPicture,;
														     cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),0) } )		
	EndIf													     
Else

	If cArqTmp->COLUNA < 2
		oSection1:Cell("COLUNA1" ):SetBlock( { || Iif( cArqTmp->SALDOATU  > 0,;
															  ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,;
														     cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),0) } )	
    Else
    
    	oSection1:Cell("COLUNA2" ):SetBlock( { || Iif(cArqTmp->SALDOATU  > 0,;
															  ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,;
														     cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),0) } )	
	EndIf														     
Endif

oSection1:Print()

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CTBR519CAB � Autor � Paulo Augusto        � Data � 22/01/07 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Monta Cabecalho do relatorio                                ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �CtCGCCabTR(Titulo,oReport)                                  ���
��������������������������������������������������������������������������Ĵ��
��� Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros �Arg1  = Indica se imprime item							   ���
���           �Arg2  = Indica se imprime c.custo						   ���
���           �Arg3  = Indica se imprime classe de valor				   ���
���           �Arg4  = Conteudo da cabec1               				   ���
���           �Arg5  = Conteudo da cabec2               				   ���
���           �Arg6  = Data final do relatorio          				   ���
���           �Arg7  = Titulo                           				   ���
���           �Arg8  = Indica se imprime analitico      				   ���
���           �Arg9  = Tipo                             				   ���
���           �Arg10 = Tamanho                          				   ���
���           �Arg11 = Retorna titulos                  				   ���
���           �Arg12 = Objeto do oReport                   				   ���
���           �Arg13 = Nome do programa                   				   ���
���           �Os parametros da funcao original �CtCGCCabec� foram mantidos���
���           �somente para a fins de compatibilidade.     				   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CTBR519CAB(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo  ,lAnalitico,cTipo,Tamanho,aCab,oReport,aDescCab,nomeprog)
		 
RptFolha := GetNewPar("MV_CTBPAG",RptFolha)

DEFAULT aCab := {} 
Default aDescCab:={}

If Len (aDescCab)>0
	aCabec:= {	"__LOGOEMP__",;
			".          " + AllTrim(SM0->M0_NOMECOM) + "       ." + RptFolha+ TRANSFORM(oReport:Page(),'999999'),;
            aDescCab[1]  ,;
			 aDescCab[2]  ,;            
            "SIGA /" + NomeProg + "/v." + cVersao + "   " + "           .",;
            RptHora + " " + time() + "     " + RptEmiss + " " + Dtoc(dDataBase) }
Else
	aCabec:= {	"__LOGOEMP__",;
			".          " + AllTrim(SM0->M0_NOMECOM) + "       ." + RptFolha+ TRANSFORM(oReport:Page(),'999999'),;
            ".          " + Titulo + "       ." ,; //"DETERMINACAO do PTU"
			".          " + STR0008 + Alltrim(Str(year(dDataFim))) + "       ." ,;             //"EXERCICIO "
            "SIGA /" + NomeProg + "/v." + cVersao + "   " + "           .",;
            RptHora + " " + time() + "     " + RptEmiss + " " + Dtoc(dDataBase) }
EndIf

SX3->(DbSetOrder(2))
SX3->(MsSeek("A1_CGC",.t.))

If SM0->(Eof())                                
	SM0->(MsSeek(cEmpAnt+cFilAnt,.T.))
Endif

Aadd(aCab,AllTrim(SM0->M0_NOMECOM))
Aadd(aCab,AllTrim(titulo))
Aadd(aCab,Transform(Alltrim(SM0->M0_CGC),alltrim(SX3->X3_PICTURE)))

Return aCabec
