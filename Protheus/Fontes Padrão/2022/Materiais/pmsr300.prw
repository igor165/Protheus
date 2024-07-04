#INCLUDE "protheus.ch"
#INCLUDE "pmsr300.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

//------------------------------------RELEASE 4------------------------------------//
Function PMSR300()
	Local oReport

	If PMSBLKINT()
		Return Nil
	EndIf

	oReport := ReportDef()

	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	

	oReport:PrintDialog()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Paulo Carnelossi    � Data �  21/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportDef()
Local cPerg		:= "PMR300"
Local cDesc1   := STR0001 //"Este relatorio ira imprimir a consulta gerencial solicitada e o cronograma financeiro previsto x realizado para execucao dos projetos/EDTs/Tarefas cadastrados na consulta."
Local cDesc2   := ""
Local cDesc3   := ""

Local oReport
Local oConsGerProj
Local oFluxo
Local nX

Local aOrdem  := {}

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

oReport := TReport():New("PMSR300",STR0002, cPerg, ;
			{|oReport| ReportPrint(oReport)},;
			cDesc1 )
//STR0002 "Consulta Gerencial - Cronograma Financeiro Previsto x Realizado"

oConsGerProj := TRSection():New(oReport, STR0011, { "AJ8" }, aOrdem /*{}*/, .F., .F.)
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
TRCell():New(oConsGerProj,	"AJ8_CODPLA"	,"AJ8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
oConsGerProj:SetLineStyle()

//-------------------------------------------------------------
oFluxo := TRSection():New(oReport, STR0012, , /*{aOrdem}*/, .F., .F.)
TRCell():New(oFluxo, "AJ8_CONTAG"		,"AJ8"	,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oFluxo, "AJ8_DESCCG"		,"AJ8"	,/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oFluxo, "AJ8_INDIC" ,"","P/R"/*Titulo*/,"@!"/*Picture*/,1/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

For nX := 1 TO 6   // no relat�rio deve ter sempre 6 periodos
	TRCell():New(oFluxo, "PERIODO-"+Str(nX,1)+"_V","","Periodo-"+Str(nX,1)+CRLF+STR0009/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Valor"
	TRCell():New(oFluxo, "PERIODO-"+Str(nX,1)+"_P","","Periodo-"+Str(nX,1)+CRLF+STR0010/*Titulo*/,"@E 999%"/*Picture*/,4/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Perc."
Next

oFluxo:Cell("AJ8_DESCCG"):SetLineBreak()
oFluxo:SetHeaderPage()
oFluxo:SetColSpace(0) 

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor  �Paulo Carnelossi    � Data � 21/08/06  ���
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

Local dAuxFim
Local dAuxIni
Local aAuxImp  := {}

Private lIniData	:= Empty(mv_par02).Or.empty(mv_par03)

oReport:SetMeter(Max(100,AJ8->(LastRec())))

dbSelectArea("AJ8")
dbSetOrder(1)
If dbSeek(xFilial()+mv_par01)
	aHandleTot1	:= PmsIniGCRE(mv_par01,CTOD("31/12/2025"))
	aHandleTot2 := PmsIniGCTP(mv_par01,CTOD("31/12/2025"))
	aAuxImp  := {}
	dAuxFim	 := Nil
	Do Case
		Case mv_par04==1
			dAuxIni := mv_par02
		Case mv_par04==2
			dAuxIni := mv_par02
			If DOW(dAuxIni)<>1
				dAuxIni -= DOW(dAuxIni)-1
			EndIf
		Case mv_par04==3
			dAuxIni := CTOD("01/"+StrZero(MONTH(mv_par02),2,0)+"/"+StrZero(YEAR(mv_par02),4,0))-1
	EndCase
	While dAuxFim==Nil .Or. dAuxFim < mv_par03
		Do Case
			Case mv_par04 == 1
				dAuxFim := dAuxIni+5
			Case mv_par04==2
				dAuxFim := dAuxIni+(5*7)
			Case mv_par04==3
				dAuxFim := dAuxIni+(5*31)
				dAuxFim := CTOD("01/"+StrZero(MONTH(dAuxFim),2,0)+"/"+StrZero(YEAR(dAuxFim),4,0))-1
		EndCase
		dx := dAuxIni
		While dx <= dAuxFim
			aHandle	:= PmsIniGCRE(mv_par01,dx)
			aHandle2:= PmsIniGCTP(mv_par01,dx)
			AJ8->(dbSeek(xFilial()+mv_par01))
			While !Eof() .And. AJ8->AJ8_FILIAL+AJ8->AJ8_CODPLA==xFilial()+mv_par01
				PmR300_Add(oReport,aAuxImp,2,AJ8->AJ8_CONTAG,AJ8->(RecNo()))
				PmR300_Add(oReport,aAuxImp,4,AJ8->AJ8_CONTAG,AJ8->(RecNo()))				
				dbSkip()
			End
			Do Case
				Case mv_par04 == 1
					dx++
				Case mv_par04==2
					dx+= 7
				Case mv_par04==3
					dx+= 35
					dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
			EndCase
		End
		dAuxIni := dx
	End
	
	PmR300_Imp(oReport, aAuxImp)      
	oReport:EndPage()
	
EndIf

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Program   � PMR300_Add  � Autor � Edson Maricate      � Data �21.06.2001���
���          �             �       � Paulo Carnelossi(R4)�      �21.08.2006���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega o array de impressao                                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMR300_Add()                                                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function PmR300_Add(oReport, aAuxImp,nPosArray,cEntidade,nRecno)
Local aArea    := {}
Local x        := 0

Aadd( aArea, AJ8->( GetArea() ) )
Aadd( aArea, GetArea() )

oReport:IncMeter()

nPosAux := aScan(aAuxImp,{|x|x[1]=="AJ8" .And. x[2]==nRecNo })
If nPosAux <= 0
	aAdd(aAuxImp,{"AJ8",nRecNo,{},0,.T.,0,0,.T.,0})
	nPosAux := Len(aAuxImp)
EndIf
If nPosArray==4
	aAuxImp[nPosAux][4] := PmsRetCGER(aHandleTot1,cEntidade)[1]
	aAuxImp[nPosAux][7] := PmsRetCGER(aHandleTot2,cEntidade)[1]
Else
	aAdd(aAuxImp[nPosAux][3],{dx,PmsRetCGER(aHandle,cEntidade)[1],PmsRetCGER(aHandle2,cEntidade)[1]})
EndIf

For x := 1 to Len(aArea)
	RestArea(aArea[x])
Next
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Program   � PMR300_Imp  � Autor � Edson Maricate      � Data �21.06.2001���
���          �             �       � Paulo Carnelossi(R4)�      �21.08.2006���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega o array de impressao                                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMR300_Imp()                                                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Pmr300_Imp(oReport, aAuxImp)

Local oConsGerProj := oReport:Section(1)
Local oFluxo := oReport:Section(2)

Local dAuxFim
Local dAuxIni
Local dCabFim
Local nX		:= 0


Do Case
	Case mv_par04==1
		dAuxIni := mv_par02
	Case mv_par04==2
		dAuxIni := mv_par02
		If DOW(dAuxIni)<>1
			dAuxIni -= DOW(dAuxIni)-1
		EndIf
	Case mv_par04==3
		dAuxIni := CTOD("01/"+StrZero(MONTH(mv_par02),2,0)+"/"+StrZero(YEAR(mv_par02),4,0))-1
EndCase
dCabIni := dAuxIni

Do Case
	Case mv_par04 == 1
		dCabFim := dCabIni+5
	Case mv_par04==2
		dCabFim := dCabIni+(5*7)
	Case mv_par04==3
		dCabFim := dCabIni+(5*31)
		dCabFim := CTOD("01/"+StrZero(MONTH(dCabFim),2,0)+"/"+StrZero(YEAR(dCabFim),4,0))-1
EndCase

dx := dCabIni
nPeriodo := 1

While dx <= dCabFim
	oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetTitle(CRLF+STR0009)  //"Valor"
	oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetTitle(DTOC(dx)+CRLF+"%"+STR0010)  //"Perc."
	nPeriodo++
	Do Case
		Case mv_par04 == 1
			dx++
		Case mv_par04==2
			dx+= 7
		Case mv_par04==3
			dx+= 35
			dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
	EndCase
End

If Len(aAuxImp) > 0
	AJ8->(dbGoto(aAuxImp[1,2]))
EndIf

oConsGerProj:Init()
oConsGerProj:PrintLine()
oConsGerProj:Finish()

oReport:SkipLine()

oFluxo:Init()

While dAuxFim==Nil .Or. dAuxFim < mv_par03

	If oReport:Cancel()
		Exit
	Endif

	oReport:IncMeter()

	Do Case
		Case mv_par04 == 1
			dAuxFim := dAuxIni+5
		Case mv_par04==2
			dAuxFim := dAuxIni+(5*7)
		Case mv_par04==3
			dAuxFim := dAuxIni+(5*31)
			dAuxFim := CTOD("01/"+StrZero(MONTH(dAuxFim),2,0)+"/"+StrZero(YEAR(dAuxFim),4,0))-1
	EndCase
	For nx := 1 to Len(aAuxImp)
		AJ8->(dbGoto(aAuxImp[nx,2])) 
		If mv_par06==1 .Or. AJ8->AJ8_TIPO=='1'
			nColuna := 0
			dx := dAuxIni
			oFluxo:Cell("AJ8_INDIC"):SetValue("P")
			oFluxo:Cell("AJ8_CONTAG"):Show()
			oFluxo:Cell("AJ8_DESCCG"):Show()
			nPeriodo := 1
			
			While dx <= dAuxFim
				If !Empty(aAuxImp[nx,3]) 
					nPos := aScan(aAuxImp[nx][3],{|x|x[1]==dx})
					If nPos > 0 .And. aAuxImp[nx,8]
						
						If (aAuxImp[nx,3,npos,3]/aAuxImp[nx,7]*100) >= 100
							aAuxImp[nx,8] := .F.
						EndIf
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(If(mv_par05==1,aAuxImp[nx,3,npos,3],aAuxImp[nx,3,npos,3]-aAuxImp[nx,9]))
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(If(mv_par05==1,aAuxImp[nx,3,npos,3],aAuxImp[nx,3,npos,3]-aAuxImp[nx,9])/aAuxImp[nx,7]*100)
						aAuxImp[nx][9] := aAuxImp[nx,3,npos,3]
					Else
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(0)
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(0)
					EndIf
					nPeriodo++
				EndIf
				Do Case
					Case mv_par04 == 1
						dx++
					Case mv_par04==2
						dx+= 7
					Case mv_par04==3
						dx+= 35
						dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
				EndCase
				nColuna++
			End
			oFluxo:PrintLine()

			nColuna := 0
			dx := dAuxIni
			oFluxo:Cell("AJ8_INDIC"):SetValue("R")
			oFluxo:Cell("AJ8_CONTAG"):Hide()
			oFluxo:Cell("AJ8_DESCCG"):Hide()
			nPeriodo := 1
			
			
			While dx <= dAuxFim
				If !Empty(aAuxImp[nx,3])
					nPos := aScan(aAuxImp[nx][3],{|x|x[1]==dx})
					If nPos > 0 .And. aAuxImp[nx,5]
						If (aAuxImp[nx,3,npos,2]/aAuxImp[nx,4]*100) >= 100
							aAuxImp[nx,5] := .F.
						EndIf
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(If(mv_par05==1,aAuxImp[nx,3,npos,2],aAuxImp[nx,3,npos,2]-aAuxImp[nx,6]))
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(If(mv_par05==1,aAuxImp[nx,3,npos,2],aAuxImp[nx,3,npos,2]-aAuxImp[nx,6])/aAuxImp[nx,4]*100)
						aAuxImp[nx][6] := aAuxImp[nx,3,npos,2]
					Else
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(0)
						oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(0)
					EndIf
					nPeriodo++
				EndIf
				Do Case
					Case mv_par04 == 1
						dx++
					Case mv_par04==2
						dx+= 7
					Case mv_par04==3
						dx+= 35
						dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
				EndCase
				nColuna++
			End
			oFluxo:PrintLine()
		EndIf
	Next
	
	dAuxIni := dx
	dCabIni := dx
	Do Case
		Case mv_par04 == 1
			dCabFim := dCabIni+5
		Case mv_par04==2
			dCabFim := dCabIni+(5*7)
		Case mv_par04==3
			dCabFim := dCabIni+(5*31)
			dCabFim := CTOD("01/"+StrZero(MONTH(dCabFim),2,0)+"/"+StrZero(YEAR(dCabFim),4,0))-1
	EndCase
	
	dx := dCabIni
	nPeriodo := 1
	
	While dx <= dCabFim

		oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetTitle(CRLF+STR0009)  //"Valor"
		oFluxo:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetTitle(DTOC(dx)+CRLF+"%"+STR0010)  //"Perc."
		nPeriodo++
		
		Do Case
			Case mv_par04 == 1
				dx++
			Case mv_par04==2
				dx+= 7
			Case mv_par04==3
				dx+= 35
				dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
		EndCase
	End

	If dAuxFim < mv_par03
		oReport:EndPage()
	EndIf

End

oFluxo:Finish()

Return