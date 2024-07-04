#include "protheus.ch"
#include "pmsr250.ch"

//-------------------------------------RELEASE 4-------------------------------------//
Function PMSR250()
	Local oReport

	If PMSBLKINT()
		Return Nil
	EndIf

	Pergunte("PMR250", .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Paulo Carnelossi    � Data �  14/08/06   ���
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
Local cPerg		:= "PMR250"
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Apontamentos de Recursos do Projeto"

Local oReport
Local oApont_AFU
Local oRecurso
Local oApontamentoR
Local oProjeto
Local oApontamentoP
Local oEquipe
Local oApontamentoE
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

oReport := TReport():New("PMSR250",STR0003, cPerg, ;
			{|oReport| ReportPrint(oReport)},;
			cDesc1+CRLF+cDesc2+CRLF+cDesc3 )
//STR0003 "Apontamentos de Recursos do Projeto"

Pergunte(cPerg,.F.)
//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Projeto de  ?                                               �
//� MV_PAR02 : Projeto ate ?                                               �
//� MV_PAR03 : Recurso de  ?                                               �
//� MV_PAR04 : Recurso ate ?                                               �
//� MV_PAR05 : Data de     ?                                               �
//� MV_PAR06 : Data ate    ?                                               �
//� MV_PAR07 : Quebra      ?  1 - Por Recurso / 2 - Por Projeto /          �
//                                              3 - Por Equipe             �
//� MV_PAR08 : Equipe de   ?                                               �
//� MV_PAR09 : Equipe ate  ?                                               �
//��������������������������������������������������������������������������

oReport:SetLandscape()

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

oRecurso := TRSection():New(oReport, STR0031, {"AE8", "AED"}, aOrdem /*{}*/, .F., .F.)
TRCell():New(oRecurso,	"AFU_RECURS"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oRecurso,	"AE8_DESCRI"	,"AE8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oRecurso,	"AED_EQUIP"		,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oRecurso, "AED", 1, {|| xFilial("AED") + AE8->AE8_EQUIP})

oRecurso:SetLineStyle()

oApontamentoR := TRSection():New(oRecurso, STR0034, { "AFU"}, /*{aOrdem}*/, .F., .F.) //"Apontamentos"
TRCell():New(oApontamentoR,	"AFU_DATA"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AFU_PROJET"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AFU_TAREFA"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AF9_DESCRI"	,"AF9",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AED_EQUIP"		,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AED_DESCRI"	,"AED",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AFU_CUSTO1"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AFU_HORAI"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AFU_HORAF"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"AFU_HQUANT"	,"AFU",/*Titulo*/,"@E 9,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoR,	"nHHMMTOT"		,	  ,STR0042/*Titulo*/,"@!"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)


//TRPosition():New(oApontamentoR, "AFU", 1, {|| xFilial("AFU") + AFU->AFU_RECURS})
oApontamentoR:Cell("AF8_DESCRI"):SetLineBreak()
oApontamentoR:Cell("AF9_DESCRI"):SetLineBreak() 
oApontamentoR:Cell("AED_DESCRI"):SetLineBreak()

oProjeto := TRSection():New(oReport, STR0032, {"AF8" }, aOrdem /*{}*/, .F., .F.)
TRCell():New(oProjeto,	"AFU_PROJET"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
oProjeto:SetLineStyle()

oApontamentoP := TRSection():New(oProjeto, STR0034, { "AFU"}, /*{aOrdem}*/, .F., .F.) //"Apontamentos"
TRCell():New(oApontamentoP,	"AFU_DATA"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AFU_TAREFA"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AF9_DESCRI"	,"AF9",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AFU_RECURS"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AE8_DESCRI"	,"AE8",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AED_EQUIP"		,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AED_DESCRI"	,"AED",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AFU_CUSTO1"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AFU_HORAI"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AFU_HORAF"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"AFU_HQUANT"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoP,	"nHHMMTOT"	    ,	  ,STR0042/*Titulo*/,"@!"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

//TRPosition():New(oApontamentoP, "AFU", 1, {|| xFilial("AFU") + })
oApontamentoP:Cell("AF9_DESCRI"):SetLineBreak()
oApontamentoP:Cell("AED_DESCRI"):SetLineBreak()
oApontamentoP:Cell("AE8_DESCRI"):SetLineBreak()

#IFDEF TOP
	oEquipe := TRSection():New(oReport, STR0033, { "AED" }, /*{aOrdem}*/, .F., .F.)
	//TRPosition():New(oEquipe, "AED", 1, {|| xFilial("AED") + AE8->AE8_EQUIP})
#ELSE
	oEquipe := TRSection():New(oReport, STR0033, { "AED" }, /*{aOrdem}*/, .F., .F.)
#ENDIF
TRCell():New(oEquipe,	"AED_EQUIP"		,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oEquipe,	"AED_DESCRI"	,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
oEquipe:SetLineStyle()
                                                                    '
oApontamentoE := TRSection():New(oEquipe, STR0034, {  "AFU" /*, "AE8", "AED" */}, /*{aOrdem}*/, .F., .F.) //"Apontamentos"
TRCell():New(oApontamentoE,	"AFU_DATA"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_PROJET"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_TAREFA"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AF9_DESCRI"	,"AF9",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_RECURS"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AE8_DESCRI"	,"AE8",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_CUSTO1"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_HORAI"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_HORAF"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"AFU_HQUANT"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oApontamentoE,	"nHHMMTOT"	    ,	  ,STR0042/*Titulo*/,"@!"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

//TRPosition():New(oApontamentoP, "AE8", 1, {|| xFilial("AE8") + AFU->AFU_RECURS})
//TRPosition():New(oApontamentoP, "AED", 1, {|| xFilial("AED") + AE8->AE8_EQUIP})
oApontamentoE:Cell("AF8_DESCRI"):SetLineBreak()
oApontamentoE:Cell("AF9_DESCRI"):SetLineBreak()
oApontamentoE:Cell("AE8_DESCRI"):SetLineBreak()

//Recurso por dia

oRecurso2 := TRSection():New(oReport, STR0035, {"AE8", "AED"}, aOrdem /*{}*/, .F., .F.) //'Recurso por dia'
TRCell():New(oRecurso2,	"AFU_RECURS"	,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oRecurso2,	"AE8_DESCRI"	,"AE8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oRecurso2,	"AED_EQUIP"		,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oRecurso2, "AED", 1, {|| xFilial("AED") + AE8->AE8_EQUIP})

oRecurso2:SetLineStyle() 

oAponR2 := TRSection():New(oRecurso2, STR0034, { "AFU","AE8","AED" }, /*{aOrdem}*/, .F., .F.) //"Apontamentos"
TRCell():New(oAponR2,	"AFU_DATA"		,"AFU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAponR2,	"AED_EQUIP"		,"AED",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAponR2,	"AE8_DESCRI"	,"AE8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAponR2,	"AFU_HORAI"		,"AFU",STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAponR2,	"AFU_HORAF"		,"AFU",STR0041,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAponR2,	"AFU_HQUANT"	,"AFU",/*Titulo*/,"@E 9,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAponR2,	"nHHMMTOT"	    ,	  ,STR0042/*Titulo*/,"@!"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) 

oAponR2:SetReadOnly()

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor  �Paulo Carnelossi  � Data �  14/08/06   ���
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

Do Case
	Case mv_par07 == 1
		Pmr250_Rec(oReport)
	Case mv_par07 == 2
		Pmr250_Prj(oReport)
	Case mv_par07 == 3
		Pmr250_Eqp(oReport)
	Case mv_par07 == 4
		Pmr250Rec2(oReport)
End Case

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pmr250_Rec  �Autor  �Paulo Carnelossi  � Data �  14/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pmr250_Rec(oReport)
Local oRecurso 		:= oReport:Section(1)
Local oApontamento 	:= oReport:Section(1):Section(1)
Local oBreak, oTotalCusto, oTotalHoras
Local cAlias := GetNextAlias()
Local cSql := ""

MakeSqlExp("REPORT")

cSql += "AND AFU_PROJET >= '"+mv_par01+"' "
cSql += "AND AFU_PROJET <= '"+mv_par02+"' "

cSql += "AND AE8_RECURS >= '"+mv_par03+"' "
cSql += "AND AE8_RECURS <= '"+mv_par04+"' "
					
cSql += "AND AFU_DATA >= '"+DTOS(mv_par05)+"' "
cSql += "AND AFU_DATA <= '"+DTOS(mv_par06)+"' "

cSql += "AND AE8_EQUIP >= '"+mv_par08+"' "
cSql += "AND AE8_EQUIP <= '"+mv_par09+"' "
cSql := "%"+cSql+"%"

oRecurso:BeginQuery()
BeginSql alias cAlias
	SELECT AFU_DATA, AFU_PROJET, AF8_DESCRI, AFU_TAREFA, AF9_DESCRI, 
			AFU_RECURS, AE8_DESCRI, AED_EQUIP, AED_DESCRI, AFU_CUSTO1, 
			AFU_HORAI, AFU_HORAF, AFU_HQUANT ,AFU_TPREAL ,AFU_COD ,AFU_LOCAL ,AFU_NUMSEQ
	
	FROM %table:AFU% AFU, %table:AF8% AF8, %table:AF9% AF9,%table:AE8% AE8 LEFT OUTER JOIN %table:AED% AED ON 
			AE8_EQUIP = AED_EQUIP				
	
	WHERE 	AFU_FILIAL = %xfilial:AFU% AND AFU.%notDel% AND
			AF8_FILIAL = %xfilial:AF8% AND AF8.%notDel% AND
			AF9_FILIAL = %xfilial:AF9% AND AF9.%notDel% AND
			AE8_FILIAL = %xfilial:AE8% AND AE8.%notDel% AND
			COALESCE(AED_FILIAL,%xfilial:AED%) = %xfilial:AED% AND
			COALESCE(AED.D_E_L_E_T_ , ' ') = ' ' AND
			AFU_PROJET = AF8_PROJET AND
			AFU_PROJET = AF9_PROJET AND
			AFU_TAREFA = AF9_TAREFA AND
			AFU_REVISA = AF8_REVISA AND
			AF9_REVISA = AF8_REVISA AND
			AFU_CTRRVS = '1' AND
			AFU_RECURS = AE8_RECURS
			%exp:cSql%				
	
	ORDER BY AFU_RECURS, AFU_DATA, AFU_HORAI, AFU_PROJET, AFU_REVISA, AFU_TAREFA
	
EndSql

oRecurso:EndQuery()	

oApontamento:SetParentQuery()
oApontamento:SetParentFilter({|cParam| (cAlias)->AFU_RECURS == cParam},{|| (cAlias)->AFU_RECURS })

oApontamento:Cell("AFU_CUSTO1"):SetBlock({||SeekCusto1((cAlias)->AFU_TPREAL ,(cAlias)->AFU_COD ,(cAlias)->AFU_LOCAL ,(cAlias)->AFU_NUMSEQ ,(cAlias)->AFU_CUSTO1)})
oApontamento:Cell("nHHMMTOT"):SetBlock({|| Pmr250FmtHours( IntToHora((cAlias)->AFU_HQUANT ,5) ) })

oApontamento:SetLinesBefore(0)
oApontamento:SetHeaderPage()
	
oTotalCusto := TRFunction():New(oApontamento:Cell("AFU_CUSTO1"),"NSUMCUSTO" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oTotalHoras := TRFunction():New(oApontamento:Cell("AFU_HQUANT"),"NSUMHORA" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRS","ONPRINT",,/*cTitle*/ ,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:SectionValue(),5) )}/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRSX","ONPRINT",,/*cTitle*/,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:ReportValue(),5 ) )}/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

oApontamento:SetTotalInLine(.F.)
oReport:SetTotalInLine(.F.)

oApontamento:SetTotalText(STR0019) //"TOTAIS DO RECURSO "
oReport:SetTotalText(STR0020) //"TOTAL GERAL DOS RECURSOS "
oRecurso:Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pmr250_Rec  �Autor  �Paulo Carnelossi  � Data �  14/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pmr250Rec2(oReport)
Local oRecurso 		:= oReport:Section(4)
Local oApontamento 	:= oReport:Section(4):Section(1)
Local oBreak, oTotalCusto, oTotalHoras
Local cAlias := GetNextAlias()
Local cSql := ""

MakeSqlExp("REPORT")

cSql += "AND AFU_PROJET >= '"+mv_par01+"' "
cSql += "AND AFU_PROJET <= '"+mv_par02+"' "

cSql += "AND AE8_RECURS >= '"+mv_par03+"' "
cSql += "AND AE8_RECURS <= '"+mv_par04+"' "
					
cSql += "AND AFU_DATA >= '"+DTOS(mv_par05)+"' "
cSql += "AND AFU_DATA <= '"+DTOS(mv_par06)+"' "

cSql += "AND AE8_EQUIP >= '"+mv_par08+"' "
cSql += "AND AE8_EQUIP <= '"+mv_par09+"' "
cSql := "%"+cSql+"%"

oRecurso:BeginQuery()
BeginSql alias cAlias
	SELECT AFU_DATA, AFU_RECURS, AE8_DESCRI, AED_EQUIP, AED_DESCRI, MIN(AFU_HORAI) AFU_HORAI, MAX(AFU_HORAF) AFU_HORAF, Sum(AFU_HQUANT) AFU_HQUANT 
	FROM %table:AFU% AFU, %table:AE8% AE8 LEFT OUTER JOIN %table:AED% AED ON 
			AE8_EQUIP = AED_EQUIP				
	
	WHERE 	AFU_FILIAL = %xfilial:AFU% AND AFU.%notDel% AND
			AE8_FILIAL = %xfilial:AE8% AND AE8.%notDel% AND
			COALESCE(AED_FILIAL,%xfilial:AED%) = %xfilial:AED% AND
			COALESCE(AED.D_E_L_E_T_ , ' ') = ' ' AND
			AFU_CTRRVS = '1' AND
			AFU_RECURS = AE8_RECURS
			%exp:cSql%				
																				
	GROUP BY AFU_RECURS, AFU_DATA, AE8_DESCRI, AED_EQUIP, AED_DESCRI
	ORDER BY AFU_RECURS, AFU_DATA
	
EndSql

oRecurso:EndQuery()	

oApontamento:SetParentQuery()
oApontamento:SetParentFilter({|cParam| (cAlias)->AFU_RECURS == cParam},{|| (cAlias)->AFU_RECURS })

oApontamento:Cell("nHHMMTOT"):SetBlock({|| Pmr250FmtHours( IntToHora((cAlias)->AFU_HQUANT ,5) ) })

oApontamento:SetLinesBefore(0)
oApontamento:SetHeaderPage()
	
oTotalHoras := TRFunction():New(oApontamento:Cell("AFU_HQUANT"),"NSUMHORA" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRS","ONPRINT",,/*cTitle*/ ,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:SectionValue(),5) )}/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRSX","ONPRINT",,/*cTitle*/,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:ReportValue(),5 ) )}/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

oApontamento:SetTotalInLine(.F.)
oReport:SetTotalInLine(.F.)

oApontamento:SetTotalText(STR0019) //"TOTAIS DO RECURSO "
oReport:SetTotalText(STR0020) //"TOTAL GERAL DOS RECURSOS "
oRecurso:Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pmr250_Prj  �Autor  �Paulo Carnelossi  � Data �  14/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pmr250_Prj(oReport)
Local oRecurso     := oReport:Section(2)
Local oApontamento := oReport:Section(2):Section(1)
Local oBreak, oTotalCusto, oTotalHoras
Local cAlias := GetNextAlias()
Local cSql := ""

MakeSqlExp("REPORT")

cSql += "AND AFU_PROJET >= '"+mv_par01+"' "
cSql += "AND AFU_PROJET <= '"+mv_par02+"' "

cSql += "AND AE8_RECURS >= '"+mv_par03+"' "
cSql += "AND AE8_RECURS <= '"+mv_par04+"' "
					
cSql += "AND AFU_DATA >= '"+DTOS(mv_par05)+"' "
cSql += "AND AFU_DATA <= '"+DTOS(mv_par06)+"' "

cSql += "AND AE8_EQUIP >= '"+mv_par08+"' "
cSql += "AND AE8_EQUIP <= '"+mv_par09+"' "
cSql := "%"+cSql+"%"

oRecurso:BeginQuery()
BeginSql alias cAlias
	SELECT AFU_DATA, AFU_PROJET, AF8_DESCRI, AFU_TAREFA, AF9_DESCRI, 
			AFU_RECURS, AE8_DESCRI, AED_EQUIP, AED_DESCRI, AFU_CUSTO1, 
			AFU_HORAI, AFU_HORAF, AFU_HQUANT ,AFU_TPREAL ,AFU_COD ,AFU_LOCAL ,AFU_NUMSEQ
	
	FROM %table:AFU% AFU, %table:AF8% AF8, %table:AF9% AF9, %table:AE8% AE8 LEFT OUTER JOIN %table:AED% AED
			ON  AE8_EQUIP = AED_EQUIP
	
	WHERE 	AFU_FILIAL = %xfilial:AFU% AND AFU.%notDel% AND
			AF8_FILIAL = %xfilial:AF8% AND AF8.%notDel% AND
			AF9_FILIAL = %xfilial:AF9% AND AF9.%notDel% AND
			AE8_FILIAL = %xfilial:AE8% AND AE8.%notDel% AND
			COALESCE(AED_FILIAL,%xfilial:AED%) = %xfilial:AED% AND
			COALESCE(AED.D_E_L_E_T_ , ' ') = ' ' AND
			AFU_PROJET = AF8_PROJET AND
			AFU_PROJET = AF9_PROJET AND
			AFU_TAREFA = AF9_TAREFA AND
			AFU_REVISA = AF8_REVISA AND
			AF9_REVISA = AF8_REVISA AND
			AFU_CTRRVS = '1' AND
			AFU_RECURS = AE8_RECURS
			
			%exp:cSql%				
	
	ORDER BY AFU_PROJET, AFU_REVISA, AFU_DATA, AFU_HORAI, AFU_TAREFA, AFU_RECURS
					
EndSql
oRecurso:EndQuery()

oApontamento:SetParentQuery()

oApontamento:Cell("AFU_CUSTO1"):SetBlock({||SeekCusto1((cAlias)->AFU_TPREAL ,(cAlias)->AFU_COD ,(cAlias)->AFU_LOCAL ,(cAlias)->AFU_NUMSEQ ,(cAlias)->AFU_CUSTO1)})
oApontamento:Cell("nHHMMTOT"):SetBlock({|| Pmr250FmtHours( IntToHora((cAlias)->AFU_HQUANT ,5) ) })

oApontamento:SetParentFilter({|cParam| (cAlias)->AFU_PROJET == cParam},{|| (cAlias)->AFU_PROJET })
oApontamento:SetHeaderPage()

oTotalCusto := TRFunction():New(oApontamento:Cell("AFU_CUSTO1"),"NSUMCUSTO" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oTotalHoras := TRFunction():New(oApontamento:Cell("AFU_HQUANT"),"NSUMHORA" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/) 

TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRS","ONPRINT",,/*cTitle*/ ,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:SectionValue(),5) )}/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRSX","ONPRINT",,/*cTitle*/,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:ReportValue(),5 ) )}/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

oApontamento:SetTotalInLine(.F.)  
oReport:SetTotalInLine(.F.) 

oApontamento:SetTotalText(STR0021) //"TOTAIS DO PROJETO "
oReport:SetTotalText(STR0022) //"TOTAL GERAL DOS PROJETOS "
	
oRecurso:Print()

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pmr250_Eqp  �Autor  �Paulo Carnelossi  � Data �  14/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pmr250_Eqp(oReport)
Local oRecurso 		:= oReport:Section(3)
Local oApontamento 	:= oReport:Section(3):Section(1)
Local oBreak, oTotalCusto, oTotalHoras
Local cAlias := GetNextAlias()
Local cSql := ""

MakeSqlExp("REPORT")

cSql += "AND AFU_PROJET >= '"+mv_par01+"' "
cSql += "AND AFU_PROJET <= '"+mv_par02+"' "

cSql += "AND AE8_RECURS >= '"+mv_par03+"' "
cSql += "AND AE8_RECURS <= '"+mv_par04+"' "
					
cSql += "AND AFU_DATA >= '"+DTOS(mv_par05)+"' "
cSql += "AND AFU_DATA <= '"+DTOS(mv_par06)+"' "

cSql += "AND AE8_EQUIP >= '"+mv_par08+"' "
cSql += "AND AE8_EQUIP <= '"+mv_par09+"' "
cSql := "%"+cSql+"%"

oRecurso:BeginQuery()	
BeginSql alias cAlias
	SELECT AFU_DATA, AFU_PROJET, AF8_DESCRI, AFU_TAREFA, AF9_DESCRI, 
			AFU_RECURS, AE8_DESCRI, AED_EQUIP, AED_DESCRI, AFU_CUSTO1, 
			AFU_HORAI, AFU_HORAF, AFU_HQUANT ,AFU_TPREAL ,AFU_COD ,AFU_LOCAL ,AFU_NUMSEQ
	
	FROM %table:AFU% AFU, %table:AF8% AF8, %table:AF9% AF9, %table:AE8% AE8, %table:AED% AED
	
	WHERE 	AFU_FILIAL = %xfilial:AFU% AND AFU.%notDel% AND
			AF8_FILIAL = %xfilial:AF8% AND AF8.%notDel% AND
			AF9_FILIAL = %xfilial:AF9% AND AF9.%notDel% AND
			AE8_FILIAL = %xfilial:AE8% AND AE8.%notDel% AND
			AED_FILIAL = %xfilial:AED% AND AED.%notDel% AND				
			AE8_FILIAL = AED_FILIAL AND
			AFU_PROJET = AF8_PROJET AND
			AFU_PROJET = AF9_PROJET AND
			AFU_TAREFA = AF9_TAREFA AND
			AFU_REVISA = AF8_REVISA AND
			AF9_REVISA = AF8_REVISA AND
			AFU_CTRRVS = '1' AND
			AFU_RECURS = AE8_RECURS AND 
			AE8_EQUIP  = AED_EQUIP				
			%exp:cSql%				
	
	ORDER BY AED_EQUIP, AFU_RECURS, AFU_DATA, AFU_HORAI, AFU_PROJET, AFU_REVISA, AFU_TAREFA
	
EndSql
oRecurso:EndQuery()

oApontamento:SetParentQuery()
oApontamento:SetParentFilter({|cParam| (cAlias)->(AED_EQUIP) == cParam},{|| (cAlias)->(AED_EQUIP) })

oBreak:= TRBreak():New( oReport,{|| (cAlias)->(AED_EQUIP) },STR0023)

oApontamento:Cell("AFU_CUSTO1"):SetBlock({||SeekCusto1((cAlias)->AFU_TPREAL ,(cAlias)->AFU_COD ,(cAlias)->AFU_LOCAL ,(cAlias)->AFU_NUMSEQ ,(cAlias)->AFU_CUSTO1)})
oApontamento:Cell("nHHMMTOT"):SetBlock({|| Pmr250FmtHours( IntToHora((cAlias)->AFU_HQUANT ,5) ) })

oApontamento:SetHeaderPage()


oTotalCusto := TRFunction():New(oApontamento:Cell("AFU_CUSTO1"),"NSUMCUSTO" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oTotalHoras := TRFunction():New(oApontamento:Cell("AFU_HQUANT"),"NSUMHORA" ,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRS","ONPRINT",,/*cTitle*/ ,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:SectionValue(),5) )}/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oApontamento:Cell("nHHMMTOT"),"NSTHRSX","ONPRINT",,/*cTitle*/,"@!"/*cPicture*/ ,{|| Pmr250FmtHours( IntToHora(oTotalHoras:ReportValue(),5 ) )}/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

oApontamento:SetTotalInLine(.F.) 
oReport:SetTotalInLine(.F.) 

oReport:SetTotalText(STR0024)
	
oRecurso:Print()  

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Pmr250FmtHours
Converte as horas em valor.

@sample 	Pmr250FmtHours() 
@return		horas, numerico, horas em valor.

@author		SQUAD CRM / FAT
@since		09/05/18   
@version	P12.1.17 
/*/
//------------------------------------------------------------------------------
Static Function Pmr250FmtHours(cHours)  
	Local nPos		:= 0
	Local nHours	:= 0		
	Local cMM		:= ""
	Default cHours  := "00:00"

	nPos := At(":",cHours)
 
	nHours := Val( SubStr(cHours,1,nPos-1) )
	cMM	   := Substr(cHours,nPos,Len(cHours))
	cHours := Str(nHours,nHours) + cMM

Return cHours  
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SeekCusto1  �Autor  �Reynaldo Miyashita� Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca o custo do apontamento do recurso, caso o tipo de     ���
���          � apontamento seja por custo m�dio. Pois deve procurar a     ���
���          � movimentacao interna gerada pelo apontamento.              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SeekCusto1(cCodTipoReal,cCodProduto ,cLocal ,cNumSeq ,nCusto)
Local aAreaSD3 := SD3->(GetArea())

DEFAULT nCusto := 0

	If cCodTipoReal == "1" // Custo real por custo medio, ou seja a movimentacao interna
		dbSelectArea("SD3")
		dbSetOrder(3)
		If dbSeek(xFilial("SD3")+cCodProduto+cLocal+cNumSeq)
			nCusto := SD3->D3_CUSTO1
		EndIf
	EndIf
	
RestArea(aAreaSD3)
Return nCusto