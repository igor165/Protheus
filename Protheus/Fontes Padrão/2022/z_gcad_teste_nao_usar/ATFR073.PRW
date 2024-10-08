#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFR073.CH"  



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFR073   �Autor  �Alvaro Camillo Neto � Data �  04/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio de Posi��o Valorizada 12 meses                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/
Function ATFR073()
Local oReport
Local lTReport	:= TRepInUse()
Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
//Inicializa��o das vari�veis Private do Relat�rio
Private aSelFil		:= {}
Private aSelClass	:= {}
Private lTodasFil	:= .F.
Private cPerg   	:= "AFR073"
Private aPeriodo 	:= {}

If !lDefTop
	Help("  ",1,"AFR073TOP",,STR0001 ,1,0) //"Fun��o dispon�vel apenas para ambientes TopConnect"
	Return
EndIf

If !lTReport
	Help("  ",1,"AFR073R4",,STR0002,1,0)//"Fun��o dispon�vel apenas TREPORT"
	Return
ENdIf

lRet := Pergunte( cPerg , .T. )


If lRet
	If mv_par20 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil(@lTodasFil)
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf
	
	If MV_PAR22 <=0 .Or. MV_PAR22 > AtfMoedas()
		Help("  ",1,"AFR073MOE",,STR0003,1,0)//"Moeda n�o cadastrada no Sistema"
		Return
	EndIf 
	
	If !VldTpSald( MV_PAR24, .T. )
		Return
	EndIf
	
	If MV_PAR02 != FirstDay(MV_PAR02) .Or. MV_PAR03 != LastDay(MV_PAR03)
		Help("  ",1,"AFR073DT",,STR0005,1,0)//"A data inicial deve ser o primeiro dia de um m�s e a data final deve ser o ultimo dia de um m�s"
		Return
	Else
		aPeriodo := AFR073Per(MV_PAR02,MV_PAR03)
		If Len(aPeriodo) < 2 .Or. Len(aPeriodo)  > 12
			Help("  ",1,"AFR073PER",,STR0006,1,0)//"O intervalo m�nimo de datas s�o 2 meses e o per�odo m�ximo 12 meses "
			Return
		EndIf
	EndIf 
	
	//Seleciona as classifica��es patrimoniais 
	If MV_PAR25 == 1 .And. Len( aSelClass ) <= 0
		aSelClass := AdmGetClas()
		If Len( aSelClass ) <= 0
			Return
		EndIf 
	EndIf
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Alvaro Camillo Neto � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Defini��o de layout do relat�rio anal�tico                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport
Local oSecBem
Local oSecValores
Local oSecItem
Local oTotBem
Local oTotFilial
Local oTotRelat
Local cReport  := "ATFR073"
Local cTitulo  :=	OemToAnsi(STR0007)//"Posicao Valorizada dos Bens - 12 Meses"
Local cDescri  :=	OemToAnsi(STR0008) + " " + OemToAnsi(STR0009) + " "   	//"Este programa ir� emitir a posi��o valorizada dos"##"bens em at� 12 per�odos"
Local aOrd	   := {}
Local bReport  := {|| }
Local cCpoAux  := ""
Local cDescAux := ""
Local cMesAux  := ""
Local nPeriodo := 0
Local cComple  :=  STR0010+ Dtoc(MV_PAR02) + STR0011+ Dtoc(MV_PAR03) +STR0012 + GetMv("MV_MOEDA" + cValtoChar(MV_PAR22))//" Per�odo "##" a "##" na Moeda "
Local nTipoRel		:= MV_PAR01

bReport := { |oReport|	oReport:SetTitle( oReport:Title() + IIF( MV_PAR01 == 1, STR0013,STR0014 ) + cComple ), AF73Print( oReport ) }//" Anal�tico."##" Sint�tico."

oReport  := TReport():New( cReport, cTitulo, cPerg, bReport, cDescri )

oSecBem := TRSection():New( oReport,  STR0015 )//"Dados do Bem"
TRCell():New( oSecBem, "N3_FILIAL"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_CBASE"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_ITEM"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N1_DESCRIC"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
TRCell():New( oSecBem, "N1_CHAPA"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N1_PATRIM"	, "SN1", /*X3Titulo*/, /*Picture*/, 15 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
TRCell():New( oSecBem, "N1_AQUISIC"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
If nTipoRel == 1
	oSecBem:SetHeaderPage(.T.)
EndIf

oSecItem := TRSection():New( oReport, STR0016) // "Per�odos"
TRCell():New( oSecItem, "N3_TIPO"		, "SN3", /*X3Titulo*/, /*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecItem, "N3_TPDEPR"		, "SN3", /*X3Titulo*/, /*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecItem, "N3_TPSALDO"	, "SN3", /*X3Titulo*/, /*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecItem, "N3_CCONTAB"	, "SN3", STR0017, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Conta Cont�bil"
TRCell():New( oSecItem, "N3_CUSTBEM"	, "SN3", STR0018, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Centro de Custo"
TRCell():New( oSecItem, "N3_SUBCCON"	, "SN3", STR0019, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Item Cont�bil"
TRCell():New( oSecItem, "N3_CLVLCON"	, "SN3", STR0045, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Classe de Valor"
If nTipoRel == 1
	oSecItem:SetHeaderPage(.T.)
EndIf
//Se��o dos per�odos
oSecValores := TRSection():New( oReport, STR0020) // "Valores"
TRCell():New( oSecValores, "VL"		, "", "-", /*Picture*/, 2 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,0,.T.)
//   New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)

//Cria��o dos campos de per�odo
For nPeriodo := 1 to Len(aPeriodo)
	cCpoAux  := "VLPER" + STRZERO(nPeriodo,2)
	cMesAux  := Alltrim( MesExtenso( Month(aPeriodo[nPeriodo][2]) ) )
	cDescAux := Left(cMesAux,3) + "/"+cValToChar(Year(aPeriodo[nPeriodo][2]))
	TRCell():New( oSecValores, cCpoAux , "", cDescAux, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,0,.T.)
	oSecValores:Cell(cCpoAux):SetHeaderAlign("RIGHT")
Next nX
oSecValores:SetHeaderPage(.T.)

oTotItem  := TRSection():New( oReport, STR0021 ) // "Texto Total Geral"
TRCell():New( oTotItem, "TEXTO"	, "", ""  /*X3Titulo*/, "" /*Picture*/, 30 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotItem, "N3_FILIAL"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotItem, "N3_CBASE"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotItem, "N3_ITEM"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
If nTipoRel == 1
	oTotItem:SetHeaderSection(.F.) 
Else
	oTotItem:SetHeaderPage(.T.)
EndIf
oTotItem:SetLeftMargin(7)

oTotBem  := TRSection():New( oReport, STR0022 ) // "Texto Total Geral"
TRCell():New( oTotBem, "TEXTO"	, "", ""  /*X3Titulo*/, "" /*Picture*/, 30 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotBem, "N3_FILIAL"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotBem, "N3_CBASE"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotBem, "N1_DESCRIC"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
oTotBem:SetHeaderSection(.F.)
oTotBem:SetLeftMargin(7)

oTotFilial  := TRSection():New( oReport, STR0023 ) // "Texto Total Geral"
TRCell():New( oTotFilial, "TEXTO"	, "", ""  /*X3Titulo*/, "" /*Picture*/, 30 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotFilial, "N3_FILIAL"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotFilial, "M0_FILIAL"	, "SM0", /*X3Titulo*/, /*Picture*/, 200/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oTotFilial:SetHeaderSection(.F.)
oTotFilial:SetLeftMargin(7)

oTotRelat  := TRSection():New( oReport, STR0024 ) // "Total Geral Relatorio"
TRCell():New( oTotRelat, "TEXTO"	, "", ""  /*X3Titulo*/, "" /*Picture*/, 30 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oTotRelat:SetHeaderSection(.F.)
oTotRelat:SetLeftMargin(7)

oSecValores:SetColSpace(0)
oReport:SetLandScape()
oReport:DisableOrientation()
oReport:ParamReadOnly()

Return oReport


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF73Print �Autor  �Microsiga           � Data �  04/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de impress�o do relat�rio                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AF73Print( oReport )
Local oSecBem		:= oReport:Section(1)
Local oSecItem		:= oReport:Section(2)
Local oSecValores	:= oReport:Section(3)
Local oTotItem		:= oReport:Section(4)
Local oTotBem		:= oReport:Section(5)
Local oTotFilial	:= oReport:Section(6)
Local oTotRelat		:= oReport:Section(7)


Local oMeter
Local oText
Local oDlg
Local lEnd
Local cAliasQry 	:= GetNextAlias()
Local nTipoRel		:= MV_PAR01
Local cGrupoIni		:= MV_PAR04
Local cGrupoFim		:= MV_PAR05
Local cBemIni   	:= MV_PAR06
Local cItemIni  	:= MV_PAR07
Local cBemFim   	:= MV_PAR08
Local cItemFim  	:= MV_PAR09
Local dAquIni		:= MV_PAR10
Local dAquFim   	:= MV_PAR11
Local cContaIni 	:= MV_PAR12
Local cContaFim 	:= MV_PAR13
Local cCCIni   		:= MV_PAR14
Local cCCFim   		:= MV_PAR15
Local cItCtbIni		:= MV_PAR16
Local cItCtbFim		:= MV_PAR17
Local cClvlIni		:= MV_PAR18
Local cClVlFim		:= MV_PAR19
Local nTipoTotal	:= MV_PAR21
Local cMoeda		:= StrZero(MV_PAR22,2)
Local nEntidade		:= MV_PAR23
Local cTipoSLD		:= MV_PAR24
Local aTipo			:= {}
Local cDescTipo		:= ""
Local cDescSld 		:= ""
Local cTipDepr 		:= ""
Local cDescMet		:= ""
Local nPeriodo		:= 0
Local nValor        := 0
Local aValores 	 	:= {}
Local aVlrOriginal 	:= {}
Local aDepMensal 	:= {}
Local aBaixa 		:= {}
Local aAmpliacao 	:= {}
Local aDepAcm		:= {}
Local aResid		:= {}
/* projeto argentina */
Local aCorrMens		:= {}
Local aCorrAcum		:= {}
Local aCorDepAcum	:= {}
Local aCorDepMen	:= {}
Local lCalcCorr		:= .F.
/* projeto argentina */
Local cTipo 		:= ""
Local cTpSaldo		:=""
Local cFilBem		:= ""
Local cCodBase		:= ""
Local cItem 		:= ""
Local cMoedaBem		:= ""
Local aTBemFis		:= Array(Len(aPeriodo))
Local aTBemGer		:= Array(Len(aPeriodo))
Local aTBemInc		:= Array(Len(aPeriodo))
Local aTItemFis		:= Array(Len(aPeriodo))
Local aTItemGer		:= Array(Len(aPeriodo))
Local aTItemInc		:= Array(Len(aPeriodo))
Local aTFilFis		:= Array(Len(aPeriodo))
Local aTFilGer		:= Array(Len(aPeriodo))
Local aTFilInc		:= Array(Len(aPeriodo))
Local aTRelFis		:= Array(Len(aPeriodo))
Local aTRelGer		:= Array(Len(aPeriodo))
Local aTRelInc		:= Array(Len(aPeriodo))
Local cTipoFiscal	:= ATFXTpBem(1)
Local cTipoGerenc   := ATFXTpBem(2)
Local cTipoIncent	:= ATFXTpBem(3)
Local nPerValor		:= 0
Local lRealProv	:= .F.

Local aValorPer		:= {}			//-- JRJ # 20170919-A 
Local cCpoAux		:= ""			//-- JRJ # 20170919-B	

If nTipoTotal == 1 //Fiscal
	aTipo := ATFXTpBem(1,.T.)
ElseIf nTipoTotal == 2 //Gerencial
	aTipo := ATFXTpBem(2,.T.)
ElseIf nTipoTotal == 3 //Incentivada
	aTipo := ATFXTpBem(3,.T.)
EndIf

/*
 * Verifica��o do campo para ativos de custo de provis�o
 */
If Select("SN3") == 0
	DbSelectArea("SN3")
EndIf
lRealProv :=  MV_PAR26 == 2

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao						 �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
ATFGERCOMP(oMeter,oText,oDlg,lEnd,cAliasQry,dAquIni,dAquFim,aPeriodo,cBemIni,cBemFim,cItemIni,cItemFim,cContaIni,cContaFim,;
cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,cMoeda,aSelFil,lTodasFil,Nil,Nil,aTipo,Nil,Nil,nEntidade,cTipoSLD,aSelClass,lRealProv) },;
OemToAnsi(OemToAnsi(STR0026)),;//"Criando Arquivo Tempor�rio..."
OemToAnsi(STR0027))//"Posicao Valorizada dos Bens 12 Meses"

// Orderna de acordo com a Ordem do relatorio
(cAliasQry)->(dbGoTop())
If (cAliasQry)->(EOF())
	Help("  ",1,"AFR073NOD",,STR0028,1,0)//"N�o h� dados, verificar parametros do relat�rio"
	Return
EndIf

//��������������������� �
//�Estrutura do Arquivo�
//��������������������� �
/*
FILIAL CBASE ITEM MOEDA CLASSIF TIPO DESC_SINT AQUISIC DTBAIXA DTINIPER DTFIMPER PERIODO CHAPA GRUPO CONTA CCUSTO SUBCTA CLVL SEQ SEQREAV FLAGBAIXA TPSALDO QUANTD
ORIGINAL AMPLIACAO ATUALIZ DEPRECACM DEPRECMES	RESIDUAL CORRECACM CORDEPACM VLBAIXAS
*/

//Impress�o da folha de Legenda
AFR073LEG(oReport)
                  
lCalcCorr := ((GetNewPar( "MV_CORREC", "N" ) == "S") .And. cPaisLoc $ "ARG|CHI")

aFill(aTRelFis,0)
aFill(aTRelGer,0)
aFill(aTRelInc,0)

While (cAliasQry)->(!EOF()) .And. !oReport:Cancel()
	//Dados do Bem
	cFilBem	:= (cAliasQry)->FILIAL
	aFill(aTFilFis,0)
	aFill(aTFilGer,0)
	aFill(aTFilInc,0)
	While (cAliasQry)->(!EOF()) .And. (cAliasQry)->(FILIAL) == cFilBem .And. !oReport:Cancel()
		cCodBase:= (cAliasQry)->CBASE
		cDescr	:= (cAliasQry)->DESC_SINT
		aFill(aTBemFis,0)
		aFill(aTBemGer,0)
		aFill(aTBemInc,0)
		
		While (cAliasQry)->(!EOF()) .And. (cAliasQry)->(FILIAL+CBASE) == cFilBem+cCodBase .And. !oReport:Cancel()
			If nTipoRel == 1 // Analitico
				oSecBem:Init()
				oSecBem:Cell("N3_FILIAL"):SetValue( (cAliasQry)->FILIAL  )
				oSecBem:Cell("N3_CBASE"):SetValue( (cAliasQry)->CBASE  )
				oSecBem:Cell("N3_ITEM"):SetValue( (cAliasQry)->ITEM  )
				oSecBem:Cell("N1_PATRIM"):SetValue( X3COMBO('N1_PATRIM',(cAliasQry)->CLASSIF)    )
				oSecBem:Cell("N1_DESCRIC"):SetValue((cAliasQry)->DESC_SINT  )
				oSecBem:Cell("N1_AQUISIC"):SetValue( (cAliasQry)->AQUISIC  )
				oSecBem:Cell("N1_CHAPA"):SetValue( (cAliasQry)->CHAPA  )
				oSecBem:PrintLine()
				oSecBem:Finish()
			EndIf
			
			cItem 	:= (cAliasQry)->ITEM
			aFill(aTItemFis,0)
			aFill(aTItemGer,0)
			aFill(aTItemInc,0)
			
			While (cAliasQry)->(!EOF()) .And. (cAliasQry)->(FILIAL+CBASE+ITEM) == cFilBem+cCodBase+cItem .And. !oReport:Cancel()
				aValores 	 := {}
				aVlrOriginal := {}
				aDepMensal 	 := {}
				aBaixa 		 := {}
				aAmpliacao 	 := {}
				aDepAcm		 := {}
				aResid		 := {}
				/* projeto argentina */
				aCorrMens	 := {}
				aCorrAcum 	 := {}
				aCorDepAcum	 := {}
				aCorDepMen	 := {}
				/* projeto argentina */
				
				cTipo 	:= (cAliasQry)->TIPO
				cMoedaBem	:= (cAliasQry)->MOEDA
				cTpSaldo:= (cAliasQry)->TPSALDO
				cSeq	:= (cAliasQry)->SEQ
				cSeqReav:= (cAliasQry)->SEQREAV
				If nTipoRel == 1 // Analitico
					SX5->(MsSeek(xFilial("SX5") + "G1"+ (cAliasQry)->TIPO ))
					cDescTipo := Alltrim(SX5->(X5Descri()))
					SX5->(MsSeek(xFilial("SX5") + "SL"+ IIF(Empty(cTpSaldo),'1',cTpSaldo) ))
					cDescSld := Alltrim(SX5->(X5Descri()))
					cTipDepr := IIF(Empty((cAliasQry)->TPDEPR), '1', (cAliasQry)->TPDEPR)
					cDescMet := AllTrim(GetAdvFVal("SN0","N0_DESC01", xFilial("SN0") +'04'+ cTipDepr ,1))
					
					oSecItem:Init()
					oSecItem:Cell("N3_TIPO"):SetValue( AllTrim((cAliasQry)->TIPO) + " - " + cDescTipo )
					oSecItem:Cell("N3_TPDEPR"):SetValue(cTipDepr +" - " + cDescMet  )
					oSecItem:Cell("N3_TPSALDO"):SetValue(cTpSaldo +" - "+ cDescSld )
					oSecItem:Cell("N3_CCONTAB"):SetValue( (cAliasQry)->CONTA  )
					oSecItem:Cell("N3_CUSTBEM"):SetValue((cAliasQry)->CCUSTO  )
					oSecItem:Cell("N3_SUBCCON"):SetValue((cAliasQry)->SUBCTA  )
					oSecItem:Cell("N3_CLVLCON"):SetValue((cAliasQry)->CLVL  )
					oSecItem:PrintLine()
					oSecItem:Finish()
				EndIf

				While (cAliasQry)->(!EOF()) .And. (cAliasQry)->(FILIAL+CBASE+ITEM+TIPO+MOEDA+TPSALDO+SEQ+SEQREAV) == cFilBem+cCodBase+cItem+cTipo+cMoedaBem+cTpSaldo+cSeq+cSeqReav .And. !oReport:Cancel()
					nPerValor 		 := Val((cAliasQry)->PERIODO)
					aAdd(aVlrOriginal,(cAliasQry)->ORIGINAL )
					aAdd(aDepMensal	 ,(cAliasQry)->DEPRECMES )
					aAdd(aBaixa		 ,(cAliasQry)->VLBAIXAS  )
					aAdd(aAmpliacao  ,(cAliasQry)->AMPLIACAO )
					aAdd(aDepAcm	 ,(cAliasQry)->DEPRECACM )
					aAdd(aResid		 ,(cAliasQry)->RESIDUAL  )
					/* projeto argentina */
					If lCalcCorr
						Aadd(aCorrMens	 ,(cAliasQry)->CORREMENS )
						Aadd(aCorrAcum	 ,(cAliasQry)->CORRECACM )
						Aadd(aCorDepMen  ,(cAliasQry)->CORDEPMEN )
						Aadd(aCorDepAcum ,(cAliasQry)->CORDEPACM )
					Endif
					/* projeto argentina */

					If Alltrim((cAliasQry)->TIPO)  $ cTipoFiscal
						If Alltrim( (cAliasQry)->TIPO ) == '05' // Reavalia��o Negativa
							aTItemFis[nPerValor]		-= (cAliasQry)->RESIDUAL
							aTBemFis[nPerValor]		-= (cAliasQry)->RESIDUAL
							aTFilFis[nPerValor]		-= (cAliasQry)->RESIDUAL
							aTRelFis[nPerValor]		-= (cAliasQry)->RESIDUAL
						Else
							aTItemFis[nPerValor]		+= (cAliasQry)->RESIDUAL
							aTBemFis[nPerValor]		+= (cAliasQry)->RESIDUAL
							aTFilFis[nPerValor]		+= (cAliasQry)->RESIDUAL
							aTRelFis[nPerValor]		+= (cAliasQry)->RESIDUAL
						EndIf
					ElseIf Alltrim((cAliasQry)->TIPO)  $ cTipoGerenc
						aTItemGer[nPerValor]		+= (cAliasQry)->RESIDUAL
						aTBemGer[nPerValor]		+= (cAliasQry)->RESIDUAL
						aTFilGer[nPerValor]		+= (cAliasQry)->RESIDUAL
						aTRelGer[nPerValor]		+= (cAliasQry)->RESIDUAL
					ElseIf Alltrim((cAliasQry)->TIPO)  $ cTipoIncent
						aTItemInc[nPerValor]		+= (cAliasQry)->RESIDUAL
						aTBemInc[nPerValor]		+= (cAliasQry)->RESIDUAL
						aTFilInc[nPerValor]		+= (cAliasQry)->RESIDUAL
						aTRelInc[nPerValor]		+= (cAliasQry)->RESIDUAL
					EndIf
					
					(cAliasQry)->(dbSkip())
				EndDo
				/* projeto argentina */
				If lCalcCorr
	 				aValores := {aVlrOriginal,aDepMensal,aBaixa,aAmpliacao,aDepAcm,aCorrMens,aCorrAcum,aCorDepMen,aCorDepAcum,aResid}
	 			Else
	 				aValores := {aVlrOriginal,aDepMensal,aBaixa,aAmpliacao,aDepAcm,aResid}
	 			Endif
				/* projeto argentina */
				If nTipoRel == 1 // Analitico
					For nValor:= 1 to Len(aValores)
						oSecValores:Init()
						aValorPer := aValores[nValor]
						oSecValores:Cell("VL"):SetValue( cValtoChar(nValor) )
						For nPeriodo := 1 to Len(aValorPer)
							cCpoAux  := "VLPER" + STRZERO(nPeriodo,2)
							oSecValores:Cell(cCpoAux):SetValue(aValorPer[nPeriodo])
						Next nPeriodo
						oSecValores:PrintLine()
						oSecValores:Finish()
					Next nValor
				EndIf
			EndDo
			
			//Totalizador por Item do Bem
			If nTipoRel == 1 // Analitico
				If (cAliasQry)->(FILIAL+CBASE+ITEM) != cFilBem+cCodBase+cItem
					oReport:SkipLine()
					oReport:ThinLine()
					
					oTotItem:Init()
					oTotItem:Cell("TEXTO"):SetValue(STR0029)//"Total Residual do Item do Bem "
					oTotItem:Cell("N3_FILIAL"):SetValue( cFilBem  )
					oTotItem:Cell("N3_CBASE"):SetValue( cCodBase )
					oTotItem:Cell("N3_ITEM"):SetValue( cItem  )
					oTotItem:PrintLine()
					oTotItem:Finish()
					
					For nValor:= 1 to 3
						aValorPer := {}
						
						If nValor == 1 .And.(nTipoTotal == 1 .Or. nTipoTotal == 4) //Fiscal
							aValorPer := aTItemFis
							cTotVL	  := "F"
						ElseIf nValor == 2 .And. (nTipoTotal == 2 .Or. nTipoTotal == 4) //Gerencial
							aValorPer := aTItemGer
							cTotVL	  := "G"
						ElseIf nValor == 3 .And. (nTipoTotal == 3 .Or. nTipoTotal == 4) //Incentivada
							aValorPer := aTItemInc
							cTotVL	  := "I"
						EndIf
						
						If !Empty(aValorPer)
							oSecValores:Init()
							oSecValores:Cell("VL"):SetValue( cTotVL )
							For nPeriodo := 1 to Len(aValorPer)
								cCpoAux  := "VLPER" + STRZERO(nPeriodo,2)
								oSecValores:Cell(cCpoAux):SetValue(aValorPer[nPeriodo])
							Next nPeriodo
							oSecValores:PrintLine()
							oSecValores:Finish()
						EndIf
					Next nValor
					oReport:SkipLine()
					oReport:ThinLine()
				EndIf
			EndIf
		EndDo
		//Totalizador por CBASE
		If (cAliasQry)->(FILIAL+CBASE) != cFilBem+cCodBase
			oTotBem:Init()
			oTotBem:Cell("TEXTO"):SetValue(STR0030)//"Total Residual do C�digo Base"
			oTotBem:Cell("N3_FILIAL"):SetValue( cFilBem  )
			oTotBem:Cell("N3_CBASE"):SetValue( cCodBase )
			oTotBem:Cell("N1_DESCRIC"):SetValue( cDescr )
			oTotBem:PrintLine()
			oTotBem:Finish()
			
			For nValor:= 1 to 3
				aValorPer := {}
				
				If nValor == 1 .And.(nTipoTotal == 1 .Or. nTipoTotal == 4) //Fiscal
					aValorPer := aTBemFis
					cTotVL	  := "F"
				ElseIf nValor == 2 .And. (nTipoTotal == 2 .Or. nTipoTotal == 4) //Gerencial
					aValorPer := aTBemGer
					cTotVL	  := "G"
				ElseIf nValor == 3 .And. (nTipoTotal == 3 .Or. nTipoTotal == 4) //Incentivada
					aValorPer := aTBemInc
					cTotVL	  := "I"
				EndIf
				
				If !Empty(aValorPer)
					oSecValores:Init()
					oSecValores:Cell("VL"):SetValue( cTotVL )
					For nPeriodo := 1 to Len(aValorPer)
						cCpoAux  := "VLPER" + STRZERO(nPeriodo,2)
						oSecValores:Cell(cCpoAux):SetValue(aValorPer[nPeriodo])
					Next nPeriodo
					oSecValores:PrintLine()
					oSecValores:Finish()
				EndIf
			Next nValor
			oReport:SkipLine()
			oReport:ThinLine()
		EndIf
	EndDo
	//Totalizador por Filial
	If (cAliasQry)->(FILIAL) != cFilBem
		cDescrFil:= GetAdvFval("SM0","M0_FILIAL",cEmpAnt + cFilBem )
		oTotFilial:Init()
		oTotFilial:Cell("TEXTO"):SetValue(STR0031)//"Total Residual da Filial "
		oTotFilial:Cell("N3_FILIAL"):SetValue( cFilBem  )
		oTotFilial:Cell("M0_FILIAL"):SetValue( cDescrFil )
		oTotFilial:PrintLine()
		oTotFilial:Finish()
		
		For nValor:= 1 to 3
			aValorPer := {}
			
			If nValor == 1 .And.(nTipoTotal == 1 .Or. nTipoTotal == 4) //Fiscal
				aValorPer := aTFilFis
				cTotVL	  := "F"
			ElseIf nValor == 2 .And. (nTipoTotal == 2 .Or. nTipoTotal == 4) //Gerencial
				aValorPer := aTFilGer
				cTotVL	  := "G"
			ElseIf nValor == 3 .And. (nTipoTotal == 3 .Or. nTipoTotal == 4) //Incentivada
				aValorPer := aTFilInc
				cTotVL	  := "I"
			EndIf
			
			If !Empty(aValorPer)
				oSecValores:Init()
				oSecValores:Cell("VL"):SetValue( cTotVL )
				For nPeriodo := 1 to Len(aValorPer)
					cCpoAux  := "VLPER" + STRZERO(nPeriodo,2)
					oSecValores:Cell(cCpoAux):SetValue(aValorPer[nPeriodo])
				Next nPeriodo
				oSecValores:PrintLine()
				oSecValores:Finish()
			EndIf
		Next nValor
		oReport:SkipLine()
		oReport:ThinLine()
	EndIf
EndDo

//Totalizador
oTotRelat:Init()
oTotRelat:Cell("TEXTO"):SetValue(STR0032)//"Total Residual do Relat�rio "
oTotRelat:PrintLine()
oTotRelat:Finish()

For nValor:= 1 to 3
	aValorPer := {}
	
	If nValor == 1 .And.(nTipoTotal == 1 .Or. nTipoTotal == 4) //Fiscal
		aValorPer := aTRelFis
		cTotVL	  := "F"
	ElseIf nValor == 2 .And. (nTipoTotal == 2 .Or. nTipoTotal == 4) //Gerencial
		aValorPer := aTRelGer
		cTotVL	  := "G"
	ElseIf nValor == 3 .And. (nTipoTotal == 3 .Or. nTipoTotal == 4) //Incentivada
		aValorPer := aTRelInc
		cTotVL	  := "I"
	EndIf
	
	If !Empty(aValorPer)
		oSecValores:Init()
		oSecValores:Cell("VL"):SetValue( cTotVL )
		For nPeriodo := 1 to Len(aValorPer)
			cCpoAux  := "VLPER" + STRZERO(nPeriodo,2)
			oSecValores:Cell(cCpoAux):SetValue(aValorPer[nPeriodo])
		Next nPeriodo
		oSecValores:PrintLine()
		oSecValores:Finish()
	EndIf
Next nValor
oReport:SkipLine()
oReport:ThinLine()


(cAliasQry)->(dbCloseArea())
MSErase(cAliasQry)

Return
      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFR073LEG �Autor  �Microsiga           � Data �  04/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime folha de legenda                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AFR073LEG(oReport)

oReport:SkipLine()
oReport:SkipLine()
oReport:SkipLine()

oReport:PrintText( STR0033 )//"Abrevia��es do Relat�rio :"

oReport:SkipLine()
oReport:ThinLine()

If MV_PAR01 == 1
	oReport:PrintText(STR0034 )// "Legenda da se��o de valores :"
	
	oReport:PrintText( STR0035 )//"1 - Valor Original "
	oReport:PrintText(STR0036  )//"2 - Deprecia��o Mensal "
	oReport:PrintText( STR0037 )//"3 - Baixa "
	oReport:PrintText( STR0038 )//"4 - Amplia��o "
	oReport:PrintText( STR0039 )//"5 - Deprecia��o Acumulada "
	If (GetNewPar( "MV_CORREC", "N" ) == "S") .And. cPaisLoc $ "ARG|CHI"
		oReport:PrintText( STR0046 )		//"6 - Corre��o mensal"
		oReport:PrintText( STR0047 )		//"7 - Corre��o acumulada"
		oReport:PrintText( STR0048 )		//"8 - Corre��o mensal da deprecia��o"
		oReport:PrintText( STR0049 )		//"9 - Corre��o acumulada da deprecia��o"
		oReport:PrintText( "10- " + AllTrim(STR0040))	//"Valor Residual do Bem"
	Else
		oReport:PrintText( "6 - " + AllTrim(STR0040))	//"Valor Residual do Bem"
	Endif
	oReport:SkipLine()
	oReport:ThinLine()
EndIf

oReport:PrintText( STR0041 )//"Legenda da se��o de totais :"
oReport:PrintText( STR0042 )//"F - Valor residual Fiscal "
oReport:PrintText(STR0043  )// "G - Valor residual Gerencial "
oReport:PrintText( STR0044 )//"I - Valor residual Incentivado"

oReport:SkipLine()
oReport:ThinLine()

oReport:EndPage()
oReport:StartPage()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFR073Per �Autor  �Alvaro Camillo Neto � Data �  04/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AFR073Per(dDataIni,dDataFim)
Local aPeriodo := {}
Local dDataAux := FirstDay(dDataIni)

While dDataAux <= LastDay(dDataFim)
	aAdd(aPeriodo,{FirstDay(dDataAux),LastDay(dDataAux)})
	dDataAux := LastDay(dDataAux)+1
EndDo

Return aPeriodo