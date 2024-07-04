#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "GTPR600.CH"


//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPR600

@type Function
@author GTP
@since 12/02/2020
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Function GTPR600()
local oReport
local cPerg := PadR('GTPR600',10)

Pergunte(cPerg,.T.)
 
oReport := ReportDef(cPerg)
oReport:printDialog()
Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} ReportDef

@type Function
@author GTP
@since 12/02/2020
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local oReport
Local oSection
Local oBreak
Local cTitulo := STR0001 //"Bilhetes - Divergencias"
Local cDescri := STR0002 //"Este relatorio apresenta os bilhetes com divergencias."
Local oCabec
 
oReport := TReport():New('GTPR600', cTitulo, cPerg, {|oReport| PrintReport(oReport)},cDescri)
oReport:SetTotalInLine(.F.)
oReport:ShowParamPage(.T.)
oCabec := TRSection():New(oReport,STR0003,{"GIC"})
oCabec:SetTotalInLine(.F.)

TRCell():New(oCabec, "GIC_FILIAL", "GIC", STR0003,PesqPict('GIC',"GIC_FILIAL"),TamSX3("GIC_FILIAL")[1]+1,/**/,/**/)//"Filial"
TRCell():New(oCabec, "TMP_FILIAL", "GIC", STR0004,"@!",30,/**/,/**/) //'Nome Filial'
TRCell():New(oCabec, "GIC_AGENCI", "GIC", STR0005,PesqPict('GIC',"GIC_AGENCI"),TamSX3("GIC_AGENCI")[1]+1,/**/,/**/) //'Agencia'
TRCell():New(oCabec, "TMP_AGENCI", "GIC", STR0006,"@!",30,/**/,/**/) //'DescriÃ§Ã£o'

oSection := TRSection():New(oReport,STR0003,{"GIC"}) //"Filial"

//GIC_DTERRO
TRCell():new(oSection, "GIC_BILHET", "GIC", STR0007,PesqPict('GIC',"GIC_BILHET"),20,/**/,/**/) //'Bilhete'
TRCell():new(oSection, "GIC_CODIGO", "GIC", STR0008,PesqPict('GIC',"GIC_CODIGO"),20,/**/,/**/) //'CÃ³digo'
TRCell():new(oSection, "GIC_DTVEND", "GIC", STR0009,PesqPict('GIC',"GIC_DTVEND"),12,/**/,/**/) //'Data Venda'

TRCell():new(oSection, "GIC_TIPO", "GIC", STR0010,PesqPict('GIC',"GIC_TIPO"),10,/**/,/**/) //'Tipo'
TRCell():new(oSection, "GIC_STATUS", "GIC", STR0011,PesqPict('GIC',"GIC_STATUS"),10,/**/,/**/) //'Status'
TRCell():new(oSection, "GIC_ORIGEM", "GIC", STR0012,PesqPict('GIC',"GIC_ORIGEM"),10,/**/,/**/) //'Origem'    //1=Manual;2=Eletronica 
TRCell():new(oSection, "GIC_CCF", "GIC", STR0013,PesqPict('GIC',"GIC_CCF"),10,/**/,/**/) //'CCF'
TRCell():new(oSection, "GIC_ECFSEQ", "GIC", STR0014,PesqPict('GIC',"GIC_ECFSEQ"),10,/**/,/**/) //'ECFSEQ'
TRCell():new(oSection, "GIC_ECFSER", "GIC", STR0015,PesqPict('GIC',"GIC_ECFSER"),10,/**/,/**/) //'ECFSER'

TRCell():new(oSection, "GIC_DTERRO", "GIC", STR0016,PesqPict('GIC',"GIC_DTERRO"),12,/**/,/**/) //'Data do erro'
TRCell():new(oSection, "GIC_MOTIVO", "GIC", STR0017,'@!',50,/**/,/**/,/**/,.F.) //'Motivo Erro'

oBreak := TRBreak():New(oCabec,oCabec:Cell("GIC_AGENCI"),"Quebra") //"Quebra"


oBreak:SetPageBreak(.F.)
oBreak:SetTotalInLine(.F.)
oBreak:SetBorder("BOTTOM",0,0,.T.)
 	
return (oReport)
 

//------------------------------------------------------------------------------
/* /{Protheus.doc} PrintReport

@type Function
@author GTP
@since 12/02/2020
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function PrintReport(oReport)

Local oCabec   := oReport:Section(1)
Local oSection := oReport:Section(2)
Local cAliasJob := GetNextAlias()
Local cQuery    := ""
Local cFilAge   := ""
Local cAgenci   := ""
Local aArea     := GetArea()

Pergunte('GTPR600',.F.)

If !(Empty(MV_PAR01)) .OR. !(Empty(MV_PAR02))
	cQuery += " AND GIC.GIC_DTVEND BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf

If !(Empty(MV_PAR03)) .OR. !(Empty(MV_PAR04))
	cQuery += " AND GIC.GIC_AGENCI BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
EndIf

If !(Empty(MV_PAR05))
	If MV_PAR05 <> 5
		cQuery += " AND GIC.GIC_STAPRO ='" + ALLTRIM(STR(MV_PAR05-1)) + "'"
	EndIf
EndIf

cQuery := "%"+cQuery+"%"

BeginSQL Alias cAliasJob
	
	SELECT GIC.R_E_C_N_O_ AS RECLOC 
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GI6% GI6
		ON  GI6.%NotDel%
		AND GI6.GI6_FILIAL = GIC.GIC_FILIAL
		AND GI6.GI6_CODIGO = GIC.GIC_AGENCI 
	WHERE GIC.%NotDel%
		%Exp:cQuery%
		AND GIC.GIC_MOTIVO != ' '
		AND GIC.GIC_DTERRO != ' '
	ORDER BY GIC_FILIAL,GIC_AGENCI,GIC_MOTIVO,GIC_TIPO,GIC_STATUS,GIC_ORIGEM,GIC_DTVEND
			
EndSQL

If (cAliasJob)->(!Eof())
	(cAliasJob)->(DbGoTop())
	oReport:SetMeter((cAliasJob)->(RecCount()))

	While (cAliasJob)->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
 		
 		GIC->(DbGoTo((cAliasJob)->RECLOC))
 		
		oReport:IncMeter()
 		
 		If GIC->GIC_FILIAL + GIC->GIC_AGENCI != cFilAge + cAgenci 
	 		If !(EMPTY(cFilAge + cAgenci))
	 			oReport:SkipLine(2)
	 			oCabec:Finish()
	 			oSection:Finish()
	 		EndIf
	 		oCabec:Init()
			oCabec:SetHeaderSection(.T.)
			
			oCabec:Cell("GIC_FILIAL"):SetValue(GIC->GIC_FILIAL)
			oCabec:Cell("GIC_FILIAL"):SetAlign("LEFT")
			
			oCabec:Cell("TMP_FILIAL"):SetValue(FWFilialName(,GIC->GIC_FILIAL))
			oCabec:Cell("TMP_FILIAL"):SetAlign("LEFT")
			
			oCabec:Cell("GIC_AGENCI"):SetValue(GIC->GIC_AGENCI)
			oCabec:Cell("GIC_AGENCI"):SetAlign("LEFT")
			
			oCabec:Cell("TMP_AGENCI"):SetValue(POSICIONE("GI6",1,GIC->GIC_FILIAL+GIC->GIC_AGENCI,"GI6_DESCRI"))
			oCabec:Cell("TMP_AGENCI"):SetAlign("LEFT")
			
			oCabec:PrintLine()
			cFilAge := GIC->GIC_FILIAL
			cAgenci := GIC->GIC_AGENCI
		EndIf
			
 		oSection:Init()
		oSection:SetHeaderSection(.T.)
 		
		oSection:Cell("GIC_CODIGO"):SetValue(GIC->GIC_CODIGO)
		oSection:Cell("GIC_CODIGO"):SetAlign("LEFT")
		
		oSection:Cell("GIC_BILHET"):SetValue(GIC->GIC_BILHET)
		oSection:Cell("GIC_BILHET"):SetAlign("LEFT")
		
		oSection:Cell("GIC_DTVEND"):SetValue(GIC->GIC_DTVEND)
		oSection:Cell("GIC_DTVEND"):SetAlign("LEFT")
		
		oSection:Cell("GIC_DTERRO"):SetValue(GIC->GIC_DTERRO)
		oSection:Cell("GIC_DTERRO"):SetAlign("LEFT")
		
		oSection:Cell("GIC_MOTIVO"):SetValue(SUBSTRING(GIC->GIC_MOTIVO,1,100)) 
		oSection:Cell("GIC_MOTIVO"):SetAlign("LEFT")
			
		oSection:PrintLine()
	 
		(cAliasJob)->(dbSkip())
	EndDo
EndIf
(cAliasJob)->(DbCloseArea())

oCabec:Finish()
oSection:Finish()

RestArea(aArea)
Return
