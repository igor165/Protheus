#include "protheus.ch"
#include "report.ch"
#include "AGRAR760.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRAR760
Função de relatorio de Ticket de Pesagem
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AGRAR760()
Local oReport
           
If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressão                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef("REPORT")
	oReport:PrintDialog()	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relatório

@return oReport	Objeto criado com o formato do relatório
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
Local oReport		:= NIL
Local oSection1	:= NIL
Local oSection2	:= NIL

Private cAliasRel	:= ""

DEFINE REPORT oReport NAME "AGRAR760" TITLE STR0001 PARAMETER "REPORT" ACTION {|oReport| PrintReport(oReport)}

oReport:lParamPage = .F.  //Não imprime os parametros
oReport:SetCustomText( {|| AG760MoCab(oReport, POSICIONE("ADA",1,FWxFilial("ADA")+&(cAliasRel+"->DXS_CODCTP"),"ADA_SAFRA")) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³"Cabecalho Romaneio"                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "DXI" LINE STYLE

DEFINE BORDER OF oSection1 EDGE_BOTTOM  WEIGHT 2 

DEFINE CELL NAME "NJ0_NOME"		OF oSection1 ALIAS "NJ0" TITLE STR0002 AUTO SIZE
DEFINE CELL NAME "DXI_LJPRO"	OF oSection1 TITLE STR0003 AUTO SIZE CELL BREAK
DEFINE CELL NAME "NJ0_CGC"		OF oSection1 ALIAS "NJ0" SIZE 20 
DEFINE CELL NAME "NJ0_INSCR"  	OF oSection1 ALIAS "NJ0" SIZE 20 CELL BREAK
DEFINE CELL NAME "DXS_PRODUTO" 	OF oSection1 TITLE STR0004 SIZE 30 BLOCK {|| POSICIONE("SB1",1,FWxFilial("SB1")+&(cAliasRel+"->DXS_CODPRO"),"B1_DESC" ) } //Produto

DEFINE CELL NAME "DXS_NUMNFS" 	OF oSection1 SIZE 30 //Nota Fiscal
DEFINE CELL NAME "DXS_SERNFS" 	OF oSection1 SIZE 30 CELL BREAK //Serie Nota

DEFINE SECTION oSection2 OF oReport TITLE STR0005 TABLES "DXM" LINE STYLE

DEFINE BORDER OF oSection2 EDGE_BOTTOM  WEIGHT 2 

DEFINE CELL NAME "DXS_PESO2" 	OF oSection2 TITLE STR0006 ALIAS "DXI" SIZE 19 ALIGN RIGHT CELL BREAK 
DEFINE CELL NAME "DXS_PESO1" 	OF oSection2 TITLE STR0007 ALIAS "DXI" SIZE 20 ALIGN RIGHT CELL BREAK 
DEFINE CELL NAME "DXS_PSSUBT"	OF oSection2 TITLE STR0008 ALIAS "DXI" SIZE 17 ALIGN RIGHT CELL BREAK  

DEFINE SECTION oSection3 OF oReport TITLE STR0009 TABLES "SA4" LINE STYLE

DEFINE BORDER OF oSection3 EDGE_BOTTOM  WEIGHT 2 

DEFINE CELL NAME "DXS_PLACA" 	OF oSection3 SIZE 19 CELL BREAK 
DEFINE CELL NAME "A4_NOME" 		OF oSection3 TITLE STR0009 SIZE 30 CELL BREAK 
DEFINE CELL NAME "A4_END" 		OF oSection3 SIZE 20 CELL BREAK 
DEFINE CELL NAME "CC2_MUN"  	OF oSection3 SIZE 20 BLOCK {|| POSICIONE("CC2",1,FWxFilial("CC2")+&(cAliasRel+"->A4_EST") + &(cAliasRel+"->A4_COD_MUN") ,"CC2_MUN") } 
DEFINE CELL NAME "A4_EST" 	 	OF oSection3 TITLE "" SIZE 5 CELL BREAK 
DEFINE CELL NAME "A4_CGC"		OF oSection3 SIZE 20 
DEFINE CELL NAME "A4_INSEST"  	OF oSection3 SIZE 20 CELL BREAK

DEFINE CELL NAME "Pesagem" 	OF oSection3 TITLE STR0010 BOLD SIZE 50 CELL BREAK //Pesagem efetuada por balanca eletronica

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que serão impressas no relatório

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@return void
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oCab	    := oReport:Section(1)
Local oPesos	:= oReport:Section(2)
Local oTransp	:= oReport:Section(3)

 
#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Begin Report Query oCab   
		cAliasRel:= GetNextAlias()
		BeginSql Alias cAliasRel
			SELECT DXS.DXS_CODIGO,DXI.DXI_PRDTOR,DXI.DXI_LJPRO,DXS.DXS_CODPRO,DXS.DXS_NUMNFS,DXS.DXS_SERNFS,
			NJ0.NJ0_NOME,NJ0.NJ0_CGC,NJ0.NJ0_INSCR,DXS_CODCTP
			FROM %table:DXS% DXS,
			     %table:DXT% DXT,
				  %table:DXI% DXI,
				  %table:NJ0% NJ0,
			WHERE DXS.DXS_FILIAL = %xFilial:DXS% AND
				DXT.DXT_FILIAL = %xFilial:DXS% AND
				DXS.DXS_CODIGO = DXT.DXT_CODIGO AND 
				DXI.DXI_FILIAL = %xFilial:DXS% AND
				DXI.DXI_ROMSAI = DXS.DXS_CODIGO AND
				NJ0.NJ0_CODENT = DXI.DXI_PRDTOR AND
				NJ0.NJ0_LOJENT = DXI.DXI_LJPRO  AND 
				NJ0.NJ0_FILIAL = %xFilial:NJ0% AND
				DXS.DXS_CODIGO = %Exp:DXS->DXS_CODIGO% AND
				DXS.%notDel% AND
				DXT.%notDel% AND
				DXI.%notDel% AND	
				NJ0.%notDel%
			GROUP BY DXS.DXS_CODIGO,DXI.DXI_PRDTOR,DXI.DXI_LJPRO,DXS.DXS_CODPRO,DXS.DXS_NUMNFS,DXS.DXS_SERNFS,
					 NJ0.NJ0_NOME,NJ0.NJ0_CGC,NJ0.NJ0_INSCR,DXS_CODCTP		
		EndSql 
	End Report Query oCab
		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime dados do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCab:Init()
	oCab:Print()
	oCab:Finish()
	(cAliasRel)->(DBCloseArea())
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio do Pesos	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Begin Report Query oPesos   
	
		cAliasRel:= GetNextAlias()
		
		BeginSql Alias cAliasRel
			SELECT *
			FROM %table:DXS% DXS
				WHERE DXS.DXS_FILIAL = %xFilial:DXS% AND
				DXS.DXS_CODIGO = %Exp:DXS->DXS_CODIGO% AND
				DXS.%notDel%
		EndSql

	End Report Query oPesos		
		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime dados de Pesos	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPesos:Init()
	oPesos:Print()
	oPesos:Finish()
	(cAliasRel)->(DBCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio da transportadora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	Begin Report Query oTransp   
	
		cAliasRel:= GetNextAlias()
		
		BeginSql Alias cAliasRel
			SELECT *
			FROM %table:DXS% DXS,
				 %table:SA4% SA4

			WHERE DXS.DXS_FILIAL = %xFilial:DXS%      AND
				DXS.DXS_TRANSP = SA4.A4_COD            AND
				DXS.DXS_CODIGO = %Exp:DXS->DXS_CODIGO% AND
				DXS.%notDel% AND
				SA4.%notDel%
		EndSql

	End Report Query oTransp
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime dados de transportadora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTransp:Init()
	oTransp:Print()
	oTransp:Finish()
	(cAliasRel)->(DBCloseArea())
	
#ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AG760MoCab
Função para montar cabecalho do relatorio  

@param oReport Objeto para manipulação das seções, atributos e dados do relatório.
@return aCabec  Array com o cabecalho montado
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AG760MoCab(oReport, cSafra)
Local aCabec 	:= {}
Local cNmEmp  	:= ""   
Local cNmFilial  	:= ""   
Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabeçalho

Default cSafra := ""

If SM0->(Eof())
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

cNmEmp	:= AllTrim( SM0->M0_NOME )
cNmFilial	:= AllTrim( SM0->M0_FILIAL )

// Linha 1
AADD(aCabec, "__LOGOEMP__") // Esquerda

// Linha 2 
AADD(aCabec, cChar) //Esquerda
aCabec[2] += Space(9) // Meio
aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

// Linha 3
AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
aCabec[3] += Space(9) + oReport:cRealTitle // Meio
aCabec[3] += Space(9) + "Dt.Ref:" + Dtoc(dDataBase)   // Direita

// Linha 4
AADD(aCabec, RptHora + oReport:cTime) //Esquerda
aCabec[4] += Space(9) // Meio
aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

// Linha 5
AADD(aCabec, "Empresa:" + cNmEmp) //Esquerda
aCabec[5] += Space(9) // Meio
If !Empty(cSafra)
	aCabec[5] += Space(9)+ "Safra:"+cSafra   // Direita
EndIf     

// Linha 5
AADD(aCabec, "Filial:" + cNmFilial) //Esquerda

Return aCabec
