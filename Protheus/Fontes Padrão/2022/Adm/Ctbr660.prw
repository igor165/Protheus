#Include "Ctbr660.Ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres
// 05/10/2011 -- Tradu��o coluna de Valor debito e valor credito para pais mexico 

//--------------------------------RELEASE 4--------------------------------//

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR660   �Autor  �Paulo Carnelossi    � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbr660()

CTBR660R4()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR660R4 �Autor  �Paulo Carnelossi    � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbr660R4()
Local aArea := GetArea()
Local cString		:= "CT2"
Local cTitulo 		:= STR0003	 	//"Quadratura contabil com Analise de Divergencias"

Private NomeProg := FunName()

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If !Pergunte("CTR660",.T.)
	Return
EndIf
//�����������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros						 	�
//� mv_par01				// Data Inicial                  	 	�
//� mv_par02				// Data Final                         	�
//� mv_par03				// Lote  Inicial                        �
//� mv_par04				// Lote  Final  						�
//� mv_par05				// Sub-Lote Inicial                  	�
//� mv_par06				// Sub-Lote Final  						�
//� mv_par07				// Documento Inicial                    �
//� mv_par08				// Documento Final			    		�
//� mv_par09				// Moeda?						     	�
//� mv_par10				// Conta? Normal/Reduzido 			    �
//� mv_par11				// Imprime Lcto? Real/Ger/Orc/Pre/Todos �
//� mv_par12				// Quebra Pagina? Sim/Nao		    	�
//� mv_par13				// Imprime Doc. em Branco? Sim/Nao	    �
//� mv_par14				// Tipo Relatorio? Analitico/Sintetico  �
//� mv_par15				// Apenas Divergentes? Sim/Nao          �
//� mv_par16				// Conta Contabil Inicial               �
//� mv_par17				// Conta Contabil Final                 �
//�������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef(cString, cTitulo)

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	

oReport:PrintDialog()

RestArea(aArea)
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR660R4 �Autor  �Paulo Carnelossi    � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
���          � Definicao das colunas do relatorio                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportDef( cString, cTitulo)
Local cPerg			:= "CTR660"
Local cDesc1 		:= STR0001		//"Este programa ira imprimir a Quadratura Contabil"
Local cDesc2 		:= STR0002	  	//"com Analise de Divergencias." 
Local cDesc3		:= ""

Local oReport
Local oQuadratura
Local aOrdem := {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

oReport := TReport():New("CTBR660",cTitulo, cPerg, ;
			{|oReport| ReportPrint(oReport, cString, cTitulo) },;
			cDesc1+CRLF+cDesc2+CRLF+cDesc3 )

oReport:SetLandScape()
oReport:SetTotalInLine(.F.)

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
//adiciona ordens do relatorio
oQuadratura := TRSection():New(oReport, "Quadratura", {  cSTring, "CT2", "CT1", "cArqTmp" }, aOrdem /*{}*/, .F., .F.)  //"Comparativo de Conta"
TRCell():New(oQuadratura,"CLN_DATA"				,""	,STR0052 /*"DATA"*/		,/*Picture*/,8/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)  
TRCell():New(oQuadratura,"CLN_SUBLOTE"			,""	,STR0053 /*"SUBLOTE"*/		,/*Picture*/,10/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oQuadratura,"CLN_DOC"				,""	,STR0054 /*"DOC"*/			,/*Picture*/,9/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oQuadratura,"CLN_CONTA"			,""	,STR0055 /*"CONTA"*/		,/*Picture*/,40/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oQuadratura,"CLN_DOCFISCAL"		,""	,STR0056 /*"DOC. FISCAL"*/  ,/*Picture*/,30/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oQuadratura,"CLN_VLRDEBITO"		,""	,STR0057 /*"VALOR DEB"*/	,/*Picture*/,21/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")
TRCell():New(oQuadratura,"CLN_VLRCREDIT"		,""	,STR0058 /*"VALOR CRED"*/	,/*Picture*/,21/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")
TRCell():New(oQuadratura,"CLN_HP"				,""	,STR0059 /*"HP"*/			,/*Picture*/,5/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oQuadratura,"CLN_HISTORICO"		,""	,STR0060 /*"HISTORICO"*/	,/*Picture*/,50/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
oQuadratura:Cell("CLN_HISTORICO"):SetLineBreak()
oQuadratura:SetHeaderPage()

If cPaisLoc == "CHI"
	TRCell():New(oQuadratura,"CLN_CORRELATO"		,""	,STR0061/*"CORRELATIVO"*/,/*Picture*/,20/*Tamanho*/	,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	oQuadratura:Cell("CLN_CORRELATO"):SetLineBreak()
EndIf   

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor �Paulo Carnelossi   � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construcao Release 4                                       ���
���          � Funcao de impressao do relatorio acionado pela execucao    ���
���          � do botao <OK> da PrintDialog()                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport, cString, cTitulo)

Local oQuadratura	:= oReport:Section(1)
Local oBreak
Local oTotCal_01, oTotCal_02, oTotImp_01, oTotImp_02, oTotImp_03
Local oTotGer_01, oTotGer_02, oTotGer_03
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

Local aCtbMoeda	:= {}
Local aColunas 
Local aSetOfBook	:= {"","",0,"","","","","",1,""}
Local aGruposCTB    := {}
//Contem os alias com suas respectivas chaves de agrupamento. Uma chave de agrupamento 
//eh um conjunto de campos que distiguem determinado documento fiscal. Eh usada para a 
//aglutinacao dos lancamentos por documento. Eh configurada no proprio relatorio e 
//deve estar contida no CTL_KEY do lancamento correspondente
//������������������������������������������������Ŀ
//�  ****** Descric�o do Array aGruposCTB *******  �
//������������������������������������������������Ĵ
//� Dimensoes  � Descric�o						   �
//������������������������������������������������Ĵ
//� 	  1	   � Alias				               �
//� 	  2	   � Campo(s) de agrupamento(diferencia�
//� 	  	   � o documento fiscal)               �
//� 	  3	   � Tamanho do(s) campo(s) de agrup.  �
//� 	  4	   � Lancamentos para os quais serah   �
//� 	  	   � usada a chave de agrupamento(opc.)�
//��������������������������������������������������
Local aLPSE5MovBco  := {"560","561","562","563","564","565"} //Lancamentos do Mov. Bancario(Transferencia, Pagar e Receber) 
                                                              //referentes a tranferencia,
                                                              //pagar e receber
Local aLPSE1Bord    := {"548","554"}                         //Lancamentos referentes a Bordero
Local aLPSE5Comp    := {"588","589","596","597"}             //Lancamentos referentes a Compensacao
                                                              //de Titulos
Local aLPCompCart   := {"535","594"}                         //Lancamentos referentes a Compensacao
															  //entre Carteiras 

Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotSbLtDb	:= 0
Local nTotSbLtCr	:= 0
Local nPosFim       := 0
Local nX            := 0
Local nI            := 0
Local nPosAlias     := 0
Local nPosGrupo     := 0
Local nPosCpoKey    := 1
Local nPosSinal     := 0 
Local nPosLP        := 0

Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""
Local cDescMoeda	:= ""
Local cSaldo		:= mv_par11
Local cMoeda		:= mv_par09
Local cArqTmp		:= ""
Local cLoteIni		:= mv_par03
Local cLoteFim		:= mv_par04
Local cSbLoteIni	:= mv_par05
Local cSbLoteFim	:= mv_par06
Local cDocIni		:= mv_par07
Local cDocFim		:= mv_par08
Local cContaIni		:= mv_par16
Local cContaFim		:= mv_par17
Local cLote			:= ""
Local cSublote		:= ""
Local cDoc			:= ""
Local cPicture		:= ""
Local cLoteAnt		:= ""
Local cGrupo        := ""
Local cAliasCTL     := ""
Local cChaveCTL     := ""
Local cCT2Key       := ""
Local cTpOper       := ""

Local dDataIni		:= mv_par01
Local dDataFim		:= mv_par02
Local dData

Local lPrimPag		:= .T.                        
Local lQuebra		:= Iif(mv_par12 == 1,.T.,.F.)
Local lImpDoc0		:= Iif(mv_par13 == 1,.T.,.F.)
Local lAnalitico	:= Iif(mv_par14 == 1,.T.,.F.)
Local lDiverg		:= Iif(mv_par15 == 1,.T.,.F.)

Private aCposCTL    := {}
//Array com as informacoes referentes aos LPs e suas respectivas chaves de agrupamento
//(nome dos campos da chave, tamanho e posicao na string dos campos que formam a chave)
//������������������������������������������������Ŀ
//�  ******* Descric�o do Array aCposCTL *******   �
//������������������������������������������������Ĵ
//� Dimensoes  � Descric�o						   �
//������������������������������������������������Ĵ
//�    1	   �Alias				               �
//�    2	   �Chave de agrupamento(diferencia o  �
//� 	  	   �documento fiscal)                  �
//�    3       �Tamanho do(s) campo(s) da chave de �
//�            �agrupamento                        �
//�    4       �LP(s) correspondente(s) que usam   �
//�            �a chave de agrupamento             �
//�    5       �                                   �
//�    5,1     �Nome do(s) campo(a)que forma(m) a  �
//�            �chave                              �
//�    5,2     �Tamanho do(s) campo(s) que forma(m)�
//�            �a chave                            �
//�    5,3     �Posicao do conteudo do(s) campo(s) �
//�            �da chave no CT2_KEY                �
//��������������������������������������������������

Private aLP560       := {}
//Array, usado para a operacao de transferencia bancaria, que armazena as informacoes 
//de data, numero do documento de transferencia e valor do registro do banco origem.
//Com estes dados, permite aglutinar com o movimento de transferencia destino correspondente 
//������������������������������������������������Ŀ
//�  ******** Descric�o do Array aLP560 ********   �
//������������������������������������������������Ĵ
//� Dimensoes  � Descric�o						   �
//������������������������������������������������Ĵ
//� 	  1	   � Data do movimento bancario        �
//� 	  2	   � Numero do Documento da transferen-�
//� 	  	   � cia                               �
//� 	  3	   � Valor da transferencia bancaria   �
//� 	  4	   � Chave de agrupamento usada na     �
//� 	  	   � identificacao das operacoes       �
//��������������������������������������������������

Private aLPCompens       := {}
//Array, usado para a operacao de compensacao pagar/receber, que armazena as informacoes 
//do lancamento(data, lote, sub-lote e num. documento). Com estes dados, permite aglutinar 
//com o lancamento gerado pela compensacao do titulo principal
//������������������������������������������������Ŀ
//�  ****** Descric�o do Array aLPCompens ******   �
//������������������������������������������������Ĵ
//� Dimensoes  � Descric�o						   �
//������������������������������������������������Ĵ
//� 	  1	   � Data do lancamento contabil       �
//� 	  2	   � Numero do lote contabil           �
//� 	  3	   � Numero do sub-lote contabil       �
//� 	  4	   � Numero do documento contabil      �
//� 	  5	   � Chave do lancamento contabil      �
//��������������������������������������������������

//Forma de Agrupamento para a quebra por documento fiscal
If cPaisLoc != "BRA"
   Aadd(aGruposCTB,{"SEL","EL_RECIBO",TamSX3("EL_RECIBO")[1],{}})  

   Aadd(aGruposCTB,{"SEK","EK_ORDPAGO",TamSX3("EK_ORDPAGO")[1],{}})

   Aadd(aGruposCTB,{"SCM","CM_REMITO+CM_FORNECE+CM_LOJA",TamSX3("CM_REMITO")[1]+TamSX3("CM_FORNECE")[1]+;
                    TamSX3("CM_LOJA")[1],{}})  

   Aadd(aGruposCTB,{"SCN","CN_REMITO+CN_CLIENTE+CN_LOJA+CN_SERIE",TamSX3("CN_REMITO")[1]+TamSX3("CN_CLIENTE")[1]+;
                    TamSX3("CN_LOJA")[1]+TamSX3("CN_SERIE")[1],{}})  
EndIf

Aadd(aGruposCTB,{"SE1","E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO",TamSX3("E1_PREFIXO")[1]+;
     TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+TamSX3("E1_TIPO")[1],{}})
Aadd(aGruposCTB,{"SE1","E1_NUMBOR",TamSX3("E1_NUMBOR")[1], aLPSE1Bord})     

Aadd(aGruposCTB,{"SE2","E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA",TamSX3("E2_PREFIXO")[1]+;
     TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+;
     TamSX3("E2_LOJA")[1],{}})
     
Aadd(aGruposCTB,{"SE5","E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA",TamSX3("E5_PREFIXO")[1]+;
     TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1]+TamSX3("E5_TIPO")[1]+TamSX3("E5_CLIFOR")[1]+;
     TamSX3("E5_LOJA")[1],{}})     
Aadd(aGruposCTB,{"SE5","E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_DOCUMEN",TamSX3("E5_PREFIXO")[1]+;
     TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1]+TamSX3("E5_TIPO")[1]+TamSX3("E5_CLIFOR")[1]+;
     TamSX3("E5_LOJA")[1]+TamSX3("E5_SEQ")[1]+TamSX3("E5_DOCUMEN")[1], aLPSE5Comp})          
Aadd(aGruposCTB,{"SE5","DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ",TamSX3("E5_DATA")[1]+;
     TamSX3("E5_BANCO")[1]+TamSX3("E5_AGENCIA")[1]+TamSX3("E5_CONTA")[1]+TamSX3("E5_NUMCHEQ")[1], aLPSE5MovBco})          
Aadd(aGruposCTB,{"SE5","E5_IDENTEE",TamSX3("E5_IDENTEE")[1],aLPCompCart})     
    
Aadd(aGruposCTB,{"SD2","D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_TIPO",TamSX3("D2_DOC")[1]+;
     TamSX3("D2_SERIE")[1]+TamSX3("D2_CLIENTE")[1]+TamSX3("D2_LOJA")[1]+TamSX3("D2_TIPO")[1],{}})
     
Aadd(aGruposCTB,{"SF2","F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE",TamSX3("F2_CLIENTE")[1]+;
     TamSX3("F2_LOJA")[1]+TamSX3("F2_DOC")[1]+TamSX3("F2_SERIE")[1]+TamSX3("F2_TIPO")[1]+;
     TamSX3("F2_ESPECIE")[1],{}})
     
Aadd(aGruposCTB,{"SD1","D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO",TamSX3("D1_DOC")[1]+;
     TamSX3("D1_SERIE")[1]+TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1]+TamSX3("D1_TIPO")[1],{}})     
     
Aadd(aGruposCTB,{"SF1","F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO+F1_ESPECIE",TamSX3("F1_DOC")[1]+;
     TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+TamSX3("F1_LOJA")[1]+TamSX3("F1_TIPO")[1]+;
     TamSX3("F1_ESPECIE")[1],{}})

DbSelectArea("CTL")
DbSetOrder(1)
DbSeek(xFilial("CTL"),.T.)
While !Eof()                                                          
   nPosLP     := Ascan(aGruposCTB,{|x| Ascan(x[4],CTL->CTL_LP) > 0 })
   If nPosLP == 0
      nPosGrupo  := Ascan(aGruposCTB,{|x| x[1] == CTL->CTL_ALIAS })
   Else 
      nPosGrupo  := nPosLP
   EndIf   
   If nPosGrupo > 0
      //Implementacao para os casos em que a chave do grupo eh a mesma para um determinado alias 
      //Busca primeiro pelo LP
      nPosLP     := Ascan(aCposCTL,{|x| Ascan(x[4],CTL->CTL_LP) > 0 })
      //Se nao encontrar o LP, busca pelo alias. Caso tenha definido o(s) LP(s) no array
      //aGruposCTB nao verifica o alias
      If nPosLP == 0 .And. Len(aGruposCTB[nPosGrupo][4]) == 0
         nPosAlias  := Ascan(aCposCTL,{|x| x[1] == CTL->CTL_ALIAS .And. Empty(x[4])})
      Else
         nPosAlias  := nPosLP      
      EndIf   
      If nPosAlias == 0
         nPosCpoKey  := 1
         cChaveCTL   := AllTrim(CTL->CTL_KEY)
         Aadd(aCposCTL,{CTL->CTL_ALIAS,aGruposCTB[nPosGrupo][2],aGruposCTB[nPosGrupo][3],;
              aGruposCTB[nPosGrupo][4],{}})   
         nI  := 1
         nX++
         //Armazena na posicao 5 do array aCposCTL os campos da chave de agrupamento com 
         //seu respectivo tamanho(X3_TAMANHO) e posicao na string(CTL_KEY)
         While nI < Len(AllTrim(CTL->CTL_KEY))
            nPosFim  := At('+',cChaveCTL)
            If nPosFim == 0
               nPosFim  := Len(cChaveCTL)+1  //Ultimo campo da chave
            EndIf      
            cCampo   := Substr(cChaveCTL,1,nPosFim-1)
            //Tratamento para campo data na chave 
            If Substr(cCampo,1,4) == "DTOS"
               nPosSinal  := At(')',cCampo)
               cCampo     := Substr(cCampo,6,nPosSinal-6)
            EndIf
            Aadd(aCposCTL[nX][5],{cCampo,TamSX3(cCampo)[1],nPosCpoKey})
            nPosCpoKey  += TamSX3(cCampo)[1]
            cChaveCTL   := Substr(cChaveCTL,nPosFim+1)         
            nI          += nPosFim
         End                         
      EndIf
   EndIf
   DbSkip()
End

aCtbMoeda  	:= CtbMoeda(mv_par09)
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
	oReport:CancelPrint()
	Return
Endif

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

cTitulo 		+= 	STR0021+cDescMoeda + STR0022 + DTOC(dDataIni) +;	// "EM"/DE"
				STR0023 + DTOC(dDataFim) + CtbTitSaldo(mv_par11)	// "ATE"

oReport:SetPageNumber(1)
oReport:SetTitle(cTitulo)

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao   					 �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTBR420Raz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,;
			cMoeda,dDataIni,dDataFim,aSetOfBook,.F.,cSaldo,"5",lAnalitico,cLoteIni,cLoteFim,;
			cSbLoteIni,cSbLoteFim,cDocIni,cDocFim)},;
			STR0008,;		// "Criando Arquivo Tempor�rio..."
			STR0007)		// "Emissao do Relatorio de Quadratura Contabil"


dbSelectArea("cArqTmp")
oReport:SetMeter(RecCount())
dbGoTop()

lQuebra	  := Iif(mv_par12 == 1,.T.,.F.)
oBreak := TRBreak():New(oReport, { || cGrupo }, {|| If(lAnalitico, STR0020, Substr(cGrupo,1,34)+ " - " + Ctbr660TpDoc(cAliasCTL,cCT2Key,cTpOper) ) })
oBreak:OnBreak( { || nTotGerDeb	+= oTotCal_01:GetValue(), nTotGerCrd += oTotCal_02:GetValue() })

If lQuebra
	oBreak:SetPageBreak(.T.)
EndIf

//criacao dos totalizadores 
oTotCal_01 := TRFunction():New(oQuadratura:Cell("CLN_VLRDEBITO"),"Deb.(01)","SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotCal_02 := TRFunction():New(oQuadratura:Cell("CLN_VLRCREDIT"),"Crd.(02)","SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotCal_01:Disable()
oTotCal_02:Disable()

oTotImp_01 := TRFunction():New(oQuadratura:Cell("CLN_VLRDEBITO"),"Deb.(01)","ONPRINT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotImp_02 := TRFunction():New(oQuadratura:Cell("CLN_VLRCREDIT"),"Crd.(02)","ONPRINT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotImp_03 := TRFunction():New(oQuadratura:Cell("CLN_HISTORICO"),"Div.(02)","ONPRINT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

oTotGer_01 := TRFunction():New(oQuadratura:Cell("CLN_VLRDEBITO"),"Deb.(01)","ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oTotGer_02 := TRFunction():New(oQuadratura:Cell("CLN_VLRCREDIT"),"Crd.(02)","ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oTotGer_03 := TRFunction():New(oQuadratura:Cell("CLN_HISTORICO"),"Div.(02)","ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

//setar as formulas para trfunction
oTotCal_01:SetFormula({|| cArqTmp->LANCDEB })
oTotCal_02:SetFormula({|| cArqTmp->LANCCRD })

oTotImp_01:SetFormula({||ValorCTB(oTotCal_01:GetValue(),,,21,2,.F.,cPicture,, , , , , , ,.F./*lSay*/)})
oTotImp_02:SetFormula({||ValorCTB(oTotCal_02:GetValue(),,,21,2,.F.,cPicture,, , , , , , ,.F./*lSay*/)})
oTotImp_03:SetFormula({||If(lAnalitico, STR0025+ " " , "")+ ValorCTB(Abs(oTotCal_02:GetValue()-oTotCal_01:GetValue()),,,21,2,.F.,cPicture,, , , , , , ,.F./*lSay*/)})

oTotGer_01:SetFormula({||ValorCTB(nTotGerDeb,,,21,2,.F.,cPicture,, , , , , , ,.F./*lSay*/)})
oTotGer_02:SetFormula({||ValorCTB(nTotGerCrd,,,21,2,.F.,cPicture,, , , , , , ,.F./*lSay*/)})
oTotGer_03:SetFormula({||If(lAnalitico, STR0025+ " " , "")+ ValorCTB(Abs(nTotGerCrd-nTotGerDeb ),,,21,2,.F.,cPicture,, , , , , , ,.F./*lSay*/)})

oReport:SetTotalText(STR0014)   //"T O T A L  G E R A L ==> "		

oQuadratura:Cell("CLN_DATA")		:SetBlock( {|| dData } )
oQuadratura:Cell("CLN_SUBLOTE")		:SetBlock( {|| cSubLote } )
oQuadratura:Cell("CLN_DOC")			:SetBlock( {|| cDoc } )
oQuadratura:Cell("CLN_CONTA")		:SetBlock( {|| If(mv_par10 == 2, CT1->CT1_RES, cArqTmp->CONTA) } )
oQuadratura:Cell("CLN_DOCFISCAL")	:SetBlock( {|| Subs(cArqTmp->CT2KEY,1,33) } )
oQuadratura:Cell("CLN_VLRDEBITO")	:SetBlock( {|| ValorCTB(cArqTmp->LANCDEB, , , 021,2,.F.,cPicture,, , , , , ,,.F./*lSay*/) } )
oQuadratura:Cell("CLN_VLRCREDIT")	:SetBlock( {|| ValorCTB(cArqTmp->LANCCRD, , , 021,2,.F.,cPicture,, , , , , ,,.F./*lSay*/) } )
oQuadratura:Cell("CLN_HP")			:SetBlock( {|| cArqTmp->HP } )
oQuadratura:Cell("CLN_HISTORICO")	:SetBlock( {|| cArqTmp->HISTORICO } )

If cPaisLoc == "CHI"
	oQuadratura:Cell("CLN_CORRELATO")	:SetBlock( {|| cArqTmp->CORRELATO } )
EndIf   

oQuadratura:Init()

cGrupo 	:= cArqTmp->GRUPO

While !Eof()

	lFirst:= .T.

	IF oReport:Cancel()
		Exit
	EndIF                                         
	
	If !lImpDoc0 .And. Empty(cArqTmp->CT2KEY) 
		dbSkip()
		Loop
	Endif	

	oReport:IncMeter()
	
	cGrupo 	:= cArqTmp->GRUPO   

	//Verificacao se credito x debito sao divergentes
	If lDiverg
	   //Se nao forem divergentes, deve posicionar no proximo grupo 
	   While !Eof() .And. !Ctbr660Diverg(cGrupo)
	      While !Eof() .And. cArqTmp->GRUPO == cGrupo         	            
	         DbSkip()
	      End
	      cGrupo 	:= cArqTmp->GRUPO
	   End
	EndIf

	While !Eof() .And. 	cArqTmp->GRUPO == cGrupo
	    
	    cSubLote    := cArqTmp->SUBLOTE
		cLote 		:= cArqTmp->LOTE
		cDoc		:= cArqTmp->DOC
		dData 		:= cArqTmp->DATAL
		cGrupo      := cArqTmp->GRUPO
		cAliasCTL   := cArqTmp->ALIAS
	
		oReport:IncMeter()
					
		If lFirst       
		   If lAnalitico
		      oReport:ThinLine()
		      oReport:PrintText(OemToAnsi(STR0018) + cLote, oReport:Row(), 10)  // "LOTE: "		   		   
		      oReport:PrintText(OemToAnsi(STR0027) + Ctbr660TpDoc(cAliasCTL,cArqTmp->CT2KEY,cArqTmp->OPERACAO), oReport:Row(), 300)  // "Tipo do Documento: "
			  oReport:SkipLine()
			  oReport:ThinLine()
		   EndIf	  
		   lFirst := .F.
		ElseIf cLoteAnt <> cArqTmp->LOTE
           oReport:SkipLine()
		   oReport:PrintText(OemToAnsi(STR0018) + cLote, oReport:Row(), 10)  // "LOTE: "		   		   
           oReport:SkipLine()
           oReport:ThinLine()
		EndIf

		If lAnalitico

		   If mv_par10 == 2
			  dbSelectArea("CT1")
			  dbSetOrder(1)
			  MsSeek(xFilial()+cArqTmp->CONTA)
		   Endif			
		   oQuadratura:PrintLine()

		Else

		   oQuadratura:Disable()
		   oQuadratura:PrintLine()

        EndIf

		dbSelectarea("cArqTmp")	
		cLoteAnt	:= cArqTmp->LOTE
		cCT2Key     := cArqTmp->CT2KEY
		cTpOper     := cArqTmp->OPERACAO
		dbSkip()				   

	Enddo     

EndDo    

oQuadratura:Finish()

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()

If Select("cArqTmp") == 0
   FErase(cArqTmp+GetDBExtension())
   FErase(cArqTmp+OrdBagExt())
EndIf	

dbselectArea("CT2")

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Ctbr660TpD� Autor � Fernando Machima      � Data � 07.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca o Tipo de operacao de forma a identificar ao usuario ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctr660TpDoc(cAliasCTL,cCT2Key,cTpOper)                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Tipo de Operacao/Documento                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAliasCTL       - Alias do arquivo                         ���
���          � cCT2Key         - Chave de agrupamento                     ���
���          � cTpOper         - Descricao da operacao                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ctbr660TpDoc(cAliasCTL,cCT2Key,cTpOper)

Local cTipoDoc    := cTpOper
Local cCpoEspecie := ""
Local cFilter     := ""
Local nPosEspecie := 0  
Local nPosEspCTL  := 0
Local nPosAlias   := 0
Local aArea       := GetArea()

If Empty(cTipoDoc)
    //Para os alias relacionados abaixo verificar a especie do documento(NF, NCC, NDP, etc.) 
	If cAliasCTL $ "SD1|SD2|SF1|SF2"
		cCpoEspecie  := Substr(cAliasCTL,2,2)+"_ESPECIE"
		nPosAlias    := Ascan(aCposCTL,{|x| x[1] == cAliasCTL })
		If nPosAlias > 0
			nPosEspCTL  := Ascan(aCposCTL[nPosAlias][5],{|x| x[1] == cCpoEspecie })
			If nPosEspCTL > 0
				//Busca a posicao de gravacao do campo_ESPECIE no CT2_KEY
				nPosEspecie  := aCposCTL[nPosAlias][5][nPosEspCTL][3]
			EndIf
		End
		If nPosEspecie > 0
			//Busca o conteudo do campo _ESPECIE no CT2_KEY
			cEspecie  := AllTrim(Substr(cCT2Key,nPosEspecie,TamSX3("F2_ESPECIE")[1]))
			Do Case
				Case cEspecie == "NF"
					If cAliasCTL $ "SD1|SF1"
						cTipoDoc  := STR0029          //"Nota Fiscal de Entrada"
					ElseIf cAliasCTL $ "SD2|SF2"
						cTipoDoc  := STR0030          //"Nota Fiscal de Saida"
					EndIf
				Case cEspecie $ "NCC|NCE"
					cTipoDoc  := STR0031             //"Nota de Credito do Cliente"
				Case cEspecie $ "NDC|NDE"
					cTipoDoc  := STR0032             //"Nota de Debito do Cliente"
				Case cEspecie $ "NCP|NCI"
					cTipoDoc  := STR0033             //"Nota de Credito do Fornecedor"
				Case cEspecie $ "NDP|NDI"
					cTipoDoc  := STR0034             //"Nota de Debito do Fornecedor"
				Case Substr(cEspecie,1,2) == "RF"
					cTipoDoc  := GetDescRem()+ STR0049  //" de Saida"					      
				Case Substr(cEspecie,1,2) == "RC"
					cTipoDoc  := GetDescRem()+ STR0050  //" de Entrada"										  
				Case Substr(cEspecie,1,2) == "RT"
					cTipoDoc  := GetDescRem()+ STR0051  //" de Transferencia"															                
				OtherWise
					cTipoDoc  := "xxxxxxxxxx"
			EndCase
		Else
			cTipoDoc  := "xxxxxxxxxx"
		EndIf
	//Para os demais alias, verificar o nome do arquivo configurado no SX2	
	Else
	    DbSelectArea("SX2")
	    //Desabilitar o filtro para encontrar o alias do arquivo no SX2
        cFilter  := DbFilter()
        Set Filter To
        DbSetOrder(1)
		If DbSeek(cAliasCTL)
			cTipoDoc  := AllTrim(Capital(X2Nome()))
		Else
			cTipoDoc  := "xxxxxxxxxx"
		EndIf
		//Habilitar o filtro 
        Set Filter To &cFilter		
	EndIf
EndIf

RestArea(aArea)
                 
Return (cTipoDoc)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Ctbr660Div� Autor � Fernando Machima      � Data � 07.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o credito e debito do documento fiscal sao     ���
���          � divergentes                                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbr660Diverg()                                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � CreditoxDebito divergente                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cGrupo - Numero do documento para agrupamento               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ctbr660Diverg(cGrupo)

Local lRet   := .F.
Local aArea  := GetArea()
Local nTotalDeb := 0
Local nTotalCrd := 0

While !Eof() .And. 	cArqTmp->GRUPO == cGrupo

   nTotalDeb += cArqTmp->LANCDEB
   nTotalCrd += cArqTmp->LANCCRD				
   
   DbSkip()   
End
lRet  := (nTotalDeb != nTotalCrd)

RestArea(aArea)

Return (lRet)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ctbr660Gru� Autor � Fernando Machima      � Data � 07/07/03 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Determina a chave de agrupamento para a Quadratura Contabil ���
���           �com quebra por documento fiscal                             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �Cbtr660Grupo(cGrupo,cAliasCTL,cCT2Key,cTpOper)              ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nao tem                                                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB(chamado do CTBR420)                                ���
��������������������������������������������������������������������������Ĵ��
���Parametros � cGrupo - Chave de agrupamento(numero do doc. de referencia ���
���           � para a aglutinacao por documento fiscal)                   ���
���           � cAliasCTL - Alias do relacionamento                        ���
���           � cCT2Key - Chave do relacionamento                          ���
���           � cTpOper - Descricao da operacao/documento                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ctbr660Grupo(cGrupo,cAliasCTL,cCT2Key,cTpOper)

Local cChaveBusca  := ""
Local cCTLKey      := "" 
Local cLancPad     := CT2->CT2_LP
Local cCampo       := ""
Local cDocMov      := ""
Local cDataMov     := ""
Local cCodBanco    := ""
Local cCodAgencia  := ""
Local cCodConta    := ""
Local cNumDoc      := ""

Local cDocumen     := ""
Local cPrefixo     := ""
Local cNumero      := ""
Local cParcela     := ""
Local cTipo        := ""
Local cCliFor      := ""
Local cLoja        := ""
Local cChaveComp   := ""
Local aArea        := GetArea()
Local aPosicao     := {}
Local nPosGrupo    := 0
Local nPosFim      := 0
Local nPosChave    := 0
Local nI           := 1
Local nTamIni      := 0 
Local nTamFim      := 0 
Local nPosSinal    := 0 
Local nPosLP       := 0
Local nValorMov    := 0
Local nPosSE5      := 0
Local nPosTitComp  := 0            
Local nLenComp     := 0
Local lLP560       := cLancPad == "560"      //Transferencia Bancaria - Saida do banco origem
Local lLP561       := cLancPad == "561"      //Transferencia Bancaria - Entrada no banco destino
Local lLPCompens   := cLancPad $  "596|597"  //Compensacao Contas a Receber/Pagar
Local lLPCancComp  := cLancPad $  "588|589"  //Cancela Compensacao Contas a Receber/Pagar
Local lLPCompCart  := cLancPad $  "535|594"  //Compensacao entre Carteiras 
Local lLPCredCH    := cLancPad $  "521|527"  //Acreditacao de cheque
Local lLPDevolCH   := cLancPad == "520"      //Devolucao de cheque
Local lFoundLP561  := .F.

CTL->(DbSetOrder(1))
If CTL->(DbSeek(xFilial("CTL")+cLancPad))
   cAliasCTL  := CTL->CTL_ALIAS                                          
   nPosLP     := Ascan(aCposCTL,{|x| Ascan(x[4],CTL->CTL_LP) > 0 })
   //Se nao encontrar o LP, busca pelo alias desde que nao tenha LPs pre-configuradas para a
   //chave no array aCposCTL
   If nPosLP == 0
      nPosGrupo  := Ascan(aCposCTL,{|x| x[1] == cAliasCTL .And. Empty(x[4])})
   Else
      nPosGrupo  := nPosLP      
   EndIf   
   If nPosGrupo > 0
      cChaveBusca  := aCposCTL[nPosGrupo][2]  //Chave de agrupamento configurada no array aGruposCTB
      nTamFim      := aCposCTL[nPosGrupo][3]  //Somatorio do tamanho total dos campos que compoem a chave
   EndIf   
   //Busca a chave de Agrupamento no CTL_KEY. Para isso, a chave configurada no array aGruposCTB 
   //deve estar contida no CTL_KEY do LP correspondente
   nPosChave  := At(cChaveBusca,CTL->CTL_KEY)
   If nPosChave > 0 
      //Busca, no CTL_KEY, todos os campos anteriores a chave de agrupamento de forma a 
      //saber a posicao inicial da chave na string do CT2_KEY
      cCTLKey    := CTL->CTL_KEY      
      While nI < (nPosChave-1)
         nPosFim  := At('+',cCTLKey)      
         cCampo   := Substr(cCTLKey,1,nPosFim-1)
         If Substr(cCampo,1,4) == "DTOS"
            nPosSinal  := At(')',cCampo)
            cCampo     := Substr(cCampo,6,nPosSinal-6)
         EndIf         
         //Verifica o tamanho dos campos que nao fazem parte do Agrupamento
         nTamIni  += TamSX3(cCampo)[1]
         cCTLKey  := Substr(cCTLKey,nPosFim+1)         
         nI       += nPosFim
      End                   
      //Contem a chave de agrupamento(Num. do Recibo, Ordem de Pago, Bordero etc.) para a quebra 
      //por documento fiscal
      cGrupo  := cAliasCTL+"-"+Substr(CT2->CT2_KEY,nTamIni+1,nTamFim)      

      //��������������������������������������������������������������Ŀ
      //� Casos Especiais                                              �
      //����������������������������������������������������������������            
      
      //��������������������������������������������������������������Ŀ
      //�Para o LP 560(Transferencia Bancaria-Saida do Banco origem),  �
      //�deve armazenar no array aLP560 os dados de data, num. docto. e�
      //�valor de maneira que encontre o LP 561(Transferencia Bancaria-�
      //�Entrada do Banco destino) correspondente. Este controle eh    �
      //�feito porque nao eh possivel configurar o CTL para o LP 561(o �
      //�campo E5_DOCUMEN nao faz parte de nenhuma chave de indice do  �      
      //�arquivo).Se for chamado para a impressao dos LP560 que nao tem�
      //�correspondentes,nao eh preciso preencher o array aLP560       �
      //����������������������������������������������������������������      
      
      //��������������������������������������������������������������Ŀ
      //� Transferencia Bancaria - Saida do banco origem               �
      //����������������������������������������������������������������            
      If lLP560                                                                   
         aPosicao  := Ctbr660Pos(nPosGrupo,"E5_DATA")   
	     cDataMov  := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])
         aPosicao  := Ctbr660Pos(nPosGrupo,"E5_NUMCHEQ")   
         cDocMov   := AllTrim(Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2]))         
         nValorMov := &('CT2->CT2_VLR'+CT2->CT2_MOEDLC)
         //Armazena a data, num. docto., valor mov. e chave de agrupamento para comparacao
         //com os registros do LP561 de maneira a encontrar os LPs correspondentes e gravar
         //a mesma chave de agrupamento
         Aadd(aLP560,{cDataMov,cDocMov,nValorMov,cGrupo})
      //��������������������������������������������������������������Ŀ
      //� Transferencia Bancaria - Entrada no banco destino            �
      //����������������������������������������������������������������      
      ElseIf lLP561                                                             
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_BANCO")   	     
	     cCodBanco   := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_AGENCIA")   	     
	     cCodAgencia := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_CONTA")   	     
	     cCodConta   := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_DATA")   	     
	     cDataMov    := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         	     
	     nValorMov   := &('CT2->CT2_VLR'+CT2->CT2_MOEDLC)
	     //Busca no Mov. Bancario o registro correspondente ao lancamento contabil e compara
	     //com os registros do array aLP560, atraves da data, valor e num. docto(E5_NUMCHEQ x E5_DOCUMEN),
	     //para identificar a chave de agrupamento(cGrupo)
	     DbSelectArea("SE5")
	     DbSetOrder(1)
	     If DbSeek(xFilial("SE5")+cDataMov+cCodBanco+cCodAgencia+cCodConta)
	        lFoundLP561  := .F.
	        While !Eof() .And. cDataMov == DTOS(SE5->E5_DATA) .And.;
	           cCodBanco+cCodAgencia+cCodConta == SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA ;
	           .And. !lFoundLP561
	           
	           cNumDoc  := AllTrim(SE5->E5_DOCUMEN)
	           If SE5->E5_TIPODOC != "TR" .Or. Empty(cNumDoc) .Or. SE5->E5_RECPAG != "R"
	              DbSkip()
	              Loop
	           EndIf
	           
	           If SE5->E5_VALOR != nValorMov
	              DbSkip()
	              Loop	           
	           EndIf
	           
	           nPosSE5  := Ascan(aLP560,{|x| DTOS(SE5->E5_DATA) == x[1] .And. ;
	                             cNumDoc == x[2] .And. SE5->E5_VALOR == x[3]})
	           
	           //Como encontrou LP correspondente, exclui o registro LP 560(Saida) correspondente ao LP 561(Entrada) 
	           If nPosSE5 > 0        
	              cGrupo       := aLP560[nPosSE5][4]
			      ADel(aLP560,nPosSE5)
			      ASize(aLP560,Len(aLP560)-1)	
			      lFoundLP561  := .T.
			   //Se nao encontrar no array aLP560, grava o num. docto.(E5_DOCUMEN) na chave do 
			   //agrupamento. Assim, eh impresso no relatorio como movimento divergente     			      
			   Else
			      cGrupo  += cNumDoc
	           EndIf         
	           
	           DbSkip()
	        End      
	     EndIf
      //��������������������������������������������������������������Ŀ
      //� Compensacao Contas a Receber/Pagar       					   �
      //����������������������������������������������������������������
      ElseIf lLPCompens                                                             	     
         //Lancamento referente aos titulos usados na compensacao do titulo principal
         If !Empty(CT2->CT2_KEY)    
            nPosTitComp  := Ascan(aLPCompens,{|x| DTOS(CT2->CT2_DATA) == x[1] .And. ;
	                              CT2->CT2_LOTE == x[2] .And. CT2->CT2_SBLOTE == x[3] .And. ;
	                              CT2->CT2_DOC == x[4]})
            If nPosTitComp == 0 
               Aadd(aLPCompens,{DTOS(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,;
                                CT2->CT2_KEY})
               nLenComp    := Len(aLPCompens)                  
	           cChaveComp  := aLPCompens[nLenComp][1]+aLPCompens[nLenComp][2]+;
	                          aLPCompens[nLenComp][3]+aLPCompens[nLenComp][4]                                      
            Else
	           cChaveComp  := aLPCompens[nPosTitComp][1]+aLPCompens[nPosTitComp][2]+;
	                          aLPCompens[nPosTitComp][3]+aLPCompens[nPosTitComp][4]      
            EndIf                    
            //A chave de agrupamento da compensacao corresponde ao numero do documento principal
            //gravado no campo E5_DOCUMEN
            aPosicao  := Ctbr660Pos(nPosGrupo,"E5_DOCUMEN")   	     
	        cDocumen  := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])	        
	        //cChaveComp eh uma chave com dados do CT2 para diferenciar as compensacoes 
	        //do mesmo titulo principal	           
            cGrupo    := cAliasCTL+cDocumen+cChaveComp
         //Lancamento referente ao titulo principal
         Else
            //Busca o lancamento referente ao titulo usado na compensacao deste titulo
            //principal
            nPosTitComp  := Ascan(aLPCompens,{|x| DTOS(CT2->CT2_DATA) == x[1] .And. ;
	                              CT2->CT2_LOTE == x[2] .And. CT2->CT2_SBLOTE == x[3] .And. ;
	                              CT2->CT2_DOC == x[4]})
            If nPosTitComp > 0 
	           cChaveComp  := aLPCompens[nPosTitComp][1]+aLPCompens[nPosTitComp][2]+;
	                          aLPCompens[nPosTitComp][3]+aLPCompens[nPosTitComp][4]                  
               cCT2Key   := aLPCompens[nPosTitComp][5]             
               //A chave de agrupamento da compensacao corresponde ao numero do documento principal
               //gravado no campo E5_DOCUMEN               
               aPosicao  := Ctbr660Pos(nPosGrupo,"E5_DOCUMEN")   	     
	           cDocumen  := Substr(cCT2Key,aPosicao[1],aPosicao[2])         
	           //cChaveComp eh uma chave com dados do CT2 para diferenciar as compensacoes 
	           //do mesmo titulo principal	           
               cGrupo    := cAliasCTL+cDocumen+cChaveComp
               cCT2Key   := xFilial("SE5")+cDocumen               
            EndIf
         EndIf
         If CT2->CT2_LP == "596"
            cTpOper  := STR0035 //"Compensacao Receber"
         Else
            cTpOper  := STR0036 //"Compensacao Pagar"
         EndIf   
      //��������������������������������������������������������������Ŀ
      //� Cancelamento de Compensacao Contas a Receber/Pagar           �
      //����������������������������������������������������������������
      ElseIf lLPCancComp                                                             	    
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_PREFIXO")   	     
	     cPrefixo    := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_NUMERO")   	     
	     cNumero     := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_PARCELA")   	     
	     cParcela    := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_TIPO")   	     
	     cTipo       := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         	     
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_CLIFOR")   	     
	     cCliFor     := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_LOJA")   	     
	     cLoja       := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         	                                      
         //Uso dos campos do arq. CT2 na chave do grupo para diferenciar compensacoes
         //distintas do mesmo titulo principal	           	     
         cChaveComp  := DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC
	     cGrupo      := cAliasCTL+cPrefixo+cNumero+cParcela+cTipo+cCliFor+cLoja+cChaveComp
         If CT2->CT2_LP == "588"
            cTpOper  := STR0037 //"Cancelamento Comp.Receber"
         Else
            cTpOper  := STR0038 //"Cancelamento Comp.Pagar"
         EndIf   	     
      //��������������������������������������������������������������Ŀ
      //� Compensacao entre Carteiras           					   �
      //����������������������������������������������������������������
      ElseIf lLPCompCart                                                             	              
         cTpOper  := STR0039 //"Compensacao de Carteiras"   
      //��������������������������������������������������������������Ŀ
      //� Acreditacao de Cheques           					           �
      //����������������������������������������������������������������
      ElseIf lLPCredCH
         cTpOper  := STR0047 //"Recebimento de Cheques"                    
      //��������������������������������������������������������������Ŀ
      //� Devolucao de Cheques           					           �
      //����������������������������������������������������������������         
	  ElseIf lLPDevolCH         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_PREFIXO")   	     
	     cPrefixo    := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_NUMERO")   	     
	     cNumero     := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_PARCELA")   	     
	     cParcela    := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         
         aPosicao    := Ctbr660Pos(nPosGrupo,"E5_TIPO")   	     
	     cTipo       := Substr(CT2->CT2_KEY,aPosicao[1],aPosicao[2])         	     	     
	     //A chave de agrupamento deve ser formada pelos dados do titulo(cheque devolvido)
         cGrupo      := "SE1-"+cPrefixo+cNumero+cParcela+cTipo	     
         cTpOper     := STR0048 //"Devolucao de Cheques"                    	  
      EndIf
   EndIf      
EndIf

RestArea(aArea)

Return .T.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ctbr660Pos� Autor � Fernando Machima      � Data � 17/07/03 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Busca a posicao e o tamanho de determinado campo na chave de���
���           �agrupamento                                                 ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �Cbtr660Pos(nPosGrupo,cCampo)                                ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Posicao e tamanho do campo                                  ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � nPosGrupo = Posicao da chave de agrupamento no array       ���
���           � aGruposCTB                                                 ���
���           � cCampo = Nome do campo desejado                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function Ctbr660Pos(nPosGrupo,cCampo)

Local nPosCpoCTL  := 0
Local nTamCTL     := 0
Local nPosCTL     := 0

nPosCpoCTL  := Ascan(aCposCTL[nPosGrupo][5],{|x| x[1] == cCampo }) 
If nPosCpoCTL > 0                                     
   nTamCTL  := aCposCTL[nPosGrupo][5][nPosCpoCTL][2]         
   //Busca a posicao de gravacao no CT2_KEY do campo passado como parametro
   nPosCTL  := aCposCTL[nPosGrupo][5][nPosCpoCTL][3]
EndIf                  

Return ({nPosCTL,nTamCTL})
