#INCLUDE "pcor600.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOR600   �Autor  �Paulo Carnelossi    � Data �  20/12/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Demonstrativo de Saldos Mensal/Acumulado ate o mes          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PCOR600(aPerg)
Default aPerg	:=	{}

PCOR600R4(aPerg)

Return

/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOR600R4� AUTOR � Paulo Carnelossi      � DATA � 12/12/2006 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Demonstr.saldo mes a mes entre 2 configuracoes de Cubos      ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOR600R4  (BASEADO NO RELATORIO PCOR550)                    ���
���_DESCRI_  � Programa de impressao do demonstrativo saldo mensal          ���
���_FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  ���
���          � partir do Menu do sistema.                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOR600R4(aPerg)
Local aArea		:= GetArea()
Local lOk		:= .F.

Private cPerg := "PCR600"
Private aSavPar	
Private cCadastro := STR0001 //"Cubos Comparativos - Demonstrativo de Saldo Mes a Mes (Volume Ate o Mes)"
Private cCfg01:=PadL(STR0002,20), cCfg02:=PadL(STR0003,20) //"Previsto"###"Realizado"
Private aPeriodoRef

Default aPerg := {}

/*
Pergunta 01 : Codigo Cubo Gerencial? 01
Pergunta 02 : Mes? 05/2006
Pergunta 03 : Qual Moeda? Moeda I
Pergunta 04 : Configuracao do Cubo-1 ? PR
Pergunta 05 : Editar Configuracoes Cubo-1 ? Sim
Pergunta 06 : Configuracao do Cubo-2? RE
Pergunta 07 : Editar Configuracoes Cubo-2? Sim
Pergunta 08 : ConsiderarZerados? Nao
*/


If Len(aPerg) >  0
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
Else
	Pergunte(cPerg, .T.)
EndIf

aSavPar := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06, MV_PAR07, MV_PAR08}

If !Empty(aSavPar[04])
	dbSelectArea("AL3")
	dbSetOrder(1)
	If MsSeek(xFilial()+aSavPar[04])
		cCfg01 := PadL(AllTrim(AL3->AL3_DESCRI),20)
	EndIf
EndIf
If !Empty(aSavPar[06])
	dbSelectArea("AL3")
	dbSetOrder(1)
	If MsSeek(xFilial()+aSavPar[06])
		cCfg02 := PadL(AllTrim(AL3->AL3_DESCRI),20)
	EndIf
EndIf

aPeriodoRef := R600Periodo(aSavPar[02])

If Len(aPeriodoRef) > 0 .And. Len(aPeriodoRef) <= 12 
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef(aPeriodoRef)
	
	If Len(aPerg) == 0 .And. !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	
	oReport:PrintDialog()
Else
	Aviso(STR0020, STR0004, {"Ok"}) //"Verifique o mes informado."###"Atencao"
EndIf	

RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �12/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(aPeriodoRef)

Local oReport
Local oComparativo
Local nX, cMes
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
oReport := TReport():New("PCOR600",STR0001,"PCR600", ; //"Cubos Comparativos - Demonstrativo de Saldo Mes a Mes (Volume Ate o Mes)"
			{|oReport| ReportPrint(oReport) },;
			STR0001 )  //"Cubos Comparativos - Demonstrativo de Saldo Mes a Mes (Volume Ate o Mes)"

oReport:SetLandScape()
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
oComparativo := TRSection():New(oReport,STR0021 , {}, {}, .F., .F.) //"Cubos Comparativos"

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
TRCell():New(oComparativo,	"CODIGO"	,"",STR0005/*Titulo*/		,/*Picture*/,70/*Tamanho*/,/*lPixel*/,/*{|| }*/)  //"Codigo"
TRCell():New(oComparativo,	"DESCRI"	,"",STR0006/*Titulo*/	,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| }*/)  //"Descricao"

For nX := 1 TO Len(aPeriodoRef)+1
	If nX <= Len(aPeriodoRef)
		cMes := PCOR600Mes(aPeriodoRef[nX, 1], 1, "-")
	Else
		cMes := STR0007+Right(aSavPar[02],4) //"Ano-"
	EndIf		
	TRCell():New(oComparativo,	"MOVMES_P"+StrZero(nX,2)	,"",cCfg01+CRLF+cMes/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT") 
	TRCell():New(oComparativo,	"MOVMES_R"+StrZero(nX,2)	,"",cCfg02+CRLF+cMes/*Titulo*/		,"@E 999,999,999,999.99"/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT")
Next
oComparativo:Cell("DESCRI"):SetLineBreak()
oComparativo:SetLineBreak()

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Paulo Carnelossi      � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �que faz a chamada desta funcao ReportPrint()                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpO1: Objeto TReport                                       ���
���          �ExpC2: Alias da tabela de Planilha Orcamentaria (AK1)       ���
���          �ExpC3: Alias da tabela de Contas da Planilha (Ak3)          ���
���          �ExpC4: Alias da tabela de Revisoes da Planilha (AKE)        ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

Local aArea		:= GetArea()
Local aProcessa, aProcComp

aProcessa := PcoRunCube(aSavPar[1], Len(aPeriodoRef)+1, "Pcor600Sld", aSavPar[4], aSavPar[5], (aSavPar[08]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

If Len(aProcessa) > 0
	aProcComp := PcoRunCube(aSavPar[1], Len(aPeriodoRef)+1, "Pcor600Sld", aSavPar[6], aSavPar[7], (aSavPar[08]==1), /*aNiveis*/,/*aFilIni*/,/*aFilFim*/,/*lReserv*/, /*aCfgCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
EndIf	

Pcor600Imp(oReport, aProcessa, aProcComp)

RestArea(aArea)
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pcor600Sld� Autor � Paulo Carnelossi      � Data �13/12/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de processamento do demonstrativo saldo mes a mes.   ���
���          �Funcao baseada a do relatorio PCOR550                       ���
���          �sera chamada pela PcoRunCube()                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Pcor600Sld                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Pcor600Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetIni,aRetFim

Local nCrdIni
Local nDebIni

Local nCrdFim
Local nDebFim
Local nMovPer
Local nX
Local nTotAno := 0

For nX := 1 TO Len(aPeriodoRef)

	//saldo do mes
	dIni := aPeriodoRef[nX,1]
	dFim := aPeriodoRef[nX,2]

	aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
	nCrdIni := aRetIni[1, aSavPar[3]]
	nDebIni := aRetIni[2, aSavPar[3]]

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aSavPar[3]]
	nDebFim := aRetFim[2, aSavPar[3]]

	nMovCrd := nCrdFim-nCrdIni	
	nMovDeb := nDebFim-nDebIni
	nMovPer := nMovCrd-nMovDeb

	aAdd(aRetorno,nMovPer)
	nTotAno += nMovPer

Next

aAdd(aRetorno, nTotAno)	

Return aRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pcor600Imp   �Autor � Paulo Carnelossi    � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao Demonst.Resumido de saldos Mensais      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR600Imp(lEnd)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pcor600Imp(oReport, aProcessa, aProcComp)

Local oComparativo := oReport:Section(1)
Local cQuebra := ""
Local nX, nY, nZ
Private aValorCf01, aValorCf02

oComparativo:Cell("CODIGO")		:SetBlock({|| Alltrim(aProcessa[nX, 3])+"-"+Alltrim(aProcessa[nX, 1])})
oComparativo:Cell("DESCRI")		:SetBlock({|| aProcessa[nX, 6] })

For nX:=1 TO Len(aPeriodoRef)+1
	oComparativo:Cell("MOVMES_P"+StrZero(nX,2)):SetBlock(MontaBlock("{|| aValorCf01["+StrZero(nX, 2)+"]}"))
	oComparativo:Cell("MOVMES_R"+StrZero(nX,2)):SetBlock(MontaBlock("{|| aValorCf02["+StrZero(nX, 2)+"]}"))
Next

oComparativo:Init()

For nx := 1 To Len(aProcessa)

	aValorCf01  := aProcessa[nX,2]

	nPosComp := ASCAN(aProcComp, { |x| x[1] == aProcessa[nx][1] })

   	If nPosComp > 0
		aValorCf02  := aProcComp[nPosComp,2]
	Else
		aValorCf02  := {}
		For nZ := 1 TO Len(aPeriodoRef)+1
			aAdd(aValorCf02, 0)
		Next
	EndIf
    
	oComparativo:PrintLine()

Next

oComparativo:Finish()

Return              

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOR600Mes �Autor  �Paulo Carnelossi    � Data � 27/12/06  ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o mes da data informada no formato                 ���
���          � Exemplo: 01/01/06 retorna Jan-06 ou  01-06                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PCOR600Mes(dData, nTipMes, cSeparador)
Local cMes
Local nMes
Local cAno
Local cData
Local aMeses := { 	{STR0009, "01"}, ; //"Jan"
					{STR0010, "02"}, ; //"Fev"
					{STR0011, "03"}, ; //"Mar"
					{STR0012, "04"}, ; //"Abr"
					{STR0013, "05"}, ; //"Mai"
					{STR0014, "06"}, ; //"Jun"
					{STR0015, "07"}, ; //"Jul"
					{STR0016, "08"}, ; //"Ago"
					{STR0017, "09"}, ; //"Set"
					{STR0022, "10"}, ; //"Out"
					{STR0018, "11"}, ; //"Nov"
					{STR0019, "12"} } //"Dez"
					
DEFAULT dData := dDataBase
DEFAULT nTipMes := 1 // nTipMes = 1 --> Jan/2006   || nTipMes = 2 ----> 01/2006
DEFAULT cSeparador := "/"

cData := DTOC(dData)

nMes  := Val(Subs(cData,4,2))


If Len(cData)==10
	cAno := Subs(cData,7,4)
	cMes := aMeses[nMes, nTipMes]+cSeparador+cAno
Else  //com 8 caracteres	
	cAno := Subs(cData,7,2)
	cMes := aMeses[nMes, nTipMes]+cSeparador+cAno
EndIf

Return(Alltrim(cMes))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOR600Mes �Autor  �Paulo Carnelossi    � Data � 27/12/06  ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna um array com os periodos em subarray :             ���
���          � Exemplo: informado 04/20006 retornara                      ���
���          �  { { 01/01/06, 31/01/06 }, ;                               ���
���          �    { 01/02/06, 28/02/06 }, ;                               ���
���          �    { 01/03/06, 31/03/06 }, ;                               ���
���          �    { 01/04/06, 30/04/06 }                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function R600Periodo(cMes)
Local aRetPer := {}
Local nMeses := Val(Subs(cMes,1,2))
Local cAno   := Right(cMes,4)
Local nX

For nX := 1 TO nMeses
	dIniPer := CTOD("01/"+StrZero(nX,2)+"/"+Right(cAno,2))
	dFimPer := LastDay(dIniPer)
	aAdd(aRetPer, { dIniPer, dFimPer } )
Next

Return(aRetPer)
