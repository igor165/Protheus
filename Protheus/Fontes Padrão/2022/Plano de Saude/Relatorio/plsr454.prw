#include "PROTHEUS.CH"
#include "PLSMGER.CH"                    
#INCLUDE "PLSR454.CH"
static objCENFUNLGP := CENFUNLGP():New() 
static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSR454  � Autor � Alexander Santos       � Data � 15.03.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao �Mapa de Pagamento											  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR454                                                    ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
���			 �      �  			  � 						              ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR454(lAuto)

LOCAL cOpeDe
LOCAL cOpeAte
LOCAL cFornecDe
LOCAL cFornecAte
LOCAL cRDADe
LOCAL cRDAAte
LOCAL cEspeDe
LOCAL cEspeAte
LOCAL cLocalDe
LOCAL cLocalAte
LOCAL cEmpDe
LOCAL cEmpAte
LOCAL cContDe
LOCAL cContAte
LOCAL cSubCDe
LOCAL cSubCAte
LOCAL cProcDe
LOCAL cProcAte
LOCAL cMesBase
LOCAL cAnoBase
LOCAL dDataDe
LOCAL dDataAte
LOCAL lRet
Local aAlias := {}

PRIVATE aResumo		:= {}
PRIVATE pMoeda      := "@E 99999"
PRIVATE pMoeda1     := "@E 99,999.99"
PRIVATE pMoeda2     := "@E 9,999,999.99"
PRIVATE nQtdLin     := 64     
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cDesc1      := ""
PRIVATE cDesc2      := "" 
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE nLi         := 1   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {} 
PRIVATE lAbortPrint := .F.
PRIVATE nColuna     := 01 	
PRIVATE aLinha      := {}
PRIVATE cPerg       := "PLR454"
PRIVATE cRel        := "PLSR454"
PRIVATE cTitulo     := FunDesc() //"Mapa de Previs�o de Pagamentos"
PRIVATE cCabec1     := ""
PRIVATE cCabec2 	:= ""
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE aCabClass   := {}
PRIVATE nTipo
PRIVATE nForma

Default lAuto := .F.

lAutoSt := lAuto

//��������������������������������������������������������������������������Ŀ
//� Testa ambiente do relatorio somente top...                               �
//����������������������������������������������������������������������������
If ! PLSRelTop()
   Return
Endif    

//��������������������������������������������������������������������������Ŀ
//� Busca os parametros...  Sai se o usuario clicar no X                     �
//����������������������������������������������������������������������������
If Pergunte(cPerg,.F.)  .AND. !lAuto
   Return 
Endif             
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint (padrao)                                                  �
//����������������������������������������������������������������������������
If !lauto
	cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
	//��������������������������������������������������������������������������Ŀ
	//� Verifica se foi cancelada a operacao (padrao)                            �
	//����������������������������������������������������������������������������
	If nLastKey  == 27 
	Return
	Endif
endIf
//��������������������������������������������������������������������������Ŀ
//� Alimenta variaveis conforme parametros									 �
//����������������������������������������������������������������������������
cOpeDe		:= Mv_Par01
cOpeAte		:= Mv_Par02
cFornecDe	:= Mv_Par03	
cFornecAte	:= Mv_Par04
cRDADe		:= Mv_Par05
cRDAAte		:= Mv_Par06
cEspeDe		:= Mv_Par07
cEspeAte	:= Mv_Par08	
cLocalDe	:= Mv_Par09	
cLocalAte	:= Mv_Par10
cEmpDe		:= Mv_Par11
cEmpAte		:= Mv_Par12
cContDe		:= Mv_Par13
cContAte	:= Mv_Par14
cSubCDe		:= Mv_Par15
cSubCAte	:= Mv_Par16	
cProcDe		:= Mv_Par17
cProcAte	:= Mv_Par18
dDataDe		:= Mv_Par19
dDataAte	:= Mv_Par20
cAnoBase	:= Mv_Par21
cMesBase	:= Mv_Par22
nForma		:= Mv_par23
nTipo    	:= Mv_Par24
If lauto
	cOpeDe		:= "  "
	cOpeAte		:= "0001"
	cFornecDe	:= "  "	
	cFornecAte	:= "ZZ"
	cRDADe		:= "  "	
	cRDAAte		:= "ZZ"
	cEspeDe		:= "  "	
	cEspeAte	:= "ZZ"	
	cLocalDe	:= "  "		
	cLocalAte	:= "ZZ"
	cEmpDe		:= "  "	
	cEmpAte		:= "ZZ"
	cContDe		:= "  "	
	cContAte	:= "ZZ"
	cSubCDe		:= "  "	
	cSubCAte	:= "ZZ"	
	cProcDe		:= "  "	
	cProcAte	:= "ZZ"
	dDataDe		:= StoD("20200101")
	dDataAte	:= StoD("20210101")
	cAnoBase	:= "2020"
	cMesBase	:= "12"
	nForma		:= 1
	nTipo    	:= 1
endIf
//��������������������������������������������������������������������������Ŀ
//� Verifica ano e mes quando for por valor mensalidade						 �
//����������������������������������������������������������������������������
If  !lauto .AND. ( Empty(cAnoBase) .Or. Empty(cMesBase) )
   MsgAlert(STR0015)
   Return
EndIf
//��������������������������������������������������������������������������Ŀ
//� Verifica Analitico e Sintetico											 �
//����������������������������������������������������������������������������
If  !lauto .AND. nForma == 1 .And. nTipo == 1
   MsgAlert(STR0022)
   Return
EndIf
//����������������������������������������������������������������Ŀ
//� Descricao do Tipo											   �
//������������������������������������������������������������������      
Do Case
   Case nTipo == 2
        cTitulo += STR0016 + STR0010
   Case nTipo == 3
        cTitulo += STR0016 + STR0011
   Case nTipo == 4
        cTitulo += STR0016 + STR0025
   Case nTipo == 5
        cTitulo += STR0016 + STR0026
EndCase   
//��������������������������������������������������������������������������Ŀ
//� Processa Dados															 �
//����������������������������������������������������������������������������
If  !lauto
	MsAguarde({|| lRet := RTRBPro(cOpeDe,cOpeAte,cFornecDe,cFornecAte,cRDADe,cRDAAte,cEspeDe,cEspeAte,cLocalDe,cLocalAte,cEmpDe,cEmpAte,cContDe,;
		   					   cContAte,cSubCDe,cSubCAte,cProcDe,cProcAte,cMesBase,cAnoBase,dDataDe,dDataAte) },cTitulo, STR0006, .T.)
else
	RTRBPro(cOpeDe,cOpeAte,cFornecDe,cFornecAte,cRDADe,cRDAAte,cEspeDe,cEspeAte,cLocalDe,cLocalAte,cEmpDe,cEmpAte,cContDe,;
		   					   cContAte,cSubCDe,cSubCAte,cProcDe,cProcAte,cMesBase,cAnoBase,dDataDe,dDataAte)
endIf

If  !lauto
	//��������������������������������������������������������������������������Ŀ
	//� Verifica qual o tamanho do relatorio									 �
	//����������������������������������������������������������������������������
	If lRet                  
	//��������������������������������������������������������������������������Ŀ
	//� Caso exista muitas classes e nao da para exibir todas no maior tamanho   �
	//����������������������������������������������������������������������������
	If Len(aCabClass) > 14
		MsgAlert(STR0012)
		Return
	EndIf    
	//��������������������������������������������������������������������������Ŀ
	//� Maior que 5 classes coloca no tamanho g									�
	//����������������������������������������������������������������������������
	If Len(aCabClass) > 11 
		nLimite  := 220     
		cTamanho := "G"     
	EndIf
	Else
		if  !lauto
			MsgInfo(STR0008)
			Return
		endIf
	EndIf
	//��������������������������������������������������������������������������Ŀ
	//� Configura impressora (padrao)                                            �
	//����������������������������������������������������������������������������
	SetDefault(aReturn,cAlias) 
endIf
//��������������������������������������������������������������������������Ŀ
//� Cabecalho																 �
//����������������������������������������������������������������������������
cCabec1 := 	STR0002 +STR0003 +DtoC(dDataDe)	+STR0004+DtoC(dDataAte)	+STR0013+; //Data
					 STR0003 +cFornecDe		+STR0004+cFornecAte		+STR0013+; //Fornecedor
					 STR0003 +cLocalDe		+STR0004+cLocalAte		+STR0013+; //Local
					 STR0003 +cContDe		+STR0004+cContAte		+STR0013   //Contrato
//��������������������������������������������������������������������������Ŀ
//� Gerando																	 �
//����������������������������������������������������������������������������
aAlias := {"SA2","BD1","BG9","BR8","BAQ"} 
objCENFUNLGP:setAlias(aAlias) 
If  ! !lauto
	MsAguarde({|| RTRBImp() },cTitulo, STR0005, .T.)
else
	RTRBImp()
endIf
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � RTRBPro	 � Autor � Alexander Santos      � Data � 18.04.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Processa Query											   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Function RTRBPro(cOpeDe,cOpeAte,cFornecDe,cFornecAte,cRDADe,cRDAAte,cEspeDe,cEspeAte,cLocalDe,cLocalAte,cEmpDe,cEmpAte,cContDe,;
				 	    cContAte,cSubCDe,cSubCAte,cProcDe,cProcAte,cMesBase,cAnoBase,dDataDe,dDataAte)
LOCAL nI
LOCAL cSQL
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
If !lAutoSt
	MsProcTxt(STR0006)                                                                           
	ProcessMessage()
endIf
//��������������������������������������������������������������������������Ŀ
//� For																		 �
//����������������������������������������������������������������������������
For nI := 1 To 2
	//��������������������������������������������������������������������������Ŀ
	//� Classe																	 �
	//����������������������������������������������������������������������������
	If nI == 1           
		cSQL := " SELECT DISTINCT BR8.BR8_CLASSE "
	Else 
		cSQL := " SELECT BD6.BD6_CODOPE,BD6.BD6_CODRDA,BD6.BD6_CODESP,BD6.BD6_LOCAL,BD6.BD6_CODEMP,BD6.BD6_CONEMP,BD6.BD6_SUBCON,BD6.BD6_CODPAD,BD6.BD6_CODPRO,BD6.BD6_DATPRO,BD6.BD6_VLRPAG, "
		cSQL += "        BD6.BD6_CODLDP,BD6.BD6_CODPEG,BD6.BD6_NUMERO,BD6.BD6_ORIMOV,BD6.BD6_SEQUEN,BD6.BD6_INTERC, "
		cSQL += "        BAU.BAU_CODSA2,BAU.BAU_LOJSA2, " 
		cSQL += "        BR8.BR8_CLASSE "
	EndIf
	cSQL += " FROM "+RetSQLName("BD6")+" BD6, "+RetSQLName("BDH")+" BDH, "+RetSQLName("BAU")+" BAU, "+RetSQLName("BR8")+" BR8 "
	cSQL += " WHERE BD6.BD6_FILIAL = '"+xFilial("BD6")+"' "
	
	cSQL += " AND BD6.BD6_CODOPE BETWEEN '"+cOpeDe+"' AND '"+cOpeAte+"' "
	cSQL += " AND BD6.BD6_CODRDA BETWEEN '"+cRDADe+"' AND '"+cRDAAte+"' "
	cSQL += " AND BD6.BD6_CODESP BETWEEN '"+cEspeDe+"' AND '"+cEspeAte+"' "
	cSQL += " AND BD6.BD6_LOCAL BETWEEN '"+cLocalDe+"' AND '"+cLocalAte+"' "
	cSQL += " AND BD6.BD6_CODEMP BETWEEN '"+cEmpDe+"' AND '"+cEmpAte+"' "
	cSQL += " AND BD6.BD6_CONEMP BETWEEN '"+cContDe+"' AND '"+cContAte+"' "
	cSQL += " AND BD6.BD6_SUBCON BETWEEN '"+cSubCDe+"' AND '"+cSubCAte+"' "
	cSQL += " AND BD6.BD6_CODPRO BETWEEN '"+cProcDe+"' AND '"+cProcAte+"' "
	cSQL += " AND BD6.BD6_DATPRO BETWEEN '"+DToS(dDataDe)+"' AND '"+DToS(dDataAte)+"' "
	cSQL += " AND BD6.BD6_MESPAG = '"+cMesBase+"' "
	cSQL += " AND BD6.BD6_ANOPAG = '"+cAnoBase+"' "
	cSQL += " AND BD6.D_E_L_E_T_ = ' ' "
	          
	cSQL += " AND BDH.BDH_FILIAL = '"+xFilial("BDH")+"' "
	cSQL += " AND BDH.BDH_CODINT = BD6.BD6_CODOPE "
	cSQL += " AND BDH.BDH_CODEMP = BD6.BD6_CODEMP "
	cSQL += " AND BDH.BDH_MATRIC = BD6.BD6_MATRIC "
	cSQL += " AND BDH.BDH_TIPREG = BD6.BD6_TIPREG "
	cSQL += " AND BDH.BDH_MESFT  = '"+cMesBase+"' "
	cSQL += " AND BDH.BDH_ANOFT  = '"+cAnoBase+"' "
	cSQL += " AND BDH.BDH_STATUS = '0' "
	cSQL += " AND BDH.D_E_L_E_T_ = ' ' "
	          
	cSQL += " AND BAU.BAU_FILIAL = '"+xFilial("BAU")+"' "
	cSQL += " AND BAU.BAU_CODIGO = BD6.BD6_CODRDA "
	cSQL += " AND BAU.BAU_CODSA2 BETWEEN '"+cFornecDe+"' AND '"+cFornecAte+"' "
	cSQL += " AND BAU.D_E_L_E_T_ = ' ' "
	          
	cSQL += " AND BR8.BR8_FILIAL = '"+xFilial("BR8")+"' "
	cSQL += " AND BR8.BR8_CODPAD = BD6.BD6_CODPAD "
	cSQL += " AND BR8.BR8_CODPSA = BD6.BD6_CODPRO "
	cSQL += " AND BR8.BR8_CLASSE <> '      ' "
	cSQL += " AND BR8.D_E_L_E_T_ = ' ' "
	//��������������������������������������������������������������������������Ŀ
	//� Classe																	 �
	//����������������������������������������������������������������������������
	If nI == 1
		cSQL += " ORDER BY BR8.BR8_CLASSE "
	Else	
	    Do Case
	       Case nTipo == 1
		        cSQL += " ORDER BY BAU.BAU_CODSA2,BR8.BR8_CLASSE,BD6.BD6_DATPRO "
	       Case nTipo == 2 .And. nForma == 1
		        cSQL += " ORDER BY BAU.BAU_CODSA2,BR8.BR8_CLASSE,BD6.BD6_LOCAL,BD6.BD6_DATPRO "
	       Case nTipo == 3 .And. nForma == 1
		        cSQL += " ORDER BY BAU.BAU_CODSA2,BR8.BR8_CLASSE,BD6.BD6_INTERC,BD6.BD6_CODEMP,BD6.BD6_DATPRO "
	       Case nTipo == 4 .And. nForma == 1
		        cSQL += " ORDER BY BAU.BAU_CODSA2,BR8.BR8_CLASSE,BD6.BD6_CODPAD,BD6.BD6_CODPRO,BD6.BD6_DATPRO "
	       Case nTipo == 5 .And. nForma == 1
		        cSQL += " ORDER BY BAU.BAU_CODSA2,BR8.BR8_CLASSE,BD6.BD6_CODESP,BD6.BD6_DATPRO "
	       Case nTipo == 2 .And. nForma == 2
		        cSQL += " ORDER BY BD6.BD6_LOCAL,BR8.BR8_CLASSE,BD6.BD6_DATPRO "
	       Case nTipo == 3 .And. nForma == 2
		        cSQL += " ORDER BY BD6.BD6_CODEMP,BD6.BD6_INTERC,BR8.BR8_CLASSE,BD6.BD6_DATPRO "
	       Case nTipo == 4 .And. nForma == 2
		        cSQL += " ORDER BY BD6.BD6_CODPAD,BD6.BD6_CODPRO,BR8.BR8_CLASSE,BD6.BD6_DATPRO "
	       Case nTipo == 5 .And. nForma == 2
		        cSQL += " ORDER BY BD6.BD6_CODESP,BR8.BR8_CLASSE,BD6.BD6_DATPRO "
		EndCase        
	EndIf	
	//��������������������������������������������������������������������������Ŀ
	//� Processa																 �
	//����������������������������������������������������������������������������
	PLSQuery(cSQL,"TRB")   
	//��������������������������������������������������������������������������Ŀ
	//� Checa se tem registro													 �
	//����������������������������������������������������������������������������
	If TRB->( Eof() )
	   TRB->(DbCloseArea())
	   Return(.F.)
	EndIf                              
	//��������������������������������������������������������������������������Ŀ
	//� Primeiro																 �
	//����������������������������������������������������������������������������
	TRB->( DbGotop() )                                                          
	//��������������������������������������������������������������������������Ŀ
	//� Matriz cabecalho x classe												 �
	//����������������������������������������������������������������������������
	If nI == 1
		AaDd(aCabClass,{"------",STR0019,0,0,0} )
		While !TRB->( Eof() ) 
		   AaDd(aCabClass,{TRB->BR8_CLASSE,Left(Posicione("BJE",1,xFilial("BJE")+TRB->BR8_CLASSE,"BJE_DESCRI"),5),0,0,0} )
		TRB->( DbSkip() )
		EndDo
		AaDd(aCabClass,{"------",STR0017,0,0,0} )
		AaDd(aCabClass,{"------",STR0020,0,0,0} )
		TRB->( DbCloseArea() )
	EndIf	
Next	
//��������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                            �
//����������������������������������������������������������������������������
Return(.T.)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � RTRBImp	 � Autor � Alexander Santos      � Data � 18.04.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime detalhe do relatorio...                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function RTRBImp()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL nI                     
LOCAL cSql
LOCAL cCodFor  	:= TRB->(BAU_CODSA2+BAU_LOJSA2)
LOCAL cLocal  	:= TRB->BD6_LOCAL
LOCAL cCodOpe  	:= TRB->BD6_CODOPE                        
LOCAL cCodEmp  	:= Iif(TRB->BD6_INTERC == '1',TRB->BD6_CODEMP,'9999999999') 
LOCAL cCodPro  	:= TRB->(BD6_CODPAD+BD6_CODPRO)
LOCAL cCodEsp  	:= TRB->BD6_CODESP
LOCAL nVlrFil  	:= 0           
LOCAL cValores 	:= ""  
LOCAL lPrimeira	:= .T.
LOCAL lEntra	:= .F.
//��������������������������������������������������������������������������Ŀ
//� Inicio da impressao dos detalhes...                                      �
//����������������������������������������������������������������������������
While !TRB->( Eof() ) 
 	//��������������������������������������������������������������������Ŀ
    //� Imprimir														   �
    //����������������������������������������������������������������������
    If !lAutoSt
		MsProcTXT(STR0007+" "+STR0009+" "+TRB->BAU_CODSA2)
		ProcessMessage()
	endIf
    //��������������������������������������������������������������������������Ŀ
    //� Imprime cabecalho...                                                     �
    //����������������������������������������������������������������������������
    If nLi > nQtdLin .Or. nLi == 1
       RTRBCabec(nTipo,nForma)
    Endif                                                     
	//��������������������������������������������������������������������������Ŀ
	//� Para fornecedor (analitico e sintetico outros tipos)					 �
	//����������������������������������������������������������������������������
    Do Case
       Case nForma == 1 .And. nTipo <> 1                    
            lEntra := .T.
       Case nForma == 2 .And. nTipo == 1                    
            lEntra := .T.
       Case nForma == 2 .And. nTipo <> 1                    
            lEntra := .F.
    EndCase
	//��������������������������������������������������������������������������Ŀ
	//� Se e fornecedor mudar	  											     �
	//����������������������������������������������������������������������������
	If ( cCodFor <> TRB->(BAU_CODSA2+BAU_LOJSA2) .And. lEntra) .Or.;
	   ( cLocal <> TRB->BD6_LOCAL .And. nTipo == 2) .Or.;
	   ( cCodEmp <> TRB->BD6_CODEMP .And. nTipo == 3) .Or.;
	   ( cCodPro <> TRB->(BD6_CODPAD+BD6_CODPRO) .And. nTipo == 4) .Or.;
	   ( cCodEsp <> TRB->BD6_CODESP .And. nTipo == 5) 
	    //����������������������������������������������������������������Ŀ
		//� Mostra novo fornecedor										   �
		//������������������������������������������������������������������        
		If nTipo <> 1 .And. lPrimeira .And. nForma == 1
		   @ ++nLi,nColuna	 pSay objCENFUNLGP:verCamNPR("A2_NOME", Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME"))
		   nLi++
		   lPrimeira := .F.
		EndIf
	    //��������������������������������������������������������������������������Ŀ
	    //� Imprime cabecalho...                                                     �
	    //����������������������������������������������������������������������������
	    If nLi > nQtdLin .Or. nLi == 1
	       RTRBCabec(nTipo,nForma)
	    Endif                                                     
	    //����������������������������������������������������������������Ŀ
		//� Imprime														   �
		//������������������������������������������������������������������        
	    ImpVal(nTipo,cCodFor,cCodOpe,cLocal,cCodEmp,cCodPro,cCodEsp)
	    //��������������������������������������������������������������������������Ŀ
	    //� Imprime cabecalho...                                                     �
	    //����������������������������������������������������������������������������
	    If nLi > nQtdLin .Or. nLi == 1
	       RTRBCabec(nTipo,nForma)
	    Endif                                                     
  	    //����������������������������������������������������������������Ŀ
		//� Imprime	Total												   �
		//������������������������������������������������������������������        
		If cCodFor <> TRB->(BAU_CODSA2+BAU_LOJSA2) .And. nTipo <> 1 .And. nForma == 1
		   ImpForTot(.T.,TRB->(BAU_CODSA2+BAU_LOJSA2),4)
		EndIf   
	    //��������������������������������������������������������������������������Ŀ
	    //� Imprime cabecalho...                                                     �
	    //����������������������������������������������������������������������������
	    If nLi > nQtdLin .Or. nLi == 1
	       RTRBCabec(nTipo,nForma)
	    Endif                                                     
	    //����������������������������������������������������������������Ŀ
	   	//� Atuliza variaveis											   �
	    //������������������������������������������������������������������        
		cCodFor := TRB->(BAU_CODSA2+BAU_LOJSA2)
		cLocal := TRB->BD6_LOCAL
		cCodOpe := TRB->BD6_CODOPE                        
		cCodEmp := Iif(TRB->BD6_INTERC == '1',TRB->BD6_CODEMP,'9999999999') 
		cCodPro := TRB->(BD6_CODPAD+BD6_CODPRO) 
		cCodEsp := TRB->BD6_CODESP
	EndIf
	//��������������������������������������������������������������������������Ŀ
	//� Acumula valores															 �
	//����������������������������������������������������������������������������
    nPos := aScan( aCabClass,{|x|x[1] == TRB->BR8_CLASSE} )                 
    If nPos >= 1
	   //��������������������������������������������������������������������������Ŀ
	   //� Vai no BD7 correspondente e pega o valor do filme						�
	   //����������������������������������������������������������������������������
       BD7->( DbSetOrder(1) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
       If BD7->( MsSeek(xFilial('BD7')+TRB->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+STR0018) ) )
		  //��������������������������������������������������������������������������Ŀ
		  //� Pega valor do filme													   �
		  //����������������������������������������������������������������������������
          nVlrFil := BD7->BD7_VLRPAG                 
		  //��������������������������������������������������������������������������Ŀ
		  //� Alimenta o valor do filme												   �
		  //����������������������������������������������������������������������������
          aCabClass[Len(aCabClass)-1,3] += nVlrFil
       Else 
          nVlrFil := 0   
       EndIf
	   //����������������������������������������������������������������Ŀ
	   //� Valor da Guia											      �
	   //������������������������������������������������������������������        
	   aCabClass[Len(aCabClass),3] += TRB->BD6_VLRPAG
	   //����������������������������������������������������������������Ŀ
	   //� Qtd Atendimento												  �
	   //������������������������������������������������������������������        
	   aCabClass[1,3]++
	   //��������������������������������������������������������������������������Ŀ
	   //� Atualiza matriz															�
	   //����������������������������������������������������������������������������
       aCabClass[nPos,3] += TRB->BD6_VLRPAG - nVlrFil
    Else
       MsgStop(STR0014)
       Return
    EndIf

	TRB->( DbSkip() )
EndDo          
//����������������������������������������������������������������Ŀ
//� Imprime														   �
//������������������������������������������������������������������        
ImpVal(nTipo,cCodFor,cCodOpe,cLocal,cCodEmp,cCodPro,cCodEsp)
//����������������������������������������������������������������Ŀ
//� Imprime	Total												   �
//������������������������������������������������������������������        
ImpForTot(.F.,cCodFor,4)
//����������������������������������������������������������������Ŀ
//� Imprime	Total Geral	somente para o analitico    			   �
//������������������������������������������������������������������        
If nForma == 1
	ImpForTot(.F.,cCodFor,5)
EndIf	
//��������������������������������������������������������������������Ŀ
//� Imprime rodape do relatorio...                                     �
//����������������������������������������������������������������������
Roda(0,space(10),cTamanho)
//��������������������������������������������������������������������Ŀ
//� Fecha arquivo...                                                   �
//����������������������������������������������������������������������
TRB->( DbCloseArea() )
//��������������������������������������������������������������������Ŀ
//� Libera															   �
//����������������������������������������������������������������������
If !lAutoSt .AND. aReturn[5] == 1 
   Set Printer To
   Ourspool(cRel)
End                      
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � ImpVal    � Autor � Alexander Santos     � Data � 18.04.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime Valores                                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function ImpVal(nTipo,cCodFor,cCodOpe,cLocal,cCodEmp,cCodPro,cCodEsp)

LOCAL cDescri
LOCAL cValores := "  "
LOCAL nI                
//����������������������������������������������������������������Ŀ
//� Descricao do Tipo											   �
//������������������������������������������������������������������      
Do Case
   Case nTipo == 1
   		cDescri := objCENFUNLGP:verCamNPR("A2_NOME", Left(Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME"),30))
   Case nTipo == 2
   		cDescri := objCENFUNLGP:verCamNPR("BD1_DESLOC", Left(Posicione("BD1",1,xFilial("BD1")+cCodOpe+cLocal,"BD1_DESLOC"),30))
   Case nTipo == 3                              
        If cCodEmp == '9999999999'
   		   cDescri := AllTrim(FWFilialName(FWGrpCompany(),FWCodFil(),2))
	   	Else 
   		   cDescri := objCENFUNLGP:verCamNPR("BG9_NREDUZ", Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_NREDUZ"))+Space(10)
	   	EndIf	
   Case nTipo == 4
   		cDescri := objCENFUNLGP:verCamNPR("BR8_DESCRI", Left(Posicione("BR8",1,xFilial("BR8")+cCodPro,"BR8_DESCRI"),30))
   Case nTipo == 5
   		cDescri := objCENFUNLGP:verCamNPR("BAQ_DESCRI", Left(Posicione("BAQ",1,xFilial("BAQ")+cCodOpe+cCodEsp,"BAQ_DESCRI"),30))
EndCase   
//����������������������������������������������������������������Ŀ
//� Valores														   �
//������������������������������������������������������������������        
For nI := 1 To Len(aCabClass)
	//��������������������������������������������������������������������������Ŀ
	//� Totais																     �
	//����������������������������������������������������������������������������
	aCabClass[nI,4] += aCabClass[nI,3]
	aCabClass[nI,5] += aCabClass[nI,4]
    //����������������������������������������������������������������Ŀ
	//� Valor a ser mostrado										   �
	//������������������������������������������������������������������        
    cValores += Iif(nI==1,StrZero(aCabClass[nI,3],6),TransForm( aCabClass[nI,3],pMoeda1 ) ) + Iif(nI==1,Space(6),Space(3))
    //����������������������������������������������������������������Ŀ
	//� Zera Valor da matriz										   �
	//������������������������������������������������������������������        
    aCabClass[nI,3] := 0
Next			        	  
//����������������������������������������������������������������Ŀ
//� Mostra Valores												   �
//������������������������������������������������������������������        
@ ++nLi,nColuna	 pSay cDescri + Space(3) + cValores
//����������������������������������������������������������������Ŀ
//� Retorno da Funcao											   �
//������������������������������������������������������������������        
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � ImpForTot � Autor � Alexander Santos     � Data � 18.04.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime Cabecalho                                          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function ImpForTot(lMosFor,cCodFor,nPosi)      

LOCAL nI
LOCAL cValores := "  "
//����������������������������������������������������������������Ŀ
//� Valores														   �
//������������������������������������������������������������������        
For nI := 1 To Len(aCabClass)
    //����������������������������������������������������������������Ŀ
	//� Valor a ser mostrado										   �
	//������������������������������������������������������������������        
    cValores += Iif(nI==1,StrZero(aCabClass[nI,nPosi],6),TransForm( aCabClass[nI,nPosi],pMoeda1 ) ) + Iif(nI==1,Space(6),Space(3))
    //����������������������������������������������������������������Ŀ
	//� Zera Valor da matriz										   �
	//������������������������������������������������������������������        
    aCabClass[nI,nPosi] := 0
Next			        	                                      
//����������������������������������������������������������������Ŀ
//� Proxima Linha												   �
//������������������������������������������������������������������
nLi++
//����������������������������������������������������������������Ŀ
//� Mostra totais												   �
//������������������������������������������������������������������
If nPosi == 4
	@ ++nLi,nColuna	 pSay STR0021 + Space(30-Len(STR0021) ) + Space(3) + cValores
Else 
	@ ++nLi,nColuna	 pSay STR0024 + Space(30-Len(STR0024) ) + Space(3) + cValores
EndIf	     
//����������������������������������������������������������������Ŀ
//� Somente para totais parciais								   �
//������������������������������������������������������������������
If nPosi == 4
	//����������������������������������������������������������������Ŀ
	//� Proxima Linha												   �
	//������������������������������������������������������������������
	nLi++
	//��������������������������������������������������������������������������Ŀ
	//� --------------															 �
	//����������������������������������������������������������������������������
	@ ++nLi,0 pSay Replicate('_',nLimite)
	//����������������������������������������������������������������Ŀ
	//� Mostra novo fornecedor										   �
	//������������������������������������������������������������������        
	If lMosFor .And. nForma == 1
	   @ ++nLi,nColuna	 pSay objCENFUNLGP:verCamNPR("A2_NOME", Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME"))
	   nLi++
	EndIf
EndIf	
//����������������������������������������������������������������Ŀ
//� Retorno da Funcao											   �
//������������������������������������������������������������������      
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � RTRBCabec � Autor � Alexander Santos     � Data � 18.04.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime Cabecalho                                          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function RTRBCabec(nTipo,nForma)      

LOCAL cDescri := ""
LOCAL cClasse := ""
LOCAL nI
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho...                                                     �
//����������������������������������������������������������������������������
nLi := Cabec(Iif(nForma==1,cTitulo,cTitulo+STR0023),cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
//��������������������������������������������������������������������������Ŀ
//� Monta linha cabecalho 1													 �
//����������������������������������������������������������������������������
If nTipo <> 1 .And. nForma <> 2 
   @ ++nLi,1 pSay  STR0009
EndIf
//����������������������������������������������������������������Ŀ
//� Descricao do Tipo											   �
//������������������������������������������������������������������      
Do Case
   Case nTipo == 1
        cDescri := STR0009	
   Case nTipo == 2
        cDescri := STR0010	
   Case nTipo == 3
        cDescri := STR0011	 
   Case nTipo == 4
        cDescri := STR0025	 
   Case nTipo == 5
        cDescri := STR0026	 
EndCase   
//����������������������������������������������������������������Ŀ
//� Classes														   �
//������������������������������������������������������������������      
For nI := 1 To Len(aCabClass)
    cClasse += aCabClass[nI,2] + Space(7)
Next			        	  
//����������������������������������������������������������������Ŀ
//� Imprime														   �
//������������������������������������������������������������������      
@ ++nLi,1 pSay	cDescri + Space(30-Len(cDescri) ) + Space(2) + objCENFUNLGP:verCamNPR( "BJE_DESCRI", cClasse )
//��������������������������������������������������������������������������Ŀ
//� --------------															 �
//����������������������������������������������������������������������������
@ ++nLi,0 pSay Replicate('_',nLimite)
//��������������������������������������������������������������������������Ŀ
//� Incremento																 �
//����������������������������������������������������������������������������
nLi++
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return                                                                       
