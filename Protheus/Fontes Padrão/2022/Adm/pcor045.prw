#INCLUDE "pcor045.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE CELLTAMDATA 		420
#DEFINE X_CLASSE 			aValorOrc[nX][2]
#DEFINE X_DESCLA 			aValorOrc[nX][3]
#DEFINE X_DESCRI 			aValorOrc[nX][4]
#DEFINE X_CC 				aValorOrc[nX][5]
#DEFINE X_DESCC			aValorOrc[nX][6]
#DEFINE X_ITCTB			aValorOrc[nX][7]
#DEFINE X_DESITCTB 		aValorOrc[nX][8]
#DEFINE X_CLVL 			aValorOrc[nX][9]
#DEFINE X_DESCLVL  		aValorOrc[nX][10]
#DEFINE X_OPER 			aValorOrc[nX][11]
#DEFINE X_PICTURE 		aValorOrc[nX][12]
#DEFINE X_VALOR 			aValorOrc[nX][13]
#DEFINE X_REGAK2			aValorOrc[nX][14]
#DEFINE X_PICTOTCO		"@E 999,999,999,999.99"


// INCLUIDO PARA TRADU��O DE PORTUGAL


//----------------------------NOVO RELATORIO RELEASE 4---------------------------//
Function PCOR045(aPerg)

PCOR045R4(aPerg)

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PCOR045R4 � Autor �Paulo Carnelossi       � Data �21/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao do Relatorio para release 4 utilizando obj tReport   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpA1: Array com conteudo dos MV_PAR do Pergunte            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PCOR045R4(aPerg)
Local aArea		:= GetArea()
Local nX
Local aNovPer		:= {}

Private aPeriodo 		:= {}

Private cRevisa
Private lContaOrc := .F.
Default aPerg := {}
Private aValores := {}
//OBSERVACAO NAO TIRAR A LINHA ABAIXO POIS SERA UTILIZADA NA CONSULTA PADRAO AKE1
Private M->AKR_ORCAME := Replicate("Z", Len(AKR->AKR_ORCAME))

If Len(aPerg) >  0
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
EndIf

Pergunte("PCR015", .T. )

If ! PcoR045Avalia()
    Return
EndIf

// obtem os periodos
aPeriodo := PcoRetPer()

aNovPer := {}   
For nX := 1 TO Len(aPeriodo)
	If DTOS(CTOD(PadR(aPeriodo[nX],10))) >= DTOS(mv_par03) .And. DTOS(CTOD(PadR(aPeriodo[nX],10))) <= DTOS(mv_par04)
		aAdd(aNovPer, aPeriodo[nX])
	EndIf
Next

aPeriodo := AClone(aNovPer)

If Empty(aPeriodo)
    HELP("  ",1,"PCOR0151")
    Return
EndIf
    
//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	

oReport:PrintDialog()

RestArea(aArea)
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PcoR045Avalia� Autor �Paulo Carnelossi    � Data �21/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao do botao OK da print Dialog obj tReport ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpA1: Array com conteudo dos MV_PAR do Pergunte            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PcoR045Avalia()
Local lOk := .T.

dbSelectArea("AK1")
dbSetOrder(1)
If MSSeek(xFilial()+MV_PAR01)
   	If !Empty(MV_PAR02)
   		dbSelectArea("AKE")
   		dbSetOrder(1)
   		If ! MSSeek(xFilial()+MV_PAR01+MV_PAR02)
   			MsgStop(STR0015) // Revisao nao encontrada. Verifique!
   			lOk := .F.
   		Else
   			cRevisa := MV_PAR02
   		EndIf
   		dbSelectArea("AKE")
   	Else			
      While AK1->(! Eof() .And. AK1_FILIAL+AK1_CODIGO == xFilial("AK1")+MV_PAR01)
		cRevisa	:= AK1->AK1_VERSAO
		nRecAK1 := AK1->(Recno())
        AK1->(dbSkip())
      End
      AK1->(dbGoto(nRecAK1))
   	EndIf
   	
   	If lOk
		lOk := (PcoVerAcessoPlan(2) > 0 )
   	EndIf	

EndIf

Return(lOk)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �21/06/2006���
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
Static Function ReportDef()

Local oReport
Local oContaOrc
Local oContaItens
Local nX
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
oReport := TReport():New("PCOR045",STR0001+" "+STR0018,"PCR015", ;
			{|oReport| ReportPrint(oReport)},;
			STR0001+" "+STR0018 )

oReport:ParamReadOnly()

//"Planilha Orcamentaria (Mod.2)"
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
oPlanilha := TRSection():New(oReport,STR0001,{"AK1"}, {}, .F., .F.)  //"Planilha Orcamentaria"

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
TRCell():New(oPlanilha,	"AK1_CODIGO"	,"AK1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AK1->AK1_CODIGO })
TRCell():New(oPlanilha,	"AK1_VERSAO"	,"AK1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cRevisa })
TRCell():New(oPlanilha,	"AK1_DESCRI"	,"AK1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AK1->AK1_DESCRI})
TRCell():New(oPlanilha,	"AK1_INIPER"	,"AK1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AK1->AK1_INIPER})
TRCell():New(oPlanilha,	"AK1_FIMPER"	,"AK1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AK1->AK1_FIMPER })
oPlanilha:SetLeftMargin(5)
oPlanilha:SetNoFilter({"AK1"})

oContaOrc := TRSection():New(oReport,STR0019,{"AK1","AK3","AK5"},/*aOrdem*/,.F.,.F.)  //"Contas Orcamentarias"
TRCell():New(oContaOrc	,"AK3_CO"		,"AK3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| PcoRetCo(AK3->AK3_CO)})
TRCell():New(oContaOrc	,"AK3_NIVEL"	,"AK3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AK3->AK3_NIVEL})
TRCell():New(oContaOrc	,"AK3_DESCRI"	,"AK3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AK3->(REPLICATE(".",(VAL(AK3_NIVEL)-1)*3)+AK3_DESCRI)})
TRCell():New(oContaOrc	,"AK3_TIPO"		,"AK3",/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| AK3->(If(AK3_TIPO $ " ;1",STR0010,STR0011))}) //"Sintetica"###"Analitica"
TRCell():New(oContaOrc	,"TOTAL_CO"		,""   ,STR0022/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/,"RIGHT",,"RIGHT")	// Total C.O.
oContaOrc:SetHeaderPage()
oContaOrc:SetRelation({ || xFilial('AK5')+AK3->AK3_CO }, "AK5", 1, .T.)

oContaOrc:SetNoFilter({"AK1","AK3","AK5"})

oContaItens := TRSection():New(oReport,STR0020+"-"+STR0019,{"AK2","AK6","CTT", "CTH", "CTD","AKF"},/*aOrdem*/,.F.,.F.)  //"Contas Orcamentarias"###"Itens"
TRCell():New(oContaItens	,"AK2_CLASSE"	,"AK2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"AK6_DESCRI"	,"AK6",STR0023/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"AK2_DESCRI"	,"AK2",STR0013/*Titulo*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"AK2_CC"		,"AK2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"CTT_DESC01"	,"CTT",/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"AK2_ITCTB"	,"AK2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"CTD_DESC01"	,"CTD",/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"AK2_CLVLR"	,"AK2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"CTH_DESC01"	,"CTH",/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
TRCell():New(oContaItens	,"AK2_OPER"		,"AK2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)

TrPosition():New(oContaItens, "AK6", 1, { || xFilial('AK6')+AK2->AK2_CLASSE	})
TrPosition():New(oContaItens, "AKF", 1, { || xFilial('AKF')+AK2->AK2_OPER  	})
TrPosition():New(oContaItens, "CTT", 1, { || xFilial('CTT')+AK2->AK2_CC	  	})
TrPosition():New(oContaItens, "CTD", 1, { || xFilial('CTD')+AK2->AK2_ITCTB	})
TrPosition():New(oContaItens, "CTH", 1, { || xFilial('CTH')+AK2->AK2_CLVLR	})

oContaItens:SetNoFilter({"AK2","AK6","CTT","CTH", "CTD","AKF"})

If Len(oContaItens:aSection) == 0 
	oValorItens := TRSection():New(oContaItens,STR0021,{},/*aOrdem*/,.F.,.F.)  //"Valores Orcados"
	oValorItens:SetLineBreak()
	For nX := 1 TO Len(aPeriodo)
		TRCell():New(oValorItens, "AK2_VALOR"+StrZero(nX,2),"","Valor Per."+StrZero(nX,2)/*Titulo*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*{|| code-block para impressao}*/)
	Next
EndIf	

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Paulo Carnelossi      � Data �29/05/2006���
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
Local aTotCO 		:= {}
Local aFilCO 		:= {}
Local aFilOper		:= {}
Local oPlanilha		:= oReport:Section(1)
Local oContaOrc 	:= oReport:Section(2)
    

// se imprime contas sinteticas e totaliza sinteticas por relatorio
If mv_par11 == 1 .And. mv_par12 == 1
	// filtra contas orcamentarias
	aFilCO := { mv_par05, mv_par06 }
EndIf	

// se imprime contas sinteticas e totaliza sinteticas por planilha
if mv_par12 == 2
	// filtra operacao
	aFilOper := { mv_par09, mv_par10 }
endif

// totaliza contas analiticas e sinteticas            
aTotCO := PCOTotCO( AK1->AK1_CODIGO, cRevisa, aFilCO, (mv_par11==1), aFilOper )

oReport:SetMeter(AK3->(LastRec()))

oPlanilha:Init()
	
dbSelectArea("AK3")
dbSetOrder(3)
MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+"001")
While !Eof() .And. 	AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_NIVEL==;
					xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+"001"

	oContaOrc:Init()				
	// Dados da classe orcamentaria
	PCOR045_CO( AK3_ORCAME ,AK3_VERSAO ,AK3_CO , aPeriodo, oReport, aTotCO )
	oContaOrc:Finish()				

	dbSelectArea("AK3")
	dbSkip()
End 

oPlanilha:Finish()
	
Return( NIL )

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR045_CO� Autor � Paulo Carnelossi         � Data �22/06/2006���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria do Centro         ���
���          �orcamentario.  (Conversao para Release 4)                      ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR045CO_CO( cOrcame,cVersao,cCO,aPeriodo,aTamanho,oPrint        ���
���          �          ,aColDescr )                                         ���
����������������������������������������������������������������������������Ĵ��
���Parametros� cOrcame    - Orcamento                                        ���
���          � cVersao    - Versao do Orcamento                              ���
���          � cCO        - Conta Orcamentaria                               ���
���          � aPeriodo   - Datas do periodo                                 ���
���          � oRepor     - objeto TReport                                   ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function PCOR045_CO(cOrcame, cVersao, cCO, aPeriodo, oReport, aTotCO)

Local aArea		:= GetArea()
Local aAreaAK2	:= AK2->(GetArea())
Local aAreaAK3	:= AK3->(GetArea())
Local oPlanilha := oReport:Section(1)
Local oContaOrc := oReport:Section(2)
Local bHeaderImpr := {||oPlanilha:lPrintHeader := .T.,If(lContaOrc, (oPlanilha:PrintLine(), oContaOrc:`PrintLine()),(oPlanilha:PrintLine())), oReport:ThinLine(),oReport:SkipLine()}
Local nPos		:= 0

lContaOrc := .F.
oReport:OnPageBreak(bHeaderImpr)
    
	If AK3->AK3_NIVEL =="001" .OR. ;
		(AK3->AK3_CO >= PadR(mv_par05, Len(AK3->AK3_CO)) .And. AK3->AK3_CO <= PadR(mv_par06, Len(AK3->AK3_CO)) .And. ;
		PcoChkUser(cOrcame, cCO, AK3->AK3_PAI, 1, "ESTRUT", cVersao))

		If ! (mv_par11 == 2 .And. AK3->AK3_TIPO $ " ;1")
			nPos := aScan( aTotCO, { |x| x[1] == AK3->AK3_CO } )
			If nPos > 0                                                                               
				oContaOrc:Cell("TOTAL_CO"):SetBlock( { || Transform(aTotCO[nPos,2],X_PICTOTCO) } )
			Else
				oContaOrc:Cell("TOTAL_CO"):SetBlock( { || "" } )				
			EndIf	
			oContaOrc:PrintLine()
			oReport:ThinLine()
		EndIf	
		
		// itens da conta orcamentaria
		PCOR045CO_It(cOrcame, cVersao, cCO, aPeriodo, oReport)

	EndIf
	
	dbSelectArea("AK3")
	dbSetOrder(2)
	MsSeek(xFilial()+cOrcame+cVersao+cCO)
	While !Eof() .And. AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_PAI==xFilial("AK3")+cOrcame+cVersao+cCO
	
		oReport:IncMeter()
		
		// Conta orcamentaria
		PCOR045_CO(AK3_ORCAME, AK3_VERSAO, AK3_CO, aPeriodo, oReport, aTotCO)
		dbSelectArea("AK3")
		dbSkip()
		
	End
	
	RestArea(aAreaAK2)
	RestArea(aAreaAK3)
	RestArea(aArea)

	
Return( NIL )

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR045CO_It� Autor � Paulo Carnelossi         � Data �22/06/2006���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria da classe           ���
���          �orcamentaria.                                                    ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR045CO_It(cOrcame, cVersao, cCO, aPeriodo, oReport)           ���
���          �                                                                 ���
������������������������������������������������������������������������������Ĵ��
���Parametros� cOrcame    - Orcamento                                          ���
���          � cVersao    - Versao do Orcamento                                ���
���          � cCO        - Conta Orcamentaria                                 ���
���          � aPeriodo   - Datas do periodo                                   ���
���          � oReport    - objeto TReport                                     ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Static Function PCOR045CO_It(cOrcame, cVersao, cCO, aPeriodo, oReport)
Local aArea			:= GetArea()
Local aAreaAK2		:= AK2->(GetArea())    
Local aAuxArea 		:= {}
Local cDescricao	:= ""
Local aClassDescr	:= {}
Local aClassTam		:= {}
Local nX 			:= 0
Local lTitle
Local cDesCla       := Space(Len(AK6->AK6_DESCRI))
Local aValorOrc     := {}
Local lVazio        := .T.
Local aAuxVlr
Local nPos
Local cPicture 		:= ""
Local oPlanilha := oReport:Section(1)
Local oContaOrc := oReport:Section(2)
Local oContaItens := oReport:Section(3)

dbSelectArea("CTT")
dbSetOrder(1)

dbSelectArea("CTD")
dbSetOrder(1)

dbSelectArea("CTH")
dbSetOrder(1)

dbSelectArea("AK2")
dbSetOrder(1)

aAuxVlr := {}



For nX := 1 TO Len(aPeriodo)

	If MsSeek(xFilial()+cOrcame+cVersao+cCO+DTOS(CTOD(PadR(aPeriodo[nX],10))))
		While AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO+DTOS(AK2->AK2_PERIOD)== xFilial()+cOrcame+cVersao+cCO+DTOS(CTOD(PadR(aPeriodo[nX],10)))
		
		    If (AK2->AK2_CLASSE >= mv_par07 .And. AK2->AK2_CLASSE <= mv_par08) .And. ;
				(AK2->AK2_OPER >= mv_par09 .And. AK2->AK2_OPER <= mv_par10 .And. AK2->AK2_VALOR != 0 .And. ; 
				PcoCC_User(cOrcame, cCO, AK3->AK3_PAI, 2, "CCUSTO", cVersao, AK2->AK2_CC) .And. ;
				PcoIC_User(cOrcame, cCO, AK3->AK3_PAI, 2, "ITMCTB", cVersao, AK2->AK2_ITCTB) .And. ;
		  		PcoCV_User(cOrcame, cCO, AK3->AK3_PAI, 2, "CLAVLR", cVersao, AK2->AK2_CLVLR) )		    
		    
				If !Empty(AK2->AK2_CHAVE)
					aAuxArea := GetArea()
					AK6->(dbSetOrder(1))
					AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
					If !Empty(AK6->AK6_VISUAL)
						dbSelectArea(Substr(AK2->AK2_CHAVE,1,3))
						dbSetOrder(Val(Substr(AK2->AK2_CHAVE,4,2)))
						dbSeek(Substr(AK2->AK2_CHAVE,6,Len(AK2->AK2_CHAVE)))
						cDescricao := alltrim(&(AK6->AK6_VISUAL))						
					Else
						cDescricao:= ""
					EndIf
					RestArea(aAuxArea)
				EndIf                 
				
				lVazio := .F.

				If (nPos:= Ascan(aAuxVlr, {|aVal|aVal[1]+aVal[2]== AK2_ID+AK2->AK2_CLASSE})) == 0
					
					CTT->( dbSeek( xFilial("CTT") + AK2->AK2_CC    ) )
					CTD->( dbSeek( xFilial("CTD") + AK2->AK2_ITCTB ) )
					CTH->( dbSeek( xFilial("CTH") + AK2->AK2_CLVLR ) )
					dbSelectArea("AK6")
					dbSetOrder(1)
					dbSeek(xFilial()+AK2->AK2_CLASSE)
					If AK6->AK6_FORMAT $ "1/3"
						cPicture := "@E 999999999999"
					Else
						cPicture := "@E 999,999,999,999"
					EndIf
					
					If AK6->AK6_DECIMA>0
						cPicture += "."+Replicate("9",AK6->AK6_DECIMA)
					EndIf

					cDescCla := AK6->AK6_DESCRI

               dbSelectArea("AK2")

					aAdd(aAuxVlr, {	AK2_ID, AK2->AK2_CLASSE, cDescCla, cDescricao, AK2->AK2_CC, CTT->CTT_DESC01,;
									CTD->CTD_ITEM, CTD->CTD_DESC01, CTH->CTH_CLVL, CTH->CTH_DESC01, AK2->AK2_OPER,;
									cPicture, ARRAY(Len(aPeriodo)),AK2->(Recno())})
									
					AFILL(aAuxVlr[Len(aAuxVlr)][13], 0 )
					aAuxVlr[Len(aAuxVlr)][13][nX] := AK2->AK2_VALOR
				Else
					aAuxVlr[nPos][13][nX] += AK2->AK2_VALOR
				EndIf	
	
			EndIf
			
			AK2->(dbSkip())
			
		End

	EndIf
	
Next

If !lVazio
	AK2->(MsSeek(xFilial()+cOrcame+cVersao+cCO))
	oContaItens:Init()
	aValorOrc := aClone(aAuxVlr)
    PCOR045_PrintItens(oReport, aValorOrc, aPeriodo)
    oContaItens:Finish()
    oReport:ThinLine()
EndIf

RestArea(aAreaAK2)
RestArea(aArea)

Return( NIL ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PCOR045_PrintItens �Autor �Paulo Carnelossi � Data � 21/01/05 ���
���������������������������������������������������������������������������͹��
���Desc.     �Impressao dos itens orcamentarios                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PCOR045_PrintItens(oReport, aValorOrc, aPeriodo)
Local oPlanilha := oReport:Section(1)
Local oContaOrc := oReport:Section(2)
Local oContaItens := oReport:Section(3)
Local nX, nY, nCol, nColAux

lContaOrc := .T.

aEval(aPeriodo,{|cValue, nIndex| 	oContaItens:Section(1):Cell(nIndex):SetTitle(Alltrim(cValue)),;
									oContaItens:Section(1):Cell(nIndex):SetAlign("RIGHT"), ;
									oContaItens:Section(1):Cell(nIndex):SetHeaderAlign("RIGHT")} )

oContaItens:Cell("AK2_CLASSE")	:SetBlock({|| X_CLASSE })
oContaItens:Cell("AK6_DESCRI")	:SetBlock({|| X_DESCLA })
oContaItens:Cell("AK2_DESCRI")	:SetBlock({|| X_DESCRI })
oContaItens:Cell("AK2_CC")		:SetBlock({|| X_CC })
oContaItens:Cell("CTT_DESC01")	:SetBlock({|| X_DESCC })
oContaItens:Cell("AK2_ITCTB")	:SetBlock({|| X_ITCTB })
oContaItens:Cell("CTD_DESC01")	:SetBlock({|| X_DESITCTB })
oContaItens:Cell("AK2_CLVLR")	:SetBlock({|| X_CLVL })
oContaItens:Cell("CTH_DESC01")	:SetBlock({|| X_DESCLVL })
oContaItens:Cell("AK2_OPER")	:SetBlock({|| X_OPER })

oContaItens:Section(1):SetLineBreak()
oContaItens:Section(1):SetLeftMargin(15)

For nX := 1 TO Len(aValorOrc)

	aValores := {}

	AK2->(dbgoto(X_REGAK2))

	For nY := 1 TO Len(aPeriodo)
		oContaItens:Section(1):Cell("AK2_VALOR"+StrZero(nY,2)):SetValue(Alltrim(PcoPlanCel(X_VALOR[nY],X_CLASSE,,X_PICTURE)))
		aAdd(aValores, X_VALOR[nY])
	Next	

	oContaItens:PrintLine()

	oContaItens:Section(1):Init()
	oContaItens:Section(1):PrintLine()
	oContaItens:Section(1):Finish()

Next	

Return( NIL )
