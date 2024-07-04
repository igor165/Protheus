#include "report.ch"
#include "protheus.ch"
#include "UBAR002.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR002
Função de relatorio Movimentação por período
@author Vitor Alexandre de Barba
@since 16/07/2013
@version MP11
/*/
//-------------------------------------------------------------------
Function UBAR002()
Local oReport      
Local cPerg := "UBAR002"
           
If FindFunction("TRepInUse") .And. TRepInUse()
	   
	/* Grupo de perguntas UBAR002
	        mv_par01 - Filial de
		mv_par02 - Filial Ate 
		mv_par03 - Safra
		mv_par04 - Produtor De
		mv_par05 - Loja De 
		mv_par06 - Produtor Ate
		mv_par07 - Loja Ate
		mv_par08 - Fazenda De 
		mv_par09 - Fazenda Ate
		mv_par10 - Periodo Inicial
		mv_par11 - Periodo Final
		mv_par12 - Produto caroço
	*/	
	Pergunte(cPerg,.F.)

	//-------------------------
	// Interface de impressão    
	//-------------------------
	oReport:= ReportDef(cPerg)
	oReport:PrintDialog()	
EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relatório

@return oReport	Objeto criado com o formato do relatório
@author Vitor Alexandre de Barba
@since 16/07/2013
@version MP11
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local oReport	:= NIL
Local oSec1	:= NIL
Local oSec2	:= NIL
Local oSec3	:= NIL
Local oSec4	:= NIL
Local oFunc1	:= NIL
Local oFunc4  := NIL

DEFINE REPORT oReport NAME "UBAR002" TITLE STR0001 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)}
oReport:uParam 			:= cPerg // Grupo de perguntas
oReport:lParamPage 		:= .F. //Não imprime os parametros
oReport:nFontBody 		:= 6 //Aumenta o tamanho da fonte
oReport:cFontBody 		:= "Arial"
oReport:SetLandscape()  // Define a orientação da pagina como paisagem
oReport:SetCustomText( {|| UBARCabec(oReport, mv_par03) } ) // Cabeçalho customizado

//---------
// Seção 1
//---------
DEFINE SECTION oSec1 OF oReport TITLE STR0002 TABLES "DXM", "DXL", "SD3" //"Algodão em Caroço"
	oSec1:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec1:SetAutoSize(.T.) 		// Define que as células serão ajustadas automaticamente na seção
	oSec1:SetReadOnly(.T.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec1:ShowHeader(.T.)        //Lista cabeçalho da sec.
	DEFINE CELL NAME "DXM_PRODUTOR"	OF oSec1 TITLE STR0003	SIZE 25
	DEFINE CELL NAME "ENTANT" 	 	OF oSec1 TITLE STR0004	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "ENTPER"    	OF oSec1 TITLE STR0005	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "ENTTOTAL"   	OF oSec1 TITLE STR0006 	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "BENANT" 		OF oSec1 TITLE STR0007	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "BENPER"		OF oSec1 TITLE STR0008 	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "BENTOTAL" 	OF oSec1 TITLE STR0009 	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "SDOCARGAS" 	OF oSec1 TITLE STR0010	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "ESPACO"   	OF oSec1 TITLE ""			SIZE 1
	DEFINE CELL NAME "ENTANTKG" 	OF oSec1 TITLE STR0011 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "ENTPERKG"	  	OF oSec1 TITLE STR0012 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "ENTTOTALKG" 	OF oSec1 TITLE STR0013	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENANTKG" 	OF oSec1 TITLE STR0014 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENPERKG"	  	OF oSec1 TITLE STR0015 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENTOTALKG" 	OF oSec1 TITLE STR0016	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SALDOKG"    	OF oSec1 TITLE STR0017	PICTURE "@E 9,999,999,999.99"	
	
	oSec1:SetTotalText(STR0050) // Texto da seção tolalizadora
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("ENTANT")     OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("ENTPER")     OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("ENTTOTAL")   OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("BENANT")     OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("BENPER")     OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("BENTOTAL")   OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("SDOCARGAS")  OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("ENTANTKG")   OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("ENTPERKG")   OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("ENTTOTALKG") OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("BENANTKG")   OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("BENPERKG")   OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("BENTOTALKG") OF oSec1 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("SALDOKG")    OF oSec1 FUNCTION SUM  NO END REPORT 

	//Bordas
	DEFINE CELL BORDER OF oSec1 EDGE_ALL  
	DEFINE CELL HEADER BORDER OF oSec1 EDGE_ALL
 		
DEFINE SECTION oSec2 OF oReport TITLE STR0018 TABLES "DXI", "DXS"
	oSec2:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec2:SetAutoSize(.T.) 		// Define que as células serão ajustadas automaticamente na seção
	oSec2:SetReadOnly(.T.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec2:ShowHeader(.T.)
	
	DEFINE CELL NAME "DXI_PRODUTOR"	OF oSec2 TITLE STR0003	SIZE 25
	DEFINE CELL NAME "BENANT" 	   	OF oSec2 TITLE STR0007	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "BENPER" 	   	OF oSec2 TITLE STR0008 	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "BENTOTAL" 	OF oSec2 TITLE STR0009 	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "SAIANT" 	  	OF oSec2 TITLE STR0019	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "SAIPER"    	OF oSec2 TITLE STR0020	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "SAITOTAL"   	OF oSec2 TITLE STR0021 	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "SDOFARDOS" 	OF oSec2 TITLE STR0022	PICTURE "@E 9,999,999,999"
	DEFINE CELL NAME "ESPACO"   	OF oSec2 TITLE ""			SIZE 1
	DEFINE CELL NAME "BENANTKG" 	OF oSec2 TITLE STR0014 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENPERKG"	  	OF oSec2 TITLE STR0015 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENTOTALKG" 	OF oSec2 TITLE STR0016	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SAIANTKG" 	OF oSec2 TITLE STR0023 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SAIPERKG"	 	OF oSec2 TITLE STR0024 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SAITOTALKG"	OF oSec2 TITLE STR0025	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SALDOKG"   	OF oSec2 TITLE STR0017	PICTURE "@E 9,999,999,999.99"
	
	oSec2:SetTotalText(STR0026) // Texto da seção tolalizadora
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("BENANT")     OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("BENPER")     OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("BENTOTAL")   OF oSec2 FUNCTION SUM  NO END REPORT
	 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SAIANT")     OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SAIPER")     OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SAITOTAL")   OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SDOFARDOS")  OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("BENANTKG")   OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("BENPERKG")   OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("BENTOTALKG") OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SAIANTKG")   OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SAIPERKG")   OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SAITOTALKG") OF oSec2 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc2 FROM oSec2:Cell("SALDOKG")    OF oSec2 FUNCTION SUM  NO END REPORT 
	
	//Bordas
	DEFINE CELL BORDER OF oSec2 EDGE_ALL  
	DEFINE CELL HEADER BORDER OF oSec2 EDGE_ALL

DEFINE SECTION oSec3 OF oReport TITLE STR0027 TABLES "DXL", "SD3"
	oSec3:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec3:SetAutoSize(.T.) 		// Define que as células serão ajustadas automaticamente na seção
	oSec3:SetReadOnly(.T.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec3:ShowHeader(.T.)
	
	DEFINE CELL NAME "DXL_PRODUTOR"	OF oSec3 TITLE STR0003	SIZE 25
	DEFINE CELL NAME "PRDANTKG"    	OF oSec3 TITLE STR0028 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "PRDPERKG"	   	OF oSec3 TITLE STR0029 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "PRDTOTALKG"  	OF oSec3 TITLE STR0030 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "ESPACO"  		OF oSec3 TITLE ""			SIZE 1
	DEFINE CELL NAME "SAIANTKG"    	OF oSec3 TITLE STR0023 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SAIPERKG"	   	OF oSec3 TITLE STR0024 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SAITOTALKG"  	OF oSec3 TITLE STR0025	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "SALDOKG"     	OF oSec3 TITLE STR0017	PICTURE "@E 9,999,999,999.99"
	
	oSec3:SetTotalText(STR0031) // Texto da seção tolalizadora
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("PRDANTKG")   OF oSec3 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("PRDPERKG")   OF oSec3 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("PRDTOTALKG") OF oSec3 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("SAIANTKG")   OF oSec3 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("SAIPERKG")   OF oSec3 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("SAITOTALKG") OF oSec3 FUNCTION SUM  NO END REPORT 
	DEFINE FUNCTION oFunc3 FROM oSec3:Cell("SALDOKG")    OF oSec3 FUNCTION SUM  NO END REPORT 

	//Bordas
	DEFINE CELL BORDER OF oSec3 EDGE_ALL  
	DEFINE CELL HEADER BORDER OF oSec3 EDGE_ALL
	
DEFINE SECTION oSec4 OF oReport TITLE STR0032 TABLES "DXL", "SD3"
	oSec4:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec4:SetAutoSize(.T.) 		// Define que as células serão ajustadas automaticamente na seção
	oSec4:SetReadOnly(.T.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec4:ShowHeader(.T.)
	oSec4:SetTotalText(STR0036) // Texto da seção totalizadora

	//Bordas
	DEFINE CELL BORDER OF oSec4 EDGE_ALL  
	DEFINE CELL HEADER BORDER OF oSec4 EDGE_ALL
	
	DEFINE CELL NAME "DXL_PRODUTOR"	OF oSec4 TITLE STR0003	SIZE 25	 
	DEFINE CELL NAME "BENEANT" 	   	OF oSec4 TITLE STR0007 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENEPER"	   	OF oSec4 TITLE STR0008 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "BENETOTAL"   	OF oSec4 TITLE STR0009 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "ESPACO"   	OF oSec4 TITLE ""			SIZE 1	
	DEFINE CELL NAME "PRENSA"  		OF oSec4 TITLE STR0052
	DEFINE CELL NAME "RENANT"  		OF oSec4 TITLE STR0033 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "RENPER"  		OF oSec4 TITLE STR0034 	PICTURE "@E 9,999,999,999.99"
	DEFINE CELL NAME "RENTOTAL"		OF oSec4 TITLE STR0035 	PICTURE "@E 9,999,999,999.99"
	
	DEFINE FUNCTION oFunc4 FROM oSec4:Cell("BENEANT")   	OF oSec4 FUNCTION SUM  		NO END REPORT 
	DEFINE FUNCTION oFunc4 FROM oSec4:Cell("BENEPER")   	OF oSec4 FUNCTION SUM  		NO END REPORT 
	DEFINE FUNCTION oFunc4 FROM oSec4:Cell("BENETOTAL") 	OF oSec4 FUNCTION SUM  		NO END REPORT
	DEFINE FUNCTION oFunc4 FROM oSec4:Cell("RENANT")    	OF oSec4 FUNCTION AVERAGE  	NO END REPORT 
	DEFINE FUNCTION oFunc4 FROM oSec4:Cell("RENPER")    	OF oSec4 FUNCTION AVERAGE  	NO END REPORT 
	DEFINE FUNCTION oFunc4 FROM oSec4:Cell("RENTOTAL")  	OF oSec4 FUNCTION AVERAGE  	NO END REPORT
	
	oFunc1:lEndSection:= .T.
	oFunc2:lEndSection:= .T.
	oFunc3:lEndSection:= .T.
	oFunc4:lEndSection:= .T.	
Return oReport	

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que serão impressas no relatório

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@return 
@author Vitor Alexandre de Barba
@since 16/07/2013
@version MP11
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oSec1		 := oReport:Section(1)
Local oSec2		 := oReport:Section(2)
Local oSec3		 := oReport:Section(3)
Local oSec4		 := oReport:Section(4)
Local cAlias	 := ""
Local cAliasAux	 := ""
Local cAliasACB  := ""
Local cAliasAPB  := ""
Local cAliasAPP  := ""
Local cAliasAPS  := ""
Local cAliasCP   := ""
Local cQueryAux1 := ""
Local cQueryAux2 := ""
Local cQueryAux3 := ""
Local cQueryAux4 := ""
Local cUN        := ""

cUN := A655GETUNB( )
	
#IFDEF TOP
	
	/*********** Tratamento das Perguntas **********/	
	
	
	
	If !Empty(mv_par03) 			
		cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
		cQueryAux1 += " AND DXM_SAFRA = '" + mv_par03 + "'"
		cQueryAux2 += " DXL_SAFRA = '" + mv_par03 + "'"	
		cQueryAux3 += " DXI_SAFRA = '" + mv_par03 + "'"
		cQueryAux4 += " DXI_SAFRA = '" + mv_par03 + "'"
	Endif
	
	If !Empty(mv_par01)
		if Empty(mv_par02) 
			If !Empty(cQueryAux1)
				cQueryAux1 += " AND DXM_FILIAL = '" + mv_par01 + "'"
			Else
				cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
				cQueryAux1 += " AND DXM_FILIAL = '" + mv_par02 + "'"
			Endif
		Endif	
	Endif
	
	If !Empty(mv_par04)
		if Empty(mv_par06) 
			If !Empty(cQueryAux1)
				cQueryAux1 += " AND DXM_PRDTOR = '" + mv_par04 + "'"
			Else
				cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
				cQueryAux1 += " AND DXM_PRDTOR = '" + mv_par04 + "'"
			Endif
		Endif	
	Endif
	
	If !Empty(mv_par06)
		If !Empty(cQueryAux1)
			cQueryAux1 += " AND DXM_PRDTOR >= '" + mv_par04 + "'" + " AND DXM_PRDTOR <= '" + mv_par04 + "'" 
		Else
			cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
			cQueryAux1 += " AND DXM_PRDTOR = '" + mv_par04 + "'" + " AND DXM_PRDTOR <= '" + mv_par06 + "'"
		Endif
	Endif
	
	If !Empty(mv_par05)
		if Empty(mv_par07) 
			If !Empty(cQueryAux1)
				cQueryAux1 += " AND DXM_LJPRO = '" + mv_par05 + "'"
			Else
				cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
				cQueryAux1 += " AND DXM_LJPRO = '" + mv_par05 + "'"
			Endif
		Endif	
	Endif
				  

	If !Empty(mv_par07)
        If !Empty(cQueryAux1)
			cQueryAux1 += " AND DXM_LJPRO >= '" + mv_par05 + "'" + " AND DXM_LJPRO <= '" + mv_par07 + "'"
		Else
			cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
			cQueryAux1 += " AND DXM_LJPRO = '" + mv_par05 + "'" + " AND DXM_LJPRO <= '" + mv_par07 + "'"
		Endif
	Endif
	
	If !Empty(mv_par08)
		if Empty(mv_par09) 
			If !Empty(cQueryAux1)
				cQueryAux1 += " AND DXM_FAZ = '" + mv_par08 + "'"
				cQueryAux2 += " AND DXL_FAZ = '" + mv_par08 + "'"
				cQueryAux3 += " AND DXI_FAZ = '" + mv_par08 + "'"
				cQueryAux4 += " AND DXI_FAZ = '" + mv_par08 + "'"
			Else
				cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
				cQueryAux1 += " AND DXM_FAZ = '" + mv_par08 + "'"
				cQueryAux2 += " DXL_FAZ = '" + mv_par08 + "'"
				cQueryAux3 += " DXI_FAZ = '" + mv_par08 + "'"
				cQueryAux4 += " DXI_FAZ = '" + mv_par08 + "'"
			Endif
		Endif	
	Endif
	
	If !Empty(mv_par08)
        If !Empty(cQueryAux1)
			cQueryAux1 += " AND DXM_FAZ >= '" + mv_par08 + "'" + " AND DXM_FAZ <= '" + mv_par09 + "'"
			cQueryAux2 += " AND DXL_FAZ >= '" + mv_par08 + "'" + " AND DXL_FAZ <= '" + mv_par09 + "'"
			cQueryAux3 += " AND DXI_FAZ >= '" + mv_par08 + "'" + " AND DXI_FAZ <= '" + mv_par09 + "'"
			cQueryAux4 += " AND DXI_FAZ >= '" + mv_par08 + "'" + " AND DXI_FAZ <= '" + mv_par09 + "'"
		Else
			cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
			cQueryAux1 += " AND DXM_FAZ = '" + mv_par08 + "'" + " AND DXM_FAZ <= '" + mv_par09 + "'"
			cQueryAux2 += " DXL_FAZ = '" + mv_par08 + "'" + " AND DXL_FAZ <= '" + mv_par09 + "'"
			cQueryAux3 += " DXI_FAZ = '" + mv_par08 + "'" + " AND DXI_FAZ <= '" + mv_par09 + "'"
			cQueryAux4 += " DXI_FAZ = '" + mv_par08 + "'" + " AND DXI_FAZ <= '" + mv_par09 + "'"
		Endif
	Endif
    
    If !Empty(cQueryAux1)
		cQueryAux1 += " AND DXM_DTEMIS <= '" + dtos(mv_par11) + "'"
		cQueryAux3 += " AND DXL_DTBEN <= '" + dtos(mv_par11) + "'"
		cQueryAux4 += " AND DXS_DATA <= '" + dtos(mv_par11) + "'"
		
		If !Empty(cUN)
			cQueryAux1 += " AND DXM_CODUNB = '" + cUN + "'"
			cQueryAux2 += " AND DXL_CODUNB = '" + cUN + "'"
			cQueryAux3 += " AND DXI_CODUNB = '" + cUN + "'"
			cQueryAux4 += " AND DXI_CODUNB = '" + cUN + "'"
		Endif	
	Else
		cQueryAux1 += " WHERE DXM.D_E_L_E_T_ = '' "
		cQueryAux1 += " AND DXM_DTEMIS <= '" + dtos(mv_par11) + "'"
		
		cQueryAux3 += " DXL_DTBEN <= '" + dtos(mv_par11) + "'"
		
		cQueryAux4 += " DXS_DATA <= '" + dtos(mv_par11) + "'"		
		
		If !Empty(cUN)
			cQueryAux1 += " AND DXM_CODUNB = '" + cUN + "'"
			cQueryAux2 += " AND DXL_CODUNB = '" + cUN + "'"
			cQueryAux3 += " AND DXI_CODUNB = '" + cUN + "'"
			cQueryAux4 += " AND DXI_CODUNB = '" + cUN + "'"
		Endif	
	Endif
	
	If Empty(cQueryAux2)
	    cQueryAux2 += "TRUE"
	    cQueryAux3 += "TRUE"
	    cQueryAux4 += "TRUE"
	Endif 
	
	cQueryAux1:= "%" + cQueryAux1 + "%" //DXM
	cQueryAux2:= "%" + cQueryAux2 + "%" //DXL
	cQueryAux3:= "%" + cQueryAux3 + "%" //DXI
	cQueryAux4:= "%" + cQueryAux4 + "%" //DXI
	
	cAlias 		:= GetNextAlias()
	cAliasACB 	:= GetNextAlias()
	cAliasAPB 	:= GetNextAlias()
	cAliasAPS 	:= GetNextAlias()
	cAliasCP 	:= GetNextAlias()
	cAliasAux 	:= GetNextAlias()
	cAliasAPP 	:= GetNextAlias()
	
	//----------------------------
	// Query do relatorio
	//----------------------------
	
	Begin Report Query oSec1
		BeginSql Alias cAlias
		
           /* ALGODÃO EM CAROÇO ENTRADA */
		    SELECT DXM_PRDTOR AS DXM_PRDTOR,NJ0_NOME AS DXM_PRODUTOR,
                 COUNT(CASE WHEN DXM_DTEMIS <  %exp:dtos(mv_par10)% THEN DXM_CODIGO ELSE NULL END) AS ENTANT,
                 COUNT(CASE WHEN DXM_DTEMIS >= %exp:dtos(mv_par10)% THEN DXM_CODIGO ELSE NULL END) AS ENTPER,
                 COUNT(DXM_CODIGO) AS ENTTOTAL,
                 SUM(CASE WHEN DXM_DTEMIS <  %exp:dtos(mv_par10)% THEN DXL_PSLIQU ELSE 0 END) AS ENTANTKG,
                 SUM(CASE WHEN DXM_DTEMIS >= %exp:dtos(mv_par10)% THEN DXL_PSLIQU ELSE 0 END) AS ENTPERKG,
                 SUM(DXL_PSLIQU) AS ENTTOTALKG
     		FROM %table:DXM% DXM
			LEFT JOIN %table:DXL% DXL
                  ON DXM_CODIGO = DXL_CODROM
            LEFT JOIN %table:NJ0% NJ0
                  ON NJ0_CODENT = DXM_PRDTOR AND
                  NJ0_LOJENT = DXM_LJPRO
                  %exp:cQueryAux1%	  	  
            GROUP BY DXM_PRDTOR,NJ0_NOME  
		EndSql 
	End Report Query oSec1
    
    While  !oReport:Cancel() .And. (cAlias)->(!Eof())
		
		BeginSql Alias cAliasACB
		
			/* ALGODÃO EM CAROÇO BENEFICIADO */
			SELECT COUNT(CASE WHEN (DXL.DXL_DTBEN <  %exp:dtos(mv_par10)% AND DXL.DXL_STATUS = '6' )  THEN DXL_CODIGO ELSE NULL END) AS BENANT, 
			       COUNT(CASE WHEN (DXL.DXL_DTBEN >= %exp:dtos(mv_par10)% AND DXL.DXL_STATUS = '6' ) THEN DXL_CODIGO ELSE NULL END) AS BENPER, 
			       COUNT(DXL_CODIGO) AS BENTOTAL, 
			       SUM(CASE WHEN DXL.DXL_DTBEN <  %exp:dtos(mv_par10)% THEN DXL.DXL_PSLIQU ELSE 0 END) AS BENANTKG, 
			       SUM(CASE WHEN DXL.DXL_DTBEN >= %exp:dtos(mv_par10)% THEN DXL.DXL_PSLIQU ELSE 0 END) AS BENPERKG,
			       SUM(DXL.DXL_PSLIQU) AS BENTOTALKG
			       FROM %table:DXL% DXL
			       WHERE DXL_PRDTOR     = %exp:(cAlias)->(DXM_PRDTOR)%
					 AND DXL.DXL_DTBEN <= %exp:dtos(mv_par11)%					       
			         AND %exp:StrTran(cQueryAux2,'AND','')%	  	                         
		EndSql 

     	(cAliasACB)->(dbGoTop())
     	if (cAliasACB)->(!Eof())
		    oSec1:Cell("BENANT"):SetValue( (cAliasACB)->(BENANT))
		    oSec1:Cell("BENPER"):SetValue( (cAliasACB)->(BENPER))
		    oSec1:Cell("BENTOTAL"):SetValue( (cAliasACB)->(BENTOTAL))
			oSec1:Cell("SDOCARGAS"):SetValue( (cAlias)->(ENTTOTAL)-(cAliasACB)->(BENTOTAL))
			oSec1:Cell("BENANTKG"):SetValue( (cAliasACB)->(BENANTKG))
 		    oSec1:Cell("BENPERKG"):SetValue( (cAliasACB)->(BENPERKG))
		    oSec1:Cell("BENTOTALKG"):SetValue( (cAliasACB)->(BENTOTALKG))
			oSec1:Cell("SALDOKG"):SetValue( (cAlias)->(ENTTOTALKG)-(cAliasACB)->(BENTOTALKG))
			oSec1:Init()
			oSec1:PrintLine()				
		Endif
		oSec1:Finish()
		
		Begin Report Query oSec2
				
			BeginSql Alias cAliasAPB
					
				/* ALGODÃO EM PLUMA BENEFICIAMENTO*/
				SELECT DXI_PRDTOR AS DXI_PRDTOR,NJ0_NOME AS DXI_PRODUTOR,
				       COUNT(CASE WHEN DXL_DTBEN <  %exp:dtos(mv_par10)% THEN DXI_CODIGO ELSE NULL END) AS BENANT,
				       COUNT(CASE WHEN DXL_DTBEN >= %exp:dtos(mv_par10)% THEN DXI_CODIGO ELSE NULL END) AS BENPER,
				       COUNT(DXI_CODIGO) AS BENTOTAL,
				       SUM(CASE WHEN DXL_DTBEN <  %exp:dtos(mv_par10)% THEN DXI_PSLIQU ELSE 0 END) AS BENANTKG,
				       SUM(CASE WHEN DXL_DTBEN >= %exp:dtos(mv_par10)% THEN DXI_PSLIQU ELSE 0 END) AS BENPERKG,
				       SUM(DXI_PSLIQU) AS BENTOTALKG
				FROM %table:DXI% DXI
				LEFT JOIN %table:NJ0% NJ0
                  ON NJ0_FILIAL = DXI_FILIAL AND
                     NJ0_CODENT = DXI_PRDTOR AND
                     NJ0_LOJENT	= DXI_LJPRO
				LEFT JOIN %table:DXL% DXL
                  ON DXL_CODIGO = DXI_FARDAO                      
					   WHERE DXI_PRDTOR = %exp:(cAlias)->(DXM_PRDTOR)%
					     AND %exp:cQueryAux3%
					GROUP BY DXI_PRDTOR,NJ0_NOME
			EndSql 

		End Report Query oSec2
		
        (cAliasAPB)->(dbGoTop())
		
		BeginSql Alias cAliasAPS
			/* ALGODÃO EM PLUMA Saída*/
			SELECT COUNT(CASE WHEN DXS_DATA <  %exp:dtos(mv_par10)% THEN DXI_ROMSAI ELSE NULL END) AS SAIANT, 
			       COUNT(CASE WHEN DXS_DATA >= %exp:dtos(mv_par10)% THEN DXI_ROMSAI ELSE NULL END) AS SAIPER, 
			       COUNT(DXI_ROMSAI) AS SAITOTAL, 
			       SUM(CASE WHEN DXS_DATA <  %exp:dtos(mv_par10)% THEN DXI_PSLIQU ELSE 0 END) AS SAIANTKG,
			       SUM(CASE WHEN DXS_DATA >= %exp:dtos(mv_par10)% THEN DXI_PSLIQU ELSE 0 END) AS SAIPERKG,
			       SUM(DXI_PSLIQU) AS SAITOTALKG
			       FROM %Table:DXI% DXI
			       INNER JOIN %Table:DXS% DXS
			       ON DXS_CODIGO = DXI_ROMSAI
				WHERE DXI_PRDTOR = %exp:(cAlias)->(DXM_PRDTOR)%
				  AND %exp:cQueryAux4%
		
		EndSql 

     	(cAliasAPS)->(dbGoTop())
		If (cAliasAPS)->(!Eof())
		
			oSec2:Cell("DXI_PRODUTOR"):SetValue( (cAliasAPB)->(DXI_PRODUTOR))
			oSec2:Cell("BENANT"):SetValue( (cAliasAPB)->(BENANT))
			oSec2:Cell("BENPER"):SetValue( (cAliasAPB)->(BENPER))
			oSec2:Cell("BENTOTAL"):SetValue( (cAliasAPB)->(BENANT) + (cAliasAPB)->(BENPER))
		    oSec2:Cell("SAIANT"):SetValue( (cAliasAPS)->(SAIANT))
		    oSec2:Cell("SAIPER"):SetValue( (cAliasAPS)->(SAIPER))
		    oSec2:Cell("SAITOTAL"):SetValue( (cAliasAPS)->(SAITOTAL))
			oSec2:Cell("SDOFARDOS"):SetValue( (cAliasAPB)->(BENTOTAL) - (cAliasAPS)->(SAITOTAL))			
			oSec2:Cell("BENANTKG"):SetValue( (cAliasAPB)->(BENANTKG))
			oSec2:Cell("BENPERKG"):SetValue( (cAliasAPB)->(BENPERKG))
			oSec2:Cell("BENTOTALKG"):SetValue( (cAliasAPB)->(BENANTKG) + (cAliasAPB)->(BENPERKG))
			oSec2:Cell("SAIANTKG"):SetValue( (cAliasAPS)->(SAIANTKG))
 		    oSec2:Cell("SAIPERKG"):SetValue( (cAliasAPS)->(SAIPERKG))
		    oSec2:Cell("SAITOTALKG"):SetValue( (cAliasAPS)->(SAITOTALKG))
			oSec2:Cell("SALDOKG"):SetValue( (cAliasAPB)->(BENTOTALKG) -(cAliasAPS)->(SAITOTALKG))
			oSec2:Init()
			oSec2:PrintLine()
		Endif
		oSec2:Finish()
		
		Begin Report Query oSec3
			BeginSql Alias cAliasCP
					
				// CAROÇO PRODUÇÃO
				SELECT DXL_PRDTOR AS DXL_PRDTOR,NJ0_NOME AS DXL_PRODUTOR,
				       SUM(CASE WHEN DXL.DXL_DTBEN <  %exp:dtos(mv_par10)% THEN DXL.DXL_PSLIQU ELSE 0 END) AS PRDANTKG, 
				       SUM(CASE WHEN DXL.DXL_DTBEN >= %exp:dtos(mv_par10)% THEN DXL.DXL_PSLIQU ELSE 0 END) AS PRDPERKG,
				       SUM(DXL.DXL_PSLIQU) AS PRDTOTALKG
					 FROM %Table:DXL% DXL
					LEFT JOIN %table:NJ0% NJ0
                  ON NJ0_CODENT = DXL_PRDTOR					        
					  WHERE DXL_PRDTOR = %exp:(cAlias)->(DXM_PRDTOR)%
				        AND DXL.DXL_DTBEN <= %exp:dtos(mv_par11)%
				        AND %exp:StrTran(cQueryAux2,'AND','')%
				        GROUP BY DXL_PRDTOR,NJ0_NOME								     
		    
		    EndSql 
			
		End Report Query oSec3
        
        (cAliasCP)->(dbGoTop())
		
		BeginSql Alias cAliasAux
			// CAROÇO SAÍDA
			SELECT DXL_PRDTOR AS DXL_PRDTOR,NJ0_NOME AS DXL_PRODUTOR,
	         		SUM(DXL.DXL_PSLIQU * DXC_PERC)/100 AS PESO_PROD_CAROCO, 
       			SUM(DXL_PSLIQU) AS PESO_FARDAO,
       			AVG(DXC_PERC) AS PERC_CAROCO,
       			AVG(DXL_RDMTO / 100) AS REDIMENTO,
       			AVG((DXL.DXL_PSLIQU) / DXL_RDMTO * 100) AS APLICACAO   
			FROM %Table:DXL% DXL
			LEFT JOIN  %Table:NJ0% NJ0  ON 
					NJ0_FILIAL = DXL_FILIAL 
					AND NJ0_CODENT = DXL.DXL_PRDTOR 
					AND  NJ0_LOJENT =  DXL.DXL_LJPRO 
			LEFT JOIN  %Table:DXI% DXI  ON 
					DXI_FILIAL = DXL_FILIAL 
					AND DXI_FARDAO = DXL.DXL_CODIGO
			LEFT JOIN  %Table:DXE% DXE  ON 
					DXE_FILIAL = DXL_FILIAL 
					AND DXE_CODIGO = DXI.DXI_CODCNJ
			LEFT JOIN  %Table:DXC% DXC  ON 
					DXC_FILIAL = DXL_FILIAL 
					AND DXC_CODIGO = DXE.DXE_CODIGO  
					AND DXC_CODPRO = %exp:(mv_par10)%
			WHERE DXL.DXL_PRDTOR = %exp:(cAlias)->(DXM_PRDTOR)%
			   	    AND DXL.DXL_PSLIQU <> 0
			   	    AND DXL.DXL_RDMTO <> 0
				    AND %exp:StrTran(cQueryAux2,'AND','')%	
			GROUP BY DXL_PRDTOR,NJ0_NOME		
		EndSql 

		Begin Report Query oSec4		
			BeginSql Alias cAliasAPP
				// Prensa
				SELECT DXL_PRDTOR AS DXL_PRDTOR,NJ0_NOME AS DXL_PRODUTOR,
						DXI_PRENSA AS PRENSA,COUNT(DXI_CODIGO) AS BENETOTAL,
						COUNT(CASE WHEN DXL_DTBEN <  %exp:dtos(mv_par10)% THEN DXI_CODIGO ELSE NULL END) AS BENEANT,
						COUNT(CASE WHEN DXL_DTBEN >= %exp:dtos(mv_par10)% THEN DXI_CODIGO ELSE NULL END) AS BENEPER,
						AVG(CASE WHEN DXL_DTBEN <  %exp:dtos(mv_par10)% THEN DXL_RDMTO ELSE NULL END) AS RENANT,
						AVG(CASE WHEN DXL_DTBEN >= %exp:dtos(mv_par10)% THEN DXL_RDMTO ELSE NULL END) AS RENPER,
						AVG(DXL_RDMTO) AS RENTOTAL
				FROM %Table:DXI% DXI
				LEFT JOIN  %Table:DXL% DXL  ON 
						DXL_FILIAL = DXI_FILIAL 
						AND DXI_FARDAO = DXL.DXL_CODIGO
				LEFT JOIN  %Table:NJ0% NJ0  ON 
						NJ0_FILIAL = DXI_FILIAL 
						AND NJ0_CODENT = DXL.DXL_PRDTOR 
						AND NJ0_LOJENT = DXL.DXL_LJPRO 
				LEFT JOIN  %Table:DXE% DXE  ON 
						DXE_FILIAL = DXI_FILIAL 
						AND DXE_CODIGO = DXI.DXI_CODCNJ
				LEFT JOIN  %Table:DXC% DXC  ON 
						DXC_FILIAL = DXI_FILIAL 
						AND DXC_CODIGO = DXE.DXE_CODIGO  
						AND DXC_CODPRO = %exp:(mv_par10)%
				WHERE DXL.DXL_PRDTOR = %exp:(cAlias)->(DXM_PRDTOR)%
				   	     AND DXL.DXL_PSLIQU <> 0
				   	     AND DXL.DXL_RDMTO <> 0
				   	     AND DXL.DXL_DTBEN < %exp:dtos(mv_par11)%
					     AND %exp:StrTran(cQueryAux2,'AND','')%	
				GROUP BY DXL_PRDTOR,NJ0_NOME,DXI_PRENSA		
			EndSql 
		End Report Query oSec4
	
     	(cAliasAux)->(dbGoTop())
		if (cAliasAux)->(!Eof())

		    oSec3:Cell("SAIANTKG"):SetValue( (cAliasAPS)->(SAIANTKG) * (cAliasAux)->(APLICACAO))
 		    oSec3:Cell("SAIPERKG"):SetValue( (cAliasAPS)->(SAIPERKG) * (cAliasAux)->(APLICACAO))
		    oSec3:Cell("SAITOTALKG"):SetValue( (cAliasAPS)->(SAITOTALKG) * (cAliasAux)->(APLICACAO))
			oSec3:Cell("SALDOKG"):SetValue( (cAliasCP)->(PRDTOTALKG)-((cAliasAPS)->(SAITOTALKG) * (cAliasAux)->(APLICACAO)))
			oSec3:Init()
			oSec3:PrintLine()
			(cAliasAux)->(dbskip())
			oSec3:Finish()
     		(cAliasAPP)->(dbGoTop())
			If (cAliasAPP)->(!Eof())
				oSec4:Cell("DXL_PRODUTOR"):SetValue( (cAliasAux)->(DXL_PRODUTOR))
				oSec4:Init()
				oSec4:PrintLine()
				(cAliasAPP)->(dbskip())
			Endif
			oSec4:Finish()				
		Endif
		
		(cAliasAux)->(dbCloseArea())
		(cAliasACB)->(dbCloseArea())
		(cAliasAPB)->(dbCloseArea())
		(cAliasAPP)->(dbCloseArea())
		(cAliasCP) ->(dbCloseArea())
		(cAliasAPS)->(dbCloseArea())
				
		(cAlias)->(dbSkip())
	End	

	(cAlias)->(dbCloseArea())
						
#ENDIF

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} UBARCabec
Função para montar cabecalho do relatorio  

@param oReport Objeto para manipulação das seções, atributos e dados do relatório.
@return aCabec  Array com o cabecalho montado
@author Aécio Gomes
@since 21/06/2013
@version MP11.8
/*/
//----------------------------------------------------------------------------------
Static Function UBARCabec(oReport, cSafra)
Local aCabec := {}
Local cNmEmp	:= ""   
Local cNmFilial	:= ""   
Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabeçalho

Default cSafra := ""

If SM0->(Eof())
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

cNmEmp	 := AllTrim( SM0->M0_NOME )
cNmFilial:= AllTrim( SM0->M0_FILIAL )

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
AADD(aCabec, STR0037 + cNmEmp) //Esquerda
aCabec[5] += Space(9) // Meio
If !Empty(cSafra)
	aCabec[5] += Space(9)+ STR0039+cSafra   // Direita
EndIf	

// Linha 6
AADD(aCabec, STR0038 + cNmFilial) //Esquerda

Return(aCabec)
