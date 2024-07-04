#include "protheus.ch"
#include "pmsr150.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PMSR150  � Autor � Edson Maricate        � Rev. � 02.07.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao dos quantitativos previstos do projeto.           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PmsR150()
Local aArea		:= GetArea()

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������

Pergunte("PMR150", .F.)

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �29/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local aOrdem := {}
Local oReport
Local oProjeto

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
oReport := TReport():New("PMSR150",STR0002,"PMR150", ;	//"Quantitativos previstos"
			{|oReport| ReportPrint(oReport)},;
			STR0001)	//"Este relat�rio ir� imprimir os quantitativos previstos para a execu��o do projeto de acordo com parametros solicitados. "

//������������������������������������������������������������������������Ŀ
//�Alimentar Array aOrdem com as Ordens Disponiveis no relatorio           �
//�observe que estas ordens nao sao do banco de dados e sim do Array       �
//��������������������������������������������������������������������������
aAdd(aOrdem, STR0003) //"PROJETO+PRODUTO+DESPESA"
aAdd(aOrdem, STR0004) //"TAREFA+PRODUTO+DESPESA"

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
oProjeto := TRSection():New(oReport,STR0009,{"AF8", "SA1"}, aOrdem/*{}*/, .F., .F.) //"Projeto"
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oProjeto,	"AF8_PROJET"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AF8->AF8_PROJET })
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AF8->AF8_DESCRI })
TRCell():New(oProjeto,	"AF8_REVISA"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| mv_par05 })

TRPosition():New(oProjeto, "SA1", 1, {|| xFilial("SA1") + AF8->AF8_CLIENT})

oProjeto:SetLineStyle()

//-----------------------------------------------------------------------------//

oABCOrdem1 := TRSection():New(oReport, STR0018 + STR0023, {"AF8","SB1","AE8"}, {}, .F., .F.) //"Ordem"
TRCell():New(oABCOrdem1	,"TIPO"      ,"SB1",STR0019/*Titulo*/,/*Picture*/,3/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Tipo"
TRCell():New(oABCOrdem1	,"B1_COD"    ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"B1_DESC"   ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"B1_UM"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"AFA_QUANT" ,"AFA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"AFA_CUSTD" ,"AFA",STR0020/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor"
TRCell():New(oABCOrdem1	,"AFA_CUSTD1","AFA","% "+STR0021/*Titulo*/,"@E 999.99"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Proj."
TRCell():New(oABCOrdem1	,"AFA_CUSTD2","AFA","% "+STR0022/*Titulo*/,"@E 999.99"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Acum."


//-----------------------------------------------------------------------------//
oABCOrdem2 := TRSection():New(oReport, STR0018 + STR0024,{"AF9", "AF8", "SB1","AE8"}, {}, .F., .F.)  //"Ordem"
TRCell():New(oABCOrdem2	,"AF9_TAREFA" ,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AF9_DESCRI" ,"AF9",/*Titulo*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"TIPO"       ,"SB1",STR0019/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Tipo"
TRCell():New(oABCOrdem2	,"B1_COD"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"B1_DESC"    ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"B1_UM"      ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AFA_QUANT"  ,"AF3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AFA_CUSTD"  ,"AF3",STR0020/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor"
TRCell():New(oABCOrdem2	,"AFA_CUSTD1" ,"AF3","% "+STR0021/*Titulo*/,"@E 999.99"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Proj."
TRCell():New(oABCOrdem2	,"AFA_CUSTD2" ,"AF3","% "+STR0022/*Titulo*/,"@E 999.99"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Acum."

Return(oReport)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor  �Paulo Carnelossi   � Data � 15/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport)
Local oProjeto		:= oReport:Section(1)
Local oABCOrdPrint	:= oReport:Section(oProjeto:GetOrder()+1)
Local oTotal
Local oTotal1
Local oTotal2
Local oTotal3
Local oTotal4
Local oTotal5
Local aArea			:= GetArea()
Local aAreaAFA		:= GetArea("AFA")
Local nDecCst			:= TamSX3("AF9_CUSTO")[2]
Local aArrayABC		:= {}
Local nX				:= 0
Local nPercAcm		:= 0
Local mvpar05Ant
Local cTrunca
Local lRevAtu
Local aAuxHand
Local nCustoPrj		:= 0
Local nCustoTrf		:= 0
Local nCustoPer		:= 0
Local nCustTrR4		:= 0
Local nCustPeR4		:= 0
Local cAnt				:= ""
Local nTotPeriodo		:= 0
Local cFiltAF8		:=	""
Local cFiltAF9		:=	""
Local cFiltSB1		:=	""
Local cFiltAE8		:=	""
Local nPerc			:= 0
Local nValor			:= 0
Local nQuant			:= 0
Local nFerram			:= 0
Local nProduc			:= 0
Local cFilAE8			:= xFilial("AE8")
Local cFilAEL			:= xFilial("AEL")
Local cFilAEN			:= xFilial("AEN")
Local cFilAF8			:= xFilial("AF8")
Local cFilAF9			:= xFilial("AF9")
Local cFilAFA			:= xFilial("AFA")
Local cFilAFB			:= xFilial("AFB")
Local cFilAJY			:= xFilial("AJY")
Local cFilSB1			:= xFilial("SB1")
Local cFilSX5			:= xFilial("SX5")

oReport:SetMeter(50)
oReport:OnPageBreak({||oProjeto:PrintLine(),oReport:ThinLine()})
oABCOrdPrint:SetHeaderPage(.T.)

If oProjeto:GetOrder() == 1

	oABCOrdPrint:Cell("TIPO")		:SetBlock({|| aArrayABC[nx,1] })
	oABCOrdPrint:Cell("B1_COD")		:SetBlock({||	If(aArrayABC[nx,1]=="PRD", SB1->B1_COD,;
													If(aArrayABC[nx,1]=="REC", AE8->AE8_RECURS,;
													If(aArrayABC[nx,1]=="INS", AJY->AJY_INSUMO, "" );
													) ) } )
	oABCOrdPrint:Cell("B1_DESC")	:SetBlock({||	If(aArrayABC[nX,1]=="PRD", SB1->B1_DESC,;
													If(aArrayABC[nX,1]=="REC", FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",NiL,.T.),;
													If(aArrayABC[nX,1]=="INS", AJY->AJY_DESC, aArrayABC[nX,2] );
													) ) } )
	oABCOrdPrint:Cell("B1_UM")		:SetBlock({||	If(aArrayABC[nX,1]=="PRD", SB1->B1_UM,;
								   					If(aArrayABC[nX,1]=="REC", "HR",;
								   					If(aArrayABC[nX,1]=="INS", AJY->AJY_UM,"" );
								   					) ) } )
	oABCOrdPrint:Cell("AFA_QUANT")	:SetBlock({|| aArrayABC[nX,3] })
	oABCOrdPrint:Cell("AFA_CUSTD")	:SetBlock({|| aArrayABC[nX,4] })
	oABCOrdPrint:Cell("AFA_CUSTD1")	:SetBlock({|| aArrayABC[nX,4]/nCustoPrj*100 })
	oABCOrdPrint:Cell("AFA_CUSTD2")	:SetBlock({|| nPercAcm })

	oABCOrdPrint:SetTotalText()
	oABCOrdPrint:SetTotalInLine(.T.)

	oTotal1:= TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD"),"NCUSTOPER" ,"SUM",,STR0016/*cTitle*/,/*cPicture*/,{|| aArrayABC[nx,4]}/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)	//"Total do Periodo"
	oTotal1:ShowHeader()

	oTotal := TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD"),"NCUSTOPRJ","ONPRINT",,STR0017/*cTitle*/,/*cPicture*/,{|| nCustoPrj }/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)	//"Total do Projeto"
	oTotal:ShowHeader()

Else

	oABCOrdPrint:Cell("AF9_TAREFA") :SetBlock({|| AF9->AF9_TAREFA })
	oABCOrdPrint:Cell("AF9_DESCRI") :SetBlock({|| AF9->AF9_DESCRI })
	oABCOrdPrint:Cell("TIPO")       :SetBlock({|| aArrayABC[nx,1] })

	oABCOrdPrint:Cell("B1_COD")		:SetBlock({||	If(Left(aArrayABC[nx,1],3)=="PRD", SB1->B1_COD,;
													If(Left(aArrayABC[nx,1],3)=="REC", AE8->AE8_RECURS,;
													If(Left(aArrayABC[nx,1],3)=="INS", AJY->AJY_INSUMO, "" );
													) ) } )
	oABCOrdPrint:Cell("B1_DESC")	:SetBlock({||	If(Left(aArrayABC[nx,1],3)=="PRD", SB1->B1_DESC,;
													If(Left(aArrayABC[nx,1],3)=="REC", FATPDObfuscate(AE8->AE8_DESCRI,"AE8_DESCRI",NiL,.T.),;
													If(Left(aArrayABC[nx,1],3)=="INS", AJY->AJY_DESC, aArrayABC[nX,2] );
													) ) } )
	oABCOrdPrint:Cell("B1_UM")		:SetBlock({||	If(Left(aArrayABC[nx,1],3)=="PRD", SB1->B1_UM,;
								   					If(Left(aArrayABC[nx,1],3)=="REC", "HR",;
								   					If(Left(aArrayABC[nx,1],3)=="INS", AJY->AJY_UM,"" );
								   					) ) } )

	oABCOrdPrint:Cell("AFA_QUANT")  :SetBlock({|| aArrayABC[nx,3] })
	oABCOrdPrint:Cell("AFA_CUSTD")  :SetBlock({|| aArrayABC[nx,4] })
	oABCOrdPrint:Cell("AFA_CUSTD1") :SetBlock({|| aArrayABC[nx,4]/nCustoPrj*100 })
	oABCOrdPrint:Cell("AFA_CUSTD2") :SetBlock({|| nPercAcm })

	oABCOrdPrint:SetTotalText()
	oABCOrdPrint:SetTotalInLine(.T.)

	oTotal1 := TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD"),"NCUSTOTRF" ,"SUM",,STR0012/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Total da Tarefa"
	oTotal1:ShowHeader()
	oTotal2 := TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD1"),"NCUSTOPRJ" ,"ONPRINT",,/*cTitle*/,/*cPicture*/,{|| nCustTrR4 }/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	oTotal3 := TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD2"),"NPERCACM" ,"ONPRINT",,/*cTitle*/,/*cPicture*/,{|| nCustPeR4 }/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

	oTotal4 := TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD"),"NCUSTOPER" ,"ONPRINT",,STR0016/*cTitle*/,/*cPicture*/,{|| nTotPeriodo }/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)	//"Total do Periodo"
	oTotal4:ShowHeader()

	oTotal5 := TRFunction():New(oABCOrdPrint:Cell("AFA_CUSTD"),"NCUSTOPRJ" ,"ONPRINT",,STR0017/*cTitle*/,/*cPicture*/,{|| nCustoPrj }/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)	//"Total do Projeto"
	oTotal5:ShowHeader()
	cFiltAF9	:=	oABCOrdPrint:GetAdvPlExp('AF9')

EndIf
cFiltAF8	:=	oABCOrdPrint:GetAdvPlExp('AF8')
cFiltSB1	:=	oABCOrdPrint:GetAdvPlExp('SB1')
cFiltAE8	:=	oABCOrdPrint:GetAdvPlExp('AE8')
		
oProjeto:Init()

lRevAtu    := Empty(mv_par05)
RestArea(aAreaAFA)

dbSelectArea("AF8")
dbSetOrder(1)
dbSeek(cFilAF8 + mv_par01,.T.)
Do While AF8->(! Eof()) .And. AF8->AF8_FILIAL == cFilAF8 .And. AF8->AF8_PROJET <= mv_par02 .AND. !oReport:Cancel()

	oReport:IncMeter()

	If	AF8->AF8_DATA > mv_par04 .OR.;
		AF8->AF8_DATA < mv_par03 .OR.;
		( ! Empty(cFiltAF8) .And. !AF8->(&(cFiltAF8)) )
		dbSelectArea("AF8")
		AF8->(DbSkip())
		LOOP
	EndIf
	
	nTotal	  := 0
	aArrayABC := {}
	nPercAcm  := 0
	mvpar05Ant := mv_par05

	cTrunca	:= AF8->AF8_TRUNCA

	If lRevAtu
		mv_par05 := AF8->AF8_REVISA
	Else
		If mv_par05 > AF8->AF8_REVISA
			mv_par05 := AF8->AF8_REVISA
		EndIf
	EndIf      
	aAuxHand  := PmsIniCOTP(AF8->AF8_PROJET,mv_par05,CTOD("31/12/2040"))
	nCustoPrj := PmsRetCOTP(aAuxHand,2,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))[1]
	nCustoPer := 0

	Do Case 
		Case oProjeto:GetOrder() == 1
			oAbcOrdPrint:Init()
		
			dbSelectArea("AFA")
			dbSetOrder(1)
			dbSeek(cFilAFA + AF8->AF8_PROJET + mv_par05 )
			While AFA->(! Eof()) .AND. AFA->AFA_FILIAL == cFilAFA .AND. AFA->AFA_PROJET == AF8->AF8_PROJET .AND. AFA->AFA_REVISA == mv_par05

				oReport:IncMeter()

				AF9->(dbSetOrder(1))
				AF9->(MsSeek(cFilAF9 + AFA->AFA_PROJET + AFA->AFA_REVISA + AFA->AFA_TAREFA))
				If !Empty(cFiltAF9) .And. !AF9->(&(cFiltAF9))
					dbSelectArea("AF9")
					dbSkip()
					Loop
				Endif

				If ! Empty(AFA->AFA_PRODUT)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(cFilSB1+AFA->AFA_PRODUT))
					If !Empty(cFiltSB1) .And. !SB1->(&(cFiltSB1))
						dbSelectArea("AFA")
						dbSkip()
						Loop
					EndIf

					// verifica a quantidade do produto
					nQuantAFA	:= PmsPrvAFA(AFA->(RecNo()),mv_par06,mv_par07,AF9->(RecNo()))

					nPosABC	:= aScan(aArrayABC,{|x| x[1]=="PRD" .And. x[2]==SB1->B1_COD})
					If nPosABC > 0
						aArrayABC[nPosABC][3] += nQuantAFA
						aArrayABC[nPosABC][4] += xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1)
					Else
						aAdd(aArrayABC,{"PRD",SB1->B1_COD,nQuantAFA,xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1)})
					EndIf
				Else
					AE8->(dbSetOrder(1))
					AE8->(dbSeek(cFilAE8+AFA->AFA_RECURS))
					If !Empty(cFiltAE8) .And. !AE8->(&(cFiltAE8))
						dbSelectArea("AFA")
						dbSkip()
						Loop
					EndIf
					// verifica a quantidade do produto
					nQuantAFA	:= PmsPrvAFA(AFA->(RecNo()),mv_par06,mv_par07,AF9->(RecNo()))

					nPosABC	:= aScan(aArrayABC,{|x| x[1]=="REC" .And. x[2]==AE8->AE8_RECURS})
					If nPosABC > 0
						aArrayABC[nPosABC][3] += nQuantAFA
						aArrayABC[nPosABC][4] += xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1)
					Else
						aAdd(aArrayABC,{"REC",AE8->AE8_RECURS,nQuantAFA,xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1)})
					EndIf
				EndIf
				dbSelectArea("AFA")
				dbSkip()
			EndDo 
			
			dbSelectArea("AFB")
			dbSetOrder(1)
			dbSeek(cFilAFB + AF8->AF8_PROJET + mv_par05 )
			While AFB->(! Eof()) .AND. AFB->AFB_FILIAL == cFilAFB .AND. AFB->AFB_PROJET == AF8->AF8_PROJET .AND. AFB->AFB_REVISA == mv_par05

				oReport:IncMeter()

				// verifica o valor da despesa
				AF9->(dbSetOrder(1))
				AF9->(MsSeek(cFilAF9 + AFB->AFB_PROJET + AFB->AFB_REVISA + AFB->AFB_TAREFA))
				nValorAFB	:= PmsPrvAFB(AFB->(RecNo()),mv_par06,mv_par07,AF9->(RecNo()))[1]

				nPosABC	:= aScan(aArrayABC,{|x| x[1]=="DSP" .And. x[2]==AFB->AFB_DESCRI})
				If nPosABC > 0
					aArrayABC[nPosABC][4] += PmsTrunca(cTrunca,xMoeda(nValorAFB,AFB->AFB_MOEDA,1),nDecCst,AF9->AF9_QUANT)
				Else
					aAdd(aArrayABC,{"DSP",AFB->AFB_DESCRI,0,PmsTrunca(cTrunca,xMoeda(nValorAFB,AFB->AFB_MOEDA,1),nDecCst,AF9->AF9_QUANT),AFB->AFB_TIPOD})
				EndIf
				dbSelectArea("AFB")
				dbSkip()
			EndDo
		
			If Len(aArrayABC) > 0
				aArrayABC := aSort(aArrayABC,,,{|x,y|x[2] < y[2]})
				For nx := 1 to Len(aArrayABC)

					Do Case
						Case aArrayABC[nx,1]=="PRD"
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(cFilSB1+aArrayABC[nx,2]))
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100

						Case aArrayABC[nx,1] == "INS"
							AJY->( DbGoTo( aArrayABC[nx][5] ) )
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							
						Case aArrayABC[nx,1]=="REC"
							AE8->(dbSetOrder(1))
							AE8->(dbSeek(cFilAE8+aArrayABC[nx,2]))
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							
						Case aArrayABC[nx,1]=="DSP"
							SX5->(MsSeek(cFilSX5 + 'FD' +aArrayABC[nx,5]))
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							oAbcOrdPrint:Cell("AFA_QUANT"):Hide()
							oAbcOrdPrint:Cell("B1_UM"):Hide()

						Case aArrayABC[nx,1] == "FER"
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							oAbcOrdPrint:Cell("AFA_QUANT"):Hide()
							oAbcOrdPrint:Cell("B1_UM"):Hide()
							
					EndCase
					
					nCustoPer += aArrayABC[nx,4]
					
					oAbcOrdPrint:PrintLine()
					
					If aArrayABC[nx,1]=="DSP" .Or. aArrayABC[nx,1]=="FER"
						oAbcOrdPrint:Cell("AFA_QUANT"):Show()
						oAbcOrdPrint:Cell("B1_UM"):Show()
					EndIf	
					
				Next
				
			EndIf
			
			oReport:SkipLine(2)

		Case oProjeto:GetOrder() == 2
			nTotPeriodo := 0
			oAbcOrdPrint:Init()

			dbSelectArea("AFA")
			dbSetOrder(1)
			dbSeek(cFilAFA + AF8->AF8_PROJET + mv_par05 )
			While AFA->(! Eof()) .And. AFA->AFA_FILIAL == cFilAFA .AND. AFA->AFA_PROJET == AF8->AF8_PROJET .AND. AFA->AFA_REVISA == mv_par05

				oReport:IncMeter()

				If !Empty(AFA->AFA_PRODUT)

					// verifica a quantidade do produto
					AF9->(dbSetOrder(1))
					AF9->(MsSeek(cFilAF9 + AFA->AFA_PROJET + AFA->AFA_REVISA + AFA->AFA_TAREFA))
					nQuantAFA:= PmsPrvAFA(AFA->(RecNo()),mv_par06,mv_par07,AF9->(RecNo()))

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(cFilSB1+AFA->AFA_PRODUT))
					nPosABC := aScan(aArrayABC,{|x| x[1]=="PRD"+AFA->AFA_TAREFA .And. x[2]==SB1->B1_COD})
					If nPosABC > 0
						aArrayABC[nPosABC][3] += nQuantAFA
						aArrayABC[nPosABC][4] += xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1)
					Else
						aAdd(aArrayABC,{"PRD"+AFA->AFA_TAREFA,SB1->B1_COD,nQuantAFA,xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1),AFA->AFA_TAREFA})
					EndIf
				Else

					// verifica a quantidade do produto
					AF9->(dbSetOrder(1))
					AF9->(MsSeek(cFilAF9 + AFA->AFA_PROJET + AFA->AFA_REVISA + AFA->AFA_TAREFA))
					nQuantAFA:= PmsPrvAFA(AFA->(RecNo()),mv_par06,mv_par07,AF9->(RecNo()))

					AE8->(dbSetOrder(1))
					AE8->(dbSeek(cFilAE8+AFA->AFA_RECURS))
					nPosABC := aScan(aArrayABC,{|x| x[1]=="REC"+AFA->AFA_TAREFA .And. x[2]==AE8->AE8_RECURS})
					If nPosABC > 0
						aArrayABC[nPosABC][3] += nQuantAFA
						aArrayABC[nPosABC][4] += xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1)
					Else
						aAdd(aArrayABC,{"REC"+AFA->AFA_TAREFA,AE8->AE8_RECURS,nQuantAFA,xMoeda(PmsTrunca(cTrunca,nQuantAFA * AFA->AFA_CUSTD,nDecCst,AF9->AF9_QUANT),AFA->AFA_MOEDA,1),AFA->AFA_TAREFA})
					EndIf
				EndIf
				dbSelectArea("AFA")
				dbSkip()
			EndDo

			dbSelectArea("AFB")
			dbSetOrder(1)
			dbSeek(cFilAFB + AF8->AF8_PROJET + mv_par05 )
			While AFB->(! Eof()) .And. AFB->AFB_FILIAL == cFilAFB .AND. AFB->AFB_PROJET == AF8->AF8_PROJET .AND. AFB->AFB_REVISA == mv_par05

				oReport:IncMeter()

				// verifica o valor da despesa
				AF9->(dbSetOrder(1))
				AF9->(MsSeek(cFilAF9 + AFB->AFB_PROJET + AFB->AFB_REVISA + AFB->AFB_TAREFA))
				nValorAFB:= PmsPrvAFB(AFB->(RecNo()),mv_par06,mv_par07,AF9->(RecNo()))[1]

				nPosABC := aScan(aArrayABC,{|x| x[1]=="DSP"+AFB->AFB_TAREFA .And. x[2]==AFB->AFB_DESCRI})
				If nPosABC > 0
					aArrayABC[nPosABC][4] += PmsTrunca(cTrunca,xMoeda(nValorAFB,AFB->AFB_MOEDA,1),nDecCst,AF9->AF9_QUANT)
				Else
					aAdd(aArrayABC,{"DSP"+AFB->AFB_TAREFA,AFB->AFB_DESCRI,0,PmsTrunca(cTrunca,xMoeda(nValorAFB,AFB->AFB_MOEDA,1),nDecCst,AF9->AF9_QUANT),AFB->AFB_TAREFA})
				EndIf
				dbSelectArea("AFB")
				dbSkip()
			EndDo

			If Len(aArrayABC) > 0
				aArrayABC := aSort(aArrayABC,,,{|x,y|x[5]+x[2] < y[5]+y[2]})
				cTrfAtu	:= aArrayABC[1,5]
				nCustoTrf := 0

				For nx := 1 to Len(aArrayABC)
					oAbcOrdPrint:Cell("AF9_TAREFA"):Hide()
					AF9->(dbSetOrder(1))
					AF9->(dbSeek(cFilAF9+AF8->AF8_PROJET+mv_par05+aArrayABC[nx,5]))
					If nx == 1 .Or. aArrayABC[nx-1,5]!= cTrfAtu
						oAbcOrdPrint:Cell("AF9_TAREFA"):Show()
						oAbcOrdPrint:Cell("AF9_DESCRI"):Show()
						nCustoTrf := 0
					Else	
						oAbcOrdPrint:Cell("AF9_TAREFA"):Hide()
						oAbcOrdPrint:Cell("AF9_DESCRI"):Hide()
					EndIf

					Do Case
						Case Substr(aArrayABC[nx,1],1,3)=="PRD"
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(cFilSB1+aArrayABC[nx,2]))
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							nCustoTrf += aArrayABC[nx,4]
							oAbcOrdPrint:Cell("AFA_QUANT"):Show()
							oAbcOrdPrint:Cell("B1_UM"):Show()
						Case Substr(aArrayABC[nx,1],1,3) == "INS"
							AJY->( DbGoTo( aArrayABC[nx][6] ) )
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							nCustoTrf += aArrayABC[nx,4]
							oAbcOrdPrint:Cell("AFA_QUANT"):Show()
							oAbcOrdPrint:Cell("B1_UM"):Show()
						Case Substr(aArrayABC[nx,1],1,3)=="REC"
							AE8->(dbSetOrder(1))
							AE8->(dbSeek(cFilAE8+aArrayABC[nx,2]))
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							nCustoTrf += aArrayABC[nx,4]
							oAbcOrdPrint:Cell("AFA_QUANT"):Show()
							oAbcOrdPrint:Cell("B1_UM"):Show()
						Case Substr(aArrayABC[nx,1],1,3)=="DSP"
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							nCustoTrf += aArrayABC[nx,4]
							oAbcOrdPrint:Cell("AFA_QUANT"):Hide()
							oAbcOrdPrint:Cell("B1_UM"):Hide()
						Case Substr(aArrayABC[nx,1],1,3)=="FER"
							nPercAcm += aArrayABC[nx,4]/nCustoPrj*100
							nCustoTrf += aArrayABC[nx,4]
							oAbcOrdPrint:Cell("AFA_QUANT"):Hide()
							oAbcOrdPrint:Cell("B1_UM"):Hide()
					EndCase

					If cAnt != aArrayABC[nx,5]
						oAbcOrdPrint:Init()
						cAnt := aArrayABC[nx,5]
					EndIf

					nCustoPer += aArrayABC[nx,4]
					oAbcOrdPrint:PrintLine()

					nTotPeriodo += aArrayABC[nx,4]
					nCustTrR4 := nCustoTrf/nCustoPrj*100
					nCustPeR4 := nPercAcm

					If (nx < Len(aArrayABC)) .And. (cAnt != aArrayABC[nx+1,5])
						oAbcOrdPrint:Finish()
					EndIf
					
					If aArrayABC[nx,1]=="DSP" .Or. aArrayABC[nx,1]=="FER"
						oAbcOrdPrint:Cell("AFA_QUANT"):Show()
						oAbcOrdPrint:Cell("B1_UM"):Show()
					EndIf	

					If nx==Len(aArrayABC) .Or. aArrayABC[nx+1,5]!= cTrfAtu
						nCustoTrf := 0
						If nx!=Len(aArrayABC) 
							cTrfAtu := aArrayABC[nx+1,5]
						EndIf
					EndIf
					
				Next

			EndIf
	EndCase
	
	oAbcOrdPrint:Finish()

	If oProjeto:GetOrder() == 2
		oTotal1:SetEndSection(.F.)
		oTotal2:SetEndSection(.F.)
		oTotal3:SetEndSection(.F.)
		oTotal4:SetEndSection(.T.)	
		oTotal5:SetEndSection(.T.)	
		oABCOrdPrint:SetTotalText("")
		oReport:SkipLine(2)
		oAbcOrdPrint:Init()
		oAbcOrdPrint:Finish()
		oABCOrdPrint:SetTotalText()
		oTotal1:SetEndSection(.T.)
		oTotal2:SetEndSection(.T.)
		oTotal3:SetEndSection(.T.)
		oTotal4:SetEndSection(.F.)	
		oTotal5:SetEndSection(.F.)	
	EndIf

	mv_par05 :=  mvpar05Ant
	dbSelectArea("AF8")
	dbSkip()

	oReport:EndPage()
EndDo

// verifica o cancelamento pelo usuario..
If oReport:Cancel()	
	oReport:SkipLine()
	oReport:PrintText(STR0025) //"*** CANCELADO PELO OPERADOR ***"
EndIf

oProjeto:Finish()

RestArea(aArea)
Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

