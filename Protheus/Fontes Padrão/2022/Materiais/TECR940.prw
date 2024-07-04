#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR940.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR940()
Endereço de Cliente

@sample 	TECR940()

@return		oReport, 	Object,	Objeto do relatório de Endereço de Cliente

@author 	Kaique Schiller
@since		14/06/2021
/*/

//--------------------------------------------------------------------------------------------------------------------
Function TECR940()
Local cPerg		:= "TECR940"
Local oReport	:= Nil 

If TRepInUse() 
	Pergunte(cPerg,.F.)	
	oReport := Rt940RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()	
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt940RDef()
Endereço de Cliente - monta as Sections para impressão do relatório

@sample Rt940RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		14/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt940RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				 
Local oSection2  	:= Nil				 
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR940",STR0001,cPerg,{|oReport| Rt940Print(oReport, cPerg, cAlias1)},STR0001) //"Endereço de Cliente"

oSection1 := TRSection():New(oReport	,FwX2Nome("SA1") ,{"SA1"},,,,,,,,,,,,,.T.)
DEFINE CELL NAME "A1_COD"		OF oSection1 ALIAS "SA1" TITLE STR0002  //"Cod. Cli."
DEFINE CELL NAME "A1_LOJA"		OF oSection1 ALIAS "SA1" SIZE 5			 
DEFINE CELL NAME "A1_NOME"		OF oSection1 ALIAS "SA1" 				 

oSection2 := TRSection():New(oSection1	,FwX2Nome("ABS") ,{"ABS"},,,,,,,,,,3,,,.T.) //Cliente
DEFINE CELL NAME "ABS_LOCAL"	OF oSection2 ALIAS "ABS" TITLE STR0003 //"Cod. Loc." 
DEFINE CELL NAME "ABS_DESCRI"	OF oSection2 ALIAS "ABS" 					
DEFINE CELL NAME "ABS_END"		OF oSection2 ALIAS "ABS" 						
DEFINE CELL NAME "ABS_BAIRRO"	OF oSection2 ALIAS "ABS" 					
DEFINE CELL NAME "ABS_MUNIC"	OF oSection2 ALIAS "ABS" 					
			
Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt940Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt940Print(oReport, cPerg, cAlias1)

@param		oReport, 	Object,	Objeto do relatório
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum

@author 	Kaique Schiller
@since		14/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt940Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1)

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT 	A1_COD,
			A1_LOJA,
            A1_NOME,
            ABS_CODIGO,
			ABS_LOCAL,
			ABS_DESCRI,
			ABS_END,
			ABS_BAIRRO,
			ABS_MUNIC
	FROM %table:SA1% SA1
	INNER JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS% AND
	 							  ABS.ABS_CODIGO = SA1.A1_COD    AND 
	 							  ABS.ABS_LOJA   = SA1.A1_LOJA   AND 
	 							  ABS.%NotDel%
	WHERE SA1.A1_FILIAL=%xFilial:SA1%
  	  AND SA1.%NotDel% 
  	  AND EXISTS( SELECT TFL_CODIGO 
  	  			  FROM %table:TFL% TFL 
 				  INNER JOIN %table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ%  AND
				 							    TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND
				 							    TFJ.TFJ_STATUS = '1'    		AND
				 							    TFJ.%NotDel%				

  	  			  WHERE TFL.TFL_FILIAL = %xFilial:TFL%
                    AND TFL.TFL_LOCAL  = ABS.ABS_LOCAL
                    AND TFL.TFL_ENCE   <> '2'
               	    AND %Exp:dTos(MV_PAR01)% 	BETWEEN TFL.TFL_DTINI AND TFL.TFL_DTFIM
                    AND TFL.%NotDel% )

  	  AND SA1.A1_COD 	BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04% 
  	  AND SA1.A1_LOJA   BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
  	  AND ABS.ABS_LOCAL BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
      
  	ORDER BY A1_COD,A1_LOJA,ABS_LOCAL
	
EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->(A1_COD+A1_LOJA) == cParam},{|| (cAlias1)->(A1_COD+A1_LOJA) })

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)
