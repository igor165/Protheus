#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FISR014.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FISR014   �Autor  � Marcos Kato       � Data �   03/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Certificado de reten��o                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Equador                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FISR014(alDados)

/*
�������������������������������������������������������������������Ŀ
� Observacao :                                                      �
�                                                                   �
� o vetor alDados recebido como parametro pelo FISA015 deve conter: �
� [x,01] > Numero do certificado                                    �
� [x,02] > Data Emissao                                             �
� [x,03] > Codigo do Cliente\Fornecedor                             �
� [x,04] > Loja                                                     �
� [x,05] > Tipo                                                     �
� [x,06] > Numero da Fatura                                         �
� [x,07] > Serie da Fatura                                          �
� [x,08] > Base de calculo da retencao                              �
� [x,09] > Aliquota para o calculo                                  �
� [x,10] > Filial que est� gerando o certificado                    �
� [x,11] > Valor do imposto da retencao                             �
� [x,12] > Valor da retencao                                        �
� [x,13] > Codigo fiscal da operacao                                �
� [x,14] > Codigo retenca                                           �
� [x,15] > Numero autorizacao                                       �
� [x,16] > Esp�cie da nota                                          �
� [x,17] > Tipo (C-Cliente/F-Fornecedor)                            �
���������������������������������������������������������������������
*/

Private opReport := Nil
Private apDados  := {}
Default alDados  := {}

If TRepInUse()
	opReport:=GeraReport(alDados)
	opReport:PrintDialog()
Endif

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraReport�Autor  �Marcos Kato       � Data �   03/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria o objeto do relatorio e o configura.                  ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GeraReport(alDados)

Local olReport := Nil

olReport:= TReport():New("FISR014",STR0001,,{|opReport|PrintReport(alDados)},"") //"Comprovante de Retencao"
olReport:lHeaderVisible		:= .F. // N�o imprime cabe�alho do protheus
olReport:lFooterVisible		:= .F. // N�o imprime rodap� do protheus
olReport:lParamPage			:= .F. // N�o imprime pagina de parametros
olReport:oPage:nPaperSize	:= 9   // Impress�o em papel A4
olReport:NFONTBODY			:= 12  // Tamanho da fonte

Return olReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrintReport�Autor  �Ivan Haponczuk     � Data �  14/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime o relatorio a partir do array.                     ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(apDados)

	Local nlX        := 0
	Local nlY        := 0	
	Local nlLin      := 0
	Local clEmissao  := ""
	Local cImprRaz   := ""
	Local cImprRuc   := ""
	Local cImprDt    := "" 
	Local lFISR014CP := ExistBlock("FIR014CP")
	
	If lFISR014CP
		ExecBlock("FIR014CP",.F.,.F.)
	EndIf
	
	If ! lFISR014CP	
		  
		cNumCert:=""       
		apDados:=aSort( apDados,,, { | x , y | x[1] < y[1] } )
		For nlX:=1 To Len(apDados)
			opReport:PrintText("",0100,0800)
	
			opReport:PrintText(SM0->M0_NOMECOM                          	,0140,0080)
			opReport:PrintText(STR0002+":"+" "+SM0->M0_CGC                  ,0140,1500)//"RUC" 
			opReport:PrintText(SM0->M0_NOME   								,0200,0080)
			opReport:PrintText(Upper(STR0001)							  	,0200,1500)//"Comprovante de Retencao" 
			opReport:PrintText(Alltrim(SM0->M0_ENDENT)+", "+SM0->M0_CIDENT	,0260,0080)		
	
			opReport:PrintText(STR0003+":"+" "+apDados[nlX,1]         		,0260,1500)//"No.Certificado" 
			opReport:PrintText(STR0004+":"+" "+apDados[nlX,15]        		,0300,1500)//"No.Autorizacao" 
			opReport:Line(0380,0080,0380,2410)

			If apDados[nlX,17] == "C"
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				SA1->(dbGoTop())
				SA1->(dbSeek(xFilial("SA1")+AvKey(apDados[nlX,3],"A1_COD")+AvKey(apDados[nlX,4],"A1_LOJA")))
				opReport:PrintText(STR0032+":"+" "+SA1->A1_NOME                         ,0440,0080)              //Sr.(es)
				opReport:PrintText(STR0002+":"+" "+SA1->A1_CGC                          ,0500,0080)              //RUC
				opReport:PrintText(STR0006+":"+" "+SubStr(ALLTRIM(SA1->A1_END)+", "+SA1->A1_MUN,1,50),0560,0080) //Endere�o
			Else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				SA2->(dbGoTop())
				SA2->(dbSeek(xFilial("SA2")+AvKey(apDados[nlX,3],"A2_COD")+AvKey(apDados[nlX,4],"A2_LOJA")))
				opReport:PrintText(STR0032+":"+" "+SA2->A2_NOME                         ,0440,0080)              //Sr.(es)
				opReport:PrintText(STR0002+":"+" "+SA2->A2_CGC                          ,0500,0080)              //RUC
				opReport:PrintText(STR0006+":"+" "+SubStr(ALLTRIM(SA2->A2_END)+", "+SA2->A2_MUN,1,50),0560,0080) //Endere�o
			EndIf
			
			opReport:PrintText(STR0033+":"+" "+apDados[nlX,16]                ,0500,1500)//"Tipo do comprovante de venda" 
			opReport:PrintText(STR0034+":"+" "+apDados[nlX,07]+""+apDados[nlX,06],0560,1500)//"N� do comprovante de venda"

			opReport:Box(0620,0080,1820,2410) 
			opReport:Line(0730,0080,0730,2410)   //Linha Horizontal
			
			opReport:Line(0620,0450,1820,0450)    //Linha Vertical 1
			opReport:Line(0620,0850,1820,0850)    //Linha Vertical 2
			opReport:Line(0620,1220,1820,1220)    //Linha Vertical 3
			opReport:Line(0620,1650,1820,1650)    //Linha Vertical 4
			opReport:Line(0620,2000,1820,2000)    //Linha Vertical 5
			opReport:PrintText(STR0007,0650,0115) //"Exer.Fiscal" 
			opReport:PrintText(STR0008,0650,0485) //"Base Calc.Ret."
			opReport:PrintText(STR0009,0650,0950) //"Imposto" 
			opReport:PrintText(STR0010,0650,1300) //"Cod.Imposto"
			opReport:PrintText(STR0011,0650,1700) //"% Retencao"
			opReport:PrintText(STR0012,0650,2050) //"Valor Retido"
			nlLin := 770
		
			For nlY:=nlX To Len(apDados)
				If apDados[nlX,1]<>apDados[nlY,1] .or. apDados[nlX,6]<>apDados[nlY,6] .or. apDados[nlX,7]<>apDados[nlY,7]
					Exit			
				Endif
				nlX:=nlY
				clEmissao := IIF(ValType(apDados[nlX,2])=="D",Substr(Dtos(apDados[nlX,2]),7,2)+"/"+Substr(Dtos(apDados[nlX,2]),5,2)+"/"+Substr(Dtos(apDados[nlX,2]),1,4),;
				Substr(apDados[nlX,2],7,2)+"/"+Substr(apDados[nlX,2],5,2)+"/"+Substr(apDados[nlX,2],1,4))      
	
				opReport:PrintText(clEmissao                                        ,nlLin,0145)
				opReport:PrintText(Transform(apDados[nlX,8],"@E 999,999,999.99")    ,nlLin,0500)
				opReport:PrintText(IIF(SubStr(apDados[nlX,5],1,1)=="I","IVA","RIR") ,nlLin,1000)
				opReport:PrintText(IIF(SubStr(apDados[nlX,5],1,1)=="I","",apDados[nlX,13]),nlLin,1400)
				opReport:PrintText(Transform(apDados[nlX,9] ,"@E %999.99")          ,nlLin,1750)
				opReport:PrintText(Transform(apDados[nlX,12],"@E 999,999,999.99")   ,nlLin,2060)
				nlLin += 40
        	Next
			nlLin := 1880
	
	
			nlLin += 240
			opReport:Line(nlLin,0080,nlLin,0810)
			nlLin += 060
			DbSelectArea("SFP")
			SFP->(DbSetOrder(7))
			If SFP->(DbSeek(xFilial("SFP")+cFilAnt+AvKey(apDados[nlX,15],"FP_NUMAUT")))
				cImprRaz:=SFP->FP_RZGRAF
				cImprRuc:=SFP->FP_RUCGRA
				cImprDt :=Dtoc(SFP->FP_DTAVAL)
			Endif
			opReport:PrintText(STR0013,nlLin,0080)//"Firma do Agente de Retencao" 
			opReport:PrintText(STR0014+":"+Space(1)+Substr(cImprDt,4,7),nlLin,1500) //"Valido para a emissao at�"
			nlLin += 120
			opReport:PrintText(cImprRaz,nlLin,0080) 
			nlLin += 060
			opReport:PrintText(STR0002+":"+Space(1)+cImprRuc,nlLin,0080)//RUC
			nlLin += 060		
			opReport:EndPage()
   		Next nlX
   	EndIf
   	
Return Nil