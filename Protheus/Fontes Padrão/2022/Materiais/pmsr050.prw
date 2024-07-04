#include "protheus.ch"
#include "PMSR050.ch"

#define CHRCOMP If(aReturn[4]==1,15,18)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �Pmsr050   � Autor � Fabio Rogerio Pereira   � Data � 29.07.02 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao da Curva ABC valor orcado dos recursos do orcamento ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                        ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                           ���
���������������������������������������������������������������������������Ĵ��
���          �               �                                              ��� 
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function PmsR050()
//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Orcamento de ?                                              �
//� MV_PAR02 : Ate?                                                        �
//� MV_PAR03 : Data validade de                                   		   �
//� MV_PAR04 : Data validade ate                                   		   �
//��������������������������������������������������������������������������

Local oReport := Nil

If PMSBLKINT()
	Return Nil
EndIf

Pergunte("PMR050", .F.)

oReport := ReportDef()
oReport:PrintDialog()

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
Local cTitulo  := STR0002 //"Quantitativos previstos"
Local oReport
Local oOrcto

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
oReport := TReport():New("PMSR050",STR0002,"PMR050", ;
			{|oReport| ReportPrint(oReport)},;
			STR0001)
//STR0002 //"Quantitativos previstos"
//STR0001 //"Este relat�rio ir� imprimir os quantitativos previstos para a execu��o do orcamento de acordo com parametros solicitados. "


//������������������������������������������������������������������������Ŀ
//�Alimentar Array aOrdem com as Ordens Disponiveis no relatorio           �
//�observe que estas ordens nao sao do banco de dados e sim do Array       �
//��������������������������������������������������������������������������
aAdd(aOrdem, STR0003) //"ORCAMENTO+PRODUTO+DESPESA"
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
oOrcto := TRSection():New(oReport,STR0013,{"AF1", "SA1"}, aOrdem/*{}*/, .F., .F.) //"Or�amento"
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
TRCell():New(oOrcto,	"AF1_ORCAME"	,"AF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AF1->AF1_ORCAME})
TRCell():New(oOrcto,	"AF1_DESCRI"	,"AF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AF1->AF1_DESCRI})

TRPosition():New(oOrcto, "SA1", 1, {|| xFilial("SA1") + AF1->AF1_CLIENT})

oOrcto:SetLineStyle()

//---CRIAR UMA SECTION PARA CADA ORDEM DO RELATORIO----------------------------//

//-----------------------------------------------------------------------------//

aAdd(aOrdem, STR0003) //"ORCAMENTO+PRODUTO+DESPESA"
aAdd(aOrdem, STR0004) //"TAREFA+PRODUTO+DESPESA"

oABCOrdem1 := TRSection():New(oReport, STR0016 + STR0014, {"AF1"}, {}, .F., .F.)
TRCell():New(oABCOrdem1	,"TIPO"       ,"SB1","Tipo"/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"B1_COD"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"B1_DESC"    ,"SB1",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"B1_UM"      ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"AF3_QUANT"  ,"AF3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"AF3_CUSTD"  ,"AF3","Valor"/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"AF3_CUSTD1" ,"AF3","% Proj."/*Titulo*/,"@E 999.99%"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem1	,"AF3_CUSTD2" ,"AF3","% Acum."/*Titulo*/,"@E 999.99%"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

//-----------------------------------------------------------------------------//
oABCOrdem2 := TRSection():New(oReport, STR0016 + STR0015, {"AF2"}, {}, .F., .F.)

TRCell():New(oABCOrdem2	,"AF2_TAREFA" ,"AF2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AF2_DESCRI" ,"AF2",/*Titulo*/,/*Picture*/,19/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"TIPO"       ,"SB1","Tipo"/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"B1_COD"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"B1_DESC"    ,"SB1",/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"B1_UM"      ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AF3_QUANT"  ,"AF3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AF3_CUSTD"  ,"AF3","Valor"/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AF3_CUSTD1" ,"AF3","% Proj."/*Titulo*/,"@E 999.99%"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oABCOrdem2	,"AF3_CUSTD2" ,"AF3","% Acum."/*Titulo*/,"@E 999.99%"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor  �Paulo Carnelossi  � Data �  08/15/06   ���
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
Local oOrcto   := oReport:Section(1)
Local oABCOrdPrint := oReport:Section(oOrcto:GetOrder()+1)
Local oBreak, oTotal
Local oBreak1, oTotal1
Local lBreak   := .F.

Local aABC	   := {}
Local nCusto   := 0
Local nCustoTsk:= 0
Local nX       := 0
Local nPerAcum := 0
Local lEncontr := .F.
/*
*/
//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Orcamento de ?                                              �
//� MV_PAR02 : Ate?                                                        �
//� MV_PAR03 : Data validade de                                   		   �
//� MV_PAR04 : Data validade ate                                   		   �
//� MV_PAR05 : Fase ?                                                      �
//��������������������������������������������������������������������������
oReport:SetMeter(50)

dbSelectArea("AF1")
dbSetOrder(1)

If Empty(mv_par01)
   lEncontr := MsSeek(xFilial("AF1"))
Else
   lEncontr := MsSeek(xFilial("AF1") + mv_par01)
EndIf   

If lEncontr

	If oOrcto:GetOrder() == 1

		oABCOrdPrint:Cell("TIPO")       :SetBlock({|| aABC[nX,1]})
		oABCOrdPrint:Cell("B1_COD")     :SetBlock({|| If(aABC[nX,1]=="PRD", SB1->B1_COD,;
														If(aABC[nX,1]=="REC",AE8->AE8_RECURS,aABC[nx,2]) )})
		oABCOrdPrint:Cell("B1_DESC")    :SetBlock({|| If(aABC[nX,1]=="PRD", SB1->B1_DESC,;
														If(aABC[nX,1]=="REC",AE8->AE8_DESCRI,aABC[nX,2]) )})
		oABCOrdPrint:Cell("B1_UM")      :SetBlock({|| If(aABC[nX,1]=="PRD", SB1->B1_UM,;
														If(aABC[nX,1]=="REC","HR","") )})
		oABCOrdPrint:Cell("AF3_QUANT")  :SetBlock({|| aABC[nX,4] })
		oABCOrdPrint:Cell("AF3_CUSTD")  :SetBlock({|| aABC[nX,5] })
		oABCOrdPrint:Cell("AF3_CUSTD1") :SetBlock({|| aABC[nX,5]/nCusto*100 })
		oABCOrdPrint:Cell("AF3_CUSTD2") :SetBlock({|| nPerAcum })
		
		oBreak:= TRBreak():New(oABCOrdPrint,{||.T.},STR0010)
		oTotal := TRFunction():New(oABCOrdPrint:Cell("AF3_CUSTD"),"NCUSTO" ,"ONPRINT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		oTotal:SetFormula({||nCusto})
		oTotal:SetTotalInLine(.F.) 

	Else

		oABCOrdPrint:Cell("AF2_TAREFA") :SetBlock({|| AF2->AF2_TAREFA })
		oABCOrdPrint:Cell("AF2_DESCRI") :SetBlock({|| AF2->AF2_DESCRI })
		oABCOrdPrint:Cell("TIPO")       :SetBlock({|| aABC[nX,1]})
		oABCOrdPrint:Cell("B1_COD")     :SetBlock({|| If(aABC[nX,1]=="PRD", SB1->B1_COD,;
														If(aABC[nX,1]=="REC",AE8->AE8_RECURS,Substr(aABC[nx,2],1,20)) )})
		oABCOrdPrint:Cell("B1_DESC")    :SetBlock({|| If(aABC[nX,1]=="PRD", SB1->B1_DESC,;
														If(aABC[nX,1]=="REC",AE8->AE8_DESCRI,aABC[nX,2]) )})
		oABCOrdPrint:Cell("B1_UM")      :SetBlock({|| If(aABC[nX,1]=="PRD", SB1->B1_UM,;
													If(aABC[nX,1]=="REC","HR","") )})
		oABCOrdPrint:Cell("AF3_QUANT")  :SetBlock({|| aABC[nX,4] })
		oABCOrdPrint:Cell("AF3_CUSTD")  :SetBlock({|| aABC[nX,5] })
		oABCOrdPrint:Cell("AF3_CUSTD1") :SetBlock({|| aABC[nX,5]/nCusto*100 })
		oABCOrdPrint:Cell("AF3_CUSTD2") :SetBlock({|| nPerAcum })

		oBreak1:= TRBreak():New(oABCOrdPrint,{|| lBreak := !lBreak },STR0010)
		oTotal1:= TRFunction():New(oABCOrdPrint:Cell("AF3_CUSTD"),"NCUSTOTSK" ,"SUM",oBreak1,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		oTotal1:SetFormula({||aABC[nx,5] })
		oTotal1:SetTotalInLine(.F.) 

		oBreak:= TRBreak():New(oABCOrdPrint,{||.T.},STR0010)
		oTotal := TRFunction():New(oABCOrdPrint:Cell("AF3_CUSTD"),"NCUSTO" ,"ONPRINT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
		oTotal:SetFormula({||nCusto})
		oTotal:SetTotalInLine(.F.) 
	
	EndIf
		
    oOrcto:Init()

	While AF1->(!Eof() .And. AF1_ORCAME >= Mv_Par01 .And. AF1_ORCAME <= Mv_Par02) .AND. !oReport:Cancel()

		// avalia se o orcamento e valido
		If !Empty(AF1->AF1_VALID) .And. (AF1->AF1_VALID < Mv_Par03) .Or. (AF1->AF1_VALID > Mv_Par04) .Or.;
			!PmrPertence(AF1->AF1_FASE,Mv_Par05)
		      
			dbSelectArea("AF1")
			dbSkip()
			Loop
		EndIf
	
		oReport:IncMeter()
	
		// carrega os valores do orcamento
		Pmr050_Ini( oOrcto, @aABC, @nCusto)
	
		If (Len(aABC) > 0)
		
			oOrcto:PrintLine()
			oABCOrdPrint:Init()

			For nX:= 1 To Len(aABC)
			
				If oReport:PageBreak()
					oABCOrdPrint:lPrintHeader := .T.
				EndIf

				Do Case 
					Case oOrcto:GetOrder()  == 1 //Por Orcamento
						If aABC[nx,1]=="PRD"
							SB1->(dbSetOrder(1))
							SB1->(MsSeek(xFilial("SB1") + aABC[nx,2]))
							nPerAcum += aABC[nx,5]/nCusto*100

		
						ElseIf aABC[nx,1]=="REC"
							AE8->(dbSetOrder(1))
							AE8->(MsSeek(xFilial("AE8") + aABC[nx,2]))
							nPerAcum += aABC[nx,5]/nCusto*100

						ElseIf aABC[nx,1]=="DSP"
							nPerAcum += aABC[nx,5]/nCusto*100
							//Esconde  as celulas que nao vao ser impressas
							oABCOrdPrint:Cell("B1_DESC"):Hide()
							oABCOrdPrint:Cell("B1_UM"):Hide()
							oABCOrdPrint:Cell("AF3_QUANT"):Hide()

						EndIf
						
						oABCOrdPrint:PrintLine()
						
						If aABC[nx,1]=="DSP"  //volta a exibir as celulas
							//Esconde  as celulas que nao vao ser impressas
							oABCOrdPrint:Cell("B1_DESC"):Show()
							oABCOrdPrint:Cell("B1_UM"):Show()
							oABCOrdPrint:Cell("AF3_QUANT"):Show()
                        EndIf
							
					Case oOrcto:GetOrder()  == 2 //Por Tarefa
						nCustoTsk+= aABC[nx,5]
						AF2->(dbSetOrder(1))
						AF2->(dbSeek(xFilial("AF2")+AF1->AF1_ORCAME+aABC[nx,3]))
		
						If aABC[nx,1] == "PRD"
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(xFilial("SB1")+aABC[nx,2]))
							nPerAcum += aABC[nx,5]/nCusto*100
							
						ElseIf aABC[nx,1]=="REC"
							AE8->(dbSetOrder(1))
							AE8->(MsSeek(xFilial("AE8") + aABC[nx,2]))
							nPerAcum += aABC[nx,5]/nCusto*100

						ElseIf aABC[nx,1] == "DSP"
							nPerAcum += aABC[nx,5]/nCusto*100
							//Esconde  as celulas que nao vao ser impressas
							oABCOrdPrint:Cell("B1_DESC"):Hide()
							oABCOrdPrint:Cell("B1_UM"):Hide()
							oABCOrdPrint:Cell("AF3_QUANT"):Hide()

						EndIf
						
						oABCOrdPrint:PrintLine()
						
						If aABC[nx,1]=="DSP"  //volta a exibir as celulas
							//Esconde  as celulas que nao vao ser impressas
							oABCOrdPrint:Cell("B1_DESC"):Show()
							oABCOrdPrint:Cell("B1_UM"):Show()
							oABCOrdPrint:Cell("AF3_QUANT"):Show()
                        EndIf
                        
		        EndCase
		        
				If oOrcto:GetOrder()  == 2 //Por Tarefa	
					nCustoTsk:= 0
				EndIf
			Next    
		    
			oABCOrdPrint:Finish()
			nCusto := 0
			nPerAcum:=0

		EndIf    
	
		dbSelectArea("AF1")
		dbSkip()
	End
	
	If oReport:Cancel()
		oReport:Say( oReport:Row()+1 ,10 ,STR0017) //"*** CANCELADO PELO OPERADOR ***"
	EndIf
	
	oOrcto:Finish()
	
EndIf

Return .T.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Program   � PMR050_Ini  � Autor �Fabio Rogerio Pereira� Data �29.07.2002���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Avalia os dados do orcamento								   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �Pmr050_Ini(aPar1, nPar1)				                       ���
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Static Function Pmr050_Ini(oOrcto,aABC,nCusto)
Local aArea    := GetArea()
Local nPos     := 0
Local nQuantAF3:= 0
Local nValorAF4:= 0

aABC :={}
dbSelectArea("AF2")
dbSetOrder(1)
If MsSeek(xFilial("AF2")+AF1->AF1_ORCAME)
	While !Eof() .And. (xFilial("AF2")+AF1->AF1_ORCAME == AF2->AF2_FILIAL+AF2->AF2_ORCAME)

//		oReport:IncMeter()

		// verifica os produtos do orcamento
		dbSelectArea("AF3")
		dbSetOrder(1)
		If MsSeek(xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
			While !Eof() .And. (xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA == AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA)

				// avalia o filtro dos produtos
				If !Empty(AF3->AF3_PRODUT)
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1") + AF3->AF3_PRODUT ))
					
					If !Empty(oOrcto:GetAdvplExp()) .And. SB1->(!&(oOrcto:GetAdvplExp()))
						dbSelectArea("AF3")
						dbSkip()
						Loop
					EndIf
				EndIf

				If oOrcto:GetOrder()  == 1 //Por Orcamento
					If (Empty(AF3->AF3_RECURS))
						nPos     := aScan(aABC,{|x| x[1] == "PRD" .And. x[2] == AF3->AF3_PRODUT})
					Else                                                                         
						nPos     := aScan(aABC,{|x| x[1] == "REC" .And. x[2] == AF3->AF3_RECURS})
					EndIf
				Else //Por Tarefa
					If (Empty(AF3->AF3_RECURS))
						nPos     := aScan(aABC,{|x| x[1] == "PRD" .And. x[2] == AF3->AF3_PRODUT .And. x[3]== AF3->AF3_TAREFA})
					Else                                                                         
						nPos     := aScan(aABC,{|x| x[1] == "REC" .And. x[2] == AF3->AF3_RECURS .And. x[3]== AF3->AF3_TAREFA})
					EndIf
				EndIf

				nQuantAF3:= PmsAF3Quant(AF3->AF3_ORCAME,AF3->AF3_TAREFA,AF3->AF3_PRODUT,AF2->AF2_QUANT,AF3->AF3_QUANT)
				If (nPos > 0)
					aABC[nPos,4]+= nQuantAF3
					aABC[nPos,5]+= xMoeda(nQuantAF3 * AF3->AF3_CUSTD,AF3->AF3_MOEDA,1)
				Else
					If (Empty(AF3->AF3_RECURS))
						aAdd(aABC,{"PRD",AF3->AF3_PRODUT,AF3->AF3_TAREFA,nQuantAF3,xMoeda(nQuantAF3 * AF3->AF3_CUSTD,AF3->AF3_MOEDA,1),AF3->AF3_ORCAME})
					Else                                                                                                                                            
						aAdd(aABC,{"REC",AF3->AF3_RECURS,AF3->AF3_TAREFA,nQuantAF3,xMoeda(nQuantAF3 * AF3->AF3_CUSTD,AF3->AF3_MOEDA,1),AF3->AF3_ORCAME})
					Endif
				EndIf
				
				nCusto += xMoeda(nQuantAF3 * AF3->AF3_CUSTD,AF3->AF3_MOEDA,1)
				dbSelectArea("AF3")
				dbSkip()
			End
		EndIf
	
		//����������������������������������Ŀ
		//�Verifica as despesa do orcamento. �
		//������������������������������������
		dbSelectArea("AF4")
		dbSetOrder(1)
		If MsSeek(xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
			While !Eof() .And. (xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA == AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA)
								
//				oReport:IncMeter()

				If oOrcto:GetOrder()  == 1 //Por Orcamento
					nPos     := aScan(aABC,{|x| x[1] == "DSP" .And. x[2] == AF4->AF4_DESCRI})
				Else //Por Tarefa
					nPos     := aScan(aABC,{|x| x[1] == "DSP" .And. x[2] == AF4->AF4_DESCRI .And. x[3] == AF4->AF4_TAREFA})
				EndIf

				nValorAF4:= PmsAF4Valor(AF2->AF2_QUANT,AF4->AF4_VALOR)
				If (nPos > 0)
					aABC[nPos,5]+= xMoeda(nValorAF4,AF4->AF4_MOEDA,1)
				Else
					aAdd(aABC,{"DSP",AF4->AF4_DESCRI,AF4->AF4_TAREFA,0,xMoeda(nValorAF4,AF4->AF4_MOEDA,1),AF4->AF4_ORCAME})
				EndIf
				
				nCusto += xMoeda(nValorAF4,AF4->AF4_MOEDA,1)
			
				dbSelectArea("AF4")
				dbSkip()
			End
		EndIf

		dbSelectArea("AF2")
		dbSkip()
	End
EndIf	

RestArea(aArea)
Return