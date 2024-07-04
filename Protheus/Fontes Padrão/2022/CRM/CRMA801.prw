#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "CRMA800.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA801

Rotina de máscara de aplicação de filtros do CRM para a rotina de
Painel de Propostas.

@author Thamara Villa Jacomo
@since 06/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Function CRMA801( cVisao )

Local cFilEnt		:= ""
Local cPerg			:= "CRMA801" 
Local cFilDef		:= ""
Local cTipoDB 		:= AllTrim( Upper( TcGetDb() ) )
Local cCatenate		:= IIF(cTipoDB = "MSSQL","+","||") //Sinal de concatenação  
Local aAddFil		:= {}
Local lCRM801Fil	:= ExistBlock( "CRM801FIL" )	// P.E. para add Filtro ao Browse
Local cRetFil 		:= ""

Default cVisao	:= "" 

If Pergunte(cPerg,.T.)
	cFilEnt	:= CRMXFilEnt( "AD1", .T. ) 
	
	cFilDef := "@ ADY_DATA BETWEEN '" + dTos(MV_PAR03) + "' AND '" + dTos(MV_PAR04) + "'"
	
	If !Empty( MV_PAR01 ) .And. !Empty( MV_PAR02 ) 
		cFilDef += " AND ADY_DTUPL BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'"	
	EndIf
	
	If lCRM801Fil //POnto de entrada para adicionar filtro Default ao Painel de Propostas. Filtro será adicionado em todos os módulos que chamam essa rotina (FAT & CONTRATOS).
		cRetFil:= ExecBlock("CRM801FIL",.F.,.F.)	
		If ValType(cRetFil) == "C"
			cFilDef += " AND "+cRetFil
		Endif
	Endif
	
	If !Empty(cFilEnt) // Se vazio, é ADMIN - Não carrega filtro
		cFilDef += " AND ADY_FILIAL"+ cCatenate  +"ADY_OPORTU IN ( SELECT AO4_CHVREG FROM " + RetSqlName("AO4")+ " WHERE AO4_CHVREG = ADY_FILIAL"+cCatenate+"ADY_OPORTU"
		cFilDef += " AND D_E_L_E_T_ = ' ' AND " + cFilEnt + " ) " 
	EndIf	
	
	CRMA800( aAddFil, cVisao, cFilDef )

EndIf 

Return Nil 