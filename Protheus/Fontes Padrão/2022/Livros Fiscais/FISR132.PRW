#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR132.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR132

Relatorio de conferencia de Ressarcimento

@return	Nil

@author Mauro A. Gonçalves
@since 05/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR132()
Local	oReport
Local	aCPOSF2	:= {"F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","F2_EMISSAO","F2_EST","F2_VALICM","F2_BASEICM","F2_ICMSRET"}
Local	aCPOSD2	:= {"D2_ITEM","D2_QUANT"}
Local	aCPOCD0	:= {"CD0_DOCENT","CD0_SERENT","CD0_FORNE","CD0_LOJENT","CD0_EMISSA","CD0_COD","CD0_ITEM","CD0_ITENFE","CD0_QUANT",;
				    "CD0_VUNIT","CD0_VLUNOP","CD0_PICMSE","CD0_ALQSTE","CD0_VALBST","CD0_VLUNRE","CD0_VLUNCR"}
						
//Verifica se os campos existem na tabela CD0
If !AnalisaCD0(aCPOCD0)
	Return
Endif


If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel

	If Pergunte("FISR132",.T.)
		oReport:= ReportDef(mv_par01,mv_par02,aCPOSF2,aCPOCD0,aCPOSD2)
		oReport:PrintDialog()
	Endif	

Else
	Alert(STR0002) //"Rotina disponível apenas em TReport (Relatório Personalizável)."
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Mauro A. Gonçalves
@since 05/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(dDTIni, dDTFin, aCPOSF2, aCPOCD0,aCPOSD2)
Local	oReport
Local	oSection, oSection1, oBreak, oBreak2
Local	cQrySF2		:= GetNextAlias()
Local 	cTitRel		:= STR0001 + " - Periodo de " + DTOC(dDTIni) + " a " + DTOC(dDTFin)
Local	lCmpFcp		:= CD0->(FieldPos("CD0_FCPST")) > 0

oReport := TReport():New("FISR132",cTitRel,"FISR132",{|oReport| ReportPrint(oReport,oSection,oSection1,cQrySF2,aCPOSF2,aCPOCD0,aCPOSD2,lCmpFcp)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.

//TRSection():New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
oSection := TRSection():New(oReport,cTitRel,{cQrySF2,"SF2","SD2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:lHeaderVisible := .F.
oSection:SetHeaderSection(.T.)
oSection:SetHeaderPage(.T.)
oSection:SetLinesBefore(2)

TRCell():New(oSection,aCPOSF2[1]	,cQrySF2,STR0003,/*cPicture*/					,TamSx3(aCPOSF2[1])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_DOC 
TRCell():New(oSection,aCPOSF2[2]	,cQrySF2,STR0004,/*cPicture*/					,TamSx3(aCPOSF2[2])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_SERIE
TRCell():New(oSection,aCPOSF2[3]	,cQrySF2,STR0005,/*cPicture*/					,TamSx3(aCPOSF2[3])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_CLIENTE
TRCell():New(oSection,aCPOSF2[4]	,cQrySF2,STR0006,/*cPicture*/					,TamSx3(aCPOSF2[4])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_LOJA
TRCell():New(oSection,aCPOSF2[5]	,cQrySF2,STR0007,/*cPicture*/					,TamSx3(aCPOSF2[5])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_EMISSAO
TRCell():New(oSection,aCPOSF2[6]	,cQrySF2,STR0008,/*cPicture*/					,TamSx3(aCPOSF2[6])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_EST
TRCell():New(oSection,aCPOSF2[7]	,cQrySF2,STR0009,PesqPict("SF2",aCPOSF2[7])	,TamSx3(aCPOSF2[7])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_VALICM
TRCell():New(oSection,aCPOSF2[8]	,cQrySF2,STR0010,PesqPict("SF2",aCPOSF2[8])	,TamSx3(aCPOSF2[8])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_BASEICM
TRCell():New(oSection,aCPOSF2[9]	,cQrySF2,STR0011,PesqPict("SF2",aCPOSF2[9])	,TamSx3(aCPOSF2[9])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //F2_ICMSRET
TRCell():New(oSection,aCPOSD2[1]	,cQrySF2,STR0029,PesqPict("SD2",aCPOSD2[1])	,TamSx3(aCPOSD2[1])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //D2_QUANT

//TRSection():New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
oSection1 := TRSection():New(oReport,"Compl. Ressarcimento.",{cQrySF2,"CD0"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:lHeaderVisible := .F.
oSection1:nLeftMargin := oSection:nLeftMargin + 5
oSection1:SetHeaderSection(.T.)
oSection1:SetHeaderPage(.T.)
oSection1:SetLinesBefore(0)

TRCell():New(oSection1,aCPOCD0[1]	,cQrySF2,STR0012,/*cPicture*/					,TamSx3(aCPOCD0[1])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_DOCENT
TRCell():New(oSection1,aCPOCD0[2]	,cQrySF2,STR0013,/*cPicture*/					,TamSx3(aCPOCD0[2])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_SERENT
TRCell():New(oSection1,aCPOCD0[3]	,cQrySF2,STR0014,/*cPicture*/					,TamSx3(aCPOCD0[3])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_FORNE
TRCell():New(oSection1,aCPOCD0[4]	,cQrySF2,STR0015,/*cPicture*/					,TamSx3(aCPOCD0[4])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_LOJENT
TRCell():New(oSection1,aCPOCD0[5]	,cQrySF2,STR0016,/*cPicture*/					,TamSx3(aCPOCD0[5])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_EMISSA
//TRCell():New(oSection1,aCPOCD0[6]	,cQrySF2,STR0017,/*cPicture*/					,TamSx3(aCPOCD0[6])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_COD
TRCell():New(oSection1,aCPOCD0[7]	,cQrySF2,STR0018,/*cPicture*/					,TamSx3(aCPOCD0[7])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_ITEM
TRCell():New(oSection1,aCPOCD0[8]	,cQrySF2,STR0019,/*cPicture*/					,TamSx3(aCPOCD0[8])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_ITENFE
TRCell():New(oSection1,aCPOCD0[9]	,cQrySF2,STR0020,PesqPict("CD0",aCPOCD0[9])		,TamSx3(aCPOCD0[9])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_QUANT
//TRCell():New(oSection1,aCPOCD0[10]	,cQrySF2,STR0021,PesqPict("CD0",aCPOCD0[10])	,TamSx3(aCPOCD0[10])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_VUNIT
//TRCell():New(oSection1,aCPOCD0[11]	,cQrySF2,STR0022,PesqPict("CD0",aCPOCD0[11])	,TamSx3(aCPOCD0[11])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_VLUNOP
//TRCell():New(oSection1,aCPOCD0[12]	,cQrySF2,STR0023,PesqPict("CD0",aCPOCD0[12])	,TamSx3(aCPOCD0[12])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_PICMSE
//TRCell():New(oSection1,aCPOCD0[13]	,cQrySF2,STR0024,PesqPict("CD0",aCPOCD0[13])	,TamSx3(aCPOCD0[13])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_ALQSTE
//TRCell():New(oSection1,aCPOCD0[14]	,cQrySF2,STR0025,PesqPict("CD0",aCPOCD0[14])	,TamSx3(aCPOCD0[14])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_VALBST
TRCell():New(oSection1,aCPOCD0[15]	,cQrySF2,STR0026,PesqPict("CD0",aCPOCD0[15])	,TamSx3(aCPOCD0[15])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_VLUNRE
TRCell():New(oSection1,aCPOCD0[16]	,cQrySF2,STR0030,PesqPict("CD0",aCPOCD0[16])	,TamSx3(aCPOCD0[16])[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_VLUNCR

If lCmpFcp
	TRCell():New(oSection1,"CD0_FCPST",cQrySF2,STR0031,PesqPict("CD0","CD0_FCPST")	,TamSx3("CD0_FCPST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //CD0_VLUNCR
Endif

oBreak := TRBreak():New(oSection,{|| F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA},"Totalizadores por nota",.T.,'Totalizadores por nota',.F.)
TRFunction():New(oSection1:Cell("CD0_VLUNRE"),NIL,"SUM",oBreak,'Ressarcimento ICMS ST: ',"999,999,999.99","Round((VLUNRE/CD0_QUANT)*CD0_QUANT,2)",.F.,.F.)
TRFunction():New(oSection1:Cell("CD0_VLUNCR"),NIL,"SUM",oBreak,'Credito ICMS: '			,"999,999,999.99","Round((VLUNCR/CD0_QUANT)*CD0_QUANT,2)",.F.,.F.)
If lCmpFcp
	TRFunction():New(oSection1:Cell("CD0_FCPST"),NIL,"SUM",oBreak,'FECP: '			,"999,999,999.99","Round((FCPST/CD0_QUANT)*CD0_QUANT,2)",.F.,.F.)
Endif

oBreak2 := TRBreak():New(oSection,'',"Totalizadores do Relatório",.T.,'Totalizadores do Relatório',.T.)
TRFunction():New(oSection1:Cell("CD0_VLUNRE"),NIL,"SUM",oBreak2,'Ressarcimento ICMS ST: ',"999,999,999.99","Round((VLUNRE/CD0_QUANT)*CD0_QUANT,2)",.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("CD0_VLUNCR"),NIL,"SUM",oBreak2,'Credito ICMS: '		,"999,999,999.99","Round((VLUNCR/CD0_QUANT)*CD0_QUANT,2)",.F.,.F.,.F.)
If lCmpFcp
	TRFunction():New(oSection1:Cell("CD0_FCPST"),NIL,"SUM",oBreak2,'FECP: '		,"999,999,999.99","Round((FCPST/CD0_QUANT)*CD0_QUANT,2)",.F.,.F.,.F.)
Endif

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Mauro A. Gonçalves
@since 05/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSection,oSection1,cQrySF2,aCPOSF2,aCPOCD0,aCPOSD2,lCmpFcp)

Local cChave	:= ""
Local cCPOS		:= ""   	
Local nA		:= 0
Local nTamArr	:= 0

nTamArr := Len(aCPOSF2)
cCPOS	 := "%"
For nA:=1 To nTamArr 
	cCPOS += "SF2." + aCPOSF2[nA] + ","
Next
	
nTamArr := Len(aCPOCD0)
For nA:=1 To nTamArr
	cCPOS += "CD0." + aCPOCD0[nA] +  ","
Next

nTamArr := Len(aCPOSD2)
For nA:=1 To nTamArr
	cCPOS += "SD2." + aCPOSD2[nA] + ","
Next
	
cCPOS += "CD0_VLUNRE*CD0_QUANT AS VLUNRE , "
cCPOS += "CD0_VLUNCR*CD0_QUANT AS VLUNCR  "

If lCmpFcp
	cCPOS += ", CD0_FCPST*CD0_QUANT AS FCPST, CD0_FCPST  "
Endif

cCPOS += "%"

oSection:BeginQuery()

BeginSql Alias cQrySF2

	COLUMN F2_EMISSAO AS DATE
	COLUMN CD0_EMISSA AS DATE
			
	SELECT %Exp:cCPOS%

	FROM %table:SF2% SF2
	JOIN %table:CD0% CD0 on 
		(CD0.CD0_FILIAL=%xFilial:CD0% AND 
		CD0.CD0_TPMOV='S' AND 
		CD0.CD0_DOC=SF2.F2_DOC AND
		CD0.CD0_SERIE=SF2.F2_SERIE AND
		CD0.CD0_CLIFOR=SF2.F2_CLIENTE AND
		CD0.CD0_LOJA=SF2.F2_LOJA AND
		CD0.%NotDel%)
	JOIN %table:SD2% SD2 on 
		(SD2.D2_FILIAL=%xFilial:SD2% AND
		SD2.D2_DOC=SF2.F2_DOC AND
		SD2.D2_SERIE=SF2.F2_SERIE AND
		SD2.D2_CLIENTE=SF2.F2_CLIENTE AND
		SD2.D2_LOJA=SF2.F2_LOJA AND
		SD2.D2_ITEM=CD0.CD0_ITEM AND
		SD2.%NotDel%)
	WHERE 
		SF2.F2_FILIAL = %xFilial:SF2% AND
		SF2.F2_EMISSAO BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)% AND		
		(SF2.F2_TIPO = 'N' OR SF2.F2_TIPO = 'D') AND
		SF2.%NotDel%
			
	ORDER BY SF2.F2_EMISSAO,SF2.F2_DOC,SF2.F2_SERIE
	
EndSQL

oSection:EndQuery()

oReport:SetMeter((cQrySF2)->(RecCount()))

//-- Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.
TRPosition():New(oSection ,"SF2",1,{||xFilial("SF2")+(cQrySF2)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)})
TRPosition():New(oSection ,"SD2",1,{||xFilial("SD2")+(cQrySF2)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)})
TRPosition():New(oSection1,"CD0",1,{||xFilial("CD0")+"S"+(cQrySF2)->(F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA+D2_ITEM)})

oReport:Section(1):Init()
oReport:Section(2):Init()

While !oReport:Cancel() .And. !(cQrySF2)->(Eof())

	If cChave == (cQrySF2)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+DTOC(F2_EMISSAO)+F2_EST)
		For nA:=1 to Len(aCPOSF2)
			oReport:Section(1):Cell(aCPOSF2[nA]):Hide()
		Next	
	Else
		For nA:=1 to Len(aCPOSF2)
			oReport:Section(1):Cell(aCPOSF2[nA]):Show()
		Next	
		oReport:Section(1):PrintLine()
	EndIf
	
	oReport:Section(2):PrintLine()
		
	cChave	:=	(cQrySF2)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+DTOC(F2_EMISSAO)+F2_EST)
	
	(cQrySF2)->(dbSkip())
	oReport:IncMeter()
EndDo

oReport:Section(1):Finish()
oReport:Section(1):SetPageBreak(.T.)
oReport:Section(2):Finish()
oReport:Section(2):SetPageBreak(.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaCDO
Funcao utilizada para verificar se os campos da CD0 foram criados

@return lRet - Retorna valor boleano
				.T. - Dicionario OK, prossegue com a rotina
				.F. - Dicionario com inconsistencias, apresetna mensagem e aborta rotina
		
@author Mauro A. Gonçalves
@since 05/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AnalisaCD0(aCPO)
Local	nA			:= 1
Local	cMsgm		:=	""

DbSelectArea("CD0")
For nA:=1 to Len(aCPO)
	If CD0->(FieldPos(aCPO[nA])) == 0
		cMsgm	:=	"A estrutura da tabela CD0 está fora do necessário para manutenção da mesma."+CRLF
		cMsgm	+=	"Por gentileza execute o compatibilizador U_UPDSIGAFIS para que o Dicionário e a base de dados sejam atualizados."
		Alert(cMsgm)
		Return .F.
	Endif	
Next
Return .T.

